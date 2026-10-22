import QtQuick

ShaderEffect {
    id: root

    property real radius: 26
    property bool lit
    property point at: Qt.point(width / 2, height / 2)
    property color color: "white"

    property vector2d itemSize: Qt.vector2d(width, height)
    property vector2d cursor: Qt.vector2d(at.x, at.y)
    property real strength: lit ? 1 : 0
    property real reach: Math.max(40, Math.min(width, height) * 0.9)
    property vector4d tint: Qt.vector4d(color.r, color.g, color.b, 1)

    visible: strength > 0.005
    fragmentShader: Qt.resolvedUrl("../shaders/contour.frag.qsb")

    Behavior on strength {
        NumberAnimation {
            duration: 320
            easing.type: Easing.OutCubic
        }
    }
}
