import QtQuick
import qs.core
import qs.services
import qs.widgets

Column {
    id: root

    required property string source
    readonly property var rows: Usage.modelRows(source)
    readonly property bool hasData: Usage.hasTokens(source)

    spacing: Tokens.spacingMedium

    Row {
        visible: root.hasData
        width: parent.width
        height: Math.max(leftCard.implicitHeight, rightCard.implicitHeight)
        spacing: Tokens.spacingMedium

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
                font.pixelSize: Tokens.fontCaption
                font.weight: Font.DemiBold
                font.letterSpacing: 1
            }

            UsageBars {
                width: parent.width
                plotHeight: 56
                labels: Usage.hours(root.source).map((_, hour) => hour % 6 === 0 ? String(hour).padStart(2, "0") : "")
                series: [{ values: Usage.hours(root.source), color: Usage.sourceColor(root.source) }]
            }
        }

        UsageCard {
            id: rightCard
            height: parent.height
            width: (root.width - 12) * 0.38
            title: "Input и output"

            UsageSplit {
                width: parent.width
                input: Usage.total(root.source, "i")
                output: Usage.total(root.source, "o")
                cache: Usage.total(root.source, "cr") + Usage.total(root.source, "cw")
            }

            Label {
                text: "ЦЕНА ЗА 1M ТОКЕНОВ"
                color: Theme.textDim
                font.pixelSize: Tokens.fontCaption
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
                        font.pixelSize: Tokens.fontSmall
                        elide: Text.ElideRight
                    }

                    Label {
                        id: priceLabel

                        anchors.right: parent.right
                        text: priceRow.modelData.p ? Usage.priceText(priceRow.modelData.p[0]) + " in · " + Usage.priceText(priceRow.modelData.p[1]) + " out" : "нет цены"
                        color: Theme.textDim
                        font.pixelSize: Tokens.fontSmall
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
            text: "За последние 7 дней в локальных логах нет запросов через этот источник."
            color: Theme.textDim
            font.pixelSize: Tokens.fontBody
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
