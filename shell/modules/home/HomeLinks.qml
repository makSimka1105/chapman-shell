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
    readonly property int notificationCount: Notifications.history.length
    readonly property string notificationApps: {
        const names = [];
        for (const item of Notifications.history)
            if (item.appName && names.indexOf(item.appName) < 0)
                names.push(item.appName);
        return names.slice(0, 2).join(", ");
    }

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

    HomeLink {
        glyph: root.notificationCount === 0 ? "󰂛" : "󰂚"
        title: root.notificationCount === 0 ? "Quiet" : root.notificationCount + " new"
        caption: root.notificationCount === 0 ? "No notifications" : root.notificationApps
        tint: root.notificationCount === 0 ? Theme.textDim : Theme.accent
        onClicked: root.pageRequested("notifications")
    }
}
