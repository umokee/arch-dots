pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications

import "../../services" as Services
import "../../utils/format.js" as Format
import "../../utils/colors.js" as Colors

Rectangle {
    id: root

    required property var notification

    property bool popupMode: false
    property bool hovered: mouseArea.containsMouse

    readonly property bool critical: Services.Notifications.isCritical(notification)

    signal requestClose()

    width: popupMode ? 420 : parent.width
    implicitHeight: content.implicitHeight + Services.Theme.spacing.lg

    radius: Services.Theme.radius.md
    color: Colors.withAlpha(Services.Theme.bg, 0.96)
    border.width: 1
    border.color: critical ? Services.Theme.red : Colors.withAlpha(Services.Theme.blue, 0.55)

    opacity: 1

    Behavior on opacity {
        NumberAnimation {
            duration: Services.Theme.animation.fast
        }
    }

    Timer {
        interval: {
            if (!root.notification)
                return 5000;

            if (root.notification.expireTimeout > 0)
                return Math.max(3000, root.notification.expireTimeout * 1000);

            return 5000;
        }

        running: root.popupMode && !root.hovered && !root.critical
        repeat: false

        onTriggered: {
            Services.Notifications.hidePopup(root.notification.id);
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: function(mouse) {
            if (mouse.button === Qt.RightButton) {
                Services.Notifications.dismiss(root.notification.id);
            }
        }
    }

    ColumnLayout {
        id: content

        anchors.fill: parent
        anchors.margins: Services.Theme.spacing.md
        spacing: Services.Theme.spacing.sm

        RowLayout {
            Layout.fillWidth: true
            spacing: Services.Theme.spacing.sm

            Text {
                text: root.notification.appName || "Application"
                color: root.critical ? Services.Theme.red : Services.Theme.blue
                font.family: Services.Theme.font.family
                font.pixelSize: Services.Theme.font.small
                font.bold: true

                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Text {
                text: Format.relativeTime(new Date())
                color: Services.Theme.muted
                font.family: Services.Theme.font.family
                font.pixelSize: Services.Theme.font.tiny
            }

            Text {
                text: "×"
                color: Services.Theme.muted
                font.family: Services.Theme.font.family
                font.pixelSize: 18
                font.bold: true

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        Services.Notifications.dismiss(root.notification.id);
                    }
                }
            }
        }

        Text {
            visible: root.notification.summary && root.notification.summary.length > 0
            text: root.notification.summary
            color: Services.Theme.fg
            font.family: Services.Theme.font.family
            font.pixelSize: Services.Theme.font.size
            font.bold: true

            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            maximumLineCount: root.popupMode ? 2 : 3
            elide: Text.ElideRight
            textFormat: Text.PlainText
        }

        Text {
            visible: root.notification.body && root.notification.body.length > 0
            text: root.notification.body
            color: Services.Theme.fg
            opacity: 0.85
            font.family: Services.Theme.font.family
            font.pixelSize: Services.Theme.font.small

            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            maximumLineCount: root.popupMode ? 3 : 6
            elide: Text.ElideRight
            textFormat: Text.PlainText
        }

        RowLayout {
            visible: root.notification.actions && root.notification.actions.length > 0
            Layout.fillWidth: true
            spacing: Services.Theme.spacing.sm

            Repeater {
                model: root.notification.actions || []

                delegate: Rectangle {
                    id: actionButton

                    required property var modelData

                    Layout.preferredHeight: 28
                    Layout.preferredWidth: actionText.implicitWidth + Services.Theme.spacing.lg

                    radius: Services.Theme.radius.sm
                    color: Colors.withAlpha(Services.Theme.surfaceVariant, 0.9)
                    border.width: 1
                    border.color: Colors.withAlpha(Services.Theme.blue, 0.35)

                    Text {
                        id: actionText

                        anchors.centerIn: parent
                        text: actionButton.modelData.text
                        color: Services.Theme.cyan
                        font.family: Services.Theme.font.family
                        font.pixelSize: Services.Theme.font.small
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            actionButton.modelData.invoke();
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
            }
        }
    }
}
