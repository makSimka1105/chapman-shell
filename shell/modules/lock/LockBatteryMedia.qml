import QtQuick
import qs.core
import qs.services
import qs.widgets

Row {
    spacing: 24

    Row {
        spacing: Tokens.spacingItem

        Glyph {
            anchors.verticalCenter: parent.verticalCenter
            text: Status.charging ? "󰂄" : "󰁹"
            color: Status.charging ? Theme.charge : Theme.text
        }

        Label {
            anchors.verticalCenter: parent.verticalCenter
            text: Math.round(Status.batteryLevel * 100) + "%"
            font.pixelSize: Tokens.fontLabel
        }
    }

    Row {
        visible: Media.active
        spacing: Tokens.spacingItem

        Glyph {
            anchors.verticalCenter: parent.verticalCenter
            text: Media.playing ? "󰎇" : "󰏤"
            color: Theme.textDim
        }

        Label {
            anchors.verticalCenter: parent.verticalCenter
            text: Media.artist === "" ? Media.title : Media.title + " - " + Media.artist
            color: Theme.textDim
            font.pixelSize: Tokens.fontLabel
        }
    }
}
