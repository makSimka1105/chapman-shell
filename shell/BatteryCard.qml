import QtQuick
import Quickshell.Bluetooth
import Quickshell.Services.UPower
import qs.services

Item {
    id: root

    readonly property real level: Status.batteryLevel
    readonly property bool pair: Math.round(Pods.left * 100) === Math.round(Pods.right * 100) && Pods.leftCharging === Pods.rightCharging
    readonly property var devices: (Bluetooth.defaultAdapter?.devices.values ?? []).filter(device => device.connected && device.batteryAvailable && !device.name.toLowerCase().includes("airpods"))
    readonly property var profiles: [
        { profile: PowerProfile.PowerSaver, glyph: "󰌪", title: "Power Saver" },
        { profile: PowerProfile.Balanced, glyph: "󰾅", title: "Balanced" },
        { profile: PowerProfile.Performance, glyph: "󱐋", title: "Performance" }
    ].filter(entry => entry.profile !== PowerProfile.Performance || PowerProfiles.hasPerformanceProfile)
    readonly property var current: profiles.find(entry => entry.profile === PowerProfiles.profile) ?? profiles[0]

    function duration(seconds) {
        const minutes = Math.round(seconds / 60);
        return Math.floor(minutes / 60) + "h " + minutes % 60 + "m";
    }

    function caption() {
        const battery = Status.battery;
        if (Status.charging)
            return battery?.timeToFull > 0 ? duration(battery.timeToFull) + " to full" : "Charging";
        if (battery?.state === UPowerDeviceState.FullyCharged)
            return "Fully charged";
        return battery?.timeToEmpty > 0 ? duration(battery.timeToEmpty) : "On battery";
    }

    function tone(value, charging) {
        return charging ? Theme.charge : value < 0.2 ? Theme.warning : Theme.accent;
    }

    function percent(value, charging) {
        return Math.round(value * 100) + "%" + (charging ? " 󱐋" : "");
    }

    width: row.width
    height: row.height

    Row {
        id: row
        spacing: 22

        Column {
            id: laptop
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Ring {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 66
                height: 66
                thickness: 7
                value: root.level
                text: String(Math.round(root.level * 100))
                fontSize: 20
                pulsing: Status.charging
                fillColor: Status.charging ? Theme.charge : root.level < 0.2 ? Theme.warning : Theme.accent
            }

            Row {
                id: caption
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 6

                Glyph {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.current.glyph
                    color: PowerProfiles.profile === PowerProfile.Performance ? Theme.warning : Theme.accent
                    font.pixelSize: 16
                }

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.caption()
                    color: Theme.textDim
                    font.pixelSize: 13
                }

                HoverHandler {
                    id: captionHover
                }
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 14
            visible: Pods.available || root.devices.length > 0

            Row {
                visible: Pods.available && root.pair
                spacing: 8

                FillIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    source: Qt.resolvedUrl("icons/pods.svg")
                    level: Pods.left
                    tone: root.tone(Pods.left, Pods.leftCharging)
                    size: 30
                }

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.percent(Pods.left, Pods.leftCharging)
                    color: Pods.leftCharging ? Theme.charge : Theme.text
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                }
            }

            Row {
                visible: Pods.available && !root.pair
                spacing: 8

                FillIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    source: Qt.resolvedUrl("icons/pods.svg")
                    part: "left"
                    level: Pods.left
                    tone: root.tone(Pods.left, Pods.leftCharging)
                    size: 30
                }

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.percent(Pods.left, Pods.leftCharging)
                    color: Pods.leftCharging ? Theme.charge : Theme.text
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                }

                FillIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    source: Qt.resolvedUrl("icons/pods.svg")
                    part: "right"
                    level: Pods.right
                    tone: root.tone(Pods.right, Pods.rightCharging)
                    size: 30
                }

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.percent(Pods.right, Pods.rightCharging)
                    color: Pods.rightCharging ? Theme.charge : Theme.text
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                }
            }

            Row {
                visible: Pods.available && Pods.box > 0
                spacing: 8

                FillIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    source: Qt.resolvedUrl("icons/case.svg")
                    level: Pods.box
                    tone: root.tone(Pods.box)
                    size: 30
                }

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Math.round(Pods.box * 100) + "%"
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                }
            }

            Repeater {
                model: root.devices

                Row {
                    required property var modelData

                    spacing: 8

                    Glyph {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰂯"
                        color: parent.modelData.battery < 0.2 ? Theme.warning : Theme.accent
                        font.pixelSize: 18
                    }

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 70
                        text: parent.modelData.name
                        elide: Text.ElideRight
                        font.pixelSize: 13
                    }

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Math.round(parent.modelData.battery * 100) + "%"
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                    }
                }
            }
        }
    }

    HoverPicker {
        x: 0
        y: laptop.y + laptop.height + 4 - height
        rowHeight: 26
        pickerWidth: 170
        hoverable: true
        held: captionHover.hovered
        transformOrigin: Item.TopLeft
        entries: root.profiles.map(entry => ({
                    glyph: entry.glyph,
                    title: entry.title,
                    active: PowerProfiles.profile === entry.profile
                }))
        onPicked: index => PowerProfiles.profile = root.profiles[index].profile
    }
}
