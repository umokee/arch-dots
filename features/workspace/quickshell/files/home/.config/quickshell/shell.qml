pragma ComponentBehavior: Bound
//@ pragma UseQApplication

import Quickshell
import QtQuick

import "app" as App

ShellRoot {
    id: root

    HostConfig {
        id: hostConfig
    }

    App.Bar {
        hostConfig: hostConfig
    }

    App.NotificationPopups {
        hostConfig: hostConfig
    }

    App.NotificationCenter {
        hostConfig: hostConfig
    }

    App.TrayMenu {
        hostConfig: hostConfig
    }

    App.WorkspaceOverview {
        hostConfig: hostConfig
    }
    
    App.Launcher {}
    App.OSD {}
}
