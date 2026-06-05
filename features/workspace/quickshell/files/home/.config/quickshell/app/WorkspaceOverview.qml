pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

import "../services" as Services
import "../widgets/overview" as OverviewWidgets
import "../utils/colors.js" as Colors

Variants {
    id: root

    required property var hostConfig

    model: Quickshell.screens

    PanelWindow {
        id: overviewWindow

        required property var modelData

        screen: modelData
        visible: modelData.name === root.hostConfig.primaryScreen
                 && Services.Overview.isOpen

        anchors.left: true
        anchors.right: true
        anchors.top: true
        anchors.bottom: true

        exclusiveZone: 0
        color: "transparent"

        readonly property int columnCount: Math.min(5, root.hostConfig.workspaceCount)
        readonly property int rowCount: Math.ceil(root.hostConfig.workspaceCount / columnCount)
        readonly property int previewHeight: 92
        readonly property int headerHeight: 26
        readonly property int panelPadding: Services.Theme.spacing.md * 2

        function workspaceById(id) {
            if (!Hyprland.workspaces || !Hyprland.workspaces.values)
                return null;

            const list = Hyprland.workspaces.values;

            for (let i = 0; i < list.length; i++) {
                if (list[i].id === id)
                    return list[i];
            }

            return null;
        }

        function focusWorkspace(id) {
            const workspace = workspaceById(id);

            if (workspace)
                workspace.activate();
            else
                Hyprland.dispatch("workspace " + id);

            Services.Overview.close();
        }

        function focusWindow(window) {
            if (!window)
                return;

            if (window.wayland)
                window.wayland.activate();
            else if (window.address && window.address.length > 0)
                Hyprland.dispatch("focuswindow address:" + window.address);

            Services.Overview.close();
        }

        onVisibleChanged: {
            if (visible)
                focusGrabber.forceActiveFocus();
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

            onClicked: {
                Services.Overview.close();
            }
        }

        Item {
            id: focusGrabber

            anchors.fill: parent
            focus: true

            Keys.onEscapePressed: {
                Services.Overview.close();
            }
        }

        Rectangle {
            id: panel

            width: Math.min(980, overviewWindow.width - 220)
            height: overviewWindow.headerHeight
                    + overviewWindow.panelPadding
                    + overviewWindow.rowCount * overviewWindow.previewHeight
                    + Math.max(0, overviewWindow.rowCount - 1) * Services.Theme.spacing.sm

            radius: Services.Theme.radius.md

            color: Colors.withAlpha(Services.Theme.bg, 0.94)
            border.width: 1
            border.color: Colors.withAlpha(Services.Theme.muted, 0.65)

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 18

            clip: true

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                onClicked: function(mouse) {
                    mouse.accepted = true;
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Services.Theme.spacing.md
                spacing: Services.Theme.spacing.sm

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: overviewWindow.headerHeight

                    Text {
                        text: "Workspaces"
                        color: Services.Theme.fg
                        opacity: 0.9

                        font.family: Services.Theme.font.family
                        font.pixelSize: Services.Theme.font.small
                        font.bold: true
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "Esc"
                        color: Services.Theme.muted

                        font.family: Services.Theme.font.family
                        font.pixelSize: Services.Theme.font.tiny
                        font.bold: true
                    }
                }

                GridLayout {
                    id: workspaceGrid

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    columns: overviewWindow.columnCount
                    columnSpacing: Services.Theme.spacing.sm
                    rowSpacing: Services.Theme.spacing.sm

                    Repeater {
                        model: root.hostConfig.workspaceCount

                        delegate: OverviewWidgets.WorkspaceCard {
                            required property int index

                            workspaceId: index + 1
                            workspace: overviewWindow.workspaceById(index + 1)

                            onWorkspaceClicked: function(workspaceId) {
                                overviewWindow.focusWorkspace(workspaceId);
                            }

                            onWindowClicked: function(window) {
                                overviewWindow.focusWindow(window);
                            }
                        }
                    }
                }
            }
        }
    }
}
