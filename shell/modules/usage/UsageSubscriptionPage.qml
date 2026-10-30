import QtQuick
import qs.core
import qs.services
import qs.widgets

Column {
    id: root

    required property string source
    readonly property var item: Usage.source(source)
    readonly property var windows: item.live?.windows ?? []
    readonly property real input: Usage.total(source, "i")
    readonly property real output: Usage.total(source, "o")
    readonly property real requests: Usage.total(source, "reqs")
    readonly property real sinceInput: Usage.sinceTotal(source, "i")
    readonly property real sinceOutput: Usage.sinceTotal(source, "o")
    readonly property var cards: windows.map(entry => ({
                title: entry.label,
                value: Math.round(entry.used * 100) + "%",
                note: "сброс через " + Usage.untilText(new Date(entry.resets_at))
            })).concat([
        { title: "Токены " + Usage.sinceLabel, value: Usage.tokensText(sinceInput + sinceOutput), note: "in " + Usage.tokensText(sinceInput) + " · out " + Usage.tokensText(sinceOutput) },
        { title: "Эквивалент " + Usage.sinceLabel, value: Usage.moneyText(Usage.sinceTotal(source, "eq")), note: "по прайсу API" },
        { title: "Запросов, 7д", value: Math.round(requests).toString(), note: requests > 0 ? Usage.tokensText((input + output) / requests) + " на запрос" : "нет" },
        { title: "Статус", value: Usage.statusText(item.status), note: item.provider }
    ]).slice(0, 4)

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

    UsageCard {
        width: parent.width
        title: "Окна лимитов"

        Repeater {
            model: root.windows

            UsageLimit {
                required property var modelData

                width: parent.width
                title: modelData.label
                note: Math.round(modelData.used * 100) + "% · сброс " + Usage.untilText(new Date(modelData.resets_at))
                used: modelData.used
                pace: Usage.windowPace(modelData.id, new Date(modelData.resets_at))
                tint: Usage.sourceColor(root.source)
            }
        }

        Label {
            visible: root.windows.length === 0
            text: "Лимиты недоступны: " + Usage.statusText(root.item.status)
            color: Usage.statusWarn(root.item.status) ? Theme.warning : Theme.textDim
            font.pixelSize: Tokens.fontBody
        }
    }

    UsageTokens {
        width: parent.width
        source: root.source
    }
}
