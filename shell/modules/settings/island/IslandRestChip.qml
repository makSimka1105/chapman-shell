import QtQuick
import qs.core
import qs.services
import qs.widgets

IslandChip {
    id: root

    property var widgets
    readonly property var meta: IslandCatalog.widget(entry.id)
    readonly property real padding: zone.wrap ? Tokens.spacingItem : 0
    readonly property bool live: preview.item !== null && preview.item.present

    implicitWidth: (live ? preview.item.width : Tokens.fontIcon) + 2 * padding
    implicitHeight: Tokens.segmentHeight

    Loader {
        id: preview
        x: root.padding
        anchors.verticalCenter: parent.verticalCenter
        visible: root.live
        sourceComponent: root.widgets.component(root.entry.id)
    }

    Binding {
        target: preview.item
        property: "variant"
        value: root.entry.variant ?? ""
        when: preview.item !== null
    }

    Glyph {
        anchors.centerIn: parent
        visible: !root.live
        text: root.meta?.glyph ?? ""
        color: Theme.textDim
    }
}
