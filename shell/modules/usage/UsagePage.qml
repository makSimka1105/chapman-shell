import QtQuick
import qs.core
import qs.services
import qs.widgets

Item {
    id: root

    property int tab: 0

    signal back

    implicitHeight: Tokens.pageHeaderHeight + 10 + tabs.height + Tokens.spacingMedium + (content.item?.implicitHeight ?? 0)

    PageHeader {
        id: header

        width: parent.width
        title: "AI Usage"
        onBack: root.back()

        Label {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: Usage.known ? "обновлено " + Qt.formatTime(Usage.updated, "HH:mm") : "нет данных"
            color: Theme.textDim
            font.pixelSize: Tokens.fontBody
            font.weight: Font.Medium
        }
    }

    UsageTabs {
        id: tabs

        y: header.height + 10
        names: ["Подписки", "Ключи API"]
        current: root.tab
        onCurrentChanged: root.tab = current
    }

    Loader {
        id: content

        y: tabs.y + tabs.height + Tokens.spacingMedium
        width: parent.width
        sourceComponent: root.tab === 0 ? subscriptionsPanel : keysPanel
    }

    Component {
        id: subscriptionsPanel
        UsageSubscriptions {
            width: content.width
        }
    }

    Component {
        id: keysPanel
        UsageKeys {
            width: content.width
        }
    }
}
