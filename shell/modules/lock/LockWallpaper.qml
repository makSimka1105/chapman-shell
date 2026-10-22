import QtQuick
import QtQuick.Effects
import qs.services

Item {
    Rectangle {
        anchors.fill: parent
        color: "black"
    }

    Image {
        id: wall
        anchors.fill: parent
        visible: false
        source: Theme.wallpaper === "" ? "" : "file://" + Theme.wallpaper
        fillMode: Image.PreserveAspectCrop
        sourceSize: Qt.size(parent.width, parent.height)
        asynchronous: true
    }

    MultiEffect {
        anchors.fill: parent
        source: wall
        visible: Theme.wallpaper !== ""
        blurEnabled: true
        blur: 1.0
        blurMax: 64
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: Theme.wallpaper === "" ? 0 : 0.25
    }
}
