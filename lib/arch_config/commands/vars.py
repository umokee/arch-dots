from __future__ import annotations

import json

from arch_config.commands.common import profile_from_args
from arch_config.engine import resolve


def cmd_vars(args) -> int:
    state = resolve(profile_from_args(args))
    keys = [key for key in state.config.keys() if not key.startswith("_")]
    print(json.dumps({key: state.config[key] for key in keys}, ensure_ascii=False, indent=2))
    return 0
