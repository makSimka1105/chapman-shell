import QtQuick
import QtQuick.Effects
import Quickshell.Bluetooth
import Quickshell.Services.UPower
import qs.core
import qs.services
import qs.widgets

Item {
    id: root

    readonly property int slotCount: 4
    readonly property real ringSize: 42
    readonly property var devices: (Bluetooth.defaultAdapter?.devices.values ?? []).filter(device => device.connected && device.batteryAvailable && !device.name.toLowerCase().includes("airpods"))
    readonly property var laptopSlot: ({ icon: "laptop", level: Status.batteryLevel, charging: Status.charging })
    readonly property var podSlots: !Pods.available ? [] : [
        { icon: "pod-left", level: Pods.left, charging: Pods.leftCharging },
        { icon: "pod-right", level: Pods.right, charging: Pods.rightCharging },
        { icon: "pods-case", level: Pods.box, charging: false, empty: Pods.box <= 0 }
    ]
    readonly property var deviceSlots: devices.map(device => ({ icon: "headphones", level: device.battery, charging: false }))
    readonly property var slots: {
        const filled = [laptopSlot, ...podSlots, ...deviceSlots].slice(0, slotCount);
        while (filled.length < slotCount)
            filled.push({ icon: "", level: 0, charging: false, empty: true });
        return filled;
    }
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

    function tone(level, charging) {
        return charging ? Theme.charge : level < 0.2 ? Theme.warning : Theme.accent;
    }

    width: column.width
    height: column.height

    component BatterySlot: Item {
        id: slot

        required property var modelData

        width: root.ringSize
        height: root.ringSize
        z: hover.hovered ? 1 : 0

        HoverHandler {
            id: hover
        }

        Ring {
            anchors.fill: parent
            thickness: 4
            value: slot.modelData.empty ? 0 : slot.modelData.level
            text: ""
            fillColor: root.tone(slot.modelData.level, slot.modelData.charging)

            Image {
                anchors.centerIn: parent
                visible: slot.modelData.icon !== ""
                width: 19
                height: 19
                source: visible ? Qt.resolvedUrl("../../icons/" + slot.modelData.icon + ".svg") : ""
                sourceSize.width: 64
                sourceSize.height: 64
                layer.enabled: true
                layer.effect: MultiEffect {
                    colorization: 1
                    colorizationColor: slot.modelData.empty ? Theme.faint : Theme.text
                }
            }

            Glyph {
                visible: slot.modelData.charging
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.top
                text: "󱐋"
                color: Theme.charge
                font.pixelSize: Tokens.fontCaption
            }
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.top
            anchors.bottomMargin: Tokens.spacingSmall
            width: percent.implicitWidth + 16
            height: percent.implicitHeight + 8
            radius: height / 2
            color: Qt.rgba(0.08, 0.08, 0.09, 0.96)
            border.color: Theme.faint
            opacity: hover.hovered && !slot.modelData.empty ? 1 : 0
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation {
                    duration: Tokens.durationFast
                }
            }

            Label {
                id: percent
                anchors.centerIn: parent
                text: Math.round(slot.modelData.level * 100) + "%"
                color: slot.modelData.charging ? Theme.charge : Theme.text
                font.pixelSize: Tokens.fontSmall
                font.weight: Font.DemiBold
            }
        }
    }

    Column {
        id: column
        spacing: Tokens.spacingItem

        Grid {
            anchors.horizontalCenter: parent.horizontalCenter
            columns: 2
            spacing: 12

            Repeater {
                model: root.slots

                BatterySlot {}
            }
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

    HoverPicker {
        x: caption.x
        y: caption.y + caption.height + 4 - height
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
