import QtQuick
import qs.core
import qs.services
import qs.widgets

FocusScope {
    id: root

    property alias text: input.text

    signal escaped
    signal moved(int step)
    signal submitted

    scale: press.pressed ? 0.98 : 1

    Behavior on scale {
        NumberAnimation {
            duration: Tokens.durationFocus
            easing.type: Easing.OutBack
            easing.overshoot: Tokens.overshootSnappy
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Qt.alpha(Theme.text, 0.08)
    }

    MouseArea {
        id: press
        anchors.fill: parent
        onClicked: root.forceActiveFocus()
    }

    Label {
        id: lens
        anchors.left: parent.left
        anchors.leftMargin: Tokens.marginField
        anchors.verticalCenter: parent.verticalCenter
        text: "󰍉"
        color: Theme.textDim
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: Tokens.fontDisplay
    }

    TextInput {
        id: input
        anchors.left: lens.right
        anchors.leftMargin: Tokens.marginRow
        anchors.right: parent.right
        anchors.rightMargin: Tokens.marginField
        anchors.verticalCenter: parent.verticalCenter
        focus: true
        color: Theme.text
        selectionColor: Qt.alpha(Theme.accent, 0.4)
        font.family: Theme.font
        font.pixelSize: Tokens.fontLarge
        renderType: Text.NativeRendering
        clip: true

        Keys.onEscapePressed: root.escaped()
        Keys.onUpPressed: root.moved(-1)
        Keys.onDownPressed: root.moved(1)
        Keys.onTabPressed: root.moved(1)
        Keys.onBacktabPressed: root.moved(-1)
        Keys.onReturnPressed: root.submitted()
        Keys.onEnterPressed: root.submitted()

        Label {
            anchors.verticalCenter: parent.verticalCenter
            visible: input.text === ""
            text: "Spotlight Search"
            color: Theme.textDim
            font.pixelSize: Tokens.fontLarge
        }
    }
}
