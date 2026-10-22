import QtQuick
import QtQuick.Effects

Item {
    id: root

    required property Item backdrop
    property rect region
    property real blur: 0.6
    readonly property real downscale: 0.5
    readonly property alias texture: frosted

    visible: false

    ShaderEffectSource {
        id: area
        sourceItem: root.backdrop
        visible: false
        sourceRect: root.region
        textureSize: Qt.size(Math.max(1, Math.round(root.region.width * root.downscale)), Math.max(1, Math.round(root.region.height * root.downscale)))
    }

    MultiEffect {
        id: frost
        source: area
        width: area.textureSize.width
        height: area.textureSize.height
        blurEnabled: true
        blurMax: 64
        blur: root.blur
        autoPaddingEnabled: false
        visible: false
    }

    ShaderEffectSource {
        id: frosted
        sourceItem: frost
        mipmap: true
        visible: false
    }
}
