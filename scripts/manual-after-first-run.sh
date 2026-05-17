#!/usr/bin/env bash
set -euo pipefail
sudo locale-gen
sudo ln -sf /usr/share/zoneinfo/Asia/Vladivostok /etc/localtime
sudo hwclock --systohc || true
sudo mkinitcpio -P
sudo grub-mkconfig -o /boot/grub/grub.cfg
systemctl --user daemon-reload || true
systemctl --user enable --now gammastep.service 2>/dev/null || true
systemctl --user enable --now swaybg-daemon.service 2>/dev/null || true
