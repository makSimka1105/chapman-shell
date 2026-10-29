import QtQuick
import Quickshell
import qs.core
import qs.services
import qs.widgets

Column {
    id: root

    required property string picker
    readonly property bool present: true
    readonly property string secondOutput: "HDMI-A-1"
    readonly property bool secondOn: Niri.workspaces.some(workspace => workspace.output === secondOutput)
    readonly property string tilingLabel: ({ halves: "Strip", grid: "Grid", tabs: "Tabs", float: "Float" })[Tiling.preset] ?? "Tiling"

    signal pageRequested(string page)
    signal pickerToggled(string name)

    spacing: Tokens.spacingRelaxed

    Grid {
        columns: 2
        spacing: Tokens.spacingItem

        HomeTile {
            glyph: "󰌌"
            caption: Niri.layoutCode
            glyphColor: Theme.textDim
            captionColor: Theme.textDim
            onClicked: root.pickerToggled("layout")
        }

        HomeTile {
            glyph: Tiling.glyph
            caption: root.tilingLabel
            glyphColor: Tiling.preset !== "none" ? Theme.accent : Theme.textDim
            captionColor: Tiling.preset !== "none" ? Theme.text : Theme.textDim
            onClicked: root.pickerToggled("tiling")
        }

        HomeTile {
            glyph: Notifications.dnd ? "󰂛" : "󰂚"
            caption: "DND"
            glyphColor: Notifications.dnd ? Theme.accent : Theme.textDim
            captionColor: Notifications.dnd ? Theme.text : Theme.textDim
            onClicked: Notifications.dnd = !Notifications.dnd
        }

        HomeTile {
            glyph: "󰅶"
            caption: "Awake"
            glyphColor: KeepAwake.active ? Theme.accent : Theme.textDim
            captionColor: KeepAwake.active ? Theme.text : Theme.textDim
            onClicked: KeepAwake.toggle()
        }

        HomeTile {
            glyph: "󰍺"
            caption: "iPad"
            glyphColor: root.secondOn ? Theme.accent : Theme.textDim
            captionColor: root.secondOn ? Theme.text : Theme.textDim
            onClicked: Spawn.run([Quickshell.env("HOME") + "/.local/bin/ipad", root.secondOn ? "off" : "on"])
        }

        HomeTile {
            glyph: "󰒓"
            caption: "Settings"
            glyphColor: Theme.textDim
            captionColor: Theme.textDim
            onClicked: Spawn.run(["qs", "-p", Quickshell.shellDir, "ipc", "call", "settings", "toggle"])
        }
    }
}
