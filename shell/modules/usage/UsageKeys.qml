import QtQuick
import qs.core
import qs.services

Grid {
    id: root

    columns: 3
    spacing: Tokens.spacingMedium

    Repeater {
        model: Usage.keys

        UsageKeyCard {
            required property var modelData

            width: (root.width - (root.columns - 1) * root.spacing) / root.columns
            entry: modelData
        }
    }
}
