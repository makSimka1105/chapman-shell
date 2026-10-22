import QtQuick
import qs.core
import qs.services
import qs.widgets

Column {
    id: root

    readonly property int shown: 5
    readonly property var items: Notifications.history.slice().reverse().slice(0, shown)

    signal back

    spacing: Tokens.spacingHairline

    PageHeader {
        width: parent.width
        title: "Notifications"
        onBack: root.back()

        Rectangle {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: clearLabel.implicitWidth + 24
            height: 34
            radius: Tokens.radiusBackButton
            color: clearArea.containsMouse ? Qt.alpha(Theme.text, 0.12) : Theme.card
            scale: clearArea.pressed ? 0.92 : 1

            Behavior on scale {
                NumberAnimation {
                    duration: Tokens.durationPress
                    easing.type: Easing.OutBack
                    easing.overshoot: Tokens.overshootSnappy
                }
            }

            Label {
                id: clearLabel
                anchors.centerIn: parent
                text: "Clear"
                font.pixelSize: Tokens.fontMedium
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
        height: Tokens.listRowHeight
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        text: "No notifications"
        color: Theme.textDim
        font.pixelSize: Tokens.fontMedium
        font.weight: Font.Medium
    }

    Repeater {
        model: root.items

        Rectangle {
            id: entry

            required property var modelData

            width: root.width
            height: 62
            radius: Tokens.radiusRow
            color: rowArea.containsMouse ? Qt.alpha(Theme.text, 0.08) : "transparent"
            scale: rowArea.pressed ? 0.98 : 1

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

            MouseArea {
                id: rowArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: Notifications.activate(entry.modelData)
            }

            Column {
                anchors.left: parent.left
                anchors.leftMargin: Tokens.marginRow
                anchors.right: closeButton.left
                anchors.rightMargin: Tokens.marginInner
                anchors.verticalCenter: parent.verticalCenter

                Label {
                    width: parent.width
                    text: entry.modelData.appName
                    color: Theme.textDim
                    elide: Text.ElideRight
                    font.pixelSize: Tokens.fontCaption
                    font.weight: Font.Medium
                }

                Label {
                    width: parent.width
                    text: entry.modelData.summary
                    elide: Text.ElideRight
                    font.pixelSize: Tokens.fontLabel
                    font.weight: Font.Bold
                }

                Label {
                    width: parent.width
                    visible: text !== ""
                    text: entry.modelData.body
                    color: Theme.textDim
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    font.pixelSize: Tokens.fontSmall
                    font.weight: Font.Medium
                }
            }

            Rectangle {
                id: closeButton
                anchors.right: parent.right
                anchors.rightMargin: Tokens.marginRow
                anchors.verticalCenter: parent.verticalCenter
                width: 26
                height: 26
                radius: Tokens.radiusBadge
                color: closeArea.containsMouse ? Qt.alpha(Theme.text, 0.12) : Theme.card
                scale: closeArea.pressed ? 0.88 : 1

                Behavior on scale {
                    NumberAnimation {
                        duration: Tokens.durationPress
                        easing.type: Easing.OutBack
                        easing.overshoot: Tokens.overshootSnappy
                    }
                }

                Glyph {
                    anchors.centerIn: parent
                    text: "󰅖"
                    font.pixelSize: Tokens.fontBody
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
