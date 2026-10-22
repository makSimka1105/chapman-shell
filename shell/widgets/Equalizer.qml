import QtQuick
import qs.services

Row {
    id: root

    property bool active
    property int bars: 4
    property real barHeight: 22
    property real barWidth: 3

    spacing: 3
    height: barHeight

    Repeater {
        model: root.bars

        Rectangle {
            id: bar

            required property int index
            property real level: 0.35

            anchors.verticalCenter: parent.verticalCenter
            width: root.barWidth
            radius: root.barWidth / 2
            height: root.barHeight * level
            color: root.active ? Theme.accent : Theme.faint

            Behavior on level {
                NumberAnimation {
                    duration: 160
                    easing.type: Easing.OutCubic
                }
            }

            Timer {
                running: root.active
                repeat: true
                interval: 150 + bar.index * 40
                onTriggered: bar.level = 0.3 + Math.random() * 0.7
                onRunningChanged: if (!running) bar.level = 0.35
            }
        }
    }
}
