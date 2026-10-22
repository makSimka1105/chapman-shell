import QtQuick
import qs.services

Item {
    id: root

    property string title
    property bool switchable
    property bool checked

    signal back
    signal toggled

    height: 44

    Rectangle {
        id: backButton
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 34
        height: 34
        radius: 17
        color: backArea.containsMouse ? Qt.alpha(Theme.text, 0.12) : Theme.card
        scale: backArea.pressed ? 0.88 : 1

        Behavior on scale {
            NumberAnimation {
                duration: 220
                easing.type: Easing.OutBack
                easing.overshoot: 3
            }
        }

        Glyph {
            anchors.centerIn: parent
            text: "󰅁"
            font.pixelSize: 18
        }

        MouseArea {
            id: backArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.back()
        }
    }

    Label {
        anchors.left: backButton.right
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        text: root.title
        font.pixelSize: 19
        font.weight: Font.Bold
    }

    Toggle {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        visible: root.switchable
        checked: root.checked
        onToggled: root.toggled()
    }
}
