import QtQuick
import Quickshell.Bluetooth
import Quickshell.Services.UPower
import qs.core
import qs.services
import qs.widgets

Item {
    id: root

    readonly property real podSize: 30
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
            spacing: Tokens.spacingItem

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
                spacing: Tokens.spacingSmall

                Glyph {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.current.glyph
                    color: PowerProfiles.profile === PowerProfile.Performance ? Theme.warning : Theme.accent
                    font.pixelSize: Tokens.fontSubtitle
                }

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.caption()
                    color: Theme.textDim
                    font.pixelSize: Tokens.fontBody
                }

                HoverHandler {
                    id: captionHover
                }
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: Tokens.spacingLarge
            visible: Pods.available || root.devices.length > 0

            Row {
                visible: Pods.available && root.pair
                spacing: Tokens.spacingItem

                FillIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    source: Qt.resolvedUrl("../../icons/pods.svg")
                    level: Pods.left
                    tone: root.tone(Pods.left, Pods.leftCharging)
                    size: root.podSize
                }

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.percent(Pods.left, Pods.leftCharging)
                    color: Pods.leftCharging ? Theme.charge : Theme.text
                    font.pixelSize: Tokens.fontSubtitle
                    font.weight: Font.DemiBold
                }
            }

            Row {
                visible: Pods.available && !root.pair
                spacing: Tokens.spacingItem

                FillIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    source: Qt.resolvedUrl("../../icons/pods.svg")
                    part: "left"
                    level: Pods.left
                    tone: root.tone(Pods.left, Pods.leftCharging)
                    size: root.podSize
                }

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.percent(Pods.left, Pods.leftCharging)
                    color: Pods.leftCharging ? Theme.charge : Theme.text
                    font.pixelSize: Tokens.fontMedium
                    font.weight: Font.DemiBold
                }

                FillIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    source: Qt.resolvedUrl("../../icons/pods.svg")
                    part: "right"
                    level: Pods.right
                    tone: root.tone(Pods.right, Pods.rightCharging)
                    size: root.podSize
                }

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.percent(Pods.right, Pods.rightCharging)
                    color: Pods.rightCharging ? Theme.charge : Theme.text
                    font.pixelSize: Tokens.fontMedium
                    font.weight: Font.DemiBold
                }
            }

            Row {
                visible: Pods.available && Pods.box > 0
                spacing: Tokens.spacingItem

                FillIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    source: Qt.resolvedUrl("../../icons/case.svg")
                    level: Pods.box
                    tone: root.tone(Pods.box)
                    size: root.podSize
                }

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Math.round(Pods.box * 100) + "%"
                    font.pixelSize: Tokens.fontMedium
                    font.weight: Font.DemiBold
                }
            }

            Repeater {
                model: root.devices

                Row {
                    required property var modelData

                    spacing: Tokens.spacingItem

                    Glyph {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰂯"
                        color: parent.modelData.battery < 0.2 ? Theme.warning : Theme.accent
                        font.pixelSize: Tokens.fontIcon
                    }

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 70
                        text: parent.modelData.name
                        elide: Text.ElideRight
                        font.pixelSize: Tokens.fontBody
                    }

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Math.round(parent.modelData.battery * 100) + "%"
                        font.pixelSize: Tokens.fontMedium
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
