#!/bin/bash
# archlinux-sway-uninstall.sh
# Cleanup script for Arch Linux Sway setup

set -e

echo "[1/10] Removing non-essential packages..."
sudo pacman -Rcns --noconfirm sway swaylock waybar wofi grim slurp wl-clipboard xorg-xwayland \
    ghostty librewolf brave-bin\
    ttf-font-awesome noto-fonts papirus-icon-theme \
    pcmanfm-gtk3 xarchiver unzip p7zip unrar qpdfview \
    playerctl dunst brightnessctl polkit-gnome \
    azote lxtask blueman

echo "[2/10] Disabling BLuetooth..."
sudo systemctl disable --now bluetooth || true
# Do NOT disable NetworkManager — user might still need it.

echo "[3/10] Removing Waybar config..."
rm -rf ~/.config/waybar

echo "[4/10] Removing Sway config..."
rm -rf ~/.config/sway

echo "[5/10] Removing Wofi config..."
rm -rf ~/.config/wofi

echo "[6/10] Removing Dunst config..."
rm -rf ~/.config/dunst

echo "[7/10] Removing custom scripts..."
rm -f ~/.local/bin/power-menu.sh
rm -f ~/.local/bin/timeshift-gui.sh

echo "[8/10] Removing custom .desktop files..."
rm -f ~/.local/share/applications/brave-browser.desktop
rm -f ~/.local/share/applications/ghostty.desktop
rm -f ~/.local/share/applications/feh.desktop
rm -f ~/.local/share/applications/qpdfview.desktop
rm -f ~/.local/share/applications/timeshift-gui.desktop

echo "[9/10] Cleaning MIME defaults and profile exports..."
rm -f ~/.config/mimeapps.list

sed -i '/export BROWSER=brave/d' ~/.profile || true
sed -i '/export TERMINAL=ghostty/d' ~/.profile || true
sed -i '/export DOCUMENT_VIEWER=qpdfview/d' ~/.profile || true

echo "[10/10] Cleanup complete!"
echo "✅ All Sway-related configs, packages, and Timeshift wrapper removed."
echo "⚠️ Essentials like NetworkManager, libnotify, inotify-tools, and Timeshift itself were kept."
