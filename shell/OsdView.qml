import QtQuick
import qs.services

Item {
    id: root

    Row {
        anchors.centerIn: parent
        spacing: 14

        Glyph {
            anchors.verticalCenter: parent.verticalCenter
            width: 28
            horizontalAlignment: Text.AlignHCenter
            text: Osd.glyph
            color: Osd.kind === "volume" && Osd.muted ? Theme.textDim : Theme.accent
            font.pixelSize: 24
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 150
            height: 8
            radius: 4
            color: Theme.faint

            Rectangle {
                width: Math.max(parent.height, parent.width * Osd.value)
                height: parent.height
                radius: 4
                color: Theme.text

                Behavior on width {
                    NumberAnimation {
                        duration: 160
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        Label {
            anchors.verticalCenter: parent.verticalCenter
            width: 34
            horizontalAlignment: Text.AlignRight
            text: Math.round(Osd.value * 100)
            font.pixelSize: 16
            font.weight: Font.DemiBold
        }
    }
}
