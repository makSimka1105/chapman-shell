import QtQuick
import qs.core
import qs.services
import qs.widgets

Column {
    id: root

    property string title
    property string note
    property real used: 0
    property real pace: -1
    property color tint: Theme.accent

    spacing: Tokens.spacingCompact

    Item {
        width: parent.width
        height: caption.height

        Label {
            id: caption

            text: root.title
            font.pixelSize: Tokens.fontBody
            font.weight: Font.DemiBold
        }

        Label {
            anchors.right: parent.right
            text: root.note
            color: Theme.textDim
            font.pixelSize: Tokens.fontSmall
        }
    }

    Rectangle {
        width: parent.width
        height: Tokens.trackHeight
        radius: Tokens.radiusBar
        color: Theme.faint

        Rectangle {
            width: Math.max(parent.height, parent.width * Math.min(1, root.used))
            height: parent.height
            radius: Tokens.radiusBar
            color: root.used > 0.85 ? Theme.warning : root.tint
        }

        Rectangle {
            visible: root.pace >= 0
            x: parent.width * Math.min(1, root.pace) - 1
            y: -3
            width: 2
            height: 14
            color: Theme.text
            opacity: 0.7
        }
    }
}
