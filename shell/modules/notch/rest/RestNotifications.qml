import QtQuick
import qs.core
import qs.services
import qs.widgets

Row {
    id: root

    property string variant
    readonly property bool present: true
    readonly property int count: Notifications.history.length

    spacing: Tokens.spacingSnug

    Glyph {
        anchors.verticalCenter: parent.verticalCenter
        text: Notifications.dnd ? "󰂛" : "󰂚"
        color: root.count > 0 ? Theme.accent : Theme.faint
        font.pixelSize: Tokens.fontHeading
    }

    Label {
        visible: root.count > 0
        anchors.verticalCenter: parent.verticalCenter
        text: root.count
        color: Theme.accent
        font.pixelSize: Tokens.fontBody
        font.weight: Font.DemiBold
    }
}
