#!/usr/bin/env bash
set -euo pipefail

USER_NAME="${ARCH_USER:-${SUDO_USER:-${USER:-$(id -un)}}}"

if [ "$USER_NAME" = "root" ]; then
  USER_NAME="$(logname 2>/dev/null || echo user)"
fi

if ! id "$USER_NAME" > /dev/null 2>&1; then
  echo "podman-rootless: user '$USER_NAME' does not exist, skipping"
  exit 0
fi

ensure_subid() {
  local file="$1"
  local user="$2"
  local start="$3"
  local count="$4"

  sudo touch "$file"

  if grep -qE "^${user}:" "$file"; then
    echo "podman-rootless: $file already has entry for $user"
    return 0
  fi

  echo "podman-rootless: adding $user:$start:$count to $file"
  echo "${user}:${start}:${count}" | sudo tee -a "$file" > /dev/null
}

ensure_subid /etc/subuid "$USER_NAME" 100000 65536
ensure_subid /etc/subgid "$USER_NAME" 100000 65536

echo "podman-rootless: done"
