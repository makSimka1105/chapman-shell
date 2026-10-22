import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.widgets
import "../../services/Calc.js" as Calc

PanelWindow {
    id: root

    property bool opened
    property bool revealed
    property int selected: 0
    property int armed: -1
    readonly property var results: build(field.text)
    readonly property bool showPreview: results.length > 0
    readonly property real compactWidth: 680
    readonly property real previewWidth: 360
    readonly property real minContentHeight: 320
    readonly property real fieldHeight: 60
    readonly property real rowHeight: 52
    readonly property real headerHeight: 28
    readonly property int visibleRows: 8
    readonly property real radius: 26
    readonly property real gap: 12

    function toggle(query) {
        if (opened)
            close();
        else
            open(query);
    }

    function group(title, items) {
        return items.length > 0 ? [{ header: true, title }, ...items] : [];
    }

    function calculation(query) {
        const value = Calc.evaluate(query.replace(/^=/, ""));
        if (value === null)
            return [];
        const text = Calc.format(value);
        return [{
            kind: "calc",
            title: text,
            subtitle: query.replace(/^=/, "") + " =",
            glyph: "\uf1ec",
            run: () => Spawn.run(["wl-copy", text])
        }];
    }

    function build(text) {
        const query = text.trim();
        if (query.startsWith("#"))
            return group("Themes", Themes.search(query.slice(1)));
        if (query.startsWith(":"))
            return group("Clipboard", Clipboard.search(query.slice(1)));
        if (query === "")
            return [];
        return [
            ...group("Calculator", calculation(query)),
            ...group("Actions", Actions.search(query)),
            ...group("Applications", Apps.search(query)),
            ...group("Files", Files.items)
        ];
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
        height: pill.height + root.gap + slab.height
        opacity: Math.min(1, openT * 2.2)
        scale: 0.9 + 0.1 * openT
        transformOrigin: Item.Top

        Behavior on openT {
            NumberAnimation {
                duration: root.revealed ? 520 : 150
                easing.type: root.revealed ? Easing.OutBack : Easing.OutCubic
                easing.overshoot: 1.5
            }
        }

        Behavior on width {
            NumberAnimation {
                duration: 420
                easing.type: Easing.OutBack
                easing.overshoot: 1
            }
        }

        Item {
            id: pill

            width: parent.width
            height: root.fieldHeight
            scale: pillPress.pressed ? 0.98 : 1

            Behavior on scale {
                NumberAnimation {
                    duration: 230
                    easing.type: Easing.OutBack
                    easing.overshoot: 3
                }
            }

            Glass {
                anchors.fill: parent
                context: glass
                radius: height / 2
                thickness: 18
                shadow: 0.35
            }

            Contour {
                anchors.fill: parent
                radius: height / 2
                lit: pillHover.hovered
                at: pillHover.point.position
            }

            HoverHandler {
                id: pillHover
            }

            MouseArea {
                id: pillPress
                anchors.fill: parent
                onClicked: field.forceActiveFocus()
            }

            Label {
                id: lens
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.verticalCenter: parent.verticalCenter
                text: "󰍉"
                color: Theme.textDim
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 24
            }

            TextInput {
                id: field
                anchors.left: lens.right
                anchors.leftMargin: 14
                anchors.right: parent.right
                anchors.rightMargin: 24
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.text
                selectionColor: Qt.alpha(Theme.accent, 0.4)
                font.family: Theme.font
                font.pixelSize: 22
                renderType: Text.NativeRendering
                clip: true
                onTextChanged: {
                    root.selected = 0;
                    root.armed = -1;
                    Files.search(/^[@#=:]/.test(text.trim()) ? "" : text);
                }

                Keys.onEscapePressed: root.close()
                Keys.onUpPressed: root.move(-1)
                Keys.onDownPressed: root.move(1)
                Keys.onTabPressed: root.move(1)
                Keys.onBacktabPressed: root.move(-1)
                Keys.onReturnPressed: root.activate(root.selected)
                Keys.onEnterPressed: root.activate(root.selected)

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: field.text === ""
                    text: "Spotlight Search"
                    color: Theme.textDim
                    font.pixelSize: 22
                }
            }
        }

        Item {
            id: slab

            y: pill.height + root.gap
            width: parent.width
            height: root.showPreview ? Math.max(list.height, root.minContentHeight) + 18 : 0
            visible: height > 1

            Behavior on height {
                NumberAnimation {
                    duration: 460
                    easing.type: root.showPreview ? Easing.OutBack : Easing.OutCubic
                    easing.overshoot: 1.2
                }
            }

            Glass {
                anchors.fill: parent
                context: glass
                radius: root.radius
                thickness: 26
                shadow: 0.6
            }

            Contour {
                anchors.fill: parent
                radius: root.radius
                lit: slabHover.hovered
                at: slabHover.point.position
            }

            HoverHandler {
                id: slabHover
            }

            MouseArea {
                anchors.fill: parent
            }

            Item {
                anchors.fill: parent
                clip: true

                ListView {
                    id: list
                    y: 9
                    x: 9
                    width: root.compactWidth - 18
                    height: Math.min(contentHeight, root.visibleRows * root.rowHeight)
                    model: root.results
                    currentIndex: root.selected
                    boundsBehavior: Flickable.StopAtBounds
                    clip: true
                    highlightFollowsCurrentItem: false

                    highlight: Rectangle {
                        y: root.rowY(root.selected)
                        width: list.width
                        height: root.rowHeight
                        radius: 14
                        color: Qt.alpha(root.armed === root.selected ? Theme.warning : Theme.accent, 0.22)

                        Behavior on y {
                            NumberAnimation {
                                duration: 260
                                easing.type: Easing.OutBack
                                easing.overshoot: 1.4
                            }
                        }
                    }

                    delegate: Item {
                        id: row

                        required property var modelData
                        required property int index
                        readonly property bool isArmed: index === root.armed
                        property real arrival: 1

                        width: list.width
                        height: modelData.header ? root.headerHeight : root.rowHeight
                        opacity: Math.min(1, arrival * 1.6)
                        transform: Translate {
                            y: (1 - row.arrival) * 16
                        }
                        Component.onCompleted: {
                            if (slab.height < root.rowHeight) {
                                arrival = 0;
                                arrive.start();
                            }
                        }

                        SequentialAnimation {
                            id: arrive
                            PauseAnimation {
                                duration: Math.min(220, row.index * 40)
                            }
                            NumberAnimation {
                                target: row
                                property: "arrival"
                                to: 1
                                duration: 460
                                easing.type: Easing.OutBack
                                easing.overshoot: 1.8
                            }
                        }

                        Label {
                            anchors.left: parent.left
                            anchors.leftMargin: 14
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 6
                            visible: row.modelData.header === true
                            text: row.modelData.title
                            color: Theme.textDim
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                        }

                        Item {
                            anchors.fill: parent
                            visible: !row.modelData.header
                            scale: rowPress.pressed ? 0.97 : 1

                            Behavior on scale {
                                NumberAnimation {
                                    duration: 230
                                    easing.type: Easing.OutBack
                                    easing.overshoot: 3
                                }
                            }

                            ResultIcon {
                                id: icon
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                width: 32
                                height: 32
                                item: row.modelData
                            }

                            Label {
                                id: name
                                anchors.left: icon.right
                                anchors.leftMargin: 14
                                anchors.verticalCenter: parent.verticalCenter
                                width: Math.min(implicitWidth, parent.width * 0.5)
                                text: row.modelData.title
                                elide: Text.ElideRight
                                font.pixelSize: 16
                                font.weight: Font.Medium
                            }

                            Label {
                                anchors.left: name.right
                                anchors.leftMargin: 10
                                anchors.right: parent.right
                                anchors.rightMargin: 14
                                anchors.baseline: name.baseline
                                text: row.isArmed ? "Press Enter again to confirm" : row.modelData.subtitle ?? ""
                                color: row.isArmed ? Theme.warning : Theme.textDim
                                elide: Text.ElideRight
                                font.pixelSize: 13
                            }

                            MouseArea {
                                id: rowPress
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: root.selected = row.index
                                onClicked: root.activate(row.index)
                            }
                        }
                    }
                }

                Rectangle {
                    anchors.top: parent.top
                    anchors.topMargin: 18
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 18
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
