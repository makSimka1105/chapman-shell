import QtQuick
import Quickshell.Networking
import qs.core
import qs.services
import qs.widgets

Column {
    id: root

    required property var network
    readonly property bool secured: Wifi.secured(network)

    spacing: Tokens.spacingItem
    bottomPadding: Wifi.asking === network ? Tokens.marginRow : 0

    Item {
        width: root.width
        height: Tokens.settingsRowHeight

        Rectangle {
            anchors.fill: parent
            radius: Tokens.radiusCard
            color: area.containsMouse ? Qt.alpha(Theme.text, 0.05) : "transparent"
        }

        MouseArea {
            id: area
            anchors.fill: parent
            hoverEnabled: true
            onClicked: Wifi.choose(root.network)
        }

        Glyph {
            id: icon
            anchors.left: parent.left
            anchors.leftMargin: Tokens.marginRow
            anchors.verticalCenter: parent.verticalCenter
            text: Wifi.bar(root.network)
            color: root.network.connected ? Theme.accent : Theme.text
        }

        Column {
            anchors.left: icon.right
            anchors.leftMargin: Tokens.marginMedium
            anchors.right: actions.left
            anchors.rightMargin: Tokens.marginInner
            anchors.verticalCenter: parent.verticalCenter
            spacing: Tokens.spacingHairline

            Label {
                width: parent.width
                text: root.network.name
                elide: Text.ElideRight
                font.pixelSize: Tokens.fontMedium
            }

            Label {
                width: parent.width
                text: Wifi.revealed === root.network ? "Пароль: " + Wifi.revealedPsk : [root.network.stateChanging ? "Подключение…" : root.network.connected ? "Подключено" : root.network.known ? "Сохранена" : "", WifiSecurityType.toString(root.network.security), Math.round(root.network.signalStrength * 100) + "%"].filter(part => part).join("  ·  ")
                elide: Text.ElideRight
                font.pixelSize: Tokens.fontCaption
                color: Theme.textDim
            }
        }

        Row {
            id: actions
            anchors.right: parent.right
            anchors.rightMargin: Tokens.marginRow
            anchors.verticalCenter: parent.verticalCenter
            spacing: Tokens.spacingCompact

            IconButton {
                visible: root.network.known && root.secured
                glyph: Wifi.revealed === root.network ? "󰈉" : "󰈈"
                onClicked: Wifi.reveal(root.network)
            }

            IconButton {
                visible: root.secured
                glyph: "󰌾"
                label: root.network.known ? "Пароль" : "Ввести пароль"
                onClicked: Wifi.ask(root.network)
            }

            IconButton {
                visible: root.network.known
                glyph: "󰆴"
                label: "Забыть"
                onClicked: Wifi.forget(root.network)
            }
        }
    }

    Loader {
        x: Tokens.marginRow
        width: root.width - 2 * Tokens.marginRow
        active: Wifi.asking === root.network
        visible: active

        sourceComponent: PasswordField {
            placeholder: root.network.known ? "Новый пароль" : "Пароль"
            problem: Wifi.problem
            onAccepted: text => Wifi.submit(text)
            onCancelled: Wifi.cancel()
        }
    }
}
