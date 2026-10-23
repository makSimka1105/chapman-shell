import QtQuick
import qs.core

Item {
    id: root

    required property string output
    readonly property var rest: IslandConfig.data.rest

    RestWidgets {
        id: restWidgets
        output: root.output
    }

    RestSlot {
        id: leftSlot
        anchors.left: parent.left
        anchors.leftMargin: Tokens.marginPanel
        anchors.verticalCenter: parent.verticalCenter
        zone: root.rest.left
        layout: root.rest.layout
        widgets: restWidgets
        available: (root.width - centerSlot.width) / 2 - Tokens.marginPanel - root.rest.layout.zoneGap
    }

    RestSlot {
        id: centerSlot
        anchors.centerIn: parent
        zone: root.rest.center
        layout: root.rest.layout
        widgets: restWidgets
    }

    RestSlot {
        anchors.right: parent.right
        anchors.rightMargin: Tokens.marginWide
        anchors.verticalCenter: parent.verticalCenter
        zone: root.rest.right
        layout: root.rest.layout
        widgets: restWidgets
        available: (root.width - centerSlot.width) / 2 - Tokens.marginWide - root.rest.layout.zoneGap
    }
}
