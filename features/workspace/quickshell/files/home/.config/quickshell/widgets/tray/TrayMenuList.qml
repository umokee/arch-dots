pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts

import "../../services" as Services
import "../../utils/colors.js" as Colors

ColumnLayout {
    id: root

    required property var menuHandle

    spacing: 2

    QsMenuOpener {
        id: opener
        menu: root.menuHandle
    }

    Repeater {
        model: opener.children

        delegate: ColumnLayout {
            id: entryBlock

            required property var modelData

            Layout.fillWidth: true
            spacing: 2

            readonly property bool isSeparator: modelData.isSeparator
            readonly property bool hasChildren: modelData.hasChildren

            // Важно:
            // submenu-пункт может быть не совсем "enabled",
            // но его всё равно надо разрешать открывать.
            readonly property bool interactive: hasChildren || modelData.enabled

            readonly property string buttonTypeName: QsMenuButtonType.toString(modelData.buttonType)
            readonly property bool isCheckBox: buttonTypeName === "CheckBox"
            readonly property bool isRadioButton: buttonTypeName === "RadioButton"
            readonly property bool isToggle: isCheckBox || isRadioButton

            readonly property bool checked: modelData.checkState === Qt.Checked
            readonly property bool partiallyChecked: modelData.checkState === Qt.PartiallyChecked

            Rectangle {
                visible: entryBlock.isSeparator

                Layout.fillWidth: true
                Layout.preferredHeight: 1
                Layout.leftMargin: Services.Theme.spacing.sm
                Layout.rightMargin: Services.Theme.spacing.sm
                Layout.topMargin: 6
                Layout.bottomMargin: 6

                color: Colors.withAlpha(Services.Theme.muted, 0.35)
            }

            Rectangle {
                id: row

                visible: !entryBlock.isSeparator

                Layout.fillWidth: true
                Layout.preferredHeight: 34

                radius: Services.Theme.radius.sm

                color: rowMouse.containsMouse && entryBlock.interactive
                    ? Colors.withAlpha(Services.Theme.blue, 0.18)
                    : "transparent"

                opacity: entryBlock.interactive ? 1.0 : 0.45

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Services.Theme.spacing.sm
                    anchors.rightMargin: Services.Theme.spacing.sm
                    spacing: Services.Theme.spacing.sm

                    Item {
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20

                        // Radio button
                        Rectangle {
                            visible: entryBlock.isRadioButton

                            anchors.centerIn: parent
                            width: 13
                            height: 13
                            radius: 7

                            color: "transparent"
                            border.width: 1
                            border.color: entryBlock.checked
                                ? Services.Theme.green
                                : Colors.withAlpha(Services.Theme.muted, 0.65)

                            Rectangle {
                                visible: entryBlock.checked

                                anchors.centerIn: parent
                                width: 7
                                height: 7
                                radius: 4
                                color: Services.Theme.green
                            }
                        }

                        // Checkbox
                        Rectangle {
                            visible: entryBlock.isCheckBox

                            anchors.centerIn: parent
                            width: 13
                            height: 13
                            radius: 3

                            color: entryBlock.checked || entryBlock.partiallyChecked
                                ? Colors.withAlpha(Services.Theme.green, 0.25)
                                : "transparent"

                            border.width: 1
                            border.color: entryBlock.checked || entryBlock.partiallyChecked
                                ? Services.Theme.green
                                : Colors.withAlpha(Services.Theme.muted, 0.65)

                            Text {
                                visible: entryBlock.checked || entryBlock.partiallyChecked

                                anchors.centerIn: parent
                                text: entryBlock.partiallyChecked ? "−" : "✓"
                                color: Services.Theme.green
                                font.family: Services.Theme.font.family
                                font.pixelSize: 10
                                font.bold: true
                            }
                        }

                        // Обычная иконка, если это не checkbox/radio
                        Image {
                            visible: !entryBlock.isToggle
                                     && entryBlock.modelData.icon
                                     && entryBlock.modelData.icon.length > 0

                            anchors.fill: parent

                            source: entryBlock.modelData.icon || ""
                            sourceSize.width: 64
                            sourceSize.height: 64
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
                            smooth: true
                        }
                    }

                    Text {
                        Layout.fillWidth: true

                        text: entryBlock.modelData.text || ""
                        color: entryBlock.interactive ? Services.Theme.fg : Services.Theme.muted
                        font.family: Services.Theme.font.family
                        font.pixelSize: Services.Theme.font.small
                        elide: Text.ElideRight
                    }

                    Text {
                        visible: entryBlock.hasChildren

                        text: "›"
                        color: Services.Theme.muted
                        font.family: Services.Theme.font.family
                        font.pixelSize: 18
                        font.bold: true
                    }
                }

                MouseArea {
                    id: rowMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton

                    cursorShape: entryBlock.interactive
                        ? Qt.PointingHandCursor
                        : Qt.ArrowCursor

                    onClicked: {
                        // 1. Submenu открываем первым.
                        // Это важно, потому что некоторые submenu-пункты
                        // могут выглядеть как disabled, но children у них есть.
                        if (entryBlock.hasChildren) {
                            Services.TrayMenu.pushMenu(
                                entryBlock.modelData,
                                entryBlock.modelData.text || "Submenu"
                            );
                            return;
                        }

                        // 2. Disabled обычный пункт не трогаем.
                        if (!entryBlock.modelData.enabled)
                            return;

                        // 3. Checkbox/radio: trigger, но меню НЕ закрываем.
                        // Так можно включать/выключать Networking/Wi-Fi,
                        // не открывая меню заново.
                        if (entryBlock.isToggle) {
                            entryBlock.modelData.triggered();
                            return;
                        }

                        // 4. Обычный action: trigger + закрыть меню.
                        entryBlock.modelData.triggered();
                        Services.TrayMenu.close();
                    }
                }
            }
        }
    }
}
