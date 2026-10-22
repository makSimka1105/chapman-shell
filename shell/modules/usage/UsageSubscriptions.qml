import QtQuick
import qs.core
import qs.services
import qs.widgets

Row {
    id: root

    spacing: Tokens.spacingMedium

    Repeater {
        model: Usage.subscriptions

        UsageCard {
            id: card

            required property var modelData

            width: (root.width - root.spacing) / 2
            title: modelData.name

            UsageLimit {
                visible: card.modelData.status === "ok"
                width: parent.width
                title: "5 часов"
                note: Usage.windowNote(card.modelData.five_hour)
                used: (card.modelData.five_hour.used_percent ?? 0) / 100
            }

            UsageLimit {
                visible: card.modelData.status === "ok"
                width: parent.width
                title: "Неделя"
                note: Usage.windowNote(card.modelData.weekly)
                used: (card.modelData.weekly.used_percent ?? 0) / 100
            }

            Label {
                visible: card.modelData.status !== "ok"
                text: card.modelData.status
                color: Theme.textDim
                font.pixelSize: Tokens.fontBody
            }
        }
    }
}
