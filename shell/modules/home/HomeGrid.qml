import QtQuick
import qs.core

Item {
    id: root

    required property HomeWidgets widgets
    property real inset: 36
    readonly property var grid: IslandConfig.data.home.grid
    readonly property real mediaWidth: 250
    property var placements: []
    property var columnBounds: []

    implicitWidth: 0
    implicitHeight: 0

    onGridChanged: Qt.callLater(relayout)

    function relayout() {
        const count = grid.columns;
        const heights = new Array(count).fill(0);
        const widths = new Array(count).fill(0);
        const placed = [];
        for (let index = 0; index < repeater.count; index++) {
            const slot = repeater.itemAt(index);
            if (slot === null || !slot.visible)
                continue;
            const span = Math.min(slot.span, count);
            let col = slot.col;
            if (col === undefined)
                col = heights.indexOf(Math.min(...heights.slice(0, count - span + 1)));
            col = Math.min(col, count - span);
            const top = Math.max(...heights.slice(col, col + span));
            for (let covered = col; covered < col + span; covered++)
                heights[covered] = top + slot.height + grid.rowGap;
            placed.push({ slot: slot, col: col, span: span, top: top });
        }
        for (const entry of placed)
            if (entry.span === 1 && !entry.slot.stretches)
                widths[entry.col] = Math.max(widths[entry.col], entry.slot.width);
        for (const entry of placed)
            if (entry.span === 1 && entry.slot.stretches) {
                const wide = Math.max(mediaWidth, widths[entry.col]);
                if (entry.slot.item.width !== wide)
                    entry.slot.item.width = wide;
                widths[entry.col] = wide;
            }
        for (const entry of placed)
            if (entry.span === 2) {
                const lack = entry.slot.width - widths[entry.col] - widths[entry.col + 1] - grid.gap;
                if (lack > 0)
                    widths[entry.col + 1] += lack;
            }

        const used = widths.filter((width, col) => heights[col] > 0);
        const gaps = Math.max(used.length - 1, 0);
        const sum = used.reduce((total, width) => total + width, 0);
        const fit = typeof grid.width !== "number";
        const free = fit ? 0 : grid.width - inset * 2 - sum;
        let spacing = grid.gap;
        let offset = 0;
        if (!fit) {
            if (grid.justify === "between" && gaps > 0)
                spacing = Math.max(grid.gap, free / gaps);
            else if (grid.justify === "evenly")
                spacing = Math.max(grid.gap, free / (used.length + 1));
            if (grid.justify === "center" || grid.justify === "evenly")
                offset = Math.max((free - spacing * gaps) / 2, 0);
        }
        const lefts = [];
        let cursor = inset + offset;
        for (let col = 0; col < count; col++) {
            lefts.push(cursor);
            if (heights[col] > 0)
                cursor += widths[col] + spacing;
        }

        const tallest = Math.max(...heights) - grid.rowGap;
        const shifts = heights.map(height => (tallest - (height - grid.rowGap)) / 2);
        for (const entry of placed)
            if (entry.span === 2) {
                const shared = Math.min(shifts[entry.col], shifts[entry.col + 1]);
                shifts[entry.col] = shared;
                shifts[entry.col + 1] = shared;
            }
        for (const entry of placed) {
            entry.slot.x = lefts[entry.col];
            entry.slot.y = entry.top + shifts[entry.col];
        }
        placements = placed.map(entry => ({ id: entry.slot.modelData.id, col: entry.col, x: entry.slot.x, y: entry.slot.y, width: entry.slot.width, height: entry.slot.height }));
        columnBounds = lefts.map((left, col) => ({ left: left, width: widths[col] }));
        implicitWidth = fit ? sum + spacing * gaps + inset * 2 : grid.width;
        implicitHeight = Math.max(tallest, 0);
    }

    Repeater {
        id: repeater
        model: IslandConfig.data.home.items.filter(entry => entry.enabled && root.widgets.has(entry.id))
        onItemAdded: Qt.callLater(root.relayout)
        onItemRemoved: Qt.callLater(root.relayout)

        Loader {
            id: slot

            required property var modelData
            readonly property var col: modelData.col
            readonly property int span: Math.min(Math.max(modelData.span ?? 1, 1), 2)
            readonly property bool stretches: modelData.id === "media"

            sourceComponent: root.widgets.component(modelData.id)
            visible: item !== null && item.present
            onWidthChanged: Qt.callLater(root.relayout)
            onHeightChanged: Qt.callLater(root.relayout)
            onVisibleChanged: Qt.callLater(root.relayout)
        }
    }
}
