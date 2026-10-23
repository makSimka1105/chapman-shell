import QtQuick
import Quickshell
import qs.core
import qs.services
import qs.widgets

Item {
    id: root

    required property string output
    required property string picker
    readonly property var map: ({
            focus: focusEntry,
            workspaces: workspaces,
            usage: usage,
            battery: battery,
            media: media,
            clock: clock,
            calendar: calendar,
            links: links,
            tiles: tiles
        })

    signal pageRequested(string page)
    signal pickerToggled(string name)

    function has(id) {
        return map[id] !== undefined;
    }

    function component(id) {
        return map[id];
    }

    Component {
        id: focusEntry

        HomeFocus {
            readonly property bool present: true
            readonly property var app: Niri.focusedWindow ? DesktopEntries.heuristicLookup(Niri.focusedWindow.app_id) : null

            title: app?.name ?? Niri.focusedWindow?.app_id ?? "Desktop"
        }
    }

    Component {
        id: workspaces

        Workspaces {
            readonly property bool present: true

            output: root.output
            capsuleWidth: 10
            capsuleHeight: 18
            activeHeight: 24
        }
    }

    Component {
        id: usage

        HomeUsage {
            readonly property bool present: true

            onClicked: root.pageRequested("usage")
        }
    }

    Component {
        id: battery

        BatteryCard {
            readonly property bool present: true
        }
    }

    Component {
        id: media

        MediaCard {
            readonly property bool present: Media.active

            height: 64
        }
    }

    Component {
        id: clock

        HomeClock {
            readonly property bool present: true
        }
    }

    Component {
        id: calendar

        Calendar {
            readonly property bool present: true
        }
    }

    Component {
        id: links

        HomeLinks {
            onPageRequested: page => root.pageRequested(page)
        }
    }

    Component {
        id: tiles

        HomeTiles {
            picker: root.picker
            onPageRequested: page => root.pageRequested(page)
            onPickerToggled: name => root.pickerToggled(name)
        }
    }
}
