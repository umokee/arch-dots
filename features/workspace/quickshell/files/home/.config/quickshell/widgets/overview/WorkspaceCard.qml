pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

import "../../services" as Services
import "../../utils/colors.js" as Colors

Rectangle {
    id: root

    required property int workspaceId
    property var workspace: null

    signal workspaceClicked(int workspaceId)
    signal windowClicked(var window)

    readonly property bool active: Hyprland.focusedWorkspace
        && Hyprland.focusedWorkspace.id === workspaceId

    readonly property int windowCount: getWindowCount(workspace)

    function getWindowCount(ws) {
        if (!ws || !ws.toplevels)
            return 0;

        if (ws.toplevels.values)
            return ws.toplevels.values.length;

        if (ws.toplevels.count !== undefined)
            return ws.toplevels.count;

        return 0;
    }

    function windowTitle(window) {
        if (!window)
            return "Window";

        if (window.title && window.title.length > 0)
            return window.title;

        if (window.wayland && window.wayland.title && window.wayland.title.length > 0)
            return window.wayland.title;

        return "Window";
    }

    function appName(window) {
        if (!window)
            return "";

        if (window.wayland && window.wayland.appId && window.wayland.appId.length > 0)
            return window.wayland.appId;

        if (window.lastIpcObject && window.lastIpcObject.class)
            return window.lastIpcObject.class;

        return "";
    }

    Layout.fillWidth: true
    Layout.preferredHeight: 92

    radius: Services.Theme.radius.sm

    color: active
        ? Colors.withAlpha(Services.Theme.surfaceVariant, 0.95)
        : Colors.withAlpha(Services.Theme.bg, 0.72)

    border.width: active ? 2 : 1
    border.color: active
        ? Services.Theme.orange
        : windowCount > 0
            ? Colors.withAlpha(Services.Theme.muted, 0.45)
            : Colors.withAlpha(Services.Theme.muted, 0.18)

    clip: true

    MouseArea {
        id: workspaceMouse

        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            root.workspaceClicked(root.workspaceId);
        }
    }

    Text {
        anchors.centerIn: parent

        text: String(root.workspaceId)
        color: root.active
            ? Colors.withAlpha(Services.Theme.fg, 0.24)
            : Colors.withAlpha(Services.Theme.muted, 0.20)

        font.family: Services.Theme.font.family
        font.pixelSize: 26
        font.bold: true
    }

    Rectangle {
        visible: root.windowCount === 0

        anchors.fill: parent
        anchors.margins: 10

        radius: Services.Theme.radius.sm
        color: "transparent"
        border.width: 1
        border.color: Colors.withAlpha(Services.Theme.muted, 0.12)
    }

    GridLayout {
        visible: root.windowCount > 0

        anchors.fill: parent
        anchors.margins: 8

        columns: root.windowCount === 1 ? 1 : 2
        rowSpacing: 5
        columnSpacing: 5

        Repeater {
            model: root.workspace && root.workspace.toplevels
                ? root.workspace.toplevels
                : 0

            delegate: Rectangle {
                id: win

                required property var modelData

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 26

                radius: 3

                color: windowMouse.containsMouse
                    ? Colors.withAlpha(Services.Theme.blue, 0.24)
                    : Colors.withAlpha(Services.Theme.bg, 0.82)

                border.width: 1
                border.color: modelData.activated
                    ? Services.Theme.blue
                    : modelData.urgent
                        ? Services.Theme.red
                        : Colors.withAlpha(Services.Theme.muted, 0.25)

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: 5

                    Text {
                        text: {
                            const app = root.appName(win.modelData);
                            return app.length > 0 ? app.charAt(0).toUpperCase() : "•";
                        }

                        color: win.modelData.urgent
                            ? Services.Theme.red
                            : Services.Theme.cyan

                        font.family: Services.Theme.font.family
                        font.pixelSize: 11
                        font.bold: true

                        Layout.preferredWidth: 14
                    }

                    Text {
                        Layout.fillWidth: true

                        text: root.windowTitle(win.modelData)
                        color: Services.Theme.fg
                        opacity: 0.85

                        font.family: Services.Theme.font.family
                        font.pixelSize: 10

                        elide: Text.ElideRight
                        maximumLineCount: 1
                        wrapMode: Text.NoWrap
                    }
                }

                MouseArea {
                    id: windowMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                    cursorShape: Qt.PointingHandCursor

                    onClicked: function(mouse) {
                        mouse.accepted = true;

                        if (mouse.button === Qt.MiddleButton) {
                            if (win.modelData.wayland)
                                win.modelData.wayland.close();

                            return;
                        }

                        root.windowClicked(win.modelData);
                    }
                }
            }
        }
    }
}
