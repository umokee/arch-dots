from __future__ import annotations

import argparse
import sys

from arch_config import __version__
from arch_config.commands import (
    cmd_check_generated,
    cmd_diff,
    cmd_generate,
    cmd_generated,
    cmd_plan,
    cmd_prune,
    cmd_self_test,
    cmd_switch,
    cmd_validate,
    cmd_vars,
)


def _insert_default_switch_command(argv: list[str]) -> list[str]:
    switch_flags = {
        "--aur",
        "--helper",
        "--dry-run",
        "-y",
        "--yes",
        "--strict",
        "--no-prune-aur",
        "--remove-orphans",
        "--no-prune-files",
    }
    known_commands = {
        "validate",
        "plan",
        "diff",
        "status",
        "generate",
        "check-generated",
        "vars",
        "switch",
        "self-test",
        "generated",
        "prune",
        "clean",
    }

    has_command = any(arg in known_commands for arg in argv)
    has_switch_flag = any(arg in switch_flags for arg in argv)

    if not has_switch_flag or has_command:
        return argv

    insert_at = 0
    while insert_at < len(argv):
        arg = argv[insert_at]
        if arg in {"-p", "--profile"} and insert_at + 1 < len(argv):
            insert_at += 2
            continue
        if arg == "--version":
            insert_at += 1
            continue
        break

    return [*argv[:insert_at], "switch", *argv[insert_at:]]


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="archctl")
    parser.add_argument("-p", "--profile", default=None)
    parser.add_argument("--version", action="store_true")
    sub = parser.add_subparsers(dest="command")

    validate_parser = sub.add_parser("validate")
    validate_parser.add_argument("--json", action="store_true")
    validate_parser.set_defaults(func=cmd_validate)

    plan_parser = sub.add_parser("plan")
    plan_parser.set_defaults(func=cmd_plan)

    status_parser = sub.add_parser("status")
    status_parser.set_defaults(func=cmd_plan)

    diff_parser = sub.add_parser("diff")
    diff_parser.add_argument("--strict", action="store_true")
    diff_parser.add_argument(
        "--no-aur",
        "--no-prune-aur",
        dest="no_aur",
        action="store_true",
    )
    diff_parser.add_argument("--remove-orphans", action="store_true")
    diff_parser.set_defaults(func=cmd_diff)

    generate_parser = sub.add_parser("generate")
    generate_parser.set_defaults(func=cmd_generate)

    check_generated_parser = sub.add_parser("check-generated")
    check_generated_parser.set_defaults(func=cmd_check_generated)

    vars_parser = sub.add_parser("vars")
    vars_parser.set_defaults(func=cmd_vars)

    switch_parser = sub.add_parser("switch")
    switch_parser.add_argument("--aur", action="store_true")
    switch_parser.add_argument("--helper", default="yay")
    switch_parser.add_argument("--dry-run", action="store_true")
    switch_parser.add_argument("-y", "--yes", action="store_true")
    switch_parser.add_argument("--strict", action="store_true")
    switch_parser.add_argument("--no-prune-aur", action="store_true")
    switch_parser.add_argument("--remove-orphans", action="store_true")
    switch_parser.add_argument("--no-prune-files", action="store_true")
    switch_parser.set_defaults(func=cmd_switch)

    prune_parser = sub.add_parser("prune")
    _add_prune_arguments(prune_parser)
    prune_parser.set_defaults(func=cmd_prune)

    clean_parser = sub.add_parser("clean")
    _add_prune_arguments(clean_parser)
    clean_parser.set_defaults(func=cmd_prune)

    self_test_parser = sub.add_parser("self-test")
    self_test_parser.add_argument("--all-profiles", action="store_true")
    self_test_parser.add_argument("--no-render", action="store_true")
    self_test_parser.set_defaults(func=cmd_self_test)

    generated_parser = sub.add_parser("generated")
    generated_sub = generated_parser.add_subparsers(dest="generated_cmd", required=True)
    generated_list_parser = generated_sub.add_parser("list")
    generated_list_parser.set_defaults(func=cmd_generated)
    generated_show_parser = generated_sub.add_parser("show")
    generated_show_parser.add_argument("name")
    generated_show_parser.set_defaults(func=cmd_generated)

    return parser


def _add_prune_arguments(parser: argparse.ArgumentParser) -> None:
    parser.add_argument("--apply", action="store_true")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("-y", "--yes", action="store_true")
    parser.add_argument("--no-aur", action="store_true")
    parser.add_argument("--remove-orphans", action="store_true")


def main(argv: list[str] | None = None) -> int:
    if argv is None:
        argv = sys.argv[1:]

    argv = _insert_default_switch_command(argv)
    parser = build_parser()
    args = parser.parse_args(argv)

    if args.version:
        print(f"archctl {__version__}")
        return 0

    if not hasattr(args, "func"):
        parser.print_help()
        return 1

    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
