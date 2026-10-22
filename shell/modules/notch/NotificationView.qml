import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import qs.services
import qs.widgets

Item {
    id: root

    property var notification: Notifications.current
    readonly property bool critical: notification?.urgency === NotificationUrgency.Critical
    readonly property string iconSource: {
        if (!notification)
            return "";
        if (notification.image)
            return notification.image;
        return notification.appIcon ? Quickshell.iconPath(notification.appIcon, true) : "";
    }

    ClippingRectangle {
        id: icon
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        width: 46
        height: 46
        radius: 12
        color: root.critical ? Theme.warning : Theme.accent

        Label {
            anchors.centerIn: parent
            visible: image.status !== Image.Ready
            text: (root.notification?.appName || root.notification?.summary || "?").charAt(0).toUpperCase()
            color: "black"
            font.pixelSize: 20
            font.weight: Font.Bold
        }

        Image {
            id: image
            anchors.fill: parent
            source: root.iconSource
            fillMode: Image.PreserveAspectCrop
            sourceSize: Qt.size(width * 2, height * 2)
        }
    }

    Column {
        anchors.left: icon.right
        anchors.leftMargin: 14
        anchors.right: parent.right
        anchors.rightMargin: 22
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        Label {
            width: parent.width
            text: root.notification?.appName ?? ""
            visible: text !== ""
            color: root.critical ? Theme.warning : Theme.textDim
            elide: Text.ElideRight
            font.pixelSize: 12
        }

        Label {
            width: parent.width
            text: root.notification?.summary ?? ""
            textFormat: Text.PlainText
            elide: Text.ElideRight
            font.pixelSize: 15
            font.weight: Font.DemiBold
        }

        Label {
            width: parent.width
            text: root.notification?.body ?? ""
            visible: text !== ""
            textFormat: Text.PlainText
            color: Theme.textDim
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
            font.pixelSize: 13
        }
    }
}
