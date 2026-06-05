#!/usr/bin/env bash
set -euo pipefail

SUDO=(sudo)
if [[ "${EUID}" -eq 0 ]]; then
  SUDO=()
fi

source /etc/archctl/3x-ui.env

generated_file="/etc/archctl/3x-ui.generated.env"

gen_alnum() {
  local length="$1"
  python3 - "$length" <<'PY'
import secrets
import string
import sys

length = int(sys.argv[1])
alphabet = string.ascii_letters + string.digits
print(''.join(secrets.choice(alphabet) for _ in range(length)), end='')
PY
}

load_generated() {
  if [[ -f "${generated_file}" ]]; then
    # shellcheck disable=SC1090
    source "${generated_file}"
  fi
}

save_generated() {
  install -d -m 700 /etc/archctl
  umask 077
  cat > "${generated_file}" <<EOF_GEN
ARCHCTL_XUI_USERNAME='${XUI_USERNAME}'
ARCHCTL_XUI_PASSWORD='${XUI_PASSWORD}'
ARCHCTL_XUI_WEB_BASE_PATH='${XUI_WEB_BASE_PATH}'
EOF_GEN
  chmod 600 "${generated_file}"
  umask 022
}

load_generated

if [[ -z "${XUI_USERNAME:-}" || "${XUI_USERNAME}" == "auto" ]]; then
  XUI_USERNAME="${ARCHCTL_XUI_USERNAME:-$(gen_alnum 12)}"
fi

if [[ -z "${XUI_PASSWORD:-}" || "${XUI_PASSWORD}" == "auto" ]]; then
  XUI_PASSWORD="${ARCHCTL_XUI_PASSWORD:-$(gen_alnum 24)}"
fi

if [[ -z "${XUI_WEB_BASE_PATH:-}" || "${XUI_WEB_BASE_PATH}" == "auto" ]]; then
  XUI_WEB_BASE_PATH="${ARCHCTL_XUI_WEB_BASE_PATH:-$(gen_alnum 18)}"
fi

XUI_PANEL_PORT="${XUI_PANEL_PORT:-2053}"
XUI_LISTEN_IP="${XUI_LISTEN_IP:-127.0.0.1}"
XUI_FORCE_UPDATE="${XUI_FORCE_UPDATE:-false}"

save_generated

export DEBIAN_FRONTEND=noninteractive

"${SUDO[@]}" apt-get update
"${SUDO[@]}" apt-get install -y \
  ca-certificates \
  curl \
  wget \
  tar \
  gzip \
  openssl \
  sqlite3 \
  iptables \
  iproute2 \
  lsof \
  socat \
  cron \
  python3

echo "== Remove old Docker 3x-ui if present =="
"${SUDO[@]}" systemctl stop 3x-ui.service 2>/dev/null || true
"${SUDO[@]}" systemctl disable 3x-ui.service 2>/dev/null || true
"${SUDO[@]}" rm -f /etc/systemd/system/3x-ui.service

if command -v docker >/dev/null 2>&1; then
  "${SUDO[@]}" docker rm -f 3xui_app 2>/dev/null || true
fi

"${SUDO[@]}" systemctl daemon-reload

need_install=0

if ! command -v x-ui >/dev/null 2>&1 && [[ ! -x /usr/local/x-ui/x-ui ]]; then
  need_install=1
fi

if [[ "${XUI_FORCE_UPDATE}" == "true" ]]; then
  need_install=1
fi

if [[ "${need_install}" -eq 1 ]]; then
  echo "== Install native 3x-ui =="

  curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh -o /tmp/3x-ui-install.sh
  chmod +x /tmp/3x-ui-install.sh

  # Best effort non-interactive setup. If upstream installer changes prompts,
  # run it manually once, then rerun archctl switch.
  {
    printf '\n'
    printf 'y\n'
    printf '%s\n' "${XUI_PANEL_PORT}"
    printf '4\n'
    printf 'y\n'
  } | "${SUDO[@]}" bash /tmp/3x-ui-install.sh || {
    echo "3x-ui installer failed in non-interactive mode."
    echo "Run manually: sudo bash /tmp/3x-ui-install.sh"
    exit 1
  }
fi

xui_bin="$(command -v x-ui || true)"
if [[ -z "${xui_bin}" && -x /usr/local/x-ui/x-ui ]]; then
  xui_bin="/usr/local/x-ui/x-ui"
fi

if [[ -z "${xui_bin}" ]]; then
  echo "x-ui binary was not found"
  exit 1
fi

echo "== Enforce 3x-ui panel settings =="
"${SUDO[@]}" "${xui_bin}" setting \
  -username "${XUI_USERNAME}" \
  -password "${XUI_PASSWORD}" \
  -port "${XUI_PANEL_PORT}" \
  -webBasePath "${XUI_WEB_BASE_PATH}"

"${SUDO[@]}" "${xui_bin}" setting -listenIP "${XUI_LISTEN_IP}" || true

"${SUDO[@]}" systemctl daemon-reload
"${SUDO[@]}" systemctl enable --now x-ui.service
"${SUDO[@]}" systemctl restart x-ui.service

"${SUDO[@]}" tee /root/3x-ui-access.txt >/dev/null <<EOF_ACCESS
3x-ui panel access

Local URL through SSH tunnel:
  http://127.0.0.1:${XUI_PANEL_PORT}/${XUI_WEB_BASE_PATH}

SSH tunnel from your PC:
  ssh -L ${XUI_PANEL_PORT}:127.0.0.1:${XUI_PANEL_PORT} server

Username:
  ${XUI_USERNAME}

Password:
  ${XUI_PASSWORD}

Panel listen IP on server:
  ${XUI_LISTEN_IP}

Public panel port is intentionally closed by firewall.
EOF_ACCESS

"${SUDO[@]}" chmod 600 /root/3x-ui-access.txt

echo
echo "3x-ui native install done."
echo "Access data:"
echo "  sudo cat /root/3x-ui-access.txt"
