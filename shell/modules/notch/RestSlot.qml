import QtQuick
import qs.core

Item {
    id: root

    required property var zone
    required property var layout
    required property RestWidgets widgets
    property real available: 0
    property real contentWidth: 0

    width: available > 0 ? available : contentWidth

    function naturalWidth(slot) {
        return slot.modelData.grow > 0 ? slot.item.implicitWidth : slot.item.width;
    }

    function baseWidth(slot) {
        return Math.max(naturalWidth(slot), slot.modelData.minWidth ?? 0);
    }

    function totalWidth(shown) {
        return shown.reduce((sum, slot) => sum + baseWidth(slot), 0) + layout.gap * Math.max(0, shown.length - 1);
    }

    function weakestIndex(shown) {
        let weakest = 0;
        for (let index = 1; index < shown.length; index++) {
            if ((shown[index].modelData.priority ?? 0) <= (shown[weakest].modelData.priority ?? 0))
                weakest = index;
        }
        return weakest;
    }

    function relayout() {
        const shown = [];
        for (let index = 0; index < repeater.count; index++) {
            const slot = repeater.itemAt(index);
            if (slot === null)
                continue;
            slot.shown = slot.item !== null && slot.item.present;
            if (slot.shown)
                shown.push(slot);
        }
        if (available > 0) {
            while (shown.length > 0 && totalWidth(shown) > available)
                shown.splice(weakestIndex(shown), 1)[0].shown = false;
        }
        const total = totalWidth(shown);
        const growSum = shown.reduce((sum, slot) => sum + (slot.modelData.grow ?? 0), 0);
        const spare = available > 0 && growSum > 0 ? Math.max(0, available - total) : 0;
        const used = total + spare;
        const free = Math.max(0, width - used);
        let x = zone.justify === "end" ? free : zone.justify === "center" ? free / 2 : 0;
        const extra = zone.justify === "between" && shown.length > 1 ? free / (shown.length - 1) : 0;
        for (const slot of shown) {
            const grow = slot.modelData.grow ?? 0;
            slot.planWidth = baseWidth(slot) + (grow > 0 ? spare * grow / growSum : 0);
            slot.x = x;
            x += slot.planWidth + layout.gap + extra;
        }
        contentWidth = used;
    }

    onAvailableChanged: relayout()
    onWidthChanged: relayout()
    onZoneChanged: relayout()
    onLayoutChanged: relayout()

    Repeater {
        id: repeater
        model: root.zone.items.filter(entry => entry.enabled && root.widgets.has(entry.id))

        Loader {
            id: slot

            required property var modelData
            property bool shown: false
            property real planWidth: 0

            anchors.verticalCenter: parent.verticalCenter
            sourceComponent: root.widgets.component(modelData.id)
            visible: shown
            onLoaded: root.relayout()

            Binding {
                target: slot
                property: "width"
                value: slot.planWidth
                when: slot.modelData.grow > 0
            }

            Connections {
                target: slot.item

                function onPresentChanged() {
                    root.relayout();
                }

                function onImplicitWidthChanged() {
                    root.relayout();
                }

                function onWidthChanged() {
                    root.relayout();
                }
            }

            Binding {
                target: slot.item
                property: "variant"
                value: slot.modelData.variant ?? ""
                when: slot.item !== null
            }
        }
    }
}
