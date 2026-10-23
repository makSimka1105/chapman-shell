import QtQuick
import qs.core
import qs.services
import qs.widgets

Item {
    id: root

    required property var sections
    property string current

    signal picked(string key)

    readonly property int currentIndex: sections.findIndex(section => section.key === current)

    Rectangle {
        y: root.currentIndex * (Tokens.sidebarItemHeight + Tokens.spacingSnug)
        width: parent.width
        height: Tokens.sidebarItemHeight
        radius: Tokens.radiusRow
        color: Qt.alpha(Theme.accent, 0.18)
        visible: root.currentIndex >= 0

        Behavior on y {
            NumberAnimation {
                duration: Tokens.durationMove
                easing.type: Easing.OutBack
                easing.overshoot: Tokens.overshootSoft
            }
        }
    }

    Column {
        width: parent.width
        spacing: Tokens.spacingSnug

        Repeater {
            model: root.sections

            Item {
                id: entry

                required property var modelData
                readonly property bool selected: modelData.key === root.current

                width: root.width
                height: Tokens.sidebarItemHeight
                scale: area.pressed ? 0.98 : 1

                Behavior on scale {
                    NumberAnimation {
                        duration: Tokens.durationNormal
                        easing.type: Easing.OutBack
                        easing.overshoot: Tokens.overshootSnappy
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: Tokens.radiusRow
                    color: Qt.alpha(Theme.text, 0.07)
                    opacity: area.containsMouse && !entry.selected ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Tokens.durationHover
                        }
                    }
                }

                Glyph {
                    id: icon
                    anchors.left: parent.left
                    anchors.leftMargin: Tokens.marginRow
                    anchors.verticalCenter: parent.verticalCenter
                    text: entry.modelData.glyph
                    color: entry.selected ? Theme.accent : Theme.textDim
                }

                Label {
                    anchors.left: icon.right
                    anchors.leftMargin: Tokens.spacingRelaxed
                    anchors.right: parent.right
                    anchors.rightMargin: Tokens.marginRow
                    anchors.verticalCenter: parent.verticalCenter
                    text: entry.modelData.title
                    elide: Text.ElideRight
                    font.pixelSize: Tokens.fontMedium
                    font.weight: entry.selected ? Font.DemiBold : Font.Normal
                    color: entry.selected ? Theme.text : Theme.textDim
                }

                MouseArea {
                    id: area
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.picked(entry.modelData.key)
                }
            }
        }
    }
}
