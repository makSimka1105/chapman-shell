import QtQuick
import qs.services
import qs.widgets

Rectangle {
    id: root

    property string title
    property string value
    property string note
    property color tint: Theme.text

    implicitHeight: column.implicitHeight + 24
    radius: 16
    color: Theme.card

    Column {
        id: column

        x: 14
        y: 12
        width: parent.width - 28
        spacing: 3

        Label {
            text: root.title.toUpperCase()
            color: Theme.textDim
            font.pixelSize: 11
            font.weight: Font.DemiBold
            font.letterSpacing: 1
        }

        Label {
            text: root.value
            color: root.tint
            font.pixelSize: 24
            font.weight: Font.Bold
        }

        Label {
            width: parent.width
            text: root.note
            color: Theme.textDim
            font.pixelSize: 12
            elide: Text.ElideRight
        }
    }
}
