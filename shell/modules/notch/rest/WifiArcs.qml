import QtQuick
import qs.core
import qs.services

Canvas {
    id: root

    readonly property bool online: Status.wifiNetwork !== null
    readonly property int bars: !online ? 0 : Status.wifiStrength > 0.5 ? 2 : 1
    property real thickness: 2

    implicitWidth: 16
    implicitHeight: 13
    antialiasing: true

    onBarsChanged: requestPaint()
    onWidthChanged: requestPaint()

    onPaint: {
        const ctx = getContext("2d");
        ctx.reset();
        const cx = width / 2;
        const cy = height - thickness;
        const step = (height - thickness) / 3;
        ctx.lineWidth = thickness;
        ctx.lineCap = "round";
        ctx.fillStyle = online ? Theme.accent : Theme.faint;
        ctx.beginPath();
        ctx.arc(cx, cy, thickness, 0, 2 * Math.PI);
        ctx.fill();
        for (let bar = 1; bar <= 2; bar++) {
            ctx.strokeStyle = bar <= bars ? Theme.accent : Theme.faint;
            ctx.beginPath();
            ctx.arc(cx, cy, step * bar + thickness / 2, -0.75 * Math.PI, -0.25 * Math.PI);
            ctx.stroke();
        }
    }

    Connections {
        target: Theme

        function onAccentChanged() {
            root.requestPaint();
        }
    }
}
