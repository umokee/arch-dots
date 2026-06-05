pragma Singleton

import QtQuick
import Quickshell.Hyprland

QtObject {
    id: root

    readonly property int activeWorkspaceId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1
    readonly property var workspaces: Hyprland.workspaces.values
    readonly property var occupiedWorkspaceIds: Hyprland.workspaces.values.map((workspace) => workspace.id)
    readonly property bool activeWindowFullscreen: Hyprland.activeWindow ? Hyprland.activeWindow.fullscreen : false

    function focusWorkspace(workspaceId) {
        Hyprland.dispatch('hl.dsp.focus({ workspace = "' + workspaceId + '" })');
    }

    function execCommand(command) {
        const escaped = String(command).replace(/\\/g, "\\\\").replace(/"/g, '\\"');
        Hyprland.dispatch('hl.dsp.exec_cmd("' + escaped + '")');
    }
}
