import QtQuick
import Quickshell
import Quickshell.Io

Image {
    id: root

    required property string name
    property int shots: 0
    readonly property string path: Quickshell.env("XDG_RUNTIME_DIR") + "/notch-" + name + ".ppm"

    signal captured

    function capture(output) {
        snapshot.command = ["grim", "-t", "ppm", "-o", output, path];
        snapshot.running = true;
    }

    visible: false
    cache: false
    source: shots > 0 ? "file://" + path + "?" + shots : ""
    onStatusChanged: if (status === Image.Ready) captured()

    Process {
        id: snapshot
        onExited: root.shots++
    }
}
