import QtQuick
import qs.core
import qs.services
import qs.widgets

Column {
    id: root

    readonly property real costTotal: Usage.allTotal("eq")
    readonly property real inputTotal: Usage.allTotal("i")
    readonly property real outputTotal: Usage.allTotal("o")
    readonly property var nearest: Usage.nearestWindow
    readonly property var cards: [
        { title: "Эквивалент API, 7д", value: Usage.moneyText(costTotal), note: "все источники" },
        { title: "Платим на деле", value: Usage.moneyText(Usage.keySpend), note: "ключи, расход по данным серверов" },
        { title: "Токены, 7д", value: Usage.tokensText(inputTotal + outputTotal), note: "in " + Usage.tokensText(inputTotal) + " · out " + Usage.tokensText(outputTotal) },
        { title: "Ближайший лимит", value: nearest ? Usage.untilText(new Date(nearest.window.resets_at)) : "-", note: nearest ? Usage.sourceName(nearest.id) + ", " + nearest.window.label + ", " + Math.round(nearest.window.used * 100) + "%" : "нет данных" }
    ]
    readonly property var costSeries: Usage.tokenIds.map(id => ({
                values: Usage.series(id, "eq"),
                color: Usage.sourceColor(id)
            }))
    readonly property var limitRows: Usage.limitWindows.map(entry => ({
                title: Usage.sourceName(entry.id) + ", " + entry.window.label,
                note: Math.round(entry.window.used * 100) + "% · сброс " + Usage.untilText(new Date(entry.window.resets_at)),
                used: entry.window.used,
                pace: Usage.windowPace(entry.window.id, new Date(entry.window.resets_at)),
                tint: Usage.sourceColor(entry.id)
            })).concat(Usage.keyIds.filter(id => (Usage.source(id).live?.limit ?? 0) > 0).map(id => ({
                title: Usage.sourceName(id) + ", ключ",
                note: Usage.moneyText(Usage.source(id).live.spend ?? 0) + " из " + Usage.moneyText(Usage.source(id).live.limit),
                used: (Usage.source(id).live.spend ?? 0) / Usage.source(id).live.limit,
                pace: -1,
                tint: Usage.sourceColor(id)
            })))

    spacing: Tokens.spacingMedium

    Row {
        width: parent.width
        spacing: Tokens.spacingItem

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
        spacing: Tokens.spacingMedium

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
                spacing: Tokens.spacingLarge

                Repeater {
                    model: Usage.tokenIds

                    Label {
                        required property string modelData

                        text: "● " + Usage.sourceName(modelData)
                        color: Usage.sourceColor(modelData)
                        font.pixelSize: Tokens.fontSmall
                    }
                }
            }
        }

        UsageCard {
            id: rightCard
            height: parent.height
            width: (root.width - 12) * 0.42
            title: "Окна и лимиты"

            Repeater {
                model: root.limitRows

                UsageLimit {
                    required property var modelData

                    width: parent.width
                    title: modelData.title
                    note: modelData.note
                    used: modelData.used
                    pace: modelData.pace
                    tint: modelData.tint
                }
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
