import QtQuick
import qs.services

Column {
    id: root

    readonly property real costTotal: Usage.sourceKeys.reduce((sum, key) => sum + Usage.total(key, "eq"), 0)
    readonly property real inputTotal: Usage.sourceKeys.reduce((sum, key) => sum + Usage.total(key, "i"), 0)
    readonly property real outputTotal: Usage.sourceKeys.reduce((sum, key) => sum + Usage.total(key, "o"), 0)
    readonly property var cards: [
        { title: "Эквивалент API, 7д", value: Usage.moneyText(costTotal), note: "все источники" },
        { title: "Платим на деле", value: Usage.moneyText(Usage.orSpendMonthly), note: "OpenRouter, месяц" },
        { title: "Токены, 7д", value: Usage.tokensText(inputTotal + outputTotal), note: "in " + Usage.tokensText(inputTotal) + " · out " + Usage.tokensText(outputTotal) },
        { title: "Ближайший лимит", value: Usage.untilText(Usage.fiveHourReset), note: "окно 5ч Claude, " + Math.round(Usage.fiveHour * 100) + "%" }
    ]
    readonly property var costSeries: Usage.sourceKeys.map(key => ({
                values: Usage.series(key, "eq"),
                color: Usage.sourceColors[key]
            }))
    readonly property real fivePace: 1 - Math.max(0, Math.min(5 * 3600000, Usage.fiveHourReset - new Date())) / (5 * 3600000)
    readonly property real sevenPace: 1 - Math.max(0, Math.min(7 * 86400000, Usage.sevenDayReset - new Date())) / (7 * 86400000)

    spacing: 12

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
            width: (root.width - 12) * 0.58
            title: "Стоимость по дням, эквивалент"

            UsageBars {
                width: parent.width
                labels: Usage.windowDays.map(day => Usage.dayLabel(day))
                series: root.costSeries
                format: value => "$" + Math.round(value)
            }

            Row {
                spacing: 14

                Repeater {
                    model: Usage.sourceKeys

                    Label {
                        required property string modelData

                        text: "● " + Usage.sourceNames[modelData]
                        color: Usage.sourceColors[modelData]
                        font.pixelSize: 12
                    }
                }
            }
        }

        UsageCard {
            id: rightCard
            height: parent.height
            width: (root.width - 12) * 0.42
            title: "Окна и лимиты"

            UsageLimit {
                width: parent.width
                title: "Claude, 5 часов"
                note: Math.round(Usage.fiveHour * 100) + "% · сброс " + Usage.untilText(Usage.fiveHourReset)
                used: Usage.fiveHour
                pace: root.fivePace
                tint: Usage.sourceColors.claude
            }

            UsageLimit {
                width: parent.width
                title: "Claude, неделя"
                note: Math.round(Usage.sevenDay * 100) + "% · сброс " + Usage.untilText(Usage.sevenDayReset)
                used: Usage.sevenDay
                pace: root.sevenPace
                tint: Usage.sourceColors.claude
            }

            UsageLimit {
                width: parent.width
                title: "OpenRouter, месяц"
                note: Usage.moneyText(Usage.openRouterSpend) + " из " + Usage.moneyText(Usage.openRouterLimit)
                used: Usage.openRouterUsed
                tint: Usage.sourceColors.or
            }
        }
    }

    UsageCard {
        width: parent.width
        title: "Дороже всего за неделю"

        UsageTable {
            width: parent.width
            rows: Usage.modelRows("").slice(0, 8)
            showSource: true
        }
    }
}
