# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Complete installation script (`install.sh`) for one-line installation
- Improved README with detailed documentation
- GitHub Actions workflow for shellcheck validation
- CONTRIBUTING.md with contribution guidelines
- **Automatic VARA HF/FM installer download** from Winlink if not found locally

### Changed
- Renamed `10-install_tools.sh` to `10-install_all.sh` for clarity
- Enhanced README with troubleshooting section
- Better organized repository structure
- VARA installers now auto-download if not present

### Fixed
- Installation paths now properly verified before proceeding
- Improved error handling in installation script

## [1.0.0] - Initial Release

### Added
- 10-install_all.sh: Automated installer for Winlink, VarAC, VARA HF/FM
- etc-vara: Smart launcher with dynamic port allocation
- fix_sources.sh: APT repository fix for Ubuntu 22.x
- Basic README documentation

### Features
- 32-bit Wine prefix support at ~/.wine32
- Automatic environment patching for Wine architecture
- Desktop launcher creation for GNOME
- INI file patching for port management
- Support for VarAC, Winlink Express, and Pat Winlink
- VARA HF and VARA FM modem support
- Port scanning (8300-8350) to avoid conflicts
- Cleanup of stale processes before launch
- PDH.dll fix for VARA modems

[Unreleased]: https://github.com/CowboyPilot/ETCR5_VARA_TOOLS/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/CowboyPilot/ETCR5_VARA_TOOLS/releases/tag/v1.0.0
