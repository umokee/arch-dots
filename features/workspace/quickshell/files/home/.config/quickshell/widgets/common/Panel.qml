import QtQuick

Rectangle {
    id: root

    property color backgroundColor: "transparent"
    property color borderColor: "transparent"
    property int borderWidth: 1

    color: backgroundColor
    border.width: borderWidth
    border.color: borderColor
}
