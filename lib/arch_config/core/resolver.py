from __future__ import annotations

from arch_config.core.models import DesiredState
from arch_config.resolver import resolve as _resolve


def resolve(profile_name: str) -> DesiredState:
    return _resolve(profile_name)
