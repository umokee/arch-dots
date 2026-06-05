pragma Singleton

import QtQuick
import "../utils/format.js" as Format

QtObject {
    id: root

    property date now: new Date()
    readonly property string text: Format.clock(now)

    property Timer refreshTimer

    refreshTimer: Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: root.now = new Date()
    }
}
