import QtQuick
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

    height: 48
    radius: 14
    color: root.active ? Qt.alpha(Theme.accent, 0.18) : area.containsMouse ? Qt.alpha(Theme.text, 0.08) : "transparent"
    scale: area.pressed ? 0.98 : 1

    Behavior on color {
        ColorAnimation {
            duration: 120
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutBack
            easing.overshoot: 3
        }
    }

    Glyph {
        id: icon
        anchors.left: parent.left
        anchors.leftMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        width: 22
        text: root.glyph
        color: root.active ? Theme.accent : Theme.text
    }

    Column {
        anchors.left: icon.right
        anchors.leftMargin: 12
        anchors.right: tail.left
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter

        Label {
            width: parent.width
            text: root.title
            elide: Text.ElideRight
            font.pixelSize: 15
            font.weight: Font.DemiBold
        }

        Label {
            width: parent.width
            visible: text !== ""
            text: root.subtitle
            color: Theme.textDim
            elide: Text.ElideRight
            font.pixelSize: 12
            font.weight: Font.Medium
        }
    }

    Label {
        id: tail
        anchors.right: parent.right
        anchors.rightMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        text: root.busy ? "…" : root.trailing
        color: Theme.textDim
        font.pixelSize: 13
        font.weight: Font.DemiBold
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }
}
