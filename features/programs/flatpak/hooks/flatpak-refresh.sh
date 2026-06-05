#!/usr/bin/env bash
set -euo pipefail

echo "== Refresh Flatpak desktop integration =="

if command -v update-desktop-database > /dev/null 2>&1; then
  update-desktop-database "$HOME/.local/share/applications" 2> /dev/null || true
  update-desktop-database "$HOME/.local/share/flatpak/exports/share/applications" 2> /dev/null || true
  sudo update-desktop-database /var/lib/flatpak/exports/share/applications 2> /dev/null || true
fi

if command -v update-mime-database > /dev/null 2>&1; then
  update-mime-database "$HOME/.local/share/mime" 2> /dev/null || true
fi

echo "+ clear tofi drun cache"
rm -f "$HOME/.cache/tofi-drun" 2> /dev/null || true

if systemctl --user show-environment > /dev/null 2>&1; then
  echo "+ reload user systemd"
  systemctl --user daemon-reload || true

  echo "+ restart xdg desktop portals when active"
  systemctl --user try-restart xdg-desktop-portal.service || true
  systemctl --user try-restart xdg-desktop-portal-hyprland.service || true
  systemctl --user try-restart xdg-desktop-portal-gtk.service || true
else
  echo "skip portal restart: user systemd is not available"
fi

echo "done"
