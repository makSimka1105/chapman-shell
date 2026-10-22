import QtQuick
import qs.core
import qs.services

Label {
    id: root

    property string glyph
    property bool enabled: true
    signal clicked

    text: glyph
    color: !enabled ? Theme.faint : area.containsMouse ? Theme.accent : Theme.text
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: Tokens.fontSubtitle

    MouseArea {
        id: area
        anchors.fill: parent
        anchors.margins: Tokens.hitAreaMargin
        hoverEnabled: true
        enabled: root.enabled
        onClicked: root.clicked()
    }
}
