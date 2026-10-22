import QtQuick
import qs.core
import qs.services
import qs.widgets

Row {
    id: root

    required property string title

    spacing: Tokens.spacingItem

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 6
        height: 6
        radius: Tokens.radiusThin
        color: Theme.accent
    }

    Label {
        width: 150
        text: root.title
        elide: Text.ElideRight
        font.pixelSize: Tokens.fontLabel
        font.weight: Font.Medium
    }
}
