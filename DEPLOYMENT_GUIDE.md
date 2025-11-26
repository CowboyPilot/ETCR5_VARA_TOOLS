# Deployment Guide - Updating Your GitHub Repository

This guide will walk you through pushing all the new files to your GitHub repository.

## Files to Upload

All files are ready in this directory. Here's what you have:

### Main Files
- `README.md` - Comprehensive documentation
- `install.sh` - Main installation script
- `10-install_all.sh` - VARA/Winlink installer
- `etc-vara` - VARA launcher
- `fix_sources.sh` - APT repository fix

### Documentation
- `CONTRIBUTING.md` - Contribution guidelines
- `CHANGELOG.md` - Version history
- `QUICKREF.md` - Quick reference guide

### GitHub Configuration
- `.github/workflows/shellcheck.yml` - Automated testing workflow

## Option 1: Using Git Command Line

If you have your repository cloned locally:

```bash
# Navigate to your repository
cd /path/to/ETCR5_VARA_TOOLS

# Copy all new files (adjust path as needed)
cp /path/to/downloaded/files/* .
cp -r /path/to/downloaded/files/.github .

# Check what will be committed
git status

# Add all files
git add .

# Commit with a descriptive message
git commit -m "Add comprehensive installation script and documentation

- Add install.sh for one-line installation
- Improve README with detailed documentation and troubleshooting
- Add CONTRIBUTING.md and CHANGELOG.md
- Add QUICKREF.md for quick command reference
- Add GitHub Actions workflow for shellcheck
- Rename 10-install_tools.sh to 10-install_all.sh for clarity"

# Push to GitHub
git push origin main
```

## Option 2: Using GitHub Web Interface

If you prefer using GitHub's web interface:

### 1. Upload Main Files

1. Go to https://github.com/CowboyPilot/ETCR5_VARA_TOOLS
2. Click "Add file" → "Upload files"
3. Drag and drop these files:
   - `README.md` (replace existing)
   - `install.sh` (new)
   - `10-install_all.sh` (replaces 10-install_tools.sh)
   - `etc-vara` (replace existing)
   - `fix_sources.sh` (replace existing)
   - `CONTRIBUTING.md` (new)
   - `CHANGELOG.md` (new)
   - `QUICKREF.md` (new)
4. Add commit message: "Add installation script and improve documentation"
5. Click "Commit changes"

### 2. Delete Old File

1. Navigate to `10-install_tools.sh` in your repository
2. Click the trash icon to delete it
3. Commit the deletion

### 3. Add GitHub Workflow

1. In your repository, click "Add file" → "Create new file"
2. Name it: `.github/workflows/shellcheck.yml`
3. Copy and paste the contents from the provided `shellcheck.yml` file
4. Commit the new file

## Option 3: GitHub Desktop

If you use GitHub Desktop:

1. Open GitHub Desktop
2. Select your repository
3. Copy all new files to your repository folder
4. GitHub Desktop will show all changes
5. Write a commit message
6. Click "Commit to main"
7. Click "Push origin"

## Verification Steps

After uploading, verify everything is working:

1. **Check the README**: Visit your repository main page - the new README should display
2. **Test the installer**: Run the one-line install command to make sure it works
   ```bash
   curl -fsSL https://raw.githubusercontent.com/CowboyPilot/ETCR5_VARA_TOOLS/main/install.sh | bash
   ```
3. **Check Actions**: Go to the "Actions" tab to see if the shellcheck workflow runs
4. **Review Files**: Make sure all files are present in the repository

## Testing the Installation

After pushing to GitHub, test the installation on a clean system:

```bash
# Test one-line install
curl -fsSL https://raw.githubusercontent.com/CowboyPilot/ETCR5_VARA_TOOLS/main/install.sh | bash

# Verify files are in correct locations
ls -l ~/add-ons/wine/10-install_all.sh
ls -l /opt/emcomm-tools/bin/etc-vara
ls -l ~/fix_sources.sh
```

## Updating Documentation

If you need to make changes to the documentation later:

1. Edit the file locally or on GitHub
2. Commit the changes
3. The changes will be immediately visible to users

## Creating a Release

Once everything is tested and working:

1. Go to your repository on GitHub
2. Click "Releases" → "Draft a new release"
3. Tag version: `v1.1.0`
4. Release title: `v1.1.0 - Installation Script and Documentation`
5. Description: Copy relevant sections from CHANGELOG.md
6. Click "Publish release"

## Troubleshooting

### "Permission denied" when testing install script
- Make sure the script has correct permissions
- GitHub serves files with correct content-type

### Install script downloads but fails
- Check that all file paths in install.sh match your repository structure
- Verify the raw GitHub URLs are correct

### GitHub Actions workflow not running
- Make sure the file is in `.github/workflows/` directory
- Check the Actions tab for any errors
- Verify YAML syntax is correct

## Next Steps

After successful deployment:

1. Test the installation on a clean ETC R5 system
2. Share the repository with the community
3. Monitor for issues and feedback
4. Update documentation as needed

## Support

If you run into issues:
- Check the GitHub Actions logs for errors
- Verify all files are committed
- Test the raw file URLs in a browser
- Review git status for uncommitted changes

Good luck with your deployment! 73!
