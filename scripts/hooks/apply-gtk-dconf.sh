#!/usr/bin/env bash
set -euo pipefail

gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
gsettings set org.gnome.desktop.interface icon-theme 'Tela-circle-blue-dark'
gsettings set org.gnome.desktop.interface font-name 'Inter 11'
gsettings set org.gnome.desktop.interface cursor-theme 'posy-black'
gsettings set org.gnome.desktop.interface cursor-size 24
gsettings set org.gnome.desktop.wm.preferences button-layout ':'

gsettings set org.nemo.preferences ignore-view-metadata true
gsettings set org.nemo.icon-view default-zoom-level 'larger'
gsettings set org.nemo.list-view default-zoom-level 'larger'
