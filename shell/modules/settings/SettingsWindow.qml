import QtQuick
import Quickshell
import qs.core
import qs.services
import qs.widgets

FloatingWindow {
    id: root

    property string currentKey: "appearance"
    readonly property var section: catalog.sections.find(candidate => candidate.key === currentKey) ?? catalog.sections[0]

    function toggle() {
        visible = !visible;
    }

    function open(key) {
        currentKey = key;
        visible = true;
    }

    title: "chapman-settings"
    implicitWidth: Tokens.settingsWidth
    implicitHeight: Tokens.settingsHeight
    color: Theme.body
    visible: false
    onVisibleChanged: if (visible) Display.refresh()

    SettingsCatalog {
        id: catalog
    }

    SettingsSidebar {
        id: sidebar
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: Tokens.marginPanel
        width: Tokens.settingsSidebarWidth - 2 * Tokens.marginPanel
        sections: catalog.sections
        current: root.currentKey
        onPicked: key => root.currentKey = key
    }

    Rectangle {
        anchors.left: sidebar.right
        anchors.leftMargin: Tokens.marginPanel
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 1
        color: Theme.faint
    }

    Flickable {
        id: scroller
        anchors.left: sidebar.right
        anchors.leftMargin: Tokens.marginPanel + 1
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        contentWidth: width
        contentHeight: page.height + Tokens.marginScreen
        boundsBehavior: Flickable.StopAtBounds
        clip: true

        Column {
            id: page
            x: (scroller.width - width) / 2
            width: Math.min(Tokens.settingsPageWidth, scroller.width - 2 * Tokens.marginField)
            spacing: Tokens.marginPanel

            SettingsHeader {
                width: parent.width
                section: root.section
            }

            Repeater {
                model: root.section.groups

                SettingsGroup {
                    required property var modelData

                    width: page.width
                    group: modelData
                }
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                topPadding: Tokens.marginScreen
                visible: !root.section.ready
                text: "Скоро"
                font.pixelSize: Tokens.fontLabel
                color: Theme.textDim
            }

            transform: Translate {
                id: slide
            }
        }

    }

    Connections {
        target: root

        function onCurrentKeyChanged() {
            scroller.contentY = 0;
            entrance.restart();
        }
    }

    ParallelAnimation {
        id: entrance

        NumberAnimation {
            target: page
            property: "opacity"
            from: 0
            to: 1
            duration: Tokens.durationSlow
        }

        NumberAnimation {
            target: slide
            property: "y"
            from: Tokens.marginField
            to: 0
            duration: Tokens.durationEntrance
            easing.type: Easing.OutBack
            easing.overshoot: Tokens.overshootSoft
        }
    }
}
