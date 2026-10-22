pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string name: current.text().trim()
    readonly property string folder: home + "/.config/themes/" + name
    readonly property var theme: themeFile.text() ? JSON.parse(themeFile.text()) : ({})
    readonly property bool custom: theme.dms?.currentThemeName === "custom"
    readonly property var palette: {
        if (custom && paletteFile.text()) {
            const colors = JSON.parse(paletteFile.text()).dark;
            return { text: colors.surfaceText, accent: colors.primary, warning: colors.error };
        }
        const generated = JSON.parse(generatedFile.text());
        const colors = generated.colors[generated.mode];
        return { text: colors.on_surface, accent: colors.primary, warning: colors.error };
    }
    readonly property string wallpaper: theme.wallpaper ?? ""

    readonly property color body: "black"
    readonly property color text: palette.text
    readonly property color textDim: Qt.alpha(palette.text, 0.55)
    readonly property color faint: Qt.alpha(palette.text, 0.16)
    readonly property color card: Qt.alpha(palette.text, 0.05)
    readonly property color accent: palette.accent
    readonly property color warning: palette.warning
    readonly property color charge: "#4cd964"
    readonly property string font: "Noto Sans"

    FileView {
        id: current
        path: root.home + "/.local/state/theme"
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()
    }

    FileView {
        id: themeFile
        path: root.folder + "/theme.json"
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()
    }

    FileView {
        id: paletteFile
        path: root.folder + "/dms.json"
        blockLoading: true
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
    }

    FileView {
        id: generatedFile
        path: root.home + "/.cache/DankMaterialShell/dms-colors.json"
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()
    }
}
