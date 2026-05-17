#!/usr/bin/env bash
set -euo pipefail
sudo pacman -Sy --needed base-devel git curl
# Official CachyOS repo bootstrap changes over time; verify before executing on a real machine.
# Current recommended path: https://wiki.cachyos.org/features/optimized_repos/
echo "Install cachyos-keyring/mirrorlist per CachyOS wiki, then run sudo decman --source ./source.py"
