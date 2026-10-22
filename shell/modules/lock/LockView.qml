import QtQuick
import QtQuick.Effects
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

    onFailuresChanged: shake.restart()
    Component.onCompleted: {
        openT = 1;
        field.forceActiveFocus();
    }

    Behavior on openT {
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutBack
            easing.overshoot: 1.2
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
    }

    Image {
        id: wall
        anchors.fill: parent
        visible: false
        source: Theme.wallpaper === "" ? "" : "file://" + Theme.wallpaper
        fillMode: Image.PreserveAspectCrop
        sourceSize: Qt.size(root.width, root.height)
        asynchronous: true
    }

    MultiEffect {
        anchors.fill: parent
        source: wall
        visible: Theme.wallpaper !== ""
        blurEnabled: true
        blur: 1.0
        blurMax: 64
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: Theme.wallpaper === "" ? 0 : 0.25
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.BlankCursor
        onClicked: field.forceActiveFocus()
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height * 0.1 - (1 - root.openT) * 30
        opacity: Math.min(1, root.openT * 1.6)
        spacing: 0

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(clock.date, "HH:mm")
            font.pixelSize: 120
            font.weight: Font.DemiBold
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(clock.date, "dddd, MMMM d")
            color: Theme.textDim
            font.pixelSize: 24
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
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

        Rectangle {
            id: pill

            property real offset: 0
            property real flush: 0

            anchors.horizontalCenter: parent.horizontalCenter
            width: 260
            height: 44
            radius: height / 2
            color: Qt.tint(Qt.alpha("white", 0.14), Qt.alpha(Theme.warning, 0.35 * flush))
            border.width: 1
            border.color: Qt.tint(Qt.alpha("white", 0.2), Qt.alpha(Theme.warning, flush))
            transform: Translate {
                x: pill.offset
            }

            SequentialAnimation {
                id: shake
                NumberAnimation {
                    target: pill
                    property: "flush"
                    to: 1
                    duration: 80
                }
                NumberAnimation {
                    target: pill
                    property: "offset"
                    to: -14
                    duration: 50
                }
                NumberAnimation {
                    target: pill
                    property: "offset"
                    to: 14
                    duration: 80
                }
                NumberAnimation {
                    target: pill
                    property: "offset"
                    to: -8
                    duration: 70
                }
                NumberAnimation {
                    target: pill
                    property: "offset"
                    to: 0
                    duration: 300
                    easing.type: Easing.OutBack
                    easing.overshoot: 3
                }
                NumberAnimation {
                    target: pill
                    property: "flush"
                    to: 0
                    duration: 400
                }
            }

            TextInput {
                id: field
                width: 0
                height: 0
                opacity: 0
                echoMode: TextInput.Password
                readOnly: root.busy
                text: root.text
                onTextChanged: if (text !== root.text) root.edited(text)
                onActiveFocusChanged: if (!activeFocus) forceActiveFocus()
                Keys.onEscapePressed: if (root.demo) root.escaped()
                Keys.onReturnPressed: root.submitted()
                Keys.onEnterPressed: root.submitted()
            }

            Item {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                clip: true
                opacity: root.busy ? 0.5 : 1

                Row {
                    anchors.centerIn: parent
                    spacing: 7

                    Repeater {
                        model: root.text.length

                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: Theme.text
                        }
                    }
                }

                Label {
                    anchors.centerIn: parent
                    visible: root.text === ""
                    text: "Enter Password"
                    color: Theme.textDim
                    font.pixelSize: 15
                }
            }
        }
    }

    Row {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 32
        spacing: 24
        opacity: Math.min(1, root.openT * 1.6)

        Row {
            spacing: 8

            Glyph {
                anchors.verticalCenter: parent.verticalCenter
                text: Status.charging ? "󰂄" : "󰁹"
                color: Status.charging ? Theme.charge : Theme.text
            }

            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: Math.round(Status.batteryLevel * 100) + "%"
                font.pixelSize: 15
            }
        }

        Row {
            visible: Media.active
            spacing: 8

            Glyph {
                anchors.verticalCenter: parent.verticalCenter
                text: Media.playing ? "󰎇" : "󰏤"
                color: Theme.textDim
            }

            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: Media.artist === "" ? Media.title : Media.title + " - " + Media.artist
                color: Theme.textDim
                font.pixelSize: 15
            }
        }
    }

    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 32
        spacing: 8
        opacity: Math.min(1, root.openT * 1.6)

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: layoutCode.width + 20
            height: 26
            radius: 13
            color: Qt.alpha(Theme.text, 0.14)

            Label {
                id: layoutCode
                anchors.centerIn: parent
                text: Niri.layoutCode
                font.pixelSize: 13
                font.weight: Font.DemiBold
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Spawn.run(["niri", "msg", "action", "switch-layout", "next"])
            }
        }

        Item {
            width: 8
            height: 1
        }

        Glyph {
            anchors.verticalCenter: parent.verticalCenter
            text: Status.wifiNetwork === null ? "󰤭" : "󰤨"
            color: Theme.textDim
        }

        Label {
            anchors.verticalCenter: parent.verticalCenter
            text: Status.wifiNetwork?.name ?? "Not connected"
            color: Theme.textDim
            font.pixelSize: 15
        }
    }
}
