import QtQuick
import qs.services
import qs.widgets

Column {
    id: root

    property var rows: []
    property bool showSource: false
    readonly property real sourceWidth: showSource ? 110 : 0
    readonly property real nameWidth: width - sourceWidth - 76 * 2 - 150 - 74

    spacing: 0

    component Cell: Label {
        font.pixelSize: 12
        elide: Text.ElideRight
    }

    Row {
        height: 22

        Cell { width: root.nameWidth; text: "МОДЕЛЬ"; color: Theme.textDim; font.pixelSize: 10; font.weight: Font.DemiBold }
        Cell { width: root.sourceWidth; visible: root.showSource; text: "ИСТОЧНИК"; color: Theme.textDim; font.pixelSize: 10; font.weight: Font.DemiBold }
        Cell { width: 76; text: "INPUT"; horizontalAlignment: Text.AlignRight; color: Theme.textDim; font.pixelSize: 10; font.weight: Font.DemiBold }
        Cell { width: 76; text: "OUTPUT"; horizontalAlignment: Text.AlignRight; color: Theme.textDim; font.pixelSize: 10; font.weight: Font.DemiBold }
        Cell { width: 150; text: "ЦЕНА IN / OUT, 1M"; horizontalAlignment: Text.AlignRight; color: Theme.textDim; font.pixelSize: 10; font.weight: Font.DemiBold }
        Cell { width: 74; text: "ЭКВИВАЛЕНТ"; horizontalAlignment: Text.AlignRight; color: Theme.textDim; font.pixelSize: 10; font.weight: Font.DemiBold }
    }

    Repeater {
        model: root.rows

        Item {
            id: line

            required property var modelData
            readonly property bool cached: (modelData.p?.length ?? 0) === 4

            width: root.width
            height: cached ? 40 : 28

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.faint
            }

            Row {
                anchors.verticalCenter: parent.verticalCenter

                Cell { width: root.nameWidth; text: line.modelData.model }
                Cell { width: root.sourceWidth; visible: root.showSource; text: Usage.sourceNames[line.modelData.src]; color: Theme.textDim }
                Cell { width: 76; text: Usage.tokensText(line.modelData.i); horizontalAlignment: Text.AlignRight }
                Cell { width: 76; text: Usage.tokensText(line.modelData.o); horizontalAlignment: Text.AlignRight }

                Column {
                    width: 150

                    Cell {
                        width: parent.width
                        text: line.modelData.p ? Usage.priceText(line.modelData.p[0]) + " / " + Usage.priceText(line.modelData.p[1]) : "нет цены"
                        horizontalAlignment: Text.AlignRight
                    }

                    Cell {
                        width: parent.width
                        visible: line.cached
                        text: line.cached ? "кэш " + Usage.priceText(line.modelData.p[2]) + " / " + Usage.priceText(line.modelData.p[3]) : ""
                        color: Theme.textDim
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignRight
                    }
                }

                Cell { width: 74; text: Usage.moneyText(line.modelData.eq); horizontalAlignment: Text.AlignRight; font.weight: Font.DemiBold }
            }
        }
    }
}
