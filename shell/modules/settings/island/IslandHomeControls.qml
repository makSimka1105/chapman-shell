import QtQuick
import qs.core
import qs.services
import qs.widgets

Rectangle {
    id: root

    required property var grid
    required property int minColumns
    readonly property bool fixedWidth: grid.width !== "fit"
    readonly property var justifyOptions: [
        { id: "start", label: "Начало" },
        { id: "center", label: "Центр" },
        { id: "between", label: "Между" },
        { id: "evenly", label: "Поровну" }
    ]

    implicitHeight: rows.height + 2 * Tokens.marginRow
    radius: Tokens.radiusCard
    color: Theme.card

    component SliderRow: Item {
        id: sliderRow

        property string title
        property real value
        property real from: 0
        property real to: 40
        property real step: 1
        property string suffix: ""

        signal moved(real value)

        width: rows.width
        height: Tokens.segmentHeight + 2 * Tokens.spacingSnug

        Label {
            anchors.verticalCenter: parent.verticalCenter
            text: sliderRow.title
            font.pixelSize: Tokens.fontBody
        }

        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: Tokens.spacingMedium

            Slider {
                width: Tokens.settingsControlWidth
                anchors.verticalCenter: parent.verticalCenter
                value: (sliderRow.value - sliderRow.from) / (sliderRow.to - sliderRow.from)
                onMoved: fraction => sliderRow.moved(Math.round((sliderRow.from + fraction * (sliderRow.to - sliderRow.from)) / sliderRow.step) * sliderRow.step)
            }

            Label {
                width: Tokens.settingsValueWidth
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignRight
                text: sliderRow.value + sliderRow.suffix
                font.pixelSize: Tokens.fontBody
                color: Theme.textDim
            }
        }
    }

    Column {
        id: rows
        x: Tokens.marginRow
        y: Tokens.marginRow
        width: parent.width - 2 * Tokens.marginRow
        spacing: Tokens.spacingMedium

        SliderRow {
            title: "Колонки"
            value: root.grid.columns
            from: 1
            to: 10
            onMoved: value => IslandConfig.set("home.grid.columns", Math.max(value, root.minColumns))
        }

        SliderRow {
            title: "Зазор колонок"
            value: root.grid.gap
            suffix: " px"
            onMoved: value => IslandConfig.set("home.grid.gap", value)
        }

        SliderRow {
            title: "Зазор строк"
            value: root.grid.rowGap
            suffix: " px"
            onMoved: value => IslandConfig.set("home.grid.rowGap", value)
        }

        Item {
            width: rows.width
            height: Tokens.segmentHeight + 2 * Tokens.spacingSnug

            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: "Ширина"
                font.pixelSize: Tokens.fontBody
            }

            SegmentedControl {
                anchors.right: parent.right
                options: [{ id: "fit", label: "По содержимому" }, { id: "fixed", label: "Фиксированная" }]
                current: root.fixedWidth ? "fixed" : "fit"
                onPicked: id => IslandConfig.set("home.grid.width", id === "fit" ? "fit" : 1200)
            }
        }

        SliderRow {
            visible: root.fixedWidth
            title: "Ширина в px"
            value: root.fixedWidth ? root.grid.width : 0
            from: 600
            to: 2000
            step: 20
            suffix: " px"
            onMoved: value => IslandConfig.set("home.grid.width", value)
        }

        Item {
            width: rows.width
            height: Tokens.segmentHeight + 2 * Tokens.spacingSnug

            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: "Колонки по ширине"
                font.pixelSize: Tokens.fontBody
            }

            SegmentedControl {
                anchors.right: parent.right
                options: root.justifyOptions
                current: root.grid.justify
                onPicked: id => IslandConfig.set("home.grid.justify", id)
            }
        }
    }
}
