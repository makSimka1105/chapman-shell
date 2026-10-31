pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

Singleton {
    id: root

    property var queue: []
    readonly property string stateDir: Quickshell.env("HOME") + "/.local/state/chapman-shell"
    property bool dnd: dndFlag.text().trim() === "1"
    readonly property var history: server.trackedNotifications.values
    readonly property var current: queue[0] ?? null

    function timeoutFor(notification) {
        if (notification.urgency === NotificationUrgency.Critical)
            return 5000;
        if (notification.urgency === NotificationUrgency.Low)
            return 1500;
        return 2500;
    }

    function toggleDnd() {
        dnd = !dnd;
        dndFlag.setText(dnd ? "1" : "");
    }

    function next() {
        queue = queue.slice(1);
    }

    function activate(notification) {
        notification.actions.find(a => a.identifier === "default")?.invoke();
        notification.dismiss();
    }

    function clear() {
        for (const item of history.slice())
            item.dismiss();
        queue = [];
    }

    function forget(notification) {
        queue = queue.filter(n => n && n !== notification);
    }

    NotificationServer {
        id: server
        keepOnReload: false
        bodySupported: true
        imageSupported: true
        actionsSupported: true
        persistenceSupported: true
        onNotification: notification => {
            notification.tracked = true;
            notification.closed.connect(() => root.forget(notification));
            if (!root.dnd || notification.urgency === NotificationUrgency.Critical)
                root.queue = [...root.queue, notification];
        }
    }

    FileView {
        id: dndFlag
        path: root.stateDir + "/dnd"
        blockLoading: true
        blockWrites: true
        printErrors: false
    }
}
