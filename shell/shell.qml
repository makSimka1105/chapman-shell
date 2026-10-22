//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.services
import qs.modules.lock
import qs.modules.notch
import qs.modules.power
import qs.modules.spotlight
import qs.modules.wallpaper

ShellRoot {
    Component.onCompleted: Clipboard.refresh()

    Variants {
        model: Quickshell.screens

        Wallpaper {
            required property var modelData

            screen: modelData
        }
    }

    Spotlight {
        id: spotlight
    }

    IpcHandler {
        target: "spotlight"

        function toggle(): void {
            spotlight.toggle("");
        }

        function toggleQuery(query: string): void {
            spotlight.toggle(query);
        }
    }

    IpcHandler {
        target: "osd"

        function brightness(): void {
            Osd.showBrightness();
        }
    }

    PowerMenu {
        id: powerMenu
    }

    IpcHandler {
        target: "power"

        function toggle(): void {
            powerMenu.toggle();
        }

        function close(): void {
            powerMenu.close();
        }
    }

    LockScreen {
        id: lockScreen
    }

    IpcHandler {
        target: "lock"

        function lock(): void {
            lockScreen.lock();
        }

        function demo(): void {
            lockScreen.demo();
        }

        function closeDemo(): void {
            lockScreen.closeDemo();
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: window

            required property var modelData
            readonly property int shadowRoom: 48
            readonly property int niriTopSpace: 26
            readonly property int windowGap: 8

            screen: modelData
            anchors.top: true
            implicitWidth: notch.homeSize.width + shadowRoom * 2
            implicitHeight: notch.maxHeight + shadowRoom
            exclusiveZone: notch.restSize.height - window.niriTopSpace + window.windowGap
            color: "transparent"
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.namespace: "notch"
            WlrLayershell.keyboardFocus: notch.state === "control" || notch.state === "themes" ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
            mask: Region {
                item: notch
            }

            Notch {
                id: notch
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                output: window.modelData.name
            }

            IpcHandler {
                target: "notch"

                function open(): void {
                    notch.pinned = true;
                    notch.state = "home";
                }

                function close(): void {
                    notch.pinned = false;
                    notch.state = "rest";
                }

                function control(page: string): void {
                    notch.openControl(page || "usage");
                }

                function themes(): void {
                    notch.openThemes();
                }

                function state(): string {
                    return notch.state + (notch.pinned ? " pinned" : "");
                }
            }
        }
    }
}
