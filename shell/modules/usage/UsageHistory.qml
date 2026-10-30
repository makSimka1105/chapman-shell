import QtQuick
import qs.core
import qs.services
import qs.widgets

Column {
    id: root

    spacing: Tokens.spacingLarge

    Repeater {
        model: Usage.subscriptionIds

        UsageWeekly {
            required property string modelData

            width: root.width
            source: modelData
        }
    }
}
