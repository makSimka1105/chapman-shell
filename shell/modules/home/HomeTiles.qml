import QtQuick
import Quickshell
import Quickshell.Services.UPower
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
    readonly property var profiles: [
        { profile: PowerProfile.PowerSaver, glyph: "󰌪" },
        { profile: PowerProfile.Balanced, glyph: "󰾅" },
        { profile: PowerProfile.Performance, glyph: "󱐋" }
    ].filter(entry => entry.profile !== PowerProfile.Performance || PowerProfiles.hasPerformanceProfile)
    readonly property var currentProfile: profiles.find(entry => entry.profile === PowerProfiles.profile) ?? profiles[0]

    signal pageRequested(string page)
    signal pickerToggled(string name)

    function cycleLayout() {
        if (Niri.layouts.length > 0)
            Spawn.run(["niri", "msg", "action", "switch-layout", String((Niri.layoutIndex + 1) % Niri.layouts.length)]);
    }

    function cyclePowerProfile() {
        const index = profiles.findIndex(entry => entry.profile === PowerProfiles.profile);
        PowerProfiles.profile = profiles[(index + 1) % profiles.length].profile;
    }

    spacing: Tokens.spacingRelaxed

    Grid {
        columns: 3
        spacing: Tokens.spacingItem

        HomeTile {
            glyph: "󰌌"
            caption: Niri.layoutCode
            glyphColor: Theme.textDim
            captionColor: Theme.textDim
            onClicked: root.cycleLayout()
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
            onClicked: Notifications.toggleDnd()
        }

        HomeTile {
            glyph: "󰅶"
            caption: "Awake"
            glyphColor: KeepAwake.active ? Theme.accent : Theme.textDim
            captionColor: KeepAwake.active ? Theme.text : Theme.textDim
            onClicked: KeepAwake.toggle()
        }

        HomeTile {
            glyph: "󰛐"
            caption: "Lid"
            glyphColor: LidOpen.active ? Theme.accent : Theme.textDim
            captionColor: LidOpen.active ? Theme.text : Theme.textDim
            onClicked: LidOpen.toggle()
        }

        HomeTile {
            glyph: "󰄀"
            caption: "Limits"
            glyphColor: Theme.textDim
            captionColor: Theme.textDim
            onClicked: root.pageRequested("usage")
        }

        HomeTile {
            glyph: root.currentProfile.glyph
            caption: "Power"
            glyphColor: PowerProfiles.profile === PowerProfile.Performance ? Theme.warning : Theme.accent
            captionColor: Theme.textDim
            onClicked: root.cyclePowerProfile()
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
