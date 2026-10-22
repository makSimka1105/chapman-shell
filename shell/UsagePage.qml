import QtQuick
import qs.services

Item {
    id: root

    property string selected: "all"
    readonly property real railWidth: 270
    readonly property real bodyHeight: 580
    readonly property var monthTotals: Usage.months.map(month => Usage.monthValue(month, "", "eq"))
    readonly property real monthSum: Math.max(0.000001, monthTotals.reduce((sum, value) => sum + value, 0))
    readonly property real costSum: Math.max(0.000001, Usage.sourceKeys.reduce((sum, key) => sum + Usage.total(key, "eq"), 0))
    readonly property var rails: [
        {
            key: "all",
            title: "Общая",
            tint: Theme.text,
            chip: Usage.sevenDay > 0.85 ? "7д " + Math.round(Usage.sevenDay * 100) + "%" : "в норме",
            warn: Usage.sevenDay > 0.85,
            figure: Usage.moneyText(costSum),
            unit: "эквивалент, 7д",
            caption: "in " + Usage.tokensText(Usage.sourceKeys.reduce((sum, key) => sum + Usage.total(key, "i"), 0)) + " · out " + Usage.tokensText(Usage.sourceKeys.reduce((sum, key) => sum + Usage.total(key, "o"), 0)),
            segments: Usage.sourceKeys.map(key => ({ ratio: Usage.total(key, "eq") / costSum, color: Usage.sourceColors[key] }))
        },
        {
            key: "claude",
            title: Usage.sourceNames.claude,
            tint: Usage.sourceColors.claude,
            chip: Usage.sevenDay > 0.85 ? "7д почти всё" : "сброс " + Usage.untilText(Usage.fiveHourReset),
            warn: Usage.sevenDay > 0.85,
            figure: Math.round(Usage.fiveHour * 100) + "%",
            unit: "5ч · " + Math.round(Usage.sevenDay * 100) + "% 7д",
            caption: "in " + Usage.tokensText(Usage.total("claude", "i")) + " · out " + Usage.tokensText(Usage.total("claude", "o")),
            segments: [{ ratio: Usage.fiveHour, color: Usage.sourceColors.claude }]
        },
        {
            key: "or",
            title: Usage.sourceNames.or,
            tint: Usage.sourceColors.or,
            chip: "сброс " + Usage.untilText(Usage.openRouterReset),
            figure: Usage.moneyText(Usage.openRouterSpend),
            unit: "из " + Usage.moneyText(Usage.openRouterLimit),
            caption: Usage.hasTokens("or") ? "in " + Usage.tokensText(Usage.total("or", "i")) + " · out " + Usage.tokensText(Usage.total("or", "o")) : "токены не считаются",
            segments: [{ ratio: Usage.openRouterUsed, color: Usage.sourceColors.or }]
        },
        {
            key: "course",
            title: Usage.sourceNames.course,
            tint: Usage.sourceColors.course,
            chip: "без лимита",
            figure: Usage.tokensText(Usage.tokenTotal("course")),
            unit: "токенов, 7д",
            caption: "in " + Usage.tokensText(Usage.total("course", "i")) + " · out " + Usage.tokensText(Usage.total("course", "o")),
            segments: [{ ratio: Usage.series("course", "i")[6] / Math.max(1, ...Usage.series("course", "i")), color: Usage.sourceColors.course }]
        },
        {
            key: "history",
            title: "История",
            tint: Theme.text,
            chip: Usage.months.length + " мес",
            figure: Usage.moneyText(monthTotals[monthTotals.length - 1] ?? 0),
            unit: "последний месяц",
            caption: Usage.months.length > 1 && Usage.fullMonth(Usage.months[Usage.months.length - 2]) ? Usage.deltaText(monthTotals[monthTotals.length - 1], monthTotals[monthTotals.length - 2]) + " к " + Usage.monthLabel(Usage.months[Usage.months.length - 2]) : "нет полного прошлого месяца",
            segments: monthTotals.map((value, index) => ({ ratio: value / monthSum, color: Theme.text, opacity: index === monthTotals.length - 1 ? 1 : 0.35 }))
        }
    ]
    readonly property var panels: ({
            all: overviewPanel,
            history: historyPanel
        })

    signal back

    implicitHeight: 44 + 10 + bodyHeight

    PageHeader {
        id: header

        width: parent.width
        title: "AI Usage"
        onBack: root.back()

        Label {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: Usage.known ? "обновлено " + Qt.formatTime(Usage.updated, "HH:mm") : "нет данных"
            color: Theme.textDim
            font.pixelSize: 13
            font.weight: Font.Medium
        }
    }

    Column {
        id: rail

        y: header.height + 10
        width: root.railWidth
        spacing: 8

        Repeater {
            model: root.rails

            UsageRail {
                required property var modelData

                width: rail.width
                title: modelData.title
                tint: modelData.tint
                chip: modelData.chip
                chipWarn: modelData.warn ?? false
                figure: modelData.figure
                unit: modelData.unit
                caption: modelData.caption
                segments: modelData.segments
                selected: root.selected === modelData.key
                onClicked: root.selected = modelData.key
            }
        }
    }

    Flickable {
        id: scroller

        x: root.railWidth + 12
        y: header.height + 10
        width: root.width - x
        height: root.bodyHeight
        contentHeight: detail.item ? detail.item.implicitHeight : 0
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick

        Loader {
            id: detail

            width: scroller.width
            sourceComponent: root.panels[root.selected] ?? sourcePanel
        }
    }

    Component {
        id: overviewPanel
        UsageOverview {}
    }

    Component {
        id: historyPanel
        UsageHistory {}
    }

    Component {
        id: sourcePanel
        UsageSource {
            source: root.selected
        }
    }
}
