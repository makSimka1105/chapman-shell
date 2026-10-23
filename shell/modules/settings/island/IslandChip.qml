import QtQuick
import qs.core
import qs.services
import qs.widgets

Item {
    id: root

    property var entry
    property int position
    property var zone
    property var board
    default property alias content: holder.data
    readonly property bool selected: zone.selectedId === entry.id
    readonly property bool dragSource: board?.active === true && board.sourceKey === zone.key && board.sourceIndex === position

    opacity: dragSource ? 0.25 : entry.enabled ? 1 : 0.4

    Behavior on opacity {
        NumberAnimation {
            duration: Tokens.durationFast
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: Tokens.radiusChip
        color: area.containsMouse ? Qt.alpha(Theme.text, 0.1) : "transparent"
        border.width: root.selected ? 1 : 0
        border.color: Theme.accent
    }

    Item {
        id: holder
        anchors.fill: parent
    }

    MouseArea {
        id: area
        property point origin
        property bool dragging: false

        anchors.fill: parent
        hoverEnabled: true
        preventStealing: true
        onPressed: mouse => origin = Qt.point(mouse.x, mouse.y)
        onPositionChanged: mouse => {
            if (!pressed)
                return;
            if (!dragging && Math.hypot(mouse.x - origin.x, mouse.y - origin.y) > Tokens.spacingItem) {
                dragging = true;
                root.board.begin(root.zone, root.position, root.entry);
            }
            if (dragging) {
                const point = mapToItem(root.board, mouse.x, mouse.y);
                root.board.update(point.x, point.y);
            }
        }
        onReleased: {
            if (dragging)
                root.board.finish();
            else
                root.zone.picked(root.entry.id);
            dragging = false;
        }
    }
}
