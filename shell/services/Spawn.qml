pragma Singleton
import QtQuick
import Quickshell

Singleton {
    function run(command) {
        Quickshell.execDetached(["niri", "msg", "action", "spawn", "--", ...command]);
    }
}
