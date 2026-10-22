import QtQuick
import qs.services
import qs.widgets

Rectangle {
    id: root

    required property string glyph
    required property string caption
    required property color glyphColor
    required property color captionColor

    signal clicked

    width: 58
    height: 46
    radius: 14
    color: Theme.card

    Column {
        anchors.centerIn: parent
        spacing: 2

        Glyph {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.glyph
            color: root.glyphColor
            font.pixelSize: 18
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.caption
            color: root.captionColor
            font.pixelSize: 11
            font.weight: Font.DemiBold
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
