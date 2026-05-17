import QtQuick
import Quickshell.Io
import Quickshell.Hyprland
import "../theme.qml"

QtObject {
    id: hwService

    property bool micMuted: true
    property bool btConnected: false
    property string btDevice: ""
    property bool hasBattery: false
    property int batPercent: 0
    property string batStatus: "Discharging"

    // Audio output (sinks)
    property var audioSinks: []
    property string currentSink: ""
    property string currentSinkName: ""

    // Filter patterns for audio switcher (case-insensitive)
    readonly property var sinkFilters: ["razer", "fifine"]

    readonly property string batteryIcon: {
        if (batStatus === "Charging")
            return "";
        if (batPercent >= 90)
            return "";
        if (batPercent >= 60)
            return "";
        if (batPercent >= 40)
            return "";
        if (batPercent >= 10)
            return "";
        return "";
    }

    readonly property string batteryColor: {
        if (batStatus === "Charging")
            return Theme.yellow;
        if (batPercent < 20)
            return Theme.red;
        return Theme.green;
    }

    property Timer regreshTimer: Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: hwService.refresh()
    }

    function refresh() {
        micProc.running = true;
        btProc.running = true;
        batProc.running = true;
        sinksProc.running = true;
    }

    function toggleMic() {
        Hyprland.dispatch("exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle");

        Qt.callLater(() => {
            micProc.running = true;
        });
    }

    function cycleAudioSink() {
        if (audioSinks.length < 2) return;

        let currentIndex = audioSinks.findIndex(s => s.id === currentSink);
        let nextIndex = (currentIndex + 1) % audioSinks.length;
        let nextSink = audioSinks[nextIndex];

        Hyprland.dispatch("exec wpctl set-default " + nextSink.id);

        Qt.callLater(() => {
            sinksProc.running = true;
        });
    }

    property Process micProc: Process {
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SOURCE@"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                if (!data)
                    return;
                hwService.micMuted = data.includes("MUTED");
            }
        }
    }

    property var _pendingSinks: []

    property Process sinksProc: Process {
        command: ["sh", "-c", `wpctl status | sed -n '/Sinks:/,/Sources:/p' | grep '[0-9]\\+\\.' | perl -pe 's/.*?(\\*?)\\s*(\\d+)\\.\\s+(.+?)\\s+\\[vol:.*/\\1\\2|\\3/'`]
        running: false
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                if (!data || !data.trim()) return;

                let isDefault = data.startsWith("*");
                let clean = isDefault ? data.substring(1) : data;
                let parts = clean.split("|");
                if (parts.length < 2) return;

                let id = parts[0].trim();
                let desc = parts[1].trim();
                let descLower = desc.toLowerCase();

                // Only add sinks matching our filters
                let matches = hwService.sinkFilters.some(f => descLower.includes(f));
                if (matches) {
                    hwService._pendingSinks.push({ id: id, description: desc });
                }

                if (isDefault) {
                    hwService.currentSink = id;
                    hwService.currentSinkName = desc;
                }
            }
        }
        onRunningChanged: {
            if (running) {
                hwService._pendingSinks = [];
            } else {
                hwService.audioSinks = hwService._pendingSinks;
            }
        }
    }

    property Process btProc: Process {
        command: ["sh", "-c", "bluetoothctl info | grep 'Name' | cut -d ' ' -f 2-"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                if (data && data.trim() !== "") {
                    hwService.btConnected = true;
                    hwService.btDevice = data.trim();
                } else {
                    hwService.btConnected = false;
                    hwService.btDevice = "";
                }
            }
        }
    }

    property Process batProc: Process {
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
            onRead: data => {
                if (!data)
                    return;
                if (data.includes("NO_BAT")) {
                    hwService.hasBattery = false;
                    return;
                }

                hwService.hasBattery = true;

                if (data.match(/^\d+$/)) {
                    hwService.batPercent = parseInt(data);
                } else if (data.length > 2) {
                    hwService.batStatus = data.trim();
                }
            }
        }
    }
}
