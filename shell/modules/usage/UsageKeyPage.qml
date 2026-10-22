import QtQuick
import qs.core
import qs.services
import qs.widgets

Column {
    id: root

    required property string source
    readonly property var item: Usage.source(source)
    readonly property var live: item.live ?? ({})
    readonly property bool hasLimit: (live.limit ?? 0) > 0
    readonly property bool spendKnown: (live.spend ?? null) !== null
    readonly property bool exhausted: item.status === "out of budget"
    readonly property real input: Usage.total(source, "i")
    readonly property real output: Usage.total(source, "o")
    readonly property var cards: [
        { title: "Потрачено", value: spendKnown ? Usage.moneyText(live.spend) : "-", note: hasLimit ? "из " + Usage.moneyText(live.limit) : "без лимита" },
        { title: "Осталось", value: live.remaining !== null && live.remaining !== undefined ? Usage.moneyText(live.remaining) : "-", note: exhausted ? "бюджет исчерпан" : "лимит ключа" },
        { title: "Токены, 7д", value: Usage.tokensText(input + output), note: "in " + Usage.tokensText(input) + " · out " + Usage.tokensText(output) },
        { title: "Эквивалент, 7д", value: Usage.moneyText(Usage.total(source, "eq")), note: "по ценам OpenRouter" }
    ]

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
        title: "Бюджет ключа"

        UsageLimit {
            visible: root.hasLimit && root.spendKnown
            width: parent.width
            title: "Расход"
            note: Usage.moneyText(root.live.spend ?? 0) + " из " + Usage.moneyText(root.live.limit ?? 0)
            used: root.hasLimit && root.spendKnown ? root.live.spend / root.live.limit : 0
            tint: Usage.sourceColor(root.source)
        }

        Label {
            width: parent.width
            text: root.exhausted ? "Бюджет ключа исчерпан: сервер отвечает 402, запросы не проходят." : "Состояние: " + Usage.statusText(root.item.status)
            color: Usage.statusWarn(root.item.status) ? Theme.warning : Theme.textDim
            font.pixelSize: Tokens.fontBody
            wrapMode: Text.WordWrap
        }
    }

    UsageTokens {
        width: parent.width
        source: root.source
    }
}
