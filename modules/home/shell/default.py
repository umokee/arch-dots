from __future__ import annotations

from modules.home.shell import fish, foot, starship, tmux


def apply(conf: dict, helpers) -> None:
    fish.apply(conf, helpers)
    foot.apply(conf, helpers)
    starship.apply(conf, helpers)
    tmux.apply(conf, helpers)
