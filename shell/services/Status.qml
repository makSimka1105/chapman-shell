pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Networking
import Quickshell.Services.UPower

Singleton {
    readonly property var battery: UPower.displayDevice
    readonly property real batteryLevel: battery?.percentage ?? 0
    readonly property bool charging: battery?.state === UPowerDeviceState.Charging
    readonly property var wifi: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var wifiNetwork: wifi?.networks.values.find(n => n.connected) ?? null
    readonly property real wifiStrength: wifiNetwork?.signalStrength ?? 0
}
