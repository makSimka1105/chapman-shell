import QtQuick
import qs.core
import qs.services
import qs.widgets

Item {
    id: root

    property string variant
    readonly property bool present: IslandConfig.data.behavior.mediaInRest && Media.active

    implicitWidth: equalizer.width
    implicitHeight: equalizer.height

    Equalizer {
        id: equalizer
        anchors.centerIn: parent
        active: Media.playing
    }
}
