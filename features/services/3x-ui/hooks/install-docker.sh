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
  gnupg \
  lsb-release

if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | "${SUDO[@]}" sh
fi

"${SUDO[@]}" systemctl enable --now docker.service
