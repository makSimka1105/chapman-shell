import QtQuick
import qs.core
import qs.services
import qs.widgets

Column {
    id: root

    readonly property int shown: 40
    readonly property string needle: search.text.trim().toLowerCase()
    readonly property var matches: Themes.schemes.filter(scheme => scheme.name.toLowerCase().includes(needle)).slice(0, shown)
    property var imported: []

    spacing: Tokens.spacingMedium
    Component.onCompleted: Themes.loadSchemes()

    Label {
        width: parent.width
        text: "Цветовые схемы ghostty: тема получает палитру схемы и стекло темы glass. Обои добавь потом во вкладке «Темы»."
        wrapMode: Text.WordWrap
        color: Theme.textDim
        font.pixelSize: Tokens.fontBody
    }

    TextField {
        id: search
        width: parent.width
        placeholder: "Поиск среди " + Themes.schemes.length + " схем"
    }

    Repeater {
        model: root.matches

        Rectangle {
            id: scheme

            required property var modelData
            readonly property bool done: root.imported.includes(modelData.name)

            width: root.width
            height: 48
            radius: Tokens.radiusRow
            color: Theme.card

            Label {
                anchors.left: parent.left
                anchors.leftMargin: Tokens.marginRow
                anchors.verticalCenter: parent.verticalCenter
                text: scheme.modelData.name
                font.pixelSize: Tokens.fontLabel
                font.weight: Font.DemiBold
            }

            Rectangle {
                anchors.right: action.left
                anchors.rightMargin: Tokens.marginMedium
                anchors.verticalCenter: parent.verticalCenter
                width: swatches.width + 2 * Tokens.spacingItem
                height: 26
                radius: 13
                color: scheme.modelData.background
                border.color: Theme.faint

                Row {
                    id: swatches
                    anchors.centerIn: parent
                    spacing: Tokens.spacingCompact

                    Repeater {
                        model: scheme.modelData.palette.slice(1, 7)

                        Rectangle {
                            required property string modelData

                            width: 14
                            height: 14
                            radius: 7
                            color: modelData
                        }
                    }
                }
            }

            IconButton {
                id: action
                anchors.right: parent.right
                anchors.rightMargin: Tokens.marginRow
                anchors.verticalCenter: parent.verticalCenter
                enabled: !scheme.done
                glyph: scheme.done ? "󰄬" : "󰋺"
                label: scheme.done ? "Готово" : "Импорт"
                onClicked: {
                    Themes.importScheme(scheme.modelData.name);
                    root.imported = [...root.imported, scheme.modelData.name];
                }
            }
        }
    }

    Label {
        visible: Themes.schemes.length > 0 && root.matches.length === root.shown
        text: "Показаны первые " + root.shown + ", уточни поиск"
        color: Theme.textDim
        font.pixelSize: Tokens.fontSmall
    }
}
