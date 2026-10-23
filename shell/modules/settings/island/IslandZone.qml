import QtQuick
import qs.core
import qs.services
import qs.widgets

Item {
    id: root

    required property string key
    required property var board
    property var entries: []
    property var widgets
    property string kind: "rest"
    property string align: "start"
    property real gap: Tokens.spacingSnug
    property bool wrap: false
    property bool vertical: false
    property string selectedId
    property real reach: Tokens.spacingItem
    readonly property bool targeted: board?.active === true && board.targetKey === key
    readonly property real contentWidth: flow.width
    readonly property real chipsWidth: flow.children.reduce((sum, child) => sum + child.width, 0)

    implicitHeight: wrap ? Math.max(flow.height, Tokens.segmentHeight) : Tokens.segmentHeight

    signal picked(string id)

    function chipAt(index) {
        return (kind === "rest" ? restChips : cardChips).itemAt(index);
    }

    function hit(layerX, layerY) {
        const point = mapFromItem(board, layerX, layerY);
        return point.x >= -reach && point.x <= width + reach && point.y >= -reach && point.y <= height + reach;
    }

    function indexAt(layerX, layerY) {
        const point = mapFromItem(board, layerX, layerY);
        let index = 0;
        for (let position = 0; position < entries.length; position++) {
            const chip = chipAt(position);
            if (chip === null)
                continue;
            const corner = chip.mapToItem(root, 0, 0);
            const before = vertical ? point.y > corner.y + chip.height / 2 : point.y > corner.y + chip.height || (point.y >= corner.y && point.x > corner.x + chip.width / 2);
            if (before)
                index = position + 1;
        }
        return index;
    }

    function markerRect(index) {
        const last = index >= entries.length;
        const chip = chipAt(last ? entries.length - 1 : index);
        if (chip === null)
            return Qt.rect(0, 0, vertical ? width : 3, vertical ? 3 : height);
        const corner = chip.mapToItem(root, 0, 0);
        if (vertical)
            return Qt.rect(corner.x, last ? corner.y + chip.height + 1 : corner.y - 4, chip.width, 3);
        return Qt.rect(last ? corner.x + chip.width + 1 : corner.x - 4, corner.y, 3, chip.height);
    }

    Component.onCompleted: board.register(root)
    Component.onDestruction: board.unregister(root)

    Rectangle {
        anchors.fill: parent
        radius: Tokens.radiusChip
        color: root.targeted ? Qt.alpha(Theme.accent, 0.14) : Qt.alpha(Theme.text, 0.04)
    }

    Flow {
        id: flow
        x: root.align === "end" ? root.width - width : root.align === "center" ? (root.width - width) / 2 : 0
        anchors.verticalCenter: root.wrap ? undefined : parent.verticalCenter
        spacing: root.align === "between" && root.entries.length > 1 ? Math.max(root.gap, (root.width - root.chipsWidth) / (root.entries.length - 1)) : root.gap

        Binding {
            target: flow
            property: "width"
            value: root.width
            when: root.wrap
        }

        Repeater {
            id: restChips
            model: root.kind === "rest" ? root.entries : []

            IslandRestChip {
                required property var modelData
                required property int index

                entry: modelData
                position: index
                zone: root
                board: root.board
                widgets: root.widgets
            }
        }

        Repeater {
            id: cardChips
            model: root.kind === "card" ? root.entries : []

            IslandCardChip {
                required property var modelData
                required property int index

                entry: modelData
                position: index
                zone: root
                board: root.board
            }
        }
    }

    Rectangle {
        readonly property rect place: root.targeted ? root.markerRect(root.board.targetIndex) : Qt.rect(0, 0, 0, 0)

        x: place.x
        y: place.y
        width: place.width
        height: place.height
        radius: Tokens.radiusHairline
        color: Theme.accent
        visible: root.targeted
    }
}
