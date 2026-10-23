import QtQuick
import Quickshell.Bluetooth
import Quickshell.Networking
import qs.core
import qs.services
import qs.widgets

Column {
    id: root

    readonly property bool present: true
    readonly property bool bluetoothOn: Bluetooth.defaultAdapter?.enabled ?? false
    readonly property bool bluetoothLinked: Bluetooth.defaultAdapter?.devices.values.some(device => device.connected) ?? false
    readonly property var headset: Bluetooth.defaultAdapter?.devices.values.find(device => device.connected) ?? null

    signal pageRequested(string page)

    spacing: 18

    HomeLink {
        glyph: Status.wifiNetwork !== null ? "󰤨" : "󰤭"
        title: "Wi-Fi"
        caption: Status.wifiNetwork?.name ?? (Networking.wifiEnabled ? "Not connected" : "Off")
        tint: Status.wifiNetwork !== null ? Theme.accent : Theme.textDim
        onClicked: root.pageRequested("wifi")
    }

    HomeLink {
        glyph: root.bluetoothLinked ? "󰂱" : root.bluetoothOn ? "󰂯" : "󰂲"
        title: "Bluetooth"
        caption: root.headset ? root.headset.name + (root.headset.batteryAvailable ? " " + Math.round(root.headset.battery * 100) + "%" : "") : root.bluetoothOn ? "No device" : "Off"
        tint: root.bluetoothOn ? Theme.accent : Theme.textDim
        onClicked: root.pageRequested("bluetooth")
    }
}
