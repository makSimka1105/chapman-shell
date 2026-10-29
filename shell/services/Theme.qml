pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string runtime: Quickshell.env("CHAPMAN_THEME_STATE") || home + "/.local/state/theme"
    readonly property var theme: colorsFile.text() ? JSON.parse(colorsFile.text()) : ({})
    readonly property string name: theme.id ?? "glass"
    readonly property var palette: {
        const colors = theme.colors ?? {};
        return { text: colors.on_surface ?? "white", accent: colors.primary ?? "white", warning: colors.error ?? "red" };
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
        id: colorsFile
        path: root.runtime + "/colors.json"
        blockLoading: true
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
    }
}
