import QtQuick
import Quickshell.Networking
import qs.core
import qs.services
import qs.widgets

Column {
    id: root

    readonly property var device: Status.wifi
    readonly property int shown: 5
    property var asking: null
    readonly property var networks: (device?.networks.values ?? [])
        .filter(network => network.name)
        .sort((a, b) => (b.connected - a.connected) || (b.known - a.known) || (b.signalStrength - a.signalStrength))
        .slice(0, shown)
    readonly property var bars: ["󰤟", "󰤢", "󰤥", "󰤨"]

    signal back

    function choose(network) {
        if (network.connected)
            network.disconnect();
        else if (network.known || network.security === WifiSecurityType.Open)
            network.connect();
        else
            asking = asking === network ? null : network;
    }

    spacing: Tokens.spacingHairline
    Component.onCompleted: if (device) device.scannerEnabled = true
    Component.onDestruction: if (device) device.scannerEnabled = false

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
        model: root.networks

        Column {
            id: entry

            required property var modelData
            readonly property bool secured: modelData.security !== WifiSecurityType.Open

            width: root.width
            spacing: Tokens.spacingHairline

            ListRow {
                width: parent.width
                height: Tokens.listRowHeight
                glyph: root.bars[Math.min(3, Math.floor(entry.modelData.signalStrength * 4))]
                title: entry.modelData.name
                subtitle: entry.modelData.connected ? "Connected" : entry.modelData.known ? "Saved" : ""
                trailing: entry.secured ? "󰌾" : ""
                active: entry.modelData.connected
                busy: entry.modelData.stateChanging
                onClicked: root.choose(entry.modelData)
            }

            Rectangle {
                visible: root.asking === entry.modelData
                width: parent.width
                height: 44
                radius: Tokens.radiusRow
                color: Theme.card
                border.color: Qt.alpha(Theme.accent, 0.5)

                TextInput {
                    id: password
                    anchors.fill: parent
                    anchors.leftMargin: Tokens.marginWide
                    anchors.rightMargin: Tokens.marginWide
                    verticalAlignment: TextInput.AlignVCenter
                    echoMode: TextInput.Password
                    color: Theme.text
                    font.family: Theme.font
                    font.pixelSize: Tokens.fontLabel
                    onVisibleChanged: if (visible) forceActiveFocus()
                    onAccepted: {
                        entry.modelData.connectWithPsk(text);
                        text = "";
                        root.asking = null;
                    }
                    Keys.onEscapePressed: root.asking = null

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: password.text === ""
                        text: "Password for " + entry.modelData.name
                        color: Theme.textDim
                        font.pixelSize: Tokens.fontLabel
                    }
                }
            }
        }
    }
}
