import QtQuick
import qs.services
import qs.widgets

Item {
    id: root

    required property string glyph
    required property string title
    required property string caption
    required property color tint

    signal clicked

    width: 124
    height: textColumn.height

    MouseArea {
        anchors.fill: parent
        anchors.margins: -6
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    Column {
        id: textColumn
        width: 124
        spacing: 1

        Row {
            spacing: 6

            Glyph {
                anchors.verticalCenter: parent.verticalCenter
                text: root.glyph
                color: root.tint
                font.pixelSize: 15
            }

            Label {
                text: root.title
                color: root.tint
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }
        }

        Label {
            width: 124
            text: root.caption
            color: Theme.textDim
            elide: Text.ElideRight
            font.pixelSize: 13
        }
    }
}
