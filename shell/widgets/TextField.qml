import QtQuick
import qs.core
import qs.services

Rectangle {
    id: root

    property string placeholder
    property alias text: input.text

    signal accepted(string text)

    implicitHeight: 44
    radius: Tokens.radiusRow
    color: Theme.card
    border.color: Qt.alpha(Theme.accent, input.activeFocus ? 0.5 : 0.2)

    TextInput {
        id: input
        anchors.fill: parent
        anchors.leftMargin: Tokens.marginWide
        anchors.rightMargin: Tokens.marginWide
        verticalAlignment: TextInput.AlignVCenter
        clip: true
        color: Theme.text
        font.family: Theme.font
        font.pixelSize: Tokens.fontLabel
        onAccepted: if (text !== "") root.accepted(text)

        Label {
            anchors.verticalCenter: parent.verticalCenter
            visible: input.text === ""
            text: root.placeholder
            color: Theme.textDim
            font.pixelSize: Tokens.fontLabel
        }
    }
}
