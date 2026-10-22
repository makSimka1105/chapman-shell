import QtQuick
import qs.services

Label {
    id: root

    property string glyph
    property bool enabled: true
    signal clicked

    text: glyph
    color: !enabled ? Theme.faint : area.containsMouse ? Theme.accent : Theme.text
    font.family: "JetBrainsMono Nerd Font"
    font.pixelSize: 16

    MouseArea {
        id: area
        anchors.fill: parent
        anchors.margins: -6
        hoverEnabled: true
        enabled: root.enabled
        onClicked: root.clicked()
    }
}
