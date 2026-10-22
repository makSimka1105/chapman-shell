import QtQuick
import qs.services

Column {
    id: root

    property real input: 0
    property real output: 0
    property real cache: 0
    readonly property real sum: Math.max(1, input + output)

    spacing: 6

    Row {
        width: parent.width
        height: 8
        spacing: 2

        Rectangle {
            width: (root.width - 2) * root.input / root.sum
            height: parent.height
            radius: 4
            color: Usage.inputColor
        }

        Rectangle {
            width: (root.width - 2) * root.output / root.sum
            height: parent.height
            radius: 4
            color: Usage.outputColor
        }
    }

    Flow {
        width: parent.width
        spacing: 14

        Label {
            text: "input " + Usage.tokensText(root.input) + " · " + Math.round(root.input / root.sum * 100) + "%"
            color: Theme.textDim
            font.pixelSize: 12
        }

        Label {
            text: "output " + Usage.tokensText(root.output) + " · " + Math.round(root.output / root.sum * 100) + "%"
            color: Theme.textDim
            font.pixelSize: 12
        }

        Label {
            visible: root.cache > 0
            text: "из input в кэше " + Usage.tokensText(root.cache)
            color: Theme.textDim
            font.pixelSize: 12
        }
    }
}
