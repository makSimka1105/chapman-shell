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
        const index = Themes.themes.findIndex(theme => theme.id === Theme.name);
        themeIndex = Math.max(index, 0);
        wallpaperIndex = wallpapers.length > 0 ? Math.max(wallpapers.indexOf(Theme.wallpaper), 0) : -1;
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

    function switchStrip(down) {
        if (down && !inWallpapers && wallpapers.length > 0)
            wallpaperIndex = Math.max(wallpapers.indexOf(Theme.wallpaper), 0);
        else if (!down)
            wallpaperIndex = -1;
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
    Keys.onReturnPressed: confirm()
    Keys.onEnterPressed: confirm()
    Keys.onPressed: event => {
        const moves = { [Qt.Key_Left]: () => step(-1), [Qt.Key_H]: () => step(-1), [Qt.Key_Right]: () => step(1), [Qt.Key_L]: () => step(1), [Qt.Key_Down]: () => switchStrip(true), [Qt.Key_J]: () => switchStrip(true), [Qt.Key_Up]: () => switchStrip(false), [Qt.Key_K]: () => switchStrip(false) };
        if (moves[event.key]) {
            moves[event.key]();
            event.accepted = true;
        }
    }
    onThemeIndexChanged: themeStrip.positionViewAtIndex(themeIndex, ListView.Contain)
    onWallpaperIndexChanged: if (wallpaperIndex >= 0) wallpaperStrip.positionViewAtIndex(wallpaperIndex, ListView.Contain)

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
            interactive: true
            boundsBehavior: Flickable.StopAtBounds
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
            interactive: true
            boundsBehavior: Flickable.StopAtBounds

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
