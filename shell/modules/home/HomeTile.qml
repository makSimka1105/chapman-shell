import QtQuick
import qs.core
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
    radius: Tokens.radiusRow
    color: Theme.card

    Column {
        anchors.centerIn: parent
        spacing: Tokens.spacingHairline

        Glyph {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.glyph
            color: root.glyphColor
            font.pixelSize: Tokens.fontIcon
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.caption
            color: root.captionColor
            font.pixelSize: Tokens.fontCaption
            font.weight: Font.DemiBold
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
