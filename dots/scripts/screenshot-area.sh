#!/usr/bin/env bash
set -euo pipefail

dir="$HOME/Pictures/Screenshots"
mkdir -p "$dir"

file="$dir/screenshot-$(date +%F-%H%M%S).png"

grim -g "$(slurp)" "$file"
wl-copy < "$file"

notify-send "Screenshot saved" "$file"
