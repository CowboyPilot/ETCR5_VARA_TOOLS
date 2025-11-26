# Repository Structure and Organization

## GitHub Repository Layout

```
ETCR5_VARA_TOOLS/
│
├── .github/                          # GitHub-specific configurations
│   └── workflows/
│       └── shellcheck.yml           # Automated testing workflow
│
├── 📄 README.md                      # Main documentation (REPLACE EXISTING)
├── 📄 CONTRIBUTING.md                # Contribution guidelines (NEW)
├── 📄 CHANGELOG.md                   # Version history (NEW)
├── 📄 QUICKREF.md                    # Quick reference guide (NEW)
│
├── 🔧 install.sh                     # Main installer script (NEW)
├── 🔧 10-install_all.sh              # VARA/Winlink installer (RENAME from 10-install_tools.sh)
├── 🔧 etc-vara                       # VARA launcher (REPLACE EXISTING)
└── 🔧 fix_sources.sh                 # APT fix script (REPLACE EXISTING)
```

## Files After User Installation

After a user runs the installer, files will be placed here:

```
User's System:
│
├── /home/user/
│   ├── add-ons/
│   │   └── wine/
│   │       └── 10-install_all.sh    # Installs VARA applications
│   │
│   ├── fix_sources.sh                # APT repository fix
│   │
│   └── .wine32/                      # 32-bit Wine prefix
│       └── drive_c/
│           ├── RMS Express/          # Winlink Express
│           ├── VarAC/                # VarAC application
│           ├── VARA/                 # VARA HF modem
│           └── VARA FM/              # VARA FM modem
│
└── /opt/emcomm-tools/
    └── bin/
        └── etc-vara                  # VARA launcher (requires sudo)
```

## File Descriptions

### Core Scripts

| File | Purpose | Install Location | Permissions |
|------|---------|------------------|-------------|
| `install.sh` | Downloads and installs all scripts | N/A (runs from curl) | Executable |
| `10-install_all.sh` | Installs Wine/VARA/Winlink apps | `~/add-ons/wine/` | Executable |
| `etc-vara` | Smart VARA launcher | `/opt/emcomm-tools/bin/` | Executable + sudo |
| `fix_sources.sh` | Fixes APT repositories | `~/` | Executable + sudo |

### Documentation

| File | Purpose | Audience |
|------|---------|----------|
| `README.md` | Main project documentation | All users |
| `QUICKREF.md` | Quick command reference | Users who need quick help |
| `CONTRIBUTING.md` | How to contribute | Contributors |
| `CHANGELOG.md` | Version history | Users tracking changes |
| `DEPLOYMENT_GUIDE.md` | How to deploy to GitHub | You (maintainer) |
| `PROJECT_SUMMARY.md` | Overview of all changes | You (maintainer) |

### Testing & CI/CD

| File | Purpose | When It Runs |
|------|---------|--------------|
| `.github/workflows/shellcheck.yml` | Automated script testing | Every push/PR |
| `test_installation.sh` | Manual testing script | After deployment |

## What to Upload to GitHub

### 1. Required Files (Must Upload)
```
✓ README.md (replace existing)
✓ CONTRIBUTING.md (new)
✓ CHANGELOG.md (new)
✓ QUICKREF.md (new)
✓ install.sh (new)
✓ 10-install_all.sh (replace 10-install_tools.sh)
✓ etc-vara (replace existing)
✓ fix_sources.sh (replace existing)
✓ .github/workflows/shellcheck.yml (new)
```

### 2. Optional Files (For Your Reference)
```
○ DEPLOYMENT_GUIDE.md (helps you deploy)
○ PROJECT_SUMMARY.md (explains changes)
○ test_installation.sh (tests after deployment)
```

### 3. Files to Delete from GitHub
```
✗ 10-install_tools.sh (renamed to 10-install_all.sh)
```

## Installation Flow

```
User runs:
curl -fsSL https://raw.githubusercontent.com/CowboyPilot/ETCR5_VARA_TOOLS/main/install.sh | bash

↓

install.sh downloads:
├── 10-install_all.sh → ~/add-ons/wine/
├── etc-vara → /opt/emcomm-tools/bin/ (with sudo)
└── fix_sources.sh → ~/

↓

User can then:
├── Run: cd ~/add-ons/wine && ./10-install_all.sh
├── Run: etc-vara (to launch applications)
└── Run: sudo ~/fix_sources.sh (if needed)
```

## GitHub Structure Best Practices

### Why This Organization?

1. **Root Directory**: Main scripts and documentation
   - Easy to find and access
   - Standard GitHub layout
   - README displays on repo homepage

2. **.github/** Directory: GitHub-specific files
   - Workflows for CI/CD
   - Issue templates (can add later)
   - Pull request templates (can add later)

3. **Documentation Files**: All in root
   - Easy to link in README
   - Accessible via GitHub web interface
   - Can be viewed without cloning

4. **No Deep Nesting**: Everything in root or .github/
   - Simpler to navigate
   - Easier to download individual files
   - Better for curl/wget commands

## Comparison: Old vs New Structure

### Before:
```
ETCR5_VARA_TOOLS/
├── README.md (basic)
├── 10-install_tools.sh
├── etc-vara
└── fix_sources.sh
```
**Issues**: 
- Manual download of each file
- Unclear installation process
- Limited documentation
- No automation

### After:
```
ETCR5_VARA_TOOLS/
├── .github/workflows/shellcheck.yml
├── README.md (comprehensive)
├── CONTRIBUTING.md
├── CHANGELOG.md
├── QUICKREF.md
├── install.sh (one-line installer!)
├── 10-install_all.sh
├── etc-vara
└── fix_sources.sh
```
**Benefits**:
- One-line installation
- Comprehensive documentation
- Automated testing
- Professional structure
- Easy contribution process

## Quick Deploy Checklist

```
Upload Order:

□ 1. Upload new documentation files
     └── README.md, CONTRIBUTING.md, CHANGELOG.md, QUICKREF.md

□ 2. Upload new install.sh script

□ 3. Upload/replace core scripts
     └── 10-install_all.sh, etc-vara, fix_sources.sh

□ 4. Create .github/workflows/ directory
     └── Upload shellcheck.yml

□ 5. Delete old 10-install_tools.sh

□ 6. Test with: curl -fsSL https://raw.githubusercontent.com/CowboyPilot/ETCR5_VARA_TOOLS/main/install.sh | bash

□ 7. Run test_installation.sh to verify all files are accessible

□ 8. Create a release (optional but recommended)
```

## Access Patterns

### Users Will Access:
1. **Main Entry Point**: README.md (via GitHub homepage)
2. **Installation**: install.sh (via curl command)
3. **Quick Help**: QUICKREF.md (when they need commands)
4. **Troubleshooting**: README.md (troubleshooting section)

### Contributors Will Access:
1. **How to Help**: CONTRIBUTING.md
2. **What Changed**: CHANGELOG.md
3. **Submit PRs**: Via GitHub interface
4. **See Test Results**: GitHub Actions tab

### You (Maintainer) Will Access:
1. **Upload Process**: DEPLOYMENT_GUIDE.md
2. **Project Overview**: PROJECT_SUMMARY.md
3. **Test Script**: test_installation.sh
4. **GitHub Actions**: To see build status

## Summary

This structure follows GitHub best practices and makes your repository:
- ✓ Easy to use (one-line install)
- ✓ Well documented (multiple docs)
- ✓ Professional (proper organization)
- ✓ Maintainable (clear structure)
- ✓ Collaborative (contribution guidelines)
- ✓ Tested (automated workflows)

73!
