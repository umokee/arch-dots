import QtQuick
import QtQuick.Layouts

import "../../services" as Services

Text {
    text: "|"
    color: Services.Theme.muted
    font.pixelSize: 20
    font.family: Services.Theme.font.family

    Layout.alignment: Qt.AlignVCenter
}
