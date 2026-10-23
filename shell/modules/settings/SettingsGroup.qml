import QtQuick
import qs.core
import qs.services
import qs.widgets

Column {
    id: root

    required property var group

    spacing: Tokens.spacingItem

    Label {
        x: Tokens.marginRow
        text: root.group.title
        visible: text !== ""
        font.pixelSize: Tokens.fontSmall
        font.weight: Font.DemiBold
        color: Theme.textDim
    }

    Rectangle {
        width: root.width
        height: rows.height
        radius: Tokens.radiusCard
        color: Theme.card

        Column {
            id: rows
            width: parent.width

            Repeater {
                model: root.group.rows

                Column {
                    id: entry

                    required property var modelData
                    required property int index

                    width: rows.width

                    Rectangle {
                        x: Tokens.marginRow
                        width: parent.width - 2 * Tokens.marginRow
                        height: 1
                        color: Theme.faint
                        visible: entry.index > 0
                    }

                    SettingsRow {
                        width: parent.width
                        row: entry.modelData
                    }
                }
            }
        }
    }
}
