import QtQuick
import qs.core
import qs.services
import qs.widgets

Column {
    id: root

    property real input: 0
    property real output: 0
    property real cache: 0
    readonly property real sum: Math.max(1, input + output)

    spacing: Tokens.spacingSmall

    Row {
        width: parent.width
        height: Tokens.trackHeight
        spacing: Tokens.spacingHairline

        Rectangle {
            width: (root.width - 2) * root.input / root.sum
            height: parent.height
            radius: Tokens.radiusBar
            color: Usage.inputColor
        }

        Rectangle {
            width: (root.width - 2) * root.output / root.sum
            height: parent.height
            radius: Tokens.radiusBar
            color: Usage.outputColor
        }
    }

    Flow {
        width: parent.width
        spacing: Tokens.spacingLarge

        Label {
            text: "input " + Usage.tokensText(root.input) + " · " + Math.round(root.input / root.sum * 100) + "%"
            color: Theme.textDim
            font.pixelSize: Tokens.fontSmall
        }

        Label {
            text: "output " + Usage.tokensText(root.output) + " · " + Math.round(root.output / root.sum * 100) + "%"
            color: Theme.textDim
            font.pixelSize: Tokens.fontSmall
        }

        Label {
            visible: root.cache > 0
            text: "из input в кэше " + Usage.tokensText(root.cache)
            color: Theme.textDim
            font.pixelSize: Tokens.fontSmall
        }
    }
}
