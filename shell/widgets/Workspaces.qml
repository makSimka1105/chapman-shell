import QtQuick
import qs.core
import qs.services

Row {
    id: root

    required property string output
    property real capsuleWidth: 8
    property real capsuleHeight: 14
    property real activeHeight: 18

    spacing: capsuleWidth * 0.75
    height: activeHeight

    Repeater {
        model: Niri.workspacesOn(root.output)

        Rectangle {
            required property var modelData

            anchors.verticalCenter: parent.verticalCenter
            width: root.capsuleWidth
            height: modelData.is_active ? root.activeHeight : root.capsuleHeight
            radius: width / 2
            color: modelData.is_active ? Theme.accent : Niri.hasWindows(modelData.id) ? Qt.alpha(Theme.accent, 0.45) : Theme.faint

            Behavior on height {
                NumberAnimation {
                    duration: Tokens.durationPress
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: Tokens.durationPress
                }
            }
        }
    }
}
