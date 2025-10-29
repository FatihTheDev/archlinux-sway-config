#!/bin/bash
# archlinux-sway-setup.sh
# Complete Sway environment setup for Arch Linux
# Includes Waybar, Wofi, PipeWire/PulseAudio, Bluetooth, LXTASK, Azote, smart volume & brightness, XF86 keys, Thunar with archive support

set -e

echo "[1/15] Updating system..."
sudo pacman -Syu --noconfirm

echo "[2/15] Installing essential packages..."
sudo pacman -S --noconfirm sway swaybg swaylock swaylock-effects swayidle waybar wofi grim slurp wl-clipboard xorg-xwayland \
    xorg-xhost alacritty librewolf brave \
    network-manager-applet nm-connection-editor xdg-desktop-portal xdg-desktop-portal-wlr xdg-utils \
    ttf-font-awesome-4 noto-fonts papirus-icon-theme jq gnome-themes-extra adwaita-qt5-git adwaita-qt6-git qt5ct qt6ct \
    nwg-look nwg-clipman feh thunar thunar-archive-plugin thunar-volman gvfs engrampa zip unzip p7zip unrar qpdfview \
    playerctl dunst libnotify inotify-tools brightnessctl polkit-gnome \
    lxtask gammastep cliphist wl-clipboard gnome-font-viewer mousepad autotiling

yay -S sway-audio-idle-inhibit-git masterpdfeditor-free

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
application/pdf=brave-browser.desktop
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
  "modules-left": ["sway/workspaces"],
  "modules-center": ["clock"],
  "modules-right": ["network", "battery", "bluetooth", "pulseaudio", "sway/language", "tray"],

  "clock": {
    "format": "{:%a %b %d  %H:%M}",
    "tooltip": false
  },
  "battery": {
    "format": "<span font='Font Awesome 6 Free 13'>{icon}</span>  {capacity}% - {time}",
    "format-icons": ["\uf244", "\uf243", "\uf242", "\uf241", "\uf240"],
    "format-charging": "<span font='Font Awesome 6 Free'>\uf0e7</span>  <span font='Font Awesome 6 Free 13'>{icon}</span>  {capacity}% - {time}",
    "format-full": "<span font='Font Awesome 6 Free'>\uf0e7</span>  <span font='Font Awesome 6 Free 13'>{icon}</span>  Charged",
    "interval": 12,
    "states": {
        "warning": 20,
        "critical": 10
    },
    "tooltip": false,
    "on-click": "2"
  },
  "pulseaudio": {
    "format": "<span font='Font Awesome 6 Free 13'>\uf026</span> {volume}%",
    "on-click": "pavucontrol",
    "capped-values": true
  },
  "network": {
    "format": "\uf1eb {ifname} {essid} {signalStrength}%",
    "on-click": "nm-connection-editor"
  },
  "bluetooth": {
    "format": "{status}",
    "format-connected": " {num_connections}",
    "format-disabled": " off",
    "tooltip-format": "{status}\n{device_alias} ({device_address})",
    "on-click": "blueberry"
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
  font-family: "Font Awesome 6 Free", "Noto Sans";
  font-size: 15px;
  color: #ffffff;
  background-color: #000000;
}

#clock {
  font-size: 18px;
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
echo "[8/15] Configuring Sway..."
mkdir -p ~/.config/sway

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
# Configurable timers (in seconds)
# -----------------------------
LOCK_TIMEOUT=300      # 5 minutes (300 seconds) → lock screen
DPMS_TIMEOUT=600      # 10 minutes (600 seconds) → turn off display

# -----------------------------
# Swaylock styling
# -----------------------------
LOCK_CMD='swaylock -f \
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

# -----------------------------
# Launch swayidle with timers
# -----------------------------

# Kill any existing swayidle to avoid conflicts
killall swayidle 2>/dev/null || true

swayidle -w \
    timeout $LOCK_TIMEOUT "$LOCK_CMD" \
    timeout $DPMS_TIMEOUT 'swaymsg "output * dpms off"' \
    resume 'swaymsg "output * dpms on"' \
    before-sleep "$LOCK_CMD"
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
# Wallpaper Settings
# ------------------
cat > ~/.local/bin/set-wallpaper.sh <<'EOF'
#!/bin/bash
DIR="$HOME/Pictures/Wallpapers"
LAST="$HOME/.cache/lastwallpaper"
CACHE="$HOME/.cache/wallthumbs"
SWAYCONF="$HOME/.config/sway/config"

mkdir -p "$CACHE"

# Generate thumbnails (128px wide, only once per image)
for img in "$DIR"/*; do
    name=$(basename "$img")
    thumb="$CACHE/$name.png"
    if [ ! -f "$thumb" ]; then
        convert "$img" -thumbnail 128x128^ -gravity center -extent 128x128 "$thumb"
    fi
done

# Build list for wofi: format "filename\0icon\x1fpath/to/thumb"
CHOICE=$(for img in "$DIR"/*; do
    name=$(basename "$img")
    echo -en "$name\0icon\x1f$CACHE/$name.png\n"
done | wofi --show dmenu --prompt "Wallpaper:")

# If user picked something, set & save it
if [ -n "$CHOICE" ]; then
    FILE="$DIR/$CHOICE"
    echo "$FILE" > "$LAST"

    # Kill previous swaybg
    pkill swaybg

    # Set wallpaper immediately
    swaybg -i "$FILE" -m fill &

    # Update sway config (replace existing bg line or append if missing)
    if grep -q "^output .* bg " "$SWAYCONF"; then
        sed -i "s|^output .* bg .*|output * bg $FILE fill|" "$SWAYCONF"
    else
        echo "output * bg $FILE fill" >> "$SWAYCONF"
    fi

    # Reload sway to apply changes
    swaymsg reload
fi
EOF
chmod +x ~/.local/bin/set-wallpaper.sh

# ------------------------------------------
# Managing Peripherals (mouse and touchpad)
# ------------------------------------------
cat > ~/.local/bin/sway-input-config.sh <<'EOF'
#!/bin/bash

# Requires: swaymsg, jq, wofi, notify-send

# Get input devices (touchpad + mouse)
DEVICES=$(swaymsg -t get_inputs | jq -r '.[] | select(.type=="touchpad" or .type=="pointer") | .identifier')
[ -z "$DEVICES" ] && { notify-send "No pointer or touchpad found"; exit 1; }

# If multiple devices, pick one
DEVICE=$(echo "$DEVICES" | wofi --dmenu --prompt "Select device:")
[ -z "$DEVICE" ] && exit 0

# Get current settings
TAP=$(swaymsg -t get_inputs | jq -r ".[] | select(.identifier==\"$DEVICE\") | .tap")
NATURAL=$(swaymsg -t get_inputs | jq -r ".[] | select(.identifier==\"$DEVICE\") | .natural_scroll")
ACCEL=$(swaymsg -t get_inputs | jq -r ".[] | select(.identifier==\"$DEVICE\") | .pointer_accel")

# Normalize states (enabled/disabled vs on/off)
normalize_state() {
    case "$1" in
        enabled|on) echo "on" ;;
        disabled|off) echo "off" ;;
        *) echo "$1" ;;
    esac
}

TAP=$(normalize_state "$TAP")
NATURAL=$(normalize_state "$NATURAL")

# Present options
OPTION=$(printf "Toggle Tap-to-Click\nToggle Natural Scroll\nSet Pointer Speed" | wofi --dmenu --prompt "Option:")
[ -z "$OPTION" ] && exit 0

case "$OPTION" in
    "Toggle Tap-to-Click")
        if [ "$TAP" = "on" ]; then
            swaymsg "input \"$DEVICE\" tap disabled"
            notify-send "Tap-to-click disabled"
        else
            swaymsg "input \"$DEVICE\" tap enabled"
            notify-send "Tap-to-click enabled"
        fi
        ;;
    "Toggle Natural Scroll")
        if [ "$NATURAL" = "on" ]; then
            swaymsg "input \"$DEVICE\" natural_scroll disabled"
            notify-send "Natural scrolling disabled"
        else
            swaymsg "input \"$DEVICE\" natural_scroll enabled"
            notify-send "Natural scrolling enabled"
        fi
        ;;
    "Set Pointer Speed")
        SPEED=$(echo "$ACCEL" | wofi --dmenu --prompt "Set pointer speed (0.0-2.0):")
        [ -n "$SPEED" ] && swaymsg "input \"$DEVICE\" pointer_accel $SPEED" && notify-send "Pointer speed set to $SPEED"
        ;;
esac
EOF
chmod +x ~/.local/bin/sway-input-config.sh

# ------------------
# Display Settings
# ------------------
cat > ~/.local/bin/display-settings.sh <<'EOF'
#!/bin/bash

# Path to your sway config
SWAY_CONFIG="$HOME/.config/sway/config"

# Get available outputs (monitors)
outputs=$(swaymsg -t get_outputs | jq -r '.[].name')

# Choose output via wofi
chosen_output=$(echo "$outputs" | wofi --dmenu --prompt "Select monitor:")
[ -z "$chosen_output" ] && exit 0

# Get available modes (resolutions + refresh rates)
modes=$(swaymsg -t get_outputs | jq -r ".[] | select(.name==\"$chosen_output\") | .modes[] | \"\(.width)x\(.height)@\(.refresh/1000)Hz\"")

# Choose mode
chosen_mode=$(echo "$modes" | wofi --dmenu --prompt "Select resolution:")
[ -z "$chosen_mode" ] && exit 0

# Extract width, height, refresh
width=$(echo "$chosen_mode" | cut -d'x' -f1)
height=$(echo "$chosen_mode" | cut -d'x' -f2 | cut -d'@' -f1)
refresh=$(echo "$chosen_mode" | cut -d'@' -f2 | sed 's/Hz//')

# Apply immediately
swaymsg output "$chosen_output" mode ${width}x${height}@${refresh}Hz

# Ask if user wants to make permanent
confirm=$(echo -e "yes\nno" | wofi --dmenu --prompt "Save to sway config?")
if [ "$confirm" == "yes" ]; then
    # Remove existing lines for this output in config
    sed -i "/^output $chosen_output/d" "$SWAY_CONFIG"
    # Append new line at the end
    echo "output $chosen_output mode ${width}x${height}@${refresh}Hz" >> "$SWAY_CONFIG"
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

# Ask user for filename
FILENAME=$(echo "$DEFAULT_FILE" | wofi --dmenu --prompt "Save screenshot as:")
[ -z "$FILENAME" ] && exit 0

# Append .png if missing
case "$FILENAME" in
    *.png) ;;
    *) FILENAME="$FILENAME.png" ;;
esac

# Save screenshot
if [ -n "$GEOM" ]; then
    eval grim $GEOM "$DIR/$FILENAME"   # Use eval to expand the quoted geometry correctly
else
    grim "$DIR/$FILENAME"
fi

# Notify user
notify-send "Screenshot saved" "$DIR/$FILENAME"
EOF
chmod +x ~/.local/bin/screenshot.sh

cat > ~/.config/sway/config <<'EOF'
# Mod4 - Superkey, Mod1 - Alt Key
set $mod Mod4

# For password prompts
exec /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# --------------------
# Launchers
# --------------------
bindsym $mod+Ctrl+Shift+l exec swaylock -f -c 000000
# Toggable Cheatsheet in Terminal
bindsym $mod+Shift+c exec ~/.local/bin/toggle-cheatsheet.sh
bindsym $mod+b exec brave
bindsym $mod+Return exec alacritty
bindsym $mod+e exec thunar
bindsym $mod+period exec ~/.local/bin/emoji-picker.sh

# Screenshots
bindsym $mod+Shift+s exec ~/.local/bin/screenshot.sh

# Managing peripherals (mouse and touchpad)
bindsym $mod+Shift+i exec ~/.local/bin/sway-input-config.sh

# Display settings, like screen resolution, refresh rate, etc.
bindsym $mod+Shift+d exec ~/.local/bin/display-settings.sh

# Wallpaper picker
bindsym $mod+Shift+w exec ~/.local/bin/set-wallpaper.sh

# GTK application theme settings
bindsym $mod+Shift+t exec nwg-look

# Clipboard history
exec_always wl-paste --type text --watch cliphist store
exec_always wl-paste --type image --watch cliphist store
bindsym $mod+v exec nwg-clipman

# Task manager
bindsym Control+Shift+Escape exec lxtask

# --------------------
# Window management
# --------------------
exec_always autotiling

gaps inner 5
gaps outer 2

bindsym $mod+f fullscreen toggle
bindsym $mod+q kill
# Vertical split + app launcher
bindsym $mod+Ctrl+v exec sh -c 'swaymsg splitv; wofi --show drun --insensitive --allow-images | xargs swaymsg exec --'
# Horizontal split + app launcher
bindsym $mod+Ctrl+h exec sh -c 'swaymsg splith; wofi --show drun --insensitive --allow-images | xargs swaymsg exec --'

# To move windows with superkey + left-click
floating_modifier $mod

# Move window with Super + Left Mouse Drag
bindsym --whole-window $mod+button2 move

# Move windows around with Super + Shift + h, j, k, l
bindsym $mod+Shift+h move left 100px
bindsym $mod+Shift+l move right 100px
bindsym $mod+Shift+k move up 100px
bindsym $mod+Shift+j move down 100px  

# Move window focus with Super + h, j, k, l (like in vim)
bindsym $mod+h focus left 100px
bindsym $mod+l focus right 100px
bindsym $mod+k focus up 100px
bindsym $mod+j focus down 100px   

# Also use arrow keys to move focus between windows
bindsym $mod+Left focus left 100px
bindsym $mod+Right focus right 100px
bindsym $mod+Up focus up 100px
bindsym $mod+Down focus down 100px   

# Also use Alt + Tab to move focus between windows (useful for tabbed layout)
bindsym Mod1+Tab focus right
bindsym Mod1+Shift+Tab focus left

# --------------------
# Floating / tiling mode toggle + resize mode
# --------------------
bindsym $mod+Shift+Space floating toggle
bindsym $mod+t layout toggle tabbed split
bindsym $mod+s layout toggle stacking split

mode "resize" {
    bindsym l resize shrink width 5 px or 5 ppt
    bindsym k resize grow height 5 px or 5 ppt
    bindsym j resize shrink height 5 px or 5 ppt
    bindsym h resize grow width 5 px or 5 ppt
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
    # for Alt+Shift use "grp:alt_shift_toggle", for Superkey+Space use "grp:win_space_toggle"
    xkb_options "grp:alt_shift_toggle" 
}

# --------------------
# Touchpad Settings
# --------------------
input type:touchpad {
    tap enabled
    natural_scroll enabled
    pointer_accel 0.2
}

# --------------------
# App launcher
# --------------------
bindsym $mod+Space exec wofi --show drun --insensitive --allow-images --keynav
bindsym $mod+Shift+q exec ~/.local/bin/power-menu.sh

# --------------------
# Autostart
# --------------------
exec waybar
exec dunst
# When audio is playing, don't lock the screen
exec sway-audio-idle-inhibit
# Night Light
exec_always gammastep -P -O 2000
exec_always ~/.local/bin/wallpaper.sh
exec_always ~/.local/bin/lock.sh
# Activate gnome-keyring (for remembering WiFi passwords)
exec_always --no-startup-id /usr/bin/gnome-keyring-daemon --start --components=secrets
# Set system-wide dark mode
# For GTK apps
exec_always gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
exec_always gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
exec_always gsettings set org.gnome.desktop.interface color-scheme 'default'
# For QT apps
exec_always swaymsg exec env QT_QPA_PLATFORMTHEME=qt5ct QT_STYLE_OVERRIDE=Adwaita-dark QT6_QPA_PLATFORMTHEME=qt6ct
# Make systemd recognize user is using Wayland (for user services)
exec_always systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE

# --------------------
# Volume control (single OSD) - PipeWire, max display 200%
# --------------------
bindsym XF86AudioRaiseVolume exec sh -c 'SINK=@DEFAULT_SINK@; pactl set-sink-volume $SINK +5%; V=$(pactl get-sink-volume $SINK | grep -oP "\d{1,3}(?=%)" | head -1); V_DISPLAY=$(( V>200 ? 200 : V )); dunstify -r 2593 -u normal "🔊 Volume" "$V_DISPLAY%" -h int:value:$V_DISPLAY'
bindsym XF86AudioLowerVolume exec sh -c 'SINK=@DEFAULT_SINK@; pactl set-sink-volume $SINK -5%; V=$(pactl get-sink-volume $SINK | grep -oP "\d{1,3}(?=%)" | head -1); V_DISPLAY=$(( V>200 ? 200 : V )); dunstify -r 2593 -u normal "🔊 Volume" "$V_DISPLAY%" -h int:value:$V_DISPLAY'
bindsym XF86AudioMute exec sh -c 'SINK=@DEFAULT_SINK@; pactl set-sink-mute $SINK toggle; M=$(pactl get-sink-mute $SINK | grep -q yes && echo "🔇 Muted" || echo "🔊 Unmuted"); V=$(pactl get-sink-volume $SINK | grep -oP "\d{1,3}(?=%)" | head -1); V_DISPLAY=$(( V>200 ? 200 : V )); dunstify -r 2593 -u normal "$M" "$V_DISPLAY%" -h int:value:$V_DISPLAY'

# Optional fallback keys
bindsym $mod+Shift+Right exec sh -c 'SINK=@DEFAULT_SINK@; pactl set-sink-volume $SINK +5%; V=$(pactl get-sink-volume $SINK | grep -oP "\d{1,3}(?=%)" | head -1); V_DISPLAY=$(( V>200 ? 200 : V )); dunstify -r 2593 -u normal "🔊 Volume" "$V_DISPLAY%" -h int:value:$V_DISPLAY'
bindsym $mod+Shift+Left exec sh -c 'SINK=@DEFAULT_SINK@; pactl set-sink-volume $SINK -5%; V=$(pactl get-sink-volume $SINK | grep -oP "\d{1,3}(?=%)" | head -1); V_DISPLAY=$(( V>200 ? 200 : V )); dunstify -r 2593 -u normal "🔊 Volume" "$V_DISPLAY%" -h int:value:$V_DISPLAY'
bindsym $mod+Shift+m exec sh -c 'SINK=@DEFAULT_SINK@; pactl set-sink-mute $SINK toggle; M=$(pactl get-sink-mute $SINK | grep -q yes && echo "🔇 Muted" || echo "🔊 Unmuted"); V=$(pactl get-sink-volume $SINK | grep -oP "\d{1,3}(?=%)" | head -1); V_DISPLAY=$(( V>200 ? 200 : V )); dunstify -r 2593 -u normal "$M" "$V_DISPLAY%" -h int:value:$V_DISPLAY'

# --------------------
# Brightness control (single OSD)
# --------------------
bindsym XF86MonBrightnessUp exec sh -c 'brightnessctl set +5% >/dev/null 2>&1; V=$(brightnessctl -m | awk -F, "{print \$4}" | tr -d "%"); dunstify -r 2594 -u normal "☀️ Brightness" "$V%" -h int:value:$V'
bindsym XF86MonBrightnessDown exec sh -c 'brightnessctl set 5%- >/dev/null 2>&1; V=$(brightnessctl -m | awk -F, "{print \$4}" | tr -d "%"); dunstify -r 2594 -u normal "☾ Brightness" "$V%" -h int:value:$V'

# Fallback Brightness keys
bindsym $mod+Shift+Up exec sh -c 'brightnessctl set +5% >/dev/null 2>&1; V=$(brightnessctl -m | awk -F, "{print \$4}" | tr -d "%"); dunstify -r 2594 -u normal "☀️ Brightness" "$V%" -h int:value:$V'
bindsym $mod+Shift+Down exec sh -c 'brightnessctl set 5%- >/dev/null 2>&1; V=$(brightnessctl -m | awk -F, "{print \$4}" | tr -d "%"); dunstify -r 2594 -u normal "☾ Brightness" "$V%" -h int:value:$V'
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

choice=$(printf "Power off\nReboot\nLogout" | wofi --show dmenu --prompt "Power Menu")
case "$choice" in
    "Power off") systemctl poweroff ;;
    "Reboot") systemctl reboot ;;
    "Logout") swaymsg exit ;;
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
