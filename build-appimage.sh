#!/bin/bash

# Stop script if some part fail
set -euo pipefail

########################################################################
# Builds an appimage
# Usage: ./build-appimage.sh
#
########################################################################

# -------------------------
# Configuration
# -------------------------

# Application name
APP_NAME="opa"

# Root directory for the source code
ROOT_DIR="./opa4"

# Path to the .lpi file
LPI_FILE="$ROOT_DIR/opa.lpi" 

# Get the current architecture
ARCH="$(uname -m)"
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
PLATFORM="${ARCH}-${OS}"

# Where lazbuild places the binary.
# This is the build directory currently set in the Lazarus compile options
BUILD_DIR="$ROOT_DIR/lib/$PLATFORM" 

# Relative path to expected binary after build
BINARY_REL="${BUILD_DIR}/${APP_NAME}" 

# Path to Linuxdeploy
LINUXDEPLOY="./linuxdeploy-x86_64.AppImage"

if [[ "${ARCH}" == "aarch64" ]]; then
 LINUXDEPLOY="./linuxdeploy-aarch64.AppImage"
fi

# AppDir folder to create
APPDIR="${APP_NAME}.AppDir"

# Desktop file 
DESKTOP_FILE="${APP_NAME}.desktop"

# Icon file
ICON_FILE="$ROOT_DIR/${APP_NAME}.png"    

# Helper: print and run
run() { echo ">>> $*"; "$@"; }

# -------------
# Preconditions
# -------------

# Check so lazbuild exists on path
if ! command -v lazbuild >/dev/null 2>&1; then
  echo "ERROR: lazbuild not found in PATH. Install Lazarus or set PATH so lazbuild is available."
  exit 2
fi

# Check so linuxdeploy exists
if ! command -v $LINUXDEPLOY >/dev/null 2>&1; then
  echo "ERROR: linuxdeploy not found. Download it or set correct path."
  exit 3
fi

# -------------
# Build the application
# -------------

# Remove old build
rm -rf "${APPDIR}" squashfs-root *.AppImage

echo
echo "Building the application"
run lazbuild --widgetset=gtk2 --build-all "${LPI_FILE}"

# Check so the binary was created
if [[ ! -f "${BINARY_REL}" ]]; then
  echo "ERROR: Binary not found at expected path:"
  echo "  ${BINARY_REL}"
  exit 4
fi

echo "Binary found at ${BINARY_REL}"

# Make sure binary is executable
chmod +x "${BINARY_REL}"

# Build the appimage
# Some gtk libraries are excluded because they break the build
# Instead relies on the host
echo
echo "Running linuxdeploy to bundle libraries and build AppImage"
run "${LINUXDEPLOY}" \
  --appdir "${APPDIR}" \
  --executable "${BINARY_REL}" \
  --desktop-file "$DESKTOP_FILE" \
  --icon-file "$ICON_FILE" \
  --exclude-library 'libgtk-x11-2.0.so*' \
  --exclude-library 'libgdk-x11-2.0.so*' \
  --output appimage 