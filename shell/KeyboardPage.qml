import QtQuick
import qs.services

Column {
    id: root

    signal back

    spacing: 4

    PageHeader {
        width: parent.width
        title: "Keyboard"
        onBack: root.back()
    }

    Repeater {
        model: Niri.layouts

        ListRow {
            required property string modelData
            required property int index

            width: root.width
            glyph: "󰌌"
            title: modelData
            subtitle: modelData.slice(0, 2).toUpperCase()
            trailing: active ? "󰄬" : ""
            active: Niri.layoutIndex === index
            onClicked: Spawn.run(["niri", "msg", "action", "switch-layout", String(index)])
        }
    }
}
