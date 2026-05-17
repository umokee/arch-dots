from __future__ import annotations

from modules.home.workspace._utils import dot_dir, generated_file
from shared.lib import add_packages, system_file


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("workspace", "hyprland"):
        return

    add_packages(
        "hyprland",
        "uwsm",
        "xorg-xwayland",
        "xdg-desktop-portal",
        "xdg-desktop-portal-hyprland",
        "xdg-desktop-portal-gtk",
        "polkit-kde-agent",
        "cliphist",
        "grim",
        "slurp",
        "swappy",
        "brightnessctl",
        "playerctl",
        "pamixer",
        "network-manager-applet",
        "wofi",
        "nemo",
        "xarchiver",
        "kitty",
    )

    dot_dir(helpers.username, ".config/hypr", ".config/hyprland")

    generated_file(
        helpers.username,
        ".config/hypr-generated/workspaces.conf",
        _workspaces_conf(helpers),
    )

    generated_file(
        helpers.username,
        ".local/bin/screenshot-tool",
        _screenshot_tool(),
        mode=0o755,
    )

    system_file(
        "/etc/environment.d/40-wayland-desktop.conf",
        """
# Managed by Decman

XDG_SESSION_TYPE=wayland
XDG_CURRENT_DESKTOP=Hyprland
XDG_SESSION_DESKTOP=Hyprland

GDK_BACKEND=wayland,x11
QT_QPA_PLATFORM=wayland;xcb
SDL_VIDEODRIVER=wayland
CLUTTER_BACKEND=wayland

ELECTRON_OZONE_PLATFORM_HINT=auto
MOZ_ENABLE_WAYLAND=1
""",
    )


def _workspaces_conf(helpers) -> str:
    if helpers.is_desktop:
        return """
# Managed by Decman

workspace = 1, monitor:DP-3, default:true
workspace = 2, monitor:DP-3
workspace = 3, monitor:DP-3
workspace = 4, monitor:DP-3
workspace = 5, monitor:DP-3

workspace = 6, monitor:HDMI-A-5, default:true
workspace = 7, monitor:HDMI-A-5
workspace = 8, monitor:HDMI-A-5
workspace = 9, monitor:HDMI-A-5
workspace = 10, monitor:HDMI-A-5

workspace = 11, monitor:DP-4, default:true
workspace = 12, monitor:DP-4, default:true
workspace = 13, monitor:DP-4, default:true
workspace = 14, monitor:DP-4, default:true
workspace = 15, monitor:DP-4, default:true
"""

    return """
# Managed by Decman

workspace = 1, monitor:eDP-1, default:true
workspace = 2, monitor:eDP-1
workspace = 3, monitor:eDP-1
workspace = 4, monitor:eDP-1
workspace = 5, monitor:eDP-1
workspace = 6, monitor:eDP-1
workspace = 7, monitor:eDP-1
workspace = 8, monitor:eDP-1
workspace = 9, monitor:eDP-1
workspace = 10, monitor:eDP-1
"""


def _screenshot_tool() -> str:
    return """
#!/usr/bin/env bash
set -euo pipefail

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"

get_next_number() {
  local i=1
  while [[ -e "$DIR/screenshot-$i.png" ]]; do
    ((i++))
  done
  echo "$i"
}

NUM="$(get_next_number)"
FILE="$DIR/screenshot-$NUM.png"

case "${1:-}" in
  "window")
    hyprctl -j activewindow | jq -r '"\\(.at[0]),\\(.at[1]) \\(.size[0])x\\(.size[1])"' | grim -g - "$FILE"
    wl-copy < "$FILE"
    echo "Saved: $FILE"
    ;;

  "area")
    grim -g "$(slurp)" "$FILE"
    wl-copy < "$FILE"
    echo "Saved: $FILE"
    ;;

  "full")
    grim "$FILE"
    wl-copy < "$FILE"
    echo "Saved: $FILE"
    ;;

  "clip")
    grim -g "$(slurp)" - | wl-copy -t image/png
    echo "Copied to clipboard"
    ;;

  *)
    echo "Usage: $0 {window|area|full|clip}"
    echo "  window - Screenshot active window"
    echo "  area   - Screenshot selected area"
    echo "  full   - Screenshot entire screen"
    echo "  clip   - Screenshot area to clipboard only"
    ;;
esac
"""
