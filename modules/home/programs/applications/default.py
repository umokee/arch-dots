from __future__ import annotations

from modules.home.programs.applications import browsers, rclone


def apply(conf: dict, helpers) -> None:
    browsers.apply(conf, helpers)
    rclone.apply(conf, helpers)
