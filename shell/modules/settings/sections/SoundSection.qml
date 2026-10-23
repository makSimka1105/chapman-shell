import QtQuick
import qs.services

Section {
    key: "sound"
    title: "Звук"
    glyph: "󰕾"
    subtitle: "Громкость и устройства"
    groups: [
        {
            title: "Вывод",
            rows: [
                {
                    type: "slider",
                    title: "Громкость",
                    read: () => Audio.outputVolume,
                    write: value => Audio.setOutputVolume(value)
                },
                {
                    type: "toggle",
                    title: "Без звука",
                    read: () => Audio.outputMuted,
                    write: muted => Audio.setOutputMuted(muted)
                },
                {
                    type: "choice",
                    title: "Устройство вывода",
                    options: () => Audio.outputDevices,
                    read: () => Audio.outputId,
                    write: id => Audio.selectOutput(id)
                }
            ]
        },
        {
            title: "Ввод",
            rows: [
                {
                    type: "slider",
                    title: "Микрофон",
                    read: () => Audio.inputVolume,
                    write: value => Audio.setInputVolume(value)
                },
                {
                    type: "toggle",
                    title: "Микрофон выключен",
                    read: () => Audio.inputMuted,
                    write: muted => Audio.setInputMuted(muted)
                }
            ]
        }
    ]
}
