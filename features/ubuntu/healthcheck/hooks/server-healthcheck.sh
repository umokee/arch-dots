#!/usr/bin/env bash
set -euo pipefail

SUDO=(sudo)
if [[ "${EUID}" -eq 0 ]]; then
  SUDO=()
fi

echo "== SSH config =="
"${SUDO[@]}" /usr/sbin/sshd -t

echo
echo "== UFW =="
"${SUDO[@]}" ufw status verbose

echo
echo "== BBR =="
sysctl net.ipv4.tcp_congestion_control || true
sysctl net.core.default_qdisc || true

echo
echo "== 3x-ui service =="
"${SUDO[@]}" systemctl is-active x-ui.service
"${SUDO[@]}" systemctl --no-pager --full status x-ui.service || true

echo
echo "== Listening ports =="
"${SUDO[@]}" ss -tulpn | grep -E ':22|:443|:2053' || true

echo
echo "Healthcheck completed."
