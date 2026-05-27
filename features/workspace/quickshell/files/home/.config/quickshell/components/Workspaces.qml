import "../theme"
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

Repeater {
    id: workspaceRepeater

    property int workspaceCount: 10

    model: workspaceCount

    Rectangle {
        id: wsButton

        required property int index
        property int wsId: index + 1
        property bool isActive: Hyprland.focusedWorkspace.id === wsId
        property bool hasWindows: Hyprland.workspaces.values.some((w) => {
            return w.id === wsId;
        })
        property var icons: ["", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]
        property string icon: index < icons.length ? icons[index] : ""

        Layout.preferredWidth: 24
        Layout.preferredHeight: parent.height
        color: "transparent"

        Text {
            anchors.centerIn: parent
            text: wsButton.isActive ? wsButton.wsId : wsButton.icon
            color: wsButton.isActive || wsButton.hasWindows ? Theme.cyan : Theme.muted
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
            color: wsButton.isActive ? Theme.purple : "transparent"
        }

        MouseArea {
            anchors.fill: parent
            z: 999
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                Hyprland.dispatch('hl.dsp.focus({ workspace = "' + wsButton.wsId + '" })');
            }
        }

    }

}
