import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services

PanelWindow {
    id: root

    property bool opened
    property int selected: 0
    property int armed: -1
    readonly property var actions: [
        { glyph: "󰌾", title: "Lock", command: ["qs", "-p", Quickshell.shellDir, "ipc", "call", "lock", "lock"] },
        { glyph: "󰤄", title: "Sleep", command: ["systemctl", "suspend"] },
        { glyph: "󰍃", title: "Log Out", command: ["niri", "msg", "action", "quit", "--skip-confirmation"], confirm: true },
        { glyph: "󰜉", title: "Restart", command: ["systemctl", "reboot"], confirm: true },
        { glyph: "󰐥", title: "Shut Down", command: ["systemctl", "poweroff"], confirm: true }
    ]
    readonly property real buttonWidth: 112
    readonly property real buttonHeight: 96
    readonly property real padding: 18
    readonly property real gap: 10

    function toggle() {
        if (opened)
            close();
        else
            open();
    }

    function open() {
        selected = 0;
        armed = -1;
        opened = true;
        keys.forceActiveFocus();
    }

    function close() {
        opened = false;
        armed = -1;
    }

    function move(step) {
        selected = (selected + step + actions.length) % actions.length;
    }

    function activate(index) {
        const action = actions[index];
        if (action.confirm && armed !== index) {
            armed = index;
            return;
        }
        Spawn.run(action.command);
        close();
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
    WlrLayershell.namespace: "powermenu"
    WlrLayershell.keyboardFocus: opened ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    onSelectedChanged: armed = -1

    Rectangle {
        anchors.fill: parent
        color: Qt.alpha("black", 0.45)
        opacity: content.openT
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.opened
        onClicked: root.close()
    }

    Item {
        id: content

        property real openT: root.opened ? 1 : 0

        anchors.centerIn: parent
        width: root.actions.length * root.buttonWidth + (root.actions.length - 1) * root.gap + root.padding * 2
        height: root.buttonHeight + root.padding * 2
        opacity: Math.min(1, openT * 2.2)
        scale: 0.9 + 0.1 * openT

        Behavior on openT {
            NumberAnimation {
                duration: root.opened ? 520 : 150
                easing.type: root.opened ? Easing.OutBack : Easing.OutCubic
                easing.overshoot: 1.5
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

        Item {
            id: keys
            anchors.fill: parent
            focus: true

            Keys.onEscapePressed: root.close()
            Keys.onLeftPressed: root.move(-1)
            Keys.onRightPressed: root.move(1)
            Keys.onReturnPressed: root.activate(root.selected)
            Keys.onEnterPressed: root.activate(root.selected)
            Keys.onPressed: event => {
                const digit = event.key - Qt.Key_1;
                if (digit >= 0 && digit < root.actions.length) {
                    root.selected = digit;
                    root.activate(digit);
                }
            }
        }

        Row {
            anchors.centerIn: parent
            spacing: root.gap

            Repeater {
                model: root.actions

                Rectangle {
                    id: button

                    required property var modelData
                    required property int index
                    readonly property bool isArmed: root.armed === index
                    readonly property bool isSelected: root.selected === index

                    width: root.buttonWidth
                    height: root.buttonHeight
                    radius: 20
                    color: isArmed ? Theme.warning : isSelected ? Qt.alpha(Theme.text, 0.14) : buttonArea.containsMouse ? Qt.alpha(Theme.text, 0.1) : Theme.card
                    scale: buttonArea.pressed ? 0.94 : 1

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 220
                            easing.type: Easing.OutBack
                            easing.overshoot: 3
                        }
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 8

                        Glyph {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: button.modelData.glyph
                            color: button.isArmed ? Theme.body : Theme.text
                            font.pixelSize: 28
                        }

                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: button.isArmed ? "Confirm" : button.modelData.title
                            color: button.isArmed ? Theme.body : Theme.text
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                        }
                    }

                    MouseArea {
                        id: buttonArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: root.selected = button.index
                        onClicked: root.activate(button.index)
                    }
                }
            }
        }
    }
}
