import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import qs.core
import qs.services

Item {
    id: root

    required property real radius
    required property real flare
    required property real squash
    required property real targetSwell
    property real swell: targetSwell

    Behavior on swell {
        NumberAnimation {
            duration: Tokens.durationNormal
            easing.type: Easing.OutBack
            easing.overshoot: Tokens.overshootMild
        }
    }

    transform: Scale {
        origin.x: root.width / 2
        origin.y: 0
        xScale: root.swell * root.squash
        yScale: root.swell
    }

    RectangularShadow {
        anchors.fill: body
        radius: root.radius
        blur: 28
        spread: 2
        offset.y: 6
        color: Qt.alpha("black", 0.45)
    }

    Rectangle {
        id: body
        anchors.fill: parent
        color: Theme.body
        topLeftRadius: 0
        topRightRadius: 0
        bottomLeftRadius: root.radius
        bottomRightRadius: root.radius
    }

    Shape {
        x: -root.flare
        width: root.flare
        height: root.flare
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: Theme.body
            strokeColor: "transparent"
            startX: 0
            startY: 0
            PathLine { x: root.flare; y: 0 }
            PathLine { x: root.flare; y: root.flare }
            PathArc {
                x: 0
                y: 0
                radiusX: root.flare
                radiusY: root.flare
                direction: PathArc.Counterclockwise
            }
        }
    }

    Shape {
        x: root.width
        width: root.flare
        height: root.flare
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: Theme.body
            strokeColor: "transparent"
            startX: 0
            startY: 0
            PathLine { x: root.flare; y: 0 }
            PathArc {
                x: 0
                y: root.flare
                radiusX: root.flare
                radiusY: root.flare
                direction: PathArc.Counterclockwise
            }
        }
    }
}
