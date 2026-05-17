from __future__ import annotations

from shared.lib import system_file


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("base", "locale"):
        return

    system_file(
        "/etc/locale.gen",
        "en_US.UTF-8 UTF-8\nru_RU.UTF-8 UTF-8\n",
    )

    system_file(
        "/etc/locale.conf",
        """
LANG=en_US.UTF-8
LC_ADDRESS=en_US.UTF-8
LC_IDENTIFICATION=en_US.UTF-8
LC_MEASUREMENT=en_US.UTF-8
LC_MONETARY=en_US.UTF-8
LC_NAME=en_US.UTF-8
LC_NUMERIC=en_US.UTF-8
LC_PAPER=en_US.UTF-8
LC_TELEPHONE=en_US.UTF-8
LC_TIME=en_US.UTF-8
""",
    )

    system_file(
        "/etc/vconsole.conf",
        "KEYMAP=us\n",
    )
