import QtQuick
import qs.core
import qs.services
import qs.widgets

IslandChip {
    id: root

    readonly property var meta: IslandCatalog.widget(entry.id)

    implicitWidth: zone.vertical ? zone.width : label.x + label.implicitWidth + Tokens.marginInner
    implicitHeight: Tokens.widgetRowHeight - Tokens.spacingItem

    Rectangle {
        anchors.fill: parent
        radius: Tokens.radiusChip
        color: Qt.alpha(Theme.text, 0.06)
        visible: zone.vertical
    }

    Glyph {
        id: icon
        x: Tokens.marginInner
        anchors.verticalCenter: parent.verticalCenter
        text: root.meta?.glyph ?? ""
        color: Theme.accent
    }

    Label {
        id: label
        x: icon.x + icon.implicitWidth + Tokens.spacingRelaxed
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(implicitWidth, root.width - x - Tokens.spacingItem)
        text: root.meta?.name ?? root.entry.id
        elide: Text.ElideRight
        font.pixelSize: Tokens.fontBody
    }

    Label {
        anchors.right: parent.right
        anchors.rightMargin: Tokens.marginInner
        anchors.verticalCenter: parent.verticalCenter
        visible: root.entry.span === 2
        text: "x2"
        font.pixelSize: Tokens.fontCaption
        color: Theme.textDim
    }
}
