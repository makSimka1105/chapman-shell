import QtQuick
import qs.core
import qs.services
import qs.widgets

FocusScope {
    id: root

    property int themeIndex: 0
    property int wallpaperIndex: -1
    property bool wasActive
    readonly property var chosen: Themes.themes[themeIndex] ?? null
    readonly property var wallpapers: chosen?.wallpapers ?? []
    readonly property bool windowActive: Window.active
    readonly property bool inWallpapers: wallpaperIndex >= 0

    signal closed

    function open() {
        wasActive = false;
        wallpaperIndex = -1;
        const index = Themes.themes.findIndex(theme => theme.id === Theme.name);
        themeIndex = Math.max(index, 0);
        forceActiveFocus();
    }

    function applyTheme(index) {
        themeIndex = index;
        Themes.apply(Themes.themes[index].id);
    }

    function applyWallpaper(index) {
        wallpaperIndex = index;
        Themes.setWallpaper(wallpapers[index]);
    }

    function step(delta) {
        if (inWallpapers)
            wallpaperIndex = Math.max(0, Math.min(wallpapers.length - 1, wallpaperIndex + delta));
        else
            themeIndex = Math.max(0, Math.min(Themes.themes.length - 1, themeIndex + delta));
    }

    function confirm() {
        if (inWallpapers)
            applyWallpaper(wallpaperIndex);
        else if (chosen)
            applyTheme(themeIndex);
    }

    onWindowActiveChanged: {
        if (windowActive)
            wasActive = true;
        else if (wasActive && visible)
            closed();
    }

    implicitWidth: Tokens.themesWidth
    implicitHeight: Tokens.themesHeight
    Keys.onEscapePressed: closed()
    Keys.onLeftPressed: step(-1)
    Keys.onRightPressed: step(1)
    Keys.onReturnPressed: confirm()
    Keys.onEnterPressed: confirm()
    Keys.onDownPressed: if (wallpapers.length > 0 && !inWallpapers) wallpaperIndex = 0
    Keys.onUpPressed: wallpaperIndex = -1

    Column {
        anchors.centerIn: parent
        spacing: Tokens.marginMedium

        ListView {
            id: themeStrip
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(contentWidth, root.width - 2 * Tokens.marginField)
            height: Tokens.themeCardHeight
            orientation: ListView.Horizontal
            spacing: Tokens.spacingMedium
            model: Themes.themes
            currentIndex: root.themeIndex
            clip: true
            interactive: false
            highlightFollowsCurrentItem: false

            delegate: ThemeCard {
                required property var modelData
                required property int index

                width: Tokens.themeCardWidth
                height: Tokens.themeCardHeight
                theme: modelData
                selected: !root.inWallpapers && index === root.themeIndex
                onClicked: root.applyTheme(index)
            }
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.chosen ? root.chosen.name + " wallpapers" : ""
            font.pixelSize: Tokens.fontCaption
            color: Theme.textDim
        }

        ListView {
            id: wallpaperStrip
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(contentWidth, root.width - 2 * Tokens.marginField)
            height: Tokens.wallpaperThumbHeight
            orientation: ListView.Horizontal
            spacing: Tokens.spacingMedium
            model: root.wallpapers
            clip: true
            interactive: false

            delegate: WallpaperThumb {
                required property string modelData
                required property int index

                width: Tokens.wallpaperThumbWidth
                height: Tokens.wallpaperThumbHeight
                source: modelData
                selected: index === root.wallpaperIndex
                current: modelData === Theme.wallpaper
                onClicked: root.applyWallpaper(index)
            }
        }
    }
}
