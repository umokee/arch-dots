#!/usr/bin/env bash
set -euo pipefail

SUDO=(sudo)
if [[ "${EUID}" -eq 0 ]]; then
  SUDO=()
fi

"${SUDO[@]}" systemctl daemon-reload

if command -v x-ui >/dev/null 2>&1; then
  "${SUDO[@]}" systemctl enable x-ui.service
  "${SUDO[@]}" systemctl restart x-ui.service
  "${SUDO[@]}" systemctl --no-pager --full status x-ui.service || true
else
  echo "x-ui command not found after installation"
  exit 1
fi
