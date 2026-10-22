import QtQuick
import qs.core
import qs.services
import qs.widgets

UsageCard {
    id: root

    required property string currentMonth
    readonly property real sourceWidth: Math.min(90, (width - 370) / Math.max(1, Usage.sourceIds.length))
    readonly property var fixedHeads: [["INPUT", 80], ["OUTPUT", 80], ["ВСЕГО", 90], ["Δ", 60]]
    readonly property var heads: [["МЕСЯЦ", 60]].concat(Usage.sourceIds.map(id => [Usage.sourceName(id).toUpperCase(), sourceWidth]), fixedHeads)

    title: "Все месяцы"

    Row {
        Repeater {
            model: root.heads

            Label {
                required property var modelData
                required property int index

                width: modelData[1]
                text: modelData[0]
                elide: Text.ElideRight
                horizontalAlignment: index === 0 ? Text.AlignLeft : Text.AlignRight
                color: Theme.textDim
                font.pixelSize: Tokens.fontMicro
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

                Label { width: 60; text: Usage.monthLabel(monthRow.modelData) + (monthRow.modelData.m === root.currentMonth ? "*" : ""); font.pixelSize: Tokens.fontSmall }
                Repeater {
                    model: Usage.sourceIds

                    Label {
                        required property string modelData

                        width: root.sourceWidth
                        text: Usage.moneyText(Usage.monthValue(monthRow.modelData, modelData, "eq"))
                        horizontalAlignment: Text.AlignRight
                        font.pixelSize: Tokens.fontSmall
                    }
                }

                Label { width: 80; text: Usage.tokensText(Usage.monthValue(monthRow.modelData, "", "i")); horizontalAlignment: Text.AlignRight; font.pixelSize: Tokens.fontSmall }
                Label { width: 80; text: Usage.tokensText(Usage.monthValue(monthRow.modelData, "", "o")); horizontalAlignment: Text.AlignRight; font.pixelSize: Tokens.fontSmall }
                Label { width: 90; text: Usage.moneyText(monthRow.cost); horizontalAlignment: Text.AlignRight; font.pixelSize: Tokens.fontSmall; font.weight: Font.DemiBold }
                Label { width: 60; text: monthRow.index > 0 ? Usage.deltaText(monthRow.cost, Usage.monthValue(Usage.months[monthRow.index - 1], "", "eq")) : "-"; horizontalAlignment: Text.AlignRight; color: Theme.textDim; font.pixelSize: Tokens.fontSmall }
            }
        }
    }

    Label {
        visible: Usage.months.length === 0
        text: "История появится после первого опроса"
        color: Theme.textDim
        font.pixelSize: Tokens.fontSmall
    }
}
