import QtQuick
import qs.core
import qs.services
import qs.widgets

Item {
    id: root

    property string selected: "all"
    readonly property real railWidth: 270
    readonly property real bodyHeight: 580
    readonly property var weekTotals: Usage.subscriptionIds.map(id => Usage.weekTokens(Usage.weeks(id)[Usage.weeks(id).length - 1]))
    readonly property real weekSum: weekTotals.reduce((sum, value) => sum + value, 0)
    readonly property real costSum: Math.max(0.000001, Usage.allTotal("eq"))
    readonly property var rails: [allRail].concat(Usage.sourceIds.map(id => sourceRail(id)), [historyRail])
    readonly property var allRail: ({
            key: "all",
            title: "Общая",
            tint: Theme.text,
            chip: Usage.tightWindow && Usage.tightWindow.window.used > 0.85 ? Usage.sourceName(Usage.tightWindow.id) + " " + Math.round(Usage.tightWindow.window.used * 100) + "%" : "в норме",
            warn: Usage.tightWindow !== null && Usage.tightWindow.window.used > 0.85,
            figure: Usage.moneyText(costSum),
            unit: "эквивалент, 7д",
            caption: "in " + Usage.tokensText(Usage.allTotal("i")) + " · out " + Usage.tokensText(Usage.allTotal("o")),
            segments: Usage.tokenIds.map(id => ({ ratio: Usage.total(id, "eq") / costSum, color: Usage.sourceColor(id) }))
        })
    readonly property var historyRail: ({
            key: "history",
            title: "История",
            tint: Theme.text,
            chip: "по неделям",
            figure: Usage.tokensText(weekSum),
            unit: "токенов, эта неделя лимита",
            caption: Usage.subscriptionIds.map((id, index) => Usage.sourceName(id) + " " + Usage.tokensText(weekTotals[index])).join(" · "),
            segments: Usage.subscriptionIds.map((id, index) => ({ ratio: weekTotals[index] / Math.max(1, weekSum), color: Usage.sourceColor(id) }))
        })

    function sourceRail(id) {
        const item = Usage.source(id);
        const tokenCaption = Usage.hasTokens(id) ? "in " + Usage.tokensText(Usage.total(id, "i")) + " · out " + Usage.tokensText(Usage.total(id, "o")) : "токенов за 7д нет";
        const rail = { key: id, title: item.name, tint: item.color, chip: Usage.statusText(item.status), warn: Usage.statusWarn(item.status), caption: tokenCaption };
        if (item.kind === "subscription")
            return Object.assign(rail, subscriptionRail(id, item));
        return Object.assign(rail, keyRail(id, item));
    }

    function subscriptionRail(id, item) {
        const windows = item.live.windows;
        if (windows.length === 0)
            return { figure: "-", unit: "лимиты недоступны", segments: [] };
        const tight = windows.some(entry => entry.used > 0.85);
        return {
            chip: tight ? "лимит почти исчерпан" : "сброс " + Usage.untilText(new Date(windows[0].resets_at)),
            warn: tight,
            figure: Math.round(windows[0].used * 100) + "%",
            unit: windows.slice(1).map(entry => Math.round(entry.used * 100) + "% " + entry.label).join(" · "),
            segments: [{ ratio: windows[0].used, color: item.color }]
        };
    }

    function keyRail(id, item) {
        const live = item.live;
        const peak = Math.max(1, ...Usage.series(id, "i"));
        const hasLimit = (live.limit ?? 0) > 0;
        return {
            figure: live.spend !== null ? Usage.moneyText(live.spend) : Usage.tokensText(Usage.tokenTotal(id)),
            unit: hasLimit ? "из " + Usage.moneyText(live.limit) : live.spend !== null ? "без лимита" : "токенов, 7д",
            segments: [{ ratio: hasLimit ? live.spend / live.limit : Usage.series(id, "i")[6] / peak, color: item.color }]
        };
    }

    readonly property var panels: ({
            all: overviewPanel,
            history: historyPanel
        })

    signal back

    implicitHeight: Tokens.pageHeaderHeight + 10 + bodyHeight

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
            font.pixelSize: Tokens.fontBody
            font.weight: Font.Medium
        }
    }

    Flickable {
        id: railScroller

        y: header.height + 10
        width: root.railWidth
        height: root.bodyHeight
        contentHeight: rail.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick

        Column {
            id: rail

            width: railScroller.width
            spacing: Tokens.spacingItem

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
            sourceComponent: root.panels[root.selected] ?? (Usage.source(root.selected).kind === "subscription" ? subscriptionPanel : keyPanel)
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
        id: subscriptionPanel
        UsageSubscriptionPage {
            source: root.selected
        }
    }

    Component {
        id: keyPanel
        UsageKeyPage {
            source: root.selected
        }
    }
}
