import QtQuick
import qs.core
import qs.services

Item {
    id: root

    property real value
    readonly property real fraction: Math.max(0, Math.min(1, value))

    signal moved(real value)

    implicitWidth: 220
    implicitHeight: Tokens.sliderHeight

    function update(positionX) {
        root.moved(Math.max(0, Math.min(1, positionX / width)));
    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: Tokens.trackHeight
        radius: height / 2
        color: Theme.faint

        Rectangle {
            width: Math.max(height, parent.width * root.fraction)
            height: parent.height
            radius: height / 2
            color: Theme.accent

            Behavior on width {
                enabled: !area.pressed

                NumberAnimation {
                    duration: Tokens.durationMove
                    easing.type: Easing.OutBack
                    easing.overshoot: Tokens.overshootMild
                }
            }
        }
    }

    Rectangle {
        x: root.fraction * (root.width - width)
        anchors.verticalCenter: parent.verticalCenter
        width: Tokens.sliderKnob
        height: width
        radius: width / 2
        color: Theme.text
        scale: area.pressed ? 1.2 : area.containsMouse ? 1.1 : 1

        Behavior on x {
            enabled: !area.pressed

            NumberAnimation {
                duration: Tokens.durationMove
                easing.type: Easing.OutBack
                easing.overshoot: Tokens.overshootMild
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: Tokens.durationNormal
                easing.type: Easing.OutBack
                easing.overshoot: Tokens.overshootSnappy
            }
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        onPressed: mouse => root.update(mouse.x)
        onPositionChanged: mouse => {
            if (pressed)
                root.update(mouse.x);
        }
    }
}
