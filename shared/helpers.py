WAYLAND_COMPOSITORS = ["hyprland", "niri", "dwl", "mangowc", "sway"]
X11_WMS = ["bspwm", "dwm"]
WLR_COMPOSITORS = ["sway", "dwl", "mangowc"]

class Helpers:
    def __init__(self, conf: dict):
        self.conf = conf

    def has_in(self, category: str, feature: str | list[str] | None = None) -> bool:
        enabled = self.conf.get(category, {}).get("enable", [])

        if feature is None:
            return bool(enabled)        
        if isinstance(feature, list):
            return any(x in enabled for x in feature)
        return feature in enabled

    @property
    def username(self) -> str: return self.conf["username"]
    @property
    def home(self) -> str: return f"/home/{self.username}"
    @property
    def is_laptop(self) -> bool: return self.conf["machine_type"] == "laptop"
    @property
    def is_desktop(self) -> bool: return self.conf["machine_type"] == "desktop"
    @property
    def is_server(self) -> bool: return self.conf["machine_type"] == "server"
    @property
    def is_iso(self) -> bool: return self.conf["machine_type"] == "iso"
    @property
    def is_wayland(self) -> bool: return self.has_in("workspace", WAYLAND_COMPOSITORS)
    @property
    def is_x11(self) -> bool: return self.has_in("workspace", X11_WMS)
    @property
    def is_wm(self) -> bool: return self.has_in("workspace", WAYLAND_COMPOSITORS + X11_WMS)
    @property
    def is_hyprland(self) -> bool: return self.has_in("workspace", "hyprland")
    @property
    def is_wlr(self) -> bool: return self.has_in("workspace", WLR_COMPOSITORS)
    @property
    def has_nvidia(self) -> bool: return self.has_in("hardware", "nvidia")
    @property
    def has_intel(self) -> bool: return self.has_in("hardware", "intel")
    @property
    def has_amd(self) -> bool: return self.has_in("hardware", "amd")

    def user_file(self, rel: str) -> str:
        return f"{self.home}/{rel.lstrip('/')}"
