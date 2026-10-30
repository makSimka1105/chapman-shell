import QtQuick
import qs.core
import qs.services
import qs.widgets

Column {
    id: root

    required property string source
    readonly property int defaultWeeks: 4
    readonly property real estimateFrom: 0.05
    readonly property var weeks: Usage.weeks(source)
    property var picked: weeks.slice(-defaultWeeks).map(week => week.from)
    readonly property var shown: weeks.filter(week => picked.includes(week.from))
    readonly property var current: weeks[weeks.length - 1]
    readonly property var full: weeks.slice(0, -1)
    readonly property real average: full.length ? full.reduce((sum, week) => sum + Usage.weekTokens(week), 0) / full.length : 0
    readonly property var peak: full.reduce((best, week) => !best || Usage.weekTokens(week) > Usage.weekTokens(best) ? week : best, null)
    readonly property real used: Usage.windowUsed(source, "seven_day")
    readonly property var cards: [
        { title: "Эта неделя", value: Usage.tokensText(Usage.weekTokens(current)), note: current ? "с " + Usage.shortDate(current.from) + " · " + Math.round(current.reqs) + " запросов" : "нет данных" },
        { title: "Средняя неделя", value: Usage.tokensText(average), note: full.length + " полных нед. · эта " + Usage.deltaText(Usage.weekTokens(current), average) },
        { title: "Пик", value: peak ? Usage.tokensText(Usage.weekTokens(peak)) : "-", note: peak ? "неделя с " + Usage.shortDate(peak.from) : "нет полных недель" },
        { title: "Весь лимит ≈", value: used >= estimateFrom ? Usage.tokensText(Usage.weekTokens(current) / used) : "-", note: Math.round(used * 100) + "% недели потрачено" }
    ]

    function toggle(from) {
        picked = picked.includes(from) ? picked.filter(item => item !== from) : picked.concat([from]);
    }

    spacing: Tokens.spacingMedium

    component Chip: Rectangle {
        id: chip

        property string text
        property bool active

        signal clicked

        width: chipLabel.width + 18
        height: 24
        radius: Tokens.radiusChip
        color: active ? Theme.text : Theme.faint

        Label {
            id: chipLabel

            anchors.centerIn: parent
            text: chip.text
            color: chip.active ? "black" : Theme.text
            font.pixelSize: Tokens.fontSmall
            font.weight: Font.DemiBold
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: chip.clicked()
        }
    }

    Label {
        text: "● " + Usage.sourceName(root.source)
        color: Usage.sourceColor(root.source)
        font.pixelSize: Tokens.fontSubtitle
        font.weight: Font.Bold
    }

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
        title: "Токены по неделям лимита"

        Flow {
            width: parent.width
            spacing: Tokens.spacingSnug

            Repeater {
                model: root.weeks

                Chip {
                    required property var modelData

                    text: Usage.shortDate(modelData.from)
                    active: root.picked.includes(modelData.from)
                    onClicked: root.toggle(modelData.from)
                }
            }
        }

        UsageBars {
            id: bars

            width: parent.width
            plotHeight: 130
            labels: root.shown.map(week => Usage.shortDate(week.from))
            series: [
                { values: root.shown.map(week => week.i), color: Usage.inputColor },
                { values: root.shown.map(week => week.o), color: Usage.outputColor }
            ]
            format: value => Usage.tokensText(value)
        }

        Row {
            x: bars.axisWidth

            Repeater {
                model: root.shown

                Label {
                    required property var modelData
                    required property int index

                    width: bars.slot
                    horizontalAlignment: Text.AlignHCenter
                    text: Usage.tokensText(Usage.weekTokens(modelData)) + (index > 0 ? " · " + Usage.deltaText(Usage.weekTokens(modelData), Usage.weekTokens(root.shown[index - 1])) : "")
                    color: Theme.textDim
                    font.pixelSize: Tokens.fontSmall
                }
            }
        }

        Label {
            visible: root.shown.length === 0
            text: "Выбери недели выше"
            color: Theme.textDim
            font.pixelSize: Tokens.fontSmall
        }
    }

    UsageCard {
        width: parent.width
        title: "Модели за 30 дней"

        UsageTable {
            width: parent.width
            rows: (Usage.history(root.source).models ?? []).map(row => Object.assign({ src: root.source }, row))
        }
    }
}
