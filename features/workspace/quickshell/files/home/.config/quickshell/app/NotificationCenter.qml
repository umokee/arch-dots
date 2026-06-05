pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts

import "../services" as Services
import "../widgets/notifications" as NotificationWidgets
import "../utils/colors.js" as Colors

Variants {
    id: root

    required property var hostConfig

    model: Quickshell.screens

    PanelWindow {
        id: centerWindow

        required property var modelData

        screen: modelData
        visible: modelData.name === root.hostConfig.primaryScreen
                 && Services.Notifications.centerOpen

        anchors.left: true
        anchors.right: true
        anchors.top: true
        anchors.bottom: true

        exclusiveZone: 0
        color: "transparent"

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

            onClicked: {
                Services.Notifications.closeCenter();
            }
        }

        Rectangle {
            id: panel

            width: 460
            height: 470
            radius: Services.Theme.radius.md

            color: Colors.withAlpha(Services.Theme.bg, 0.98)
            border.width: 1
            border.color: Colors.withAlpha(Services.Theme.blue, 0.6)

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                onClicked: function(mouse) {
                    mouse.accepted = true;
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Services.Theme.spacing.lg
                spacing: Services.Theme.spacing.md

                RowLayout {
                    Layout.fillWidth: true

                    ColumnLayout {
                        spacing: 2

                        Text {
                            text: "Notifications"
                            color: Services.Theme.fg
                            font.family: Services.Theme.font.family
                            font.pixelSize: 20
                            font.bold: true
                        }

                        Text {
                            text: Services.Notifications.count + " total"
                            color: Services.Theme.muted
                            font.family: Services.Theme.font.family
                            font.pixelSize: Services.Theme.font.small
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        Layout.preferredHeight: 30
                        Layout.preferredWidth: dndText.implicitWidth + Services.Theme.spacing.lg

                        radius: Services.Theme.radius.sm
                        color: Services.Notifications.dndEnabled
                            ? Colors.withAlpha(Services.Theme.red, 0.22)
                            : Colors.withAlpha(Services.Theme.surfaceVariant, 0.8)

                        border.width: 1
                        border.color: Services.Notifications.dndEnabled
                            ? Services.Theme.red
                            : Colors.withAlpha(Services.Theme.muted, 0.55)

                        Text {
                            id: dndText

                            anchors.centerIn: parent
                            text: Services.Notifications.dndEnabled ? "DND on" : "DND off"
                            color: Services.Notifications.dndEnabled ? Services.Theme.red : Services.Theme.cyan
                            font.family: Services.Theme.font.family
                            font.pixelSize: Services.Theme.font.small
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                Services.Notifications.toggleDnd();
                            }
                        }
                    }

                    Rectangle {
                        Layout.preferredHeight: 30
                        Layout.preferredWidth: clearText.implicitWidth + Services.Theme.spacing.lg

                        radius: Services.Theme.radius.sm
                        color: Colors.withAlpha(Services.Theme.surfaceVariant, 0.8)
                        border.width: 1
                        border.color: Colors.withAlpha(Services.Theme.muted, 0.55)

                        Text {
                            id: clearText

                            anchors.centerIn: parent
                            text: "Clear"
                            color: Services.Theme.yellow
                            font.family: Services.Theme.font.family
                            font.pixelSize: Services.Theme.font.small
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                Services.Notifications.clearAll();
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Colors.withAlpha(Services.Theme.muted, 0.45)
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Text {
                        visible: Services.Notifications.count === 0
                        anchors.centerIn: parent

                        text: "No notifications"
                        color: Services.Theme.muted
                        font.family: Services.Theme.font.family
                        font.pixelSize: Services.Theme.font.size
                        font.bold: true
                    }

                    ListView {
                        visible: Services.Notifications.count > 0
                        anchors.fill: parent

                        spacing: Services.Theme.spacing.sm
                        clip: true
                        model: Services.Notifications.notifications

                        delegate: NotificationWidgets.NotificationCard {
                            required property var modelData

                            width: ListView.view.width
                            notification: modelData
                            popupMode: false
                        }
                    }
                }
            }
        }
    }
}
