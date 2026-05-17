from __future__ import annotations

from shared.lib import add_packages, enable_units, system_file


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("base", "cleanup"):
        return

    add_packages(
        "pacman-contrib",
        "pacutils",
        "lostfiles",
    )

    enable_units(
        "paccache.timer",
        "fstrim.timer",
    )

    system_file(
        "/usr/local/bin/arch-gc",
        _arch_gc_script(),
        mode=0o755,
    )


def _arch_gc_script() -> str:
    return """
#!/usr/bin/env bash
set -euo pipefail

echo "== Pacman cache =="
sudo paccache -rk2 || true
sudo paccache -ruk0 || true

echo
echo "== Orphans =="
orphans="$(pacman -Qdtq || true)"

if [ -n "$orphans" ]; then
  echo "$orphans"
  read -rp "Remove orphans? [y/N] " answer

  if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo "$orphans" | sudo pacman -Rns -
  fi
else
  echo "No orphans."
fi

echo
echo "== Pacdiff =="
sudo pacdiff || true

echo
echo "== Journal cleanup =="
sudo journalctl --vacuum-time=14d

echo
echo "== CachyOS mirrors =="
if command -v cachyos-rate-mirrors >/dev/null 2>&1; then
  sudo cachyos-rate-mirrors || true
fi
"""
