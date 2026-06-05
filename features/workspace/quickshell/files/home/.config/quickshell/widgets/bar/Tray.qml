pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray

import "../../services" as Services

RowLayout {
    id: root

    required property var dockPanel

    spacing: Services.Theme.spacing.sm

    Repeater {
        model: SystemTray.items

        Rectangle {
            id: trayIcon

            required property var modelData

            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            color: "transparent"
            visible: !!modelData.icon

            Image {
                anchors.fill: parent

                sourceSize.width: 128
                sourceSize.height: 128
                source: trayIcon.modelData.icon || ""
                fillMode: Image.PreserveAspectFit
                mipmap: true
                smooth: true
                antialiasing: true
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                cursorShape: Qt.PointingHandCursor

                onClicked: function(mouse) {
                    if (mouse.button === Qt.LeftButton) {
                        if (trayIcon.modelData.onlyMenu && trayIcon.modelData.hasMenu) {
                            const pos = trayIcon.mapToItem(root.dockPanel.contentItem, trayIcon.width / 2, trayIcon.height / 2);
                            Services.TrayMenu.open(trayIcon.modelData, pos.x);
                        } else {
                            trayIcon.modelData.activate();
                        }

                        return;
                    }

                    if (mouse.button === Qt.MiddleButton) {
                        trayIcon.modelData.secondaryActivate();
                        return;
                    }

                    if (mouse.button === Qt.RightButton && trayIcon.modelData.hasMenu) {
                        const pos = trayIcon.mapToItem(root.dockPanel.contentItem, trayIcon.width / 2, trayIcon.height / 2);
                        Services.TrayMenu.open(trayIcon.modelData, pos.x);
                    }
                }
            }
        }
    }
}
