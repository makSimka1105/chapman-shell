import QtQuick
import qs.core
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
    property real startAngle: -Math.PI / 2
    property real sweep: 2 * Math.PI

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
                duration: Tokens.durationRing
            }

            NumberAnimation {
                to: 1
                duration: Tokens.durationRing
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
            ctx.arc(cx, cy, radius, root.startAngle, root.startAngle + root.sweep);
            ctx.stroke();
            if (root.value <= 0)
                return;
            ctx.strokeStyle = root.fillColor;
            ctx.beginPath();
            ctx.arc(cx, cy, radius, root.startAngle, root.startAngle + root.sweep * Math.min(1, root.value));
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
