import QtQuick
import qs.core
import qs.services
import qs.widgets

UsageCard {
    id: root

    property var entry: ({})
    readonly property bool hasLimit: entry.status === "ok" && (entry.limit ?? 0) > 0

    title: entry.name

    Label {
        text: root.entry.provider
        color: Theme.textDim
        font.pixelSize: Tokens.fontSmall
    }

    UsageLimit {
        visible: root.hasLimit
        width: parent.width
        title: Usage.moneyText(root.entry.spend ?? 0)
        note: "из " + Usage.moneyText(root.entry.limit ?? 0)
        used: (root.entry.spend ?? 0) / (root.entry.limit || 1)
    }

    Label {
        visible: root.entry.status === "ok" && !root.hasLimit
        text: Usage.moneyText(root.entry.spend ?? 0) + " потрачено"
        font.pixelSize: Tokens.fontBody
        font.weight: Font.DemiBold
    }

    Label {
        visible: root.entry.status !== "ok"
        text: root.entry.status
        color: root.entry.status === "out of budget" ? Theme.warning : Theme.textDim
        font.pixelSize: Tokens.fontBody
        font.weight: root.entry.status === "out of budget" ? Font.DemiBold : Font.Normal
    }
}
