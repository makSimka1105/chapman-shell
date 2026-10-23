import QtQuick
import Quickshell
import qs.core
import qs.services
import qs.widgets
import qs.modules.home

Item {
    id: root

    readonly property var grid: IslandConfig.data.home.grid
    readonly property var items: IslandConfig.data.home.items
    property string selectedId
    readonly property var selectedEntry: items.find(entry => entry.id === selectedId) ?? null
    readonly property var placements: islandGrid.placements
    readonly property var placedIds: placements.map(placement => placement.id)
    readonly property var trayEntries: IslandCatalog.widgets
        .filter(widget => widget.places.includes("home") && !placedIds.includes(widget.id))
        .map(widget => items.find(entry => entry.id === widget.id) ?? { id: widget.id, enabled: true, col: 0, span: 1 })
    readonly property real islandRadius: 36
    readonly property real emptyWidth: 2 * Tokens.segmentWidth / 3
    readonly property real islandWidth: islandGrid.implicitWidth
    readonly property real islandHeight: islandGrid.implicitHeight + 2 * Tokens.homeInsetVertical
    readonly property real fitScale: islandWidth > 0 ? Math.min(1, previewArea.width / islandWidth) : 1
    readonly property var cardsByColumn: Array.from({ length: grid.columns }, (unused, col) => placements
        .filter(placement => placement.col === col)
        .map(placement => ({
            entry: items.find(entry => entry.id === placement.id),
            x: placement.x,
            y: placement.y + Tokens.homeInsetVertical,
            width: placement.width,
            height: placement.height
        }))
        .filter(card => card.entry))
    readonly property var emptyColumns: cardsByColumn.map((cards, col) => col).filter(col => cardsByColumn[col].length === 0)

    function lastUsedColumn() {
        return items.reduce((last, entry) => Math.max(last, entry.col + entry.span - 1), 0);
    }

    function removeColumn(column) {
        IslandConfig.set("home.items", items.map(entry => entry.col > column ? Object.assign({}, entry, { col: entry.col - 1 }) : entry));
        IslandConfig.set("home.grid.columns", grid.columns - 1);
    }

    function applyDrop(fromKey, fromIndex, toKey, toIndex, entry) {
        const remaining = items.filter(candidate => candidate.id !== entry.id);
        if (toKey !== "tray") {
            const column = Number(toKey.slice(3));
            const placed = Object.assign({}, entry, { col: column, enabled: true });
            const inColumn = remaining.filter(candidate => candidate.col === column && placedIds.includes(candidate.id));
            const adjusted = fromKey === toKey && fromIndex < toIndex ? toIndex - 1 : toIndex;
            const before = inColumn[adjusted];
            const at = before ? remaining.indexOf(before) : inColumn.length > 0 ? remaining.indexOf(inColumn[inColumn.length - 1]) + 1 : remaining.length;
            remaining.splice(at, 0, placed);
        }
        IslandConfig.set("home.items", remaining);
    }

    function patchSelected(patch) {
        IslandConfig.set("home.items", items.map(entry => entry.id === selectedId ? Object.assign({}, entry, patch) : entry));
    }

    implicitHeight: content.height

    Column {
        id: content
        width: parent.width
        spacing: Tokens.marginMedium

        Row {
            width: parent.width
            spacing: Tokens.spacingItem

            Item {
                id: previewArea
                width: parent.width - addColumn.width - parent.spacing
                height: root.islandHeight * root.fitScale

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -Tokens.marginRow
                    radius: Tokens.radiusCard
                    color: Theme.card
                }

                Item {
                    id: island
                    width: root.islandWidth
                    height: root.islandHeight
                    scale: root.fitScale
                    transformOrigin: Item.TopLeft

                    Rectangle {
                        anchors.fill: parent
                        radius: root.islandRadius
                        color: "black"
                    }

                    HomeGrid {
                        id: islandGrid
                        widgets: islandWidgets
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    HomeWidgets {
                        id: islandWidgets
                        output: Quickshell.screens[0]?.name ?? ""
                        picker: ""
                    }

                    MouseArea {
                        anchors.fill: parent
                    }

                    Repeater {
                        model: root.cardsByColumn

                        IslandHomeColumn {
                            required property var modelData
                            required property int index

                            visible: modelData.length > 0
                            key: "col" + index
                            board: dragBoard
                            cards: modelData
                            rowGap: root.grid.rowGap
                            reach: islandGrid.columnBounds[index] ? root.grid.gap / 2 : 0
                            selectedId: root.selectedId
                            x: islandGrid.columnBounds[index]?.left ?? 0
                            width: islandGrid.columnBounds[index]?.width ?? 0
                            height: root.islandHeight
                            onPicked: id => root.selectedId = id
                        }
                    }
                }
            }

            IconButton {
                id: addColumn
                glyph: "󰐕"
                onClicked: IslandConfig.set("home.grid.columns", root.grid.columns + 1)
            }
        }

        Row {
            spacing: Tokens.spacingItem
            visible: root.emptyColumns.length > 0

            Repeater {
                model: root.emptyColumns

                IslandHomeColumn {
                    id: emptyColumn

                    required property int modelData

                    key: "col" + modelData
                    board: dragBoard
                    rowGap: root.grid.rowGap
                    reach: Tokens.spacingItem
                    width: root.emptyWidth
                    height: Tokens.widgetRowHeight

                    IconButton {
                        anchors.centerIn: parent
                        glyph: "󰆴"
                        visible: root.grid.columns > 1 && !root.items.some(entry => entry.col === emptyColumn.modelData)
                        onClicked: root.removeColumn(emptyColumn.modelData)
                    }
                }
            }
        }

        IslandHomeControls {
            width: parent.width
            grid: root.grid
            minColumns: root.lastUsedColumn() + 1
        }

        Label {
            text: "Свободные виджеты"
            font.pixelSize: Tokens.fontSmall
            font.weight: Font.DemiBold
            color: Theme.textDim
        }

        IslandZone {
            key: "tray"
            kind: "card"
            board: dragBoard
            entries: root.trayEntries
            width: parent.width
            wrap: true
            reach: Tokens.marginMedium
        }

        IslandHomePanel {
            width: parent.width
            entry: root.selectedEntry
            onSpanPicked: span => root.patchSelected({ span: span })
            onToggled: root.patchSelected({ enabled: !root.selectedEntry.enabled })
        }
    }

    IslandDragLayer {
        id: dragBoard
        anchors.fill: parent
        z: 50
        onDropped: (fromKey, fromIndex, toKey, toIndex, entry) => root.applyDrop(fromKey, fromIndex, toKey, toIndex, entry)
    }
}
