import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import qs.services

Item {
    id: root

    required property string output
    property string state: "rest"
    property bool pinned
    readonly property string mode: state === "control" ? "control" : Notifications.current ? "notification" : Osd.active && state === "rest" ? "osd" : state

    readonly property size restSize: Qt.size(340, 40)
    readonly property size homeSize: Qt.size(1400, 240)
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
            control: 32
        })
    readonly property size goal: mode === "control" ? Qt.size(control.implicitWidth, control.implicitHeight) : sizes[mode]

    readonly property int morphDuration: 300
    property real radius: radii[mode]
    property real squash: 1
    readonly property real flare: mode === "rest" ? 9 : mode === "home" ? 26 : 18
    readonly property real swell: press.pressed ? 1 - 4 / Math.max(goal.width, goal.height) : hover.hovered ? 1 + 6 / Math.max(goal.width, goal.height) : 1

    function openControl(page) {
        closeDelay.stop();
        control.show(page);
        state = "control";
        control.forceActiveFocus();
    }

    function close() {
        pinned = false;
        state = "rest";
    }

    width: goal.width
    height: goal.height
    onModeChanged: squashAnimation.restart()

    Behavior on width {
        NumberAnimation {
            duration: root.morphDuration
            easing.type: Easing.OutBack
            easing.overshoot: 1
        }
    }

    Behavior on height {
        NumberAnimation {
            duration: root.morphDuration
            easing.type: Easing.OutBack
            easing.overshoot: 1
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
            easing.overshoot: 1.5
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
        interval: 120
        onTriggered: if (root.state === "rest") root.state = "home"
    }

    Timer {
        id: closeDelay
        interval: root.state === "control" ? 700 : 280
        onTriggered: if (!root.pinned && !control.typing) root.state = "rest"
    }

    HoverHandler {
        id: hover
        onHoveredChanged: {
            if (hovered) {
                closeDelay.stop();
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

    Item {
        id: visual

        property real swell: root.swell

        anchors.fill: parent

        Behavior on swell {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutBack
                easing.overshoot: 1
            }
        }

        transform: Scale {
            origin.x: visual.width / 2
            origin.y: 0
            xScale: visual.swell * root.squash
            yScale: visual.swell
        }

        RectangularShadow {
            anchors.fill: body
            radius: root.radius
            blur: 28
            spread: 2
            offset.y: 6
            color: Qt.alpha("black", 0.45)
        }

        Rectangle {
            id: body
            anchors.fill: parent
            color: Theme.body
            topLeftRadius: 0
            topRightRadius: 0
            bottomLeftRadius: root.radius
            bottomRightRadius: root.radius
        }

        Shape {
            x: -root.flare
            width: root.flare
            height: root.flare
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                fillColor: Theme.body
                strokeColor: "transparent"
                startX: 0
                startY: 0
                PathLine { x: root.flare; y: 0 }
                PathLine { x: root.flare; y: root.flare }
                PathArc {
                    x: 0
                    y: 0
                    radiusX: root.flare
                    radiusY: root.flare
                    direction: PathArc.Counterclockwise
                }
            }
        }

        Shape {
            x: body.width
            width: root.flare
            height: root.flare
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                fillColor: Theme.body
                strokeColor: "transparent"
                startX: 0
                startY: 0
                PathLine { x: root.flare; y: 0 }
                PathArc {
                    x: 0
                    y: root.flare
                    radiusX: root.flare
                    radiusY: root.flare
                    direction: PathArc.Counterclockwise
                }
            }
        }
    }

    Item {
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * root.squash * visual.swell
        height: parent.height * visual.swell
        clip: true

        RestView {
            anchors.horizontalCenter: parent.horizontalCenter
            width: root.restSize.width
            height: root.restSize.height
            output: root.output
            opacity: root.mode === "rest" ? 1 : 0
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 120
                }
            }
        }

        NotificationView {
            anchors.horizontalCenter: parent.horizontalCenter
            width: root.notificationSize.width
            height: root.notificationSize.height
            opacity: root.mode === "notification" ? 1 : 0
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.InCubic
                }
            }
        }

        OsdView {
            anchors.horizontalCenter: parent.horizontalCenter
            width: root.osdSize.width
            height: root.osdSize.height
            opacity: root.mode === "osd" ? 1 : 0
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }
            }
        }

        HomeView {
            anchors.horizontalCenter: parent.horizontalCenter
            width: root.homeSize.width
            height: root.homeSize.height
            output: root.output
            opacity: root.mode === "home" ? 1 : 0
            visible: opacity > 0
            onPageRequested: page => root.openControl(page)

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.InCubic
                }
            }
        }

        ControlView {
            id: control
            anchors.horizontalCenter: parent.horizontalCenter
            width: implicitWidth
            height: implicitHeight
            opacity: root.mode === "control" ? 1 : 0
            visible: opacity > 0
            onClosed: root.state = "home"

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.InCubic
                }
            }
        }
    }
}
