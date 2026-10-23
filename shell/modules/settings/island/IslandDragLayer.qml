import QtQuick
import qs.core
import qs.services
import qs.widgets

Item {
    id: root

    property var zones: []
    property bool active: false
    property string sourceKey
    property int sourceIndex: -1
    property var payload: null
    property string targetKey
    property int targetIndex: -1
    property point pointer

    signal dropped(string fromKey, int fromIndex, string toKey, int toIndex, var entry)

    function register(zone) {
        zones = zones.concat([zone]);
    }

    function unregister(zone) {
        zones = zones.filter(candidate => candidate !== zone);
    }

    function begin(zone, index, entry) {
        sourceKey = zone.key;
        sourceIndex = index;
        payload = entry;
        targetKey = "";
        targetIndex = -1;
        active = true;
    }

    function update(positionX, positionY) {
        pointer = Qt.point(positionX, positionY);
        const zone = zones.find(candidate => candidate.hit(positionX, positionY));
        targetKey = zone ? zone.key : "";
        targetIndex = zone ? zone.indexAt(positionX, positionY) : -1;
    }

    function finish() {
        if (targetKey !== "")
            dropped(sourceKey, sourceIndex, targetKey, targetIndex, payload);
        active = false;
        targetKey = "";
        targetIndex = -1;
    }

    Rectangle {
        visible: root.active
        x: root.pointer.x - width / 2
        y: root.pointer.y - height / 2
        width: ghostRow.width + 2 * Tokens.marginInner
        height: Tokens.segmentHeight
        radius: Tokens.radiusChip
        color: Qt.alpha(Theme.accent, 0.3)
        border.width: 1
        border.color: Theme.accent

        Row {
            id: ghostRow
            anchors.centerIn: parent
            spacing: Tokens.spacingSmall

            Glyph {
                text: IslandCatalog.widget(root.payload?.id ?? "")?.glyph ?? ""
                font.pixelSize: Tokens.fontMedium
            }

            Label {
                text: IslandCatalog.widget(root.payload?.id ?? "")?.name ?? ""
                font.pixelSize: Tokens.fontBody
            }
        }
    }
}
