pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string stateDir: Quickshell.env("HOME") + "/.local/state/chapman-shell"
    property bool active: flag.text().trim() === "1"

    function toggle() {
        active = !active;
        flag.setText(active ? "1" : "");
        switcher.command = ["codex-lid", active ? "on" : "off"];
        switcher.running = true;
    }

    Process {
        id: switcher
    }

    FileView {
        id: flag
        path: root.stateDir + "/lid-open"
        blockLoading: true
        blockWrites: true
        printErrors: false
    }
}
