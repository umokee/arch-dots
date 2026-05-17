#!/usr/bin/env bash
set -euo pipefail

if ! command -v cliphist > /dev/null 2>&1; then
  notify-send "cliphist" "cliphist is not installed"
  exit 1
fi

if ! command -v wofi > /dev/null 2>&1; then
  notify-send "wofi" "wofi is not installed"
  exit 1
fi

cliphist list | wofi --dmenu --prompt "Clipboard" | cliphist decode | wl-copy
