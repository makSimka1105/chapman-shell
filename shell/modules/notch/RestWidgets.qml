import QtQuick
import qs.modules.notch.rest

Item {
    id: root

    required property string output
    readonly property var map: ({
            workspaces: workspaces,
            equalizer: equalizer,
            clock: clock,
            layout: layout,
            bluetooth: bluetooth,
            wifi: wifi,
            battery: battery,
            notifications: notifications,
            media: media
        })

    function has(id) {
        return map[id] !== undefined;
    }

    function component(id) {
        return map[id];
    }

    Component {
        id: workspaces

        RestWorkspaces {
            output: root.output
        }
    }

    Component {
        id: equalizer

        RestEqualizer {}
    }

    Component {
        id: clock

        RestClock {}
    }

    Component {
        id: layout

        RestLayout {}
    }

    Component {
        id: bluetooth

        RestBluetooth {}
    }

    Component {
        id: wifi

        RestWifi {}
    }

    Component {
        id: battery

        RestBattery {}
    }

    Component {
        id: notifications

        RestNotifications {}
    }

    Component {
        id: media

        RestMedia {}
    }
}
