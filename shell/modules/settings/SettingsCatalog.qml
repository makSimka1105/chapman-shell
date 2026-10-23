import QtQuick
import qs.modules.settings.sections

QtObject {
    readonly property list<Section> sections: [
        IslandSection {},
        Section { key: "wifi"; title: "Wi-Fi"; glyph: "󰖩"; ready: false },
        Section { key: "bluetooth"; title: "Bluetooth"; glyph: "󰂯"; ready: false },
        Section { key: "network"; title: "Сеть"; glyph: "󰛳"; ready: false },
        SoundSection {},
        DisplaysSection {},
        Section { key: "battery"; title: "Батарея"; glyph: "󰁹"; ready: false },
        AppearanceSection {},
        Section { key: "wallpaper"; title: "Обои"; glyph: "󰸉"; ready: false },
        Section { key: "notifications"; title: "Уведомления"; glyph: "󰂚"; ready: false },
        Section { key: "keyboard"; title: "Клавиатура"; glyph: "󰌌"; ready: false },
        Section { key: "lock"; title: "Экран блокировки"; glyph: "󰌾"; ready: false },
        Section { key: "tiling"; title: "Tiling"; glyph: "󰭮"; ready: false }
    ]
}
