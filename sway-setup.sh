#!/bin/bash
# archlinux-sway-setup.sh
# Complete Sway environment setup for Arch Linux
# Includes Waybar, Wofi, PipeWire/PulseAudio, Bluetooth, LXTASK, Azote, smart volume & brightness, XF86 keys, PCManFM with archive support

set -e

echo "[1/15] Updating system..."
sudo pacman -Syu --noconfirm

echo "[2/15] Installing essential packages..."
sudo pacman -S --noconfirm sway swaylock swaylock-effects swayidle waybar wofi grim slurp wl-clipboard xorg-xwayland \
    xorg-xhost ghostty librewolf brave \
    network-manager-applet nm-connection-editor \
    ttf-font-awesome noto-fonts papirus-icon-theme \
    pcmanfm-gtk3 xarchiver unzip p7zip unrar qpdfview \
    playerctl dunst libnotify inotify-tools brightnessctl polkit-gnome \
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
    echo "[3/15] Installing PulseAudio..."
    sudo pacman -S --noconfirm pulseaudio pavucontrol
    echo "PulseAudio selected."
else
    echo "[3/15] Installing PipeWire (default)..."
    sudo pacman -S --noconfirm pipewire pipewire-pulse wireplumber pavucontrol
    echo "PipeWire selected."
fi

echo "[4/15] Setting default applications..."

# ensure dirs exist
mkdir -p ~/.local/share/applications
mkdir -p ~/.config

# install xdg-utils if missing (non-blocking)
if ! command -v xdg-mime >/dev/null 2>&1; then
  echo "Installing xdg-utils..."
  sudo pacman -S --noconfirm xdg-utils || true
fi

# Create fallback .desktop files (only if missing)

# Brave desktop (brave-bin typical desktop name is brave-browser.desktop)
if [[ ! -f ~/.local/share/applications/brave-browser.desktop ]]; then
cat > ~/.local/share/applications/brave-browser.desktop <<'EOF'
[Desktop Entry]
Name=Brave Browser
Exec=brave %U
Terminal=false
Icon=brave-browser
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
EOF
fi

# Ghostty desktop
if [[ ! -f ~/.local/share/applications/ghostty.desktop ]]; then
cat > ~/.local/share/applications/ghostty.desktop <<'EOF'
[Desktop Entry]
Name=Ghostty
Comment=Fast modern terminal
Exec=ghostty
Icon=utilities-terminal
Terminal=false
Type=Application
Categories=System;TerminalEmulator;
EOF
fi

# Feh desktop
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

# qpdfview desktop
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

# Update desktop database (user-level) if tool exists; don't fail script on error
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database ~/.local/share/applications || true
fi

# Build (or replace) user-level mimeapps list (freedesktop standard)
MIMEFILE="$HOME/.config/mimeapps.list"
cat > "$MIMEFILE" <<'EOF'
[Default Applications]
text/html=brave-browser.desktop
x-scheme-handler/http=brave-browser.desktop
x-scheme-handler/https=brave-browser.desktop
application/pdf=qpdfview.desktop
image/png=feh.desktop
image/jpeg=feh.desktop
image/jpg=feh.desktop
image/gif=feh.desktop
image/bmp=feh.desktop
image/webp=feh.desktop
image/svg+xml=feh.desktop
x-scheme-handler/terminal=ghostty.desktop
EOF

# Also set via xdg-mime as a fallback (safe — won't block)
xdg-mime default qpdfview.desktop application/pdf || true
xdg-mime default feh.desktop image/png image/jpeg image/jpg image/bmp image/gif || true
xdg-mime default ghostty.desktop x-scheme-handler/terminal || true

# Export env vars once (avoid duplicates)
grep -qxF 'export BROWSER=brave' ~/.profile 2>/dev/null || echo 'export BROWSER=brave' >> ~/.profile
grep -qxF 'export TERMINAL=ghostty' ~/.profile 2>/dev/null || echo 'export TERMINAL=ghostty' >> ~/.profile
grep -qxF 'export DOCUMENT_VIEWER=qpdfview' ~/.profile 2>/dev/null || echo 'export DOCUMENT_VIEWER=qpdfview' >> ~/.profile

echo "Default applications set (user mimeapps.list written to $MIMEFILE)."

# -----------------------
# Bluetooth installation
# -----------------------
echo "[5/15] Installing Bluetooth stack and GUI..."
sudo pacman -S --noconfirm bluez bluez-utils blueman
sudo systemctl enable bluetooth
sudo systemctl start bluetooth

# -----------------------
# Enable NetworkManager
# -----------------------
sudo systemctl enable --now NetworkManager

# -----------------------
# Waybar configuration
# -----------------------
echo "[6/15] Configuring Waybar..."

mkdir -p ~/.config/waybar

cat > ~/.config/waybar/config <<'EOF'
{
  "layer": "top",
  "position": "top",
  "modules-left": ["sway/workspaces"],
  "modules-center": ["clock"],
  "modules-right": ["network", "battery", "bluetooth", "pulseaudio", "sway/language", "tray"],

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
  },
  "sway/language": {
	"format": "{short} {variant}",
  },
  "tray": {
    "icon-size": 12,
    "spacing": 10
  },
  "sway/workspaces": {
    "format": "{name}: {icon}",
    "format-icons": {
      "urgent": "\uf06a",
      "focused": "\u25cf",
      "default": "\u25CB"
    }
  }
}
EOF

if [[ ! -f ~/.config/waybar/style.css ]]; then
cat > ~/.config/waybar/style.css <<'EOF'
* {
  font-family: "Font Awesome 6 Free", "JetBrainsMono Nerd Font", "Noto Sans";
  font-size: 15px;
  color: #ffffff;
  background-color: #000000;
}

#clock {
  font-size: 18px;
  font-weight: bold;
}

#battery, #pulseaudio, #network, #bluetooth {
  padding: 0 10px;
}
EOF
fi

# -----------------------
# Configure Sway
# -----------------------
echo "[7/15] Configuring Sway..."
mkdir -p ~/.config/sway
if [ ! -f ~/.config/sway/config ]; then
    cp /etc/sway/config ~/.config/sway/config
fi

# ------------------
# Screen Locking
# ------------------

mkdir -p ~/.local/bin
cat > ~/.local/bin/lock.sh <<'EOF'
#!/bin/bash

# Launch swayidle to handle auto-lock & screen off
swayidle -w \
    timeout 300 'swaylock-effects \
      --indicator \
      --indicator-radius 120 \
      --indicator-thickness 15 \
      --inside-color 1e1e2eff \
      --ring-color 4c7899ff \
      --key-hl-color 990000ff \
      --bs-hl-color ff0000ff \
      --text-color ffffffff \
      --line-color 00000000 \
      --separator-color 00000000 \
      --inside-ver-color 285577ff \
      --ring-ver-color 4c7899ff \
      --inside-wrong-color ff0000ff \
      --ring-wrong-color ff0000ff \
      --grace 2 \
      --fade-in 0.3' \
    timeout 600 'swaymsg "output * dpms off"' \
    resume 'swaymsg "output * dpms on"' \
    before-sleep 'swaylock-effects \
      --indicator \
      --indicator-radius 120 \
      --indicator-thickness 15 \
      --inside-color 1e1e2eff \
      --ring-color 4c7899ff \
      --key-hl-color 990000ff \
      --bs-hl-color ff0000ff \
      --text-color ffffffff \
      --line-color 00000000 \
      --separator-color 00000000 \
      --inside-ver-color 285577ff \
      --ring-ver-color 4c7899ff \
      --inside-wrong-color ff0000ff \
      --ring-wrong-color ff0000ff \
      --grace 2 \
      --fade-in 0.3'
EOF
chmod +x ~/.local/bin/lock.sh

cat > ~/.config/sway/config <<'EOF'
set $mod Mod4

# For password prompts
exec /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# --------------------
# Launchers
# --------------------
bindsym $mod+Shift+l exec swaylock -f -c 000000
bindsym $mod+t exec pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY timeshift-gtk  
bindsym $mod+b exec brave
bindsym $mod+l exec librewolf
bindsym $mod+Return exec ghostty
bindsym $mod+e exec pcmanfm
bindsym $mod+Shift+s exec sh -c 'mkdir -p "$HOME/Pictures/Screenshots"; grim -g "$(slurp)" "$(zenity --file-selection --save --confirm-overwrite --filename=$HOME/Pictures/Screenshots/screenshot-$(date +%Y-%m-%d_%H-%M-%S).png")"'
bindsym $mod+w exec azote
bindsym Control+Shift+Escape exec lxtask

# --------------------
# Window management
# --------------------
bindsym $mod+f fullscreen toggle
bindsym $mod+q kill
bindsym $mod+v split vertical  # To make the next window tile vertically
bindsym $mod+h split horizontal  # To make the next window tile horizontally

# To move windows with superkey + left-click
floating_modifier $mod

# Move window with Super + Left Mouse Drag
bindsym --whole-window $mod+button2 move

# Optionally: Resize window with Super + Right Mouse Drag
bindsym --whole-window $mod+button3 resize

# Move windows with Super + Arrow Keys
bindsym $mod+Left move left 100px
bindsym $mod+Right move right 100px
bindsym $mod+Up move up 100px
bindsym $mod+Down move down 100px   

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
bindsym $mod+d exec wofi --show drun --show-icons --keynav
bindsym $mod+Shift+q exec ~/.local/bin/power-menu.sh

# --------------------
# Autostart
# --------------------
exec waybar
exec dunst

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
bindsym XF86MonBrightnessDown exec sh -c 'brightnessctl set 5%- >/dev/null 2>&1; V=$(brightnessctl -m | awk -F, "{print \$4}" | tr -d "%"); dunstify -r 2594 -u normal "🌙 Brightness" "$V%" -h int:value:$V'

# Fallback Brightness keys
bindsym $mod+Shift+Up exec sh -c 'brightnessctl set +10% >/dev/null 2>&1; V=$(brightnessctl -m | awk -F, "{print \$4}" | tr -d "%"); dunstify -r 2594 -u normal "☀️ Brightness" "$V%" -h int:value:$V'
bindsym $mod+Shift+Down exec sh -c 'brightnessctl set 10%- >/dev/null 2>&1; V=$(brightnessctl -m | awk -F, "{print \$4}" | tr -d "%"); dunstify -r 2594 -u normal "🌙 Brightness" "$V%" -h int:value:$V'
EOF

# -----------------------
# Wofi configuration
# -----------------------
echo "[8/15] Configuring Wofi..."

# Setting Papirus icon theme as default
mkdir -p ~/.config/gtk-3.0
if [[ ! -f ~/.config/gtk-3.0/settings.ini ]]; then
    # File does not exist → create it with header and key
    cat > ~/.config/gtk-3.0/settings.ini <<'EOF'
[Settings]
gtk-icon-theme-name=Papirus-Dark
gtk-application-prefer-dark-theme=1
EOF
else
    # File exists → ensure it has [Settings], then add key if missing
    if ! grep -q "^\[Settings\]" ~/.config/gtk-3.0/settings.ini; then
        sed -i '1i [Settings]' ~/.config/gtk-3.0/settings.ini
    fi

    grep -qxF "gtk-icon-theme-name=Papirus-Dark" ~/.config/gtk-3.0/settings.ini 2>/dev/null || \
    echo "gtk-icon-theme-name=Papirus-Dark" >> ~/.config/gtk-3.0/settings.ini
fi

mkdir -p ~/.config/wofi
# Main config (functional options)
cat > ~/.config/wofi/config <<'EOF'
[wofi]
show=drun
allow-images=true
icon-theme=Papirus-Dark
term=ghostty
EOF

# Style (GTK CSS selectors)
#touch ~/.config/wofi/style.css
cat > ~/.config/wofi/style.css <<'EOF'
window {
  border: 1px solid #1e1e2e;
  background-color: #1e1e2e;
  border-radius: 8px;
}

#input {
  border: none;
  padding: 6px;
  margin: 6px;
  background-color: #1e1e2e;
  color: #ffffff;
  font-family: "Noto Sans";
  font-size: 15px;
}

#entry {
  padding: 6px;
  background-color: #1e1e2e;
  color: #ffffff;
}

#entry:selected {
  background-color: #3a5f9e;
  color: #ffffff;
}

#img {
  padding-right: 8px;
}

#text {
  color: #ffffff;
}
EOF

# -----------------------
# Power menu script
# -----------------------
echo "[9/15] Creating power menu script..."
cat > ~/.local/bin/power-menu.sh <<'EOF'
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
echo "[10/15] Configuring Dunst notifications..."
mkdir -p ~/.config/dunst
cat > ~/.config/dunst/dunstrc <<'EOF'
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
echo "[11/15] Setting default brightness to 15%..."
brightnessctl set 15%
sudo usermod -aG video $USER

echo "[12/15] Creating Timeshift GUI wrapper..."
# 1. Create the wrapper script
cat > ~/.local/bin/timeshift-gui.sh <<'EOF'
#!/bin/bash
# Wrapper for Timeshift GUI under Sway/Wayland

# Preserve environment for GUI apps
export DISPLAY=:0
export XAUTHORITY=$HOME/.Xauthority
export WAYLAND_DISPLAY=wayland-0
export DBUS_SESSION_BUS_ADDRESS=unix:path=$XDG_RUNTIME_DIR/bus

sudo -E timeshift-gtk
EOF
chmod +x ~/.local/bin/timeshift-gui.sh

# 2. Create the user-level .desktop file for Wofi and menus
mkdir -p ~/.local/share/applications
if [[ ! -f ~/.local/share/applications/timeshift-gui.desktop ]]; then
cat > ~/.local/share/applications/timeshift-gui.desktop <<'EOF'
[Desktop Entry]
Name=Timeshift GUI
Comment=Open Timeshift snapshot manager
Exec=/home/$USER/.local/bin/timeshift-gui.sh
Terminal=false
Icon=timeshift
Type=Application
Categories=System;Utility;
EOF
fi

echo "✅ Timeshift GUI ready: appears in Wofi, old Timeshift hidden."


echo "[13/15] Final touches and reminders..."
echo "✅ Setup complete!"
echo " - Task Manager: Ctrl+Shift+Esc (LXTASK)"
echo " - Network Manager: Waybar click → nm-connection-editor"
echo " - Bluetooth Manager: Waybar click → blueman-manager"
echo " - Wallpaper GUI: Super+W (Azote)"
echo " - Volume Keys: XF86Audio keys + smart fallback Super+Shift+Right/Left/M (with OSD)"
echo " - Brightness Keys: XF86MonBrightness keys + smart fallback Super+Shift+Up/Down (with OSD)"
echo " - Media Keys: Play/Pause/Next/Prev supported"
echo " - Keyboard layout switching: Alt+Shift"

echo "[14/15] Restart Sway to apply all changes."
echo "[15/15] Done!"
