import QtQuick
import qs.core
import qs.services
import qs.widgets

Item {
    id: root

    required property var theme
    property bool selected
    readonly property bool current: theme.id === Theme.name
    readonly property var swatches: ["primary", "secondary", "tertiary", "error", "on_surface", "surface"]

    property bool removable

    signal clicked
    signal removed

    Rectangle {
        anchors.fill: parent
        radius: Tokens.radiusCard
        color: Theme.card
        border.width: root.current ? 2 : root.selected ? 1 : 0
        border.color: root.current ? Theme.accent : Theme.textDim
    }

    Column {
        anchors.centerIn: parent
        spacing: Tokens.spacingLarge

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Tokens.spacingItem

            Repeater {
                model: root.swatches

                Rectangle {
                    required property string modelData

                    width: Tokens.themeDot
                    height: width
                    radius: width / 2
                    color: root.theme.colors[modelData]
                    border.width: 1
                    border.color: Theme.faint
                }
            }
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.theme.name
            font.pixelSize: Tokens.fontLabel
            font.weight: root.current ? Font.DemiBold : Font.Normal
            color: root.current || root.selected ? Theme.text : Theme.textDim
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }

    Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: Tokens.spacingItem
        width: 22
        height: 22
        radius: 11
        visible: root.removable && hover.hovered
        color: removeArea.containsMouse ? Theme.warning : Qt.alpha("black", 0.6)

        Glyph {
            anchors.centerIn: parent
            text: "󰅖"
            color: "white"
            font.pixelSize: Tokens.fontSmall
        }

        MouseArea {
            id: removeArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.removed()
        }
    }

    HoverHandler {
        id: hover
    }
}
