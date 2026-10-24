import QtQuick
import qs.core
import qs.services

Rectangle {
    id: root

    property string glyph
    property string title
    property string subtitle
    property string trailing
    property bool active
    property bool busy

    signal clicked
    signal secondaryClicked

    height: 48
    radius: Tokens.radiusRow
    color: root.active ? Qt.alpha(Theme.accent, 0.18) : area.containsMouse ? Qt.alpha(Theme.text, 0.08) : "transparent"
    scale: area.pressed ? 0.98 : 1

    Behavior on color {
        ColorAnimation {
            duration: Tokens.durationHover
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: Tokens.durationNormal
            easing.type: Easing.OutBack
            easing.overshoot: Tokens.overshootSnappy
        }
    }

    Glyph {
        id: icon
        anchors.left: parent.left
        anchors.leftMargin: Tokens.marginRow
        anchors.verticalCenter: parent.verticalCenter
        width: 22
        text: root.glyph
        color: root.active ? Theme.accent : Theme.text
    }

    Column {
        anchors.left: icon.right
        anchors.leftMargin: Tokens.marginMedium
        anchors.right: tail.left
        anchors.rightMargin: Tokens.marginInner
        anchors.verticalCenter: parent.verticalCenter

        Label {
            width: parent.width
            text: root.title
            elide: Text.ElideRight
            font.pixelSize: Tokens.fontLabel
            font.weight: Font.DemiBold
        }

        Label {
            width: parent.width
            visible: text !== ""
            text: root.subtitle
            color: Theme.textDim
            elide: Text.ElideRight
            font.pixelSize: Tokens.fontSmall
            font.weight: Font.Medium
        }
    }

    Label {
        id: tail
        anchors.right: parent.right
        anchors.rightMargin: Tokens.marginRow
        anchors.verticalCenter: parent.verticalCenter
        text: root.busy ? "…" : root.trailing
        color: Theme.textDim
        font.pixelSize: Tokens.fontBody
        font.weight: Font.DemiBold
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => mouse.button === Qt.RightButton ? root.secondaryClicked() : root.clicked()
    }
}
