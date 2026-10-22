import QtQuick
import qs.core
import qs.services
import qs.widgets

Column {
    id: root

    signal back

    spacing: Tokens.spacingSnug

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
