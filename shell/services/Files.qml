pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "Fuzzy.js" as Fuzzy

Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property int minLength: 2
    readonly property int fetchLimit: 80
    readonly property int limit: 6
    readonly property var excluded: ["go", "result"]
    readonly property var images: ["png", "jpg", "jpeg", "webp", "gif", "bmp", "svg"]
    readonly property var texts: ["txt", "md", "qml", "js", "ts", "py", "go", "rs", "c", "cpp", "h", "java", "cs", "json", "toml", "yaml", "yml", "kdl", "nix", "sh", "css", "html", "sql", "conf", "ini", "lua"]
    property string query
    property var items: []

    function search(text) {
        query = text.trim();
        if (query.length < minLength) {
            items = [];
            finder.running = false;
            return;
        }
        debounce.restart();
    }

    function extension(path) {
        const name = path.split("/").pop();
        const dot = name.lastIndexOf(".");
        return dot > 0 ? name.slice(dot + 1).toLowerCase() : "";
    }

    function tilde(path) {
        return path.startsWith(home) ? "~" + path.slice(home.length) : path;
    }

    function glyph(path, isDir) {
        const ext = extension(path);
        if (isDir)
            return "";
        if (images.includes(ext))
            return "";
        if (ext === "pdf")
            return "";
        if (["zip", "tar", "gz", "xz", "7z", "rar", "zst"].includes(ext))
            return "";
        if (["mp3", "flac", "ogg", "wav", "m4a"].includes(ext))
            return "";
        if (["mp4", "mkv", "webm", "mov", "avi"].includes(ext))
            return "";
        if (texts.includes(ext))
            return "";
        return "";
    }

    function item(line) {
        const isDir = line.endsWith("/");
        const path = isDir ? line.slice(0, -1) : line;
        const name = path.split("/").pop();
        const parent = path.slice(0, path.length - name.length - 1);
        return {
            kind: "file",
            title: name,
            subtitle: tilde(parent),
            glyph: glyph(path, isDir),
            path,
            isDir,
            image: images.includes(extension(path)) ? "file://" + path : undefined,
            text: texts.includes(extension(path)),
            run: () => Spawn.run(["xdg-open", path])
        };
    }

    function rank(lines) {
        const needle = query.toLowerCase();
        return lines
            .map(line => {
                const name = line.replace(/\/$/, "").split("/").pop();
                return { line, score: Fuzzy.score(name, needle) - line.split("/").length * 6 };
            })
            .sort((a, b) => b.score - a.score)
            .slice(0, limit)
            .map(result => item(result.line));
    }

    Timer {
        id: debounce
        interval: 120
        onTriggered: {
            finder.running = false;
            finder.command = ["fd", "--ignore-case", "--absolute-path", "--max-results", String(root.fetchLimit), ...[].concat(...root.excluded.map(dir => ["--exclude", dir])), "--fixed-strings", "--", root.query, root.home];
            finder.running = true;
        }
    }

    Process {
        id: finder
        stdout: StdioCollector {
            onStreamFinished: root.items = root.query.length < root.minLength ? [] : root.rank(text.split("\n").filter(line => line.length > 0))
        }
    }
}
