import QtQuick
import qs.services
import qs.widgets

FocusScope {
    id: root

    property bool busy
    property bool demo
    property string text
    property int failures

    signal edited(string value)
    signal submitted
    signal escaped

    implicitWidth: 260
    implicitHeight: 44
    onFailuresChanged: shake.restart()

    Rectangle {
        id: pill

        property real offset: 0
        property real flush: 0

        anchors.fill: parent
        radius: height / 2
        color: Qt.tint(Qt.alpha("white", 0.14), Qt.alpha(Theme.warning, 0.35 * flush))
        border.width: 1
        border.color: Qt.tint(Qt.alpha("white", 0.2), Qt.alpha(Theme.warning, flush))
        transform: Translate {
            x: pill.offset
        }

        SequentialAnimation {
            id: shake
            NumberAnimation {
                target: pill
                property: "flush"
                to: 1
                duration: 80
            }
            NumberAnimation {
                target: pill
                property: "offset"
                to: -14
                duration: 50
            }
            NumberAnimation {
                target: pill
                property: "offset"
                to: 14
                duration: 80
            }
            NumberAnimation {
                target: pill
                property: "offset"
                to: -8
                duration: 70
            }
            NumberAnimation {
                target: pill
                property: "offset"
                to: 0
                duration: 300
                easing.type: Easing.OutBack
                easing.overshoot: 3
            }
            NumberAnimation {
                target: pill
                property: "flush"
                to: 0
                duration: 400
            }
        }

        TextInput {
            id: field
            width: 0
            height: 0
            opacity: 0
            focus: true
            echoMode: TextInput.Password
            readOnly: root.busy
            text: root.text
            onTextChanged: if (text !== root.text) root.edited(text)
            onActiveFocusChanged: if (!activeFocus) root.forceActiveFocus()
            Keys.onEscapePressed: if (root.demo) root.escaped()
            Keys.onReturnPressed: root.submitted()
            Keys.onEnterPressed: root.submitted()
        }

        Item {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            clip: true
            opacity: root.busy ? 0.5 : 1

            Row {
                anchors.centerIn: parent
                spacing: 7

                Repeater {
                    model: root.text.length

                    Rectangle {
                        width: 8
                        height: 8
                        radius: 4
                        color: Theme.text
                    }
                }
            }

            Label {
                anchors.centerIn: parent
                visible: root.text === ""
                text: "Enter Password"
                color: Theme.textDim
                font.pixelSize: 15
            }
        }
    }
}
