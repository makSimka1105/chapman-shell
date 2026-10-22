import QtQuick

Item {
    id: root

    required property GlassContext context
    required property real cornerRadius
    required property real thickness
    required property real shadow

    Glass {
        anchors.fill: parent
        context: root.context
        radius: root.cornerRadius
        thickness: root.thickness
        shadow: root.shadow
    }

    Contour {
        anchors.fill: parent
        radius: root.cornerRadius
        lit: hover.hovered
        at: hover.point.position
    }

    HoverHandler {
        id: hover
    }
}
