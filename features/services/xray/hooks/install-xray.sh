#!/usr/bin/env bash
set -euo pipefail

SUDO=(sudo)
if [[ "${EUID}" -eq 0 ]]; then
  SUDO=()
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

install_script="$tmp/install-release.sh"

curl -L \
  --retry 5 \
  --retry-delay 5 \
  -o "$install_script" \
  https://github.com/XTLS/Xray-install/raw/main/install-release.sh

chmod +x "$install_script"

"${SUDO[@]}" bash "$install_script" install --logrotate

"${SUDO[@]}" mkdir -p /usr/local/etc/xray /var/log/xray
"${SUDO[@]}" chmod 755 /usr/local/etc/xray
"${SUDO[@]}" chmod 755 /var/log/xray
