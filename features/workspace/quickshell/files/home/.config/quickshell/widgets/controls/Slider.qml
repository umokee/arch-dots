import QtQuick

import "../../services" as Services

Rectangle {
    id: root

    property real value: 0
    property real from: 0
    property real to: 1

    signal moved(real value)

    width: 120
    height: 8
    radius: height / 2
    color: Services.Theme.surface

    Rectangle {
        height: parent.height
        width: parent.width * Math.max(0, Math.min(1, (root.value - root.from) / (root.to - root.from)))
        radius: parent.radius
        color: Services.Theme.blue
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onPressed: updateValue(mouse.x)
        onPositionChanged: if (pressed) updateValue(mouse.x)

        function updateValue(x) {
            const ratio = Math.max(0, Math.min(1, x / root.width));
            root.value = root.from + ratio * (root.to - root.from);
            root.moved(root.value);
        }
    }
}
