pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property bool isOpen: false

    function open(): void {
        isOpen = true;
    }

    function close(): void {
        isOpen = false;
    }

    function toggle(): void {
        isOpen = !isOpen;
    }

    property IpcHandler ipc: IpcHandler {
        target: "overview"

        function open(): void {
            root.open();
        }

        function close(): void {
            root.close();
        }

        function toggle(): void {
            root.toggle();
        }
    }
}
