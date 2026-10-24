import QtQuick
import Quickshell
import Quickshell.Networking
import qs.core
import qs.services
import qs.widgets
import qs.modules.settings

Column {
    id: root

    readonly property var current: Wifi.current
    readonly property var power: ({
            rows: [
                {
                    type: "toggle",
                    title: "Wi-Fi",
                    subtitle: Networking.wifiHardwareEnabled ? "" : "Выключен кнопкой или в BIOS",
                    read: () => Networking.wifiEnabled,
                    write: on => Networking.wifiEnabled = on
                }
            ]
        })

    spacing: Tokens.marginPanel
    Component.onCompleted: Wifi.scan(true)
    Component.onDestruction: {
        Wifi.cancel();
        Wifi.revealed = null;
        Wifi.scan(false);
    }

    SettingsGroup {
        width: root.width
        group: root.power
    }

    Rectangle {
        width: root.width
        height: Tokens.settingsRowHeight
        radius: Tokens.radiusCard
        color: Theme.card
        visible: root.current !== null

        Glyph {
            id: currentIcon
            anchors.left: parent.left
            anchors.leftMargin: Tokens.marginRow
            anchors.verticalCenter: parent.verticalCenter
            text: root.current ? Wifi.bar(root.current) : ""
            color: Theme.accent
        }

        Column {
            anchors.left: currentIcon.right
            anchors.leftMargin: Tokens.marginMedium
            anchors.right: currentActions.left
            anchors.rightMargin: Tokens.marginInner
            anchors.verticalCenter: parent.verticalCenter
            spacing: Tokens.spacingHairline

            Label {
                width: parent.width
                text: root.current?.name ?? ""
                elide: Text.ElideRight
                font.pixelSize: Tokens.fontMedium
            }

            Label {
                width: parent.width
                text: root.current && Wifi.revealed === root.current ? "Пароль: " + Wifi.revealedPsk : root.current ? [WifiSecurityType.toString(root.current.security), Math.round(root.current.signalStrength * 100) + "%", (Wifi.addresses["IP4.ADDRESS"] ?? "").split("/")[0]].filter(part => part).join("  ·  ") : ""
                elide: Text.ElideRight
                font.pixelSize: Tokens.fontCaption
                color: Theme.textDim
            }
        }

        Row {
            id: currentActions
            anchors.right: parent.right
            anchors.rightMargin: Tokens.marginRow
            anchors.verticalCenter: parent.verticalCenter
            spacing: Tokens.spacingCompact

            IconButton {
                glyph: Wifi.revealed === root.current ? "󰈉" : "󰈈"
                onClicked: Wifi.reveal(root.current)
            }

            IconButton {
                glyph: "󰖪"
                label: "Отключиться"
                onClicked: root.current.disconnect()
            }

            IconButton {
                glyph: "󰆴"
                label: "Забыть"
                onClicked: Wifi.forget(root.current)
            }
        }
    }

    Column {
        width: root.width
        visible: Networking.wifiEnabled
        spacing: Tokens.spacingItem

        Label {
            x: Tokens.marginRow
            text: Wifi.networks.length === 0 ? "Поиск сетей…" : "Сети рядом"
            font.pixelSize: Tokens.fontSmall
            font.weight: Font.DemiBold
            color: Theme.textDim
        }

        Rectangle {
            width: parent.width
            height: list.height
            radius: Tokens.radiusCard
            color: Theme.card
            visible: Wifi.networks.length > 0

            Column {
                id: list
                width: parent.width

                Repeater {
                    model: ScriptModel {
                        values: Wifi.networks.filter(network => !network.connected)
                    }

                    WifiNetworkRow {
                        required property var modelData

                        width: list.width
                        network: modelData
                    }
                }
            }
        }
    }
}
