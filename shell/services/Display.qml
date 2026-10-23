pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real brightness: 0
    property var outputs: []

    function refresh() {
        brightnessProcess.running = true;
        outputsProcess.running = true;
    }

    function setBrightness(value) {
        const percent = Math.round(Math.max(0.01, Math.min(1, value)) * 100);
        brightness = percent / 100;
        Quickshell.execDetached(["brightnessctl", "--class=backlight", "set", percent + "%"]);
    }

    function describeMode(output) {
        const mode = output.modes[output.current_mode ?? -1];
        if (!mode)
            return "Off";
        const hertz = Math.round(mode.refresh_rate / 1000);
        return mode.width + "x" + mode.height + " @ " + hertz + " Hz";
    }

    function describeOutput(output) {
        const scale = output.logical ? "  /  scale " + output.logical.scale : "";
        return describeMode(output) + scale;
    }

    Component.onCompleted: refresh()

    Process {
        id: brightnessProcess
        command: ["brightnessctl", "-m", "--class=backlight"]
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = text.trim().split(",");
                root.brightness = Number(fields[2]) / Math.max(1, Number(fields[4]));
            }
        }
    }

    Process {
        id: outputsProcess
        command: ["niri", "msg", "--json", "outputs"]
        stdout: StdioCollector {
            onStreamFinished: root.outputs = Object.values(JSON.parse(text)).sort((a, b) => a.name.localeCompare(b.name))
        }
    }
}
