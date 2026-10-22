import QtQuick

Item {
    id: root

    required property GlassContext context
    property real radius: 26
    property real tint: 0.3
    property real thickness: 24
    property real dispersion: 0.06
    property real saturation: 1.3
    property real rim: 0.6
    property real shadow: 0.5
    readonly property real pad: 24
    readonly property point origin: windowPosition()

    function windowPosition() {
        let x = 0;
        let y = 0;
        for (let item = root; item; item = item.parent) {
            x += item.x;
            y += item.y;
        }
        return Qt.point(x, y);
    }

    ShaderEffect {
        x: -root.pad
        y: -root.pad
        width: root.width + 2 * root.pad
        height: root.height + 2 * root.pad
        fragmentShader: Qt.resolvedUrl("shaders/glass.frag.qsb")

        property variant backdrop: root.context.texture
        property vector2d itemSize: Qt.vector2d(width, height)
        property vector2d glassSize: Qt.vector2d(root.width, root.height)
        property vector2d backdropSize: Qt.vector2d(root.context.region.width, root.context.region.height)
        property vector2d backdropOffset: Qt.vector2d(root.origin.x - root.pad - root.context.region.x, root.origin.y - root.pad - root.context.region.y)
        property real pad: root.pad
        property real radius: root.radius
        property real bezel: Math.max(1, Math.min(root.height * 0.36, 26))
        property real thickness: root.thickness
        property real dispersion: root.dispersion
        property real softness: 1.5
        property real tint: root.tint
        property real saturation: root.saturation
        property real rim: root.rim
        property real grain: 0.006
        property real shadow: root.shadow
    }
}
