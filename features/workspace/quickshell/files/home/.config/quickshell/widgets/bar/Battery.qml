import QtQuick
import QtQuick.Layouts

import "../../services" as Services

RowLayout {
    id: root

    spacing: 2
    visible: Services.Hardware.hasBattery

    readonly property color batteryColor: {
        if (Services.Hardware.batteryStatus === "Charging")
            return Services.Theme.yellow;
        if (Services.Hardware.batteryPercent < 20)
            return Services.Theme.red;
        return Services.Theme.green;
    }

    Text {
        text: Services.Hardware.batteryIcon
        color: root.batteryColor
        font.family: Services.Theme.font.family
        font.pixelSize: 20
    }

    Text {
        text: Services.Hardware.batteryPercent + "%"
        color: Services.Theme.fg
        font.pixelSize: Services.Theme.font.size
        font.family: Services.Theme.font.family
        font.bold: true
    }
}
