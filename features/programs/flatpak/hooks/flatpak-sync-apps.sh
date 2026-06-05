#!/usr/bin/env bash
set -euo pipefail

APPS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/flatpak/apps.txt"
FLATHUB_URL="https://dl.flathub.org/repo/flathub.flatpakrepo"

if ! command -v flatpak > /dev/null 2>&1; then
  echo "flatpak is not installed"
  exit 1
fi

if [[ ! -f $APPS_FILE ]]; then
  echo "No Flatpak apps file: $APPS_FILE"
  exit 0
fi

flatpak remote-add --user --if-not-exists flathub "$FLATHUB_URL"

trim() {
  local value="$1"

  value="${value%%#*}"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"

  printf '%s' "$value"
}

echo "== Sync user Flatpak apps =="

while IFS= read -r raw_line || [[ -n $raw_line ]]; do
  app_id="$(trim "$raw_line")"

  if [[ -z $app_id ]]; then
    continue
  fi

  if flatpak info "$app_id" > /dev/null 2>&1; then
    echo "skip $app_id: already installed"
    continue
  fi

  echo "+ install $app_id"
  flatpak install --user -y flathub "$app_id"
done < "$APPS_FILE"
