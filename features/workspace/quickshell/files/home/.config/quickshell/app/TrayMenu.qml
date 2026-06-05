pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts

import "../services" as Services
import "../widgets/tray" as TrayWidgets
import "../utils/colors.js" as Colors

Variants {
    id: root

    required property var hostConfig

    model: Quickshell.screens

    PanelWindow {
        id: menuWindow

        required property var modelData

        screen: modelData
        visible: modelData.name === root.hostConfig.primaryScreen
                 && Services.TrayMenu.isOpen
                 && Services.TrayMenu.currentMenu !== null

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
                Services.TrayMenu.close();
            }
        }

        Rectangle {
            id: panel

            readonly property int wantedWidth: 280
            readonly property int safeMargin: 12
            readonly property int maxBodyHeight: 340

            readonly property real activeListHeight: {
                if (Services.TrayMenu.depth === 1)
                    return level1List.implicitHeight;
                if (Services.TrayMenu.depth === 2)
                    return level2List.implicitHeight;
                if (Services.TrayMenu.depth === 3)
                    return level3List.implicitHeight;

                return level0List.implicitHeight;
            }

            readonly property int correctedX: Math.max(
                safeMargin,
                Math.min(
                    Services.TrayMenu.anchorX - wantedWidth / 2,
                    menuWindow.width - wantedWidth - safeMargin
                )
            )

            x: correctedX
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 14

            width: wantedWidth
            height: Math.min(content.implicitHeight + Services.Theme.spacing.lg, 460)

            radius: Services.Theme.radius.md
            color: Colors.withAlpha(Services.Theme.bg, 0.98)
            border.width: 1
            border.color: Colors.withAlpha(Services.Theme.blue, 0.65)

            clip: true

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                onClicked: function(mouse) {
                    mouse.accepted = true;
                }
            }

            ColumnLayout {
                id: content

                anchors.fill: parent
                anchors.margins: Services.Theme.spacing.md
                spacing: Services.Theme.spacing.sm

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 28
                    spacing: Services.Theme.spacing.sm

                    Rectangle {
                        visible: Services.TrayMenu.canGoBack

                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28

                        radius: Services.Theme.radius.sm
                        color: backMouse.containsMouse
                            ? Colors.withAlpha(Services.Theme.blue, 0.18)
                            : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "‹"
                            color: Services.Theme.cyan
                            font.family: Services.Theme.font.family
                            font.pixelSize: 22
                            font.bold: true
                        }

                        MouseArea {
                            id: backMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                Services.TrayMenu.popMenu();
                            }
                        }
                    }

                    Image {
                        visible: !Services.TrayMenu.canGoBack
                                 && Services.TrayMenu.activeItem
                                 && Services.TrayMenu.activeItem.icon
                                 && Services.TrayMenu.activeItem.icon.length > 0

                        Layout.preferredWidth: 22
                        Layout.preferredHeight: 22

                        source: Services.TrayMenu.activeItem ? Services.TrayMenu.activeItem.icon : ""
                        sourceSize.width: 64
                        sourceSize.height: 64
                        fillMode: Image.PreserveAspectFit
                        mipmap: true
                        smooth: true
                    }

                    ColumnLayout {
                        id: titleBlock

                        Layout.fillWidth: true
                        Layout.maximumWidth: panel.wantedWidth - 92
                        Layout.preferredWidth: panel.wantedWidth - 92

                        spacing: 1

                        Text {
                            Layout.fillWidth: true
                            Layout.maximumWidth: titleBlock.Layout.maximumWidth

                            text: Services.TrayMenu.title
                            color: Services.Theme.fg
                            font.family: Services.Theme.font.family
                            font.pixelSize: Services.Theme.font.small
                            font.bold: true

                            maximumLineCount: 1
                            wrapMode: Text.NoWrap
                            elide: Text.ElideRight
                        }

                        Text {
                            visible: Services.TrayMenu.description.length > 0

                            Layout.fillWidth: true
                            Layout.maximumWidth: titleBlock.Layout.maximumWidth

                            text: Services.TrayMenu.description
                            color: Services.Theme.muted
                            font.family: Services.Theme.font.family
                            font.pixelSize: Services.Theme.font.tiny

                            maximumLineCount: 1
                            wrapMode: Text.NoWrap
                            elide: Text.ElideRight
                        }
                    }

                    Rectangle {
                        id: closeButton

                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28

                        radius: Services.Theme.radius.sm
                        color: closeMouse.containsMouse
                            ? Colors.withAlpha(Services.Theme.red, 0.18)
                            : "transparent"

                        Text {
                            anchors.centerIn: parent

                            text: "×"
                            color: closeMouse.containsMouse ? Services.Theme.red : Services.Theme.muted
                            font.family: Services.Theme.font.family
                            font.pixelSize: 18
                            font.bold: true
                        }

                        MouseArea {
                            id: closeMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                Services.TrayMenu.close();
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Colors.withAlpha(Services.Theme.muted, 0.35)
                }

                Item {
                    id: menuBody

                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(panel.activeListHeight, panel.maxBodyHeight)

                    clip: true

                    Flickable {
                        id: level0Body

                        anchors.fill: parent
                        visible: Services.TrayMenu.depth === 0

                        contentWidth: width
                        contentHeight: level0List.implicitHeight
                        interactive: contentHeight > height
                        boundsBehavior: Flickable.StopAtBounds
                        clip: true

                        TrayWidgets.TrayMenuList {
                            id: level0List

                            width: level0Body.width
                            menuHandle: Services.TrayMenu.rootMenu
                        }
                    }

                    Flickable {
                        id: level1Body

                        anchors.fill: parent
                        visible: Services.TrayMenu.depth === 1

                        contentWidth: width
                        contentHeight: level1List.implicitHeight
                        interactive: contentHeight > height
                        boundsBehavior: Flickable.StopAtBounds
                        clip: true

                        TrayWidgets.TrayMenuList {
                            id: level1List

                            width: level1Body.width
                            menuHandle: Services.TrayMenu.level1Menu
                        }
                    }

                    Flickable {
                        id: level2Body

                        anchors.fill: parent
                        visible: Services.TrayMenu.depth === 2

                        contentWidth: width
                        contentHeight: level2List.implicitHeight
                        interactive: contentHeight > height
                        boundsBehavior: Flickable.StopAtBounds
                        clip: true

                        TrayWidgets.TrayMenuList {
                            id: level2List

                            width: level2Body.width
                            menuHandle: Services.TrayMenu.level2Menu
                        }
                    }

                    Flickable {
                        id: level3Body

                        anchors.fill: parent
                        visible: Services.TrayMenu.depth === 3

                        contentWidth: width
                        contentHeight: level3List.implicitHeight
                        interactive: contentHeight > height
                        boundsBehavior: Flickable.StopAtBounds
                        clip: true

                        TrayWidgets.TrayMenuList {
                            id: level3List

                            width: level3Body.width
                            menuHandle: Services.TrayMenu.level3Menu
                        }
                    }
                }
            }
        }
    }
}
