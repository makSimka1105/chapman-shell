import QtQuick
import qs.services
import qs.widgets

Row {
    id: root

    required property string title

    spacing: 8

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 6
        height: 6
        radius: 3
        color: Theme.accent
    }

    Label {
        width: 150
        text: root.title
        elide: Text.ElideRight
        font.pixelSize: 15
        font.weight: Font.Medium
    }
}
