import QtQuick
import Quickshell.Widgets
import qs.core
import qs.services

Item {
    id: root

    required property string source
    property bool selected
    property bool current

    signal clicked

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
}
