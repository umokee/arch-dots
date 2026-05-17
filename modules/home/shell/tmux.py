from __future__ import annotations

from modules.home.shell._utils import dot_dir, generated_file
from shared.lib import add_packages


def apply(conf: dict, helpers) -> None:
    if not (helpers.has_in("programs", "tmux") or helpers.has_in("programs", "shell")):
        return

    add_packages("tmux")

    dot_dir(helpers.username, ".config/tmux")
    generated_file(
        helpers.username,
        ".tmux.conf",
        "source-file ~/.config/tmux/tmux.conf\n",
    )
