import QtQuick
import qs.services

Row {
    id: root

    property real strength: Status.wifiStrength
    property bool connected: Status.wifiNetwork !== null
    property real barWidth: 3
    property real maxHeight: 13
    readonly property int bars: 4

    spacing: 2
    height: maxHeight

    Repeater {
        model: root.bars

        Rectangle {
            required property int index

            anchors.bottom: parent.bottom
            width: root.barWidth
            height: root.maxHeight * (index + 1) / root.bars
            radius: 1
            color: root.connected && root.strength * root.bars > index ? Theme.accent : Theme.faint
        }
    }
}
