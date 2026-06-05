#!/usr/bin/env bash
set -euo pipefail

SUDO=(sudo)
if [[ "${EUID}" -eq 0 ]]; then
  SUDO=()
fi

"${SUDO[@]}" systemctl daemon-reload
"${SUDO[@]}" xray -test -config /usr/local/etc/xray/config.json
"${SUDO[@]}" systemctl restart xray.service
"${SUDO[@]}" systemctl --no-pager --full status xray.service || true
