import QtQuick
import QtQuick.Layouts

import "../../services" as Services

Text {
    property color iconColor: Services.Theme.fg
    property int iconSize: Services.Theme.font.size

    color: iconColor
    font.family: Services.Theme.font.family
    font.pixelSize: iconSize
    font.bold: true

    Layout.alignment: Qt.AlignVCenter
}
