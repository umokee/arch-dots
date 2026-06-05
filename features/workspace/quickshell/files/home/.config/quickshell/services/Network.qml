pragma Singleton

import QtQuick

QtObject {
    id: root

    // Пока не используется в панели. Оставлено как отдельный сервис,
    // чтобы потом не смешивать NetworkManager/nmcli с UI-компонентами.
    property bool online: true
    property string activeConnection: ""
}
