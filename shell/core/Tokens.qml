pragma Singleton
import QtQuick
import Quickshell

Singleton {
    readonly property real radiusHairline: 1.5
    readonly property real radiusThin: 3
    readonly property real radiusBar: 4
    readonly property real radiusChip: 12
    readonly property real radiusBadge: 13
    readonly property real radiusRow: 14
    readonly property real radiusMedia: 16
    readonly property real radiusBackButton: 17
    readonly property real radiusCard: 18
    readonly property real radiusPanel: 26

    readonly property real spacingHairline: 2
    readonly property real spacingTight: 3
    readonly property real spacingSnug: 4
    readonly property real spacingCompact: 5
    readonly property real spacingSmall: 6
    readonly property real spacingMid: 7
    readonly property real spacingItem: 8
    readonly property real spacingRelaxed: 10
    readonly property real spacingMedium: 12
    readonly property real spacingLarge: 14

    readonly property real hitAreaMargin: -6
    readonly property real marginTight: 6
    readonly property real marginInner: 10
    readonly property real marginMedium: 12
    readonly property real marginRow: 14
    readonly property real marginWide: 16
    readonly property real marginPanel: 18
    readonly property real searchWidth: 716
    readonly property real marginLarge: 20
    readonly property real marginField: 24
    readonly property real marginScreen: 32
    readonly property real homeInsetVertical: 32.5

    readonly property int fontMicro: 10
    readonly property int fontCaption: 11
    readonly property int fontSmall: 12
    readonly property int fontBody: 13
    readonly property int fontMedium: 14
    readonly property int fontLabel: 15
    readonly property int fontSubtitle: 16
    readonly property int fontIcon: 18
    readonly property int fontHeading: 20
    readonly property int fontLarge: 22
    readonly property int fontDisplay: 24

    readonly property int durationShakeStep: Math.round(80 / motionSpeed)
    readonly property int durationHover: Math.round(120 / motionSpeed)
    readonly property int durationQuick: Math.round(150 / motionSpeed)
    readonly property int durationFast: Math.round(160 / motionSpeed)
    readonly property int durationNormal: Math.round(200 / motionSpeed)
    readonly property int durationPress: Math.round(220 / motionSpeed)
    readonly property int durationFocus: Math.round(230 / motionSpeed)
    readonly property int durationMove: Math.round(260 / motionSpeed)
    readonly property int durationSlow: Math.round(300 / motionSpeed)
    readonly property int durationLong: Math.round(400 / motionSpeed)
    readonly property int durationEntrance: Math.round(460 / motionSpeed)
    readonly property int durationReveal: Math.round(520 / motionSpeed)
    readonly property int durationRing: Math.round(900 / motionSpeed)

    readonly property real motionSpeed: Math.max(0.1, IslandConfig.data.motion.speed)
    readonly property real overshootScale: IslandConfig.data.motion.overshoot
    readonly property real islandDetachGap: IslandConfig.data.motion.detachGap
    readonly property real overshootMild: 1 * overshootScale
    readonly property real overshootSoft: 1.2 * overshootScale
    readonly property real overshootMedium: 1.4 * overshootScale
    readonly property real overshootStrong: 1.5 * overshootScale
    readonly property real overshootSnappy: 3 * overshootScale

    readonly property real listRowHeight: 42
    readonly property real pageHeaderHeight: 44
    readonly property real trackHeight: 8
    readonly property real themesWidth: 1000
    readonly property real themesHeight: 290
    readonly property real themeCardWidth: 200
    readonly property real themeCardHeight: 96
    readonly property real themeDot: 18
    readonly property real wallpaperThumbWidth: 192
    readonly property real wallpaperThumbHeight: 108

    readonly property real sliderHeight: 24
    readonly property real sliderKnob: 16
    readonly property real choiceHeight: 40
    readonly property real settingsWidth: 1100
    readonly property real settingsHeight: 720
    readonly property real settingsSidebarWidth: 240
    readonly property real settingsRowHeight: 56
    readonly property real settingsControlWidth: 240
    readonly property real settingsPageWidth: 720
    readonly property real sidebarItemHeight: 38
    readonly property real headerIconSize: 64
    readonly property real settingsPercentWidth: 40

    readonly property real iconButtonSize: 30
    readonly property real segmentWidth: 128
    readonly property real segmentHeight: 34
    readonly property real dropdownWidth: 150
    readonly property real dropdownRowHeight: 34
    readonly property real widgetRowHeight: 48
    readonly property real settingsValueWidth: 64
}
