import QtQuick
import Quickshell
import qs.services
import qs.widgets

Item {
    id: root

    property bool busy
    property bool demo
    property string text
    property int failures
    property real openT: 0
    readonly property string user: Quickshell.env("USER")

    signal edited(string value)
    signal submitted
    signal escaped

    Component.onCompleted: {
        openT = 1;
        password.forceActiveFocus();
    }

    Behavior on openT {
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutBack
            easing.overshoot: 1.2
        }
    }

    LockWallpaper {
        anchors.fill: parent
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.BlankCursor
        onClicked: password.forceActiveFocus()
    }

    LockClock {
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height * 0.1 - (1 - root.openT) * 30
        opacity: Math.min(1, root.openT * 1.6)
    }

    Column {
        id: login

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.height * 0.14
        opacity: Math.min(1, root.openT * 1.6)
        scale: 0.9 + 0.1 * root.openT
        spacing: 14

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 72
            height: 72
            radius: 36
            color: Theme.accent

            Label {
                anchors.centerIn: parent
                text: root.user.charAt(0).toUpperCase()
                color: Theme.body
                font.pixelSize: 32
                font.weight: Font.DemiBold
            }
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.user
            font.pixelSize: 18
            font.weight: Font.DemiBold
        }

        LockPassword {
            id: password
            anchors.horizontalCenter: parent.horizontalCenter
            busy: root.busy
            demo: root.demo
            text: root.text
            failures: root.failures
            onEdited: value => root.edited(value)
            onSubmitted: root.submitted()
            onEscaped: root.escaped()
        }
    }

    LockBatteryMedia {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 32
        opacity: Math.min(1, root.openT * 1.6)
    }

    LockLayoutWifi {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 32
        opacity: Math.min(1, root.openT * 1.6)
    }
}
