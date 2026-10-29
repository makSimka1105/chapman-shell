pragma Singleton
import QtQuick
import Quickshell

Singleton {
    readonly property var widgets: [
        {
            id: "workspaces",
            name: "Рабочие столы",
            glyph: "󰍹",
            places: ["rest", "home"],
            variants: [
                { id: "dots", name: "Точки" },
                { id: "numbers", name: "Цифры" }
            ]
        },
        {
            id: "equalizer",
            name: "Эквалайзер",
            glyph: "󰎆",
            places: ["rest"],
            variants: []
        },
        {
            id: "clock",
            name: "Часы",
            glyph: "󰥔",
            places: ["rest", "home"],
            variants: [
                { id: "time", name: "Время" },
                { id: "seconds", name: "Время с секундами" },
                { id: "date", name: "Дата" }
            ]
        },
        {
            id: "layout",
            name: "Раскладка",
            glyph: "󰌌",
            places: ["rest"],
            variants: [
                { id: "code", name: "Код" }
            ]
        },
        {
            id: "bluetooth",
            name: "Bluetooth",
            glyph: "󰂯",
            places: ["rest"],
            variants: [
                { id: "icon", name: "Значок" }
            ]
        },
        {
            id: "wifi",
            name: "Wi-Fi",
            glyph: "󰤨",
            places: ["rest"],
            variants: [
                { id: "icon", name: "Значок" },
                { id: "name", name: "Название сети" }
            ]
        },
        {
            id: "battery",
            name: "Батарея",
            glyph: "󰁹",
            places: ["rest", "home"],
            variants: [
                { id: "icon", name: "Значок" },
                { id: "percent", name: "Проценты" },
                { id: "both", name: "Значок и проценты" },
                { id: "ring", name: "Кольцо вокруг Wi-Fi" }
            ]
        },
        {
            id: "notifications",
            name: "Уведомления",
            glyph: "󰂚",
            places: ["rest"],
            variants: [
                { id: "count", name: "Счётчик" }
            ]
        },
        {
            id: "media",
            name: "Медиа",
            glyph: "󰝚",
            places: ["rest", "home"],
            variants: [
                { id: "title", name: "Название трека" }
            ]
        },
        {
            id: "focus",
            name: "Активное окно",
            glyph: "󰖯",
            places: ["home"],
            variants: []
        },
        {
            id: "usage",
            name: "Лимиты",
            glyph: "󰓅",
            places: ["home"],
            variants: []
        },
        {
            id: "calendar",
            name: "Календарь",
            glyph: "󰃭",
            places: ["home"],
            variants: []
        },
        {
            id: "links",
            name: "Сети",
            glyph: "󰖩",
            places: ["home"],
            variants: []
        },
        {
            id: "tiles",
            name: "Быстрые кнопки",
            glyph: "󰕰",
            places: ["home"],
            variants: []
        }
    ]

    function widget(id) {
        return widgets.find(entry => entry.id === id) ?? null;
    }
}
