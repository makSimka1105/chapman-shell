import QtQuick
import qs.core
import qs.services
import qs.widgets

Item {
    id: root

    required property var row
    readonly property bool stacked: row.type === "choice" || row.type === "themes" || row.type === "wallpapers"

    readonly property real sliderMin: row.min ?? 0
    readonly property real sliderMax: row.max ?? 1

    function sliderValue(fraction) {
        const raw = sliderMin + fraction * (sliderMax - sliderMin);
        return row.step ? Number((Math.round(raw / row.step) * row.step).toFixed(3)) : raw;
    }

    implicitHeight: stacked ? stack.implicitHeight + 2 * Tokens.marginRow : Tokens.settingsRowHeight

    Column {
        anchors.left: parent.left
        anchors.leftMargin: Tokens.marginRow
        anchors.verticalCenter: root.stacked ? undefined : parent.verticalCenter
        visible: !root.stacked
        spacing: Tokens.spacingHairline

        Label {
            text: root.row.title ?? ""
            font.pixelSize: Tokens.fontMedium
        }

        Label {
            text: root.row.subtitle ?? ""
            visible: text !== ""
            font.pixelSize: Tokens.fontCaption
            color: Theme.textDim
        }
    }

    Loader {
        anchors.right: parent.right
        anchors.rightMargin: Tokens.marginRow
        anchors.verticalCenter: parent.verticalCenter
        active: !root.stacked
        sourceComponent: root.row.type === "slider" ? slider : root.row.type === "toggle" ? toggle : info
    }

    Column {
        id: stack
        x: Tokens.marginRow
        y: Tokens.marginRow
        width: root.width - 2 * Tokens.marginRow
        visible: root.stacked
        spacing: Tokens.spacingRelaxed

        Label {
            text: root.row.title ?? ""
            visible: text !== ""
            font.pixelSize: Tokens.fontMedium
        }

        Loader {
            width: parent.width
            active: root.stacked
            sourceComponent: root.row.type === "choice" ? choice : cards
        }
    }

    Component {
        id: slider

        Row {
            spacing: Tokens.spacingMedium

            Slider {
                width: Tokens.settingsControlWidth
                anchors.verticalCenter: parent.verticalCenter
                value: (root.row.read() - root.sliderMin) / (root.sliderMax - root.sliderMin)
                onMoved: value => root.row.write(root.sliderValue(value))
            }

            Label {
                width: root.row.format ? Tokens.settingsValueWidth : Tokens.settingsPercentWidth
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignRight
                text: root.row.format ? root.row.format(root.row.read()) : Math.round(root.row.read() * 100) + "%"
                font.pixelSize: Tokens.fontBody
                color: Theme.textDim
            }
        }
    }

    Component {
        id: toggle

        Toggle {
            checked: root.row.read()
            onToggled: root.row.write(!checked)
        }
    }

    Component {
        id: info

        Label {
            text: root.row.read()
            font.pixelSize: Tokens.fontBody
            color: Theme.textDim
        }
    }

    Component {
        id: choice

        ChoiceList {
            options: root.row.options()
            current: root.row.read()
            onPicked: id => root.row.write(id)
        }
    }

    Component {
        id: cards

        SettingsCards {
            row: root.row
        }
    }
}
