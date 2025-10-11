# Arch Linux Sway Config

A complete, minimal, and highly functional **Sway setup for Arch Linux**, including Waybar, Wofi, PipeWire, smart volume & brightness controls, lightweight GUI utilities, and default keybindings.

This setup is designed for **minimal Arch installations** and provides a user-friendly yet lightweight desktop experience.

---

## Features

- **Waybar** at the top with:
  - Centered large clock  
  - Battery percentage  
  - Volume control  
  - WiFi and network status  
  - Bluetooth status and device management  
  - System tray  

- **Wofi** as an app launcher on `Super + d` keys
- **Power menu** with Poweroff, Reboot, Logout via `Super+Shift+Q`  
- **Browsers**:
  - Brave → `Super+B`  
  - LibreWolf → `Super+L`  
- **Terminal** → `Super+Enter` (Alacritty)  
- **File manager** → `Super+E` (Thunar)
- **GTK App Theme Settings** → `Super+Shift+T`
- **Task Manager GUI** → `Ctrl+Shift+Esc` (LXTASK)  
- **Keyboard layouts**: Bosnian (`ba`) and English (`us`), switched with `Alt+Shift`  
- **Screenshot tool** → `Super+Shift+S`  
- **Volume controls**:
  - XF86 hardware keys supported  
  - Smart fallback keys if hardware keys fail: `Super+Shift+Right` (volume up), `Super+Shift+Left` (volume down), `Super+Shift+M` (mute)  
- **Brightness controls**:
  - XF86 hardware keys supported  
  - Smart fallback keys if hardware keys fail: `Super+Shift+Up` (increase), `Super+Shift+Down` (decrease)  
  - Default brightness set to **15%**  
- **Wallpaper Changer (need to have an image in ~/Pictures/Wallpapers)** → `Super+Shift+W`
- **Tabbed layout toggle** -> `Super+t`
- **Floating/Tilind layouts toggle** -> `Super+Shift+Space`
- **Lock screen** -> `Super+Ctrl+Shift+L`
- **Media keys**: Play/Pause, Next, Previous (via Playerctl)  

---

## Keybindings

| Action                      | Keybinding                  |
|------------------------------|-----------------------------|
| App launcher (Wofi)          | Super                        |
| Brave browser                | Super+B                      |
| LibreWolf browser            | Super+L                      |
| Terminal (Alacritty)         | Super+Enter                  |
| File manager (Thunar)        | Super+E                      |
| Task Manager GUI (LXTASK)    | Ctrl+Shift+Esc               |
| Power menu                   | Super+Shift+Q                |
| Wallpaper Changer            | Super+Shift+W                |
| Tiling layout toggle         | Super+T                      |
| Floating/Tilind layout toggle| Super+Shift+Space            |
| Lock screen                  | Super+Ctrl+Shift+L           |
| Screenshot                   | Super+Shift+S                |
| Volume Up                    | XF86AudioRaiseVolume / Super+Shift+Right |
| Volume Down                  | XF86AudioLowerVolume / Super+Shift+Left |
| Mute Toggle                  | XF86AudioMute / Super+Shift+M |
| Brightness Up                | XF86MonBrightnessUp / Super+Shift+Up |
| Brightness Down              | XF86MonBrightnessDown / Super+Shift+Down |
| Fullscreen toggle            | Super+F                      |
| Close window                 | Super+Q                      |
| Keyboard layout toggle       | Alt+Shift                    |
| Media Play/Pause             | XF86AudioPlay                |
| Media Next                   | XF86AudioNext                |
| Media Previous               | XF86AudioPrev                |

---

## Installation

Method 1 - Install using wget (install wget with ```sudo pacman -S wget```):

```sudo wget -qO - https://raw.githubusercontent.com/FatihTheDev/archlinux-sway-config/main/sway-setup.sh | bash```

Note: This is a capital o, not a zero.

Method 2 - Install by cloning the git repository:

1. **Clone the repository:**
```bash
git clone https://github.com/FatihTheDev/archlinux-sway-config.git
cd archlinux-sway-config
```
2. **Run the setup script:**
```bash
bash sway-setup.sh
```

The script will install all required packages, configure Sway, Waybar, Wofi, bluetooth, smart volume & brightness keys, and set up GUI utilities.

3.**Restart Sway to apply all changes.**
