# Quick Reference Guide

## Installation Commands

### One-Line Install
```bash
curl -fsSL https://raw.githubusercontent.com/CowboyPilot/ETCR5_VARA_TOOLS/main/install.sh | bash
```

### Manual Download & Install
```bash
wget https://raw.githubusercontent.com/CowboyPilot/ETCR5_VARA_TOOLS/main/install.sh
chmod +x install.sh
./install.sh
```

## File Locations

| File | Location | Purpose |
|------|----------|---------|
| `10-install_all.sh` | `~/add-ons/wine/` | Install VARA apps into Wine |
| `etc-vara` | `/opt/emcomm-tools/bin/` | Launch VARA applications |
| `fix_sources.sh` | `~/` | Fix APT repository issues |
| Wine prefix | `~/.wine32` | 32-bit Wine environment |
| Winlink | `~/.wine32/drive_c/RMS Express/` | Winlink Express files |
| VarAC | `~/.wine32/drive_c/VarAC/` | VarAC application |
| VARA HF | `~/.wine32/drive_c/VARA/` | VARA HF modem |
| VARA FM | `~/.wine32/drive_c/VARA FM/` | VARA FM modem |

## Common Commands

### Install VARA Applications
```bash
cd ~/add-ons/wine
./10-install_all.sh
```

**Note:** First run may require logout/login to update environment.

### Launch VARA Applications
```bash
etc-vara
```

### Fix APT Issues
```bash
sudo ~/fix_sources.sh
```

### Manual VARA Launch
```bash
# Launch Winlink manually
env -u WINEARCH WINEPREFIX=$HOME/.wine32 wine "C:\RMS Express\RMS Express.exe"

# Launch VarAC manually
env -u WINEARCH WINEPREFIX=$HOME/.wine32 wine "C:\VarAC\VarAC.exe"
```

### Check Port Usage
```bash
# See what's using VARA ports
ss -tan | grep "83[0-4][0-9]"

# Kill stray VARA processes
pkill -f "VARA"
pkill -f "VarAC"
WINEPREFIX=~/.wine32 wineserver -k
```

## etc-vara Menu Options

| Option | Description |
|--------|-------------|
| 1 | VarAC + VARA HF |
| 2 | VarAC + VARA FM |
| 3 | Winlink + VARA HF |
| 4 | Winlink + VARA FM |
| 5 | Winlink Other (ARDOP/Telnet) |
| 6 | Pat + VARA HF |
| 7 | Pat + VARA FM |
| 8 | VARA HF Modem Only |
| 9 | VARA FM Modem Only |
| 10 | Exit |

## Prerequisites

Before installation, run these EmComm Tools commands:

```bash
et-user    # Set callsign and user info
et-audio   # Configure audio devices
et-radio   # Configure radio
```

## Required Downloads

Download and place in `~/add-ons/wine/` or `~/Downloads/`:

- VarAC installer: `VarAC_Installer*.exe`
- VARA HF installer: `VARA*.exe` (optional)
- VARA FM installer: `VARAFM*.exe` or `VARA*FM*.exe` (optional)

## Troubleshooting Quick Fixes

### "WINEARCH not set to win32"
```bash
# Log out and log back in after first run of 10-install_all.sh
# Then run it again
cd ~/add-ons/wine
./10-install_all.sh
```

### "No free port found"
```bash
# Kill all VARA processes
pkill -f "VARA"
pkill -f "VarAC"
pkill -f "RMS Express"
WINEPREFIX=~/.wine32 wineserver -k
```

### APT/Package Errors
```bash
sudo ~/fix_sources.sh
```

### Wine Process Stuck
```bash
# Force kill Wine processes
WINEPREFIX=~/.wine32 wineserver -k

# Or kill everything
/opt/emcomm-tools/bin/et-kill-all
```

### Missing Dependencies
```bash
sudo apt update
sudo apt install wine winetricks wget curl unzip jq
```

## Environment Variables

| Variable | Value | Purpose |
|----------|-------|---------|
| `WINEARCH` | `win32` | Force 32-bit Wine |
| `WINEPREFIX` | `$HOME/.wine32` | Wine prefix location |

## Port Range

VARA applications use TCP ports **8300-8350** for command and data channels.

## Links

- GitHub Repository: https://github.com/CowboyPilot/ETCR5_VARA_TOOLS
- EmComm Tools: https://github.com/WheezyE/Winelink
- VARA Website: https://rosmodem.wordpress.com/
- VarAC Website: https://www.varac-hamradio.com/

## Getting Help

1. Check the main [README.md](README.md) for detailed documentation
2. Review [Troubleshooting](README.md#troubleshooting) section
3. Open an issue on GitHub
4. Check existing issues for solutions

73!
