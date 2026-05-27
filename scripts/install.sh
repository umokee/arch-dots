#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PREFIX="${PREFIX:-$HOME/.local/bin}"

mkdir -p "$PREFIX"
ln -sfn "$ROOT/scripts/archctl" "$PREFIX/archctl"
chmod +x "$ROOT/scripts/archctl" "$ROOT/scripts/archctl.py"

echo "installed: $PREFIX/archctl -> $ROOT/scripts/archctl"
echo "make sure $PREFIX is in PATH"
