import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.core
import qs.services
import qs.widgets

PanelWindow {
    id: root

    property bool opened
    property bool revealed
    property int selected: 0
    property int armed: -1
    readonly property var results: search.build(field.text)
    readonly property bool showPreview: results.length > 0
    readonly property real compactWidth: 680
    readonly property real previewWidth: 360
    readonly property real minContentHeight: 320
    readonly property real fieldHeight: 60
    readonly property real rowHeight: 52
    readonly property real headerHeight: 28
    readonly property int visibleRows: 8
    readonly property real radius: Tokens.radiusPanel
    readonly property real gap: 12

    SpotlightSearch {
        id: search
    }

    function toggle(query) {
        if (opened)
            close();
        else
            open(query);
    }

    function open(query) {
        Themes.refresh();
        Clipboard.refresh();
        field.text = query;
        revealed = false;
        shot.capture(screen.name);
        revealFallback.restart();
        opened = true;
        field.forceActiveFocus();
    }

    function close() {
        opened = false;
        revealed = false;
    }

    function activate(index) {
        const item = results[index];
        if (!item || item.header)
            return;
        if (item.prefill !== undefined) {
            field.text = item.prefill;
            return;
        }
        if (item.confirm && armed !== index) {
            armed = index;
            return;
        }
        item.run();
        close();
    }

    function rowY(index) {
        return results.slice(0, index).reduce((y, item) => y + (item.header ? headerHeight : rowHeight), 0);
    }

    function firstItem() {
        return results.findIndex(item => !item.header);
    }

    function move(step) {
        if (firstItem() < 0)
            return;
        let index = selected;
        do
            index = (index + step + results.length) % results.length;
        while (results[index].header);
        selected = index;
    }

    screen: Quickshell.screens.find(s => s.name === Niri.focusedOutput) ?? Quickshell.screens[0]
    visible: opened || content.opacity > 0
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "spotlight"
    WlrLayershell.keyboardFocus: opened ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    onResultsChanged: {
        if (selected >= results.length || results[selected].header)
            selected = Math.max(0, firstItem());
    }
    onSelectedChanged: armed = -1

    Backdrop {
        id: shot
        anchors.fill: parent
        name: "spotlight"
        onCaptured: if (root.opened) root.revealed = true
    }

    Timer {
        id: revealFallback
        interval: 400
        onTriggered: if (root.opened) root.revealed = true
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.opened
        onClicked: root.close()
    }

    GlassContext {
        id: glass
        backdrop: shot
        region: Qt.rect(content.x - 96, content.y - 96, content.width + 192, content.height + 192)
    }

    Item {
        id: content

        property real openT: root.revealed ? 1 : 0

        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.22
        width: root.showPreview ? root.compactWidth + root.previewWidth : root.compactWidth
        height: field.height + root.gap + slab.height
        opacity: Math.min(1, openT * 2.2)
        scale: 0.9 + 0.1 * openT
        transformOrigin: Item.Top

        Behavior on openT {
            NumberAnimation {
                duration: root.revealed ? Tokens.durationReveal : Tokens.durationQuick
                easing.type: root.revealed ? Easing.OutBack : Easing.OutCubic
                easing.overshoot: Tokens.overshootStrong
            }
        }

        Behavior on width {
            NumberAnimation {
                duration: 420
                easing.type: Easing.OutBack
                easing.overshoot: Tokens.overshootMild
            }
        }

        SpotlightField {
            id: field

            width: parent.width
            height: root.fieldHeight
            glass: glass
            onTextChanged: {
                root.selected = 0;
                root.armed = -1;
                Files.search(/^[@#=:]/.test(text.trim()) ? "" : text);
            }
            onEscaped: root.close()
            onMoved: step => root.move(step)
            onSubmitted: root.activate(root.selected)
        }


        Item {
            id: slab

            y: field.height + root.gap
            width: parent.width
            height: root.showPreview ? Math.max(list.height, root.minContentHeight) + 18 : 0
            visible: height > 1

            Behavior on height {
                NumberAnimation {
                    duration: Tokens.durationEntrance
                    easing.type: root.showPreview ? Easing.OutBack : Easing.OutCubic
                    easing.overshoot: Tokens.overshootSoft
                }
            }

            GlassSurface {
                anchors.fill: parent
                context: glass
                cornerRadius: root.radius
                thickness: 26
                shadow: 0.6
            }

            MouseArea {
                anchors.fill: parent
            }

            Item {
                anchors.fill: parent
                clip: true

                SpotlightResults {
                    id: list
                    y: 9
                    x: 9
                    width: root.compactWidth - 18
                    height: Math.min(contentHeight, root.visibleRows * root.rowHeight)
                    model: root.results
                    currentIndex: root.selected
                    rowHeight: root.rowHeight
                    headerHeight: root.headerHeight
                    highlightY: root.rowY(root.selected)
                    highlightArmed: root.armed === root.selected
                    armed: root.armed
                    collapsed: slab.height < root.rowHeight
                    onHovered: index => root.selected = index
                    onClicked: index => root.activate(index)
                }


                Rectangle {
                    anchors.top: parent.top
                    anchors.topMargin: Tokens.marginPanel
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Tokens.marginPanel
                    x: root.compactWidth
                    width: 1
                    color: Qt.alpha(Theme.text, 0.08)
                }

                Preview {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    width: root.previewWidth
                    item: root.results[root.selected] ?? null
                }
            }
        }
    }
}
