pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray as Tray

Singleton {
    id: root

    readonly property var item: Tray.SystemTray.items.values.find(entry => entry.id === "librepods") ?? null
    readonly property string line: item?.tooltipTitle ?? ""
    readonly property var match: /Left: (\d+)%.*Right: (\d+)%.*Case: (\d+)%/.exec(line)
    readonly property bool available: match !== null
    readonly property real left: match ? Number(match[1]) / 100 : 0
    readonly property real right: match ? Number(match[2]) / 100 : 0
    readonly property real box: match ? Number(match[3]) / 100 : 0
    readonly property bool inCase: box > 0
    readonly property bool leftCharging: inCase && left < 1
    readonly property bool rightCharging: inCase && right < 1
}
