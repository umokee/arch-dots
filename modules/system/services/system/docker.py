from __future__ import annotations

from shared.lib import add_packages, enable_units, system_file


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("services", "docker"):
        return

    add_packages(
        "docker",
        "docker-compose",
        "docker-buildx",
    )

    system_file(
        "/etc/docker/daemon.json",
        _daemon_json(),
    )

    enable_units("docker.service")


def _daemon_json() -> str:
    return """{
  "dns": [
    "1.1.1.1",
    "8.8.8.8"
  ],
  "log-driver": "journald",
  "features": {
    "cdi": true
  }
}
"""
