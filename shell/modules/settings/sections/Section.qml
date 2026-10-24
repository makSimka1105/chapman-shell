import QtQuick

QtObject {
    required property string key
    required property string title
    required property string glyph
    property string subtitle
    property bool ready: true
    property var groups: []
    property var pages: []
    property string file
}
