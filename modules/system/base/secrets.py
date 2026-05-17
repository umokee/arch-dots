from __future__ import annotations

from shared.lib import add_packages, system_file


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("base", "secrets"):
        return

    add_packages(
        "sops",
        "age",
    )

    key_path = conf.get("paths", {}).get("sops_age_key", "/etc/key.txt")

    system_file(
        "/etc/sops/age/README",
        f"""
Managed by Decman.

Put the age private key here:

  {key_path}

Original NixOS sops-nix mappings are preserved in:
  reference/nixos-original/modules/nixos/core/secrets.nix
""",
        mode=0o600,
    )
