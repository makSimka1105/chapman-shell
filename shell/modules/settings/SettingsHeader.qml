import QtQuick
import qs.core
import qs.services
import qs.widgets

Column {
    id: root

    required property var section

    spacing: Tokens.spacingItem
    topPadding: Tokens.marginField

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        width: Tokens.headerIconSize
        height: width
        radius: Tokens.radiusPanel
        color: Qt.alpha(Theme.accent, 0.16)

        Glyph {
            anchors.centerIn: parent
            text: root.section.glyph
            font.pixelSize: Tokens.fontDisplay + Tokens.fontHeading
            color: Theme.accent
        }
    }

    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.section.title
        font.pixelSize: Tokens.fontDisplay
        font.weight: Font.DemiBold
    }

    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.section.subtitle
        visible: text !== ""
        font.pixelSize: Tokens.fontBody
        color: Theme.textDim
    }
}
