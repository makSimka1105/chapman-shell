pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "Fuzzy.js" as Fuzzy

Singleton {
    id: root

    readonly property string stateDir: Quickshell.env("HOME") + "/.local/state/chapman-shell"
    readonly property var entries: DesktopEntries.applications.values.filter(e => !e.noDisplay)
    readonly property string terminal: "ghostty"
    readonly property int limit: 30
    property var launches: store.text() ? JSON.parse(store.text()) : ({})

    function score(entry, query) {
        const best = Math.max(
            Fuzzy.score(entry.name, query),
            Fuzzy.score(entry.genericName, query) * 0.6,
            Math.max(0, ...entry.keywords.map(k => Fuzzy.score(k, query))) * 0.5,
            Fuzzy.score(entry.id, query) * 0.4
        );
        return best > 0 ? best + 40 * Math.log2(1 + (launches[entry.id] ?? 0)) : 0;
    }

    function search(query) {
        const needle = query.trim().toLowerCase();
        if (needle === "")
            return [];
        return entries
            .map(entry => ({ entry, score: score(entry, needle) }))
            .filter(result => result.score > 0)
            .sort((a, b) => b.score - a.score)
            .slice(0, limit)
            .map(result => item(result.entry));
    }

    function item(entry) {
        return {
            kind: "app",
            title: entry.name,
            subtitle: entry.genericName || entry.comment,
            comment: entry.comment,
            icon: entry.icon,
            run: () => launch(entry)
        };
    }

    function launch(entry) {
        const updated = Object.assign({}, launches);
        updated[entry.id] = (updated[entry.id] ?? 0) + 1;
        launches = updated;
        store.setText(JSON.stringify(updated));
        const command = entry.runInTerminal ? [terminal, "-e", ...entry.command] : entry.command;
        Spawn.run(command);
    }

    Component.onCompleted: Quickshell.execDetached(["mkdir", "-p", stateDir])

    FileView {
        id: store
        path: root.stateDir + "/launches.json"
        blockLoading: true
        printErrors: false
    }
}
