import QtQuick
import qs.services
import qs.widgets

Column {
    id: root

    property string metric: "eq"
    property int first: Math.max(0, Usage.months.length - 2)
    property int second: Math.max(0, Usage.months.length - 1)
    readonly property var metrics: [
        { key: "eq", title: "Эквивалент $" },
        { key: "i", title: "Input" },
        { key: "o", title: "Output" }
    ]
    readonly property string currentMonth: Qt.formatDate(new Date(), "yyyy-MM")
    readonly property var current: Usage.months.find(month => month.m === currentMonth)
    readonly property var previous: Usage.months[Usage.months.length - 2]
    readonly property real dayOfMonth: new Date().getDate()
    readonly property real daysInMonth: new Date(new Date().getFullYear(), new Date().getMonth() + 1, 0).getDate()
    readonly property real currentCost: Usage.monthValue(current, "", "eq")
    readonly property real forecast: currentCost * daysInMonth / dayOfMonth
    readonly property var peak: Usage.months.reduce((best, month) => !best || Usage.monthValue(month, "", "eq") > Usage.monthValue(best, "", "eq") ? month : best, null)
    readonly property var cards: [
        { title: "Этот месяц", value: Usage.moneyText(currentCost), note: dayOfMonth + " из " + daysInMonth + " дн." },
        { title: "Прогноз на месяц", value: Usage.moneyText(forecast), note: Usage.fullMonth(previous) ? Usage.deltaText(forecast, Usage.monthValue(previous, "", "eq")) + " к " + Usage.monthLabel(previous) : "нет полного прошлого месяца" },
        { title: "Прошлый месяц", value: previous ? Usage.moneyText(Usage.monthValue(previous, "", "eq")) : "-", note: previous ? "in " + Usage.tokensText(Usage.monthValue(previous, "", "i")) + " · out " + Usage.tokensText(Usage.monthValue(previous, "", "o")) : "" },
        { title: "Пик", value: peak ? Usage.moneyText(Usage.monthValue(peak, "", "eq")) : "-", note: peak ? Usage.monthLabel(peak) + " " + peak.m.slice(0, 4) : "" }
    ]
    readonly property var compareRows: Usage.sourceKeys.concat([""]).map(key => ({
                name: key === "" ? "Всего" : Usage.sourceNames[key],
                a: Usage.monthValue(Usage.months[first], key, metric),
                b: Usage.monthValue(Usage.months[second], key, metric)
            }))

    function metricText(value) {
        return metric === "eq" ? Usage.moneyText(value) : Usage.tokensText(value);
    }

    spacing: 12

    component Chip: Rectangle {
        id: chip

        property string text
        property bool active

        signal clicked

        width: chipLabel.width + 18
        height: 24
        radius: 12
        color: active ? Theme.text : Theme.faint

        Label {
            id: chipLabel

            anchors.centerIn: parent
            text: chip.text
            color: chip.active ? "black" : Theme.text
            font.pixelSize: 12
            font.weight: Font.DemiBold
        }

        MouseArea {
            anchors.fill: parent
            onClicked: chip.clicked()
        }
    }

    Row {
        width: parent.width
        spacing: 8

        Repeater {
            model: root.cards

            UsageKpi {
                required property var modelData

                width: (root.width - 24) / 4
                title: modelData.title
                value: modelData.value
                note: modelData.note
            }
        }
    }

    Row {
        width: parent.width
        height: Math.max(leftCard.implicitHeight, rightCard.implicitHeight)
        spacing: 12

        UsageCard {
            id: leftCard
            height: parent.height
            width: (root.width - 12) * 0.56
            title: "По месяцам"

            Row {
                spacing: 6

                Repeater {
                    model: root.metrics

                    Chip {
                        required property var modelData

                        text: modelData.title
                        active: root.metric === modelData.key
                        onClicked: root.metric = modelData.key
                    }
                }
            }

            UsageBars {
                width: parent.width
                plotHeight: 130
                labels: Usage.months.map(month => Usage.monthLabel(month) + (month.m === root.currentMonth ? "*" : ""))
                series: Usage.sourceKeys.map(key => ({
                            values: Usage.months.map(month => Usage.monthValue(month, key, root.metric)),
                            color: Usage.sourceColors[key]
                        }))
                format: value => root.metricText(value)
            }

            Label {
                text: "* месяц не закончен, история пишется при каждом опросе"
                color: Theme.textDim
                font.pixelSize: 11
            }
        }

        UsageCard {
            id: rightCard
            height: parent.height
            width: (root.width - 12) * 0.44
            title: "Сравнить два месяца"

            Row {
                spacing: 4

                Repeater {
                    model: Usage.months

                    Chip {
                        required property var modelData
                        required property int index

                        text: Usage.monthLabel(modelData)
                        active: root.first === index
                        onClicked: root.first = index
                    }
                }
            }

            Row {
                spacing: 4

                Repeater {
                    model: Usage.months

                    Chip {
                        required property var modelData
                        required property int index

                        text: Usage.monthLabel(modelData)
                        active: root.second === index
                        onClicked: root.second = index
                    }
                }
            }

            Repeater {
                model: root.compareRows

                Item {
                    id: compareRow

                    required property var modelData

                    width: parent.width
                    height: 22

                    Label {
                        text: compareRow.modelData.name
                        font.pixelSize: 12
                        font.weight: compareRow.modelData.name === "Всего" ? Font.Bold : Font.Normal
                    }

                    Row {
                        anchors.right: parent.right
                        spacing: 0

                        Label {
                            width: 70
                            text: root.metricText(compareRow.modelData.a)
                            horizontalAlignment: Text.AlignRight
                            font.pixelSize: 12
                        }

                        Label {
                            width: 70
                            text: root.metricText(compareRow.modelData.b)
                            horizontalAlignment: Text.AlignRight
                            font.pixelSize: 12
                        }

                        Label {
                            width: 56
                            text: Usage.deltaText(compareRow.modelData.b, compareRow.modelData.a)
                            horizontalAlignment: Text.AlignRight
                            color: Theme.textDim
                            font.pixelSize: 12
                        }
                    }
                }
            }
        }
    }

    UsageCard {
        width: parent.width
        title: "Все месяцы"

        Row {
            Repeater {
                model: [["МЕСЯЦ", 60], ["CLAUDE", 90], ["OPENROUTER", 90], ["КУРС", 90], ["INPUT", 80], ["OUTPUT", 80], ["ВСЕГО", 90], ["Δ", 60]]

                Label {
                    required property var modelData
                    required property int index

                    width: modelData[1]
                    text: modelData[0]
                    horizontalAlignment: index === 0 ? Text.AlignLeft : Text.AlignRight
                    color: Theme.textDim
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                }
            }
        }

        Repeater {
            model: Usage.months

            Item {
                id: monthRow

                required property var modelData
                required property int index
                readonly property real cost: Usage.monthValue(modelData, "", "eq")

                width: parent.width
                height: 26

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.faint
                }

                Row {
                    anchors.verticalCenter: parent.verticalCenter

                    Label { width: 60; text: Usage.monthLabel(monthRow.modelData) + (monthRow.modelData.m === root.currentMonth ? "*" : ""); font.pixelSize: 12 }
                    Label { width: 90; text: Usage.moneyText(Usage.monthValue(monthRow.modelData, "claude", "eq")); horizontalAlignment: Text.AlignRight; font.pixelSize: 12 }
                    Label { width: 90; text: Usage.moneyText(Usage.monthValue(monthRow.modelData, "or", "eq")); horizontalAlignment: Text.AlignRight; font.pixelSize: 12 }
                    Label { width: 90; text: Usage.moneyText(Usage.monthValue(monthRow.modelData, "course", "eq")); horizontalAlignment: Text.AlignRight; font.pixelSize: 12 }
                    Label { width: 80; text: Usage.tokensText(Usage.monthValue(monthRow.modelData, "", "i")); horizontalAlignment: Text.AlignRight; font.pixelSize: 12 }
                    Label { width: 80; text: Usage.tokensText(Usage.monthValue(monthRow.modelData, "", "o")); horizontalAlignment: Text.AlignRight; font.pixelSize: 12 }
                    Label { width: 90; text: Usage.moneyText(monthRow.cost); horizontalAlignment: Text.AlignRight; font.pixelSize: 12; font.weight: Font.DemiBold }
                    Label { width: 60; text: monthRow.index > 0 ? Usage.deltaText(monthRow.cost, Usage.monthValue(Usage.months[monthRow.index - 1], "", "eq")) : "-"; horizontalAlignment: Text.AlignRight; color: Theme.textDim; font.pixelSize: 12 }
                }
            }
        }

        Label {
            visible: Usage.months.length === 0
            text: "История появится после первого опроса"
            color: Theme.textDim
            font.pixelSize: 12
        }
    }
}
