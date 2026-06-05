#!/usr/bin/env bash
set -euo pipefail

SUDO=(sudo)
if [[ "${EUID}" -eq 0 ]]; then
  SUDO=()
fi

"${SUDO[@]}" /usr/sbin/sshd -t
"${SUDO[@]}" systemctl reload ssh.service || "${SUDO[@]}" systemctl restart ssh.service

"${SUDO[@]}" systemctl enable --now fail2ban.service || true
"${SUDO[@]}" fail2ban-client reload || "${SUDO[@]}" systemctl restart fail2ban.service || true

echo "SSH hardening applied"
