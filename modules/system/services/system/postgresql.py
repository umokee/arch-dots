from __future__ import annotations

from shared.lib import add_packages, enable_units, system_file, systemd_unit


def apply(conf: dict, helpers) -> None:
    if not helpers.has_in("services", "postgresql"):
        return

    add_packages(
        "postgresql",
        "postgresql-libs",
    )

    system_file(
        "/etc/tmpfiles.d/postgresql-local.conf",
        "d /var/lib/postgres/data 0700 postgres postgres -\n",
    )

    system_file(
        "/etc/postgresql/local.conf",
        _postgresql_local_conf(),
    )

    systemd_unit(
        "postgresql-first-init.service",
        _postgresql_first_init_unit(),
    )

    systemd_unit(
        "postgresql-apply-config.service",
        _postgresql_apply_config_unit(),
    )

    enable_units(
        "postgresql-first-init.service",
        "postgresql-apply-config.service",
        "postgresql.service",
    )


def _postgresql_local_conf() -> str:
    return """# Managed by Decman

port = 5432
listen_addresses = '*'

shared_buffers = '128MB'
effective_cache_size = '512MB'
work_mem = '4MB'
maintenance_work_mem = '64MB'

wal_buffers = '16MB'
checkpoint_completion_target = 0.9
min_wal_size = '1GB'
max_wal_size = '4GB'

log_min_duration_statement = 1000
log_connections = on
log_disconnections = on
"""


def _postgresql_first_init_unit() -> str:
    return """[Unit]
Description=Initialize PostgreSQL database if needed
Before=postgresql.service
ConditionPathExists=!/var/lib/postgres/data/PG_VERSION

[Service]
Type=oneshot
User=postgres
ExecStart=/usr/bin/initdb -D /var/lib/postgres/data --locale=en_US.UTF-8 -E UTF8

[Install]
WantedBy=multi-user.target
"""


def _postgresql_apply_config_unit() -> str:
    return """[Unit]
Description=Attach Decman PostgreSQL config
After=postgresql-first-init.service
Before=postgresql.service
ConditionPathExists=/var/lib/postgres/data/postgresql.conf

[Service]
Type=oneshot
ExecStart=/usr/bin/bash -lc 'grep -q "^include_if_exists = '\\''/etc/postgresql/local.conf'\\''" /var/lib/postgres/data/postgresql.conf || echo "include_if_exists = '\\''/etc/postgresql/local.conf'\\''" >> /var/lib/postgres/data/postgresql.conf'

[Install]
WantedBy=multi-user.target
"""
