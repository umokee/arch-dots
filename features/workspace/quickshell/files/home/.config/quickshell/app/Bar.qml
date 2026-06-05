pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts

import "../services" as Services
import "../widgets/bar" as BarWidgets
import "../widgets/common" as Common
import "../utils/colors.js" as Colors

Variants {
    id: root

    required property var hostConfig

    model: Quickshell.screens

    PanelWindow {
        id: panel

        required property var modelData

        screen: modelData
        visible: modelData.name === root.hostConfig.primaryScreen

        anchors.left: true
        anchors.right: true
        anchors.bottom: true

        height: dock.zoneHeight
        exclusiveZone: dock.exclusiveZone
        color: "transparent"

        QtObject {
            id: dock

            property bool autoHideEnabled: false
            property int panelHeight: 60
            property int contentHeight: 40

            readonly property bool isHovered: dockHover.hovered
            readonly property bool isFullscreen: Services.Hyprland.activeWindowFullscreen
            readonly property bool isVisible: isHovered || (!autoHideEnabled && !isFullscreen)
            readonly property int exclusiveZone: (!autoHideEnabled && !isFullscreen) ? panelHeight : 0
            readonly property int zoneHeight: panelHeight
            readonly property int bottomMargin: isVisible ? 10 : (-contentHeight - 20)
        }

        HoverHandler {
            id: dockHover
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        }

        Common.Panel {
            id: visualDock

            height: dock.contentHeight
            width: mainLayout.implicitWidth + Services.Theme.spacing.xl
            radius: Services.Theme.radius.sm
            backgroundColor: Services.Theme.bg
            borderColor: Colors.withAlpha(Services.Theme.muted, 0.5)

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: dock.bottomMargin

            Behavior on anchors.bottomMargin {
                NumberAnimation {
                    duration: Services.Theme.animation.normal
                    easing.type: Easing.InOutQuad
                }
            }

            RowLayout {
                id: mainLayout

                anchors.centerIn: parent
                spacing: Services.Theme.spacing.md

                BarWidgets.Clock {}

                Common.Divider {}

                BarWidgets.OverviewButton {}

                Common.Divider {}

                BarWidgets.Workspaces {
                    workspaceCount: root.hostConfig.workspaceCount
                    activeWorkspaceId: Services.Hyprland.activeWorkspaceId
                    occupiedWorkspaceIds: Services.Hyprland.occupiedWorkspaceIds

                    onWorkspaceClicked: function (workspaceId) {
                        Services.Hyprland.focusWorkspace(workspaceId);
                    }
                }

                Common.Divider {}

                BarWidgets.NotificationIndicator {}

                Common.Divider {}

                BarWidgets.SystemIndicators {
                    dockPanel: panel
                }
            }
        }
    }
}
