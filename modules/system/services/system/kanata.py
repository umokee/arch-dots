from __future__ import annotations

from shared.lib import add_aur, system_file, systemd_unit


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("services", "kanata"):
        return

    add_aur("kanata")

    system_file(
        "/etc/kanata/config.kbd",
        _kanata_config(),
    )

    systemd_unit(
        "kanata.service",
        _kanata_unit(),
    )


def _kanata_config() -> str:
    return """;; Managed by Decman
;; Placeholder.
;; Put your final keyboard remap here.

(defcfg
  process-unmapped-keys yes
)

(defsrc)
(deflayer base)
"""


def _kanata_unit() -> str:
    return """[Unit]
Description=Kanata keyboard remapper
After=multi-user.target

[Service]
Type=simple
ExecStart=/usr/bin/kanata -c /etc/kanata/config.kbd
Restart=on-failure
RestartSec=2

[Install]
WantedBy=multi-user.target
"""
