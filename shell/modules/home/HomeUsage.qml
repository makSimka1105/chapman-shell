import QtQuick
import qs.core
import qs.services
import qs.widgets

Item {
    id: root

    signal clicked

    readonly property int cellWidth: 64
    readonly property int cellHeight: 36

    width: usageGrid.width
    height: usageGrid.height

    Grid {
        id: usageGrid
        columns: 3
        rowSpacing: Tokens.spacingRelaxed
        columnSpacing: Tokens.spacingMedium

        Repeater {
            model: [
                { id: "claude", label: "CL 5ч", window: "five_hour" },
                { id: "codex", label: "CX 5ч", window: "five_hour" },
                { id: "openrouter", label: "OR" },
                { id: "claude", label: "CL 7д", window: "seven_day" },
                { id: "codex", label: "CX 7д", window: "seven_day" },
                { id: "" }
            ]

            Item {
                id: cell

                required property var modelData
                readonly property bool spare: modelData.id === ""
                readonly property bool money: modelData.window === undefined
                readonly property real used: money ? Usage.openRouterUsed : Usage.windowUsed(modelData.id, modelData.window)
                readonly property string valueText: money ? Usage.moneyText(Usage.openRouterSpend) : Math.round(used * 100) + "%"
                readonly property string footText: money ? "из " + Usage.moneyText(Usage.openRouterLimit) : Usage.untilText(Usage.windowReset(modelData.id, modelData.window))

                width: root.cellWidth
                height: root.cellHeight

                Rectangle {
                    visible: cell.spare
                    anchors.fill: parent
                    radius: Tokens.radiusChip
                    color: "transparent"
                    border.color: Theme.faint
                    border.width: 1.5

                    Label {
                        anchors.centerIn: parent
                        text: "+"
                        color: Theme.faint
                        font.pixelSize: Tokens.fontSubtitle
                    }
                }

                Column {
                    visible: !cell.spare
                    width: parent.width
                    spacing: Tokens.spacingCompact

                    Item {
                        width: parent.width
                        height: valueLabel.height

                        Label {
                            anchors.baseline: valueLabel.baseline
                            text: cell.modelData.label ?? ""
                            color: Theme.textDim
                            font.pixelSize: Tokens.fontMicro
                            font.weight: Font.DemiBold
                        }

                        Label {
                            id: valueLabel
                            anchors.right: parent.right
                            text: Usage.known ? cell.valueText : "-"
                            font.pixelSize: Tokens.fontBody
                            font.weight: Font.DemiBold
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 5
                        radius: height / 2
                        color: Theme.faint

                        Rectangle {
                            width: Usage.known ? Math.max(parent.height, parent.width * Math.min(1, cell.used)) : 0
                            height: parent.height
                            radius: height / 2
                            color: cell.used > 0.85 ? Theme.warning : Usage.sourceColor(cell.modelData.id)

                            Behavior on width {
                                NumberAnimation {
                                    duration: Tokens.durationLong
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }

                    Label {
                        text: Usage.known ? cell.footText : ""
                        color: Theme.textDim
                        font.pixelSize: Tokens.fontMicro
                    }
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
