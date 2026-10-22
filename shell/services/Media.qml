pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    readonly property var players: Mpris.players.values
    readonly property MprisPlayer player: players.find(p => p.isPlaying) ?? players[0] ?? null
    readonly property bool playing: player?.isPlaying ?? false
    readonly property bool active: player !== null && player.playbackState !== MprisPlaybackState.Stopped && title !== ""
    readonly property string title: player?.trackTitle ?? ""
    readonly property string artist: player?.trackArtist ?? ""
    readonly property string art: player?.trackArtUrl ?? ""
    readonly property real progress: player && player.length > 0 ? player.position / player.length : 0

    function sourceWindow() {
        const windows = Object.values(Niri.windows);
        const entry = (player?.desktopEntry ?? "").toLowerCase();
        return windows.find(w => title !== "" && w.title.includes(title)) ?? windows.find(w => entry !== "" && w.app_id.toLowerCase().includes(entry)) ?? null;
    }

    function focusSource() {
        const window = sourceWindow();
        if (window)
            Quickshell.execDetached(["niri", "msg", "action", "focus-window", "--id", String(window.id)]);
        else if (player?.canRaise)
            player.raise();
    }
}
