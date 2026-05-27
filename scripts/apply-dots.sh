#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
profile="${ARCH_PROFILE:-desktop}"
exec "$ROOT/scripts/archctl" -p "$profile" dots apply "$@"
