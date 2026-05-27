#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARCHCTL="$ROOT/scripts/archctl"

shell_name="${1:-${SHELL##*/}}"

case "$shell_name" in
  fish|bash|zsh)
    exec "$ARCHCTL" completions "$shell_name" --install --force
    ;;
  *)
    echo "Usage: $0 {fish|bash|zsh}" >&2
    exit 2
    ;;
esac
