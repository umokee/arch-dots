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
echo "== Xray config =="
if command -v xray >/dev/null 2>&1; then
  "${SUDO[@]}" xray run -test -config /usr/local/etc/xray/config.json
else
  echo "xray command not found"
  exit 1
fi

echo
echo "== Xray service =="
if ! "${SUDO[@]}" systemctl is-active --quiet xray.service; then
  "${SUDO[@]}" systemctl --no-pager --full status xray.service || true
  echo "xray.service is not active"
  exit 1
fi

"${SUDO[@]}" systemctl --no-pager --full status xray.service || true

echo
echo "== Old 3x-ui/x-ui service =="
if "${SUDO[@]}" systemctl list-unit-files x-ui.service >/dev/null 2>&1; then
  "${SUDO[@]}" systemctl is-active x-ui.service || true
else
  echo "x-ui.service not installed"
fi

echo
echo "== Listening ports =="
"${SUDO[@]}" ss -tulpn | grep -E ':22|:443|xray' || true

echo
echo "Healthcheck completed."
