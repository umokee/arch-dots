#!/usr/bin/env bash
set -euo pipefail

SUDO=(sudo)
if [[ "${EUID}" -eq 0 ]]; then
  SUDO=()
fi

"${SUDO[@]}" systemctl daemon-reload
"${SUDO[@]}" systemctl restart 3x-ui.service
"${SUDO[@]}" systemctl --no-pager --full status 3x-ui.service || true
