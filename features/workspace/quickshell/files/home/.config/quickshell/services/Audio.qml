pragma Singleton

import QtQuick
import Quickshell.Hyprland
import Quickshell.Io

QtObject {
    id: root

    property bool micMuted: true
    property var audioSinks: []
    property string currentSink: ""
    property string currentSinkName: ""

    readonly property var sinkFilters: ["razer", "fifine"]
    property var _pendingSinks: []

    property Timer refreshTimer
    property Process micProc
    property Process sinksProc

    function refresh() {
        root.micProc.running = true;
        root.sinksProc.running = true;
    }

    function toggleMic() {
        Hyprland.dispatch('hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")');

        Qt.callLater(function () {
            root.micProc.running = true;
        });
    }

    function cycleAudioSink() {
        if (root.audioSinks.length < 2)
            return;

        const currentIndex = root.audioSinks.findIndex(function (sink) {
            return sink.id === root.currentSink;
        });

        const nextIndex = (currentIndex + 1) % root.audioSinks.length;
        const nextSink = root.audioSinks[nextIndex];

        Hyprland.dispatch('hl.dsp.exec_cmd("wpctl set-default ' + nextSink.id + '")');

        Qt.callLater(function () {
            root.sinksProc.running = true;
        });
    }

    refreshTimer: Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: root.refresh()
    }

    micProc: Process {
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SOURCE@"]
        running: false

        stdout: SplitParser {
            onRead: function (data) {
                if (!data)
                    return;

                root.micMuted = data.includes("MUTED");
            }
        }
    }

    sinksProc: Process {
        command: ["sh", "-c", `wpctl status | sed -n '/Sinks:/,/Sources:/p' | grep '[0-9]\\+\\.' | perl -pe 's/.*?(\\*?)\\s*(\\d+)\\.\\s+(.+?)\\s+\\[vol:.*/\\1\\2|\\3/'`]
        running: false

        onRunningChanged: {
            if (running) {
                root._pendingSinks = [];
            } else {
                root.audioSinks = root._pendingSinks;
            }
        }

        stdout: SplitParser {
            splitMarker: "\n"

            onRead: function (data) {
                if (!data || !data.trim())
                    return;

                const isDefault = data.startsWith("*");
                const clean = isDefault ? data.substring(1) : data;
                const parts = clean.split("|");

                if (parts.length < 2)
                    return;

                const id = parts[0].trim();
                const description = parts[1].trim();
                const descriptionLower = description.toLowerCase();

                const matches = root.sinkFilters.some(function (filter) {
                    return descriptionLower.includes(filter);
                });

                if (matches) {
                    root._pendingSinks.push({
                        id: id,
                        description: description,
                    });
                }

                if (isDefault) {
                    root.currentSink = id;
                    root.currentSinkName = description;
                }
            }
        }
    }
}
