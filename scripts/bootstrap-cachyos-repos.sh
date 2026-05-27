#!/usr/bin/env bash
set -euo pipefail

URL="${CACHYOS_REPO_URL:-https://mirror.cachyos.org/cachyos-repo.tar.xz}"
FORCE="${CACHYOS_REPO_FORCE:-0}"

if [ "$(id -u)" -ne 0 ]; then
  echo "error: bootstrap-cachyos-repos.sh must run as root" >&2
  exit 1
fi

has() {
  command -v "$1" > /dev/null 2>&1
}

fetch() {
  local url="$1"
  local out="$2"

  if has curl; then
    curl -L "$url" -o "$out"
    return
  fi

  if has wget; then
    wget "$url" -O "$out"
    return
  fi

  echo "error: need curl or wget to download CachyOS repo installer" >&2
  exit 1
}

cachyos_repo_config_present() {
  grep -qs '^\[cachyos' /etc/pacman.conf 2> /dev/null
}

cachyos_mirrorlists_present() {
  [ -f /etc/pacman.d/cachyos-mirrorlist ] || return 1

  if [ -f /etc/pacman.d/cachyos-v3-mirrorlist ] || [ -f /etc/pacman.d/cachyos-v4-mirrorlist ]; then
    return 0
  fi

  return 1
}

cachyos_repo_healthy() {
  cachyos_repo_config_present || return 1
  cachyos_mirrorlists_present || return 1

  pacman -Syy --noconfirm > /dev/null 2>&1
}

echo "[cachyos] checking repositories"

if [ "$FORCE" != "1" ] && cachyos_repo_healthy; then
  echo "[cachyos] repositories already configured and pacman sync works"
  exit 0
fi

tmpdir="$(mktemp -d)"

cleanup() {
  rm -rf "$tmpdir"
}

trap cleanup EXIT

archive="$tmpdir/cachyos-repo.tar.xz"

echo "[cachyos] downloading repo installer"
fetch "$URL" "$archive"

echo "[cachyos] extracting repo installer"
tar xvf "$archive" -C "$tmpdir" > /dev/null

if [ ! -x "$tmpdir/cachyos-repo/cachyos-repo.sh" ]; then
  echo "error: cachyos-repo.sh not found or not executable" >&2
  exit 1
fi

echo "[cachyos] running repo installer"

(
  cd "$tmpdir/cachyos-repo"
  ./cachyos-repo.sh
)

echo "[cachyos] refreshing pacman databases"
pacman -Syy --noconfirm

echo "[cachyos] repositories installed"
