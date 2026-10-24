import QtQuick
import Quickshell
import Quickshell.Networking
import qs.core
import qs.services
import qs.widgets

Column {
    id: root

    readonly property int shown: 5
    readonly property var asking: Wifi.asking
    readonly property var networks: {
        const top = Wifi.networks.slice(0, shown);
        if (asking && !top.includes(asking))
            top.push(asking);
        return top;
    }

    signal back

    spacing: Tokens.spacingHairline
    Component.onCompleted: Wifi.scan(true)
    Component.onDestruction: {
        Wifi.cancel();
        Wifi.scan(false);
    }

    PageHeader {
        width: parent.width
        title: "Wi-Fi"
        switchable: true
        checked: Networking.wifiEnabled
        onBack: root.back()
        onToggled: Networking.wifiEnabled = !Networking.wifiEnabled
    }

    Label {
        visible: root.networks.length === 0
        width: parent.width
        height: Tokens.listRowHeight
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        text: Networking.wifiEnabled ? "Searching…" : "Wi-Fi is off"
        color: Theme.textDim
        font.pixelSize: Tokens.fontMedium
        font.weight: Font.Medium
    }

    Repeater {
        model: ScriptModel {
            values: root.networks
        }

        Column {
            id: entry

            required property var modelData

            width: root.width
            spacing: Tokens.spacingHairline

            ListRow {
                width: parent.width
                height: Tokens.listRowHeight
                glyph: Wifi.bar(entry.modelData)
                title: entry.modelData.name
                subtitle: entry.modelData.connected ? "Connected" : entry.modelData.known ? "Saved · right click to change password" : ""
                trailing: Wifi.secured(entry.modelData) ? "󰌾" : ""
                active: entry.modelData.connected
                busy: entry.modelData.stateChanging
                onClicked: Wifi.choose(entry.modelData)
                onSecondaryClicked: if (Wifi.secured(entry.modelData)) Wifi.ask(entry.modelData)
            }

            Loader {
                width: parent.width
                active: root.asking === entry.modelData
                visible: active

                sourceComponent: PasswordField {
                    placeholder: (entry.modelData.known ? "New password for " : "Password for ") + entry.modelData.name
                    problem: Wifi.problem
                    onAccepted: text => Wifi.submit(text)
                    onCancelled: Wifi.cancel()
                }
            }
        }
    }
}
