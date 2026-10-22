import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Services.UPower
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

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Column {
        id: leftColumn
        anchors.left: parent.left
        anchors.leftMargin: root.side
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12

        Row {
            spacing: 8

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 6
                height: 6
                radius: 3
                color: Theme.accent
            }

            Label {
                width: 150
                text: root.app?.name ?? Niri.focusedWindow?.app_id ?? "Desktop"
                elide: Text.ElideRight
                font.pixelSize: 15
                font.weight: Font.Medium
            }
        }

        Workspaces {
            output: root.output
            capsuleWidth: 10
            capsuleHeight: 18
            activeHeight: 24
        }

        Item {
            width: usageColumn.width
            height: usageColumn.height

            Column {
                id: usageColumn
                spacing: 7

                Repeater {
                    model: [
                        { label: "5h", value: Usage.fiveHour, text: Math.round(Usage.fiveHour * 100) + "%" },
                        { label: "7d", value: Usage.sevenDay, text: Math.round(Usage.sevenDay * 100) + "%" },
                        { label: "OR", value: Usage.openRouterUsed, text: "$" + Usage.openRouterSpend.toFixed(2) }
                    ]

                    Row {
                        required property var modelData

                        spacing: 8

                        Label {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 22
                            text: parent.modelData.label
                            color: Theme.textDim
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                        }

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 110
                            height: 6
                            radius: 3
                            color: Theme.faint

                            Rectangle {
                                width: Usage.known ? Math.max(parent.height, parent.width * Math.min(1, parent.parent.modelData.value)) : 0
                                height: parent.height
                                radius: 3
                                color: parent.parent.modelData.value > 0.85 ? Theme.warning : Theme.accent

                                Behavior on width {
                                    NumberAnimation {
                                        duration: 400
                                        easing.type: Easing.OutCubic
                                    }
                                }
                            }
                        }

                        Label {
                            anchors.verticalCenter: parent.verticalCenter
                            text: Usage.known ? parent.modelData.text : "-"
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                        }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -8
                cursorShape: Qt.PointingHandCursor
                onClicked: root.pageRequested("usage")
            }
        }
    }

    Column {
        id: powerColumn
        anchors.left: leftColumn.right
        anchors.leftMargin: 34
        anchors.verticalCenter: parent.verticalCenter
        spacing: 14

        BatteryCard {
            id: batteryCard
        }

        MediaCard {
            visible: Media.active
            width: Math.max(250, batteryCard.width)
            height: 64
        }
    }

    Column {
        id: clockColumn
        anchors.right: parent.horizontalCenter
        anchors.rightMargin: root.gutter / 2
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12

        Column {
            spacing: 0

            Label {
                text: Qt.formatTime(clock.date, "HH:mm")
                font.pixelSize: 40
                font.weight: Font.DemiBold
            }

            Label {
                text: clock.date.toLocaleDateString(Qt.locale("en_US"), "dddd, MMMM d")
                color: Theme.textDim
                font.pixelSize: 14
            }
        }
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

            Item {
                width: 124
                height: wifiText.height

                Column {
                    id: wifiText
                    spacing: 1

                    Row {
                        spacing: 6

                        Glyph {
                            anchors.verticalCenter: parent.verticalCenter
                            text: Status.wifiNetwork !== null ? "󰤨" : "󰤭"
                            color: Status.wifiNetwork !== null ? Theme.accent : Theme.textDim
                            font.pixelSize: 15
                        }

                        Label {
                            text: "Wi-Fi"
                            color: Status.wifiNetwork !== null ? Theme.accent : Theme.textDim
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                        }
                    }

                    Label {
                        width: 124
                        text: Status.wifiNetwork?.name ?? (Networking.wifiEnabled ? "Not connected" : "Off")
                        color: Theme.textDim
                        elide: Text.ElideRight
                        font.pixelSize: 13
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.pageRequested("wifi")
                }
            }

            Item {
                width: 124
                height: bluetoothText.height

                Column {
                    id: bluetoothText
                    spacing: 1

                    Row {
                        spacing: 6

                        Glyph {
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.bluetoothLinked ? "󰂱" : root.bluetoothOn ? "󰂯" : "󰂲"
                            color: root.bluetoothOn ? Theme.accent : Theme.textDim
                            font.pixelSize: 15
                        }

                        Label {
                            text: "Bluetooth"
                            color: root.bluetoothOn ? Theme.accent : Theme.textDim
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                        }
                    }

                    Label {
                        width: 124
                        text: root.headset ? root.headset.name + (root.headset.batteryAvailable ? " " + Math.round(root.headset.battery * 100) + "%" : "") : root.bluetoothOn ? "No device" : "Off"
                        color: Theme.textDim
                        elide: Text.ElideRight
                        font.pixelSize: 13
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.pageRequested("bluetooth")
                }
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            Grid {
                columns: 2
                spacing: 8

                Rectangle {
                    width: 58
                    height: 46
                    radius: 14
                    color: Theme.card

                    Column {
                        anchors.centerIn: parent
                        spacing: 2

                        Glyph {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "󰌌"
                            color: false ? Theme.accent : Theme.textDim
                            font.pixelSize: 18
                        }

                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Niri.layoutCode
                            color: false ? Theme.text : Theme.textDim
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.picker = root.picker === "layout" ? "" : "layout"
                    }
                }

                Rectangle {
                    width: 58
                    height: 46
                    radius: 14
                    color: Theme.card

                    Column {
                        anchors.centerIn: parent
                        spacing: 2

                        Glyph {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Tiling.glyph
                            color: Tiling.preset !== "none" ? Theme.accent : Theme.textDim
                            font.pixelSize: 18
                        }

                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.tilingLabel
                            color: Tiling.preset !== "none" ? Theme.text : Theme.textDim
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.picker = root.picker === "tiling" ? "" : "tiling"
                    }
                }

                Rectangle {
                    width: 58
                    height: 46
                    radius: 14
                    color: Theme.card

                    Column {
                        anchors.centerIn: parent
                        spacing: 2

                        Glyph {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Notifications.dnd ? "󰂛" : "󰂚"
                            color: Notifications.dnd ? Theme.accent : Theme.textDim
                            font.pixelSize: 18
                        }

                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "DND"
                            color: Notifications.dnd ? Theme.text : Theme.textDim
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Notifications.dnd = !Notifications.dnd
                    }
                }

                Rectangle {
                    width: 58
                    height: 46
                    radius: 14
                    color: Theme.card

                    Column {
                        anchors.centerIn: parent
                        spacing: 2

                        Glyph {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "󰅶"
                            color: KeepAwake.active ? Theme.accent : Theme.textDim
                            font.pixelSize: 18
                        }

                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Awake"
                            color: KeepAwake.active ? Theme.text : Theme.textDim
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: KeepAwake.toggle()
                    }
                }
            }

            Item {
                width: 124
                height: notificationText.height

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.pageRequested("notifications")
                }

                Column {
                    id: notificationText
                    width: 124
                    spacing: 1

                    Row {
                        spacing: 6

                        Glyph {
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.notificationCount === 0 ? "󰂛" : "󰂚"
                            color: root.notificationCount === 0 ? Theme.textDim : Theme.accent
                            font.pixelSize: 15
                        }

                        Label {
                            text: root.notificationCount === 0 ? "Quiet" : root.notificationCount + " new"
                            color: root.notificationCount === 0 ? Theme.textDim : Theme.accent
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                        }
                    }

                    Label {
                        width: 124
                        text: root.notificationCount === 0 ? "No notifications" : root.notificationApps
                        color: Theme.textDim
                        elide: Text.ElideRight
                        font.pixelSize: 13
                    }
                }
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
