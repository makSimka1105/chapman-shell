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
        visible: root.variant === "icon" || root.variant === "both"
        anchors.verticalCenter: parent.verticalCenter
        bodyWidth: 30
        bodyHeight: 15
    }

    Label {
        visible: root.variant === "percent" || root.variant === "both"
        anchors.verticalCenter: parent.verticalCenter
        text: Math.round(Status.batteryLevel * 100) + "%"
        color: Status.charging ? Theme.charge : Theme.textDim
        font.pixelSize: Tokens.fontBody
        font.weight: Font.DemiBold
    }

    Ring {
        visible: root.variant === "ring"
        anchors.verticalCenter: parent.verticalCenter
        width: 30
        height: 30
        thickness: 2.5
        startAngle: 0.75 * Math.PI
        sweep: 1.5 * Math.PI
        value: Status.batteryLevel
        text: ""
        fillColor: Status.charging ? Theme.charge : Status.batteryLevel < 0.2 ? Theme.warning : Theme.text

        WifiArcs {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -1
        }
    }
}
