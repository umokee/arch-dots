import QtQuick
import QtQuick.Layouts

import "../../services" as Services
import "../../widgets/common" as Common

Common.IconButton {
    text: "󰕰"
    textColor: Services.Overview.isOpen ? Services.Theme.yellow : Services.Theme.blue
    textSize: 18

    onClicked: {
        Services.Overview.toggle();
    }
}
