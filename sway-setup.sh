#!/bin/bash
# archlinux-sway-setup.sh
# Complete Sway environment setup for Arch Linux
# Includes Waybar, Wofi, PipeWire/PulseAudio, Bluetooth, LXTASK, Azote, smart volume & brightness, XF86 keys, PCManFM with archive support

set -e

echo "[1/14] Updating system..."
sudo pacman -Syu --noconfirm

echo "[2/14] Installing essential packages..."
sudo pacman -S --noconfirm sway swaylock waybar wofi grim slurp wl-clipboard \
    ghostty librewolf brave \
    network-manager-applet nm-connection-editor \
    ttf-font-awesome noto-fonts papirus-icon-theme \
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

mkdir -p ~/.local/share/applications

# Brave Browser .desktop (fallback)
if [[ ! -f ~/.local/share/applications/brave-browser.desktop ]]; then
cat > ~/.local/share/applications/brave-browser.desktop <<'EOF'
[Desktop Entry]
Name=Brave Browser
Exec=brave %U
Terminal=false
Icon=brave-browser
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/about;x-scheme-handler/unknown;
EOF
fi

if [[ ! -f ~/.local/share/applications/ghostty.desktop ]]; then
cat > ~/.local/share/applications/ghostty.desktop <<'EOF'
[Desktop Entry]
Name=Ghostty
Exec=ghostty
Icon=utilities-terminal
Type=Application
Categories=System;TerminalEmulator;
Terminal=false
EOF
fi

if [[ ! -f ~/.local/share/applications/feh.desktop ]]; then
cat > ~/.local/share/applications/feh.desktop <<'EOF'
[Desktop Entry]
Name=Feh
Comment=Lightweight image viewer
Exec=feh %f
Icon=image-viewer
Terminal=false
Type=Application
Categories=Graphics;Viewer;
MimeType=image/jpeg;image/png;image/gif;image/bmp;image/webp;image/svg+xml;
EOF
fi

if [[ ! -f ~/.local/share/applications/qpdfview.desktop ]]; then
cat > ~/.local/share/applications/qpdfview.desktop <<'EOF'
[Desktop Entry]
Name=qpdfview
Comment=Tabbed PDF viewer
Exec=qpdfview %f
Icon=qpdfview
Terminal=false
Type=Application
Categories=Office;Viewer;
MimeType=application/pdf;application/x-pdf;image/pdf;
EOF
fi

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
# Floating / tiling mode toggle + resize mode
# --------------------
bindsym $mod+Shift+Space floating toggle
mode "resize" {
    bindsym Left resize shrink width 10 px or 10 ppt
    bindsym Down resize grow height 10 px or 10 ppt
    bindsym Up resize shrink height 10 px or 10 ppt
    bindsym Right resize grow width 10 px or 10 ppt
    bindsym Return mode "default"
    bindsym Escape mode "default"
}
bindsym $mod+r mode "resize"

# --------------------
# Workspace switching
# --------------------
# Switch workspace
bindsym $mod+1 workspace 1
bindsym $mod+2 workspace 2
bindsym $mod+3 workspace 3
bindsym $mod+4 workspace 4
bindsym $mod+5 workspace 5
bindsym $mod+6 workspace 6
bindsym $mod+7 workspace 7
bindsym $mod+8 workspace 8
bindsym $mod+9 workspace 9
bindsym $mod+0 workspace 10

# Move window to workspace
bindsym $mod+Shift+1 move container to workspace 1
bindsym $mod+Shift+2 move container to workspace 2
bindsym $mod+Shift+3 move container to workspace 3
bindsym $mod+Shift+4 move container to workspace 4
bindsym $mod+Shift+5 move container to workspace 5
bindsym $mod+Shift+6 move container to workspace 6
bindsym $mod+Shift+7 move container to workspace 7
bindsym $mod+Shift+8 move container to workspace 8
bindsym $mod+Shift+9 move container to workspace 9
bindsym $mod+Shift+0 move container to workspace 10

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
bindsym $mod+d exec wofi --show drun
bindsym $mod+Shift+q exec ~/.local/bin/power-menu.sh

# --------------------
# Autostart
# --------------------
exec_always waybar
exec_always dunst

# --------------------
# Volume control (single OSD)
# --------------------
bindsym XF86AudioRaiseVolume exec sh -c 'SINK=@DEFAULT_SINK@; pactl set-sink-volume $SINK +5%; V=$(pactl get-sink-volume $SINK | grep -oP "\d{1,3}(?=%)" | head -1); dunstify -r 2593 -u normal "🔊 Volume" "$V%" -h int:value:$V'
bindsym XF86AudioLowerVolume exec sh -c 'SINK=@DEFAULT_SINK@; pactl set-sink-volume $SINK -5%; V=$(pactl get-sink-volume $SINK | grep -oP "\d{1,3}(?=%)" | head -1); dunstify -r 2593 -u normal "🔊 Volume" "$V%" -h int:value:$V'
bindsym XF86AudioMute exec sh -c 'SINK=@DEFAULT_SINK@; pactl set-sink-mute $SINK toggle; M=$(pactl get-sink-mute $SINK | grep -q yes && echo "🔇 Muted" || echo "🔊 Unmuted"); V=$(pactl get-sink-volume $SINK | grep -oP "\d{1,3}(?=%)" | head -1); dunstify -r 2593 -u normal "$M" "$V%" -h int:value:$V'

# Optional fallback keys
bindsym $mod+Shift+Right exec sh -c 'SINK=@DEFAULT_SINK@; pactl set-sink-volume $SINK +5%; V=$(pactl get-sink-volume $SINK | grep -oP "\d{1,3}(?=%)" | head -1); dunstify -r 2593 -u normal "🔊 Volume" "$V%" -h int:value:$V'
bindsym $mod+Shift+Left  exec sh -c 'SINK=@DEFAULT_SINK@; pactl set-sink-volume $SINK -5%; V=$(pactl get-sink-volume $SINK | grep -oP "\d{1,3}(?=%)" | head -1); dunstify -r 2593 -u normal "🔊 Volume" "$V%" -h int:value:$V'
bindsym $mod+Shift+m     exec sh -c 'SINK=@DEFAULT_SINK@; pactl set-sink-mute $SINK toggle; M=$(pactl get-sink-mute $SINK | grep -q yes && echo "🔇 Muted" || echo "🔊 Unmuted"); V=$(pactl get-sink-volume $SINK | grep -oP "\d{1,3}(?=%)" | head -1); dunstify -r 2593 -u normal "$M" "$V%" -h int:value:$V'

# --------------------
# Brightness control (single OSD)
# --------------------
bindsym XF86MonBrightnessUp exec sh -c 'brightnessctl set +5% >/dev/null 2>&1; V=$(brightnessctl -m | awk -F, "{print \$4}" | tr -d "%"); dunstify -r 2594 -u normal "☀️ Brightness" "$V%" -h int:value:$V'
bindsym XF86MonBrightnessDown exec sh -c 'brightnessctl set -5%- >/dev/null 2>&1; V=$(brightnessctl -m | awk -F, "{print \$4}" | tr -d "%"); dunstify -r 2594 -u normal "🌙 Brightness" "$V%" -h int:value:$V'

# Fallback Brightness keys
bindsym $mod+Shift+Up exec sh -c 'brightnessctl set +10% >/dev/null 2>&1; V=$(brightnessctl -m | awk -F, "{print \$4}" | tr -d "%"); dunstify -r 2594 -u normal "☀️ Brightness" "$V%" -h int:value:$V'
bindsym $mod+Shift+Down exec sh -c 'brightnessctl set 10%- >/dev/null 2>&1; V=$(brightnessctl -m | awk -F, "{print \$4}" | tr -d "%"); dunstify -r 2594 -u normal "🌙 Brightness" "$V%" -h int:value:$V'

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
[wofi]
show=drun
allow-images=true
icon-theme=Papirus
term=ghostty

[style]
window-border-width=1
window-border-color=#1e1e2e
window-background=#1e1e2e
window-radius=8
list-background=#1e1e2e
list-text-color=#ffffff
list-hover-background=#3a5f9e
list-hover-text-color=#ffffff
font=Noto Sans 10
padding=6
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
