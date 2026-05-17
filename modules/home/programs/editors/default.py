from __future__ import annotations

from modules.home.programs.editors import nvim, vscode


def apply(conf: dict, helpers) -> None:
    nvim.apply(conf, helpers)
    vscode.apply(conf, helpers)
