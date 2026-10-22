import QtQuick
import qs.core
import qs.services
import qs.widgets

Item {
    id: root

    property var labels: []
    property var series: []
    property var format: value => Math.round(value).toString()
    property real plotHeight: 96
    readonly property real axisWidth: 46
    readonly property var totals: labels.map((_, column) => series.reduce((sum, item) => sum + (item.values[column] ?? 0), 0))
    readonly property real highest: Math.max(0.000001, ...totals)
    readonly property real magnitude: Math.pow(10, Math.floor(Math.log10(highest)))
    readonly property real ceiling: Math.ceil(highest / magnitude) * magnitude
    readonly property real slot: (width - axisWidth) / Math.max(1, labels.length)

    function below(column, row) {
        let sum = 0;
        for (let k = 0; k < row; k++)
            sum += series[k].values[column] ?? 0;
        return sum;
    }

    implicitHeight: plotHeight + 20

    Repeater {
        model: [0, 0.5, 1]

        Item {
            id: gridLine

            required property real modelData

            width: root.width
            y: root.plotHeight * (1 - modelData)

            Rectangle {
                x: root.axisWidth
                width: parent.width - root.axisWidth
                height: 1
                color: Theme.faint
            }

            Label {
                y: -height / 2
                text: root.format(root.ceiling * gridLine.modelData)
                color: Theme.textDim
                font.pixelSize: Tokens.fontMicro
            }
        }
    }

    Repeater {
        model: root.labels.length

        Item {
            id: column

            required property int index

            x: root.axisWidth + index * root.slot
            width: root.slot
            height: root.plotHeight

            Repeater {
                model: root.series.length

                Rectangle {
                    required property int index

                    readonly property real size: (root.series[index].values[column.index] ?? 0) / root.ceiling * root.plotHeight

                    x: 5
                    width: column.width - 10
                    height: size > 0 ? Math.max(2, size - 1) : 0
                    y: root.plotHeight - (root.below(column.index, index) / root.ceiling * root.plotHeight) - size
                    radius: Tokens.radiusThin
                    color: root.series[index].color
                    opacity: column.index === root.labels.length - 1 ? 1 : 0.6
                }
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                y: root.plotHeight + 4
                text: root.labels[column.index]
                color: Theme.textDim
                font.pixelSize: Tokens.fontMicro
            }
        }
    }
}
