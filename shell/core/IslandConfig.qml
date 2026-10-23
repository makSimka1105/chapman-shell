pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string runtime: Quickshell.env("CHAPMAN_STATE") || Quickshell.env("HOME") + "/.local/state/chapman-shell"
    readonly property string userPath: runtime + "/config/island.json"
    readonly property var defaults: parse(defaultsFile.text())
    property var userLayer: migrate(parse(userFile.text()))
    property bool userExists: false
    readonly property var data: merge(defaults, userLayer)

    signal changed

    function parse(text) {
        try {
            return JSON.parse(text);
        } catch (error) {
            return ({});
        }
    }

    function migrate(tree) {
        const rest = tree.rest;
        if (rest !== undefined)
            for (const zone of ["left", "center", "right"])
                if (Array.isArray(rest[zone]))
                    rest[zone] = { items: rest[zone] };
        const home = tree.home;
        if (home !== undefined && Array.isArray(home.columns)) {
            home.items = home.columns.reduce((items, column, col) => items.concat(column.items.map(item => Object.assign({ col: col, span: 1 }, item))), []);
            home.grid = Object.assign({ columns: home.columns.length }, home.grid);
            delete home.columns;
        }
        return tree;
    }

    function merge(base, layer) {
        if (layer === undefined)
            return base;
        if (base === null || typeof base !== "object" || Array.isArray(base) || layer === null || typeof layer !== "object" || Array.isArray(layer))
            return layer;
        const result = Object.assign({}, base);
        for (const key of Object.keys(layer))
            result[key] = merge(base[key], layer[key]);
        return result;
    }

    function lookup(tree, path) {
        return path === "" ? tree : path.split(".").reduce((node, key) => node?.[key], tree);
    }

    function get(path) {
        return lookup(data, path);
    }

    function assign(tree, path, value) {
        const keys = path.split(".");
        const last = keys.pop();
        const parent = keys.reduce((node, key) => node[key], tree);
        parent[last] = value;
    }

    function set(path, value) {
        const next = JSON.parse(JSON.stringify(data));
        assign(next, path, JSON.parse(JSON.stringify(value)));
        userLayer = next;
        saveTimer.restart();
    }

    function reset(path) {
        if (path === "") {
            userLayer = JSON.parse(JSON.stringify(defaults));
            saveTimer.restart();
        } else {
            set(path, lookup(defaults, path));
        }
    }

    onDataChanged: changed()

    FileView {
        id: defaultsFile
        path: Quickshell.shellDir + "/defaults/island.json"
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()
    }

    FileView {
        id: userFile
        path: root.userPath
        blockLoading: true
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: {
            root.userExists = true;
            if (!saveTimer.running)
                root.userLayer = root.migrate(root.parse(userFile.text()));
        }
        onLoadFailed: root.userExists = false
    }

    Timer {
        interval: 500
        running: !root.userExists
        repeat: true
        onTriggered: userFile.reload()
    }

    Timer {
        id: saveTimer
        interval: 300
        onTriggered: {
            if (writer.running) {
                restart();
                return;
            }
            writer.command = ["sh", "-c", 'mkdir -p "$(dirname "$2")" && printf %s "$1" > "$2.tmp" && mv "$2.tmp" "$2"', "sh", JSON.stringify(root.userLayer, null, 2), root.userPath];
            writer.running = true;
        }
    }

    Process {
        id: writer
        onExited: userFile.reload()
    }
}
