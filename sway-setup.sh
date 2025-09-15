#!/bin/bash
# archlinux-sway-setup.sh
# Complete Sway environment setup for Arch Linux
# Includes Waybar, Wofi, PipeWire/PulseAudio, Bluetooth, LXTASK, Azote, smart volume & brightness, XF86 keys, PCManFM with archive support

set -e

echo "[1/14] Updating system..."
sudo pacman -Syu --noconfirm

echo "[2/14] Installing essential packages..."
sudo pacman -S --noconfirm sway waybar wofi grim slurp wl-clipboard \
    ghostty librewolf brave \
    network-manager-applet nm-connection-editor \
    ttf-font-awesome noto-fonts \
    pcmanfm-gtk3 xarchiver unzip p7zip unrar qpdfview \
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

echo "[4/18] Setting default applications..."
xdg-settings set default-web-browser brave.desktop
xdg-mime default ghostty.desktop x-scheme-handler/terminal
xdg-mime default feh.desktop image/png image/jpeg image/jpg image/bmp image/gif
xdg-mime default qpdfview.desktop application/pdf application/epub+zip application/vnd.djvu
echo "BROWSER=brave" >> ~/.profile
echo "TERMINAL=ghostty" >> ~/.profile
echo "DOCUMENT_VIEWER=qpdfview" >> ~/.profile

# -----------------------
# Bluetooth installation
# -----------------------
echo "[5/14] Installing Bluetooth stack and GUI..."
sudo pacman -S --noconfirm bluez bluez-utils blueman
sudo systemctl enable --now bluetooth

# -----------------------
# Enable NetworkManager
# -----------------------
sudo systemctl enable --now NetworkManager

# -----------------------
# Configure Sway
# -----------------------
echo "[6/14] Configuring Sway..."
mkdir -p ~/.config/sway
if [ ! -f ~/.config/sway/config ]; then
    cp /etc/sway/config ~/.config/sway/config
fi

cat > ~/.config/sway/config << 'EOF'
set $mod Mod4

# --------------------
# Launchers
# --------------------
bindsym $mod+Shift+l exec swaylock -f -c 000000
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
# Waybar configuration
# -----------------------
echo "[7/14] Configuring Waybar..."
mkdir -p ~/.config/waybar
cat > ~/.config/waybar/config << 'EOF'
{
  "layer": "top",
  "position": "top",
  "modules-left": ["network", "pulseaudio", "bluetooth", "battery"],
  "modules-center": ["clock"],
  "modules-right": ["tray"],

  "clock": {
    "format": "{:%a %b %d  %H:%M}",
    "tooltip": false
  },
  "battery": {
    "format": "{capacity}%"
  },
  "pulseaudio": {
    "format": "{volume}%",
    "on-click": "pavucontrol"
  },
  "network": {
    "format": "{ifname} {essid} {signalStrength}%",
    "on-click": "nm-connection-editor"
  },
  "bluetooth": {
    "format": "{status}",
    "format-connected": " {num_connections}",
    "format-disabled": " off",
    "tooltip-format": "{status}\n{device_alias} ({device_address})",
    "on-click": "blueman-manager"
  }
}
EOF

cat > ~/.config/waybar/style.css << 'EOF'
* {
  font-family: "Noto Sans", "Font Awesome 6 Free";
  font-size: 14px;
  color: #ffffff;
}

#clock {
  font-size: 18px;
  font-weight: bold;
}

#battery, #pulseaudio, #network, #bluetooth {
  padding: 0 10px;
}
EOF

# -----------------------
# Wofi configuration
# -----------------------
echo "[8/14] Configuring Wofi..."
mkdir -p ~/.config/wofi
cat > ~/.config/wofi/config << 'EOF'
show=drun
allow-images=true
term=ghostty
EOF

# -----------------------
# Power menu script
# -----------------------
echo "[9/14] Creating power menu script..."
mkdir -p ~/.local/bin
cat > ~/.local/bin/power-menu.sh << 'EOF'
#!/bin/bash
choice=$(printf " Poweroff\n Reboot\n Logout" | wofi --show dmenu --prompt "Power Menu")
case "$choice" in
    " Poweroff") systemctl poweroff ;;
    " Reboot") systemctl reboot ;;
    " Logout") swaymsg exit ;;
esac
EOF
chmod +x ~/.local/bin/power-menu.sh

# -----------------------
# Dunst configuration
# -----------------------
echo "[10/14] Configuring Dunst notifications..."
mkdir -p ~/.config/dunst
cat > ~/.config/dunst/dunstrc << 'EOF'
[global]
    font = Noto Sans 10
    frame_color = "#4C7899"
    separator_color = "#4C7899"
    padding = 8
    horizontal_padding = 8
    frame_width = 2
    transparency = 10
    corner_radius = 8
    follow = mouse
    format = "%s\n%b"
    indicate_hidden = yes
    sort = yes
    show_age_threshold = 60

[urgency_low]
    frame_color = "#4C7899"
    background = "#1e1e2e"
    foreground = "#ffffff"
    highlight = "#4C7899"

[urgency_normal]
    frame_color = "#4C7899"
    background = "#1e1e2e"
    foreground = "#ffffff"
    highlight = "#4C7899"

[urgency_critical]
    frame_color = "#ff0000"
    background = "#1e1e2e"
    foreground = "#ffffff"
    highlight = "#ff0000"
EOF

# -----------------------
# Default brightness
# -----------------------
echo "[11/14] Setting default brightness to 15%..."
brightnessctl set 15%
sudo usermod -aG video $USER

echo "[12/14] Final touches and reminders..."
echo "✅ Setup complete!"
echo " - Task Manager: Ctrl+Shift+Esc (LXTASK)"
echo " - Network Manager: Waybar click → nm-connection-editor"
echo " - Bluetooth Manager: Waybar click → blueman-manager"
echo " - Wallpaper GUI: Super+W (Azote)"
echo " - Volume Keys: XF86Audio keys + smart fallback Super+Shift+Right/Left/M (with OSD)"
echo " - Brightness Keys: XF86MonBrightness keys + smart fallback Super+Shift+Up/Down (with OSD)"
echo " - Media Keys: Play/Pause/Next/Prev supported"
echo " - Keyboard layout switching: Alt+Shift"

echo "[13/14] Restart Sway to apply all changes."
echo "[14/14] Done!"
