import QtQuick
import Quickshell
import Quickshell.Services.Polkit
import Quickshell.Wayland
import qs.core
import qs.services
import qs.widgets

PanelWindow {
    id: root

    readonly property var flow: agent.flow
    readonly property bool opened: agent.isActive && flow !== null
    readonly property real cardWidth: 420
    readonly property real padding: 22

    function cancel() {
        if (flow)
            flow.cancelAuthenticationRequest();
    }

    PolkitAgent {
        id: agent
    }

    screen: Quickshell.screens.find(s => s.name === Niri.focusedOutput) ?? Quickshell.screens[0]
    visible: opened || content.opacity > 0
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "polkit"
    WlrLayershell.keyboardFocus: opened ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    Rectangle {
        anchors.fill: parent
        color: Qt.alpha("black", 0.45)
        opacity: content.openT
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.opened
        onClicked: root.cancel()
    }

    Item {
        id: content

        property real openT: root.opened ? 1 : 0

        anchors.centerIn: parent
        width: root.cardWidth
        height: column.implicitHeight + root.padding * 2
        opacity: Math.min(1, openT * 2.2)
        scale: 0.9 + 0.1 * openT

        Behavior on openT {
            NumberAnimation {
                duration: root.opened ? Tokens.durationReveal : Tokens.durationQuick
                easing.type: root.opened ? Easing.OutBack : Easing.OutCubic
                easing.overshoot: Tokens.overshootStrong
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: 28
            color: Theme.body
            border.width: 1
            border.color: Theme.faint
        }

        MouseArea {
            anchors.fill: parent
        }

        Column {
            id: column
            x: root.padding
            y: root.padding
            width: parent.width - root.padding * 2
            spacing: Tokens.spacingItem * 2

            Row {
                spacing: Tokens.spacingItem * 2

                Glyph {
                    text: "󰒃"
                    color: Theme.accent
                    font.pixelSize: 28
                }

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Authentication required"
                    font.pixelSize: Tokens.fontMedium
                    font.weight: Font.DemiBold
                }
            }

            Label {
                width: parent.width
                text: root.flow?.message ?? ""
                color: Theme.textDim
                wrapMode: Text.WordWrap
                font.pixelSize: Tokens.fontBody
            }

            Loader {
                width: parent.width
                active: root.opened && (root.flow?.isResponseRequired ?? false)

                sourceComponent: PasswordField {
                    placeholder: root.flow.inputPrompt || "Password"
                    problem: root.flow.supplementaryIsError ? root.flow.supplementaryMessage : ""
                    revealed: root.flow.responseVisible
                    onAccepted: text => root.flow.submit(text)
                    onCancelled: root.cancel()
                }
            }
        }
    }
}
