pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property var cache: file.text() ? JSON.parse(file.text()) : ({})
    readonly property var subscriptions: cache.subscriptions ?? []
    readonly property var keys: cache.keys ?? []
    readonly property var claude: subscriptions.find(entry => entry.id === "claude") ?? {}
    readonly property var openRouter: keys.find(entry => entry.provider === "openrouter") ?? {}
    readonly property real fiveHour: (claude.five_hour?.used_percent ?? 0) / 100
    readonly property real sevenDay: (claude.weekly?.used_percent ?? 0) / 100
    readonly property real openRouterSpend: openRouter.spend ?? 0
    readonly property real openRouterUsed: (openRouter.limit ?? 0) > 0 ? openRouterSpend / openRouter.limit : 0
    readonly property date updated: new Date(cache.fetched_at ?? 0)
    readonly property bool known: cache.fetched_at !== undefined

    function untilText(moment) {
        const minutes = Math.max(0, Math.round((moment - new Date()) / 60000));
        if (minutes < 60)
            return minutes + "м";
        const hours = Math.floor(minutes / 60);
        if (hours < 48)
            return hours + "ч " + minutes % 60 + "м";
        return Math.floor(hours / 24) + "д " + hours % 24 + "ч";
    }

    function moneyText(value) {
        return "$" + value.toFixed(value < 10 ? 2 : value < 100 ? 1 : 0);
    }

    function windowNote(entry) {
        if (entry.used_percent === null || entry.used_percent === undefined)
            return "нет данных";
        return Math.round(entry.used_percent) + "% · сброс " + untilText(new Date(entry.resets_at));
    }

    FileView {
        id: file
        path: Quickshell.env("XDG_RUNTIME_DIR") + "/chapman-usage.json"
        blockLoading: true
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
    }
}
