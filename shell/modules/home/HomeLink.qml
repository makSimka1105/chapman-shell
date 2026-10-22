import QtQuick
import qs.core
import qs.services
import qs.widgets

Item {
    id: root

    required property string glyph
    required property string title
    required property string caption
    required property color tint

    readonly property real columnWidth: 124

    signal clicked

    width: root.columnWidth
    height: textColumn.height

    MouseArea {
        anchors.fill: parent
        anchors.margins: Tokens.hitAreaMargin
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    Column {
        id: textColumn
        width: root.columnWidth
        spacing: 1

        Row {
            spacing: Tokens.spacingSmall

            Glyph {
                anchors.verticalCenter: parent.verticalCenter
                text: root.glyph
                color: root.tint
                font.pixelSize: Tokens.fontLabel
            }

            Label {
                text: root.title
                color: root.tint
                font.pixelSize: Tokens.fontMedium
                font.weight: Font.DemiBold
            }
        }

        Label {
            width: root.columnWidth
            text: root.caption
            color: Theme.textDim
            elide: Text.ElideRight
            font.pixelSize: Tokens.fontBody
        }
    }
}
