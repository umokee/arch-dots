import QtQuick

QtObject {
    id: root

    // Будущий OSD для громкости/яркости.
    property bool visible: false
    property string label: ""
    property real value: 0

    function show(nextLabel, nextValue) {
        label = nextLabel;
        value = nextValue;
        visible = true;
    }

    function hide() {
        visible = false;
    }
}
