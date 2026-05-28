#!/usr/bin/env bash
set -euo pipefail

target_user="${SUDO_USER:-${USER:-}}"

if [ -z "$target_user" ] || [ "$target_user" = "root" ]; then
  target_user="$(logname 2> /dev/null || true)"
fi

if [ -z "$target_user" ] || ! id "$target_user" > /dev/null 2>&1; then
  echo "Cannot determine normal user for docker group"
  exit 1
fi

sudo groupadd -f docker

for group in docker kvm; do
  if getent group "$group" > /dev/null 2>&1; then
    if ! id -nG "$target_user" | tr ' ' '\n' | grep -qx "$group"; then
      echo "Adding $target_user to $group"
      sudo usermod -aG "$group" "$target_user"
    else
      echo "$target_user is already in $group"
    fi
  fi
done

echo
echo "Docker group was checked."
echo "If docker was just added, relogin or reboot is required."
