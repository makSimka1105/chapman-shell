pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking

Singleton {
    id: root

    readonly property var device: Status.wifi
    readonly property var current: Status.wifiNetwork
    readonly property var networks: (device?.networks.values ?? [])
        .filter(network => network.name)
        .sort((a, b) => (b.connected - a.connected) || (b.known - a.known) || (b.signalStrength - a.signalStrength))
    readonly property var bars: ["󰤟", "󰤢", "󰤥", "󰤨"]
    property var asking: null
    property var pending: null
    property string problem
    property var addresses: ({})
    property int scanners: 0

    function bar(network) {
        return bars[Math.min(3, Math.floor(network.signalStrength * 4))];
    }

    function secured(network) {
        return network.security !== WifiSecurityType.Open;
    }

    function choose(network) {
        if (network.connected) {
            network.disconnect();
        } else if (network.known || !secured(network)) {
            pending = network;
            network.connect();
        } else {
            ask(network);
        }
    }

    function ask(network) {
        problem = "";
        asking = asking === network ? null : network;
    }

    function cancel() {
        problem = "";
        asking = null;
    }

    function submit(psk) {
        pending = asking;
        cancel();
        pending.connectWithPsk(psk);
    }

    function forget(network) {
        if (asking === network)
            cancel();
        network.forget();
    }

    function describeFailure(reason) {
        if (reason === ConnectionFailReason.WifiNetworkLost)
            return "Network is out of range";
        if (reason === ConnectionFailReason.WifiAuthTimeout)
            return "No answer from the network, try again";
        return "Wrong password, try again";
    }

    function scan(on) {
        scanners += on ? 1 : -1;
    }

    onCurrentChanged: {
        addresses = {};
        if (current && device)
            addressProcess.running = true;
    }

    Binding {
        target: root.device
        property: "scannerEnabled"
        value: root.scanners > 0
        when: root.device !== null
    }

    Connections {
        target: root.pending

        function onConnectionFailed(reason) {
            if (!root.secured(root.pending))
                return;
            root.asking = root.pending;
            root.problem = root.describeFailure(reason);
        }

        function onConnectedChanged() {
            if (root.pending.connected)
                root.pending = null;
        }
    }

    Process {
        id: addressProcess
        command: ["nmcli", "-t", "-f", "IP4.ADDRESS", "device", "show", root.device?.name ?? ""]
        stdout: StdioCollector {
            onStreamFinished: {
                const found = {};
                for (const line of text.trim().split("\n")) {
                    const split = line.indexOf(":");
                    const key = line.slice(0, split).replace(/\[\d+\]$/, "");
                    const value = line.slice(split + 1);
                    if (value)
                        found[key] = found[key] ? found[key] + ", " + value : value;
                }
                root.addresses = found;
            }
        }
    }
}
