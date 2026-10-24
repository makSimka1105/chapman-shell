import QtQuick
import qs.core
import qs.services

Rectangle {
    id: root

    property string placeholder
    property string problem
    property bool revealed

    signal accepted(string text)
    signal cancelled

    height: 44 + (problem === "" ? 0 : warning.height)
    radius: Tokens.radiusRow
    color: Theme.card
    border.color: Qt.alpha(problem === "" ? Theme.accent : Theme.warning, 0.5)
    Component.onCompleted: password.forceActiveFocus()

    Label {
        id: warning
        x: Tokens.marginWide
        y: Tokens.spacingItem
        visible: root.problem !== ""
        text: root.problem
        color: Theme.warning
        font.pixelSize: Tokens.fontSmall
        font.weight: Font.DemiBold
    }

    TextInput {
        id: password
        anchors.left: parent.left
        anchors.right: eye.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: Tokens.marginWide
        anchors.rightMargin: Tokens.marginInner
        height: 44
        verticalAlignment: TextInput.AlignVCenter
        echoMode: root.revealed ? TextInput.Normal : TextInput.Password
        color: Theme.text
        font.family: Theme.font
        font.pixelSize: Tokens.fontLabel
        onAccepted: if (text !== "") root.accepted(text)
        Keys.onEscapePressed: root.cancelled()

        Label {
            anchors.verticalCenter: parent.verticalCenter
            visible: password.text === ""
            text: root.placeholder
            color: Theme.textDim
            font.pixelSize: Tokens.fontLabel
        }
    }

    Glyph {
        id: eye
        anchors.right: parent.right
        anchors.rightMargin: Tokens.marginWide
        anchors.verticalCenter: password.verticalCenter
        text: root.revealed ? "󰈉" : "󰈈"
        color: eyeArea.containsMouse ? Theme.text : Theme.textDim
        font.pixelSize: Tokens.fontMedium

        MouseArea {
            id: eyeArea
            anchors.fill: parent
            anchors.margins: -Tokens.spacingItem
            hoverEnabled: true
            onClicked: root.revealed = !root.revealed
        }
    }
}
