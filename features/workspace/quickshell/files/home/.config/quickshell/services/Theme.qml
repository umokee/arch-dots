pragma Singleton

import QtQuick
import "../styles" as Styles

QtObject {
    // readonly property color bg: "#090B17"
    // readonly property color surface: "#151827"
    // readonly property color surfaceVariant: "#292e42"
    // readonly property color fg: "#c0caf5"
    // readonly property color muted: "#565f89"
    // readonly property color cyan: "#7dcfff"
    // readonly property color purple: "#bb9af7"
    // readonly property color red: "#f7768e"
    // readonly property color yellow: "#e0af68"
    // readonly property color blue: "#7aa2f7"
    // readonly property color green: "#9ece6a"

    readonly property color bg: "#101216"
    readonly property color surface: "#171A20"
    readonly property color surfaceVariant: "#222630"
    readonly property color fg: "#D7DAE0"
    readonly property color muted: "#8A9099"

    readonly property color cyan: "#AAB2BF"
    readonly property color purple: "#AAB2BF"
    readonly property color blue: "#8EA3B8"

    readonly property color red: "#C97B7B"
    readonly property color yellow: "#C9A86A"
    readonly property color green: "#8FAF8F"

    readonly property QtObject font: QtObject {
        readonly property string family: Styles.Typography.family
        readonly property int size: Styles.Typography.normal
        readonly property int small: Styles.Typography.small
        readonly property int tiny: Styles.Typography.tiny
    }

    readonly property QtObject spacing: QtObject {
        readonly property int xs: Styles.Spacing.xs
        readonly property int sm: Styles.Spacing.sm
        readonly property int md: Styles.Spacing.md
        readonly property int lg: Styles.Spacing.lg
        readonly property int xl: Styles.Spacing.xl
    }

    readonly property QtObject radius: QtObject {
        readonly property int xs: Styles.Radius.xs
        readonly property int sm: Styles.Radius.sm
        readonly property int md: Styles.Radius.md
    }

    readonly property QtObject animation: QtObject {
        readonly property int fast: 150
        readonly property int normal: 300
    }
}
