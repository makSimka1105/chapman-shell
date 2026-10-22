import QtQuick
import qs.core
import qs.services

Rectangle {
    id: root

    property bool held
    property string header
    property var entries: []
    property bool hoverable: false
    readonly property bool shown: held || (hoverable && (hover.hovered || linger.running))
    property real rowHeight: 36
    property real pickerWidth: 210

    signal picked(int index)

    onHeldChanged: if (!held && hoverable) linger.restart()

    readonly property bool compact: entries.length === 0

    width: compact ? headerLabel.implicitWidth + 28 : pickerWidth
    height: compact ? 32 : 12 + (header !== "" ? 34 : 0) + entries.length * rowHeight + Math.max(0, entries.length - 1) * 2
    radius: 22
    color: Qt.rgba(0.08, 0.08, 0.09, 0.96)
    border.color: Theme.faint
    transformOrigin: Item.Right
    opacity: shown ? 1 : 0
    scale: shown ? 1 : 0.85
    visible: opacity > 0

    Behavior on opacity {
        NumberAnimation {
            duration: Tokens.durationFast
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: Tokens.durationMove
            easing.type: Easing.OutBack
            easing.overshoot: 2
        }
    }

    Timer {
        id: linger
        interval: 220
    }

    HoverHandler {
        id: hover
        enabled: root.hoverable
    }

    Label {
        id: headerLabel
        visible: root.header !== ""
        anchors.left: parent.left
        anchors.leftMargin: root.compact ? 14 : 18
        y: root.compact ? 0 : 10
        height: root.compact ? 32 : 34
        verticalAlignment: Text.AlignVCenter
        text: root.header
        font.pixelSize: root.compact ? 13 : 22
        font.weight: Font.DemiBold
    }

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Tokens.marginTight
        spacing: Tokens.spacingHairline

        Repeater {
            model: root.entries

            ListRow {
                required property var modelData
                required property int index

                width: parent.width
                height: root.rowHeight
                radius: Tokens.radiusChip
                glyph: modelData.glyph
                title: modelData.title
                trailing: active ? "󰄬" : ""
                active: modelData.active
                onClicked: root.picked(index)
            }
        }
    }
}
