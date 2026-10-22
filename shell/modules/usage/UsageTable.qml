import QtQuick
import qs.core
import qs.services
import qs.widgets

Column {
    id: root

    property var rows: []
    property bool showSource: false
    readonly property real tokensColumnWidth: 76
    readonly property real priceColumnWidth: 150
    readonly property real equivalentColumnWidth: 74
    readonly property real sourceColumnWidth: 110
    readonly property real sourceWidth: showSource ? sourceColumnWidth : 0
    readonly property real nameWidth: width - sourceWidth - tokensColumnWidth * 2 - priceColumnWidth - equivalentColumnWidth

    spacing: 0

    component Cell: Label {
        font.pixelSize: Tokens.fontSmall
        elide: Text.ElideRight
    }

    Row {
        height: 22

        Cell { width: root.nameWidth; text: "МОДЕЛЬ"; color: Theme.textDim; font.pixelSize: Tokens.fontMicro; font.weight: Font.DemiBold }
        Cell { width: root.sourceWidth; visible: root.showSource; text: "ИСТОЧНИК"; color: Theme.textDim; font.pixelSize: Tokens.fontMicro; font.weight: Font.DemiBold }
        Cell { width: root.tokensColumnWidth; text: "INPUT"; horizontalAlignment: Text.AlignRight; color: Theme.textDim; font.pixelSize: Tokens.fontMicro; font.weight: Font.DemiBold }
        Cell { width: root.tokensColumnWidth; text: "OUTPUT"; horizontalAlignment: Text.AlignRight; color: Theme.textDim; font.pixelSize: Tokens.fontMicro; font.weight: Font.DemiBold }
        Cell { width: root.priceColumnWidth; text: "ЦЕНА IN / OUT, 1M"; horizontalAlignment: Text.AlignRight; color: Theme.textDim; font.pixelSize: Tokens.fontMicro; font.weight: Font.DemiBold }
        Cell { width: root.equivalentColumnWidth; text: "ЭКВИВАЛЕНТ"; horizontalAlignment: Text.AlignRight; color: Theme.textDim; font.pixelSize: Tokens.fontMicro; font.weight: Font.DemiBold }
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
                Cell { width: root.sourceWidth; visible: root.showSource; text: Usage.sourceName(line.modelData.src); color: Theme.textDim }
                Cell { width: root.tokensColumnWidth; text: Usage.tokensText(line.modelData.i); horizontalAlignment: Text.AlignRight }
                Cell { width: root.tokensColumnWidth; text: Usage.tokensText(line.modelData.o); horizontalAlignment: Text.AlignRight }

                Column {
                    width: root.priceColumnWidth

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
                        font.pixelSize: Tokens.fontCaption
                        horizontalAlignment: Text.AlignRight
                    }
                }

                Cell { width: root.equivalentColumnWidth; text: Usage.moneyText(line.modelData.eq); horizontalAlignment: Text.AlignRight; font.weight: Font.DemiBold }
            }
        }
    }
}
