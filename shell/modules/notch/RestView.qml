import QtQuick
import Quickshell
import Quickshell.Bluetooth
import qs.core
import qs.services
import qs.widgets

Item {
    id: root

    required property string output
    readonly property bool bluetoothOn: Bluetooth.defaultAdapter?.enabled ?? false
    readonly property bool bluetoothLinked: Bluetooth.defaultAdapter?.devices.values.some(device => device.connected) ?? false

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Workspaces {
        id: workspaces
        anchors.left: parent.left
        anchors.leftMargin: Tokens.marginPanel
        anchors.verticalCenter: parent.verticalCenter
        output: root.output
    }

    Item {
        anchors.left: workspaces.right
        anchors.right: time.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        Equalizer {
            anchors.centerIn: parent
            visible: Media.active
            active: Media.playing
        }
    }

    Label {
        id: time
        anchors.centerIn: parent
        text: Qt.formatTime(clock.date, "HH:mm")
        font.pixelSize: 17
        font.weight: Font.DemiBold
    }

    Row {
        anchors.right: parent.right
        anchors.rightMargin: Tokens.marginWide
        anchors.verticalCenter: parent.verticalCenter
        spacing: 9

        Label {
            anchors.verticalCenter: parent.verticalCenter
            text: Niri.layoutCode
            color: Theme.textDim
            font.pixelSize: Tokens.fontMedium
            font.weight: Font.DemiBold
        }

        Glyph {
            anchors.verticalCenter: parent.verticalCenter
            text: !bluetoothOn ? "󰂲" : bluetoothLinked ? "󰂱" : "󰂯"
            color: bluetoothOn ? Theme.accent : Theme.faint
            font.pixelSize: Tokens.fontHeading
        }

        Glyph {
            anchors.verticalCenter: parent.verticalCenter
            text: Status.wifiNetwork === null ? "󰤭" : Status.wifiStrength > 0.66 ? "󰤨" : Status.wifiStrength > 0.33 ? "󰤥" : "󰤢"
            color: Status.wifiNetwork !== null ? Theme.accent : Theme.faint
            font.pixelSize: Tokens.fontHeading
        }

        Battery {
            anchors.verticalCenter: parent.verticalCenter
            bodyWidth: 30
            bodyHeight: 15
        }
    }
}
