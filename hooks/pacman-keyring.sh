#!/usr/bin/env bash
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "[pacman-keyring] this hook must run as root" >&2
  exit 1
fi

echo "[pacman-keyring] ensure pacman keyring"

if [ ! -d /etc/pacman.d/gnupg ] || [ ! -f /etc/pacman.d/gnupg/pubring.gpg ]; then
  pacman-key --init
fi

pacman-key --populate archlinux || true

if grep -Rqs '^\[cachyos' /etc/pacman.conf /etc/pacman.d/*.conf 2> /dev/null; then
  echo "[pacman-keyring] CachyOS repositories detected"

  pacman-key --recv-keys 882DCFE48E2051D48E2562ABF3B607488DB35A47 \
    --keyserver keyserver.ubuntu.com || true

  pacman-key --lsign-key 882DCFE48E2051D48E2562ABF3B607488DB35A47 || true
  pacman-key --populate cachyos || true
fi

pacman -Sy

echo "[pacman-keyring] done"
