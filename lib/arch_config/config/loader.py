from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

import tomllib

from arch_config.paths import FEATURES_DIR, PROFILES_DIR


def read_toml(path: Path) -> dict[str, Any]:
    with path.open("rb") as handle:
        return tomllib.load(handle)


@dataclass(frozen=True)
class LoadedFeature:
    id: str
    root: Path
    data: dict[str, Any]


def feature_path(feature_id: str) -> Path:
    parts = feature_id.split(".")
    if len(parts) != 2 or not all(parts):
        raise SystemExit(f"Bad feature id: {feature_id}")
    return FEATURES_DIR / parts[0] / parts[1] / "feature.toml"


def load_profile(profile: str) -> dict[str, Any]:
    path = PROFILES_DIR / f"{profile}.toml"
    if not path.exists():
        raise SystemExit(f"Missing profile: {path}")
    data = read_toml(path)
    data["_profile"] = profile
    data["_profile_path"] = str(path)
    return data


def load_feature(feature_id: str) -> LoadedFeature:
    path = feature_path(feature_id)
    if not path.exists():
        raise SystemExit(f"Missing feature {feature_id}: {path}")
    data = read_toml(path)
    actual = str(data.get("id", feature_id))
    if actual != feature_id:
        raise SystemExit(
            f"Feature id mismatch in {path}: expected {feature_id}, got {actual}"
        )
    return LoadedFeature(id=feature_id, root=path.parent, data=data)
