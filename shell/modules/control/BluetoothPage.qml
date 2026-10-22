import QtQuick
import Quickshell.Bluetooth
import qs.services
import qs.widgets

Column {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property int shown: 5
    readonly property var unnamed: /^([0-9A-F]{2}[-:]){5}[0-9A-F]{2}$/i
    readonly property var devices: (adapter?.devices.values ?? [])
        .filter(device => device.paired || (device.name && !root.unnamed.test(device.name)))
        .sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired) || a.name.localeCompare(b.name))
        .slice(0, shown)
    readonly property var glyphs: ({
            "audio-headphones": "󰋋",
            "audio-headset": "󰋎",
            "audio-card": "󰓃",
            "input-mouse": "󰍽",
            "input-keyboard": "󰌌",
            "input-gaming": "󰊴",
            "phone": "󰄜"
        })

    signal back

    function choose(device) {
        if (device.connected)
            device.disconnect();
        else if (device.paired)
            device.connect();
        else
            device.pair();
    }

    function status(device) {
        if (device.pairing)
            return "Pairing…";
        if (device.connected)
            return device.batteryAvailable ? "Connected · " + Math.round(device.battery * 100) + "%" : "Connected";
        return device.paired ? "Paired" : "New device";
    }

    spacing: 2
    Component.onCompleted: if (adapter?.enabled) adapter.discovering = true
    Component.onDestruction: if (adapter) adapter.discovering = false

    PageHeader {
        width: parent.width
        title: "Bluetooth"
        switchable: true
        checked: root.adapter?.enabled ?? false
        onBack: root.back()
        onToggled: if (root.adapter) root.adapter.enabled = !root.adapter.enabled
    }

    Label {
        visible: root.devices.length === 0
        width: parent.width
        height: 42
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        text: root.adapter?.enabled ? "Searching…" : "Bluetooth is off"
        color: Theme.textDim
        font.pixelSize: 14
        font.weight: Font.Medium
    }

    Repeater {
        model: root.devices

        ListRow {
            required property var modelData
            readonly property bool airpods: modelData.name.toLowerCase().includes("airpods")

            width: root.width
            height: 42
            glyph: root.glyphs[modelData.icon] ?? "󰂯"
            title: modelData.name
            subtitle: root.status(modelData)
            trailing: airpods && modelData.connected ? "LibrePods ›" : ""
            active: modelData.connected
            busy: modelData.state === BluetoothDeviceState.Connecting || modelData.state === BluetoothDeviceState.Disconnecting
            onClicked: airpods && modelData.connected ? Spawn.run(["librepods"]) : root.choose(modelData)
        }
    }
}
