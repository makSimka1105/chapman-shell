pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property var cache: file.text() ? JSON.parse(file.text()) : ({})
    readonly property var claude: cache.claude ?? {}
    readonly property var qwen: cache.qwen ?? []
    readonly property real fiveHour: (claude.five_hour?.utilization ?? 0) / 100
    readonly property real sevenDay: (claude.seven_day?.utilization ?? 0) / 100
    readonly property date fiveHourReset: new Date(claude.five_hour?.resets_at ?? 0)
    readonly property date sevenDayReset: new Date(claude.seven_day?.resets_at ?? 0)
    readonly property var openRouter: qwen.find(entry => entry.name === "openrouter") ?? {}
    readonly property var course: qwen.find(entry => entry.name === "course") ?? {}
    readonly property real openRouterSpend: openRouter.spend_usd ?? 0
    readonly property real openRouterLimit: openRouter.limit_usd ?? 0
    readonly property real openRouterUsed: openRouterLimit > 0 ? openRouterSpend / openRouterLimit : 0
    readonly property date openRouterReset: new Date(openRouter.resets_at ?? 0)
    readonly property real courseTokens: course.tokens_used ?? 0
    readonly property date updated: new Date(cache.fetched_at ?? 0)
    readonly property bool known: claude.five_hour !== undefined
    readonly property var tokens: cache.tokens ?? ({})
    readonly property var windowDays: tokens.window ?? []
    readonly property var months: tokens.months ?? []
    readonly property var sourceKeys: ["claude", "or", "course"]
    readonly property var sourceNames: ({
            claude: "Подписка Claude",
            or: "OpenRouter",
            course: "Ключ курса"
        })
    readonly property var sourceColors: ({
            claude: "#e3a15b",
            or: "#8fb4ff",
            course: "#7fd8b4"
        })
    readonly property color inputColor: "#9ab8e8"
    readonly property color outputColor: "#f2a66b"
    readonly property var currentMonth: months.find(month => month.m === Qt.formatDate(new Date(), "yyyy-MM"))
    readonly property real orSpendMonthly: currentMonth?.or?.eq ?? openRouter.spend_monthly_usd ?? 0
    readonly property real orSpendDaily: openRouter.spend_daily_usd ?? 0
    readonly property real orSpendWeekly: openRouter.spend_weekly_usd ?? 0

    function untilText(moment) {
        const minutes = Math.max(0, Math.round((moment - new Date()) / 60000));
        if (minutes < 60)
            return minutes + "м";
        const hours = Math.floor(minutes / 60);
        if (hours < 48)
            return hours + "ч " + minutes % 60 + "м";
        return Math.floor(hours / 24) + "д " + hours % 24 + "ч";
    }

    function series(source, key) {
        return tokens.daily?.[source]?.[key] ?? [0, 0, 0, 0, 0, 0, 0];
    }

    function total(source, key) {
        return series(source, key).reduce((sum, value) => sum + value, 0);
    }

    function tokenTotal(source) {
        return total(source, "i") + total(source, "o");
    }

    function modelRows(source) {
        return (tokens.models ?? []).filter(row => !source || row.src === source);
    }

    function hours(source) {
        return tokens.hourly?.[source] ?? new Array(24).fill(0);
    }

    function monthValue(month, source, key) {
        if (!month)
            return 0;
        return source ? (month[source]?.[key] ?? 0) : sourceKeys.reduce((sum, name) => sum + (month[name]?.[key] ?? 0), 0);
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

    function hasTokens(source) {
        return tokenTotal(source) > 0;
    }

    function fullMonth(month) {
        return (month?.days ?? 0) >= 15;
    }

    function priceOf(fragment) {
        const row = (tokens.models ?? []).find(item => item.model.includes(fragment));
        return row?.p ?? null;
    }

    function costAt(source, price) {
        return price ? (total(source, "i") * price[0] + total(source, "o") * price[1]) / 1e6 : 0;
    }

    function refresh() {
        if (!poll.running)
            poll.running = true;
    }

    Process {
        id: poll
        command: [Quickshell.env("HOME") + "/.local/bin/usage-poll"]
        environment: ({
                PATH: Quickshell.env("HOME") + "/.nix-profile/bin:/etc/profiles/per-user/" + Quickshell.env("USER") + "/bin:/run/wrappers/bin:/run/current-system/sw/bin"
            })
    }

    Timer {
        interval: 300000
        running: false
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    FileView {
        id: file
        path: Quickshell.env("XDG_RUNTIME_DIR") + "/notch-usage.json"
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()
    }
}
