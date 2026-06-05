from __future__ import annotations

import json

from arch_config.commands.common import profile_from_args
from arch_config.core.reporter import print_validation_result
from arch_config.engine import validate


def cmd_validate(args) -> int:
    profile = profile_from_args(args)
    code, errors, warnings = validate(profile)

    if args.json:
        print(json.dumps({"errors": errors, "warnings": warnings}, ensure_ascii=False, indent=2))
        return code

    print_validation_result(profile, errors, warnings)
    return code
