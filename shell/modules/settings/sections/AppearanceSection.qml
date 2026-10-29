import QtQuick
import qs.services

Section {
    key: "appearance"
    title: "Оформление"
    glyph: "󰏘"
    subtitle: "Темы, обои и цветовые схемы"
    pages: [
        {
            key: "themes",
            title: "Темы",
            groups: [
                {
                    title: "Тема",
                    rows: [
                        {
                            type: "themes",
                            items: () => Themes.themes,
                            read: () => Theme.name,
                            write: id => Themes.apply(id)
                        },
                        {
                            type: "input",
                            title: "Новая тема",
                            subtitle: "Копия текущей, id из латиницы и дефисов",
                            placeholder: "my-theme",
                            write: id => Themes.create(id)
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
                        },
                        {
                            type: "actions",
                            title: "Папка обоев темы",
                            subtitle: "Все картинки из неё доступны в выборе",
                            actions: [
                                { glyph: "󰋩", label: "Добавить", run: () => Themes.pickWallpapers() },
                                { glyph: "󰉋", label: "Открыть", run: () => Themes.openWallpapers() }
                            ]
                        }
                    ]
                }
            ]
        },
        {
            key: "import",
            title: "Импорт",
            file: "appearance/SchemeImportPage.qml"
        }
    ]
}
