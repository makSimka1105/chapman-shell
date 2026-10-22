pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string bin: Quickshell.shellDir + "/../bin/chapman-shell"
    property var themes: []

    function refresh() {
        listProcess.running = true;
    }

    function apply(id) {
        Quickshell.execDetached([bin, "theme", id]);
    }

    function setWallpaper(path) {
        Quickshell.execDetached([bin, "wallpaper", path]);
    }

    function search(query) {
        const needle = query.trim().toLowerCase();
        return themes
            .filter(theme => theme.name.toLowerCase().includes(needle))
            .map(theme => ({
                kind: "theme",
                title: theme.name,
                subtitle: theme.id === Theme.name ? "Current" : theme.id,
                image: theme.wallpapers[0],
                run: () => apply(theme.id)
            }));
    }

    Component.onCompleted: refresh()

    Process {
        id: listProcess
        command: [root.bin, "theme", "--json"]
        stdout: StdioCollector {
            onStreamFinished: root.themes = JSON.parse(text)
        }
    }
}
