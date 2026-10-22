import QtQuick
import qs.core
import qs.services
import qs.widgets

Rectangle {
    id: root

    property string title
    default property alias content: body.data

    implicitHeight: column.implicitHeight + 28
    radius: Tokens.radiusCard
    color: Theme.card

    Column {
        id: column

        x: 14
        y: 14
        width: parent.width - 28
        spacing: Tokens.spacingRelaxed

        Label {
            visible: root.title !== ""
            text: root.title.toUpperCase()
            color: Theme.textDim
            font.pixelSize: Tokens.fontCaption
            font.weight: Font.DemiBold
            font.letterSpacing: 1
        }

        Column {
            id: body

            width: parent.width
            spacing: Tokens.spacingRelaxed
        }
    }
}
