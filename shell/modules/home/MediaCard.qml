import QtQuick
import Quickshell.Widgets
import qs.services
import qs.widgets

Rectangle {
    id: root

    radius: 16
    color: Theme.card

    Timer {
        running: root.visible && Media.playing
        interval: 1000
        repeat: true
        onTriggered: Media.player.positionChanged()
    }

    MouseArea {
        anchors.left: parent.left
        anchors.right: controls.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        enabled: Media.player !== null
        cursorShape: Qt.PointingHandCursor
        onClicked: Media.focusSource()
    }

    ClippingRectangle {
        id: cover
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: parent.height - 20
        height: width
        radius: 10
        color: Theme.faint
        opacity: Media.playing ? 1 : 0.55

        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }
        }

        Image {
            anchors.fill: parent
            source: Media.art
            fillMode: Image.PreserveAspectCrop
            sourceSize: Qt.size(width * 2, height * 2)
        }
    }

    Column {
        anchors.left: cover.right
        anchors.leftMargin: 10
        anchors.right: controls.left
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        spacing: 3

        Row {
            width: parent.width
            spacing: 6

            Label {
                id: title
                width: Math.min(implicitWidth, parent.width - (equalizer.visible ? equalizer.width + parent.spacing : 0))
                text: Media.title || "Nothing playing"
                color: Media.player ? Theme.text : Theme.textDim
                elide: Text.ElideRight
                font.pixelSize: 13
                font.weight: Font.DemiBold
            }

            Equalizer {
                id: equalizer
                anchors.verticalCenter: title.verticalCenter
                active: Media.playing
                visible: Media.player !== null
            }
        }

        Label {
            width: parent.width
            visible: text !== ""
            text: Media.artist
            color: Theme.textDim
            elide: Text.ElideRight
            font.pixelSize: 11
        }

        Rectangle {
            width: parent.width
            height: 3
            radius: 1.5
            color: Theme.faint
            visible: Media.player !== null

            Rectangle {
                width: parent.width * Media.progress
                height: parent.height
                radius: parent.radius
                color: Theme.accent

                Behavior on width {
                    NumberAnimation {
                        duration: 1000
                    }
                }
            }
        }
    }

    Row {
        id: controls
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8
        visible: Media.player !== null

        MediaButton {
            anchors.verticalCenter: parent.verticalCenter
            visible: Media.player?.canGoPrevious ?? false
            glyph: "󰒮"
            onClicked: Media.player.previous()
        }

        Rectangle {
            width: 32
            height: 32
            radius: 16
            color: Theme.accent

            Label {
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: Media.playing ? 0 : 1
                text: Media.playing ? "󰏤" : "󰐊"
                color: "black"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 16
            }

            MouseArea {
                anchors.fill: parent
                enabled: Media.player?.canTogglePlaying ?? false
                cursorShape: Qt.PointingHandCursor
                onClicked: Media.player.togglePlaying()
            }
        }

        MediaButton {
            anchors.verticalCenter: parent.verticalCenter
            visible: Media.player?.canGoNext ?? false
            glyph: "󰒭"
            onClicked: Media.player.next()
        }
    }
}
