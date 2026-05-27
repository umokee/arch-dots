# Friendly format

Профиль — единственное место для параметров конкретной машины. Если шаблон использует `{{ kernel.params }}` или `{{ quickshell.screen }}`, эти значения должны быть явно видны в `profiles/<profile>.toml`.

Feature — самодостаточный модуль. Пример:

```toml
id = "workspace.quickshell"
description = "Quickshell panel"

[packages]
pacman = ["qt6-base", "qt6-declarative"]
aur = ["quickshell-git"]

[[dirs]]
target = "~/.config/quickshell"
permissions = "755"

[[files]]
source = "files/home/.config/quickshell"
target = "~/.config/quickshell"
mode = "link"
type = "dir"

[[files]]
source = "templates/HostConfig.qml.j2"
target = "~/.config/quickshell/HostConfig.qml"
mode = "template"
permissions = "644"

[[systemd.user]]
unit = "quickshell.service"
enable = true
start = true

[[hooks]]
name = "some-hook"
script = "some-hook.sh"
run = "post"
```

## File modes

- `link` — сделать symlink на файл/папку внутри feature;
- `copy` — скопировать файл;
- `template` — отрендерить `{{ ... }}` из профиля и записать target.

## Templates

Шаблоны используют маленький Jinja2-похожий синтаксис без внешней зависимости:

```text
{{ username }}
{{ kernel.params | join(' ') }}
{{ quickshell.screen }}
```

Поддержанные фильтры:

```text
join('separator')
lower
upper
quote
html_escape
```

Расширение `.j2` нужно только как маркер: это шаблон. В систему `.j2` не попадает.

## Hooks

Hooks всегда лежат в `hooks/*.sh`. Если нужны root-права, скрипт сам вызывает `sudo`.
