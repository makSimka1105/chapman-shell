import QtQuick
import qs.services
import qs.widgets

Column {
    id: root

    readonly property int shown: 5
    readonly property var items: Notifications.history.slice().reverse().slice(0, shown)

    signal back

    spacing: 2

    PageHeader {
        width: parent.width
        title: "Notifications"
        onBack: root.back()

        Rectangle {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: clearLabel.implicitWidth + 24
            height: 34
            radius: 17
            color: clearArea.containsMouse ? Qt.alpha(Theme.text, 0.12) : Theme.card
            scale: clearArea.pressed ? 0.92 : 1

            Behavior on scale {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutBack
                    easing.overshoot: 3
                }
            }

            Label {
                id: clearLabel
                anchors.centerIn: parent
                text: "Clear"
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }

            MouseArea {
                id: clearArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: Notifications.clear()
            }
        }
    }

    Label {
        visible: root.items.length === 0
        width: parent.width
        height: 42
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        text: "No notifications"
        color: Theme.textDim
        font.pixelSize: 14
        font.weight: Font.Medium
    }

    Repeater {
        model: root.items

        Rectangle {
            id: entry

            required property var modelData

            width: root.width
            height: 62
            radius: 14
            color: rowArea.containsMouse ? Qt.alpha(Theme.text, 0.08) : "transparent"
            scale: rowArea.pressed ? 0.98 : 1

            Behavior on color {
                ColorAnimation {
                    duration: 120
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutBack
                    easing.overshoot: 3
                }
            }

            MouseArea {
                id: rowArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: Notifications.activate(entry.modelData)
            }

            Column {
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.right: closeButton.left
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter

                Label {
                    width: parent.width
                    text: entry.modelData.appName
                    color: Theme.textDim
                    elide: Text.ElideRight
                    font.pixelSize: 11
                    font.weight: Font.Medium
                }

                Label {
                    width: parent.width
                    text: entry.modelData.summary
                    elide: Text.ElideRight
                    font.pixelSize: 15
                    font.weight: Font.Bold
                }

                Label {
                    width: parent.width
                    visible: text !== ""
                    text: entry.modelData.body
                    color: Theme.textDim
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    font.pixelSize: 12
                    font.weight: Font.Medium
                }
            }

            Rectangle {
                id: closeButton
                anchors.right: parent.right
                anchors.rightMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                width: 26
                height: 26
                radius: 13
                color: closeArea.containsMouse ? Qt.alpha(Theme.text, 0.12) : Theme.card
                scale: closeArea.pressed ? 0.88 : 1

                Behavior on scale {
                    NumberAnimation {
                        duration: 220
                        easing.type: Easing.OutBack
                        easing.overshoot: 3
                    }
                }

                Glyph {
                    anchors.centerIn: parent
                    text: "󰅖"
                    font.pixelSize: 13
                }

                MouseArea {
                    id: closeArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: entry.modelData.dismiss()
                }
            }
        }
    }
}
