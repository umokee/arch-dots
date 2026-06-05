import QtQuick
import QtQuick.Layouts

import "../../services" as Services

Rectangle {
    id: root

    property string text: ""
    property color textColor: Services.Theme.fg
    property int textSize: Services.Theme.font.size
    property bool bold: false
    property string tooltip: ""
    readonly property bool hovered: mouseArea.containsMouse

    signal clicked

    Layout.preferredWidth: 24
    Layout.preferredHeight: 24

    color: "transparent"

    Text {
        anchors.centerIn: parent
        text: root.text
        color: root.textColor
        font.family: Services.Theme.font.family
        font.pixelSize: root.textSize
        font.bold: root.bold
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton

        onClicked: root.clicked()
    }
}
