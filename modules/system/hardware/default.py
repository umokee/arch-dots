from __future__ import annotations

from modules.system.hardware import (
    amd,
    bluetooth,
    graphics,
    intel,
    nvidia,
    peripherals,
    power,
    print,
    sound,
)


def apply(conf: dict, helpers) -> None:
    graphics.apply(conf, helpers)
    intel.apply(conf, helpers)
    amd.apply(conf, helpers)
    nvidia.apply(conf, helpers)
    sound.apply(conf, helpers)
    bluetooth.apply(conf, helpers)
    power.apply(conf, helpers)
    print.apply(conf, helpers)
    peripherals.apply(conf, helpers)
