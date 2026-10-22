import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import qs.services

Scope {
    id: root

    property bool demoOpened
    property string typed
    property int failures
    readonly property bool locked: session.locked

    function lock() {
        typed = "";
        const english = Niri.layouts.findIndex(name => name.startsWith("English"));
        if (english >= 0 && english !== Niri.layoutIndex)
            Spawn.run(["niri", "msg", "action", "switch-layout", String(english)]);
        session.locked = true;
    }

    function demo() {
        typed = "";
        demoOpened = true;
    }

    function closeDemo() {
        demoOpened = false;
    }

    PamContext {
        id: pam
        config: "swaylock"
        user: Quickshell.env("USER")

        onPamMessage: {
            if (responseRequired)
                respond(root.typed);
        }

        onCompleted: result => {
            if (result === PamResult.Success) {
                session.locked = false;
            } else {
                root.typed = "";
                root.failures++;
            }
        }
    }

    WlSessionLock {
        id: session

        WlSessionLockSurface {
            color: "black"

            LockView {
                anchors.fill: parent
                busy: pam.active
                text: root.typed
                failures: root.failures
                onEdited: value => root.typed = value
                onSubmitted: {
                    if (root.typed !== "" && !pam.active)
                        pam.start();
                }
            }
        }
    }

    PanelWindow {
        screen: Quickshell.screens.find(s => s.name === Niri.focusedOutput) ?? Quickshell.screens[0]
        visible: root.demoOpened
        anchors.top: true
        anchors.bottom: true
        anchors.left: true
        anchors.right: true
        color: "black"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "notch-lock-demo"
        WlrLayershell.keyboardFocus: root.demoOpened ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        LockView {
            anchors.fill: parent
            demo: true
            text: root.typed
            failures: root.failures
            onEdited: value => root.typed = value
            onEscaped: root.closeDemo()
        }
    }
}
