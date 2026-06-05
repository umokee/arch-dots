import QtQuick

import "../../services" as Services

Rectangle {
    id: root

    property bool checked: false

    signal toggled(bool checked)

    width: 38
    height: 20
    radius: height / 2
    color: checked ? Services.Theme.blue : Services.Theme.surface

    Rectangle {
        width: 16
        height: 16
        radius: 8
        color: Services.Theme.fg
        anchors.verticalCenter: parent.verticalCenter
        x: root.checked ? root.width - width - 2 : 2

        Behavior on x {
            NumberAnimation {
                duration: Services.Theme.animation.fast
                easing.type: Easing.InOutQuad
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            root.checked = !root.checked;
            root.toggled(root.checked);
        }
    }
}
