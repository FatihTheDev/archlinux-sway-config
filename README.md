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

- **Wofi** as an app launcher on `Super` key  
- **Power menu** with Poweroff, Reboot, Logout via `Super+Shift+Q`  
- **Browsers**:
  - Brave → `Super+B`  
  - LibreWolf → `Super+L`  
- **Terminal** → `Super+Enter` (Ghostty)  
- **File manager** → `Super+E` (PCManFM)  
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
- **Wallpaper GUI** → `Super+W` (Azote)  
- **Media keys**: Play/Pause, Next, Previous (via Playerctl)  

---

## Keybindings

| Action                      | Keybinding                  |
|------------------------------|-----------------------------|
| App launcher (Wofi)          | Super                        |
| Brave browser                | Super+B                      |
| LibreWolf browser            | Super+L                      |
| Terminal (Ghostty)           | Super+Enter                  |
| File manager (PCManFM)       | Super+E                      |
| Task Manager GUI (LXTASK)    | Ctrl+Shift+Esc               |
| Power menu                   | Super+Shift+Q                |
| Wallpaper GUI (Azote)        | Super+W                      |
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
