import QtQuick
import QtQuick.Layouts

import "../../services" as Services
import "../../widgets/common" as Common

RowLayout {
    id: root

    spacing: 2

    Common.IconButton {
        text: Services.Notifications.dndEnabled ? "󰂛" : "󰂚"
        textColor: Services.Notifications.dndEnabled
            ? Services.Theme.red
            : Services.Notifications.unreadCount > 0
                ? Services.Theme.yellow
                : Services.Theme.blue
        textSize: 19

        onClicked: Services.Notifications.toggleCenter()
    }

    Text {
        visible: Services.Notifications.unreadCount > 0

        text: Services.Notifications.unreadCount
        color: Services.Theme.yellow
        font.family: Services.Theme.font.family
        font.pixelSize: Services.Theme.font.small
        font.bold: true

        Layout.alignment: Qt.AlignVCenter
    }
}
