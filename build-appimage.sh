#!/bin/bash

# Stop script if some part fail
set -euo pipefail

########################################################################
# Builds an appimage
# Usage: ./build-appimage.sh
#
########################################################################

## -------------------------
## CONFIG
## -------------------------

APP_NAME="opa" # Application name
ROOT_DIR="opa4" # Root directory for the source code
LPI_FILE="$ROOT_DIR/opa.lpi" # Path to the .lpi file

# Get the current architecture
ARCH="$(uname -m)"
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
PLATFORM="${ARCH}-${OS}"

# Lazarus build
BUILD_DIR="$ROOT_DIR/lib/$PLATFORM" # Where lazbuild places the binary.
#This is the build directory currently set in the Lazarus compile options 
BINARY_REL="${BUILD_DIR}/${APP_NAME}" # Relative path to expected binary after build

# Linuxdeploy
LINUXDEPLOY="$HOME/linuxdeploy/linuxdeploy-x86_64.AppImage"

## linuxdeploy URLs (pin a release if you want stability)
#LINUXDEPLOY_URL_x86="https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage"
#PLUGIN_URL_x86="https://github.com/linuxdeploy/linuxdeploy-plugin-appimage/releases/download/continuous/linuxdeploy-plugin-appimage-x86_64.AppImage"
#LINUXDEPLOY="./linuxdeploy-x86_64.AppImage"
#PLUGIN="./linuxdeploy-plugin-appimage-x86_64.AppImage"

#if [[ "${ARCH}" == "aarch64" ]]; then
#  LINUXDEPLOY_URL_x86="https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-aarch64.AppImage"
#  PLUGIN_URL_x86="https://github.com/linuxdeploy/linuxdeploy-plugin-appimage/releases/download/continuous/linuxdeploy-plugin-appimage-aarch64.AppImage"
#  LINUXDEPLOY="./linuxdeploy-aarch64.AppImage"
#  PLUGIN="./linuxdeploy-plugin-appimage-aarch64.AppImage"
#fi


# Appdir
APPDIR="${APP_NAME}.AppDir" # AppDir folder to create
DESKTOP_FILE="${APP_NAME}.desktop" # Desktop file 
ICON_FILE="$ROOT_DIR/${APP_NAME}.png"    # icon (optional but recommended)

#DESKTOP_FILE="packaging/${APP_NAME}.desktop"  # desktop file (will be created if missing)
#ARCH="x86_64"                             # x86_64 or aarch64
#DOWNLOAD_LINUXDEPLOY=true                 # set false if you already have linuxdeploy files
#PUBLISH_TO_GITHUB=false                   # set true to upload release (needs gh CLI & auth)
#GH_REPO="user/repo"                       # required if PUBLISH_TO_GITHUB=true
## -------------------------



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

# Check so linuxdeploy exists otherwise download it
if ! command -v $LINUXDEPLOY >/dev/null 2>&1; then
  echo "ERROR: linuxdeploy not found. Download it or set correct path."
  exit 3
fi

## -------------
## Download linuxdeploy & plugin if needed
## -------------
#echo
#if [[ "${DOWNLOAD_LINUXDEPLOY}" == "true" ]]; then
#  if [[ ! -f "${LINUXDEPLOY}" ]]; then
#    echo "Downloading linuxdeploy..."
#    run wget -q -O "${LINUXDEPLOY}" "${LINUXDEPLOY_URL_x86}"
#    run chmod +x "${LINUXDEPLOY}"
#  fi
#  if [[ ! -f "${PLUGIN}" ]]; then
#    echo "Downloading linuxdeploy plugin (appimage plugin)..."
#    run wget -q -O "${PLUGIN}" "${PLUGIN_URL_x86}"
#    run chmod +x "${PLUGIN}"
#  fi
#else
#  echo "Assuming linuxdeploy and plugin are already available at ${LINUXDEPLOY} and ${PLUGIN}"
#fi

# -------------
# Build the application
# -------------
echo
echo "Building the application"
run lazbuild --build-all "${LPI_FILE}"

# Check so the binary was created
if [[ ! -f "${BINARY_REL}" ]]; then
  echo "ERROR: Binary not found at expected path:"
  echo "  ${BINARY_REL}"
  exit 4
fi

echo "Binary found at ${BINARY_REL}"

# make sure binary is executable
chmod +x "${BINARY_REL}"

# -------------
# Prepare AppDir
# -------------
#echo
#echo "Creating AppDir layout: ${APPDIR}"
#rm -rf "${APPDIR}"
#mkdir -p "${APPDIR}/usr/bin" \
#         "${APPDIR}/usr/share/applications" \
#         "${APPDIR}/usr/share/icons/hicolor/128x128/apps"

#cp "${BINARY_REL}" "${APPDIR}/usr/bin/${APP_NAME}"
#chmod +x "${APPDIR}/usr/bin/${APP_NAME}"


# create .desktop if missing
#if [[ ! -f "${DESKTOP_FILE}" ]]; then
#  echo "Notice: desktop file ${DESKTOP_FILE} not found — creating a minimal one."
#  mkdir -p "$(dirname "${DESKTOP_FILE}")"
#  cat > "${DESKTOP_FILE}" <<EOF
#[Desktop Entry]
#Type=Application
#Name=${APP_NAME}
#Exec=${APP_NAME} %F
#Icon=${APP_NAME}
#Categories=Utility;
#Terminal=false
#EOF
#fi
#cp "${DESKTOP_FILE}" "${APPDIR}/usr/share/applications/${APP_NAME}.desktop"

## copy icon if present; warn if missing
#if [[ -f "${ICON_FILE}" ]]; then
#  cp "${ICON_FILE}" "${APPDIR}/usr/share/icons/hicolor/128x128/apps/${APP_NAME}.png"
#else
#  echo "Warning: icon not found at ${ICON_FILE} — you should provide 48x48, 128x128 and an svg for best integration."
#fi



# -------------
# Run linuxdeploy to create AppImage
# -------------
echo
echo "Running linuxdeploy to bundle libraries and build AppImage"
run "${LINUXDEPLOY}" \
  --appdir "${APPDIR}" \
  --executable "${BINARY_REL}" \
  --desktop-file "$DESKTOP_FILE" \
  --icon-file "$ICON_FILE" \
  --output appimage 
  
## linuxdeploy will call the plugin/appimagetool when --output appimage is used
#run "${LINUXDEPLOY}" \
#  --appdir "${APPDIR}" \
#  --executable "${APPDIR}/usr/bin/${APP_NAME}" \
#  --desktop-file "${APPDIR}/usr/share/applications/${APP_NAME}.desktop" \
#  ${ICON_FILE:+--icon-file "${APPDIR}/usr/share/icons/hicolor/128x128/apps/${APP_NAME}.png"} \
#  --output appimage

## find produced AppImage
#APPIMAGE_FILE=$(ls -1t ${APP_NAME}*${ARCH}.AppImage 2>/dev/null || true)
#if [[ -z "${APPIMAGE_FILE}" ]]; then
#  # fallback: any .AppImage in current dir
#  APPIMAGE_FILE=$(ls -1t *.AppImage 2>/dev/null | head -n1 || true)
#fi

#if [[ -z "${APPIMAGE_FILE}" ]]; then
#  echo "ERROR: no AppImage produced. Check linuxdeploy output above for errors."
#  exit 4
#fi

#echo "AppImage produced: ${APPIMAGE_FILE}"
#chmod +x "${APPIMAGE_FILE}"

## -------------
## Optional: generate .zsync if appimagetool present (useful for AppImageUpdate)
## -------------
#if command -v appimagetool >/dev/null 2>&1; then
#  echo
#  echo "==> 4) Generating .zsync using appimagetool (optional)"
#  # appimagetool can generate zsync if given APPDIR or AppImage and flags; here we try lightweight
#  # Note: some appimagetool versions require different invocations; adapt if needed.
#  run appimagetool --generate-zsync "${APPIMAGE_FILE}" || echo "Note: zsync generation failed or not supported by this appimagetool version."
#else
#  echo "Note: appimagetool not found; skipping .zsync generation. Use appimage-builder in CI for deterministic zsync generation."
#fi

## -------------
## Optional: upload to GitHub Releases using gh CLI
## -------------
#if [[ "${PUBLISH_TO_GITHUB}" == "true" ]]; then
#  if ! command -v gh >/dev/null 2>&1; then
#    echo "ERROR: gh CLI not found; cannot upload. Install GitHub CLI and run 'gh auth login' to authenticate."
#    exit 0
#  fi
#  if [[ -z "${GH_REPO}" || "${GH_REPO}" == "user/repo" ]]; then
#    echo "ERROR: set GH_REPO to your repo (owner/repo) in the CONFIG section if you want to publish."
#    exit 1
#  fi

#  TAG="v$(date +%Y%m%d%H%M%S)"
#  echo
#  echo "==> 5) Creating GitHub release ${TAG} and uploading ${APPIMAGE_FILE}"
#  run gh release create "${TAG}" "${APPIMAGE_FILE}" --repo "${GH_REPO}" --title "${APP_NAME} ${TAG}" --notes "AppImage build ${TAG}"
#  echo "Uploaded to ${GH_REPO} release ${TAG}"
#fi

#echo
#echo "All done. Test the AppImage on a clean VM or container (different distro) before publishing widely."

