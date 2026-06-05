#!/usr/bin/env bash
set -euo pipefail

SUDO=(sudo)
if [[ "${EUID}" -eq 0 ]]; then
  SUDO=()
fi

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
  lsof

curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh -o /tmp/3x-ui-install.sh
chmod +x /tmp/3x-ui-install.sh

"${SUDO[@]}" bash /tmp/3x-ui-install.sh

"${SUDO[@]}" systemctl daemon-reload
"${SUDO[@]}" systemctl enable --now x-ui.service
