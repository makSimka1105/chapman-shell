import QtQuick
import Quickshell
import qs.core
import qs.widgets

Label {
    id: root

    property string variant: "time"
    readonly property bool present: true
    readonly property var formats: ({
            time: "HH:mm",
            seconds: "HH:mm:ss",
            date: "ddd d MMM"
        })

    text: Qt.formatDateTime(clock.date, formats[variant] ?? formats.time)
    font.pixelSize: 17
    font.weight: Font.DemiBold

    SystemClock {
        id: clock
        precision: root.variant === "seconds" ? SystemClock.Seconds : SystemClock.Minutes
    }
}
