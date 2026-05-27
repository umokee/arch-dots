import QtQuick
import "../theme"

Text {
    id: clockText

    text: Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
    color: Theme.blue
    font.pixelSize: Theme.fontSize
    font.family: Theme.font
    font.bold: true

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: clockText.text = Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
    }
}
