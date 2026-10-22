import QtQuick
import qs.services
import qs.widgets

Row {
    spacing: 8

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: layoutCode.width + 20
        height: 26
        radius: 13
        color: Qt.alpha(Theme.text, 0.14)

        Label {
            id: layoutCode
            anchors.centerIn: parent
            text: Niri.layoutCode
            font.pixelSize: 13
            font.weight: Font.DemiBold
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: Spawn.run(["niri", "msg", "action", "switch-layout", "next"])
        }
    }

    Item {
        width: 8
        height: 1
    }

    Glyph {
        anchors.verticalCenter: parent.verticalCenter
        text: Status.wifiNetwork === null ? "󰤭" : "󰤨"
        color: Theme.textDim
    }

    Label {
        anchors.verticalCenter: parent.verticalCenter
        text: Status.wifiNetwork?.name ?? "Not connected"
        color: Theme.textDim
        font.pixelSize: 15
    }
}
