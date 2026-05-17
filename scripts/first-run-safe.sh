#!/usr/bin/env bash
set -euo pipefail
mkdir -p ./state
pacman -Qeqn > ./state/pacman-explicit-native.before.txt
pacman -Qeqm > ./state/pacman-explicit-foreign.before.txt || true
systemctl list-unit-files --state=enabled --no-pager > ./state/systemd-enabled.before.txt || true
echo "Snapshot recommended before running decman."
echo "Run: sudo DEC_HOST=desktop decman --source ./source.py --debug"
