import QtQuick
import qs.core
import qs.services
import qs.widgets

Item {
    id: root

    required property string picker
    readonly property var map: ({
            usage: usage,
            battery: battery,
            media: media,
            clock: clock,
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

            height: 80
        }
    }

    Component {
        id: clock

        HomeClock {
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
