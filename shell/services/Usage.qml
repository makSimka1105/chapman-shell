pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property var cache: file.text() ? JSON.parse(file.text()) : ({})
    readonly property var sources: cache.sources ?? []
    readonly property var sourceIds: sources.map(item => item.id)
    readonly property var subscriptionIds: sources.filter(item => item.kind === "subscription").map(item => item.id)
    readonly property var keyIds: sources.filter(item => item.kind === "key").map(item => item.id)
    readonly property var tokenIds: sourceIds.filter(id => hasTokens(id))
    readonly property var windowDays: cache.window ?? []
    readonly property var months: cache.months ?? []
    readonly property date updated: new Date(cache.fetched_at ?? 0)
    readonly property bool known: cache.fetched_at !== undefined
    readonly property var windowSpans: ({
            five_hour: 5 * 3600000,
            seven_day: 7 * 86400000
        })
    readonly property real fiveHour: windowUsed("claude", "five_hour")
    readonly property real sevenDay: windowUsed("claude", "seven_day")
    readonly property date fiveHourReset: windowReset("claude", "five_hour")
    readonly property date sevenDayReset: windowReset("claude", "seven_day")
    readonly property real openRouterSpend: source("openrouter").live?.spend ?? 0
    readonly property real openRouterLimit: source("openrouter").live?.limit ?? 0
    readonly property real openRouterUsed: openRouterLimit > 0 ? openRouterSpend / openRouterLimit : 0
    readonly property real keySpend: keyIds.reduce((sum, id) => sum + (source(id).live?.spend ?? 0), 0)
    readonly property var limitWindows: subscriptionIds.reduce((all, id) => all.concat((source(id).live?.windows ?? []).filter(item => item.used !== null).map(item => ({
                    id: id,
                    window: item
                }))), [])
    readonly property var nearestWindow: limitWindows.reduce((best, item) => !best || new Date(item.window.resets_at) < new Date(best.window.resets_at) ? item : best, null)
    readonly property var tightWindow: limitWindows.reduce((best, item) => !best || item.window.used > best.window.used ? item : best, null)
    readonly property var statusTexts: ({
            "ok": "в норме",
            "out of budget": "бюджет исчерпан",
            "not logged in": "нет входа",
            "no usage endpoint": "без запроса лимита",
            "active, no spend data": "активен",
            "network error": "нет сети"
        })
    readonly property color inputColor: "#9ab8e8"
    readonly property color outputColor: "#f2a66b"
    readonly property var currentMonth: months.find(month => month.m === Qt.formatDate(new Date(), "yyyy-MM"))

    function untilText(moment) {
        const minutes = Math.max(0, Math.round((moment - new Date()) / 60000));
        if (minutes < 60)
            return minutes + "м";
        const hours = Math.floor(minutes / 60);
        if (hours < 48)
            return hours + "ч " + minutes % 60 + "м";
        return Math.floor(hours / 24) + "д " + hours % 24 + "ч";
    }

    function statusText(status) {
        return statusTexts[status] ?? status;
    }

    function statusWarn(status) {
        return !(status in statusTexts) || status === "out of budget" || status === "network error";
    }

    function source(id) {
        return sources.find(item => item.id === id) ?? ({});
    }

    function sourceName(id) {
        return source(id).name ?? id;
    }

    function sourceColor(id) {
        return source(id).color ?? "#ffffff";
    }

    function windowOf(id, windowId) {
        return (source(id).live?.windows ?? []).find(item => item.id === windowId) ?? ({});
    }

    function windowUsed(id, windowId) {
        return windowOf(id, windowId).used ?? 0;
    }

    function windowReset(id, windowId) {
        return new Date(windowOf(id, windowId).resets_at ?? 0);
    }

    function windowPace(windowId, reset) {
        const span = windowSpans[windowId];
        return 1 - Math.max(0, Math.min(span, reset - new Date())) / span;
    }

    function series(id, key) {
        return source(id).tokens?.daily?.[key] ?? [0, 0, 0, 0, 0, 0, 0];
    }

    function total(id, key) {
        return series(id, key).reduce((sum, value) => sum + value, 0);
    }

    function allTotal(key) {
        return sourceIds.reduce((sum, id) => sum + total(id, key), 0);
    }

    function tokenTotal(id) {
        return total(id, "i") + total(id, "o");
    }

    function modelRows(id) {
        const ids = id ? [id] : sourceIds;
        return ids.reduce((all, name) => all.concat((source(name).tokens?.models ?? []).map(row => Object.assign({
                    src: name
                }, row))), []).sort((a, b) => b.eq - a.eq);
    }

    function hours(id) {
        return source(id).tokens?.hourly ?? new Array(24).fill(0);
    }

    function monthValue(month, id, key) {
        if (!month)
            return 0;
        return id ? (month[id]?.[key] ?? 0) : sourceIds.reduce((sum, name) => sum + (month[name]?.[key] ?? 0), 0);
    }

    function monthLabel(month) {
        return ["янв", "фев", "мар", "апр", "май", "июн", "июл", "авг", "сен", "окт", "ноя", "дек"][parseInt(month.m.slice(5, 7)) - 1];
    }

    function tokensText(count) {
        if (count >= 1000000)
            return (count / 1000000).toFixed(count >= 10000000 ? 1 : 2) + "M";
        if (count >= 1000)
            return Math.round(count / 1000) + "k";
        return Math.round(count).toString();
    }

    function moneyText(value) {
        return "$" + value.toFixed(value < 10 ? 2 : value < 100 ? 1 : 0);
    }

    function priceText(value) {
        return "$" + parseFloat(value.toFixed(3));
    }

    function dayLabel(iso) {
        return ["Вс", "Пн", "Вт", "Ср", "Чт", "Пт", "Сб"][new Date(iso + "T12:00:00").getDay()];
    }

    function deltaText(value, base) {
        if (base <= 0)
            return "-";
        const percent = Math.round((value - base) / base * 100);
        return (percent >= 0 ? "+" : "") + percent + "%";
    }

    function hasTokens(id) {
        return tokenTotal(id) > 0;
    }

    function fullMonth(month) {
        return (month?.days ?? 0) >= 15;
    }

    function priceOf(fragment) {
        const row = modelRows("").find(item => item.model.includes(fragment));
        return row?.p ?? null;
    }

    function costAt(id, price) {
        return price ? (total(id, "i") * price[0] + total(id, "o") * price[1]) / 1e6 : 0;
    }

    FileView {
        id: file
        path: Quickshell.env("XDG_RUNTIME_DIR") + "/chapman-usage.json"
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()
    }
}
