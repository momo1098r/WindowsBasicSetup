# WindowsBasicSetup
 Windows Auto Setup Script

A two-file automation script (`setup.cmd` + `setup.ps1`) for quick Windows configuration after a fresh install. Run it once — it handles everything from registry tweaks and software installation to Windows Update, rebooting and resuming automatically until the system is fully up to date.

---

## Features

- 🎨 **Wallpaper & Lock Screen** — sets a custom image for both desktop and lock screen, disabling Windows Spotlight
- 🌑 **Dark Theme** — enables dark mode for apps and system UI
- 🖱️ **Classic Context Menu** — restores the full right-click menu on Windows 11
- 📂 **File Extensions** — makes file extensions visible in Explorer
- 🔒 **UAC Disabled** — removes User Account Control prompts
- ⚡ **Power Plan** — disables standby, monitor timeout and disk timeout; sets boot timeout to 3 seconds
- 🔍 **Search** — disables Cortana and Bing integration in Windows Search
- 🛡️ **Security Health** — restores the Security Health icon in the system tray
- 📋 **Context Menu** — adds CopyTo and MoveTo entries to the right-click menu
- 🍫 **Chocolatey** — installs automatically and uses it to deploy:
  - Google Chrome, Firefox
  - VLC, K-Lite Codec Pack Mega
  - 7-Zip, Everything, TeraCopy
  - Adobe Reader, HWiNFO, Java Runtime
- 📦 **Office 2024** — downloads and runs the official Microsoft installer (Italian, x64)
- 🔄 **Windows Update Loop** — installs all available updates, reboots if needed, and resumes automatically via Scheduled Task until no updates remain

---

## Requirements

- Windows 10 or Windows 11 (Home and Pro supported)
- Internet connection
- Administrator privileges (the script self-elevates automatically)

---

## Usage

1. Download both `setup.cmd` and `setup.ps1` and place them in the **same folder**
2. Double-click `setup.cmd`
3. Accept the UAC prompt
4. Wait — the script will handle the rest, including reboots

> After each reboot, Windows Update will resume automatically. No need to re-run anything manually.

---

## File Overview

| File | Role |
|------|------|
| `setup.cmd` | Launcher — applies registry tweaks, then calls `setup.ps1` |
| `setup.ps1` | Main script — wallpaper, software, Office, Windows Update loop |

---

## Notes

- The Office 2024 installer is downloaded directly from Microsoft's servers (`c2rsetup.officeapps.live.com`) — no third-party source involved
- The Windows Update Scheduled Task (`SetupWindowsUpdate`) is automatically removed once all updates are installed
- The `SETUP_UPDATE_MODE` environment variable is used internally to skip the first-run block on post-reboot cycles — it is also cleaned up automatically

---
