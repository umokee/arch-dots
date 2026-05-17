COMMON = {
    "hostname": "archlinux",
    "username": "user",
    "color_scheme": "dark",
    "wallpaper_name": "backyard",
    "default": {
        "terminal": "foot",
        "editor": "nvim",
        "visual": "nvim",
        "browser": "zen",
    },
    "cachyos": {
        "repo_target": "v4",
        "include_base_repo": True,
        "kernel": "linux-cachyos-eevdf-lto",
        "kernel_headers": "linux-cachyos-eevdf-lto-headers",
        "kernel_extra_packages": [
            "linux-cachyos-eevdf-lto-nvidia-open",
        ],
        "install_settings": True,
        "manage_pacman_conf": False,
    },
    "paths": {
        "dotfiles": "/home/user/arch-config",
        "sops_age_key": "/etc/key.txt",
    },
}

HOSTS = {
    "desktop": {
        **COMMON,
        "machine_type": "desktop",
        "base": {
            "enable": [
                "boot",
                "system",
                "security",
                "locale",
                "network",
                "users",
                "fonts",
                "packages",
                "secrets",
                "cleanup",
            ]
        },
        "hardware": {
            "enable": [
                "sound",
                "keyboard-mouse",
                "intel",
                "nvidia",
                "power",
                "print",
            ]
        },
        "workspace": {
            "enable": [
                "hyprland",
                "display-manager",
                "quickshell",
                "themes",
                "wallpapers",
            ]
        },
        "programs": {
            "enable": [
                "git",
                "nvim",
                "vscode",
                "gaming",
                "appimage",
                "browsers",
                "terminal",
                "dev",
                "shell",
            ]
        },
        "services": {
            "enable": [
                "postgresql",
                "virtual-machine",
                "xray",
                "openssh",
                "gammastep",
                "file-management",
                "fstrim",
                "kanata",
            ]
        },
    },
    "laptop": {
        **COMMON,
        "machine_type": "laptop",
        "base": {
            "enable": [
                "boot",
                "system",
                "security",
                "locale",
                "network",
                "users",
                "fonts",
                "packages",
                "secrets",
                "cleanup",
            ]
        },
        "hardware": {
            "enable": [
                "keyboard-mouse",
                "amd",
                "power",
                "sound",
            ]
        },
        "workspace": {
            "enable": [
                "hyprland",
                "display-manger",
                "wallpapers",
                "themes",
            ]
        },
        "programs": {
            "enable": [
                "git",
                "nvim",
                "browsers",
                "shell",
                "dev",
            ]
        },
        "services": {
            "enable": [
                "sing-box",
                "openssh",
                "brightnessctl",
                "fstrim",
                "gammastep",
            ]
        },
    },
    "server": {
        **COMMON,
        "machine_type": "server",
        "base": {
            "enable": [
                "boot",
                "system",
                "security",
                "locale",
                "network",
                "users",
                "packages",
                "secrets",
                "cleanup",
            ]
        },
        "hardware": {"enable": []},
        "workspace": {"enable": []},
        "programs": {
            "enable": [
                "git",
                "shell",
            ]
        },
        "services": {
            "enable": [
                "postgresql",
                "openssh",
                "xray",
                "fail2ban",
                "fstrim",
            ]
        },
    },
    "iso": {
        **COMMON,
        "machine_type": "iso",
        "base": {
            "enable": [
                "system",
                "security",
                "locale",
                "network",
                "users",
                "fonts",
                "packages",
            ]
        },
        "hardware": {
            "enable": [
                "sound",
                "keyboard-mouse",
            ]
        },
        "workspace": {
            "enable": [
                "hyprland",
                "display-manager",
                "wallpapers",
                "themes",
            ]
        },
        "programs": {
            "enable": [
                "git",
                "nvim",
                "shell",
            ]
        },
        "services": {"enable": []},
    },
}
