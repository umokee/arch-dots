#!/usr/bin/env bash
set -euo pipefail

EXTENSIONS_FILE="${HOME}/.config/Code/User/extensions.txt"

if ! command -v code > /dev/null 2>&1; then
  echo "[vscode] code command not found, skipping VS Code extensions" >&2
  exit 0
fi

if [ ! -f "$EXTENSIONS_FILE" ]; then
  echo "[vscode] extensions file not found, skipping: $EXTENSIONS_FILE" >&2
  exit 0
fi

wanted_file="$(mktemp)"
installed_file="$(mktemp)"
failed_file="$(mktemp)"

cleanup() {
  rm -f "$wanted_file" "$installed_file" "$failed_file"
}
trap cleanup EXIT

grep -v '^[[:space:]]*$' "$EXTENSIONS_FILE" |
  grep -v '^[[:space:]]*#' |
  sed 's/^[[:space:]]*//; s/[[:space:]]*$//' |
  sort -fu > "$wanted_file"

code --list-extensions |
  sed 's/^[[:space:]]*//; s/[[:space:]]*$//' |
  sort -fu > "$installed_file"

echo "[vscode] install missing extensions"

while IFS= read -r extension; do
  [ -z "$extension" ] && continue

  if grep -Fxiq "$extension" "$installed_file"; then
    echo "[vscode] already installed: $extension"
    continue
  fi

  echo "[vscode] install: $extension"

  if code --install-extension "$extension" --force; then
    echo "[vscode] installed: $extension"
  else
    echo "[vscode] WARNING: failed to install: $extension" >&2
    echo "$extension" >> "$failed_file"
  fi
done < "$wanted_file"

if [ -s "$failed_file" ]; then
  echo
  echo "[vscode] Some extensions failed to install:"
  sed 's/^/  - /' "$failed_file"
  echo
  echo "[vscode] Switch continues. Fix/remove unavailable extensions later."
fi

echo "[vscode] extensions done"
