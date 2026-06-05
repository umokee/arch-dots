pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import "../../services" as Services
import "../../utils/format.js" as Format

RowLayout {
    id: root

    required property int workspaceCount
    required property int activeWorkspaceId
    required property var occupiedWorkspaceIds

    signal workspaceClicked(int workspaceId)

    spacing: Services.Theme.spacing.xs

    Repeater {
        model: root.workspaceCount

        delegate: Rectangle {
            id: wsButton

            required property int index

            readonly property int workspaceId: index + 1
            readonly property bool isActive: root.activeWorkspaceId === workspaceId
            readonly property bool hasWindows: Format.includes(root.occupiedWorkspaceIds, workspaceId)
            readonly property string icon: Format.workspaceIcon(index)

            Layout.preferredWidth: 24
            Layout.preferredHeight: 28
            color: "transparent"

            Text {
                anchors.centerIn: parent
                text: wsButton.isActive ? wsButton.workspaceId : wsButton.icon
                color: wsButton.isActive || wsButton.hasWindows ? Services.Theme.cyan : Services.Theme.muted
                font.pixelSize: Services.Theme.font.size
                font.family: Services.Theme.font.family
                font.bold: true
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                width: parent.width - 8
                height: 3
                radius: 2
                color: wsButton.isActive ? Services.Theme.purple : "transparent"
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton
                cursorShape: Qt.PointingHandCursor

                onClicked: root.workspaceClicked(wsButton.workspaceId)
            }
        }
    }
}
