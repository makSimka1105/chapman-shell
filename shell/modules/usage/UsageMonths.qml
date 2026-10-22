import QtQuick
import qs.core
import qs.services
import qs.widgets

UsageCard {
    id: root

    required property string currentMonth

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
                Label { width: 90; text: Usage.moneyText(Usage.monthValue(monthRow.modelData, "claude", "eq")); horizontalAlignment: Text.AlignRight; font.pixelSize: Tokens.fontSmall }
                Label { width: 90; text: Usage.moneyText(Usage.monthValue(monthRow.modelData, "or", "eq")); horizontalAlignment: Text.AlignRight; font.pixelSize: Tokens.fontSmall }
                Label { width: 90; text: Usage.moneyText(Usage.monthValue(monthRow.modelData, "course", "eq")); horizontalAlignment: Text.AlignRight; font.pixelSize: Tokens.fontSmall }
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
