import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.core

PanelWindow {
    id: root

    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: Tokens.radiusScreen
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "chapman-corners"
    mask: Region {}

    Canvas {
        anchors.fill: parent
        onWidthChanged: requestPaint()
        onPaint: {
            const ctx = getContext("2d");
            const r = height;
            ctx.reset();
            ctx.fillStyle = "black";
            ctx.beginPath();
            ctx.moveTo(0, 0);
            ctx.lineTo(r, 0);
            ctx.arc(r, r, r, -Math.PI / 2, Math.PI, true);
            ctx.closePath();
            ctx.moveTo(width, 0);
            ctx.lineTo(width, r);
            ctx.arc(width - r, r, r, 0, -Math.PI / 2, true);
            ctx.closePath();
            ctx.fill();
        }
    }
}
