pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property string backlight: "/sys/class/backlight/intel_backlight"
    property string kind: "volume"
    property real brightness: 0
    property bool ready: false
    property bool active: false
    readonly property real value: kind === "volume" ? (muted ? 0 : Math.min(1, volume)) : brightness
    readonly property string glyph: {
        if (kind === "brightness")
            return value > 0.66 ? "󰃠" : value > 0.33 ? "󰃟" : "󰃞";
        if (muted || volume <= 0)
            return "󰝟";
        return volume > 0.66 ? "󰕾" : volume > 0.33 ? "󰖀" : "󰕿";
    }

    function show(name) {
        kind = name;
        active = true;
        hide.restart();
    }

    function showBrightness() {
        brightnessFile.reload();
        maxFile.reload();
        brightness = Number(brightnessFile.text()) / Math.max(1, Number(maxFile.text()));
        show("brightness");
    }

    PwObjectTracker {
        objects: [root.sink]
    }

    Connections {
        target: root.sink?.audio ?? null
        ignoreUnknownSignals: true

        function onVolumeChanged() {
            if (root.ready)
                root.show("volume");
        }

        function onMutedChanged() {
            if (root.ready)
                root.show("volume");
        }
    }

    Timer {
        interval: 2000
        running: true
        onTriggered: root.ready = true
    }

    Timer {
        id: hide
        interval: 900
        onTriggered: root.active = false
    }

    FileView {
        id: brightnessFile
        path: root.backlight + "/brightness"
        blockLoading: true
    }

    FileView {
        id: maxFile
        path: root.backlight + "/max_brightness"
        blockLoading: true
    }
}
