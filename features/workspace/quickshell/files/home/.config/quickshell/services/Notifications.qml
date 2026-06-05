pragma Singleton

import QtQuick
import Quickshell.Services.Notifications

QtObject {
    id: root

    property bool centerOpen: false
    property bool dndEnabled: false

    property var notifications: []
    property var popups: []

    readonly property int count: notifications.length
    property int unreadCount: 0

    readonly property int maxHistory: 50
    readonly property int maxPopups: 4

    property NotificationServer server: NotificationServer {
        id: notificationServer

        actionsSupported: true
        actionIconsSupported: true
        bodySupported: true
        bodyMarkupSupported: false
        bodyImagesSupported: true
        imageSupported: true
        persistenceSupported: true
        keepOnReload: false

        onNotification: function(notification) {
            root.add(notification);
        }
    }

    function isMeaningless(notification) {
        if (!notification)
            return true;

        const appName = notification.appName || "";
        const summary = notification.summary || "";
        const body = notification.body || "";
        const actions = notification.actions || [];

        return appName.length === 0
            && summary.length === 0
            && body.length === 0
            && actions.length === 0;
    }

    function add(notification) {
        if (isMeaningless(notification)) {
            notification.tracked = false;
            notification.expire();
            return;
        }

        notification.tracked = true;

        notifications = [notification].concat(notifications).slice(0, maxHistory);
        unreadCount += 1;

        notification.closed.connect(function() {
            removeById(notification.id);
            hidePopup(notification.id);
        });

        if (dndEnabled || centerOpen) {
            hidePopup(notification.id);
            notification.expire();
            return;
        }

        popups = [notification].concat(popups).slice(0, maxPopups);
    }

    function removeById(id) {
        notifications = notifications.filter(function(notification) {
            return notification.id !== id;
        });
    }

    function hidePopup(id) {
        popups = popups.filter(function(notification) {
            return notification.id !== id;
        });
    }

    function dismiss(id) {
        for (let i = 0; i < notifications.length; i++) {
            if (notifications[i].id === id) {
                notifications[i].dismiss();
                break;
            }
        }

        removeById(id);
        hidePopup(id);
    }

    function clearAll() {
        const copy = notifications.slice();

        for (let i = 0; i < copy.length; i++) {
            copy[i].dismiss();
        }

        notifications = [];
        popups = [];
        unreadCount = 0;
    }

    function markAllRead() {
        unreadCount = 0;
    }

    function toggleCenter() {
        centerOpen = !centerOpen;

        if (centerOpen) {
            markAllRead();
            popups = {};
        }
    }

    function closeCenter() {
        centerOpen = false;
    }

    function toggleDnd() {
        dndEnabled = !dndEnabled;

        if (dndEnabled) {
            const copy = popups.slice();

            for (let i = 0; i < copy.length; i++) {
                copy[i].expire();
            }

            popups = [];
        }
    }

    function urgencyName(notification) {
        if (!notification)
            return "normal";

        return NotificationUrgency.toString(notification.urgency).toLowerCase();
    }

    function isCritical(notification) {
        return notification && notification.urgency === NotificationUrgency.Critical;
    }
}
