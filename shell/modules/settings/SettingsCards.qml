import QtQuick
import qs.core
import qs.services
import qs.widgets
import qs.modules.themes

Flow {
    id: root

    required property var row
    readonly property bool wallpapers: row.type === "wallpapers"

    readonly property int columns: wallpapers ? 3 : 4
    readonly property real cellWidth: (width - (columns - 1) * spacing) / columns

    spacing: Tokens.spacingMedium

    Repeater {
        model: root.row.items()

        Loader {
            required property var modelData

            sourceComponent: root.wallpapers ? thumb : card

            Component {
                id: card

                ThemeCard {
                    width: root.cellWidth
                    height: Tokens.themeCardHeight
                    theme: modelData
                    removable: modelData.user && root.row.remove !== undefined
                    onClicked: root.row.write(modelData.id)
                    onRemoved: root.row.remove(modelData.id)
                }
            }

            Component {
                id: thumb

                WallpaperThumb {
                    width: root.cellWidth
                    height: root.cellWidth * Tokens.wallpaperThumbHeight / Tokens.wallpaperThumbWidth
                    source: modelData
                    current: modelData === root.row.read()
                    removable: root.row.remove !== undefined
                    onClicked: root.row.write(modelData)
                    onRemoved: root.row.remove(modelData)
                }
            }
        }
    }
}
