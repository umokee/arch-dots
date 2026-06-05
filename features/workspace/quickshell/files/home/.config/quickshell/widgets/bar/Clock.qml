import QtQuick
import QtQuick.Layouts

import "../../services" as Services

Text {
    text: Services.ClockService.text
    color: Services.Theme.blue
    font.pixelSize: Services.Theme.font.size
    font.family: Services.Theme.font.family
    font.bold: true

    Layout.alignment: Qt.AlignVCenter
}
