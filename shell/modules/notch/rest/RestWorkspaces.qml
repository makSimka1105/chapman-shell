import QtQuick
import qs.core
import qs.services
import qs.widgets

Item {
    id: root

    required property string output
    property string variant: "dots"
    readonly property bool present: true

    implicitWidth: variant === "numbers" ? numbers.width : dots.width
    implicitHeight: variant === "numbers" ? numbers.height : dots.height

    Workspaces {
        id: dots
        visible: root.variant !== "numbers"
        anchors.verticalCenter: parent.verticalCenter
        output: root.output
    }

    Row {
        id: numbers
        visible: root.variant === "numbers"
        anchors.verticalCenter: parent.verticalCenter
        spacing: Tokens.spacingItem

        Repeater {
            model: root.variant === "numbers" ? Niri.workspacesOn(root.output) : []

            Label {
                required property var modelData

                text: modelData.idx
                color: modelData.is_active ? Theme.accent : Niri.hasWindows(modelData.id) ? Qt.alpha(Theme.accent, 0.45) : Theme.faint
                font.pixelSize: Tokens.fontMedium
                font.weight: Font.DemiBold
            }
        }
    }
}
