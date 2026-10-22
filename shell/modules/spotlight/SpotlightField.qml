import QtQuick
import qs.services
import qs.widgets

FocusScope {
    id: root

    required property GlassContext glass
    property alias text: input.text

    signal escaped
    signal moved(int step)
    signal submitted

    scale: press.pressed ? 0.98 : 1

    Behavior on scale {
        NumberAnimation {
            duration: 230
            easing.type: Easing.OutBack
            easing.overshoot: 3
        }
    }

    GlassSurface {
        anchors.fill: parent
        context: root.glass
        cornerRadius: height / 2
        thickness: 18
        shadow: 0.35
    }

    MouseArea {
        id: press
        anchors.fill: parent
        onClicked: root.forceActiveFocus()
    }

    Label {
        id: lens
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.verticalCenter: parent.verticalCenter
        text: "󰍉"
        color: Theme.textDim
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 24
    }

    TextInput {
        id: input
        anchors.left: lens.right
        anchors.leftMargin: 14
        anchors.right: parent.right
        anchors.rightMargin: 24
        anchors.verticalCenter: parent.verticalCenter
        focus: true
        color: Theme.text
        selectionColor: Qt.alpha(Theme.accent, 0.4)
        font.family: Theme.font
        font.pixelSize: 22
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
            font.pixelSize: 22
        }
    }
}
