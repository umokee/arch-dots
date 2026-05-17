pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import "../theme"

RowLayout {
    id: widget

    required property var hardwareService
    required property var dockPanel

    spacing: Theme.spacingSmall

    Rectangle {
        Layout.preferredWidth: 24
        Layout.preferredHeight: 24
        color: "transparent"

        Text {
            anchors.centerIn: parent
            text: widget.hardwareService.micMuted ? "M" : "UM"//"" : ""
            color: widget.hardwareService.micMuted ? Theme.muted : Theme.red
            font.family: Theme.font
            font.pixelSize: 20
        }

        TapHandler {
            onTapped: widget.hardwareService.toggleMic()
        }
    }

    // Audio output switcher
    Text {
        visible: widget.hardwareService.audioSinks.length > 1
        text: widget.hardwareService.currentSinkName ? widget.hardwareService.currentSinkName.charAt(0).toUpperCase() : "?"
        color: Theme.cyan
        font.family: Theme.font
        font.pixelSize: 18
        font.bold: true

        TapHandler {
            onTapped: widget.hardwareService.cycleAudioSink()
        }
    }

    Rectangle {
        Layout.preferredWidth: 24
        Layout.preferredHeight: 24
        color: "transparent"
        visible: widget.hardwareService.btConnected

        Text {
            anchors.centerIn: parent
            text: ""
            color: Theme.blue
            font.family: Theme.font
            font.pixelSize: 20
        }

        HoverHandler {
            id: btHover
        }

        Rectangle {
            z: 999
            visible: btHover.hovered
            anchors.bottom: parent.top
            anchors.bottomMargin: 8
            anchors.horizontalCenter: parent.horizontalCenter

            width: btText.contentWidth + 16
            height: btText.contentHeight + 8
            radius: Theme.radiusSmall
            color: Theme.bg
            border.width: 1
            border.color: Theme.muted

            Text {
                id: btText
                anchors.centerIn: parent
                text: widget.hardwareService.btDevice
                color: Theme.fg
                font.pixelSize: 12
                font.family: Theme.font
            }
        }
    }

    // Батарея
    RowLayout {
        spacing: 2
        visible: widget.hardwareService.hasBattery

        Text {
            text: widget.hardwareService.batteryIcon
            color: widget.hardwareService.batteryColor
            font.family: Theme.font
            font.pixelSize: 20
        }

        Text {
            text: widget.hardwareService.batPercent + "%"
            color: Theme.fg
            font.pixelSize: Theme.fontSize
            font.bold: true
        }
    }

    // System Tray
    Repeater {
        model: SystemTray.items

        Rectangle {
            required property var modelData

            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            color: "transparent"
            visible: !!modelData.icon

            Image {
                anchors.fill: parent
                sourceSize.width: 128
                sourceSize.height: 128
                source: parent.modelData.icon || ""
                fillMode: Image.PreserveAspectFit
                mipmap: true
                smooth: true
                antialiasing: true
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onClicked: function (mouse) {
                    if (mouse.button === Qt.LeftButton) {
                        parent.modelData.activate();
                    } else if (mouse.button === Qt.RightButton && parent.modelData.hasMenu) {
                        var pos = parent.mapToItem(widget.dockPanel.contentItem, 0, 0);
                        parent.modelData.display(widget.dockPanel, pos.x + 120, pos.y - 5);
                    }
                }
            }
        }
    }
}
