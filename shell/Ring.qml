import QtQuick
import qs.services

Item {
    id: root

    property real value: 0
    property real thickness: 5
    property color trackColor: Theme.faint
    property color fillColor: value > 0.85 ? Theme.warning : Theme.accent
    property string text: Math.round(value * 100) + "%"
    property real fontSize: 12
    property bool pulsing: false

    implicitWidth: 44
    implicitHeight: 44

    onValueChanged: canvas.requestPaint()
    onFillColorChanged: canvas.requestPaint()
    onTrackColorChanged: canvas.requestPaint()
    onWidthChanged: canvas.requestPaint()

    Canvas {
        id: canvas

        SequentialAnimation on opacity {
            running: root.pulsing
            loops: Animation.Infinite
            onRunningChanged: if (!running) canvas.opacity = 1

            NumberAnimation {
                to: 0.35
                duration: 900
            }

            NumberAnimation {
                to: 1
                duration: 900
            }
        }

        anchors.fill: parent
        antialiasing: true
        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            const radius = (Math.min(width, height) - root.thickness) / 2;
            const cx = width / 2;
            const cy = height / 2;
            ctx.lineWidth = root.thickness;
            ctx.lineCap = "round";
            ctx.strokeStyle = root.trackColor;
            ctx.beginPath();
            ctx.arc(cx, cy, radius, 0, 2 * Math.PI);
            ctx.stroke();
            if (root.value <= 0)
                return;
            ctx.strokeStyle = root.fillColor;
            ctx.beginPath();
            ctx.arc(cx, cy, radius, -Math.PI / 2, -Math.PI / 2 + 2 * Math.PI * Math.min(1, root.value));
            ctx.stroke();
        }
    }

    Label {
        anchors.centerIn: parent
        text: root.text
        font.pixelSize: root.fontSize
        font.weight: Font.DemiBold
    }
}
