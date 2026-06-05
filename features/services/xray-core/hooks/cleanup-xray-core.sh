#!/usr/bin/env bash
set -euo pipefail

SUDO=(sudo)
if [[ "${EUID}" -eq 0 ]]; then
  SUDO=()
fi

"${SUDO[@]}" systemctl disable --now xray.service 2>/dev/null || true

echo "xray.service disabled."
echo "Config and generated keys were intentionally kept:"
echo "  /usr/local/etc/xray/config.json"
echo "  /etc/archctl/xray-core.generated.env"
echo "  /root/xray-client-links.txt"
