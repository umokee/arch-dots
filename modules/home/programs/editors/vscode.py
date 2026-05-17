from __future__ import annotations

from modules.home.programs.editors._utils import dot_dir, generated_file
from shared.lib import add_packages


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("programs", "vscode"):
        return

    add_packages(
        "code",
    )

    username = helpers.username

    generated_file(
        username,
        ".config/environment.d/30-vscode-qml.conf",
        _vscode_qml_env(),
    )

    dot_dir(username, ".config/Code/User")

    generated_file(
        username,
        ".config/Code/User/keybindings.json",
        _keybindings_json(),
    )


def _vscode_qml_env() -> str:
    return """
# Managed by Decman
QML_IMPORT_PATH=/usr/lib/qt6/qml
QML2_IMPORT_PATH=/usr/lib/qt6/qml
QT_PLUGIN_PATH=/usr/lib/qt6/plugins
"""


def _keybindings_json() -> str:
    return """
[
  { "key": "ctrl+e", "command": "workbench.view.explorer" },
  { "key": "ctrl+l", "command": "workbench.action.focusActiveEditorGroup" },
  { "key": "ctrl+t", "command": "workbench.action.terminal.toggleTerminal" },
  { "key": "alt+g", "command": "workbench.view.scm" },
  { "key": "alt+x", "command": "workbench.view.extensions" },
  { "key": "alt+t", "command": "workbench.action.terminal.toggleTerminal" },
  { "key": "ctrl+5", "command": "workbench.view.debug" },
  { "key": "ctrl+6", "command": "workbench.view.search" },
  { "key": "ctrl+b", "command": "workbench.action.toggleSidebarVisibility" },
  { "key": "ctrl+j", "command": "workbench.action.togglePanel" }
]
"""
