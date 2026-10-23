import QtQuick
import qs.core
import qs.services
import qs.widgets

Label {
    property string variant
    readonly property bool present: IslandConfig.data.behavior.mediaInRest && Media.active

    width: Math.min(implicitWidth, 140)
    text: Media.title
    color: Theme.textDim
    elide: Text.ElideRight
    font.pixelSize: Tokens.fontBody
}
