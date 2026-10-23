import QtQuick
import qs.services

Section {
    key: "appearance"
    title: "Оформление"
    glyph: "󰏘"
    subtitle: "Темы и обои"
    groups: [
        {
            title: "Тема",
            rows: [
                {
                    type: "themes",
                    items: () => Themes.themes,
                    read: () => Theme.name,
                    write: id => Themes.apply(id)
                }
            ]
        },
        {
            title: "Обои",
            rows: [
                {
                    type: "wallpapers",
                    items: () => Themes.themes.find(theme => theme.id === Theme.name)?.wallpapers ?? [],
                    read: () => Theme.wallpaper,
                    write: path => Themes.setWallpaper(path)
                }
            ]
        }
    ]
}
