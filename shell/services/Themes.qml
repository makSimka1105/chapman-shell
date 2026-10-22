pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string bin: Quickshell.env("HOME") + "/.local/bin/theme"
    property var themes: []

    function refresh() {
        listProcess.running = true;
    }

    function search(query) {
        const needle = query.trim().toLowerCase();
        return themes
            .filter(theme => theme.name.toLowerCase().includes(needle))
            .map(theme => ({
                kind: "theme",
                title: theme.name,
                subtitle: theme.current ? "Current" : theme.palette,
                image: theme.wallpaper,
                run: () => Spawn.run([bin, theme.name])
            }));
    }

    Process {
        id: listProcess
        command: [root.bin, "--json"]
        stdout: StdioCollector {
            onStreamFinished: root.themes = JSON.parse(text)
        }
    }
}
