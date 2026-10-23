import QtQuick
import qs.core
import qs.services
import qs.widgets

Column {
    id: root

    required property string picker
    readonly property bool present: true
    readonly property int notificationCount: Notifications.history.length
    readonly property string notificationApps: {
        const names = [];
        for (const item of Notifications.history)
            if (item.appName && names.indexOf(item.appName) < 0)
                names.push(item.appName);
        return names.slice(0, 2).join(", ");
    }
    readonly property string tilingLabel: ({ halves: "Strip", grid: "Grid", tabs: "Tabs", float: "Float" })[Tiling.preset] ?? "Tiling"

    signal pageRequested(string page)
    signal pickerToggled(string name)

    spacing: Tokens.spacingRelaxed

    Grid {
        columns: 2
        spacing: Tokens.spacingItem

        HomeTile {
            glyph: "󰌌"
            caption: Niri.layoutCode
            glyphColor: Theme.textDim
            captionColor: Theme.textDim
            onClicked: root.pickerToggled("layout")
        }

        HomeTile {
            glyph: Tiling.glyph
            caption: root.tilingLabel
            glyphColor: Tiling.preset !== "none" ? Theme.accent : Theme.textDim
            captionColor: Tiling.preset !== "none" ? Theme.text : Theme.textDim
            onClicked: root.pickerToggled("tiling")
        }

        HomeTile {
            glyph: Notifications.dnd ? "󰂛" : "󰂚"
            caption: "DND"
            glyphColor: Notifications.dnd ? Theme.accent : Theme.textDim
            captionColor: Notifications.dnd ? Theme.text : Theme.textDim
            onClicked: Notifications.dnd = !Notifications.dnd
        }

        HomeTile {
            glyph: "󰅶"
            caption: "Awake"
            glyphColor: KeepAwake.active ? Theme.accent : Theme.textDim
            captionColor: KeepAwake.active ? Theme.text : Theme.textDim
            onClicked: KeepAwake.toggle()
        }
    }

    HomeLink {
        glyph: root.notificationCount === 0 ? "󰂛" : "󰂚"
        title: root.notificationCount === 0 ? "Quiet" : root.notificationCount + " new"
        caption: root.notificationCount === 0 ? "No notifications" : root.notificationApps
        tint: root.notificationCount === 0 ? Theme.textDim : Theme.accent
        onClicked: root.pageRequested("notifications")
    }
}
