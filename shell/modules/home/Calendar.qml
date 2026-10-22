import QtQuick
import Quickshell
import qs.services
import qs.widgets

Rectangle {
    id: root

    readonly property var locale: Qt.locale("en_US")
    readonly property date today: clock.date
    readonly property int year: today.getFullYear()
    readonly property int month: today.getMonth()
    readonly property int offset: (new Date(year, month, 1).getDay() + 6) % 7
    readonly property int days: new Date(year, month + 1, 0).getDate()
    readonly property real cellWidth: 34
    readonly property real cellHeight: 22

    implicitWidth: grid.width + 32
    implicitHeight: column.height + 28
    radius: 18
    color: Theme.card

    SystemClock {
        id: clock
        precision: SystemClock.Hours
    }

    Column {
        id: column
        anchors.centerIn: parent
        spacing: 4

        Label {
            leftPadding: (root.cellWidth - 14) / 2
            text: root.locale.standaloneMonthName(root.month).toUpperCase()
            color: Theme.accent
            font.pixelSize: 11
            font.weight: Font.Bold
            font.letterSpacing: 0.5
        }

        Grid {
            id: grid
            columns: 7

            Repeater {
                model: 7

                Label {
                    required property int index

                    width: root.cellWidth
                    height: 18
                    horizontalAlignment: Text.AlignHCenter
                    text: root.locale.dayName((index + 1) % 7, Locale.NarrowFormat)
                    color: Theme.textDim
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                }
            }

            Repeater {
                model: root.offset + root.days

                Item {
                    required property int index
                    readonly property int day: index - root.offset + 1
                    readonly property bool isToday: day === root.today.getDate()

                    width: root.cellWidth
                    height: root.cellHeight

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.height
                        height: width
                        radius: width / 2
                        color: Theme.accent
                        visible: parent.isToday
                    }

                    Label {
                        anchors.centerIn: parent
                        visible: parent.day > 0
                        text: parent.day
                        color: parent.isToday ? "black" : index % 7 > 4 ? Theme.textDim : Theme.text
                        font.pixelSize: 12
                        font.weight: parent.isToday ? Font.Bold : Font.Medium
                    }
                }
            }
        }
    }
}
