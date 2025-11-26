# VARA Auto-Download Feature

## Overview

The `10-install_all.sh` script now includes automatic download capability for VARA HF and VARA FM installers. If these installers are not found locally, the script will automatically download the latest versions from the official Winlink server.

## How It Works

### Download Logic

1. **Check Local Files First**: The script searches for VARA installers in:
   - `~/add-ons/wine/` (script directory)
   - `~/Downloads/`

2. **Auto-Download If Not Found**: If no installer is found locally:
   - Fetches the Winlink VARA Products index page
   - Parses the HTML to find the latest installer
   - Downloads to the script directory
   - Proceeds with installation

3. **Fallback**: If auto-download fails:
   - Displays clear error message
   - Provides manual download instructions
   - Allows user to download and re-run

### Download Patterns

- **VARA HF**: Searches for files matching `VARA setup` pattern
- **VARA FM**: Searches for files matching `VARAFM` pattern

## Source Integration

This feature is based on the `vara-downloader.sh` script by Gaston Gonzalez, integrated directly into the installer for a seamless user experience.

### Key Improvements Over Standalone Script

1. **Integrated Flow**: No separate download step required
2. **Automatic Retry**: Can re-run installer after manual download
3. **Better Error Handling**: Clear messages about what to do if download fails
4. **No Extra Dependencies**: Works with standard tools (curl, grep)

## Requirements

### Essential
- `curl` - For downloading files

### Optional (Improved Parsing)
- `pup` - Better HTML parsing (falls back to grep if not available)

The script works without `pup`, but having it installed provides more reliable HTML parsing.

## User Experience

### Before (Manual Download)
```
1. User runs installer
2. Installer says "VARA not found, download it"
3. User goes to Winlink website
4. User finds and downloads VARA
5. User re-runs installer
```

### After (Auto-Download)
```
1. User runs installer
2. Installer says "VARA not found, downloading..."
3. Installer downloads latest version automatically
4. Installer proceeds with installation
```

## Error Handling

The auto-download feature handles several scenarios:

### Network Issues
```
[!] Failed to fetch VARA download page
    Please manually download...
```

### Pattern Not Found
```
[!] Could not find VARA HF installer matching pattern: VARA setup
    Please manually download...
```

### Download Failure
```
[!] Failed to download VARA HF installer
    Please manually download the VARA HF installer and save it in:
      - ~/add-ons/wine
      - or ~/Downloads
    Then re-run this script.
```

## Technical Details

### Download Function

```bash
download_vara_installer() {
  local pattern="$1"  # Pattern to match
  local mode="$2"     # "HF" or "FM"
  
  # Fetch index page
  curl -s -f -L -o "${tmp_html}" "${index_url}"
  
  # Parse HTML (with fallback)
  if command -v pup >/dev/null 2>&1; then
    vara_file_path=$(pup 'a attr{href}' < "${tmp_html}" | grep -i "${pattern}" | head -n 1)
  else
    vara_file_path=$(grep -oP 'href="\K[^"]*' "${tmp_html}" | grep -i "${pattern}" | head -n 1)
  fi
  
  # Download file
  curl -s -f -L -o "${dest_file}" "${full_url}"
}
```

### Integration Points

The download function is called in two places:

1. **VARA HF Installation** (Line ~420)
2. **VARA FM Installation** (Line ~470)

Each follows the same pattern:
```bash
# Try to find locally
if VARA_HF_INSTALLER=$(find_vara_hf_installer); then
  echo "Found locally"
else
  # Try to download
  if VARA_HF_INSTALLER=$(download_vara_installer "VARA setup" "HF"); then
    echo "Downloaded successfully"
  else
    echo "Please download manually"
  fi
fi
```

## Benefits

### For Users
- **No Extra Steps**: VARA downloads automatically
- **Always Latest**: Gets current version from Winlink
- **Less Confusion**: No hunting for download links
- **Still Flexible**: Can provide installers manually if preferred

### For Support
- **Fewer Questions**: "Where do I download VARA?" answered automatically
- **Consistent Versions**: Everyone gets latest from official source
- **Better Logs**: Clear messages about what happened

### For Maintainability
- **Single Script**: No separate download utility to maintain
- **Graceful Degradation**: Works even if download fails
- **No Breaking Changes**: Existing manual workflow still works

## Testing

To test the auto-download feature:

### Test Auto-Download
```bash
cd ~/add-ons/wine
# Remove any existing VARA installers
rm -f VARA*.exe VaraFM*.exe
# Run installer
./10-install_all.sh
# Should download automatically
```

### Test Manual Fallback
```bash
# Simulate network issue by blocking downloads.winlink.org
# Or just try with no internet connection
./10-install_all.sh
# Should show manual download instructions
```

### Test Local Files
```bash
# Place VARA installers in directory
cp /path/to/VARAsetup.exe ~/add-ons/wine/
./10-install_all.sh
# Should use local file, not download
```

## Future Enhancements

Potential improvements for future versions:

1. **VarAC Auto-Download**: Extend to VarAC installer (currently requires manual download)
2. **Version Selection**: Option to download specific VARA version
3. **Checksum Verification**: Verify downloaded file integrity
4. **Download Progress**: Show progress bar for large downloads
5. **Retry Logic**: Automatic retry on transient failures

## Troubleshooting

### "curl not found"
Install curl:
```bash
sudo apt update
sudo apt install curl
```

### "Failed to fetch VARA download page"
Check internet connection and try:
```bash
curl https://downloads.winlink.org/VARA%20Products/
```

### "Could not find VARA installer matching pattern"
The Winlink page structure may have changed. Download manually from:
https://downloads.winlink.org/VARA%20Products/

### Downloaded File Won't Run
- Verify the download completed (check file size)
- Try downloading manually
- Check Wine is properly configured

## Credits

Auto-download logic based on `vara-downloader.sh` by Gaston Gonzalez (February 28, 2025), integrated and enhanced for the ETC R5 VARA Tools installer.

## See Also

- [README.md](README.md) - Main documentation
- [QUICKREF.md](QUICKREF.md) - Quick reference guide
- Original vara-downloader.sh - Standalone download utility

73!
