import QtQuick
import qs.core
import qs.services
import qs.widgets

Rectangle {
    id: root

    property string title
    property string value
    property string note
    property color tint: Theme.text

    implicitHeight: column.implicitHeight + 24
    radius: Tokens.radiusMedia
    color: Theme.card

    Column {
        id: column

        x: 14
        y: 12
        width: parent.width - 28
        spacing: Tokens.spacingTight

        Label {
            text: root.title.toUpperCase()
            color: Theme.textDim
            font.pixelSize: Tokens.fontCaption
            font.weight: Font.DemiBold
            font.letterSpacing: 1
        }

        Label {
            text: root.value
            color: root.tint
            font.pixelSize: Tokens.fontDisplay
            font.weight: Font.Bold
        }

        Label {
            width: parent.width
            text: root.note
            color: Theme.textDim
            font.pixelSize: Tokens.fontSmall
            elide: Text.ElideRight
        }
    }
}
