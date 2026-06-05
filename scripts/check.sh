#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE="${ARCH_PROFILE:-desktop}"
PYTHON_BIN="${PYTHON:-python3}"

cd "$ROOT"

PYTHONPATH="$ROOT/lib" "$PYTHON_BIN" -m compileall -q lib/arch_config
"$ROOT/scripts/archctl" --version
"$ROOT/scripts/archctl" -p "$PROFILE" validate
"$ROOT/scripts/archctl" -p "$PROFILE" self-test --all-profiles --no-render
"$ROOT/scripts/archctl" -p "$PROFILE" generate
"$ROOT/scripts/archctl" -p "$PROFILE" check-generated
