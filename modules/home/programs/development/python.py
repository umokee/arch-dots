from __future__ import annotations

from shared.lib import add_packages, system_file


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("programs", "python-dev"):
        return

    username = helpers.username
    home = f"/home/{username}"

    add_packages(
        "python",
        "python-pip",
        "python-virtualenv",
        "python-pipx",
        "python-setuptools",
        "python-wheel",
        "uv",
        "python-numpy",
        "python-pandas",
        "python-matplotlib",
        "python-scipy",
        "python-requests",
        "python-rich",
        "python-typer",
        "python-pydantic",
        "python-sqlalchemy",
        "python-alembic",
        "python-psycopg",
        "python-asyncpg",
        "python-httpx",
        "python-pytest",
        "python-ipython",
        "pyside6",
        "python-gobject",
        "tk",
        "opencv",
        "python-pillow",
    )

    system_file(
        f"{home}/.config/direnv/lib/python-dev.sh",
        _direnv_python_lib(),
        owner=username,
    )


def _direnv_python_lib() -> str:
    return """
# Managed by Decman
# Usage in .envrc:
#   source ~/.config/direnv/lib/python-dev.sh

export QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-wayland;xcb}"
export GDK_BACKEND="${GDK_BACKEND:-wayland,x11}"
export DISPLAY="${DISPLAY:-:0}"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-1}"

export PYTHONPYCACHEPREFIX="${XDG_CACHE_HOME:-$HOME/.cache}/python"
export PIP_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/pip"
"""
