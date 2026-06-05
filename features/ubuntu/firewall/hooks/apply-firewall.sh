#!/usr/bin/env bash
set -euo pipefail

SUDO=(sudo)
if [[ "${EUID}" -eq 0 ]]; then
  SUDO=()
fi

"${SUDO[@]}" /usr/local/sbin/archctl-apply-firewall
