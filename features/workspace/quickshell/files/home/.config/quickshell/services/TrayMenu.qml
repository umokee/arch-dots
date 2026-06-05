pragma Singleton

import QtQuick

QtObject {
    id: root

    property bool isOpen: false

    property var activeItem: null

    property var rootMenu: null
    property var level1Menu: null
    property var level2Menu: null
    property var level3Menu: null

    property string rootTitle: "Tray"
    property string level1Title: "Submenu"
    property string level2Title: "Submenu"
    property string level3Title: "Submenu"

    property int depth: 0
    property int anchorX: 0

    readonly property bool canGoBack: depth > 0

    readonly property var currentMenu: {
        if (depth === 1)
            return level1Menu;
        if (depth === 2)
            return level2Menu;
        if (depth === 3)
            return level3Menu;

        return rootMenu;
    }

    readonly property string title: {
        if (depth === 1)
            return level1Title;
        if (depth === 2)
            return level2Title;
        if (depth === 3)
            return level3Title;

        return rootTitle;
    }

    readonly property string description: {
        if (depth > 0)
            return "";

        if (!activeItem || !activeItem.tooltipDescription)
            return "";

        return activeItem.tooltipDescription;
    }

    function itemTitle(item) {
        if (!item)
            return "Tray";

        if (item.tooltipTitle && item.tooltipTitle.length > 0)
            return item.tooltipTitle;

        if (item.title && item.title.length > 0)
            return item.title;

        if (item.id && item.id.length > 0)
            return item.id;

        return "Tray";
    }

    function open(item, x) {
        if (!item || !item.hasMenu || !item.menu)
            return;

        activeItem = item;

        rootMenu = item.menu;
        level1Menu = null;
        level2Menu = null;
        level3Menu = null;

        rootTitle = itemTitle(item);
        level1Title = "Submenu";
        level2Title = "Submenu";
        level3Title = "Submenu";

        depth = 0;
        anchorX = x;
        isOpen = true;
    }

    function pushMenu(menuHandle, titleText) {
        if (!menuHandle)
            return;

        const nextTitle = titleText && titleText.length > 0
            ? titleText
            : "Submenu";

        if (depth === 0) {
            level1Menu = menuHandle;
            level1Title = nextTitle;
            level2Menu = null;
            level3Menu = null;
            depth = 1;
            return;
        }

        if (depth === 1) {
            level2Menu = menuHandle;
            level2Title = nextTitle;
            level3Menu = null;
            depth = 2;
            return;
        }

        if (depth === 2) {
            level3Menu = menuHandle;
            level3Title = nextTitle;
            depth = 3;
            return;
        }
    }

    function popMenu() {
        if (depth === 3) {
            level3Menu = null;
            level3Title = "Submenu";
            depth = 2;
            return;
        }

        if (depth === 2) {
            level2Menu = null;
            level2Title = "Submenu";
            depth = 1;
            return;
        }

        if (depth === 1) {
            level1Menu = null;
            level1Title = "Submenu";
            depth = 0;
            return;
        }
    }

    function close() {
        isOpen = false;

        activeItem = null;

        rootMenu = null;
        level1Menu = null;
        level2Menu = null;
        level3Menu = null;

        rootTitle = "Tray";
        level1Title = "Submenu";
        level2Title = "Submenu";
        level3Title = "Submenu";

        depth = 0;
        anchorX = 0;
    }

    function reset() {
        close();
    }
}
