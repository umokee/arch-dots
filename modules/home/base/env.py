from __future__ import annotations

from shared.lib import system_file


def apply(conf: dict, helpers) -> None:
    username = helpers.username
    home = f"/home/{username}"

    system_file(
        f"{home}/.config/environment.d/10-user.conf",
        _environment_d(conf, username),
        owner=username,
    )

    system_file(
        f"{home}/.config/fish/conf.d/env.fish",
        _fish_env(conf, username),
        owner=username,
    )

    system_file(
        f"{home}/.config/npm/npmrc",
        _npmrc(),
        owner=username,
    )


def _environment_d(conf: dict, username: str) -> str:
    default = conf.get("default", {})

    terminal = default.get("terminal", "foot")
    editor = default.get("editor", "nvim")
    visual = default.get("visual", editor)
    browser = default.get("browser", "firefox")

    return f"""
# Managed by Decman

DOTS=/home/{username}/arch
TERMINAL={terminal}
EDITOR={editor}
VISUAL={visual}
BROWSER={browser}

XDG_CONFIG_HOME=/home/{username}/.config
XDG_DATA_HOME=/home/{username}/.local/share
XDG_CACHE_HOME=/home/{username}/.cache
XDG_STATE_HOME=/home/{username}/.local/state

SOPS_AGE_KEY_FILE=/etc/key.txt
"""


def _fish_env(conf: dict, username: str) -> str:
    default = conf.get("default", {})

    terminal = default.get("terminal", "foot")
    editor = default.get("editor", "nvim")
    visual = default.get("visual", editor)
    browser = default.get("browser", "firefox")

    return f"""
# Managed by Decman

set -gx DOTS "/home/{username}/config"

set -gx TERMINAL {terminal}
set -gx EDITOR {editor}
set -gx VISUAL {visual}
set -gx BROWSER {browser}

set -gx PAGER less
set -gx LESS "-R"
set -gx LESSHISTFILE "-"

set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_DATA_HOME "$HOME/.local/share"
set -gx XDG_CACHE_HOME "$HOME/.cache"
set -gx XDG_STATE_HOME "$HOME/.local/state"

set -gx SOPS_AGE_KEY_FILE /etc/key.txt

set -gx PYTHONPYCACHEPREFIX "$XDG_CACHE_HOME/python"
set -gx PYTHON_HISTORY "$XDG_STATE_HOME/python/history"

set -gx CARGO_HOME "$XDG_DATA_HOME/cargo"
set -gx RUSTUP_HOME "$XDG_DATA_HOME/rustup"
set -gx GOPATH "$XDG_DATA_HOME/go"

set -gx NPM_CONFIG_USERCONFIG "$XDG_CONFIG_HOME/npm/npmrc"

fish_add_path "$HOME/.local/bin"
fish_add_path "$CARGO_HOME/bin"
fish_add_path "$GOPATH/bin"
"""


def _npmrc() -> str:
    return """
prefix=${XDG_DATA_HOME}/npm
cache=${XDG_CACHE_HOME}/npm
init-module=${XDG_CONFIG_HOME}/npm/config/npm-init.js
logs-dir=${XDG_STATE_HOME}/npm/logs
"""
