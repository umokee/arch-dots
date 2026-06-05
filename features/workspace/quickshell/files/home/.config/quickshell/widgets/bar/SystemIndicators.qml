import QtQuick
import QtQuick.Layouts

import "../../services" as Services
import "../../widgets/common" as Common
import "../../utils/format.js" as Format

RowLayout {
    id: root

    required property var dockPanel

    spacing: Services.Theme.spacing.xs

    Common.IconButton {
        text: Services.Audio.micMuted ? "M" : "UM"
        textColor: Services.Audio.micMuted ? Services.Theme.muted : Services.Theme.red
        textSize: 20

        onClicked: Services.Audio.toggleMic()
    }

    Common.IconButton {
        visible: Services.Audio.audioSinks.length > 1
        text: Format.audioSinkShortName(Services.Audio.currentSinkName)
        textColor: Services.Theme.cyan
        textSize: 18
        bold: true

        onClicked: Services.Audio.cycleAudioSink()
    }

    Common.IconButton {
        id: bluetoothButton

        visible: Services.Hardware.bluetoothConnected
        text: ""
        textColor: Services.Theme.blue
        textSize: 20
    }

    Rectangle {
        z: 999
        visible: bluetoothButton.visible && bluetoothButton.hovered

        anchors.bottom: bluetoothButton.top
        anchors.bottomMargin: Services.Theme.spacing.md
        anchors.horizontalCenter: bluetoothButton.horizontalCenter

        width: btText.contentWidth + Services.Theme.spacing.lg
        height: btText.contentHeight + Services.Theme.spacing.md
        radius: Services.Theme.radius.xs
        color: Services.Theme.bg
        border.width: 1
        border.color: Services.Theme.muted

        Text {
            id: btText
            anchors.centerIn: parent
            text: Services.Hardware.bluetoothDevice
            color: Services.Theme.fg
            font.pixelSize: Services.Theme.font.small
            font.family: Services.Theme.font.family
        }
    }

    Battery {}

    Tray {
        dockPanel: root.dockPanel
    }
}
