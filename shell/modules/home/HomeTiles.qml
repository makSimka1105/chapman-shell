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

    spacing: Tokens.spacingRelaxed

    Grid {
        columns: 3
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
            id: powerTile
            glyph: root.currentProfile.glyph
            caption: "Power"
            glyphColor: PowerProfiles.profile === PowerProfile.Performance ? Theme.warning : Theme.accent
            captionColor: Theme.textDim
            onClicked: root.pickerToggled("power")
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

    Rectangle {
        visible: root.picker === "power"
        x: powerTile.x
        y: powerTile.y + powerTile.height + Tokens.spacingSmall
        width: powerRow.width + Tokens.spacingSmall * 2
        height: 42
        radius: height / 2
        color: Qt.rgba(0.08, 0.08, 0.09, 0.96)
        border.color: Theme.faint

        Row {
            id: powerRow
            anchors.centerIn: parent
            spacing: Tokens.spacingSmall

            Repeater {
                model: root.profiles

                Item {
                    required property var modelData
                    required property int index
                    width: 34
                    height: 34

                    Rectangle {
                        anchors.fill: parent
                        radius: height / 2
                        color: PowerProfiles.profile === modelData.profile ? Theme.card : "transparent"
                    }

                    Glyph {
                        anchors.centerIn: parent
                        text: modelData.glyph
                        color: PowerProfiles.profile === modelData.profile ? Theme.text : Theme.textDim
                        font.pixelSize: Tokens.fontSubtitle
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            PowerProfiles.profile = modelData.profile;
                            root.pickerToggled("power");
                        }
                    }
                }
            }
        }
    }
}
