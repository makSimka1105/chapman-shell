pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int limit: 40
    readonly property string imageMark: "[[ binary data"
    property var entries: []

    function refresh() {
        list.running = true;
    }

    function parse(line) {
        const tab = line.indexOf("\t");
        const text = line.slice(tab + 1);
        return { id: line.slice(0, tab), text, isImage: text.startsWith(imageMark) };
    }

    function item(entry) {
        const single = entry.text.replace(/\s+/g, " ").trim();
        return {
            kind: "clip",
            title: entry.isImage ? "Image" : single,
            subtitle: entry.isImage ? entry.text.replace(/^\[\[ binary data |\]\]$/g, "") : entry.text.length + " chars",
            glyph: entry.isImage ? "" : "",
            clipId: entry.id,
            isImage: entry.isImage,
            run: () => Spawn.run(["sh", "-c", "cliphist decode \"$1\" | wl-copy", "sh", entry.id])
        };
    }

    function search(query) {
        const needle = query.trim().toLowerCase();
        return entries
            .filter(entry => needle === "" || (!entry.isImage && entry.text.toLowerCase().includes(needle)))
            .slice(0, limit)
            .map(item);
    }

    Process {
        id: list
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: root.entries = text.split("\n").filter(line => line.includes("\t")).map(root.parse)
        }
    }

    Process {
        running: true
        command: ["wl-paste", "--type", "text", "--watch", "cliphist", "store"]
    }

    Process {
        running: true
        command: ["wl-paste", "--type", "image", "--watch", "cliphist", "store"]
    }
}
