#!/usr/bin/env bash
set -euo pipefail

REPO="benfaerber/claude-desktop-for-linux"
APP_NAME="claude-desktop"
INSTALL_DIR="${HOME}/.local/bin"
DESKTOP_DIR="${HOME}/.local/share/applications"
ICON_DIR="${HOME}/.local/share/icons/hicolor"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

info() { printf "${BLUE}>${RESET} %s\n" "$*"; }
success() { printf "${GREEN}>${RESET} %s\n" "$*"; }
error() { printf "${RED}>${RESET} %s\n" "$*" >&2; }

detect_arch() {
  local arch
  arch="$(uname -m)"
  case "$arch" in
    x86_64|amd64) echo "amd64" ;;
    aarch64|arm64) echo "arm64" ;;
    *) error "Unsupported architecture: $arch"; exit 1 ;;
  esac
}

detect_format() {
  if command -v dpkg &>/dev/null && command -v apt &>/dev/null; then
    echo "deb"
  elif command -v rpm &>/dev/null; then
    echo "rpm"
  else
    echo "appimage"
  fi
}

get_latest_release() {
  local url="https://api.github.com/repos/${REPO}/releases/latest"
  if command -v curl &>/dev/null; then
    curl -fsSL "$url"
  elif command -v wget &>/dev/null; then
    wget -qO- "$url"
  else
    error "Neither curl nor wget found"
    exit 1
  fi
}

download() {
  local url="$1" dest="$2"
  info "Downloading $(basename "$dest")..."
  if command -v curl &>/dev/null; then
    curl -fSL --progress-bar -o "$dest" "$url"
  else
    wget --show-progress -qO "$dest" "$url"
  fi
}

install_deb() {
  local url="$1" tmp
  tmp="$(mktemp /tmp/claude-desktop-XXXXXX.deb)"
  download "$url" "$tmp"
  info "Installing .deb package (requires sudo)..."
  sudo dpkg -i "$tmp" || sudo apt-get install -f -y
  rm -f "$tmp"
  success "Installed via dpkg. Launch 'Claude Desktop' from your app menu."
}

install_rpm() {
  local url="$1" tmp
  tmp="$(mktemp /tmp/claude-desktop-XXXXXX.rpm)"
  download "$url" "$tmp"
  info "Installing .rpm package (requires sudo)..."
  sudo rpm -U "$tmp"
  rm -f "$tmp"
  success "Installed via rpm. Launch 'Claude Desktop' from your app menu."
}

install_appimage() {
  local url="$1" dest
  mkdir -p "$INSTALL_DIR"
  dest="${INSTALL_DIR}/${APP_NAME}"
  download "$url" "$dest"
  chmod +x "$dest"

  mkdir -p "$DESKTOP_DIR"
  cat > "${DESKTOP_DIR}/${APP_NAME}.desktop" <<EOF
[Desktop Entry]
Name=Claude Desktop
Comment=Claude AI Desktop Client
Exec=${dest}
Icon=${APP_NAME}
Terminal=false
Type=Application
Categories=Network;Chat;InstantMessaging;
StartupWMClass=claude-desktop
EOF

  if command -v update-desktop-database &>/dev/null; then
    update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
  fi

  success "Installed AppImage to ${dest}"
  success "Desktop entry created. Launch 'Claude Desktop' from your app menu."

  if [[ ":$PATH:" != *":${INSTALL_DIR}:"* ]]; then
    info "Add ${INSTALL_DIR} to your PATH to run '${APP_NAME}' from the terminal:"
    info "  export PATH=\"${INSTALL_DIR}:\$PATH\""
  fi
}

cleanup_old_installs() {
  local stale="${DESKTOP_DIR}/${APP_NAME}.desktop"
  if [ -f "$stale" ]; then
    info "Removing old desktop entry: ${stale}"
    rm -f "$stale"
  fi

  local old_bin="${INSTALL_DIR}/${APP_NAME}"
  if [ -f "$old_bin" ]; then
    info "Removing old binary: ${old_bin}"
    rm -f "$old_bin"
  fi

  if command -v update-desktop-database &>/dev/null; then
    update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
  fi
}

main() {
  printf "\n${BOLD}Claude Desktop for Linux — Installer${RESET}\n\n"

  local arch format
  arch="$(detect_arch)"
  format="$(detect_format)"

  cleanup_old_installs

  info "Detected: arch=${arch} format=${format}"
  info "Fetching latest release..."

  local release_json
  release_json="$(get_latest_release)"

  local version
  version="$(echo "$release_json" | grep '"tag_name"' | head -1 | sed 's/.*"tag_name": *"v\?\([^"]*\)".*/\1/')"
  info "Latest version: ${version}"

  local pattern download_url
  case "$format" in
    deb)     pattern="${APP_NAME}_${version}_${arch}\.deb" ;;
    rpm)     pattern="${APP_NAME}-${version}\.${arch}\.rpm" ;;
    appimage) pattern="Claude.Desktop.*\.AppImage" ;;
  esac

  download_url="$(echo "$release_json" | grep '"browser_download_url"' | grep -iE "$pattern" | head -1 | sed 's/.*"browser_download_url": *"\([^"]*\)".*/\1/')"

  if [ -z "$download_url" ]; then
    error "Could not find a ${format} package for ${arch} in release ${version}."
    error "Available assets:"
    echo "$release_json" | grep '"browser_download_url"' | sed 's/.*"browser_download_url": *"\([^"]*\)".*/  \1/'
    exit 1
  fi

  case "$format" in
    deb)      install_deb "$download_url" ;;
    rpm)      install_rpm "$download_url" ;;
    appimage) install_appimage "$download_url" ;;
  esac

  printf "\n${GREEN}${BOLD}Done!${RESET}\n\n"
}

main "$@"
