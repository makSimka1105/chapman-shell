pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property real outputVolume: sink?.audio?.volume ?? 0
    readonly property bool outputMuted: sink?.audio?.muted ?? false
    readonly property real inputVolume: source?.audio?.volume ?? 0
    readonly property bool inputMuted: source?.audio?.muted ?? false
    readonly property var outputDevices: Pipewire.nodes.values
        .filter(node => node.isSink && !node.isStream && node.audio)
        .map(node => ({ id: String(node.id), label: node.description || node.nickname || node.name, node: node }))
    readonly property string outputId: sink ? String(sink.id) : ""

    function setOutputVolume(value) {
        if (sink?.audio)
            sink.audio.volume = Math.max(0, Math.min(1, value));
    }

    function setOutputMuted(muted) {
        if (sink?.audio)
            sink.audio.muted = muted;
    }

    function setInputVolume(value) {
        if (source?.audio)
            source.audio.volume = Math.max(0, Math.min(1, value));
    }

    function setInputMuted(muted) {
        if (source?.audio)
            source.audio.muted = muted;
    }

    function selectOutput(id) {
        const device = outputDevices.find(candidate => candidate.id === id);
        if (device)
            Pipewire.preferredDefaultAudioSink = device.node;
    }

    PwObjectTracker {
        objects: [root.sink, root.source]
    }
}
