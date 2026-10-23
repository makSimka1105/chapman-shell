import QtQuick
import qs.core
import qs.services
import qs.widgets

Label {
    property string variant
    readonly property bool present: true

    text: Niri.layoutCode
    color: Theme.textDim
    font.pixelSize: Tokens.fontMedium
    font.weight: Font.DemiBold
}
