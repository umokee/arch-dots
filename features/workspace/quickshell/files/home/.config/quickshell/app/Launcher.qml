import QtQuick

QtObject {
    id: root

    // Будущий launcher. Пока специально пустой, чтобы архитектура уже была готова,
    // но shell не создавал лишних окон и не ломал текущую панель.
    property bool opened: false

    function open() {
        opened = true;
    }

    function close() {
        opened = false;
    }

    function toggle() {
        opened = !opened;
    }
}
