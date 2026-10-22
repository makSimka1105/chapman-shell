import QtQuick
import Quickshell
import qs.services
import qs.widgets

Column {
    spacing: 0

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Label {
        text: Qt.formatTime(clock.date, "HH:mm")
        font.pixelSize: 40
        font.weight: Font.DemiBold
    }

    Label {
        text: clock.date.toLocaleDateString(Qt.locale("en_US"), "dddd, MMMM d")
        color: Theme.textDim
        font.pixelSize: 14
    }
}
