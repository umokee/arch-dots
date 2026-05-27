#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${1:-$ROOT/dist}"
NAME="${2:-arch-dots-clean.tar.gz}"

mkdir -p "$OUT_DIR"

tar   --exclude='./generated'   --exclude='./.generated.tmp-*'   --exclude='./state'   --exclude='./cache'   --exclude='./dist'   --exclude='./.git'   --exclude='*.tar.gz'   --exclude='*.sha256.txt'   -czf "$OUT_DIR/$NAME"   -C "$ROOT/.."   "$(basename "$ROOT")"

sha256sum "$OUT_DIR/$NAME" > "$OUT_DIR/$NAME.sha256.txt"

echo "$OUT_DIR/$NAME"
echo "$OUT_DIR/$NAME.sha256.txt"
