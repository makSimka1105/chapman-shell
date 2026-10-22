import QtQuick
import qs.core
import qs.services
import qs.widgets

Item {
    id: root

    signal clicked

    width: usageColumn.width
    height: usageColumn.height

    Column {
        id: usageColumn
        spacing: Tokens.spacingMid

        Repeater {
            model: [
                { label: "5h", value: Usage.fiveHour, text: Math.round(Usage.fiveHour * 100) + "%" },
                { label: "7d", value: Usage.sevenDay, text: Math.round(Usage.sevenDay * 100) + "%" },
                { label: "OR", value: Usage.openRouterUsed, text: Usage.moneyText(Usage.openRouterSpend) }
            ]

            Row {
                required property var modelData

                spacing: Tokens.spacingItem

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 22
                    text: parent.modelData.label
                    color: Theme.textDim
                    font.pixelSize: Tokens.fontSmall
                    font.weight: Font.DemiBold
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 110
                    height: 6
                    radius: Tokens.radiusThin
                    color: Theme.faint

                    Rectangle {
                        width: Usage.known ? Math.max(parent.height, parent.width * Math.min(1, parent.parent.modelData.value)) : 0
                        height: parent.height
                        radius: Tokens.radiusThin
                        color: parent.parent.modelData.value > 0.85 ? Theme.warning : Theme.accent

                        Behavior on width {
                            NumberAnimation {
                                duration: Tokens.durationLong
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Usage.known ? parent.modelData.text : "-"
                    font.pixelSize: Tokens.fontSmall
                    font.weight: Font.DemiBold
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        anchors.margins: -8
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
