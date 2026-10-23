import QtQuick
import qs.core

Section {
    key: "island"
    title: "Остров"
    glyph: "󱂬"
    subtitle: "Виджеты, движение и поведение"
    pages: [
        {
            key: "rest",
            title: "В покое",
            reset: "rest",
            file: "island/IslandRestPage.qml"
        },
        {
            key: "home",
            title: "Раскрытый вид",
            reset: "home",
            file: "island/IslandHomePage.qml"
        },
        {
            key: "motion",
            title: "Движение",
            reset: "motion",
            groups: [
                {
                    rows: [
                        {
                            type: "slider",
                            title: "Скорость",
                            subtitle: "Множитель всех длительностей",
                            min: 0.5,
                            max: 2,
                            step: 0.05,
                            format: value => value.toFixed(2) + "x",
                            read: () => IslandConfig.data.motion.speed,
                            write: value => IslandConfig.set("motion.speed", value)
                        },
                        {
                            type: "slider",
                            title: "Перелёт",
                            subtitle: "Амплитуда пружинного отскока",
                            min: 0,
                            max: 2,
                            step: 0.05,
                            format: value => value.toFixed(2) + "x",
                            read: () => IslandConfig.data.motion.overshoot,
                            write: value => IslandConfig.set("motion.overshoot", value)
                        },
                        {
                            type: "slider",
                            title: "Зазор отрыва",
                            subtitle: "Расстояние поиска от острова",
                            min: 0,
                            max: 30,
                            step: 1,
                            format: value => value + " px",
                            read: () => IslandConfig.data.motion.detachGap,
                            write: value => IslandConfig.set("motion.detachGap", value)
                        },
                        {
                            type: "toggle",
                            title: "Сжатие",
                            subtitle: "Сжатие при смене режима",
                            read: () => IslandConfig.data.motion.squash,
                            write: value => IslandConfig.set("motion.squash", value)
                        }
                    ]
                }
            ]
        },
        {
            key: "behavior",
            title: "Поведение",
            reset: "behavior",
            groups: [
                {
                    rows: [
                        {
                            type: "toggle",
                            title: "Раскрывать по наведению",
                            read: () => IslandConfig.data.behavior.hoverOpen,
                            write: value => IslandConfig.set("behavior.hoverOpen", value)
                        },
                        {
                            type: "slider",
                            title: "Задержка раскрытия",
                            min: 0,
                            max: 1000,
                            step: 10,
                            format: value => value + " мс",
                            read: () => IslandConfig.data.behavior.hoverDelay,
                            write: value => IslandConfig.set("behavior.hoverDelay", value)
                        },
                        {
                            type: "slider",
                            title: "Задержка закрытия",
                            min: 0,
                            max: 2000,
                            step: 10,
                            format: value => value + " мс",
                            read: () => IslandConfig.data.behavior.closeDelay,
                            write: value => IslandConfig.set("behavior.closeDelay", value)
                        },
                        {
                            type: "toggle",
                            title: "Медиа в покое",
                            subtitle: "Показывать трек в свёрнутом острове",
                            read: () => IslandConfig.data.behavior.mediaInRest,
                            write: value => IslandConfig.set("behavior.mediaInRest", value)
                        }
                    ]
                }
            ]
        }
    ]
}
