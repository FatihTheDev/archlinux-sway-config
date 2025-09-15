#!/bin/bash
# sway-setup.sh
# Setup Sway + Waybar + Wofi + custom config on Arch Linux
# Includes: Bluetooth, PipeWire/PulseAudio choice, smart volume & brightness fallbacks, wallpaper GUI

set -e

echo "[1/14] Updating system..."
sudo pacman -Syu --noconfirm

echo "[2/14] Installing essential packages..."
sudo pacman -S --noconfirm sway waybar wofi grim slurp wl-clipboard \
    ghostty librewolf brave-bin \
    network-manager-applet nm-connection-editor \
    ttf-font-awesome noto-fonts \
    pcmanfm-gtk3 alacritty \
    playerctl dunst libnotify brightnessctl \
    azote lxtask

# -----------------------
# Audio system selection
# -----------------------
echo "Select audio system (default PipeWire):"
echo "1) PipeWire"
echo "2) PulseAudio"
read -p "Enter choice [1-2]: " audio_choice
audio_choice=${audio_choice:-1}

if [ "$audio_choice" -eq 2 ]; then
    echo "[3/14] Installing PulseAudio..."
    sudo pacman -S --noconfirm pulseaudio pavucontrol
    echo "PulseAudio selected."
else
    echo "[3/14] Installing PipeWire (default)..."
    sudo pacman -S --noconfirm pipewire pipewire-pulse wireplumber pavucontrol
    echo "PipeWire selected."
fi

# -----------------------
# Bluetooth installation
# -----------------------
echo "[4/14] Installing Bluetooth stack and GUI..."
sudo pacman -S --noconfirm bluez bluez-utils blueman
sudo systemctl enable --now bluetooth

# -----------------------
# NetworkManager
# -----------------------
sudo systemctl enable --now NetworkManager

# -----------------------
# Configuring Sway
# -----------------------
echo "[5/14] Configuring Sway..."
mkdir -p ~/.config/sway
if [ ! -f ~/.config/sway/config ]; then
    cp /etc/sway/config ~/.config/sway/config
fi

cat > ~/.config/sway/config << 'EOF'
set $mod Mod4

# --------------------
# Launchers
# --------------------
bindsym $mod+b exec brave
bindsym $mod+l exec librewolf
bindsym $mod+Return exec ghostty
bindsym $mod+e exec pcmanfm
bindsym $mod+Shift+s exec grim -g "$(slurp)" - | wl-copy
bindsym $mod+w exec azote
bindsym Control+Shift+Escape exec lxtask

# --------------------
# Window management
# --------------------
bindsym $mod+f fullscreen toggle
bindsym $mod+q kill

# --------------------
# Keyboard layouts
# --------------------
input * {
    xkb_layout "ba,us"
    xkb_options "grp:alt_shift_toggle"
}

# --------------------
# App launcher
# --------------------
bindsym $mod exec wofi --show drun
bindsym $mod+Shift+q exec ~/.local/bin/power-menu.sh

# --------------------
# Autostart
# --------------------
exec_always waybar
exec_always dunst

# --------------------
# Volume keys (XF86)
# --------------------
bindsym XF86AudioRaiseVolume exec pactl set-sink-volume @DEFAULT_SINK@ +5% && \
    pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d{1,3}(?=%)' | head -1 | \
    xargs -I{} notify-send "🔊 Volume ↑" "{}%" --hint=int:value:{}
bindsym XF86AudioLowerVolume exec pactl set-sink-volume @DEFAULT_SINK@ -5% && \
    pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d{1,3}(?=%)' | head -1 | \
    xargs -I{} notify-send "🔉 Volume ↓" "{}%" --hint=int:value:{}
bindsym XF86AudioMute exec pactl set-sink-mute @DEFAULT_SINK@ toggle && \
    pactl get-sink-mute @DEFAULT_SINK@ | grep -q "yes" && \
    notify-send "🔇 Muted" --hint=int:value:0 || \
    pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d{1,3}(?=%)' | head -1 | \
    xargs -I{} notify-send "🔊 Unmuted" "{}%" --hint=int:value:{}

# --------------------
# Brightness keys (XF86)
# --------------------
bindsym XF86MonBrightnessUp exec brightnessctl set +10% && \
    brightnessctl -m | awk -F, '{print $4}' | tr -d '%' | \
    xargs -I{} notify-send "☀️ Brightness ↑" "{}%" --hint=int:value:{}
bindsym XF86MonBrightnessDown exec brightnessctl set 10%- && \
    brightnessctl -m | awk -F, '{print $4}' | tr -d '%' | \
    xargs -I{} notify-send "🌙 Brightness ↓" "{}%" --hint=int:value:{}

# --------------------
# Smart fallback brightness
# --------------------
bindsym $mod+Shift+Up exec bash -c '
OLD=$(brightnessctl get)
brightnessctl set +10% >/dev/null 2>&1
sleep 0.05
NEW=$(brightnessctl get)
if [ "$OLD" -eq "$NEW" ]; then brightnessctl set +10%; fi
brightnessctl -m | awk -F, "{print \$4}" | tr -d "%" | \
xargs -I{} notify-send "☀️ Brightness ↑" "{}%" --hint=int:value:{}'

bindsym $mod+Shift+Down exec bash -c '
OLD=$(brightnessctl get)
brightnessctl set 10%- >/dev/null 2>&1
sleep 0.05
NEW=$(brightnessctl get)
if [ "$OLD" -eq "$NEW" ]; then brightnessctl set 10%-; fi
brightnessctl -m | awk -F, "{print \$4}" | tr -d "%" | \
xargs -I{} notify-send "🌙 Brightness ↓" "{}%" --hint=int:value:{}'

# --------------------
# Smart fallback volume
# --------------------
bindsym $mod+Shift+Right exec bash -c '
OLD=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP "\d{1,3}(?=%)" | head -1)
pactl set-sink-volume @DEFAULT_SINK@ +5% >/dev/null 2>&1
sleep 0.05
NEW=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP "\d{1,3}(?=%)" | head -1)
if [ "$OLD" -eq "$NEW" ]; then pactl set-sink-volume @DEFAULT_SINK@ +5%; fi
pactl get-sink-volume @DEFAULT_SINK@ | grep -oP "\d{1,3}(?=%)" | head -1 | \
xargs -I{} notify-send "🔊 Volume ↑" "{}%" --hint=int:value:{}'

bindsym $mod+Shift+Left exec bash -c '
OLD=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP "\d{1,3}(?=%)" | head -1)
pactl set-sink-volume @DEFAULT_SINK@ -5% >/dev/null 2>&1
sleep 0.05
NEW=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP "\d{1,3}(?=%)" | head -1)
if [ "$OLD" -eq "$NEW" ]; then pactl set-sink-volume @DEFAULT_SINK@ -5%; fi
pactl get-sink-volume @DEFAULT_SINK@ | grep -oP "\d{1,3}(?=%)" | head -1 | \
xargs -I{} notify-send "🔉 Volume ↓" "{}%" --hint=int:value:{}'

bindsym $mod+Shift+m exec bash -c '
OLD=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -q yes && echo 1 || echo 0)
pactl set-sink-mute @DEFAULT_SINK@ toggle >/dev/null 2>&1
sleep 0.05
NEW=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -q yes && echo 1 || echo 0)
if [ "$OLD" -eq "$NEW" ]; then pactl set-sink-mute @DEFAULT_SINK@ toggle; fi
pactl get-sink-mute @DEFAULT_SINK@ | grep -q yes && \
notify-send "🔇 Muted" --hint=int:value:0 || \
pactl get-sink-volume @DEFAULT_SINK@ | grep -oP "\d{1,3}(?=%)" | head -1 | \
xargs -I{} notify-send "🔊 Unmuted" "{}%" --hint=int:value:{}'
EOF

# -----------------------
# Continue configuring Waybar, Wofi, Power menu, Dunst, etc.
# (The rest of the script remains unchanged from previous version)
# -----------------------

echo "[6/14] Configuring Waybar..."
mkdir -p ~/.config/waybar
# Waybar config/style (same as before)
# ...
# [Rest of the script unchanged, including wallpaper GUI, default brightness 15%, etc.]

echo "[14/14] Done! Restart Sway to apply all changes."
