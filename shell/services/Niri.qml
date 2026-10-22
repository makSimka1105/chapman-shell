pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var workspaces: []
    property var windows: ({})
    property var focusedWindowId: null
    property var layouts: []
    property int layoutIndex: 0

    readonly property var focusedWindow: focusedWindowId === null ? null : windows[focusedWindowId] ?? null
    readonly property string focusedOutput: workspaces.find(w => w.is_focused)?.output ?? ""
    readonly property string layoutCode: (layouts[layoutIndex] ?? "").slice(0, 2).toUpperCase()

    function workspacesOn(output) {
        return workspaces.filter(w => w.output === output).sort((a, b) => a.idx - b.idx);
    }

    function hasWindows(workspaceId) {
        return Object.values(windows).some(w => w.workspace_id === workspaceId);
    }

    function activate(workspaceId, focused) {
        const updated = workspaces.map(w => Object.assign({}, w));
        const target = updated.find(w => w.id === workspaceId);
        if (!target)
            return;
        for (const w of updated) {
            if (w.output === target.output)
                w.is_active = w.id === workspaceId;
            if (focused)
                w.is_focused = w.id === workspaceId;
        }
        workspaces = updated;
    }

    function setWindow(window) {
        const updated = Object.assign({}, windows);
        updated[window.id] = window;
        windows = updated;
        if (window.is_focused)
            focusedWindowId = window.id;
    }

    function removeWindow(id) {
        const updated = Object.assign({}, windows);
        delete updated[id];
        windows = updated;
        if (focusedWindowId === id)
            focusedWindowId = null;
    }

    function handle(event) {
        if (event.WorkspacesChanged) {
            workspaces = event.WorkspacesChanged.workspaces;
        } else if (event.WorkspaceActivated) {
            activate(event.WorkspaceActivated.id, event.WorkspaceActivated.focused);
        } else if (event.WindowsChanged) {
            const map = {};
            for (const w of event.WindowsChanged.windows)
                map[w.id] = w;
            windows = map;
            focusedWindowId = event.WindowsChanged.windows.find(w => w.is_focused)?.id ?? null;
        } else if (event.WindowOpenedOrChanged) {
            setWindow(event.WindowOpenedOrChanged.window);
        } else if (event.WindowClosed) {
            removeWindow(event.WindowClosed.id);
        } else if (event.WindowFocusChanged) {
            focusedWindowId = event.WindowFocusChanged.id;
        } else if (event.KeyboardLayoutsChanged) {
            layouts = event.KeyboardLayoutsChanged.keyboard_layouts.names;
            layoutIndex = event.KeyboardLayoutsChanged.keyboard_layouts.current_idx;
        } else if (event.KeyboardLayoutSwitched) {
            layoutIndex = event.KeyboardLayoutSwitched.idx;
        }
    }

    Socket {
        path: Quickshell.env("NIRI_SOCKET")
        connected: true
        onConnectedChanged: {
            if (connected) {
                write('"EventStream"\n');
                flush();
            }
        }
        parser: SplitParser {
            onRead: line => root.handle(JSON.parse(line))
        }
    }
}
