import QtQuick
import qs.core
import qs.services
import qs.widgets
import qs.modules.notch

Row {
    id: root

    property string variant: "icon"
    readonly property bool present: true

    spacing: Tokens.spacingSmall

    Battery {
        visible: root.variant !== "percent"
        anchors.verticalCenter: parent.verticalCenter
        bodyWidth: 30
        bodyHeight: 15
    }

    Label {
        visible: root.variant !== "icon"
        anchors.verticalCenter: parent.verticalCenter
        text: Math.round(Status.batteryLevel * 100) + "%"
        color: Status.charging ? Theme.charge : Theme.textDim
        font.pixelSize: Tokens.fontBody
        font.weight: Font.DemiBold
    }
}
