import QtQuick
import qs.core
import qs.services

Column {
    id: root

    property var options: []
    property string current

    signal picked(string id)

    spacing: Tokens.spacingSnug

    Repeater {
        model: root.options

        Rectangle {
            id: option

            required property var modelData
            readonly property bool chosen: modelData.id === root.current

            width: root.width
            height: Tokens.choiceHeight
            radius: Tokens.radiusChip
            color: chosen ? Qt.alpha(Theme.accent, 0.18) : area.containsMouse ? Qt.alpha(Theme.text, 0.08) : "transparent"
            scale: area.pressed ? 0.98 : 1

            Behavior on color {
                ColorAnimation {
                    duration: Tokens.durationHover
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: Tokens.durationNormal
                    easing.type: Easing.OutBack
                    easing.overshoot: Tokens.overshootSnappy
                }
            }

            Label {
                anchors.left: parent.left
                anchors.leftMargin: Tokens.marginRow
                anchors.right: mark.left
                anchors.rightMargin: Tokens.spacingMedium
                anchors.verticalCenter: parent.verticalCenter
                text: option.modelData.label
                elide: Text.ElideRight
                font.pixelSize: Tokens.fontBody
                color: option.chosen ? Theme.text : Theme.textDim
            }

            Glyph {
                id: mark
                anchors.right: parent.right
                anchors.rightMargin: Tokens.marginRow
                anchors.verticalCenter: parent.verticalCenter
                text: "󰄬"
                font.pixelSize: Tokens.fontLabel
                color: Theme.accent
                opacity: option.chosen ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Tokens.durationFast
                    }
                }
            }

            MouseArea {
                id: area
                anchors.fill: parent
                hoverEnabled: true
                onClicked: root.picked(option.modelData.id)
            }
        }
    }
}
