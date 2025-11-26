#!/bin/bash
# 10-install_vara_winlink.sh
#
# Installs into a dedicated 32-bit Wine prefix:
#   - Winlink Express
#   - VarAC (VARA Chat)  (if VarAC_Installer*.exe is present)
#   - VARA HF
#   - VARA FM
#
# Wine prefix used:
#   ~/.wine32
#
# GNOME menu entries placed under:
#   Applications → Ham Radio
#
# Rerunnable:
#   - If prefix exists → reused
#   - If Winlink present → skipped
#   - If VARA HF/FM present → skipped
#   - VarAC can be added later by rerunning the script
#

set -euo pipefail

PREFIX="${HOME}/.wine32"
WINLINK_ZIP_URL="https://downloads.winlink.org/User%20Programs/Winlink_Express_install_1-7-28-0.zip"
WINLINK_ZIP_FILE="Winlink_Express.zip"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

echo
echo "============================================================="
echo "   Installer: Winlink + VarAC + VARA HF/FM"
echo "             Wine prefix: ${PREFIX}"
echo "============================================================="
echo

if [[ "${EUID}" -eq 0 ]]; then
  echo "ERROR: Do NOT run this script as root."
  exit 1
fi

for cmd in wine wineboot winetricks wget unzip curl; do
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "ERROR: Required command '${cmd}' is missing."
    echo "       Please install '${cmd}' and rerun."
    exit 1
  fi
done

if [[ -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" ]]; then
  echo "ERROR: Must run from a graphical desktop session."
  exit 1
fi

# -------------------------------------------------------------
#   Helpers to patch shell env files for WINEARCH=win32 + ~/.wine32
# -------------------------------------------------------------
patch_shell_env_file() {
  local f="$1"
  [[ -f "$f" ]] || return 0

  echo "  - Patching $f"

  # Backup first
  cp "$f" "${f}.bak_etwine_$(date +%s)" 2>/dev/null || true

  # Normalize WINEARCH win64 -> win32 in common forms
  sed -i -E 's/export[[:space:]]+WINEARCH="win64"/export WINEARCH="win32"/' "$f"
  sed -i -E 's/export[[:space:]]+WINEARCH=win64/export WINEARCH=win32/' "$f"
  sed -i -E 's/WINEARCH="win64"/WINEARCH="win32"/' "$f"
  sed -i -E 's/WINEARCH=win64/WINEARCH=win32/' "$f"

  # If anyone hardcoded .wine, bump it to .wine32
  sed -i -E 's|\$HOME/\.wine"|$HOME/.wine32"|' "$f" || true
  sed -i -E 's|\$HOME/\.wine\b|$HOME/.wine32|' "$f" || true
}

patch_common_checks() {
  local f="/opt/emcomm-tools/bin/common_checks.sh"
  [[ -f "$f" ]] || return 0

  echo "  - Patching $f"
  cp "$f" "${f}.bak_etwine_$(date +%s)" 2>/dev/null || true

  sed -i -E \
    -e 's/export[[:space:]]+WINEARCH="win64"/export WINEARCH="win32"/g' \
    -e 's/export[[:space:]]+WINEARCH=win64/export WINEARCH=win32/g' \
    -e 's/WINEARCH="win64"/WINEARCH="win32"/g' \
    -e 's/WINEARCH=win64/WINEARCH=win32/g' \
    -e 's/\.wine\b/.wine32/g' \
    "$f"
}

# -------------------------------------------------------------
#   Gate on current WINEARCH
# -------------------------------------------------------------
CURRENT_WA="${WINEARCH:-}"

if [[ "${CURRENT_WA}" != "win32" ]]; then
  echo
  echo "-------------------------------------------------------------"
  echo "  WINEARCH IS NOT SET TO win32 IN THIS SESSION"
  echo "-------------------------------------------------------------"
  echo "  Detected WINEARCH: '${CURRENT_WA:-<unset>}'"
  echo
  echo "  To safely use a 32-bit prefix at ~/.wine32, we need to:"
  echo "    - Update your shell init files to use WINEARCH=\"win32\""
  echo "    - Update EmComm Tools common_checks.sh to use .wine32"
  echo

  echo "[*] Patching shell init files for 32-bit Wine + ~/.wine32 ..."
  patch_shell_env_file "${HOME}/.bash_profile"
  patch_shell_env_file "${HOME}/.bashrc"
  patch_shell_env_file "${HOME}/.profile"

  echo "[*] Patching EmComm Tools common_checks.sh if present ..."
  patch_common_checks

  echo
  echo "============================================================="
  echo "  ENVIRONMENT UPDATED FOR 32-BIT WINE (~/.wine32)"
  echo "============================================================="
  echo "Next steps:"
  echo "  1) Log out of your desktop session (or SSH session) completely."
  echo "  2) Log back in, so the new WINEARCH=win32 takes effect."
  echo "  3) Re-run this installer:"
  echo "       ${SCRIPT_DIR}/10-install_vara_winlink.sh"
  echo
  echo "After your next login, 'echo \$WINEARCH' should output: win32"
  echo "Only then will this script continue with installation."
  echo
  exit 0
fi

# If we get here, WINEARCH is already win32 for this shell
export WINEARCH="win32"
export WINEPREFIX="${PREFIX}"

echo
echo "[*] WINEARCH is '${WINEARCH}', proceeding with installation."
echo "    WINEPREFIX = ${WINEPREFIX}"

# -------------------------------------------------------------
#   CLEAN UP OLD / AUTO-GENERATED SHORTCUTS
# -------------------------------------------------------------
echo
echo "[*] Cleaning stale Wine application shortcuts..."
rm -rf "${HOME}/.local/share/applications/wine" 2>/dev/null || true
rm -f "${HOME}"/.local/share/applications/*Winlink*.desktop 2>/dev/null || true
rm -f "${HOME}"/.local/share/applications/*RMS*Express*.desktop 2>/dev/null || true
rm -f "${HOME}"/.local/share/applications/*VarAC*.desktop 2>/dev/null || true
update-desktop-database "${HOME}/.local/share/applications" 2>/dev/null || true
xdg-desktop-menu forceupdate 2>/dev/null || true
echo "[*] Old Wine shortcuts removed."

# -------------------------------------------------------------
#   Helper functions (installers, wrappers, pdh.dll, etc.)
# -------------------------------------------------------------

find_varac_installer() {
  local dirs=("${SCRIPT_DIR}" "${HOME}/Downloads")
  for dir in "${dirs[@]}"; do
    local files
    files=$(ls -1 "${dir}/VarAC_Installer"*.exe 2>/dev/null | sort -r || true)
    if [[ -n "${files}" ]]; then
      echo "${files}" | head -n 1
      return 0
    fi
  done
  return 1
}

# VARA HF installer: prefer names containing "VARA" but NOT "FM"
find_vara_hf_installer() {
  local dirs=("${SCRIPT_DIR}" "${HOME}/Downloads")
  for dir in "${dirs[@]}"; do
    local files
    files=$(ls -1 "${dir}"/VARA*.exe 2>/dev/null | grep -iv "fm" || true)
    if [[ -n "${files}" ]]; then
      echo "${files}" | head -n 1
      return 0
    fi
  done
  return 1
}

# VARA FM installer: names with "FM"
find_vara_fm_installer() {
  local dirs=("${SCRIPT_DIR}" "${HOME}/Downloads")
  for dir in "${dirs[@]}"; do
    local files
    files=$(ls -1 "${dir}"/VARA*FM*.exe "${dir}"/VaraFM*.exe 2>/dev/null || true)
    if [[ -n "${files}" ]]; then
      echo "${files}" | head -n 1
      return 0
    fi
  done
  return 1
}

# Helper: create vara.cmd wrapper next to modem EXE
create_vara_wrapper_cmd() {
  local exe_path="$1"   # full Unix path to VARA.exe / VaraFM.exe
  local mode="$2"       # "HF" or "FM"

  [[ -f "${exe_path}" ]] || return 0

  local exe_dir exe_base cmd_path win_cd_path
  exe_dir="$(dirname "${exe_path}")"
  exe_base="$(basename "${exe_path}")"

  cmd_path="${exe_dir}/vara.cmd"

  # Windows path for cd /d line (convert PREFIX/drive_c/... → C:\...)
  local rel="${exe_dir#${PREFIX}/drive_c/}"
  rel="${rel//\//\\}"
  win_cd_path="C:\\${rel}"

  cat > "${cmd_path}" <<EOF
@echo off
cd /d "${win_cd_path}"
start "" "${exe_base}"
EOF

  echo "[*] Created VARA ${mode} wrapper: ${cmd_path}"
}

# Helper: convert absolute Unix path under drive_c to Windows path
to_windows_path() {
  local abs="$1"
  local rel="${abs#${PREFIX}/drive_c/}"
  rel="${rel//\//\\\\}"
  echo "C:\\\\${rel}"
}

# Helper: fix pdh.dll requirement by pulling nt4pdhdll.exe into VARA dir
fix_pdh_dll_for_vara_dir() {
  local vara_dir="$1"

  [[ -d "${vara_dir}" ]] || return 0

  if [[ ! -e "${vara_dir}/nt4pdhdll.exe" ]]; then
    echo "[*] VARA directory '${vara_dir}' missing nt4pdhdll.exe, installing pdh.dll bundle..."
    local CWD
    CWD="$(pwd)"
    cd "${vara_dir}"
    curl -s -f -L -O \
      "http://download.microsoft.com/download/winntsrv40/update/5.0.2195.2668/nt4/en-us/nt4pdhdll.exe" && \
      unzip -o nt4pdhdll.exe >/dev/null 2>&1 || {
        echo "[!] Failed to download or unzip nt4pdhdll.exe in ${vara_dir}"
      }
    cd "${CWD}"
  else
    echo "[*] nt4pdhdll.exe already present in '${vara_dir}', skipping pdh.dll fix."
  fi
}

# -------------------------------------------------------------
#   Step 1: Create or reuse Wine prefix (~/.wine32)
# -------------------------------------------------------------
NEW_PREFIX=0

if [[ -d "${PREFIX}" ]]; then
  echo "[*] Reusing existing prefix: ${PREFIX}"
  if ! grep -q "#arch=win32" "${PREFIX}/system.reg" 2>/dev/null; then
    echo "ERROR: Existing prefix is NOT 32-bit (missing #arch=win32)."
    echo "       Please remove '${PREFIX}' or migrate data manually, then rerun."
    exit 1
  fi
else
  NEW_PREFIX=1
  echo "[*] Creating NEW 32-bit Wine prefix at ${PREFIX}..."
  WINEARCH=win32 WINEPREFIX="${PREFIX}" wineboot -u
  sleep 2
  WINEARCH=win32 WINEPREFIX="${PREFIX}" wineboot -u
  unset WINEARCH
fi

# -------------------------------------------------------------
#   Step 2: Install dependencies for new prefix
# -------------------------------------------------------------
if [[ "${NEW_PREFIX}" -eq 1 ]]; then
  echo
  echo "[*] Installing Wine dependencies via winetricks..."
  echo "    winxp, sound=alsa, dotnet35sp1, vb6run,"
  echo "    vcrun2015, dotnet40, dotnet46, corefonts,"
  echo "    tahoma, gdiplus, msxml6"
  echo

  DEPS=(winxp sound=alsa dotnet35sp1 vb6run vcrun2015 dotnet40 dotnet46 corefonts tahoma gdiplus msxml6)

  for dep in "${DEPS[@]}"; do
    echo "  -> winetricks ${dep}"
    set +e
    env -u WINEARCH WINEPREFIX="${PREFIX}" winetricks -q ${dep}
    STATUS=$?
    set -e
    if [[ ${STATUS} -ne 0 ]]; then
      echo "WARNING: winetricks ${dep} returned ${STATUS}. Continuing..."
    fi
  done

  echo
  echo "[*] Disabling Windows spooler service in prefix to avoid print crashes..."
  env -u WINEARCH WINEPREFIX="${PREFIX}" wine reg add \
    "HKLM\\System\\CurrentControlSet\\Services\\Spooler" \
    /v Start /t REG_DWORD /d 4 /f >/dev/null 2>&1 || true
fi

# -------------------------------------------------------------
#   Step 3: Install Winlink Express
# -------------------------------------------------------------
WINLINK_PATH_ON_DISK=$(find "${PREFIX}/drive_c" -maxdepth 6 -iname "RMS Express.exe" | head -n 1 || true)

if [[ -n "${WINLINK_PATH_ON_DISK}" ]]; then
  echo
  echo "[*] Winlink Express already installed at:"
  echo "    ${WINLINK_PATH_ON_DISK}"
else
  echo
  echo "============================================================="
  echo "                 Installing Winlink Express"
  echo "============================================================="

  if [[ ! -f "${WINLINK_ZIP_FILE}" ]]; then
    echo "[*] Downloading Winlink Express ZIP..."
    wget -O "${WINLINK_ZIP_FILE}" "${WINLINK_ZIP_URL}"
  else
    echo "[*] Using existing ${WINLINK_ZIP_FILE}"
  fi

  echo "[*] Extracting ${WINLINK_ZIP_FILE}..."
  unzip -o "${WINLINK_ZIP_FILE}"

  WINLINK_INSTALLER=""
  for f in Winlink_Express_install*.exe RMS_Express_install*.exe; do
    if [[ -f "$f" ]]; then
      WINLINK_INSTALLER="$f"
      break
    fi
  done

  if [[ -z "${WINLINK_INSTALLER}" ]]; then
    echo "ERROR: No Winlink Express installer found in current directory."
    echo "       Expected names like Winlink_Express_install_*.exe"
    exit 1
  fi

  echo "[*] Running Winlink Express installer: ${WINLINK_INSTALLER}"
  env -u WINEARCH WINEPREFIX="${PREFIX}" wine "${WINLINK_INSTALLER}"

  WINLINK_PATH_ON_DISK=$(find "${PREFIX}/drive_c" -maxdepth 6 -iname "RMS Express.exe" | head -n 1 || true)
  if [[ -z "${WINLINK_PATH_ON_DISK}" ]]; then
    echo "WARNING: Winlink installer ran but RMS Express.exe not found."
  else
    echo "[*] Winlink Express installed at:"
    echo "    ${WINLINK_PATH_ON_DISK}"
  fi
fi

# -------------------------------------------------------------
#   Step 4: Install VarAC
# -------------------------------------------------------------
VARAC_PATH_ON_DISK=$(find "${PREFIX}/drive_c" -maxdepth 6 -iname "VarAC.exe" | head -n 1 || true)

if [[ -n "${VARAC_PATH_ON_DISK}" ]]; then
  echo
  echo "[*] VarAC already installed at:"
  echo "    ${VARAC_PATH_ON_DISK}"
else
  echo
  echo "============================================================="
  echo "                 Checking for VarAC installer"
  echo "============================================================="

  VARAC_INSTALLER=""
  if VARAC_INSTALLER=$(find_varac_installer); then
    echo "[*] Found VarAC installer:"
    echo "    ${VARAC_INSTALLER}"
    echo "[*] Running VarAC installer..."
    env -u WINEARCH WINEPREFIX="${PREFIX}" wine "${VARAC_INSTALLER}"
    VARAC_PATH_ON_DISK=$(find "${PREFIX}/drive_c" -maxdepth 6 -iname "VarAC.exe" | head -n 1 || true)
    echo "[*] VarAC installation finished."
  else
    echo "[!] VarAC installer NOT found."
    echo "    Download the WINDOWS installer from:"
    echo "      https://www.varac-hamradio.com/download"
    echo "    Save it as VarAC_Installer_*.exe in:"
    echo "      - ${SCRIPT_DIR}"
    echo "      - or ${HOME}/Downloads"
    echo
    read -r -p "Continue WITHOUT installing VarAC? (y/N) " ANS
    ANS=${ANS:-N}
    if [[ ! "${ANS}" =~ ^[Yy]$ ]]; then
      echo "Please download VarAC_Installer_*.exe and rerun this script."
      exit 1
    else
      echo "[*] Skipping VarAC installation."
    fi
  fi
fi

# -------------------------------------------------------------
#   Step 5: Install VARA HF / VARA FM + pdh.dll fix
# -------------------------------------------------------------
echo
echo "============================================================="
echo "                 Installing VARA HF / VARA FM"
echo "============================================================="

VARA_HF_EXE=$(find "${PREFIX}/drive_c" -maxdepth 6 -iname "VARA.exe" | head -n 1 || true)
VARA_FM_EXE=$(find "${PREFIX}/drive_c" -maxdepth 6 -iname "VaraFM.exe" | head -n 1 || true)

# --- VARA HF ---
if [[ -n "${VARA_HF_EXE}" ]]; then
  echo "[*] VARA HF already installed at:"
  echo "    ${VARA_HF_EXE}"
else
  VARA_HF_INSTALLER=""
  if VARA_HF_INSTALLER=$(find_vara_hf_installer); then
    echo "[*] Found VARA HF installer:"
    echo "    ${VARA_HF_INSTALLER}"
    echo "[*] Running VARA HF installer..."
    env -u WINEARCH WINEPREFIX="${PREFIX}" wine "${VARA_HF_INSTALLER}"
    VARA_HF_EXE=$(find "${PREFIX}/drive_c" -maxdepth 6 -iname "VARA.exe" | head -n 1 || true)
    if [[ -n "${VARA_HF_EXE}" ]]; then
      echo "[*] VARA HF installed at:"
      echo "    ${VARA_HF_EXE}"
    else
      echo "WARNING: VARA HF installer ran but VARA.exe not found."
    fi
  else
    echo "[!] VARA HF installer NOT found."
    echo "    Download the VARA HF installer (e.g. VARAsetup.exe) and save it in:"
    echo "      - ${SCRIPT_DIR}"
    echo "      - or ${HOME}/Downloads"
  fi
fi

# --- VARA FM ---
if [[ -n "${VARA_FM_EXE}" ]]; then
  echo "[*] VARA FM already installed at:"
  echo "    ${VARA_FM_EXE}"
else
  VARA_FM_INSTALLER=""
  if VARA_FM_INSTALLER=$(find_vara_fm_installer); then
    echo "[*] Found VARA FM installer:"
    echo "    ${VARA_FM_INSTALLER}"
    echo "[*] Running VARA FM installer..."
    env -u WINEARCH WINEPREFIX="${PREFIX}" wine "${VARA_FM_INSTALLER}"
    VARA_FM_EXE=$(find "${PREFIX}/drive_c" -maxdepth 6 -iname "VaraFM.exe" | head -n 1 || true)
    if [[ -n "${VARA_FM_EXE}" ]]; then
      echo "[*] VARA FM installed at:"
      echo "    ${VARA_FM_EXE}"
    else
      echo "WARNING: VARA FM installer ran but VaraFM.exe not found."
    fi
  else
    echo "[!] VARA FM installer NOT found."
    echo "    Download the VARA FM installer (e.g. VARAFMsetup.exe) and save it in:"
    echo "      - ${SCRIPT_DIR}"
    echo "      - or ${HOME}/Downloads"
  fi
fi

# Create vara.cmd wrappers if EXEs were found
if [[ -n "${VARA_HF_EXE}" ]]; then
  create_vara_wrapper_cmd "${VARA_HF_EXE}" "HF"
fi
if [[ -n "${VARA_FM_EXE}" ]]; then
  create_vara_wrapper_cmd "${VARA_FM_EXE}" "FM"
fi

# Apply pdh.dll fix (nt4pdhdll.exe) to both VARA dirs if present
if [[ -n "${VARA_HF_EXE}" ]]; then
  fix_pdh_dll_for_vara_dir "$(dirname "${VARA_HF_EXE}")"
fi
if [[ -n "${VARA_FM_EXE}" ]]; then
  fix_pdh_dll_for_vara_dir "$(dirname "${VARA_FM_EXE}")"
fi

# -------------------------------------------------------------
#   Step 6: Wine graphics / font / focus tweaks
# -------------------------------------------------------------
echo
echo "============================================================="
echo "           Applying Wine graphics / font / focus tweaks"
echo "============================================================="

cat > /tmp/vara_fix.reg << 'EOF'
[HKEY_CURRENT_USER\Software\Wine\X11 Driver]
"ClientSideGraphics"="N"
"ClientSideWithRender"="N"
"UseXIM"="N"

[HKEY_CURRENT_USER\Software\Wine\Direct3D]
"renderer"="gdi"
"MaxVersionGL"=dword:00030002

; Try to reduce focus stealing / flashing by matching a conservative Windows desktop config
[HKEY_CURRENT_USER\Control Panel\Desktop]
"ForegroundLockTimeout"=dword:00030d40
"ForegroundFlashCount"=dword:00000001
"MenuShowDelay"="400"
EOF

env -u WINEARCH WINEPREFIX="${PREFIX}" wine regedit /tmp/vara_fix.reg >/dev/null 2>&1 || true
rm -f /tmp/vara_fix.reg

# Disable winemenubuilder to avoid random menu entries / interference
env -u WINEARCH WINEPREFIX="${PREFIX}" wine reg add \
  "HKCU\\Software\\Wine" \
  /v "EnableMenuBuilder" /t REG_SZ /d "N" /f >/dev/null 2>&1 || true

echo "[*] Wine tweaks applied."

# -------------------------------------------------------------
#   Step 7: COM10 → /dev/et-cat
# -------------------------------------------------------------
echo
echo "============================================================="
echo "              Mapping COM10 → /dev/et-cat"
echo "============================================================="

mkdir -p "${PREFIX}/dosdevices"
ln -sf "/dev/et-cat" "${PREFIX}/dosdevices/com10" 2>/dev/null || true

env -u WINEARCH WINEPREFIX="${PREFIX}" wine reg add \
  "HKLM\\Software\\Wine\\Ports" \
  /v COM10 /t REG_SZ /d "/dev/et-cat" /f >/dev/null 2>&1 || true

echo "[*] COM10 mapped to /dev/et-cat (symlink + registry)."

# -------------------------------------------------------------
#   Step 8: GNOME launchers (Winlink + VarAC only)
# -------------------------------------------------------------
echo
echo "============================================================="
echo "               Creating GNOME Ham Radio Launchers"
echo "============================================================="

APP_DIR_TOP="${HOME}/.local/share/applications"
mkdir -p "${APP_DIR_TOP}"

# Helper: grab Icon= from a Wine-generated .desktop if possible
get_wine_icon() {
  local pattern="$1"
  local wine_apps="${HOME}/.local/share/applications/wine"
  local src
  src=$(find "${wine_apps}" -type f -iname "${pattern}" 2>/dev/null | head -n 1 || true)
  if [[ -n "${src}" ]]; then
    local icon_line
    icon_line=$(grep '^Icon=' "${src}" 2>/dev/null || true)
    if [[ -n "${icon_line}" ]]; then
      echo "${icon_line#Icon=}"
      return 0
    fi
  fi
  echo "wine"
}

# ---- Winlink Express ----
WINLINK_EXE="${WINLINK_PATH_ON_DISK:-$(find "${PREFIX}/drive_c" -maxdepth 6 -iname 'RMS Express.exe' | head -n 1 || true)}"
WINLINK_DIR="${PREFIX}/drive_c"
WINLINK_WIN="C:\\\\RMS Express\\\\RMS Express.exe"

if [[ -n "${WINLINK_EXE}" ]]; then
  WINLINK_DIR="$(dirname "${WINLINK_EXE}")"
  WINLINK_WIN="$(to_windows_path "${WINLINK_EXE}")"
fi

WINLINK_ICON=$(get_wine_icon "*Winlink*Express*.desktop")
cat > "${APP_DIR_TOP}/winlink-express-wle.desktop" <<EOF
[Desktop Entry]
Name=Winlink Express (WLE)
Exec=env -u WINEARCH WINEPREFIX="${PREFIX}" wine-stable "${WINLINK_WIN}"
Type=Application
StartupNotify=true
Path=${WINLINK_DIR}
Icon=${WINLINK_ICON}
Categories=Network;HamRadio;Application;
EOF

# ---- VarAC (only if installed) ----
VARAC_EXE="${VARAC_PATH_ON_DISK:-$(find "${PREFIX}/drive_c" -maxdepth 6 -iname 'VarAC.exe' | head -n 1 || true)}"
if [[ -n "${VARAC_EXE}" ]]; then
  VARAC_DIR="$(dirname "${VARAC_EXE}")"
  VARAC_WIN="$(to_windows_path "${VARAC_EXE}")"
  VARAC_ICON=$(get_wine_icon "VarAC*.desktop")
  cat > "${APP_DIR_TOP}/varac.desktop" <<EOF
[Desktop Entry]
Name=VarAC (Chat)
Exec=env -u WINEARCH WINEPREFIX="${PREFIX}" wine-stable "${VARAC_WIN}"
Type=Application
StartupNotify=true
Path=${VARAC_DIR}
Icon=${VARAC_ICON}
Categories=Network;HamRadio;Application;
EOF
fi

# Fallback: if wine-stable isn’t present, use wine
if ! command -v wine-stable >/dev/null 2>&1; then
  sed -i 's/wine-stable/wine/' \
    "${APP_DIR_TOP}/winlink-express-wle.desktop" 2>/dev/null || true
  if [[ -f "${APP_DIR_TOP}/varac.desktop" ]]; then
    sed -i 's/wine-stable/wine/' "${APP_DIR_TOP}/varac.desktop" 2>/dev/null || true
  fi
fi

update-desktop-database "${APP_DIR_TOP}" 2>/dev/null || true
xdg-desktop-menu forceupdate 2>/dev/null || true

echo
echo "============================================================="
echo "   Winlink + VarAC + VARA HF/FM installation COMPLETE"
echo "============================================================="
echo "Launchers should appear under:  Applications → Ham Radio"
echo
echo "Wine prefix: ${PREFIX}"
echo
echo "Manual run examples:"
echo '  env -u WINEARCH WINEPREFIX=$HOME/.wine32 wine "C:\RMS Express\RMS Express.exe"'
if [[ -n "${VARAC_EXE}" ]]; then
  echo '  env -u WINEARCH WINEPREFIX=$HOME/.wine32 wine "C:\VarAC\VarAC.exe"'
fi
echo
echo "VARA HF/FM EXEs (if installed):"
[[ -n "${VARA_HF_EXE}" ]] && echo "  HF: ${VARA_HF_EXE}"
[[ -n "${VARA_FM_EXE}" ]] && echo "  FM: ${VARA_FM_EXE}"
echo
echo "IMPORTANT:"
echo "  - First run: this script may only patch your env and exit."
echo "    After logging out and back in, rerun to complete installs."
echo "  - Winlink, VarAC, and VARA all share the 32-bit prefix ~/.wine32."
echo "  - pdh.dll (via nt4pdhdll.exe) has been installed into VARA dirs"
echo "    when possible to avoid the pdh.dll missing error."
echo
