import QtQuick
import Quickshell
import qs.core
import qs.services
import qs.widgets
import qs.modules.notch

Item {
    id: root

    readonly property var slots: ["left", "center", "right"]
    readonly property var slotTitles: ({ left: "Левая зона", center: "Центр", right: "Правая зона" })
    readonly property var justifyOptions: [
        { id: "start", label: "Начало" },
        { id: "center", label: "Центр" },
        { id: "end", label: "Конец" },
        { id: "between", label: "Поровну" }
    ]
    readonly property var rest: IslandConfig.data.rest
    readonly property bool fixedWidth: typeof rest.layout.width === "number"
    property string selectedId
    readonly property var selectedEntry: slots.reduce((found, slot) => found ?? rest[slot].items.find(entry => entry.id === selectedId) ?? null, null)
    readonly property var trayEntries: IslandCatalog.widgets
        .filter(widget => widget.places.includes("rest") && !slots.some(slot => rest[slot].items.some(entry => entry.id === widget.id)))
        .map(widget => newEntry(widget))

    function newEntry(widget) {
        return widget.variants.length > 0 ? { id: widget.id, enabled: true, variant: widget.variants[0].id } : { id: widget.id, enabled: true };
    }

    function commit(lists) {
        for (const slot of slots) {
            if (JSON.stringify(lists[slot]) !== JSON.stringify(rest[slot].items))
                IslandConfig.set("rest." + slot + ".items", lists[slot]);
        }
    }

    function currentLists() {
        return { left: rest.left.items.slice(), center: rest.center.items.slice(), right: rest.right.items.slice() };
    }

    function applyDrop(fromKey, fromIndex, toKey, toIndex, entry) {
        const lists = currentLists();
        if (fromKey !== "tray")
            lists[fromKey].splice(fromIndex, 1);
        if (toKey !== "tray") {
            const adjusted = fromKey === toKey && fromIndex < toIndex ? toIndex - 1 : toIndex;
            lists[toKey].splice(adjusted, 0, entry);
        }
        commit(lists);
    }

    function patchSelected(patch) {
        const lists = currentLists();
        for (const slot of slots)
            lists[slot] = lists[slot].map(entry => entry.id === selectedId ? Object.assign({}, entry, patch) : entry);
        commit(lists);
    }

    implicitHeight: content.height

    RestWidgets {
        id: restWidgets
        output: Quickshell.screens[0]?.name ?? ""
    }

    Column {
        id: content
        width: parent.width
        spacing: Tokens.marginMedium

        Rectangle {
            width: parent.width
            height: pill.height + Tokens.marginPanel
            radius: Tokens.radiusCard
            color: Theme.card

            Rectangle {
                id: pill
                anchors.horizontalCenter: parent.horizontalCenter
                width: root.fixedWidth ? root.rest.layout.width : IslandConfig.data.size.restWidth > 0 ? IslandConfig.data.size.restWidth : 340
                height: IslandConfig.data.size.restHeight > 0 ? IslandConfig.data.size.restHeight : 40
                color: Theme.body
                topLeftRadius: 0
                topRightRadius: 0
                bottomLeftRadius: 20
                bottomRightRadius: 20

                IslandZone {
                    id: leftZone
                    key: "left"
                    board: dragBoard
                    widgets: restWidgets
                    entries: root.rest.left.items
                    align: root.rest.left.justify
                    gap: root.rest.layout.gap
                    selectedId: root.selectedId
                    x: Tokens.marginPanel
                    width: (pill.width - centerZone.width) / 2 - Tokens.marginPanel - root.rest.layout.zoneGap
                    height: pill.height
                    onPicked: id => root.selectedId = id
                }

                IslandZone {
                    id: centerZone
                    key: "center"
                    board: dragBoard
                    widgets: restWidgets
                    entries: root.rest.center.items
                    align: root.rest.center.justify
                    gap: root.rest.layout.gap
                    selectedId: root.selectedId
                    anchors.centerIn: parent
                    width: Math.max(contentWidth, Tokens.fontIcon)
                    height: pill.height
                    onPicked: id => root.selectedId = id
                }

                IslandZone {
                    key: "right"
                    board: dragBoard
                    widgets: restWidgets
                    entries: root.rest.right.items
                    align: root.rest.right.justify
                    gap: root.rest.layout.gap
                    selectedId: root.selectedId
                    x: pill.width - Tokens.marginWide - width
                    width: leftZone.width + Tokens.marginPanel - Tokens.marginWide
                    height: pill.height
                    onPicked: id => root.selectedId = id
                }
            }
        }

        Rectangle {
            width: parent.width
            implicitHeight: controls.height + 2 * Tokens.marginRow
            radius: Tokens.radiusCard
            color: Theme.card

            Column {
                id: controls
                x: Tokens.marginRow
                y: Tokens.marginRow
                width: parent.width - 2 * Tokens.marginRow
                spacing: Tokens.spacingMedium

                Repeater {
                    model: root.slots

                    Item {
                        required property string modelData

                        width: controls.width
                        height: Tokens.segmentHeight + 2 * Tokens.spacingSnug

                        Label {
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.slotTitles[modelData]
                            font.pixelSize: Tokens.fontBody
                        }

                        SegmentedControl {
                            anchors.right: parent.right
                            options: root.justifyOptions
                            current: root.rest[modelData].justify
                            onPicked: id => IslandConfig.set("rest." + modelData + ".justify", id)
                        }
                    }
                }

                IslandSliderRow {
                    width: parent.width
                    title: "Отступ между виджетами"
                    value: root.rest.layout.gap
                    to: 24
                    suffix: " px"
                    onMoved: value => IslandConfig.set("rest.layout.gap", value)
                }

                Item {
                    width: parent.width
                    height: Tokens.segmentHeight + 2 * Tokens.spacingSnug

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Ширина"
                        font.pixelSize: Tokens.fontBody
                    }

                    SegmentedControl {
                        anchors.right: parent.right
                        options: [{ id: "fit", label: "По содержимому" }, { id: "fixed", label: "Фиксированная" }]
                        current: root.fixedWidth ? "fixed" : "fit"
                        onPicked: id => IslandConfig.set("rest.layout.width", id === "fit" ? "fit" : 640)
                    }
                }

                IslandSliderRow {
                    width: parent.width
                    visible: root.fixedWidth
                    title: "Ширина в покое"
                    value: root.fixedWidth ? root.rest.layout.width : 0
                    from: 300
                    to: 1000
                    step: 10
                    suffix: " px"
                    onMoved: value => IslandConfig.set("rest.layout.width", value)
                }
            }
        }

        Label {
            text: "Свободные виджеты"
            font.pixelSize: Tokens.fontSmall
            font.weight: Font.DemiBold
            color: Theme.textDim
        }

        IslandZone {
            key: "tray"
            board: dragBoard
            widgets: restWidgets
            entries: root.trayEntries
            width: parent.width
            wrap: true
            reach: Tokens.marginMedium
        }

        IslandSelectionPanel {
            width: parent.width
            entry: root.selectedEntry
            onPatched: patch => root.patchSelected(patch)
        }
    }

    IslandDragLayer {
        id: dragBoard
        anchors.fill: parent
        z: 50
        onDropped: (fromKey, fromIndex, toKey, toIndex, entry) => root.applyDrop(fromKey, fromIndex, toKey, toIndex, entry)
    }
}
