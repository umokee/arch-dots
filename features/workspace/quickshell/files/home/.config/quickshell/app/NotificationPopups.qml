pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts

import "../services" as Services
import "../widgets/notifications" as NotificationWidgets

Variants {
    id: root

    required property var hostConfig

    model: Quickshell.screens

    PanelWindow {
        id: popupWindow

        required property var modelData

        screen: modelData
        visible: modelData.name === root.hostConfig.primaryScreen
                 && Services.Notifications.popups.length > 0
                 && !Services.Notifications.centerOpen

        anchors.left: true
        anchors.right: true
        anchors.bottom: true

        height: 340
        exclusiveZone: 0
        color: "transparent"

        mask: Region {
            item: popupStack
        }

        Item {
            anchors.fill: parent

            ColumnLayout {
                id: popupStack

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 20

                width: 420
                spacing: Services.Theme.spacing.sm

                Repeater {
                    model: Services.Notifications.popups

                    delegate: NotificationWidgets.NotificationCard {
                        required property var modelData

                        notification: modelData
                        popupMode: true

                        Layout.preferredWidth: 420
                    }
                }
            }
        }
    }
}
