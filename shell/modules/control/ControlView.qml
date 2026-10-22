import QtQuick
import qs.services
import qs.modules.usage

FocusScope {
    id: root

    property string page
    readonly property real side: 22
    readonly property real topPadding: 12
    readonly property real bottomPadding: 16
    readonly property real pageWidth: page === "usage" ? 1120 : 600
    readonly property bool typing: (sub.item?.asking ?? null) !== null
    readonly property var pages: ({
            wifi: wifiPage,
            bluetooth: bluetoothPage,
            usage: usagePage,
            notifications: notificationsPage,
            keyboard: keyboardPage
        })

    signal closed

    function show(name) {
        if (name in pages)
            page = name;
        else
            closed();
    }

    implicitWidth: pageWidth + 2 * side
    implicitHeight: topPadding + bottomPadding + (sub.item?.implicitHeight ?? 0)
    Keys.onEscapePressed: closed()

    Loader {
        id: sub

        x: root.side
        y: root.topPadding
        width: root.pageWidth
        sourceComponent: root.pages[root.page] ?? null
    }

    Connections {
        target: sub.item
        ignoreUnknownSignals: true

        function onBack() {
            root.closed();
        }
    }

    Component {
        id: wifiPage
        WifiPage {
            width: root.pageWidth
        }
    }

    Component {
        id: bluetoothPage
        BluetoothPage {
            width: root.pageWidth
        }
    }

    Component {
        id: usagePage
        UsagePage {
            width: root.pageWidth
        }
    }

    Component {
        id: notificationsPage
        NotificationsPage {
            width: root.pageWidth
        }
    }

    Component {
        id: keyboardPage
        KeyboardPage {
            width: root.pageWidth
        }
    }
}
