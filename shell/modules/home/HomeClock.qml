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
        text: Qt.formatTime(clock.date, "HH:mm")
        font.pixelSize: 40
        font.weight: Font.DemiBold
    }

    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        text: clock.date.toLocaleDateString(Qt.locale("en_US"), "dddd dd.MM")
        color: Theme.textDim
        font.pixelSize: Tokens.fontMedium
    }
}
