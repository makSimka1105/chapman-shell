import QtQuick
import qs.services
import "../../services/Calc.js" as Calc

QtObject {
    function group(title, items) {
        return items.length > 0 ? [{ header: true, title }, ...items] : [];
    }

    function calculation(query) {
        const value = Calc.evaluate(query.replace(/^=/, ""));
        if (value === null)
            return [];
        const text = Calc.format(value);
        return [{
            kind: "calc",
            title: text,
            subtitle: query.replace(/^=/, "") + " =",
            glyph: "\uf1ec",
            run: () => Spawn.run(["wl-copy", text])
        }];
    }

    function build(text) {
        const query = text.trim();
        if (query.startsWith("#"))
            return group("Themes", Themes.search(query.slice(1)));
        if (query.startsWith(":"))
            return group("Clipboard", Clipboard.search(query.slice(1)));
        if (query === "")
            return [];
        return [
            ...group("Calculator", calculation(query)),
            ...group("Actions", Actions.search(query)),
            ...group("Applications", Apps.search(query)),
            ...group("Files", Files.items)
        ];
    }
}
