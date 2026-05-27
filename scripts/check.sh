#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
PYTHONPATH="$ROOT/lib" python -m compileall -q lib/arch_config
PYTHONPATH="$ROOT/lib" python -m arch_config.cli -p desktop validate
PYTHONPATH="$ROOT/lib" python -m arch_config.cli -p desktop self-test --all-profiles --no-render
PYTHONPATH="$ROOT/lib" python -m arch_config.cli -p desktop generate
PYTHONPATH="$ROOT/lib" python -m arch_config.cli -p desktop check-generated
