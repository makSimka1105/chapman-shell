import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services

PanelWindow {
    id: root

    property string shown: Theme.wallpaper
    readonly property int fadeDuration: 600

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    color: "black"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "notch-wallpaper"

    Image {
        id: back
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        sourceSize: Qt.size(root.width, root.height)
        asynchronous: true
    }

    Image {
        id: front
        anchors.fill: parent
        source: root.shown ? "file://" + root.shown : ""
        fillMode: Image.PreserveAspectCrop
        sourceSize: Qt.size(root.width, root.height)
        asynchronous: true
        onStatusChanged: if (status === Image.Ready) fade.restart()
    }

    NumberAnimation {
        id: fade
        target: front
        property: "opacity"
        from: 0
        to: 1
        duration: root.fadeDuration
        easing.type: Easing.InOutQuad
        onFinished: back.source = front.source
    }
}
