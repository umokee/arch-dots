from __future__ import annotations

from shared.lib import add_packages, system_file

FONT_PACKAGES = [
    "fontconfig",
    "ttf-dejavu",
    "ttf-liberation",
    "noto-fonts",
    "noto-fonts-emoji",
    "noto-fonts-cjk",
    "noto-fonts-extra",
]


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("base", "fonts"):
        return

    add_packages(*FONT_PACKAGES)

    system_file(
        "/etc/fonts/local.conf",
        """
<?xml version='1.0'?>
<!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
<fontconfig>
  <alias>
    <family>serif</family>
    <prefer>
      <family>DejaVu Serif</family>
    </prefer>
  </alias>

  <alias>
    <family>sans-serif</family>
    <prefer>
      <family>DejaVu Sans</family>
    </prefer>
  </alias>

  <alias>
    <family>monospace</family>
    <prefer>
      <family>JetBrainsMono Nerd Font</family>
    </prefer>
  </alias>
</fontconfig>
""",
    )
