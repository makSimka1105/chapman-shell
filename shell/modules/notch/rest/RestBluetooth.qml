import QtQuick
import Quickshell.Bluetooth
import qs.core
import qs.services
import qs.widgets

Glyph {
    property string variant
    readonly property bool present: true
    readonly property bool powered: Bluetooth.defaultAdapter?.enabled ?? false
    readonly property bool linked: Bluetooth.defaultAdapter?.devices.values.some(device => device.connected) ?? false

    text: !powered ? "󰂲" : linked ? "󰂱" : "󰂯"
    color: powered ? Theme.accent : Theme.faint
    font.pixelSize: Tokens.fontHeading
}
