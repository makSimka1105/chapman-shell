pragma Singleton
import QtQuick
import Quickshell
import "Fuzzy.js" as Fuzzy

Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property int minScore: 400
    readonly property int limit: 4
    readonly property var actions: [
        { title: "Themes", subtitle: "Desktop themes with #", glyph: "󰏘", keywords: ["theme", "colors", "wallpaper"], prefill: "#" },
        { title: "Clipboard History", subtitle: "Copied items with :", glyph: "\uf0ea", keywords: ["clipboard", "paste", "copy"], prefill: ":" },
        { title: "Screenshot", subtitle: "Select an area", glyph: "󰹑", keywords: ["capture", "screen"], command: ["sh", "-c", "sleep 0.3; niri msg action screenshot"] },
        { title: "Switch to DMS", subtitle: "Shell", glyph: "󰍹", keywords: ["shell", "dms"], command: [home + "/.local/bin/shell", "dms"] },
        { title: "Suspend", subtitle: "System", glyph: "󰤄", keywords: ["sleep"], command: ["systemctl", "suspend"] },
        { title: "Log Out", subtitle: "System", glyph: "󰍃", keywords: ["logout", "exit", "quit"], command: ["niri", "msg", "action", "quit", "--skip-confirmation"], confirm: true },
        { title: "Restart", subtitle: "System", glyph: "󰜉", keywords: ["reboot"], command: ["systemctl", "reboot"], confirm: true },
        { title: "Shut Down", subtitle: "System", glyph: "󰐥", keywords: ["poweroff", "shutdown"], command: ["systemctl", "poweroff"], confirm: true }
    ]

    function score(action, query) {
        return Math.max(Fuzzy.score(action.title, query), ...action.keywords.map(k => Fuzzy.score(k, query) * 0.8));
    }

    function search(query) {
        const needle = query.trim().toLowerCase();
        return actions
            .map(action => ({ action, score: score(action, needle) }))
            .filter(result => result.score >= minScore)
            .sort((a, b) => b.score - a.score)
            .slice(0, limit)
            .map(result => Object.assign({ kind: "action", run: () => Spawn.run(result.action.command) }, result.action));
    }
}
