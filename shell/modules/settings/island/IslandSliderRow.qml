import QtQuick
import qs.core
import qs.services
import qs.widgets

Item {
    id: root

    property string title
    property real value
    property real from: 0
    property real to: 1
    property real step: 1
    property string suffix

    signal moved(real value)

    implicitHeight: Tokens.iconButtonSize

    Label {
        anchors.verticalCenter: parent.verticalCenter
        text: root.title
        font.pixelSize: Tokens.fontBody
    }

    Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Tokens.spacingMedium

        Slider {
            width: Tokens.settingsControlWidth
            anchors.verticalCenter: parent.verticalCenter
            value: (root.value - root.from) / (root.to - root.from)
            onMoved: fraction => root.moved(Number((Math.round((root.from + fraction * (root.to - root.from)) / root.step) * root.step).toFixed(3)))
        }

        Label {
            width: Tokens.settingsValueWidth
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignRight
            text: root.value + root.suffix
            font.pixelSize: Tokens.fontBody
            color: Theme.textDim
        }
    }
}
