#!/usr/bin/env bash
set -euo pipefail

SUDO=(sudo)
if [[ "${EUID}" -eq 0 ]]; then
  SUDO=()
fi

"${SUDO[@]}" /usr/sbin/sshd -t
"${SUDO[@]}" systemctl reload ssh.service

if systemctl list-unit-files fail2ban.service >/dev/null 2>&1; then
  "${SUDO[@]}" systemctl restart fail2ban.service || true
fi
