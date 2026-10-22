import QtQuick
import qs.services
import qs.widgets

Rectangle {
    id: root

    property string title
    property color tint: Theme.text
    property string chip
    property bool chipWarn
    property string figure
    property string unit
    property string caption
    property var segments: []
    property bool selected

    signal clicked

    implicitHeight: column.implicitHeight + 20
    radius: 18
    color: selected ? Qt.alpha(Theme.text, 0.1) : area.containsMouse ? Qt.alpha(Theme.text, 0.07) : Theme.card
    border.width: 1
    border.color: selected ? Theme.faint : "transparent"

    Column {
        id: column

        x: 14
        y: 10
        width: parent.width - 28
        spacing: 5

        Item {
            width: parent.width
            height: name.height

            Rectangle {
                id: dot

                anchors.verticalCenter: parent.verticalCenter
                width: 9
                height: 9
                radius: 5
                color: root.tint
            }

            Label {
                id: name

                anchors.left: dot.right
                anchors.leftMargin: 8
                text: root.title
                font.pixelSize: 13
                font.weight: Font.DemiBold
            }

            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: chipLabel.width + 14
                height: chipLabel.height + 4
                radius: height / 2
                color: root.chipWarn ? Qt.alpha(Theme.warning, 0.2) : Theme.faint

                Label {
                    id: chipLabel

                    anchors.centerIn: parent
                    text: root.chip
                    color: root.chipWarn ? Theme.warning : Theme.text
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                }
            }
        }

        Row {
            spacing: 6

            Label {
                text: root.figure
                font.pixelSize: 22
                font.weight: Font.Bold
            }

            Label {
                anchors.baseline: parent.children[0].baseline
                text: root.unit
                color: Theme.textDim
                font.pixelSize: 12
            }
        }

        Row {
            width: parent.width
            height: 8
            spacing: 2

            Rectangle {
                visible: root.segments.length === 0
                width: parent.width
                height: parent.height
                radius: 4
                color: Theme.faint
            }

            Repeater {
                model: root.segments

                Rectangle {
                    required property var modelData

                    width: Math.max(modelData.ratio > 0 ? 4 : 0, (column.width - (root.segments.length - 1) * 2) * Math.min(1, modelData.ratio))
                    height: 8
                    radius: 4
                    color: modelData.color
                    opacity: modelData.opacity ?? 1
                }
            }
        }

        Label {
            width: parent.width
            text: root.caption
            color: Theme.textDim
            font.pixelSize: 12
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: area

        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }
}
