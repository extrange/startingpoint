#!/usr/bin/env bash

set -oue pipefail

gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true

# Setup Alt-Tab to switch between windows instead of applications
dconf write /org/gnome/desktop/wm/keybindings/switch-applications "@as []"
dconf write /org/gnome/desktop/wm/keybindings/switch-windows "['<alt>Tab']"

# Map capslock to backspace
dconf write /org/gnome/desktop/input-sources/xkb-options "['caps:backspace']"