import QtQuick
import Quickshell.Widgets
import qs.core
import qs.services
import qs.widgets

Item {
    id: root

    required property string source
    property bool selected
    property bool current

    property bool removable

    signal clicked
    signal removed

    ClippingRectangle {
        anchors.fill: parent
        radius: Tokens.radiusRow
        color: Theme.card

        Image {
            anchors.fill: parent
            source: "file://" + root.source
            sourceSize: Qt.size(width, height)
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: Tokens.radiusRow
        color: "transparent"
        border.width: root.selected || root.current ? 2 : 0
        border.color: root.selected ? Theme.text : Theme.accent
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }

    Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: Tokens.spacingItem
        width: 22
        height: 22
        radius: 11
        visible: root.removable && hover.hovered
        color: removeArea.containsMouse ? Theme.warning : Qt.alpha("black", 0.6)

        Glyph {
            anchors.centerIn: parent
            text: "󰅖"
            color: "white"
            font.pixelSize: Tokens.fontSmall
        }

        MouseArea {
            id: removeArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.removed()
        }
    }

    HoverHandler {
        id: hover
    }
}
