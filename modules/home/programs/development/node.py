from __future__ import annotations

from shared.lib import add_packages, system_file


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("programs", "node-dev"):
        return

    username = helpers.username
    home = f"/home/{username}"

    add_packages(
        "nodejs",
        "npm",
        "pnpm",
        "yarn",
        "typescript",
        "eslint",
        "vscode-css-languageserver",
        "vscode-html-languageserver",
        "vscode-json-languageserver",
    )

    system_file(
        f"{home}/.config/direnv/lib/node-dev.sh",
        _direnv_node_lib(),
        owner=username,
    )


def _direnv_node_lib() -> str:
    return """
# Managed by Decman
# Usage in .envrc:
#   source ~/.config/direnv/lib/node-dev.sh

export NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/npm/npmrc"
export npm_config_cache="${XDG_CACHE_HOME:-$HOME/.cache}/npm"
export PNPM_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/pnpm"

case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
"""
