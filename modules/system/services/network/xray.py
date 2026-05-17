from __future__ import annotations

from shared.lib import add_aur, system_file


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("services", "xray"):
        return

    add_aur("xray")

    system_file(
        "/etc/xray/config.json",
        _xray_config(),
        mode=0o600,
    )

    # Enable only when you are ready.
    # Old Decman config also kept xray.service disabled/commented.
    # enable_units("xray.service")


def _xray_config() -> str:
    return """{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [],
  "outbounds": [
    {
      "protocol": "freedom",
      "tag": "direct"
    }
  ]
}
"""
