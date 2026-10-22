pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string runtime: Quickshell.env("CHAPMAN_STATE") || home + "/.local/state/chapman-shell"
    readonly property var selection: currentFile.text() ? JSON.parse(currentFile.text()) : ({})
    readonly property string name: selection.theme ?? "glass"
    readonly property string folder: Quickshell.shellDir + "/../themes/" + name
    readonly property var theme: themeFile.text() ? JSON.parse(themeFile.text()) : ({})
    readonly property var palette: {
        const colors = theme.colors;
        return { text: colors.on_surface, accent: colors.primary, warning: colors.error };
    }
    readonly property string wallpaper: selection.wallpaper ?? theme.wallpapers?.[0] ?? ""

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
        id: currentFile
        path: root.runtime + "/current.json"
        blockLoading: true
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
    }

    FileView {
        id: themeFile
        path: root.folder + "/theme.json"
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()
    }
}
