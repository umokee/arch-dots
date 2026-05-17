from __future__ import annotations

from modules.home.workspace._utils import dot_dir, generated_file
from shared.lib import add_aur


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("workspace", "tofi"):
        return

    add_aur("tofi")

    dot_dir(helpers.username, ".config/tofi")

    generated_file(
        helpers.username,
        ".local/bin/tofi-clear-cache",
        _clear_cache_script(),
        mode=0o755,
    )


def _clear_cache_script() -> str:
    return """
#!/usr/bin/env bash
set -euo pipefail

rm -f "$HOME/.cache/tofi-drun"
"""
