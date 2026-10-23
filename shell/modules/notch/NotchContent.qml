import QtQuick
import qs.core
import qs.services
import qs.modules.control
import qs.modules.home
import qs.modules.spotlight
import qs.modules.themes

Item {
    id: content

    required property Item notch
    property alias control: control
    property alias themes: themes
    property alias searchView: searchView
    property alias homeView: homeView

    clip: true

    RestView {
        anchors.horizontalCenter: parent.horizontalCenter
        width: notch.restSize.width
        height: notch.restSize.height
        output: notch.output
        opacity: notch.mode === "rest" ? 1 : 0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: Tokens.durationHover
            }
        }
    }

    NotificationView {
        anchors.horizontalCenter: parent.horizontalCenter
        width: notch.notificationSize.width
        height: notch.notificationSize.height
        opacity: notch.mode === "notification" ? 1 : 0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: Tokens.durationNormal
                easing.type: Easing.InCubic
            }
        }
    }

    OsdView {
        anchors.horizontalCenter: parent.horizontalCenter
        width: notch.osdSize.width
        height: notch.osdSize.height
        opacity: notch.mode === "osd" ? 1 : 0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: Tokens.durationQuick
            }
        }
    }

    HomeView {
        id: homeView
        anchors.horizontalCenter: parent.horizontalCenter
        width: notch.homeSize.width
        height: notch.homeSize.height
        output: notch.output
        opacity: notch.mode === "home" ? 1 : 0
        visible: opacity > 0
        onPageRequested: page => notch.openControl(page)

        Behavior on opacity {
            NumberAnimation {
                duration: Tokens.durationNormal
                easing.type: Easing.InCubic
            }
        }
    }

    ControlView {
        id: control
        anchors.horizontalCenter: parent.horizontalCenter
        width: implicitWidth
        height: implicitHeight
        opacity: notch.mode === "control" ? 1 : 0
        visible: opacity > 0
        onClosed: notch.state = "home"

        Behavior on opacity {
            NumberAnimation {
                duration: Tokens.durationNormal
                easing.type: Easing.InCubic
            }
        }
    }

    ThemesView {
        id: themes
        anchors.horizontalCenter: parent.horizontalCenter
        width: implicitWidth
        height: implicitHeight
        opacity: notch.mode === "themes" ? 1 : 0
        visible: opacity > 0
        onClosed: notch.close()

        Behavior on opacity {
            NumberAnimation {
                duration: Tokens.durationNormal
                easing.type: Easing.InCubic
            }
        }
    }

    SearchView {
        id: searchView
        anchors.horizontalCenter: parent.horizontalCenter
        width: implicitWidth
        height: implicitHeight
        opacity: notch.mode === "search" ? 1 : 0
        visible: opacity > 0
        onClosed: notch.close()

        Behavior on opacity {
            NumberAnimation {
                duration: Tokens.durationNormal
                easing.type: Easing.InCubic
            }
        }
    }
}
