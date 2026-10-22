import QtQuick
import qs.core
import qs.services
import qs.widgets

Row {
    id: root

    property var names: []
    property int current: 0

    spacing: Tokens.spacingItem

    Repeater {
        model: root.names

        Rectangle {
            id: tab

            required property string modelData
            required property int index

            width: tabLabel.implicitWidth + 28
            height: 32
            radius: Tokens.radiusChip
            color: root.current === index ? Qt.alpha(Theme.text, 0.16) : Theme.card

            Label {
                id: tabLabel

                anchors.centerIn: parent
                text: tab.modelData
                color: root.current === tab.index ? Theme.text : Theme.textDim
                font.pixelSize: Tokens.fontBody
                font.weight: Font.DemiBold
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.current = tab.index
            }
        }
    }
}
