import QtQuick
import qs.core
import qs.services
import qs.widgets

Item {
    id: root

    Row {
        anchors.centerIn: parent
        spacing: Tokens.spacingLarge

        Glyph {
            anchors.verticalCenter: parent.verticalCenter
            width: 28
            horizontalAlignment: Text.AlignHCenter
            text: Osd.glyph
            color: Osd.kind === "volume" && Osd.muted ? Theme.textDim : Theme.accent
            font.pixelSize: Tokens.fontDisplay
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 150
            height: Tokens.trackHeight
            radius: Tokens.radiusBar
            color: Theme.faint

            Rectangle {
                width: Math.max(parent.height, parent.width * Osd.value)
                height: parent.height
                radius: Tokens.radiusBar
                color: Theme.text

                Behavior on width {
                    NumberAnimation {
                        duration: Tokens.durationFast
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
            font.pixelSize: Tokens.fontSubtitle
            font.weight: Font.DemiBold
        }
    }
}
