# ETC R5 VARA Tools

A collection of scripts to simplify VARA modem and Winlink Express installation and management on EmComm Tools R5 (Ubuntu-based ham radio distribution).

Note: Right now you have to run this script three times, the first will set the Wine Prefix to 32 bit then require you to log out and log back in to run the script again.  There are two bugs currently, one involves the Winlink INI file and it will crash the script, just start it again and it will finish up.  The second is that it downloads the VARA installers but doesn't see them so you'll need to run it a third time to get them to install.  Annoying for sure but the long run is only the first time.  Once I get some time I'll hammer out the bug that requires it to be run a third time.  The logging out process is going to be necessary regardless unless the base ET image updates to win32 as a default.

## Features

- **Automated Installation**: One-line install script that downloads and sets up everything
- **VARA Launcher**: Smart launcher that manages VARA HF/FM modems with dynamic port allocation
- **Winlink Integration**: Support for Winlink Express, VarAC, and Pat Winlink
- **System Fixes**: Utility to fix APT repository issues on Ubuntu 22.x systems

## Quick Start

### One-Line Installation

Run this command to download and install all tools:

```bash
curl -fsSL https://raw.githubusercontent.com/CowboyPilot/ETCR5_VARA_TOOLS/main/install.sh | bash
```

Or download and run manually:

```bash
wget https://raw.githubusercontent.com/CowboyPilot/ETCR5_VARA_TOOLS/main/install.sh
chmod +x install.sh
./install.sh
```

## What Gets Installed

The installation script will:

1. **10-install_all.sh** → `~/add-ons/wine/`
   - Installs Winlink Express, VarAC, VARA HF, and VARA FM into a 32-bit Wine prefix
   - Creates desktop launchers
   - Handles environment configuration

2. **vara-downloader.sh** → `~/add-ons/wine/`
   - Helper script for downloading VARA installers from Winlink

3. **etc-vara** → `/opt/emcomm-tools/bin/` (requires sudo)
   - Smart launcher for VARA modems and applications
   - Dynamically allocates ports (8300-8350)
   - Supports VarAC, Winlink, and Pat combinations

4. **fix_sources.sh** → `~/`
   - Fixes APT repository issues on Ubuntu 22.x (especially kinetic)
   - Installs alsa-utils

5. **update-g90-config.sh** → `~/`
   - Configures Xiegu G90 for DigiRig with CAT or RTS PTT options

## Prerequisites

Before running the installer, ensure you have completed these EmComm Tools setup steps:

- `et-user` - Configure your callsign and user information
- `et-audio` - Set up audio devices
- `et-radio` - Configure your radio

You will need the VarAC installer:

- Download `VarAC_Installer_v*.exe` to `~/add-ons/wine/` or `~/Downloads/`

**VARA HF and VARA FM installers will be automatically downloaded** from Winlink if not found locally. If automatic download fails, you can manually download them from the [Winlink VARA Products page](https://downloads.winlink.org/VARA%20Products/).

## Usage

### Installing VARA Applications

After running the installation script, install VARA applications:

```bash
cd ~/add-ons/wine
./10-install_all.sh
```

**Important**: The first run may patch your environment and require you to log out and back in. After re-logging, run it again to complete the installation.

### Launching VARA Applications

Use the `etc-vara` launcher for a menu-driven experience:

```bash
etc-vara
```

Available options:
1. VarAC + VARA HF
2. VarAC + VARA FM
3. Winlink + VARA HF
4. Winlink + VARA FM
5. Winlink Other (ARDOP/Telnet - no VARA)
6. Pat + VARA HF
7. Pat + VARA FM
8. VARA HF Modem Only
9. VARA FM Modem Only

The launcher will:
- Clean up any running VARA/Wine processes
- Find a free TCP port (8300-8350)
- Update all INI files with the correct port
- Launch your selected combination

### Fixing APT Repository Issues

If you encounter APT/package installation errors (especially on Ubuntu 22.10 kinetic):

```bash
cd ~/
sudo ./fix_sources.sh
```

This will:
- Detect your Ubuntu version
- Update `/etc/apt/sources.list` to use the correct repositories
- Install alsa-utils

### Configuring Xiegu G90 with DigiRig

If you have a Xiegu G90 radio with DigiRig interface:

```bash
cd ~/
sudo ./update-g90-config.sh
```

This will present a menu to choose:
1. DigiRig with CAT PTT (recommended for better PTT control)
2. DigiRig with RTS PTT (original configuration)

The script will update the radio configuration and create a backup of the original settings.

## Manual Installation

If you prefer to install manually:

### 1. Install 10-install_all.sh

```bash
mkdir -p ~/add-ons/wine
cd ~/add-ons/wine
wget https://raw.githubusercontent.com/CowboyPilot/ETCR5_VARA_TOOLS/main/10-install_all.sh
chmod +x 10-install_all.sh
```

### 2. Install etc-vara (requires sudo)

```bash
sudo wget -O /opt/emcomm-tools/bin/etc-vara \
  https://raw.githubusercontent.com/CowboyPilot/ETCR5_VARA_TOOLS/main/etc-vara
sudo chmod +x /opt/emcomm-tools/bin/etc-vara
```

### 3. Install fix_sources.sh (optional)

```bash
cd ~/
wget https://raw.githubusercontent.com/CowboyPilot/ETCR5_VARA_TOOLS/main/fix_sources.sh
chmod +x fix_sources.sh
```

## Troubleshooting

### Wine Architecture Issues

If you see errors about WINEARCH, the installer will automatically patch your shell configuration files. You'll need to log out and back in for changes to take effect.

### VARA Not Connecting

- Ensure your radio is connected and configured via `et-radio`
- Check that the correct audio devices are selected in VARA settings
- Verify that no other applications are using the same TCP ports

### Missing Dependencies

The scripts check for required commands and will notify you if anything is missing. Common requirements:
- `wine`
- `winetricks`
- `wget`
- `curl`
- `unzip`
- `jq` (for Pat configuration)
- `pup` (for VARA auto-download, install with: `sudo apt install pup`)

### Port Conflicts

If you get "No free port found" errors, the launcher couldn't find an available port in the 8300-8350 range. Try:

```bash
# Check what's using ports
ss -tan | grep "83[0-4][0-9]"

# Kill any stray processes
pkill -f "VARA"
pkill -f "VarAC"
WINEPREFIX=~/.wine32 wineserver -k
```

## Technical Details

### Wine Prefix

All applications are installed in a dedicated 32-bit Wine prefix at `~/.wine32`. This keeps VARA applications isolated from other Wine installations.

### Port Management

The `etc-vara` launcher intelligently manages TCP ports:
- Scans ports 8300-8350 for availability
- Patches all relevant INI files (VARA HF/FM, VarAC, Winlink)
- Configures Pat Winlink if selected

### File Locations

- Wine prefix: `~/.wine32`
- Winlink: `~/.wine32/drive_c/RMS Express/`
- VarAC: `~/.wine32/drive_c/VarAC/`
- VARA HF: `~/.wine32/drive_c/VARA/`
- VARA FM: `~/.wine32/drive_c/VARA FM/`
- Desktop launchers: `~/.local/share/applications/`

## Contributing

Issues, suggestions, and pull requests are welcome! This project is designed specifically for EmComm Tools R5 but may work on other Ubuntu-based systems.

## License

These scripts are provided as-is for the amateur radio community. Use at your own risk.

## Credits

Developed for the EmComm Tools R5 community to simplify VARA modem setup and management.

73!
