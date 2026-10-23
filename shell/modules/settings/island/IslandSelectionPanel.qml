import QtQuick
import qs.core
import qs.services
import qs.widgets

Rectangle {
    id: root

    property var entry: null
    readonly property var meta: entry ? IslandCatalog.widget(entry.id) : null
    readonly property var variants: meta?.variants ?? []

    signal patched(var patch)

    implicitHeight: entry === null ? Tokens.widgetRowHeight : body.height + 2 * Tokens.marginRow
    radius: Tokens.radiusCard
    color: Theme.card

    Label {
        anchors.centerIn: parent
        visible: root.entry === null
        text: "Выберите виджет в превью"
        font.pixelSize: Tokens.fontBody
        color: Theme.textDim
    }

    Column {
        id: body
        x: Tokens.marginRow
        y: Tokens.marginRow
        width: parent.width - 2 * Tokens.marginRow
        visible: root.entry !== null
        spacing: Tokens.spacingMedium

        Item {
            width: parent.width
            height: Tokens.iconButtonSize

            Glyph {
                id: icon
                anchors.verticalCenter: parent.verticalCenter
                text: root.meta?.glyph ?? ""
                color: Theme.accent
            }

            Label {
                anchors.left: icon.right
                anchors.leftMargin: Tokens.spacingRelaxed
                anchors.verticalCenter: parent.verticalCenter
                text: root.meta?.name ?? ""
                font.pixelSize: Tokens.fontMedium
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: Tokens.spacingMedium

                Dropdown {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.variants.length > 1 && root.entry?.variant !== undefined
                    options: root.variants.map(variant => ({ id: variant.id, label: variant.name }))
                    current: root.entry?.variant ?? ""
                    onPicked: id => root.patched({ variant: id })
                }

                Toggle {
                    anchors.verticalCenter: parent.verticalCenter
                    checked: root.entry?.enabled ?? false
                    onToggled: root.patched({ enabled: !root.entry.enabled })
                }
            }
        }

        IslandSliderRow {
            width: parent.width
            title: "Доля свободного места"
            value: root.entry?.grow ?? 0
            to: 4
            step: 0.5
            onMoved: value => root.patched({ grow: value })
        }

        IslandSliderRow {
            width: parent.width
            title: "Минимальная ширина"
            value: root.entry?.minWidth ?? 0
            to: 200
            step: 5
            suffix: " px"
            onMoved: value => root.patched({ minWidth: value })
        }

        IslandSliderRow {
            width: parent.width
            title: "Приоритет"
            value: root.entry?.priority ?? 0
            to: 10
            onMoved: value => root.patched({ priority: value })
        }
    }
}
