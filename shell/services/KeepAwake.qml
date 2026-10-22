pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool active: false

    function toggle() {
        active = !active;
        switcher.command = ["systemctl", "--user", active ? "stop" : "start", "chapman-shell-idle"];
        switcher.running = true;
    }

    Process {
        id: switcher
    }
}
