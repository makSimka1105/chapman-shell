import QtQuick
import qs.services

Section {
    key: "displays"
    title: "Экран"
    glyph: "󰍹"
    subtitle: "Яркость и мониторы"
    groups: [
        {
            title: "Яркость",
            rows: [
                {
                    type: "slider",
                    title: "Яркость экрана",
                    read: () => Display.brightness,
                    write: value => Display.setBrightness(value)
                }
            ]
        },
        {
            title: "Мониторы",
            rows: Display.outputs.map(output => ({
                type: "info",
                title: output.name,
                subtitle: output.make + " " + output.model,
                read: () => Display.describeOutput(output)
            }))
        }
    ]
}
