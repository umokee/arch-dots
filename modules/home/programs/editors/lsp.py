from __future__ import annotations

from shared.lib import add_aur, add_packages


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("programs", ["nvim", "vscode"]):
        return

    add_packages(
        "lua-language-server",
        "stylua",
        "nil",
        "nixfmt",
        "ruff",
        "python-black",
        "python-isort",
        "typescript-language-server",
        "prettier",
        "eslint_d",
        "yaml-language-server",
        "bash-language-server",
        "shfmt",
        "shellcheck",
        "clang",
        "clang-tools-extra",
        "gopls",
        "go",
    )

    add_aur(
        "selene",
        "basedpyright",
        "vscode-langservers-extracted",
        "emmet-ls",
        "dockerfile-language-server",
        "docker-compose-language-service",
        "tailwindcss-language-server",
        "hadolint-bin",
        "netcoredbg",
        "omnisharp-roslyn",
    )
