from __future__ import annotations

from modules.home.theme import cursor, env, fonts, gtk, icons, qt


def apply(conf: dict, helpers) -> None:
    if not (helpers.has_in("workspace", "themes") or helpers.is_wm):
        return

    env.apply(conf, helpers)
    fonts.apply(conf, helpers)
    icons.apply(conf, helpers)
    cursor.apply(conf, helpers)
    gtk.apply(conf, helpers)
    qt.apply(conf, helpers)
