import QtQuick
import qs.services

Column {
    id: root

    required property string source
    readonly property color tint: Usage.sourceColors[source]
    readonly property var rows: Usage.modelRows(source)
    readonly property real input: Usage.total(source, "i")
    readonly property real output: Usage.total(source, "o")
    readonly property bool hasData: Usage.hasTokens(source)
    readonly property real requests: Usage.total(source, "reqs")
    readonly property real cost: Usage.total(source, "eq")
    readonly property real saved: Usage.costAt(source, Usage.priceOf("sonnet")) - cost
    readonly property var cards: {
        const tokens = { title: "Токены, 7д", value: Usage.tokensText(input + output), note: "in " + Usage.tokensText(input) + " · out " + Usage.tokensText(output) };
        if (source === "claude")
            return [
                { title: "5 часов", value: Math.round(Usage.fiveHour * 100) + "%", note: "сброс через " + Usage.untilText(Usage.fiveHourReset) },
                { title: "7 дней", value: Math.round(Usage.sevenDay * 100) + "%", note: "сброс через " + Usage.untilText(Usage.sevenDayReset) },
                { title: "Эквивалент, 7д", value: Usage.moneyText(cost), note: "по прайсу API" },
                tokens
            ];
        if (source === "or" && !hasData)
            return [
                { title: "Потрачено, месяц", value: Usage.moneyText(Usage.openRouterSpend), note: "из " + Usage.moneyText(Usage.openRouterLimit) + ", сброс через " + Usage.untilText(Usage.openRouterReset) },
                { title: "Осталось", value: Usage.moneyText(Math.max(0, Usage.openRouterLimit - Usage.openRouterSpend)), note: "лимит ключа" },
                { title: "Сегодня", value: Usage.moneyText(Usage.orSpendDaily), note: "по данным OpenRouter" },
                { title: "За неделю", value: Usage.moneyText(Usage.orSpendWeekly), note: Usage.moneyText(Usage.orSpendWeekly / 7) + " в день" }
            ];
        if (source === "or")
            return [
                { title: "Потрачено", value: Usage.moneyText(Usage.openRouterSpend), note: "из " + Usage.moneyText(Usage.openRouterLimit) + ", сброс через " + Usage.untilText(Usage.openRouterReset) },
                { title: "Осталось", value: Usage.moneyText(Math.max(0, Usage.openRouterLimit - Usage.openRouterSpend)), note: Usage.moneyText(Usage.orSpendWeekly / 7) + " в день за неделю" },
                tokens,
                { title: "Запросов", value: Math.round(requests).toString(), note: "по данным OpenRouter" }
            ];
        return [
            tokens,
            { title: "Эквивалент, 7д", value: Usage.moneyText(cost), note: "по ценам OpenRouter" },
            { title: "Запросов", value: Math.round(requests).toString(), note: requests > 0 ? Usage.tokensText((input + output) / requests) + " на запрос" : "нет" },
            { title: "Экономия", value: Usage.moneyText(Math.max(0, saved)), note: "против sonnet на тех же токенах" }
        ];
    }

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
        visible: root.hasData
        width: parent.width
        height: Math.max(leftCard.implicitHeight, rightCard.implicitHeight)
        spacing: 12

        UsageCard {
            id: leftCard
            height: parent.height
            width: (root.width - 12) * 0.62
            title: "Токены по дням, input и output"

            UsageBars {
                width: parent.width
                labels: Usage.windowDays.map(day => Usage.dayLabel(day))
                series: [
                    { values: Usage.series(root.source, "i"), color: Usage.inputColor },
                    { values: Usage.series(root.source, "o"), color: Usage.outputColor }
                ]
                format: value => Usage.tokensText(value)
            }

            Label {
                text: "СЕГОДНЯ ПО ЧАСАМ, ЗАПРОСЫ"
                color: Theme.textDim
                font.pixelSize: 11
                font.weight: Font.DemiBold
                font.letterSpacing: 1
            }

            UsageBars {
                width: parent.width
                plotHeight: 56
                labels: Usage.hours(root.source).map((_, hour) => hour % 6 === 0 ? String(hour).padStart(2, "0") : "")
                series: [{ values: Usage.hours(root.source), color: root.tint }]
            }
        }

        UsageCard {
            id: rightCard
            height: parent.height
            width: (root.width - 12) * 0.38
            title: "Input и output"

            UsageSplit {
                width: parent.width
                input: root.input
                output: root.output
                cache: Usage.total(root.source, "cr") + Usage.total(root.source, "cw")
            }

            Label {
                text: "ЦЕНА ЗА 1M ТОКЕНОВ"
                color: Theme.textDim
                font.pixelSize: 11
                font.weight: Font.DemiBold
                font.letterSpacing: 1
            }

            Repeater {
                model: root.rows

                Item {
                    id: priceRow

                    required property var modelData

                    width: parent.width
                    height: 18

                    Label {
                        width: parent.width - priceLabel.width - 8
                        text: priceRow.modelData.model
                        font.pixelSize: 12
                        elide: Text.ElideRight
                    }

                    Label {
                        id: priceLabel

                        anchors.right: parent.right
                        text: priceRow.modelData.p ? Usage.priceText(priceRow.modelData.p[0]) + " in · " + Usage.priceText(priceRow.modelData.p[1]) + " out" : "нет цены"
                        color: Theme.textDim
                        font.pixelSize: 12
                    }
                }
            }
        }
    }

    UsageCard {
        visible: !root.hasData
        width: parent.width
        title: "Токены"

        Label {
            width: parent.width
            text: "Токены этого ключа не считаются: OpenRouter отдаёт только расход в долларах, а локальных сессий через него нет. Расход и остаток лимита берутся с сервера."
            color: Theme.textDim
            font.pixelSize: 13
            wrapMode: Text.WordWrap
        }
    }

    UsageCard {
        visible: root.hasData
        width: parent.width
        title: "Модели: токены, цена API, эквивалент"

        UsageTable {
            width: parent.width
            rows: root.rows
        }
    }
}
