import QtQuick
import QtQuick.Effects
import qs.services

Item {
    id: root

    property url source
    property real level: 1
    property color tone: Theme.accent
    property real size: 28
    property string part: "full"
    readonly property real shown: Math.max(0, Math.min(1, level))
    readonly property real offset: part === "right" ? -size / 2 : 0

    width: part === "full" ? size : size / 2
    height: size

    component Layer: Image {
        required property color tint

        x: root.offset
        width: root.size
        height: root.size
        source: root.source
        sourceSize.width: 128
        sourceSize.height: 128
        layer.enabled: true
        layer.effect: MultiEffect {
            colorization: 1
            colorizationColor: tint
        }
    }

    Item {
        anchors.fill: parent
        clip: true

        Layer {
            tint: Theme.faint
        }
    }

    Item {
        y: root.size * (1 - root.shown)
        width: parent.width
        height: root.size * root.shown
        clip: true

        Layer {
            y: -root.size * (1 - root.shown)
            tint: root.tone
        }
    }
}
