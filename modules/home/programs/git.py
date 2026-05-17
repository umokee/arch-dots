from __future__ import annotations

from shared.lib import add_packages, system_file


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("programs", "git"):
        return

    username = helpers.username
    home = f"/home/{username}"

    add_packages(
        "git",
        "github-cli",
        "diff-so-fancy",
    )

    system_file(
        f"{home}/.gitconfig",
        _gitconfig(),
        owner=username,
    )

    system_file(
        f"{home}/.config/git/ignore",
        _gitignore(),
        owner=username,
    )


def _gitconfig() -> str:
    return """
# Managed by Decman

[user]
    name = umokee
    email = hituaev@gmail.com

[init]
    defaultBranch = main

[core]
    editor = nvim
    excludesFile = ~/.config/git/ignore
    autocrlf = input
    whitespace = trailing-space,space-before-tab

[pull]
    rebase = false

[push]
    autoSetupRemote = true
    default = simple

[merge]
    conflictStyle = zdiff3

[diff]
    colorMoved = default

[color]
    ui = auto

[status]
    short = true
    branch = true
    showStash = true

[log]
    date = local

[alias]
    st = status
    co = checkout
    br = branch
    ci = commit
    lg = log --oneline --graph --decorate --all
    last = log -1 HEAD --stat
    unstage = reset HEAD --
    amend = commit --amend

[interactive]
    diffFilter = diff-so-fancy --patch

[diff-so-fancy]
    markEmptyLines = false
"""


def _gitignore() -> str:
    return """
.vscode/
.idea/
__pycache__/
.venv/
.syncrclone/
node_modules/
tags
test.sh
.luarc.json
spell/
lazy-lock.json
CLAUDE.md
.claude/
storage/*
.lh/
.history/
"""
