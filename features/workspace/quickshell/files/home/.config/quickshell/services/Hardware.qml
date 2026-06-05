pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property bool bluetoothConnected: false
    property string bluetoothDevice: ""

    property bool hasBattery: false
    property int batteryPercent: 0
    property string batteryStatus: "Discharging"

    readonly property string batteryIcon: {
        if (batteryStatus === "Charging")
            return "";
        if (batteryPercent >= 90)
            return "";
        if (batteryPercent >= 60)
            return "";
        if (batteryPercent >= 40)
            return "";
        if (batteryPercent >= 10)
            return "";
        return "";
    }

    property Timer refreshTimer
    property Process bluetoothProc
    property Process batteryProc

    function refresh() {
        root.bluetoothProc.running = true;
        root.batteryProc.running = true;
    }

    refreshTimer: Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: root.refresh()
    }

    bluetoothProc: Process {
        command: ["sh", "-c", "bluetoothctl info | grep 'Name' | cut -d ' ' -f 2-"]
        running: false

        stdout: SplitParser {
            onRead: function (data) {
                if (data && data.trim() !== "") {
                    root.bluetoothConnected = true;
                    root.bluetoothDevice = data.trim();
                } else {
                    root.bluetoothConnected = false;
                    root.bluetoothDevice = "";
                }
            }
        }
    }

    batteryProc: Process {
        command: ["sh", "-c", `
            BAT=$(ls /sys/class/power_supply/ | grep '^BAT' | head -n 1)
            if [ -z "$BAT" ]; then
                echo 'NO_BAT'
            else
                cat /sys/class/power_supply/$BAT/capacity
                cat /sys/class/power_supply/$BAT/status
            fi
        `]
        running: false

        stdout: SplitParser {
            splitMarker: "\n"

            onRead: function (data) {
                if (!data)
                    return;

                if (data.includes("NO_BAT")) {
                    root.hasBattery = false;
                    return;
                }

                root.hasBattery = true;

                if (data.match(/^\d+$/)) {
                    root.batteryPercent = parseInt(data);
                } else if (data.length > 2) {
                    root.batteryStatus = data.trim();
                }
            }
        }
    }
}
