import QtQuick

import "../../services" as Services

Panel {
    id: root

    property alias contentItem: content.data

    radius: Services.Theme.radius.sm
    backgroundColor: Services.Theme.bg
    borderColor: Services.Theme.muted

    width: content.implicitWidth + Services.Theme.spacing.lg
    height: content.implicitHeight + Services.Theme.spacing.md

    Item {
        id: content
        anchors.fill: parent
        anchors.margins: Services.Theme.spacing.sm
    }
}
