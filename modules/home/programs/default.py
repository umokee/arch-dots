from __future__ import annotations

from modules.home.programs import appimage, apps, files, gaming, git, ssh
from modules.home.programs.applications import default as applications
from modules.home.programs.development import default as development
from modules.home.programs.editors import default as editors


def apply(conf: dict, helpers) -> None:
    git.apply(conf, helpers)
    ssh.apply(conf, helpers)
    apps.apply(conf, helpers)
    files.apply(conf, helpers)
    gaming.apply(conf, helpers)
    appimage.apply(conf, helpers)
    applications.apply(conf, helpers)
    development.apply(conf, helpers)
    editors.apply(conf, helpers)
