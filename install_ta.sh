#!/usr/bin/env bash
#
# install_ta_lib.sh — local-or-remote install of TA-Lib .deb package
#
# Works both as root and as normal user (if sudo is available).
# Tested on Ubuntu 22.04+, Debian 12.
#
# Usage:
#   ./install_ta_lib.sh                          # defaults to 0.6.4
#   TA_LIB_VERSION=0.6.2 ./install_ta_lib.sh     # different version
#   TA_URL="https://…/custom.deb" ./install_ta_lib.sh    # custom URL
#
set -euo pipefail

# ------------------------------ constants --------------------------------- #
DEFAULT_VER="0.6.4"
TA_LIB_VERSION="${TA_LIB_VERSION:-$DEFAULT_VER}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
LOCAL_DEB="${SCRIPT_DIR}/releases/ta-lib_${TA_LIB_VERSION}_amd64.deb"

DEFAULT_URL="https://raw.githubusercontent.com/zcoder/ta-lib/build_talib_${TA_LIB_VERSION}/releases/ta-lib_${TA_LIB_VERSION}_amd64.deb"
DEB_URL="${TA_URL:-$DEFAULT_URL}"

TMP_DIR="$(mktemp -d)"
PKG_PATH="${TMP_DIR}/ta-lib.deb"

log() { printf "\e[1;34m[TA-Lib installer]\e[0m %s\n" "$*"; }

# ------------------------- privilege handling ----------------------------- #
if [[ "$(id -u)" -eq 0 ]]; then
  SUDO=""
elif command -v sudo >/dev/null 2>&1; then
  SUDO="sudo"
else
  echo "Error: need root privileges or sudo to install packages." >&2
  exit 1
fi

# --------------------------- prerequisites -------------------------------- #
for cmd in dpkg apt-get; do
  command -v "$cmd" >/dev/null || {
    echo "Error: '$cmd' not found. Are you on a Debian/Ubuntu system?" >&2
    exit 1
  }
done

if command -v curl >/dev/null; then
  DL="curl -fL --retry 3 -o"
elif command -v wget >/dev/null; then
  DL="wget -qO"
else
  echo "Error: neither curl nor wget is installed." >&2
  exit 1
fi

# ------------------------- local-first install ---------------------------- #
if [[ -f "$LOCAL_DEB" ]]; then
  log "Found local package → ${LOCAL_DEB}"
  PKG_PATH="$LOCAL_DEB"
else
  log "No local package. Downloading from ${DEB_URL}"
  $DL "$PKG_PATH" "$DEB_URL"
fi

# --------------------------- installation --------------------------------- #
log "Installing package..."
$SUDO dpkg -i "$PKG_PATH" || {
  log "Resolving missing dependencies (apt-get -f install)"
  $SUDO apt-get -y -qq update
  $SUDO apt-get -y -qq install -f
}

# Clean temporary artefacts only if we downloaded the file
[[ "$PKG_PATH" == "$TMP_DIR/"* ]] && rm -rf "$TMP_DIR"

log "TA-Lib ${TA_LIB_VERSION} successfully installed 🎉"

