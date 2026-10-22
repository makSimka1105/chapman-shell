pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string tool: Quickshell.env("HOME") + "/.config/niri/scripts/niri-layout"
    readonly property var presets: [
        { id: "halves", label: "Strip", glyph: "󰕴" },
        { id: "grid", label: "Grid", glyph: "󰕮" },
        { id: "tabs", label: "Tabs", glyph: "󰓩" },
        { id: "float", label: "Floating", glyph: "󰖲" }
    ]
    property string preset: "none"
    readonly property int workspaceId: Niri.workspaces.find(w => w.is_focused)?.id ?? -1
    readonly property string glyph: presets.find(p => p.id === preset)?.glyph ?? "󰕰"

    function run(args) {
        runner.command = [tool].concat(args);
        runner.running = true;
    }

    function apply(id) {
        run(["toggle", id]);
    }

    function restore() {
        run(["restore"]);
    }

    function refresh() {
        if (!status.running)
            status.running = true;
    }

    onWorkspaceIdChanged: settle.restart()

    Connections {
        target: Niri

        function onWindowsChanged() {
            settle.restart();
        }
    }

    Timer {
        id: settle
        interval: 150
        onTriggered: root.refresh()
    }

    Process {
        id: status
        command: [root.tool, "status"]
        stdout: StdioCollector {
            onStreamFinished: root.preset = text.trim() || "none"
        }
    }

    Process {
        id: runner
        onExited: settle.restart()
    }

    Component.onCompleted: refresh()
}
