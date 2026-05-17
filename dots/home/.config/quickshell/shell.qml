pragma ComponentBehavior: Bound
//@ pragma UseQApplication
import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "theme"
import "services"
import "components"

ShellRoot {
    id: root

    HardwareService {
        id: hardwareService
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel

            required property var modelData
            screen: modelData
            visible: modelData.name === "DP-3"

            anchors.bottom: true
            width: visualDock.width
            height: dockLogic.zoneHeight
            exclusiveZone: dockLogic.exclusiveZone
            color: "transparent"

            QtObject {
                id: dockLogic
                property bool autoHideEnabled: false
                property int panelHeight: 60
                property int contentHeight: 40

                property bool isHovered: dockHover.hovered
                property bool isFullscreen: Hyprland.activeWindow.fullscreen

                readonly property bool isVisible: isHovered || (!autoHideEnabled && !isFullscreen)
                readonly property int exclusiveZone: (!autoHideEnabled && !isFullscreen) ? panelHeight : 0
                readonly property int zoneHeight: panelHeight
                readonly property int bottomMargin: isVisible ? 10 : (-contentHeight - 20)
            }

            HoverHandler {
                id: dockHover
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            }

            Rectangle {
                id: visualDock

                height: dockLogic.contentHeight
                width: mainLayout.implicitWidth + 20
                radius: 5

                color: Theme.bg
                border.width: 1
                border.color: Qt.rgba(Theme.muted.r, Theme.muted.g, Theme.muted.b, 0.5)

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: dockLogic.bottomMargin

                Behavior on anchors.bottomMargin {
                    NumberAnimation {
                        duration: Theme.animationDuration
                        easing.type: Easing.InOutQuad
                    }
                }

                RowLayout {
                    id: mainLayout
                    anchors.centerIn: parent
                    spacing: Theme.spacing

                    Clock {}

                    Divider {}

                    Workspaces {}

                    Divider {}

                    StatusIndicators {
                        hardwareService: hardwareService
                        dockPanel: panel
                    }
                }
            }
        }
    }
}
