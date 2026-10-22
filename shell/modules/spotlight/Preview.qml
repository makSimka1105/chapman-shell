import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.core
import qs.services
import qs.widgets

Item {
    id: root

    property var item: null
    readonly property real imageHeight: 190
    readonly property string kind: item?.kind ?? ""
    readonly property string heroImage: item?.image ?? clipImage
    readonly property bool wide: heroImage !== ""
    readonly property string runtimeDir: Quickshell.env("XDG_RUNTIME_DIR")
    property string fileText
    property string fileInfo
    property string clipImage

    function size(bytes) {
        const units = ["B", "KB", "MB", "GB"];
        let value = bytes;
        let unit = 0;
        while (value >= 1024 && unit < units.length - 1) {
            value /= 1024;
            unit++;
        }
        return (unit === 0 ? value : value.toFixed(1)) + " " + units[unit];
    }

    function describe(stat) {
        const [bytes, mtime] = stat.trim().split(" ").map(Number);
        const date = new Date(mtime * 1000).toLocaleString(Qt.locale("en_US"), "d MMM yyyy, HH:mm");
        return (item.isDir ? "Folder" : size(bytes)) + "  ·  " + date;
    }

    function details() {
        switch (kind) {
        case "app":
            return [item.subtitle, item.comment].filter((line, index, lines) => line && lines.indexOf(line) === index);
        case "file":
            return [item.subtitle, fileInfo];
        default:
            return [item?.subtitle ?? ""];
        }
    }

    onItemChanged: {
        fileText = "";
        fileInfo = "";
        clipImage = "";
        loader.restart();
    }

    Timer {
        id: loader
        interval: 80
        onTriggered: {
            if (root.kind === "clip") {
                const target = root.runtimeDir + "/notch-clip-" + root.item.clipId;
                clip.target = root.item.isImage ? target : "";
                clip.command = root.item.isImage
                    ? ["sh", "-c", "cliphist decode \"$1\" > \"$2\"", "sh", root.item.clipId, target]
                    : ["sh", "-c", "cliphist decode \"$1\" | head -c 2400", "sh", root.item.clipId];
                clip.running = true;
                return;
            }
            if (root.kind !== "file")
                return;
            stat.command = ["stat", "-c", "%s %Y", root.item.path];
            stat.running = true;
            if (root.item.text) {
                head.command = ["head", "-c", "2400", root.item.path];
                head.running = true;
            }
        }
    }

    Process {
        id: stat
        stdout: StdioCollector {
            onStreamFinished: if (text) root.fileInfo = root.describe(text)
        }
    }

    Process {
        id: clip

        property string target

        stdout: StdioCollector {
            onStreamFinished: {
                if (clip.target)
                    root.clipImage = "file://" + clip.target;
                else
                    root.fileText = text;
            }
        }
    }

    Process {
        id: head
        stdout: StdioCollector {
            onStreamFinished: root.fileText = text
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: Tokens.marginPanel
        spacing: Tokens.spacingLarge
        visible: root.item !== null

        ClippingRectangle {
            width: parent.width
            height: root.imageHeight
            radius: Tokens.radiusRow
            visible: root.wide
            color: Theme.card

            Image {
                anchors.fill: parent
                source: root.heroImage
                fillMode: root.kind === "theme" ? Image.PreserveAspectCrop : Image.PreserveAspectFit
                sourceSize: Qt.size(width * 2, height * 2)
                asynchronous: true
            }
        }

        Rectangle {
            width: parent.width
            height: root.imageHeight
            radius: Tokens.radiusRow
            visible: root.fileText !== ""
            color: Theme.card
            clip: true

            Text {
                anchors.fill: parent
                anchors.margins: Tokens.marginMedium
                text: root.fileText
                textFormat: Text.PlainText
                color: Theme.textDim
                font.family: "JetBrains Mono"
                font.pixelSize: Tokens.fontCaption
                renderType: Text.NativeRendering
                wrapMode: root.kind === "clip" ? Text.WrapAnywhere : Text.NoWrap
            }
        }

        ResultIcon {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 88
            height: 88
            visible: !root.wide && root.fileText === "" && root.item !== null
            item: root.item ?? {}
        }

        Label {
            width: parent.width
            horizontalAlignment: root.wide || root.fileText !== "" ? Text.AlignLeft : Text.AlignHCenter
            text: root.item?.title ?? ""
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
            font.pixelSize: root.kind === "calc" ? 34 : 18
            font.weight: Font.DemiBold
        }

        Repeater {
            model: root.item ? root.details() : []

            Label {
                required property string modelData

                width: parent.width
                horizontalAlignment: root.wide || root.fileText !== "" ? Text.AlignLeft : Text.AlignHCenter
                text: modelData
                visible: text !== ""
                color: Theme.textDim
                wrapMode: Text.Wrap
                maximumLineCount: 6
                elide: Text.ElideRight
                font.pixelSize: Tokens.fontBody
            }
        }
    }
}
