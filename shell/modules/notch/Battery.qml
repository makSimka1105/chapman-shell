import QtQuick
import qs.core
import qs.services
import qs.widgets

Item {
    id: root

    property real level: Status.batteryLevel
    property real bodyWidth: 42
    property real bodyHeight: 22
    property bool showNumber: false
    readonly property bool low: level < 0.2 && !Status.charging
    readonly property color tone: Status.charging ? Theme.charge : low ? Theme.warning : Theme.text

    width: bodyWidth + 5
    height: bodyHeight

    Rectangle {
        id: body
        width: root.bodyWidth
        height: root.bodyHeight
        radius: height * 0.32
        color: "transparent"
        border.width: Math.max(1.5, height / 11)
        border.color: Theme.textDim

        Rectangle {
            x: parent.border.width + 1.5
            y: parent.border.width + 1.5
            width: Math.max(height, (parent.width - 2 * x) * Math.min(1, root.level))
            height: parent.height - 2 * y
            radius: height * 0.3
            color: root.tone

            Behavior on width {
                NumberAnimation {
                    duration: Tokens.durationSlow
                }
            }
        }

        Row {
            anchors.centerIn: parent
            spacing: 1

            Glyph {
                visible: Status.charging
                anchors.verticalCenter: parent.verticalCenter
                text: "\udb85\udc0b"
                color: Theme.body
                font.pixelSize: root.bodyHeight * 0.6
            }

            Label {
                visible: root.showNumber
                anchors.verticalCenter: parent.verticalCenter
                text: Math.round(root.level * 100)
                color: Theme.body
                font.pixelSize: root.bodyHeight * 0.76
                font.weight: Font.Bold
            }
        }
    }

    Rectangle {
        x: root.bodyWidth + 2
        anchors.verticalCenter: body.verticalCenter
        width: 3
        height: root.bodyHeight * 0.36
        radius: Tokens.radiusHairline
        color: Theme.textDim
    }
}
