import QtQuick
import qs.core
import qs.services

ListView {
    id: root

    required property real rowHeight
    required property real headerHeight
    required property real highlightY
    required property bool highlightArmed
    required property int armed
    required property bool collapsed

    signal hovered(int index)
    signal clicked(int index)

    boundsBehavior: Flickable.StopAtBounds
    clip: true
    highlightFollowsCurrentItem: false

    highlight: Rectangle {
        y: root.highlightY
        width: root.width
        height: root.rowHeight
        radius: Tokens.radiusRow
        color: Qt.alpha(root.highlightArmed ? Theme.warning : Theme.accent, 0.22)

        Behavior on y {
            NumberAnimation {
                duration: Tokens.durationMove
                easing.type: Easing.OutBack
                easing.overshoot: Tokens.overshootMedium
            }
        }
    }

    delegate: SpotlightRow {
        width: root.width
        rowHeight: root.rowHeight
        headerHeight: root.headerHeight
        armed: index === root.armed
        animateIn: root.collapsed
        onHovered: root.hovered(index)
        onClicked: root.clicked(index)
    }
}
