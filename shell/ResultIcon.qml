import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.services

Item {
    id: root

    required property var item
    readonly property string fallback: (item.title ?? "?").charAt(0).toUpperCase()

    IconImage {
        id: icon
        anchors.fill: parent
        visible: root.item.icon !== undefined
        source: root.item.icon ? Quickshell.iconPath(root.item.icon, true) : ""
        asynchronous: true
    }

    ClippingRectangle {
        anchors.fill: parent
        visible: root.item.image !== undefined
        radius: width / 4
        color: Theme.faint

        Image {
            anchors.fill: parent
            source: root.item.image ?? ""
            fillMode: Image.PreserveAspectCrop
            sourceSize: Qt.size(width * 2, height * 2)
            asynchronous: true
        }
    }

    Rectangle {
        anchors.fill: parent
        visible: root.item.glyph !== undefined || (root.item.icon !== undefined && icon.status !== Image.Ready)
        radius: width / 4
        color: root.item.glyph !== undefined ? Qt.alpha(Theme.accent, 0.18) : Theme.accent

        Label {
            anchors.centerIn: parent
            text: root.item.glyph ?? root.fallback
            color: root.item.glyph !== undefined ? Theme.accent : "black"
            font.family: root.item.glyph !== undefined ? "JetBrainsMono Nerd Font" : Theme.font
            font.pixelSize: parent.height * 0.5
            font.weight: Font.Bold
        }
    }
}
