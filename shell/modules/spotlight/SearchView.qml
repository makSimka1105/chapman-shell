import QtQuick
import qs.core
import qs.services
import qs.widgets

FocusScope {
    id: root

    property int selected: 0
    property int armed: -1
    readonly property var results: search.build(field.text)
    readonly property bool hasResults: results.length > 0
    readonly property real fieldHeight: 60
    readonly property real rowHeight: 52
    readonly property real headerHeight: 28
    readonly property int visibleRows: 8
    readonly property real gap: 12
    readonly property real padding: Tokens.marginPanel
    readonly property real slabHeight: hasResults ? list.height + 18 : 0

    signal closed

    function open(query) {
        Themes.refresh();
        Clipboard.refresh();
        field.text = query;
        field.forceActiveFocus();
    }

    function activate(index) {
        const item = results[index];
        if (!item || item.header)
            return;
        if (item.prefill !== undefined) {
            field.text = item.prefill;
            return;
        }
        if (item.confirm && armed !== index) {
            armed = index;
            return;
        }
        item.run();
        closed();
    }

    function rowY(index) {
        return results.slice(0, index).reduce((y, item) => y + (item.header ? headerHeight : rowHeight), 0);
    }

    function firstItem() {
        return results.findIndex(item => !item.header);
    }

    function move(step) {
        if (firstItem() < 0)
            return;
        let index = selected;
        do
            index = (index + step + results.length) % results.length;
        while (results[index].header);
        selected = index;
    }

    implicitWidth: Tokens.searchWidth
    implicitHeight: padding * 2 + fieldHeight + (hasResults ? gap + slabHeight : 0)
    onResultsChanged: {
        if (selected >= results.length || results[selected].header)
            selected = Math.max(0, firstItem());
    }
    onSelectedChanged: armed = -1

    SpotlightSearch {
        id: search
    }

    SpotlightField {
        id: field
        x: root.padding
        y: root.padding
        width: root.width - 2 * root.padding
        height: root.fieldHeight
        onTextChanged: {
            root.selected = 0;
            root.armed = -1;
            Files.search(/^[@#=:]/.test(text.trim()) ? "" : text);
        }
        onEscaped: root.closed()
        onMoved: step => root.move(step)
        onSubmitted: root.activate(root.selected)
    }

    Item {
        x: root.padding
        y: root.padding + root.fieldHeight + root.gap
        width: root.width - 2 * root.padding
        height: root.slabHeight
        visible: root.hasResults
        clip: true

        SpotlightResults {
            id: list
            y: 9
            x: 9
            width: parent.width - 18
            height: Math.min(contentHeight, root.visibleRows * root.rowHeight)
            model: root.results
            currentIndex: root.selected
            rowHeight: root.rowHeight
            headerHeight: root.headerHeight
            highlightY: root.rowY(root.selected)
            highlightArmed: root.armed === root.selected
            armed: root.armed
            collapsed: true
            onHovered: index => root.selected = index
            onClicked: index => root.activate(index)
        }
    }
}
