import QtQuick
import Quickshell
import qs.core
import qs.services
import qs.widgets

Column {
    spacing: 0

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        text: Qt.formatDateTime(clock.date, "HH:mm")
        font.pixelSize: 120
        font.weight: Font.DemiBold
    }

    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        text: Qt.formatDateTime(clock.date, "dddd, MMMM d")
        color: Theme.textDim
        font.pixelSize: Tokens.fontDisplay
    }
}
