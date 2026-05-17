from __future__ import annotations

from shared.lib import add_packages, enable_units, system_file, systemd_unit


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("services", "sing-box"):
        return

    add_packages("sing-box")

    system_file(
        "/etc/sing-box/config.json",
        _sing_box_config(),
        mode=0o600,
    )

    systemd_unit(
        "singbox-wrapper.service",
        _sing_box_unit(),
    )

    enable_units("singbox-wrapper.service")


def _sing_box_config() -> str:
    return """{
  "log": {
    "level": "warn"
  },
  "inbounds": [],
  "outbounds": [
    {
      "type": "direct",
      "tag": "direct"
    }
  ]
}
"""


def _sing_box_unit() -> str:
    return """[Unit]
Description=sing-box service wrapper
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=/usr/bin/sing-box run -c /etc/sing-box/config.json
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
"""
