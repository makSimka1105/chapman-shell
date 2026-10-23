import QtQuick
import qs.core
import qs.services

Item {
    id: root

    required property string output
    property string state: "rest"
    property bool pinned
    readonly property string mode: state === "control" || state === "themes" || state === "search" ? state : Notifications.current ? "notification" : Osd.active && state === "rest" ? "osd" : state

    readonly property int restWidth: typeof IslandConfig.data.rest.layout.width === "number" ? IslandConfig.data.rest.layout.width : IslandConfig.data.size.restWidth > 0 ? IslandConfig.data.size.restWidth : 340
    readonly property int restHeight: IslandConfig.data.size.restHeight > 0 ? IslandConfig.data.size.restHeight : 40
    readonly property size restSize: Qt.size(restWidth, restHeight)
    readonly property size homeSize: Qt.size(content.homeView.implicitWidth, content.homeView.implicitHeight)
    readonly property size notificationSize: Qt.size(480, 104)
    readonly property size osdSize: Qt.size(300, 56)
    readonly property real maxHeight: 700
    readonly property var sizes: ({
            rest: restSize,
            home: homeSize,
            notification: notificationSize,
            osd: osdSize
        })
    readonly property var radii: ({
            rest: 20,
            home: 36,
            notification: 30,
            osd: 24,
            control: 32,
            themes: 36,
            search: 36
        })
    readonly property size goal: mode === "control" ? Qt.size(content.control.implicitWidth, content.control.implicitHeight) : mode === "themes" ? Qt.size(content.themes.implicitWidth, content.themes.implicitHeight) : mode === "search" ? Qt.size(content.searchView.implicitWidth, content.searchView.implicitHeight) : sizes[mode]

    readonly property int morphDuration: Tokens.durationSlow
    readonly property bool hoverOpen: IslandConfig.data.behavior.hoverOpen
    property real radius: radii[mode]
    property real squash: 1
    property real detach: state === "search" ? 1 : 0
    readonly property real detachOffset: Math.max(0, detach) * Tokens.islandDetachGap
    readonly property real flare: mode === "rest" ? 9 : mode === "home" ? 26 : 18
    readonly property real swell: press.pressed ? 1 - 4 / Math.max(goal.width, goal.height) : hover.hovered ? 1 + 6 / Math.max(goal.width, goal.height) : 1

    function openControl(page) {
        closeDelay.stop();
        content.control.show(page);
        state = "control";
        content.control.forceActiveFocus();
    }

    function openThemes() {
        if (state === "themes") {
            close();
            return;
        }
        closeDelay.stop();
        content.themes.open();
        pinned = true;
        state = "themes";
    }

    function toggleSearch(query) {
        if (state === "search") {
            close();
            return;
        }
        closeDelay.stop();
        pinned = true;
        state = "search";
        content.searchView.open(query);
    }

    function close() {
        pinned = false;
        state = "rest";
    }

    width: goal.width
    height: goal.height
    onModeChanged: if (IslandConfig.data.motion.squash) squashAnimation.restart()

    Behavior on width {
        NumberAnimation {
            duration: root.morphDuration
            easing.type: Easing.OutBack
            easing.overshoot: Tokens.overshootMild
        }
    }

    Behavior on height {
        NumberAnimation {
            duration: root.morphDuration
            easing.type: Easing.OutBack
            easing.overshoot: Tokens.overshootMild
        }
    }

    Behavior on detach {
        NumberAnimation {
            duration: Tokens.durationMove
            easing.type: Easing.OutBack
            easing.overshoot: Tokens.overshootSoft
        }
    }

    Behavior on radius {
        NumberAnimation {
            duration: root.morphDuration
            easing.type: Easing.OutCubic
        }
    }

    SequentialAnimation {
        id: squashAnimation
        NumberAnimation {
            target: root
            property: "squash"
            to: 0.9
            duration: root.morphDuration / 3
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: root
            property: "squash"
            to: 1
            duration: root.morphDuration * 2 / 3
            easing.type: Easing.OutBack
            easing.overshoot: Tokens.overshootStrong
        }
    }

    Timer {
        id: notificationTimer
        running: root.mode === "notification" && !hover.hovered
        interval: Notifications.current ? Notifications.timeoutFor(Notifications.current) : 0
        onTriggered: Notifications.next()
    }

    Connections {
        target: Notifications
        function onCurrentChanged() {
            notificationTimer.restart();
        }
    }

    Timer {
        id: openDelay
        interval: IslandConfig.data.behavior.hoverDelay
        onTriggered: if (root.state === "rest") root.state = "home"
    }

    Timer {
        id: closeDelay
        interval: root.state === "control" || root.state === "themes" || root.state === "search" ? 700 : IslandConfig.data.behavior.closeDelay
        onTriggered: if (!root.pinned && !content.control.typing) root.state = "rest"
    }

    HoverHandler {
        id: hover
        onHoveredChanged: {
            if (hovered) {
                closeDelay.stop();
                if (root.hoverOpen)
                    openDelay.restart();
            } else {
                openDelay.stop();
                closeDelay.restart();
            }
        }
    }

    MouseArea {
        id: press
        anchors.fill: parent
        onClicked: {
            if (root.mode === "notification")
                Notifications.activate(Notifications.current);
            else if (root.mode === "home")
                root.pinned = !root.pinned;
            else if (root.mode === "rest")
                root.state = "home";
        }
    }

    NotchBody {
        id: visual
        anchors.fill: parent
        radius: root.radius
        baseFlare: root.flare
        detach: Math.min(1, Math.max(0, root.detach))
        squash: root.squash
        targetSwell: root.swell
    }

    NotchContent {
        id: content
        notch: root
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * root.squash * visual.swell
        height: parent.height * visual.swell
    }
}
