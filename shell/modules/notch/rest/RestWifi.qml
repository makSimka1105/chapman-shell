import QtQuick
import qs.core
import qs.services
import qs.widgets

Row {
    id: root

    property string variant: "icon"
    readonly property bool present: true
    readonly property bool online: Status.wifiNetwork !== null

    spacing: Tokens.spacingSmall

    Glyph {
        anchors.verticalCenter: parent.verticalCenter
        text: !root.online ? "󰤭" : Status.wifiStrength > 0.66 ? "󰤨" : Status.wifiStrength > 0.33 ? "󰤥" : "󰤢"
        color: root.online ? Theme.accent : Theme.faint
        font.pixelSize: Tokens.fontHeading
    }

    Label {
        visible: root.variant === "name" && root.online
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(implicitWidth, 90)
        text: Status.wifiNetwork?.name ?? ""
        color: Theme.textDim
        elide: Text.ElideRight
        font.pixelSize: Tokens.fontBody
    }
}
