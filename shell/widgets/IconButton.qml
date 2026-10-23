import QtQuick
import qs.core
import qs.services

Rectangle {
    id: root

    property string glyph
    property string label

    signal clicked

    implicitWidth: content.implicitWidth + 2 * Tokens.marginInner
    implicitHeight: Tokens.iconButtonSize
    radius: Tokens.radiusChip
    color: area.containsMouse ? Qt.alpha(Theme.text, 0.12) : Qt.alpha(Theme.text, 0.05)
    opacity: enabled ? 1 : 0.3
    scale: area.pressed ? 0.94 : 1

    Behavior on color {
        ColorAnimation {
            duration: Tokens.durationHover
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: Tokens.durationNormal
            easing.type: Easing.OutBack
            easing.overshoot: Tokens.overshootSnappy
        }
    }

    Row {
        id: content
        anchors.centerIn: parent
        spacing: Tokens.spacingCompact

        Glyph {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.glyph !== ""
            text: root.glyph
            font.pixelSize: Tokens.fontMedium
        }

        Label {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.label !== ""
            text: root.label
            font.pixelSize: Tokens.fontBody
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }
}
