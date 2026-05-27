# arch-dots final friendly

Новый формат сделан так, чтобы модуль был самодостаточным и не приходилось прыгать между `config`, `templates/*/files.toml` и `dots`.

```text
profiles/<name>.toml          профиль машины, включённые features и явные параметры
features/<group>/<name>/      один самодостаточный модуль
  feature.toml                пакеты, файлы, systemd, hooks
  files/                      обычные файлы без параметров, обычно symlink
  templates/                  шаблоны с {{ variable }}
hooks/*.sh                    только shell-хуки
```

Правило простое:

```text
files/      = хранится как есть
templates/  = рендерится из profiles/*.toml
feature.toml = всё, что делает модуль
```

## Важно при установке

Не распаковывай архив поверх старой папки `arch-dots`. Иначе могут остаться старые пакеты Python вроде `lib/arch_config/resolver/`, которые перекроют новый `resolver.py`.

Нормально так:

```bash
cd ~
mv arch-dots arch-dots-old
unzip arch-dots-final-friendly.zip
cd arch-dots
```

## Проверка

```bash
./scripts/archctl --version
./scripts/archctl -p desktop validate
./scripts/archctl -p desktop self-test --all-profiles --no-render
./scripts/archctl -p desktop generate
./scripts/archctl -p desktop check-generated
```

Или одной командой:

```bash
./scripts/check.sh
```

## Обычное применение

```bash
./scripts/archctl -p desktop plan
./scripts/archctl -p desktop switch --aur
```

Старый привычный запуск тоже работает и автоматически считается `switch`:

```bash
./scripts/archctl.py -p desktop --aur
```

## Строгая чистка пакетов

Посмотреть, что будет удалено:

```bash
./scripts/archctl -p desktop prune
```

Удалить лишние пакеты:

```bash
./scripts/archctl -p desktop prune --apply
```

Или после применения:

```bash
./scripts/archctl -p desktop switch --aur --strict
```

Исключения задаются в профиле:

```toml
[ignore]
pacman = ["yay"]
foreign = ["yay", "decman", "aconfmgr-git"]

[prune]
protected = []
protect_patterns = ["linux*", "nvidia*", "cachyos*"]
```

## Диски

Проверить генерацию automount:

```bash
./scripts/archctl -p desktop generated list | grep disk
./scripts/archctl -p desktop generated show 'mnt-disk\x2dbtrfs.automount'
```
