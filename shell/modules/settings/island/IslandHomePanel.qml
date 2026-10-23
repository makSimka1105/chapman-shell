import QtQuick
import qs.core
import qs.services
import qs.widgets

Rectangle {
    id: root

    property var entry: null
    readonly property var meta: entry ? IslandCatalog.widget(entry.id) : null

    signal spanPicked(int span)
    signal toggled

    height: Tokens.widgetRowHeight
    radius: Tokens.radiusCard
    color: Theme.card

    Label {
        anchors.centerIn: parent
        visible: root.entry === null
        text: "Выберите виджет в превью"
        font.pixelSize: Tokens.fontBody
        color: Theme.textDim
    }

    Glyph {
        id: icon
        x: Tokens.marginRow
        anchors.verticalCenter: parent.verticalCenter
        visible: root.entry !== null
        text: root.meta?.glyph ?? ""
        color: Theme.accent
    }

    Label {
        anchors.left: icon.right
        anchors.leftMargin: Tokens.spacingRelaxed
        anchors.verticalCenter: parent.verticalCenter
        visible: root.entry !== null
        text: root.meta?.name ?? ""
        font.pixelSize: Tokens.fontMedium
    }

    Row {
        anchors.right: parent.right
        anchors.rightMargin: Tokens.marginRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: Tokens.spacingMedium
        visible: root.entry !== null

        SegmentedControl {
            anchors.verticalCenter: parent.verticalCenter
            options: [{ id: "1", label: "1 колонка" }, { id: "2", label: "2 колонки" }]
            current: String(root.entry?.span ?? 1)
            onPicked: id => root.spanPicked(Number(id))
        }

        Toggle {
            anchors.verticalCenter: parent.verticalCenter
            checked: root.entry?.enabled ?? false
            onToggled: root.toggled()
        }
    }
}
