import QtQuick
import qs.core
import qs.services
import qs.widgets

Item {
    id: root

    required property string output
    readonly property real side: 36
    property string picker

    signal pageRequested(string page)

    implicitWidth: grid.implicitWidth
    implicitHeight: grid.implicitHeight + Tokens.homeInsetVertical * 2

    onVisibleChanged: if (!visible) picker = ""

    MouseArea {
        anchors.fill: parent
        z: -1
        onPressed: mouse => mouse.accepted = root.picker !== ""
        onClicked: root.picker = ""
    }

    HomeGrid {
        id: grid
        widgets: homeWidgets
        inset: root.side
        anchors.verticalCenter: parent.verticalCenter
    }

    HomeWidgets {
        id: homeWidgets
        picker: root.picker
        onPageRequested: page => root.pageRequested(page)
        onPickerToggled: name => root.picker = root.picker === name ? "" : name
    }

    HoverPicker {
        anchors.right: parent.right
        anchors.rightMargin: root.side - 14
        anchors.verticalCenter: parent.verticalCenter
        held: root.picker === "layout"
        entries: Niri.layouts.slice(0, 4).map((name, index) => ({
                    glyph: "󰌌",
                    title: name,
                    active: Niri.layoutIndex === index
                }))
        onPicked: index => {
            Spawn.run(["niri", "msg", "action", "switch-layout", String(index)]);
            root.picker = "";
        }
    }

    HoverPicker {
        anchors.right: parent.right
        anchors.rightMargin: root.side - 14
        anchors.verticalCenter: parent.verticalCenter
        held: root.picker === "tiling"
        entries: Tiling.presets.map(entry => ({
                    glyph: entry.glyph,
                    title: entry.label,
                    active: Tiling.preset === entry.id
                })).concat([{ glyph: "󰕌", title: "Restore", active: false }])
        onPicked: index => {
            if (index < Tiling.presets.length)
                Tiling.apply(Tiling.presets[index].id);
            else
                Tiling.restore();
            root.picker = "";
        }
    }
}
