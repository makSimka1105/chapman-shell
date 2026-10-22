import QtQuick
import qs.core
import qs.services

Rectangle {
    id: root

    property bool checked

    signal toggled

    width: 42
    height: 24
    radius: height / 2
    color: checked ? Theme.accent : Theme.faint

    Behavior on color {
        ColorAnimation {
            duration: Tokens.durationFast
        }
    }

    Rectangle {
        x: root.checked ? root.width - width - 3 : 3
        anchors.verticalCenter: parent.verticalCenter
        width: root.height - 6
        height: width
        radius: width / 2
        color: root.checked ? Theme.body : Theme.text

        Behavior on x {
            NumberAnimation {
                duration: Tokens.durationPress
                easing.type: Easing.OutBack
                easing.overshoot: Tokens.overshootMedium
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.toggled()
    }
}
