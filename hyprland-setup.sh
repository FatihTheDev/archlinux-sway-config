#!/bin/bash
# hyprland-setup.sh
# Complete Hyprland environment setup for Arch Linux
# Includes Waybar, Wofi, PipeWire/PulseAudio, Bluetooth, LXTASK, Azote, smart volume & brightness, XF86 keys, Thunar with archive support

set -e

echo "[1/15] Updating system..."
sudo pacman -Syu --noconfirm

echo "[2/15] Installing essential packages..."
sudo pacman -S --noconfirm hyprland swaybg hyprlock hypridle waybar wofi grim slurp wl-clipboard xorg-xwayland \
    xorg-xhost alacritty librewolf brave \
    network-manager-applet nm-connection-editor xdg-desktop-portal xdg-desktop-portal-wlr xdg-utils \
    ttf-font-awesome-4 noto-fonts papirus-icon-theme jq gnome-themes-extra adwaita-qt5-git adwaita-qt6-git qt5ct qt6ct \
    nwg-look nwg-clipman feh thunar thunar-archive-plugin thunar-volman gvfs engrampa zip unzip p7zip unrar qpdfview \
    playerctl dunst libnotify inotify-tools brightnessctl polkit-gnome \
    lxtask gammastep cliphist wl-clipboard gnome-font-viewer mousepad autotiling

yay -S sway-audio-idle-inhibit-git masterpdfeditor-free wayscriber-bin

mkdir -p ~/Desktop
mkdir -p ~/Code
mkdir -p ~/Documents
mkdir -p ~/Downloads
mkdir -p ~/Pictures
mkdir -p ~/Pictures/Screenshots
mkdir -p ~/Pictures/Wallpapers
mkdir -p ~/Videos

echo "[3/15] Starting xdg-desktop-portal and xdg-desktop-portal-wlr services (for screen sharing)"
systemctl --user enable pipewire pipewire-pulse wireplumber xdg-desktop-portal xdg-desktop-portal-wlr
systemctl --user daemon-reload

# -----------------------
# Audio system selection
# -----------------------
echo "Select audio system (default PipeWire):"
echo "1) PipeWire"
echo "2) PulseAudio"
read -p "Enter choice [1-2]: " audio_choice
audio_choice=${audio_choice:-1}

if [ "$audio_choice" -eq 2 ]; then
    echo "[4/15] Installing PulseAudio..."
    sudo pacman -S --noconfirm pulseaudio pavucontrol
    echo "PulseAudio selected."
else
    echo "[4/15] Installing PipeWire (default)..."
    sudo pacman -S --noconfirm pipewire pipewire-pulse wireplumber pavucontrol
    echo "PipeWire selected."
fi

echo "[5/15] Setting default applications..."

# ensure dirs exist
mkdir -p ~/.local/share/applications
mkdir -p ~/.config

# install xdg-utils if missing (non-blocking)
if ! command -v xdg-mime >/dev/null 2>&1; then
  echo "Installing xdg-utils..."
  sudo pacman -S --noconfirm xdg-utils || true
fi

# Create fallback .desktop files (only if missing)

# AUR Package Search (through Brave browser)
if [[ ! -f ~/.local/share/applications/brave-AUR_Package_Search.desktop ]]; then
cat > ~/.local/share/applications/brave-AUR_Package_Search.desktop <<'EOF'
#!/usr/bin/env xdg-open
[Desktop Entry]
Version=1.0
Type=Application
Name=AUR Package Search
Exec=/opt/brave-bin/brave --profile-directory=Default --ignore-profile-directory-if-not-exists "https://aur.archlinux.org/packages?O=0&K="
Icon=/home/fatihthedev/.config/BraveSoftware/Brave-Browser/Default/Web Shortcut Icons/shortcut-213742ec107d211ef56c945c6fec3608.png
URL=https://aur.archlinux.org/packages?O=0&K=
Comment=Open https://aur.archlinux.org/packages?O=0&K= in a new tab in Brave.
EOF
fi

# Chaotic AUR Package Search (through Brave browser)
if [[ ! -f ~/.local/share/applications/brave-Chaotic_AUR_Package_Search.desktop ]]; then
cat > ~/.local/share/applications/brave-Chaotic_AUR_Package_Search.desktop <<'EOF'
#!/usr/bin/env xdg-open
[Desktop Entry]
Version=1.0
Type=Application
Name=Chaotic AUR Package Search
Exec=/opt/brave-bin/brave --profile-directory=Default --ignore-profile-directory-if-not-exists https://aur.chaotic.cx/packages
Icon=/home/fatihthedev/.config/BraveSoftware/Brave-Browser/Default/Web Shortcut Icons/shortcut-83a060dc0cabe27c43c8189da18a8654.png
URL=https://aur.chaotic.cx/packages
Comment=Open https://aur.chaotic.cx/packages in a new tab in Brave.
EOF
fi

# Neovim
if [[ ! -f ~/.local/share/applications/nvim.desktop ]]; then
cat > ~/.local/share/applications/nvim.desktop <<'EOF'
[Desktop Entry]
Name=Neovim
GenericName=Text Editor
GenericName[ckb]=دەستکاریکەری دەق
GenericName[de]=Texteditor
GenericName[fr]=Éditeur de texte
GenericName[pl]=Edytor tekstu
GenericName[ru]=Текстовый редактор
GenericName[sr]=Едитор текст
GenericName[tr]=Metin Düzenleyici
Comment=Edit text files
Comment[af]=Redigeer tekslêers
Comment[am]=የጽሑፍ ፋይሎች ያስተካክሉ
Comment[ar]=حرّر ملفات نصية
Comment[az]=Mətn fayllarını redaktə edin
Comment[be]=Рэдагаваньне тэкставых файлаў
Comment[bg]=Редактиране на текстови файлове
Comment[bn]=টেক্স্ট ফাইল এডিট করুন
Comment[bs]=Izmijeni tekstualne datoteke
Comment[ca]=Edita fitxers de text
Comment[ckb]=دەستکاریی فایلی دەق بکە
Comment[cs]=Úprava textových souborů
Comment[cy]=Golygu ffeiliau testun
Comment[da]=Redigér tekstfiler
Comment[de]=Textdateien bearbeiten
Comment[el]=Επεξεργασία αρχείων κειμένου
Comment[en_CA]=Edit text files
Comment[en_GB]=Edit text files
Comment[es]=Edita archivos de texto
Comment[et]=Redigeeri tekstifaile
Comment[eu]=Editatu testu-fitxategiak
Comment[fa]=ویرایش پرونده‌های متنی
Comment[fi]=Muokkaa tekstitiedostoja
Comment[fr]=Éditer des fichiers texte
Comment[ga]=Eagar comhad Téacs
Comment[gu]=લખાણ ફાઇલોમાં ફેરફાર કરો
Comment[he]=ערוך קבצי טקסט
Comment[hi]=पाठ फ़ाइलें संपादित करें
Comment[hr]=Uređivanje tekstualne datoteke
Comment[hu]=Szövegfájlok szerkesztése
Comment[id]=Edit file teks
Comment[it]=Modifica file di testo
Comment[ja]=テキストファイルを編集します
Comment[kn]=ಪಠ್ಯ ಕಡತಗಳನ್ನು ಸಂಪಾದಿಸು
Comment[ko]=텍스트 파일을 편집합니다
Comment[lt]=Redaguoti tekstines bylas
Comment[lv]=Rediģēt teksta failus
Comment[mk]=Уреди текстуални фајлови
Comment[ml]=വാചക രചനകള് തിരുത്തുക
Comment[mn]=Текст файл боловсруулах
Comment[mr]=गद्य फाइल संपादित करा
Comment[ms]=Edit fail teks
Comment[nb]=Rediger tekstfiler
Comment[ne]=पाठ फाइललाई संशोधन गर्नुहोस्
Comment[nl]=Tekstbestanden bewerken
Comment[nn]=Rediger tekstfiler
Comment[no]=Rediger tekstfiler
Comment[or]=ପାଠ୍ଯ ଫାଇଲଗୁଡ଼ିକୁ ସମ୍ପାଦନ କରନ୍ତୁ
Comment[pa]=ਪਾਠ ਫਾਇਲਾਂ ਸੰਪਾਦਨ
Comment[pl]=Edytor plików tekstowych
Comment[pt]=Editar ficheiros de texto
Comment[pt_BR]=Edite arquivos de texto
Comment[ro]=Editare fişiere text
Comment[ru]=Редактирование текстовых файлов
Comment[sk]=Úprava textových súborov
Comment[sl]=Urejanje datotek z besedili
Comment[sq]=Përpuno files teksti
Comment[sr]=Уређујте текст фајлове
Comment[sr@Latn]=Izmeni tekstualne datoteke
Comment[sv]=Redigera textfiler
Comment[ta]=உரை கோப்புகளை தொகுக்கவும்
Comment[th]=แก้ไขแฟ้มข้อความ
Comment[tk]=Metin faýllary editle
Comment[tr]=Metin dosyaları düzenleyin
Comment[uk]=Редактор текстових файлів
Comment[vi]=Soạn thảo tập tin văn bản
Comment[wa]=Asspougnî des fitchîs tecses
Comment[zh_CN]=编辑文本文件
Comment[zh_TW]=編輯文字檔
TryExec=nvim
Exec=alacritty -e nvim %F
Terminal=false
Type=Application
Keywords=Text;editor;
Keywords[ckb]=دەق;دەستکاریکەر;
Keywords[fr]=Texte;éditeur;
Keywords[ru]=текст;текстовый редактор;
Keywords[sr]=Текст;едитор;
Keywords[tr]=Metin;düzenleyici;
Icon=nvim
Categories=Utility;TextEditor;
StartupNotify=false
MimeType=text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;
EOF
fi

# Feh desktop
if [[ ! -f ~/.local/share/applications/feh.desktop ]]; then
cat > ~/.local/share/applications/feh.desktop <<'EOF'
[Desktop Entry]
Name=Feh
Comment=Lightweight image viewer
Exec=feh --edit %f
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
text/plain=org.xfce.mousepad.desktop
text/x-markdown=nvim.desktop
application/x-shellscript=nvim.desktop
text/html=brave-browser.desktop
x-scheme-handler/http=brave-browser.desktop
x-scheme-handler/https=brave-browser.desktop
application/pdf=masterpdfeditor4.desktop
image/png=feh.desktop
image/jpeg=feh.desktop
image/jpg=feh.desktop
image/gif=feh.desktop
image/bmp=feh.desktop
image/webp=feh.desktop
image/svg+xml=brave-browser.desktop
x-scheme-handler/terminal=Alacritty.desktop
application/xhtml+xml=brave-browser.desktop
text/xml=brave-browser.desktop
application/rss+xml=brave-browser.desktop
application/atom+xml=brave-browser.desktop
text/x-c=nvim.desktop
text/x-c++=nvim.desktop
text/x-python=nvim.desktop
text/x-java=nvim.desktop
text/x-shellscript=nvim.desktop
text/x-javascript=nvim.desktop
text/css=nvim.desktop
text/x-typescript=nvim.desktop
text/markdown=nvim.desktop
EOF

# Also set via xdg-mime as a fallback (make browser open files for viewing and neovim for editing)

# Images → feh
xdg-mime default feh.desktop image/png image/jpeg image/jpg image/bmp image/gif || true

# Default file manager -> Thunar
xdg-mime default thunar.desktop inode/directory

# Browser stuff → Brave
xdg-mime default brave-browser.desktop text/html || true
xdg-mime default brave-browser.desktop application/xhtml+xml || true
xdg-mime default brave-browser.desktop image/svg+xml || true
xdg-mime default brave-browser.desktop text/xml || true
xdg-mime default brave-browser.desktop application/rss+xml || true
xdg-mime default brave-browser.desktop application/atom+xml || true

# Pdf editor and viewer
xdg-mime default masterpdfeditor4.desktop application/pdf || true

# Terminal handler
xdg-mime default Alacritty.desktop x-scheme-handler/terminal || true

# Code → Neovim
xdg-mime default nvim.desktop text/x-c || true
xdg-mime default nvim.desktop text/x-c++ || true
xdg-mime default nvim.desktop text/x-python || true
xdg-mime default nvim.desktop text/x-java || true
xdg-mime default nvim.desktop text/x-shellscript || true
xdg-mime default nvim.desktop text/x-javascript || true
xdg-mime default nvim.desktop text/css || true
xdg-mime default nvim.desktop text/x-typescript || true
xdg-mime default nvim.desktop text/markdown || true

# Plain text → Mousepad
xdg-mime default org.xfce.mousepad.desktop text/plain || true

# Export env vars once (avoid duplicates)
grep -qxF 'export BROWSER=brave' ~/.profile 2>/dev/null || echo 'export BROWSER=brave' >> ~/.profile
grep -qxF 'export TERMINAL=alacritty' ~/.profile 2>/dev/null || echo 'export TERMINAL=alacritty' >> ~/.profile
grep -qxF 'export DOCUMENT_VIEWER=qpdfview' ~/.profile 2>/dev/null || echo 'export DOCUMENT_VIEWER=qpdfview' >> ~/.profile

echo "Default applications set (user mimeapps.list written to $MIMEFILE)."

# -----------------------
# Bluetooth installation
# -----------------------
echo "[6/15] Installing Bluetooth stack and GUI..."
sudo pacman -S --noconfirm bluez bluez-utils blueberry
sudo systemctl enable bluetooth
sudo systemctl start bluetooth

# -----------------------
# Enable NetworkManager
# -----------------------
sudo systemctl enable --now NetworkManager

# -----------------------
# Waybar configuration
# -----------------------
echo "[7/15] Configuring Waybar..."

mkdir -p ~/.config/waybar

cat > ~/.config/waybar/config <<'EOF'
{
  "layer": "top",
  "position": "top",

  "modules-left": ["sway/workspaces", "hyprland/workspaces"],
  "modules-center": ["clock"],
  "modules-right": ["network", "battery", "bluetooth", "pulseaudio", "sway/language", "hyprland/language", "tray"],

  "clock": {
    "format": "{:%a %b %d  %H:%M}",
    "tooltip": false
  },

  "battery": {
    "format": "<span font='Font Awesome 6 Free 11'>{icon}</span>  {capacity}% - {time}",
    "format-icons": ["\uf244", "\uf243", "\uf242", "\uf241", "\uf240"],
    "format-charging": "<span font='Font Awesome 6 Free'>\uf0e7</span>  <span font='Font Awesome 6 Free 11'>{icon}</span>  {capacity}% - {time}",
    "format-full": "<span font='Font Awesome 6 Free'>\uf0e7</span>  <span font='Font Awesome 6 Free 11'>{icon}</span>  Charged",
    "interval": 12,
    "states": {
      "warning": 20,
      "critical": 10
    },
    "tooltip": false,
    "on-click": "2"
  },

  "pulseaudio": {
    "format": "\uf028 {volume}%",
    "on-click": "pavucontrol",
    "capped-values": true
  },

  "network": {
    "format": "\uf1eb {ifname} {essid} {signalStrength}%",
    "on-click": "nmtui"
  },

  "bluetooth": {
    "format": "{status}",
    "format-connected": " {num_connections}",
    "format-disabled": " off",
    "tooltip-format": "{status}\n{device_alias} ({device_address})",
    "on-click": "blueberry"
  },

  "hyprland/language": {
    "format": "{short} {variant}"
  },
  "sway/language": {
    "format": "{short} {variant}"
  },

  "tray": {
    "icon-size": 12,
    "spacing": 10
  },

  "hyprland/workspaces": {
  "format": "{name} {icon}",
  "on-scroll-up": "hyprctl dispatch workspace e-1",
  "on-scroll-down": "hyprctl dispatch workspace e+1",
  "format-icons": {
    "active": "\u25cf",
    "default": "\u25CB"
  }
  },

  "sway/workspaces": {
    "format": "{name}: {icon}",
    "format-icons": {
      "urgent": "\uf06a",
      "focused": "\u25cf",
      "default": "\u25CB"
    },
  }
}
EOF

if [[ ! -f ~/.config/waybar/style.css ]]; then
cat > ~/.config/waybar/style.css <<'EOF'
* {
  font-family: "Font Awesome 6 Free", "Noto Sans";
  font-size: 15px;
  color: #ffffff;
  background-color: #000000;
}

#workspaces {
padding: 0px 5px 0px 5px;
}

#clock {
  font-size: 17px;
  font-weight: bold;
}

#battery,
#pulseaudio,
#network,
#bluetooth,
#language,
#tray,
#workspaces {
  padding: 0 10px;
}
EOF
fi

# -----------------------
# Configure Sway
# -----------------------
echo "[8/15] Configuring Hyprland..."
mkdir -p ~/.config/hypr

cat > ~/.config/hypr/hyprlock.conf <<'EOF'
# Dark Mode / Eye-Friendly hyprlock.conf

general {
    disable_loading_bar = true
    grace = 1000
    hide_cursor = false
}

# The Background
background {
    monitor = 
    path = $(cat $HOME/.cache/lastwallpaper)
    blur_passes = 3    
}

# Centered, Dark Input Field
input-field {
    monitor = 
    size = 300, 50 
    position = 0, 0 
    halign = center
    valign = center
    
    outline_thickness = 2 # Thin border
    
    # Dark/Muted Colors for minimal intensity
    inner_color = rgb(151515DD) # Very dark gray, slightly transparent
    outer_color = rgb(333333FF) # Darker gray border
    
    font_color = rgb(AAAAAA) # Muted white text
    placeholder_text = <span foreground="##555555">Enter Password...</span> # Very dark gray placeholder
    
    # Error/Success colors should still be visible but not neon
    fail_color = rgb(A00000) # Muted red for failure
    check_color = rgb(006000) # Dark green for success
    
    dots_size = 0
}

# Muted Time Label
label {
    monitor = 
    text = cmd[update:1000] echo "<b>$(date +'%H:%M')</b>"
    font_size = 20
    
    # Muted white text color
    color = rgb(999999DD) 
    
    position = 0, -150 
    halign = center
    valign = center
}
EOF

cat > ~/.config/hypr/hypridle.conf <<'EOF'
general {
    lock_cmd = hyprlock
    before_sleep_cmd = loginctl lock-session
    after_sleep_cmd = hyprctl dispatch dpms on
}

listener {
    timeout = 300 # in 5 minutes (300 seconds) of idle time, lock screen
    on-timeout = hyprlock
}

listener {
    timeout = 600 # in 10 minutes (600 seconds) of idle time, turn screen off
    on-timeout = hyprctl dispatch dpms off
    on-resume = hyprctl dispatch dpms on
}

listener {
    on-timeout = hyprlock
}
EOF

# -----------------------
# Configure Alacritty (transparent background)
# -----------------------
echo "[9/15] Configuring Alacritty"
mkdir -p ~/.config/alacritty
cat > ~/.config/alacritty/alacritty.toml <<'EOF'
[window]
opacity = 0.5
EOF

# ------------------
# Screen Locking
# ------------------

mkdir -p ~/.local/bin
cat > ~/.local/bin/lock.sh <<'EOF'
#!/bin/bash

# -----------------------------
# Configuration
# -----------------------------
LOCK_TIMEOUT=300         # 5 minutes (300 seconds) → lock screen
DPMS_TIMEOUT=600         # 10 minutes (600 seconds) → turn off display
CONFIG_DIR="$HOME/.config/hypr"
CONFIG_PATH="$CONFIG_DIR/hypridle.conf"

# --- Compositor Detection & Command Setup ---
if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    COMPOSITOR="hyprland"
    IDLE_MANAGER="hypridle"
    
    echo "Detected Compositor: Hyprland. Using hypridle and generating config."

elif [ -n "$SWAYSOCK" ]; then
    COMPOSITOR="sway"
    IDLE_MANAGER="swayidle"
    
    LOCKER_CMD='swaylock -f \
      -c 000000 \
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
      --fade-in 0.3'
      
    DPMS_OFF_CMD='swaymsg "output * dpms off"'
    DPMS_ON_CMD='swaymsg "output * dpms on"'
    
    # swayidle command line arguments
    IDLE_ARGS="-w \
        timeout $LOCK_TIMEOUT \"$LOCKER_CMD\" \
        timeout $DPMS_TIMEOUT \"$DPMS_OFF_CMD\" \
        resume \"$DPMS_ON_CMD\" \
        before-sleep \"$LOCKER_CMD\""
        
    echo "Detected Compositor: Sway. Using swayidle."
    
else
    echo "Error: Neither Sway nor Hyprland detected. Exiting."
    exit 1
fi
# -----------------------------

# Kill any existing manager to avoid conflicts
killall $IDLE_MANAGER 2>/dev/null || true

# --- Execute Idle Manager ---
if [ "$COMPOSITOR" = "hyprland" ]; then
    # 3. Execute hypridle, which will automatically find the config file
    $IDLE_MANAGER &

elif [ "$COMPOSITOR" = "sway" ]; then
    # swayidle uses command line arguments, using 'eval' for safe execution of the string
    eval $IDLE_MANAGER $IDLE_ARGS &
fi

echo "$IDLE_MANAGER started in the background."
EOF
chmod +x ~/.local/bin/lock.sh

# ------------------
# Cheat sheet for keybindings
# ------------------
cat > ~/.local/bin/toggle-cheatsheet.sh <<'EOF'
#!/bin/bash

# Define the constants
CHEATSHEET_TITLE="Sway Cheatsheet"
CHEATSHEET_FILE="$HOME/.config/sway/cheatsheet.txt"
TERMINAL="alacritty"

# Search for the window based on the application ID or title
# We use both 'app_id' (set by --class) and 'name' (set by --title) for reliability.
CON_ID=$(swaymsg -t get_tree | jq -r '
    .. | 
    select(.type?) | 
    select(.app_id == "cheatsheet" or .name == "'$CHEATSHEET_TITLE'") | 
    .id
')

if [ -n "$CON_ID" ]; then
    # The cheatsheet is open, so kill the window
    swaymsg "[con_id=$CON_ID] kill"
else
    # The cheatsheet is not open, so launch it in a new terminal
    # - The --class flag sets the app_id for detection/toggling.
    # - The -e flag runs the 'less' utility, which allows scrolling and uses 'q' to quit.
    "$TERMINAL" --class "cheatsheet" --title "$CHEATSHEET_TITLE" -e less "$CHEATSHEET_FILE" &
fi
EOF
chmod +x ~/.local/bin/toggle-cheatsheet.sh

# ------------------
# Wofi toggle
# ------------------
cat > ~/.local/bin/toggle-wofi.sh <<'EOF'
#!/bin/bash

# Check if Wofi is already running
if pgrep -x "wofi" > /dev/null; then
    # If running, kill it
    pkill wofi
else
    # If not running, launch it
    wofi --show drun --insensitive --allow-images
fi
EOF
chmod +x ~/.local/bin/toggle-wofi.sh

# ------------------
# Dynamic workspace functionality (if workspace doesn't exist, create it)
# ------------------
cat > ~/.local/bin/dynamic-workspaces.sh <<'EOF'
#!/bin/bash

# Detect compositor
if pidof sway >/dev/null; then
    compositor="sway"
elif pidof Hyprland >/dev/null; then
    compositor="hyprland"
else
    echo "Unsupported compositor"
    exit 1
fi

direction=$1

if [ "$compositor" = "sway" ]; then
    # Get current workspace number
    current=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused) | .num')

    if [ "$direction" = "next" ]; then
        target=$((current + 1))
    elif [ "$direction" = "prev" ]; then
        target=$((current - 1))
    else
        echo "Usage: $0 {next|prev}"
        exit 1
    fi

    # Create and switch
    swaymsg workspace number "$target"

    # Optional: remove empty workspaces after short delay
    (
      sleep 0.2
      swaymsg -t get_workspaces | jq -r '.[] | select(.num > 9 or .num < 20) | .num' | \
      while read ws; do
        empty=$(swaymsg -t get_tree | jq ".. | select(.type? == \"workspace\" and .num == $ws) | (.nodes + .floating_nodes) | length == 0")
        [ "$empty" = "true" ] && swaymsg workspace number "$ws", kill
      done
    ) &

elif [ "$compositor" = "hyprland" ]; then
    if [ "$direction" = "next" ]; then
        hyprctl dispatch workspace +1
    elif [ "$direction" = "prev" ]; then
        hyprctl dispatch workspace -1
    else
        exit 1
    fi
fi
EOF
chmod +x ~/.local/bin/dynamic-workspaces.sh

# ------------------
# Wallpaper Settings
# ------------------
cat > ~/.local/bin/set-wallpaper.sh <<'EOF'
#!/bin/bash

# --- Configuration Variables ---
DIR="$HOME/Pictures/Wallpapers"
LAST="$HOME/.cache/lastwallpaper"
# CACHE logic removed

# Detect Compositor and set paths/commands
if [ -n "$SWAYSOCK" ]; then
    COMPOSITOR="sway"
    CONFIG_FILE="$HOME/.config/sway/config"
    RELOAD_CMD="swaymsg reload"
    echo "Detected Compositor: Sway"
elif [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    COMPOSITOR="hyprland"
    CONFIG_FILE="$HOME/.config/hypr/hyprland.conf"
    RELOAD_CMD="hyprctl reload"
    echo "Detected Compositor: Hyprland"
else
    echo "Error: Neither Sway nor Hyprland detected. Exiting."
    exit 1
fi
# -------------------------------

# Build list for wofi: simply list filenames
CHOICE=$(find "$DIR" -maxdepth 1 -type f | while read -r img; do 
    basename "$img"
done | wofi --show dmenu --prompt "Wallpaper:")

# If user picked something, set & save it
if [ -n "$CHOICE" ]; then
    FILE="$DIR/$CHOICE"
    echo "$FILE" > "$LAST"
    
    # --- IMMEDIATE WALLPAPER SETTING (same for both) ---
    # NOTE: Using 'pkill -f' is sometimes safer to kill the specific process chain
    pkill -f swaybg
    swaybg -i "$FILE" -m fill &
    
    # --- CONFIGURATION UPDATE (Compositor-specific) ---
    
    if [ "$COMPOSITOR" == "sway" ]; then
        BG_CONFIG_LINE="output * bg $FILE fill"
        # Safely replace/append the Sway config line
        if grep -q "^output .* bg " "$CONFIG_FILE"; then
            sed -i "s|^output .* bg .*|${BG_CONFIG_LINE}|" "$CONFIG_FILE"
        else
            echo "${BG_CONFIG_LINE}" >> "$CONFIG_FILE"
        fi
        
    elif [ "$COMPOSITOR" == "hyprland" ]; then
        BG_CONFIG_LINE="exec = swaybg -i $FILE -m fill"
        
        # 1. Escape the file path for use in sed
        ESCAPED_FILE=$(echo "$FILE" | sed 's/[\/&]/\\&/g')
        ESCAPED_NEW_LINE="exec = swaybg -i ${ESCAPED_FILE} -m fill"
        
        # 2. Check and replace (or append) the swaybg exec command
        if grep -q "^exec = swaybg " "$CONFIG_FILE"; then
            # Replace existing line using 'c\' (change line)
            sed -i "/^exec = swaybg /c\\${ESCAPED_NEW_LINE}" "$CONFIG_FILE"
        else
            # Append to the config file
            echo "${BG_CONFIG_LINE}" >> "$CONFIG_FILE"
        fi
    fi

    # --- RELOAD COMPOSITOR ---
    $RELOAD_CMD
fi
EOF
chmod +x ~/.local/bin/set-wallpaper.sh

# ------------------------------------------
# Managing Peripherals (mouse and touchpad)
# ------------------------------------------
cat > ~/.local/bin/input-devices-config.sh <<'EOF'
#!/bin/bash

# --- Compositor Detection ---
if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    COMPOSITOR="hyprland"
    MSG_CMD="hyprctl keyword"
    QUERY_CMD="hyprctl devices -j"
elif [ -n "$SWAYSOCK" ]; then
    COMPOSITOR="sway"
    MSG_CMD="swaymsg"
    QUERY_CMD="swaymsg -t get_inputs"
else
    notify-send "Error: Neither Sway nor Hyprland detected."
    exit 1
fi
# ----------------------------

# --- Device Listing ---
# Note: Hyprland separates touchpads and mice, so we'll merge them for simplicity.
if [ "$COMPOSITOR" == "hyprland" ]; then
    DEVICES=$(
        $QUERY_CMD | jq -r '.touchpads[] | .name'
        $QUERY_CMD | jq -r '.mice[] | .name'
    )
    # The Hyprland command structure requires the device name (e.g., 'elan0801:00-04f3:3161-touchpad')
    DEVICE_IDENTIFIER="name"
else # Sway
    DEVICES=$($QUERY_CMD | jq -r '.[] | select(.type=="touchpad" or .type=="pointer") | .identifier')
    # The Sway command structure requires the device identifier (e.g., '1:1:AT_Translated_Set_2_keyboard')
    DEVICE_IDENTIFIER="identifier"
fi

[ -z "$DEVICES" ] && { notify-send "No pointer or touchpad found"; exit 1; }

# If multiple devices, pick one
DEVICE=$(echo "$DEVICES" | wofi --dmenu --prompt "Select device:")
[ -z "$DEVICE" ] && exit 0
# ----------------------------


# --- Get Current Settings ---
if [ "$COMPOSITOR" == "hyprland" ]; then
    # Function to get Hyprland settings by device type
    get_setting_hyprland() {
        local type="$1" # touchpads or mice
        local prop="$2" # tap-to-click or natural_scroll
        $QUERY_CMD | jq -r ".$type[] | select(.name==\"$DEVICE\") | .input_config.$prop // \"not_found\""
    }

    # Tap and Natural Scroll settings are under 'touchpads' only
    TAP=$(get_setting_hyprland "touchpads" "tap-to-click")
    NATURAL=$(get_setting_hyprland "touchpads" "natural_scroll")

    # Pointer speed (acceleration) is under both touchpads and mice
    ACCEL=$(get_setting_hyprland "touchpads" "sensitivity")
    if [ "$ACCEL" == "not_found" ]; then
        ACCEL=$(get_setting_hyprland "mice" "sensitivity")
    fi
    # Hyprland sensitivity is a float, e.g., 0.5. We use 1.0 as the default.
    ACCEL=${ACCEL//not_found/1.0}

    # Normalize states (true/false in Hyprland JSON)
    normalize_state() {
        case "$1" in
            true) echo "on" ;;
            false) echo "off" ;;
            *) echo "off" ;; # Default to off if property not found
        esac
    }

    # Hyprland uses 'input:device_name:property'
    # Tap and Natural Scroll apply to the device itself.
    TAP_CMD_PREFIX="input:$DEVICE:tap-to-click"
    NAT_CMD_PREFIX="input:$DEVICE:natural_scroll"
    ACCEL_CMD_PREFIX="input:$DEVICE:sensitivity"

else # Sway
    # Original Sway logic
    TAP=$($QUERY_CMD | jq -r ".[] | select(.identifier==\"$DEVICE\") | .tap")
    NATURAL=$($QUERY_CMD | jq -r ".[] | select(.identifier==\"$DEVICE\") | .natural_scroll")
    ACCEL=$($QUERY_CMD | jq -r ".[] | select(.identifier==\"$DEVICE\") | .pointer_accel")

    # Normalize states (enabled/disabled in Sway JSON)
    normalize_state() {
        case "$1" in
            enabled|on) echo "on" ;;
            disabled|off) echo "off" ;;
            *) echo "$1" ;;
        esac
    }

    # Sway uses 'input "identifier" property'
    TAP_CMD_PREFIX="input \"$DEVICE\" tap"
    NAT_CMD_PREFIX="input \"$DEVICE\" natural_scroll"
    ACCEL_CMD_PREFIX="input \"$DEVICE\" pointer_accel"
fi

TAP=$(normalize_state "$TAP")
NATURAL=$(normalize_state "$NATURAL")
# ----------------------------


# --- Present Options and Execute ---
OPTION=$(printf "Toggle Tap-to-Click\nToggle Natural Scroll\nSet Pointer Speed" | wofi --dmenu --prompt "Option:")
[ -z "$OPTION" ] && exit 0

case "$OPTION" in
    "Toggle Tap-to-Click")
        if [ "$TAP" = "on" ]; then
            $MSG_CMD "$TAP_CMD_PREFIX" $([ "$COMPOSITOR" == "hyprland" ] && echo "false" || echo "disabled")
            notify-send "Tap-to-click disabled"
        else
            $MSG_CMD "$TAP_CMD_PREFIX" $([ "$COMPOSITOR" == "hyprland" ] && echo "true" || echo "enabled")
            notify-send "Tap-to-click enabled"
        fi
        ;;
    "Toggle Natural Scroll")
        if [ "$NATURAL" = "on" ]; then
            $MSG_CMD "$NAT_CMD_PREFIX" $([ "$COMPOSITOR" == "hyprland" ] && echo "false" || echo "disabled")
            notify-send "Natural scrolling disabled"
        else
            $MSG_CMD "$NAT_CMD_PREFIX" $([ "$COMPOSITOR" == "hyprland" ] && echo "true" || echo "enabled")
            notify-send "Natural scrolling enabled"
        fi
        ;;
    "Set Pointer Speed")
        # Hyprland uses -1.0 to 1.0 (default 0.0). Sway uses -1.0 to 1.0 (default 0.0), but the prompt says 0.0-2.0.
        # We'll stick to a common range for the prompt, but the underlying command works.
        ACCEL_VAL=$(echo "$ACCEL" | wofi --dmenu --prompt "Set pointer speed (-1.0 to 1.0):")
        [ -n "$ACCEL_VAL" ] && $MSG_CMD "$ACCEL_CMD_PREFIX" "$ACCEL_VAL" && notify-send "Pointer speed set to $ACCEL_VAL"
        ;;
esac
EOF
chmod +x ~/.local/bin/input-devices-config.sh

# ------------------
# Display Settings
# ------------------
cat > ~/.local/bin/display-settings.sh <<'EOF'
#!/bin/bash

# Detect compositor
COMPOSITOR=""
# Use specific environment variables for reliable detection
if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    COMPOSITOR="hyprland"
    CONFIG="$HOME/.config/hypr/hyprland.conf"
elif [ -n "$SWAYSOCK" ] || [ -n "$I3SOCK" ]; then
    COMPOSITOR="sway"
    CONFIG="$HOME/.config/sway/config"
# Fallback to checking commands and session type (less reliable, but kept for compatibility)
elif command -v hyprctl &>/dev/null && [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    COMPOSITOR="hyprland"
    CONFIG="$HOME/.config/hypr/hyprland.conf"
elif command -v swaymsg &>/dev/null && [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    COMPOSITOR="sway"
    CONFIG="$HOME/.config/sway/config"
else
    echo "Unsupported compositor or not running Wayland."
    exit 1
fi

# Function to select monitor and mode for Sway (Verified Working)
function sway_mode() {
    local outputs=$(swaymsg -t get_outputs | jq -r '.[].name')
    local chosen_output=$(echo "$outputs" | wofi --dmenu --prompt "Select monitor:")
    [ -z "$chosen_output" ] && exit 0

    local modes=$(swaymsg -t get_outputs | jq -r ".[] | select(.name==\"$chosen_output\") | .modes[] | \"\(.width)x\(.height)@\(.refresh/1000)Hz\"")
    local chosen_mode=$(echo "$modes" | wofi --dmenu --prompt "Select resolution:")
    [ -z "$chosen_mode" ] && exit 0

    local width=$(echo "$chosen_mode" | cut -d'x' -f1)
    local height=$(echo "$chosen_mode" | cut -d'x' -f2 | cut -d'@' -f1)
    local refresh=$(echo "$chosen_mode" | cut -d'@' -f2 | sed 's/Hz//')

    swaymsg output "$chosen_output" mode ${width}x${height}@${refresh}Hz

    local confirm=$(echo -e "yes\nno" | wofi --dmenu --prompt "Save to sway config?")
    if [ "$confirm" == "yes" ]; then
        sed -i "/^output $chosen_output/d" "$CONFIG"
        echo "output $chosen_output mode ${width}x${height}@${refresh}Hz" >> "$CONFIG"
    fi
}

# Function to select monitor and mode for Hyprland (Fully Fixed)
function hyprland_mode() {
    # STEP 1: Get monitor outputs.
    local outputs=$(hyprctl -j monitors | jq -r '.[].name')
    
    [ -z "$outputs" ] && echo "ERROR: No monitor outputs detected." && exit 1

    local chosen_output=$(echo "$outputs" | wofi --dmenu --prompt "Select monitor:")
    [ -z "$chosen_output" ] && exit 0

    # STEP 2: Get modes. Correctly uses .availableModes[] field.
    local modes=$(hyprctl -j monitors | jq -r --arg out "$chosen_output" '.[] | select(.name == $out) | .availableModes[]')

    [ -z "$modes" ] && echo "ERROR: No modes found for $chosen_output." && exit 1

    # STEP 3: Second wofi prompt (should now display modes)
    local chosen_mode=$(echo "$modes" | wofi --dmenu --prompt "Select resolution:")
    [ -z "$chosen_mode" ] && exit 0

    # Apply the setting: monitor name, mode, position (auto), scale (1)
    hyprctl keyword monitor "$chosen_output,$chosen_mode,auto,1"

    local confirm=$(echo -e "yes\nno" | wofi --dmenu --prompt "Save to hyprland config?")
    if [ "$confirm" == "yes" ]; then
        sed -i "/^monitor=$chosen_output/d" "$CONFIG"
        
        # FINAL FIX: Must include offset (0x0) and scale (1) for valid config syntax.
        echo "monitor=$chosen_output, $chosen_mode, 0x0, 1" >> "$CONFIG"
    fi
}

# Run appropriate function
if [ "$COMPOSITOR" = "sway" ]; then
    sway_mode
elif [ "$COMPOSITOR" = "hyprland" ]; then
    hyprland_mode
fi
EOF
chmod +x ~/.local/bin/display-settings.sh

# ------------------
# Screenshots
# ------------------
cat > ~/.local/bin/screenshot.sh <<'EOF'
#!/bin/bash

# Directory for screenshots
DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"

# Default filename with timestamp
DEFAULT_FILE="screenshot-$(date +%Y-%m-%d_%H-%M-%S).png"

# Ask user: full screen or select region
MODE=$(printf "Full Screen\nSelect Area" | wofi --dmenu --prompt "Capture mode:")
[ -z "$MODE" ] && exit 0

# Determine geometry argument
if [ "$MODE" = "Select Area" ]; then
    GEOM=$(slurp)
    [ -z "$GEOM" ] && exit 0
    GEOM="-g \"$GEOM\""  # quote the geometry
else
    GEOM=""  # Full screen
fi

# Save screenshot to a temporary file
if [ -n "$GEOM" ]; then
    eval grim $GEOM /tmp/screenshot.png
else
    grim /tmp/screenshot.png
fi

# Ask user for filename
FILENAME=$(echo "$DEFAULT_FILE" | wofi --dmenu --prompt "Save screenshot as:")
[ -z "$FILENAME" ] && exit 0

# Append .png if missing
case "$FILENAME" in
    *.png) ;;
    *) FILENAME="$FILENAME.png" ;;
esac

# Move the screenshot to the final location
mv /tmp/screenshot.png "$DIR/$FILENAME"

# Notify user
notify-send "Screenshot saved" "$DIR/$FILENAME"
EOF
chmod +x ~/.local/bin/screenshot.sh

cat > ~/.config/input-config.sh <<'EOF'
#!/bin/bash

# --- Config File Path ---
HYPR_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/hyprland.conf"
# ------------------------

# --- Compositor Detection ---
if [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    notify-send "Error: Hyprland not detected."
    exit 1
fi
# ----------------------------


# --- Get Current Settings from Config ---
if [ ! -f "$HYPR_CONFIG" ]; then
    notify-send "Error: Config not found at $HYPR_CONFIG"
    exit 1
fi

# Get Sensitivity from config
SENSITIVITY=$(grep -E "^\s*sensitivity\s*=" "$HYPR_CONFIG" | tail -n 1 | sed -E 's/^\s*sensitivity\s*=\s*([-0-9\.]+).*/\1/')
[ -z "$SENSITIVITY" ] && SENSITIVITY="0.0" # Default if not found

# Get Mouse Acceleration (flat / adaptive) from config
PROFILE=$(grep -E "^\s*accel_profile\s*=" "$HYPR_CONFIG" | tail -n 1 | sed -E 's/^\s*accel_profile\s*=\s*([a-zA-Z]+).*/\1/')
[ -z "$PROFILE" ] && PROFILE="adaptive" # Default if not found
# ----------------------------


# --- Present Options and Execute ---
OPTION=$(printf "Set Mouse Sensitivity\nToggle Mouse Acceleration (flat / adaptive)" | wofi --dmenu --prompt "Option:")
[ -z "$OPTION" ] && exit 0

case "$OPTION" in
    "Set Mouse Sensitivity")
        SENS_VAL=$(echo "$SENSITIVITY" | wofi --dmenu --prompt "Set sensitivity (-1.0 to 1.0):")
        
        if [ -n "$SENS_VAL" ]; then
            # 1. Apply runtime setting GLOBALLY
            hyprctl keyword input:sensitivity "$SENS_VAL"
            notify-send "Runtime (Global): Sensitivity set to $SENS_VAL"

            # 2. Apply permanent setting to config file
            sed -i -E "s/^(\s*sensitivity\s*=\s*)[-0-9\.]+(\s*#.*)?$/\1$SENS_VAL\2/" "$HYPR_CONFIG"
            notify-send "Permanent: Config sensitivity set to $SENS_VAL"
        fi
        ;;
        
    "Toggle Mouse Acceleration (flat / adaptive)")
        NEW_PROFILE=""
        if [ "$PROFILE" = "flat" ]; then
            NEW_PROFILE="adaptive"
        else
            NEW_PROFILE="flat"
        fi

        # 1. Apply runtime setting GLOBALLY
        hyprctl keyword input:accel_profile "$NEW_PROFILE"
        notify-send "Runtime (Global): Profile set to $NEW_PROFILE"
        
        # 2. Apply permanent setting
        sed -i -E "s/^(\s*accel_profile\s*=\s*)[a-zA-Z]+(\s*#.*)?$/\1$NEW_PROFILE\2/" "$HYPR_CONFIG"
        notify-send "Permanent: Config profile set to $NEW_PROFILE"
        ;;
esac
EOF
chmod +x ~/.local/bin/input-config.sh

cat > ~/.config/hypr/hyprland.conf <<'EOF'
# ================================
# MOD KEYS
# ================================

# SUPER = SuperKey, ALT = Alt Key
$mod = SUPER

# ================================
# STARTUP
# ================================
# Draw on-screen (press ESC to close drawing mode)
bind = SUPER, D, exec, wayscriber --active

exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
exec-once = xhost +SI:localuser:root
exec-once = wl-paste --type text --watch cliphist store
exec-once = wl-paste --type image --watch cliphist store
exec-once = waybar
exec-once = dunst
exec-once = sway-audio-idle-inhibit
exec-once = gammastep -O 1510
exec-once = ~/.local/bin/lock.sh
exec-once = /usr/bin/gnome-keyring-daemon --start --components=secrets
exec-once = gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
exec-once = gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
exec-once = gsettings set org.gnome.desktop.interface color-scheme 'default'
exec-once = env QT_QPA_PLATFORMTHEME=qt5ct QT_STYLE_OVERRIDE=Adwaita-dark QT6_QPA_PLATFORMTHEME=qt6ct swaymsg exec true
exec-once = systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE

# ================================
# APPEARANCE
# ================================
general {
    gaps_in = 5
    gaps_out = 2
    border_size = 2
    layout = dwindle
}

decoration {
    rounding = 5
}

misc {
    disable_hyprland_logo = true
}

# ================================
# INPUTS
# ================================
input {
    kb_layout = ba,us
    kb_options = grp:alt_shift_toggle
    accel_profile = adaptive
    sensitivity = 0.4 # -1.0 - 1.0, 0 means no modification.
    touchpad {
        natural_scroll = true
        tap-to-click = true
    }
}

# ================================
# APP LAUNCHERS
# ================================
bind = $mod, RETURN, exec, alacritty
bind = $mod, B, exec, brave
bind = $mod, E, exec, thunar
bind = $mod SHIFT, C, exec, ~/.local/bin/toggle-cheatsheet.sh
bind = $mod SHIFT, S, exec, ~/.local/bin/screenshot.sh
bind = $mod SHIFT, I, exec, ~/.local/bin/input-config.sh
bind = $mod SHIFT, D, exec, ~/.local/bin/display-settings.sh
bind = $mod SHIFT, W, exec, ~/.local/bin/set-wallpaper.sh
bind = $mod SHIFT, T, exec, nwg-look
bind = $mod, SPACE, exec, ~/.local/bin/toggle-wofi.sh
bind = $mod SHIFT, Q, exec, ~/.local/bin/power-menu.sh
bind = $mod CTRL SHIFT, L, exec, hyprlock
bind = CTRL SHIFT, ESCAPE, exec, lxtask
bind = $mod, V, exec, nwg-clipman

# ================================
# WINDOW MANAGEMENT
# ================================
bind = $mod, Q, killactive
bind = $mod, F, fullscreen
bind = $mod, T, layoutmsg, toggletab
bind = $mod, S, layoutmsg, togglefloating
bind = $mod SHIFT, SPACE, togglefloating
bind = $mod, R, submap, resize

# Move tiling windows around
bind = $mod SHIFT, H, movewindow, l
bind = $mod SHIFT, J, movewindow, d
bind = $mod SHIFT, K, movewindow, u
bind = $mod SHIFT, L, movewindow, r   

# Move floating windows around
bind = $mod SHIFT, H, moveactive, -100 0
bind = $mod SHIFT, L, moveactive, 100 0
bind = $mod SHIFT, K, moveactive, 0 -100
bind = $mod SHIFT, J, moveactive, 0 100

# Focus windows
bind = $mod, H, movefocus, l
bind = $mod, L, movefocus, r
bind = $mod, K, movefocus, u
bind = $mod, J, movefocus, d
bind = $mod, LEFT, movefocus, l
bind = $mod, RIGHT, movefocus, r
bind = $mod, UP, movefocus, u
bind = $mod, DOWN, movefocus, d

# =======================================================
# Touchpad gestures (4-finger swipe to switch workpaces)
# =======================================================
gesture = 4, horizontal, workspace


# Zoom in and out with mod + plus / mod + minus
binde = $mod, minus, exec, hyprctl keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | grep float | awk '{print $2 - 0.1}')
binde = $mod, plus, exec, hyprctl keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | grep float | awk '{print $2 + 0.1}')   

binde = $mod, KP_Subtract, exec, hyprctl keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | grep float | awk '{print $2 - 0.1}')
binde = $mod, KP_Add, exec, hyprctl keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | grep float | awk '{print $2 + 0.1}')   

# ================================
# RESIZE MODE
# ================================
submap = resize
bind = , L, resizeactive, 5 0
bind = , H, resizeactive, -5 0
bind = , K, resizeactive, 0 -5
bind = , J, resizeactive, 0 5
bind = , RETURN, submap, reset
bind = , ESCAPE, submap, reset
submap = reset

# ================================
# WORKSPACES
# ================================
# Switch
bind = $mod, 1, workspace, 1
bind = $mod, 2, workspace, 2
bind = $mod, 3, workspace, 3
bind = $mod, 4, workspace, 4
bind = $mod, 5, workspace, 5
bind = $mod, 6, workspace, 6
bind = $mod, 7, workspace, 7
bind = $mod, 8, workspace, 8
bind = $mod, 9, workspace, 9
bind = $mod, 0, workspace, 10

# Move window to workspace
bind = $mod SHIFT, 1, movetoworkspace, 1
bind = $mod SHIFT, 2, movetoworkspace, 2
bind = $mod SHIFT, 3, movetoworkspace, 3
bind = $mod SHIFT, 4, movetoworkspace, 4
bind = $mod SHIFT, 5, movetoworkspace, 5
bind = $mod SHIFT, 6, movetoworkspace, 6
bind = $mod SHIFT, 7, movetoworkspace, 7
bind = $mod SHIFT, 8, movetoworkspace, 8
bind = $mod SHIFT, 9, movetoworkspace, 9
bind = $mod SHIFT, 0, movetoworkspace, 10

# Super + Mouse scroll to switch workspaces dynamically
bind = SUPER, mouse_up, exec, ~/.local/bin/sway-dynamic-workspaces.sh next
bind = SUPER, mouse_down, exec, ~/.local/bin/sway-dynamic-workspaces.sh prev

# ================================
# 🔊 VOLUME CONTROL
# ================================
bind = , XF86AudioRaiseVolume, exec, sh -c 'SINK=@DEFAULT_SINK@; pactl set-sink-volume $SINK +5%; V=$(pactl get-sink-volume $SINK | grep -oP "\\d{1,3}(?=%)" | head -1); V_DISPLAY=$(( V>200 ? 200 : V )); dunstify -r 2593 -u normal "🔊 Volume" "$V_DISPLAY%" -h int:value:$V_DISPLAY'
bind = , XF86AudioLowerVolume, exec, sh -c 'SINK=@DEFAULT_SINK@; pactl set-sink-volume $SINK -5%; V=$(pactl get-sink-volume $SINK | grep -oP "\\d{1,3}(?=%)" | head -1); V_DISPLAY=$(( V>200 ? 200 : V )); dunstify -r 2593 -u normal "🔊 Volume" "$V_DISPLAY%" -h int:value:$V_DISPLAY'
bind = , XF86AudioMute, exec, sh -c 'SINK=@DEFAULT_SINK@; pactl set-sink-mute $SINK toggle; M=$(pactl get-sink-mute $SINK | grep -q yes && echo "🔇 Muted" || echo "🔊 Unmuted"); V=$(pactl get-sink-volume $SINK | grep -oP "\\d{1,3}(?=%)" | head -1); V_DISPLAY=$(( V>200 ? 200 : V )); dunstify -r 2593 -u normal "$M" "$V_DISPLAY%" -h int:value:$V_DISPLAY'
bind = $mod SHIFT, RIGHT, exec, sh -c 'SINK=@DEFAULT_SINK@; pactl set-sink-volume $SINK +5%; V=$(pactl get-sink-volume $SINK | grep -oP "\\d{1,3}(?=%)" | head -1); V_DISPLAY=$(( V>200 ? 200 : V )); dunstify -r 2593 -u normal "🔊 Volume" "$V_DISPLAY%" -h int:value:$V_DISPLAY'
bind = $mod SHIFT, LEFT, exec, sh -c 'SINK=@DEFAULT_SINK@; pactl set-sink-volume $SINK -5%; V=$(pactl get-sink-volume $SINK | grep -oP "\\d{1,3}(?=%)" | head -1); V_DISPLAY=$(( V>200 ? 200 : V )); dunstify -r 2593 -u normal "🔊 Volume" "$V_DISPLAY%" -h int:value:$V_DISPLAY'
bind = $mod SHIFT, M, exec, sh -c 'SINK=@DEFAULT_SINK@; pactl set-sink-mute $SINK toggle; M=$(pactl get-sink-mute $SINK | grep -q yes && echo "🔇 Muted" || echo "🔊 Unmuted"); V=$(pactl get-sink-volume $SINK | grep -oP "\\d{1,3}(?=%)" | head -1); V_DISPLAY=$(( V>200 ? 200 : V )); dunstify -r 2593 -u normal "$M" "$V_DISPLAY%" -h int:value:$V_DISPLAY'

# ================================
# 💡 BRIGHTNESS CONTROL
# ================================
bind = , XF86MonBrightnessUp, exec, sh -c 'brightnessctl set +5%; V=$(brightnessctl -m | awk -F, "{print \$4}" | tr -d "%"); dunstify -r 2594 -u normal "☀️ Brightness" "$V%" -h int:value:$V'
bind = , XF86MonBrightnessDown, exec, sh -c 'brightnessctl set 5%-; V=$(brightnessctl -m | awk -F, "{print \$4}" | tr -d "%"); dunstify -r 2594 -u normal "☾ Brightness" "$V%" -h int:value:$V'
bind = $mod SHIFT, UP, exec, sh -c 'brightnessctl set +5%; V=$(brightnessctl -m | awk -F, "{print \$4}" | tr -d "%"); dunstify -r 2594 -u normal "☀️ Brightness" "$V%" -h int:value:$V'
bind = $mod SHIFT, DOWN, exec, sh -c 'brightnessctl set 5%-; V=$(brightnessctl -m | awk -F, "{print \$4}" | tr -d "%"); dunstify -r 2594 -u normal "☾ Brightness" "$V%" -h int:value:$V'
EOF

cat > ~/.config/sway/cheatsheet.txt <<'EOF'
                                   Sway WM Keybindings Cheatsheet
                                 (Superkey is the Windows/Meta key)

========================================================================================
                                     WINDOW MANAGEMENT & MOVEMENT
========================================================================================
Super + Return ............ Launch Terminal (Alacritty)
Super + q ................. Close/Kill Focused Window
Super + f ................. Toggle Fullscreen Mode
Super + Shift + Space ..... Toggle Floating/Tiling Mode
Super + r ................. Enter Resize Mode (Use Arrow Keys to resize. Esc or Return to exit.)

                                       FOCUS & MOVEMENT
Super + h/j/k/l or Super + Arrow Keys ........... Move Focus Left/Down/Up/Right
Super + Shift + h/j/k/l ......................... Move Window Left/Down/Up/Right

                                         SPLIT & LAUNCH
Super + Ctrl + v .......... Vertical Split, then Launch App
Super + Ctrl + h .......... Horizontal Split, then Launch App

                                          MOUSE ACTIONS
Super + Left Click Drag ... Move Window
Super + Right Click Drag .. Resize Window

========================================================================================
                                           WORKSPACES
========================================================================================
Super + 1-0 ............... Switch to Workspace 1 through 10
Super + Shift + 1-0 ....... Move Current Window to Workspace 1 through 10

========================================================================================
                                          LAUNCHERS & APPS
========================================================================================
Super + Space ............. App Launcher (Wofi drun)
Super + e ................. File Manager (Thunar)
Super + b ................. Browser (Brave)
Super + v ................. Clipboard History Picker (Clipman)
Control + Shift + Escape .. Task Manager (lxtask)

========================================================================================
                                        SYSTEM & UTILITIES
========================================================================================
Super + Shift + q ......... Power Menu (Shutdown, Reboot, etc.)
Super + Shift + Ctrl + l .. Lock Screen (swaylock)
Super + Shift + s ......... Take Screenshot
Super + Shift + c ......... Display this CheatSheet

                                          MEDIA CONTROLS
Super + Shift + Up/Down ... Change Brightness
Super + Shift + Left/Right. Change Volume
Super + Shift + m ......... Toggle Mute

                                          CONFIG LAUNCHERS
Super + Shift + d ......... Display Settings/Monitor Config
Super + Shift + i ......... Peripherals/Input Config
Super + Shift + t ......... GTK Theme Settings (nwg-look)
Super + Shift + w ......... Wallpaper Picker (make sure you put the wallpapers in ~/Pictures/Wallpapers)

                                          MISCELLANEOUS
Alt + Shift ............... Toggle Keyboard Layout (ba/us)
EOF

# -----------------------
# Wofi configuration
# -----------------------
echo "[9/15] Configuring Wofi..."

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
term=alacritty
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
echo "[10/15] Creating power menu script..."
cat > ~/.local/bin/power-menu.sh <<'EOF'
#!/bin/bash

# Detect compositor
if pidof sway >/dev/null; then
    compositor="sway"
elif pidof Hyprland >/dev/null; then
    compositor="hyprland"
else
    compositor="unknown"
fi

# Show menu
choice=$(printf "Power off\nReboot\nLogout" | wofi --show dmenu --prompt "Power Menu")

case "$choice" in
    "Power off")
        systemctl poweroff
        ;;
    "Reboot")
        systemctl reboot
        ;;
    "Logout")
        if [ "$compositor" = "sway" ]; then
            swaymsg exit
        elif [ "$compositor" = "hyprland" ]; then
            hyprctl dispatch exit
        else
            notify-send "Unknown compositor" "Cannot logout"
            exit 1
        fi
        ;;
esac
EOF
chmod +x ~/.local/bin/power-menu.sh

# -----------------------
# Dunst configuration
# -----------------------
echo "[11/15] Configuring Dunst notifications..."
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
echo "[12/15] Setting default brightness to 15%..."
brightnessctl set 15%
sudo usermod -aG video $USER

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
