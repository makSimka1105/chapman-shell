import QtQuick
import qs.core
import qs.services

Rectangle {
    id: root

    property var options: []
    property string current

    signal picked(string id)

    readonly property int currentIndex: options.findIndex(option => option.id === current)

    implicitWidth: options.length * Tokens.segmentWidth + 2 * Tokens.spacingSnug
    implicitHeight: Tokens.segmentHeight + 2 * Tokens.spacingSnug
    radius: Tokens.radiusRow
    color: Theme.card

    Rectangle {
        x: Tokens.spacingSnug + Math.max(0, root.currentIndex) * Tokens.segmentWidth
        y: Tokens.spacingSnug
        width: Tokens.segmentWidth
        height: Tokens.segmentHeight
        radius: Tokens.radiusChip
        color: Qt.alpha(Theme.accent, 0.22)
        visible: root.currentIndex >= 0

        Behavior on x {
            NumberAnimation {
                duration: Tokens.durationMove
                easing.type: Easing.OutBack
                easing.overshoot: Tokens.overshootSoft
            }
        }
    }

    Row {
        x: Tokens.spacingSnug
        y: Tokens.spacingSnug

        Repeater {
            model: root.options

            Item {
                id: segment

                required property var modelData
                readonly property bool selected: modelData.id === root.current

                width: Tokens.segmentWidth
                height: Tokens.segmentHeight

                Label {
                    anchors.centerIn: parent
                    text: segment.modelData.label
                    font.pixelSize: Tokens.fontBody
                    color: segment.selected ? Theme.text : Theme.textDim
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.picked(segment.modelData.id)
                }
            }
        }
    }
}
