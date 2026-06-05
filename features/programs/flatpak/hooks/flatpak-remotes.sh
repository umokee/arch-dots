#!/usr/bin/env bash
set -euo pipefail

FLATHUB_URL="https://dl.flathub.org/repo/flathub.flatpakrepo"

if ! command -v flatpak >/dev/null 2>&1; then
  echo "flatpak is not installed"
  exit 1
fi

echo "== Flatpak remotes =="

echo "+ add system Flathub remote"
sudo flatpak remote-add --system --if-not-exists flathub "$FLATHUB_URL"

echo "+ add user Flathub remote"
flatpak remote-add --user --if-not-exists flathub "$FLATHUB_URL"

echo "+ list remotes"
flatpak remotes --columns=name,options || true
