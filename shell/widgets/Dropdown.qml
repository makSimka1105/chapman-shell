import QtQuick
import qs.core
import qs.services

Item {
    id: root

    property var options: []
    property string current
    property string label
    property string glyph
    property bool opened: false
    property point origin

    signal picked(string id)

    readonly property var chosen: options.find(option => option.id === current)
    readonly property string caption: label !== "" ? label : chosen?.label ?? ""
    readonly property bool compact: caption === ""
    readonly property real panelWidth: Math.max(width, Tokens.dropdownWidth)

    implicitWidth: compact ? Tokens.iconButtonSize : Tokens.dropdownWidth
    implicitHeight: Tokens.iconButtonSize
    opacity: enabled ? 1 : 0.3

    onOpenedChanged: {
        if (opened) {
            overlay.parent = Window.contentItem;
            origin = mapToItem(null, 0, 0);
            panel.x = Math.max(Tokens.spacingItem, Math.min(origin.x + width - panelWidth, overlay.width - panelWidth - Tokens.spacingItem));
            const below = origin.y + height + Tokens.spacingSnug;
            const flip = below + panel.height > overlay.height - Tokens.spacingItem;
            panel.y = flip ? origin.y - panel.height - Tokens.spacingSnug : below;
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: Tokens.radiusChip
        color: area.containsMouse || root.opened ? Qt.alpha(Theme.text, 0.12) : Qt.alpha(Theme.text, 0.05)
        scale: area.pressed ? 0.96 : 1

        Behavior on color {
            ColorAnimation {
                duration: Tokens.durationHover
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: Tokens.durationNormal
                easing.type: Easing.OutBack
                easing.overshoot: Tokens.overshootSnappy
            }
        }

        Glyph {
            anchors.left: parent.left
            anchors.leftMargin: root.compact ? 0 : Tokens.marginInner
            anchors.right: root.compact ? parent.right : undefined
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignHCenter
            visible: root.glyph !== ""
            text: root.glyph
            font.pixelSize: Tokens.fontMedium
        }

        Label {
            anchors.left: parent.left
            anchors.leftMargin: Tokens.marginInner + (root.glyph !== "" ? Tokens.fontIcon + Tokens.spacingSmall : 0)
            anchors.right: chevron.left
            anchors.rightMargin: Tokens.spacingSmall
            anchors.verticalCenter: parent.verticalCenter
            visible: !root.compact
            text: root.caption
            elide: Text.ElideRight
            font.pixelSize: Tokens.fontBody
        }

        Glyph {
            id: chevron
            anchors.right: parent.right
            anchors.rightMargin: Tokens.spacingRelaxed
            anchors.verticalCenter: parent.verticalCenter
            visible: !root.compact
            text: root.opened ? "󰅃" : "󰅀"
            font.pixelSize: Tokens.fontBody
            color: Theme.textDim
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.opened = !root.opened
    }

    Item {
        id: overlay
        anchors.fill: parent
        z: 1000
        visible: root.opened || panel.opacity > 0

        MouseArea {
            anchors.fill: parent
            enabled: root.opened
            onClicked: root.opened = false
        }

        Rectangle {
            id: panel
            width: root.panelWidth
            height: list.height + 2 * Tokens.spacingSnug
            radius: Tokens.radiusRow
            color: Qt.tint(Theme.body, Qt.alpha(Theme.text, 0.1))
            border.width: 1
            border.color: Theme.faint
            opacity: root.opened ? 1 : 0
            scale: root.opened ? 1 : 0.94
            transformOrigin: Item.Top

            Behavior on opacity {
                NumberAnimation {
                    duration: Tokens.durationFast
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: Tokens.durationNormal
                    easing.type: Easing.OutBack
                    easing.overshoot: Tokens.overshootSoft
                }
            }

            Column {
                id: list
                x: Tokens.spacingSnug
                y: Tokens.spacingSnug
                width: parent.width - 2 * Tokens.spacingSnug

                Repeater {
                    model: root.options

                    Rectangle {
                        id: entry

                        required property var modelData
                        readonly property bool selected: modelData.id === root.current

                        width: list.width
                        height: Tokens.dropdownRowHeight
                        radius: Tokens.radiusChip
                        color: entryArea.containsMouse ? Qt.alpha(Theme.text, 0.1) : selected ? Qt.alpha(Theme.accent, 0.18) : "transparent"

                        Glyph {
                            id: entryGlyph
                            x: Tokens.marginInner
                            anchors.verticalCenter: parent.verticalCenter
                            visible: text !== ""
                            text: entry.modelData.glyph ?? ""
                            font.pixelSize: Tokens.fontMedium
                            color: entry.selected ? Theme.accent : Theme.textDim
                        }

                        Label {
                            anchors.left: entryGlyph.visible ? entryGlyph.right : parent.left
                            anchors.leftMargin: entryGlyph.visible ? Tokens.spacingRelaxed : Tokens.marginInner
                            anchors.right: parent.right
                            anchors.rightMargin: Tokens.marginInner
                            anchors.verticalCenter: parent.verticalCenter
                            text: entry.modelData.label
                            elide: Text.ElideRight
                            font.pixelSize: Tokens.fontBody
                        }

                        MouseArea {
                            id: entryArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                root.opened = false;
                                root.picked(entry.modelData.id);
                            }
                        }
                    }
                }
            }
        }
    }
}
