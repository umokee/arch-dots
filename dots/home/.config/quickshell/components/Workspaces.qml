import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../theme"

Repeater {
    model: 15

    Rectangle {
        required property int index

        Layout.preferredWidth: 24
        Layout.preferredHeight: parent.height
        color: "transparent"

        property int wsId: index + 1
        property bool isActive: Hyprland.focusedWorkspace.id === wsId
        property bool hasWindows: Hyprland.workspaces.values.some(w => w.id === wsId)
        property var icons: ["", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]

        Text {
            anchors.centerIn: parent
            text: parent.isActive ? parent.wsId : parent.icons[parent.index]
            color: parent.isActive || parent.hasWindows ? Theme.cyan : Theme.muted
            font.pixelSize: Theme.fontSize
            font.family: Theme.font
            font.bold: true
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            width: parent.width - 8
            height: 3
            radius: 2
            color: parent.isActive ? Theme.purple : "transparent"
        }

        TapHandler {
            onTapped: Hyprland.dispatch("workspace " + parent.wsId)
        }
    }
}
