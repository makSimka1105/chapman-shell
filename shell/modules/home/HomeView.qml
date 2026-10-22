import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Services.UPower
import qs.core
import qs.services
import qs.widgets

Item {
    id: root

    required property string output
    readonly property var app: Niri.focusedWindow ? DesktopEntries.heuristicLookup(Niri.focusedWindow.app_id) : null
    readonly property real side: 36
    readonly property real gutter: 14
    readonly property bool bluetoothOn: Bluetooth.defaultAdapter?.enabled ?? false
    readonly property bool bluetoothLinked: Bluetooth.defaultAdapter?.devices.values.some(device => device.connected) ?? false
    readonly property var headset: Bluetooth.defaultAdapter?.devices.values.find(device => device.connected) ?? null
    readonly property var profiles: [
        { profile: PowerProfile.PowerSaver, glyph: "󰌪", title: "Power Saver", short: "Save" },
        { profile: PowerProfile.Balanced, glyph: "󰾅", title: "Balanced", short: "Bal" },
        { profile: PowerProfile.Performance, glyph: "󱐋", title: "Performance", short: "Perf" }
    ].filter(entry => entry.profile !== PowerProfile.Performance || PowerProfiles.hasPerformanceProfile)

    readonly property int notificationCount: Notifications.history.length
    readonly property string notificationApps: {
        const names = [];
        for (const item of Notifications.history)
            if (item.appName && names.indexOf(item.appName) < 0)
                names.push(item.appName);
        return names.slice(0, 2).join(", ");
    }
    readonly property string tilingLabel: ({ halves: "Strip", grid: "Grid", tabs: "Tabs", float: "Float" })[Tiling.preset] ?? "Tiling"
    property string picker

    signal pageRequested(string page)

    onVisibleChanged: if (!visible) picker = ""

    MouseArea {
        anchors.fill: parent
        z: -1
        onPressed: mouse => mouse.accepted = root.picker !== ""
        onClicked: root.picker = ""
    }

    Column {
        id: leftColumn
        anchors.left: parent.left
        anchors.leftMargin: root.side
        anchors.verticalCenter: parent.verticalCenter
        spacing: Tokens.spacingMedium

        HomeFocus {
            title: root.app?.name ?? Niri.focusedWindow?.app_id ?? "Desktop"
        }

        Workspaces {
            output: root.output
            capsuleWidth: 10
            capsuleHeight: 18
            activeHeight: 24
        }

        HomeUsage {
            onClicked: root.pageRequested("usage")
        }
    }

    Column {
        id: powerColumn
        anchors.left: leftColumn.right
        anchors.leftMargin: 34
        anchors.verticalCenter: parent.verticalCenter
        spacing: Tokens.spacingLarge

        BatteryCard {
            id: batteryCard
        }

        MediaCard {
            visible: Media.active
            width: Math.max(250, batteryCard.width)
            height: 64
        }
    }

    HomeClock {
        anchors.right: parent.horizontalCenter
        anchors.rightMargin: root.gutter / 2
        anchors.verticalCenter: parent.verticalCenter
    }

    Calendar {
        anchors.left: parent.horizontalCenter
        anchors.leftMargin: root.gutter / 2
        anchors.verticalCenter: parent.verticalCenter
    }

    Row {
        id: status
        anchors.right: parent.right
        anchors.rightMargin: root.side
        anchors.verticalCenter: parent.verticalCenter
        spacing: 20

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 18

            HomeLink {
                glyph: Status.wifiNetwork !== null ? "󰤨" : "󰤭"
                title: "Wi-Fi"
                caption: Status.wifiNetwork?.name ?? (Networking.wifiEnabled ? "Not connected" : "Off")
                tint: Status.wifiNetwork !== null ? Theme.accent : Theme.textDim
                onClicked: root.pageRequested("wifi")
            }

            HomeLink {
                glyph: root.bluetoothLinked ? "󰂱" : root.bluetoothOn ? "󰂯" : "󰂲"
                title: "Bluetooth"
                caption: root.headset ? root.headset.name + (root.headset.batteryAvailable ? " " + Math.round(root.headset.battery * 100) + "%" : "") : root.bluetoothOn ? "No device" : "Off"
                tint: root.bluetoothOn ? Theme.accent : Theme.textDim
                onClicked: root.pageRequested("bluetooth")
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: Tokens.spacingRelaxed

            Grid {
                columns: 2
                spacing: Tokens.spacingItem

                HomeTile {
                    glyph: "󰌌"
                    caption: Niri.layoutCode
                    glyphColor: Theme.textDim
                    captionColor: Theme.textDim
                    onClicked: root.picker = root.picker === "layout" ? "" : "layout"
                }

                HomeTile {
                    glyph: Tiling.glyph
                    caption: root.tilingLabel
                    glyphColor: Tiling.preset !== "none" ? Theme.accent : Theme.textDim
                    captionColor: Tiling.preset !== "none" ? Theme.text : Theme.textDim
                    onClicked: root.picker = root.picker === "tiling" ? "" : "tiling"
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
            }

            HomeLink {
                glyph: root.notificationCount === 0 ? "󰂛" : "󰂚"
                title: root.notificationCount === 0 ? "Quiet" : root.notificationCount + " new"
                caption: root.notificationCount === 0 ? "No notifications" : root.notificationApps
                tint: root.notificationCount === 0 ? Theme.textDim : Theme.accent
                onClicked: root.pageRequested("notifications")
            }
        }
    }

    HoverPicker {
        anchors.right: parent.right
        anchors.rightMargin: root.side - 14
        anchors.verticalCenter: parent.verticalCenter
        held: root.picker === "layout"
        entries: Niri.layouts.slice(0, 4).map((name, index) => ({
                    glyph: "󰌌",
                    title: name,
                    active: Niri.layoutIndex === index
                }))
        onPicked: index => {
            Spawn.run(["niri", "msg", "action", "switch-layout", String(index)]);
            root.picker = "";
        }
    }

    HoverPicker {
        anchors.right: parent.right
        anchors.rightMargin: root.side - 14
        anchors.verticalCenter: parent.verticalCenter
        held: root.picker === "tiling"
        entries: Tiling.presets.map(entry => ({
                    glyph: entry.glyph,
                    title: entry.label,
                    active: Tiling.preset === entry.id
                })).concat([{ glyph: "󰕌", title: "Restore", active: false }])
        onPicked: index => {
            if (index < Tiling.presets.length)
                Tiling.apply(Tiling.presets[index].id);
            else
                Tiling.restore();
            root.picker = "";
        }
    }
}
