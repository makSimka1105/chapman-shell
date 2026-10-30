pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string bin: Quickshell.shellDir + "/../bin/chapman-shell"
    property var themes: []
    property var schemes: []

    function run(args) {
        commandProcess.command = [bin, ...args];
        commandProcess.running = true;
    }

    function refresh() {
        listProcess.running = true;
    }

    function apply(id) {
        Quickshell.execDetached([bin, "theme", id]);
    }

    function setWallpaper(path) {
        Quickshell.execDetached([bin, "wallpaper", path]);
    }

    function create(id) {
        run(["theme", "new", id]);
    }

    function importScheme(name) {
        run(["theme", "import", name]);
    }

    function remove(id) {
        run(["theme", "delete", id]);
    }

    function removeWallpaper(path) {
        run(["wallpaper", "remove", path]);
    }

    function addWallpapers(paths) {
        run(["wallpaper", "add", ...paths]);
    }

    function pickWallpapers() {
        pickProcess.running = true;
    }

    function openWallpapers() {
        Quickshell.execDetached(["sh", "-c", "dir=$(\"$0\" wallpaper dir) && mkdir -p \"$dir\" && xdg-open \"$dir\"", bin]);
    }

    function loadSchemes() {
        if (schemes.length === 0)
            schemesProcess.running = true;
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

    Process {
        id: commandProcess
        onExited: root.refresh()
    }

    Process {
        id: schemesProcess
        command: [root.bin, "schemes", "--json"]
        stdout: StdioCollector {
            onStreamFinished: root.schemes = JSON.parse(text)
        }
    }

    Process {
        id: pickProcess
        command: [Quickshell.shellDir + "/../../../bin/chapman-pick", "Обои для темы"]
        stdout: StdioCollector {
            onStreamFinished: {
                const paths = text.split("\n").filter(path => path.length > 0);
                if (paths.length > 0)
                    root.addWallpapers(paths);
            }
        }
    }
}
