import QtQuick
import qs.services
import qs.widgets

Item {
    id: root

    required property var modelData
    required property int index
    required property real rowHeight
    required property real headerHeight
    required property bool armed
    required property bool animateIn
    property real arrival: 1

    signal hovered
    signal clicked

    height: modelData.header ? headerHeight : rowHeight
    opacity: Math.min(1, arrival * 1.6)
    transform: Translate {
        y: (1 - root.arrival) * 16
    }
    Component.onCompleted: {
        if (animateIn) {
            arrival = 0;
            arrive.start();
        }
    }

    SequentialAnimation {
        id: arrive
        PauseAnimation {
            duration: Math.min(220, root.index * 40)
        }
        NumberAnimation {
            target: root
            property: "arrival"
            to: 1
            duration: 460
            easing.type: Easing.OutBack
            easing.overshoot: 1.8
        }
    }

    Label {
        anchors.left: parent.left
        anchors.leftMargin: 14
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 6
        visible: root.modelData.header === true
        text: root.modelData.title
        color: Theme.textDim
        font.pixelSize: 12
        font.weight: Font.DemiBold
    }

    Item {
        anchors.fill: parent
        visible: !root.modelData.header
        scale: rowPress.pressed ? 0.97 : 1

        Behavior on scale {
            NumberAnimation {
                duration: 230
                easing.type: Easing.OutBack
                easing.overshoot: 3
            }
        }

        ResultIcon {
            id: icon
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            width: 32
            height: 32
            item: root.modelData
        }

        Label {
            id: name
            anchors.left: icon.right
            anchors.leftMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(implicitWidth, parent.width * 0.5)
            text: root.modelData.title
            elide: Text.ElideRight
            font.pixelSize: 16
            font.weight: Font.Medium
        }

        Label {
            anchors.left: name.right
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 14
            anchors.baseline: name.baseline
            text: root.armed ? "Press Enter again to confirm" : root.modelData.subtitle ?? ""
            color: root.armed ? Theme.warning : Theme.textDim
            elide: Text.ElideRight
            font.pixelSize: 13
        }

        MouseArea {
            id: rowPress
            anchors.fill: parent
            hoverEnabled: true
            onEntered: root.hovered()
            onClicked: root.clicked()
        }
    }
}
