import QtQuick
import qs.core
import qs.services
import qs.widgets

Item {
    id: root

    required property string key
    required property var board
    property var cards: []
    property real rowGap
    property real reach
    property string selectedId
    readonly property bool vertical: true
    readonly property bool targeted: board?.active === true && board.targetKey === key
    readonly property var entries: cards.map(card => card.entry)

    signal picked(string id)

    function chipAt(index) {
        return chips.itemAt(index);
    }

    function hit(layerX, layerY) {
        const point = mapFromItem(board, layerX, layerY);
        return point.x >= -reach && point.x <= width + reach && point.y >= -reach && point.y <= height + reach;
    }

    function indexAt(layerX, layerY) {
        const point = mapFromItem(board, layerX, layerY);
        let index = 0;
        for (let position = 0; position < cards.length; position++)
            if (point.y > chipAt(position).y + chipAt(position).height / 2)
                index = position + 1;
        return index;
    }

    function markerRect(index) {
        const marker = Math.max(rowGap, 4);
        if (cards.length === 0)
            return Qt.rect(0, height / 2, width, marker);
        const last = index >= cards.length;
        const chip = chipAt(last ? cards.length - 1 : index);
        return Qt.rect(chip.x, last ? chip.y + chip.height + (rowGap - marker) / 2 : chip.y - (rowGap + marker) / 2, chip.width, marker);
    }

    Component.onCompleted: board.register(root)
    Component.onDestruction: board.unregister(root)

    Rectangle {
        anchors.fill: parent
        radius: Tokens.radiusChip
        color: "transparent"
        border.width: root.cards.length === 0 ? 1 : 0
        border.color: Theme.faint
    }

    Repeater {
        id: chips
        model: root.cards

        IslandChip {
            required property var modelData
            required property int index

            entry: modelData.entry
            position: index
            zone: root
            board: root.board
            x: modelData.x - root.x
            y: modelData.y
            width: modelData.width
            height: modelData.height
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
