#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

REPO="benfaerber/claude-desktop-for-linux"
INSTALL_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons/hicolor/512x512/apps"

echo -e "${GREEN}Claude Desktop for Linux - Installer${NC}"
echo "========================================"
echo ""

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    echo -e "${RED}Error: curl is not installed${NC}"
    echo "Please install curl and try again:"
    echo "  Ubuntu/Debian: sudo apt install curl"
    echo "  Fedora: sudo dnf install curl"
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}Warning: jq is not installed. Using fallback method for parsing JSON.${NC}"
    USE_JQ=false
else
    USE_JQ=true
fi

echo "📥 Fetching latest release..."

# Get latest release info
RELEASE_DATA=$(curl -sL "https://api.github.com/repos/$REPO/releases/latest")

if [ "$USE_JQ" = true ]; then
    DOWNLOAD_URL=$(echo "$RELEASE_DATA" | jq -r '.assets[] | select(.name | endswith(".AppImage")) | .browser_download_url')
    VERSION=$(echo "$RELEASE_DATA" | jq -r '.tag_name')
else
    # Fallback: parse JSON manually
    DOWNLOAD_URL=$(echo "$RELEASE_DATA" | grep -o '"browser_download_url": *"[^"]*\.AppImage"' | grep -o 'https://[^"]*')
    VERSION=$(echo "$RELEASE_DATA" | grep -o '"tag_name": *"[^"]*"' | grep -o 'v[^"]*' | head -n1)
fi

if [ -z "$DOWNLOAD_URL" ]; then
    echo -e "${RED}Error: Could not find AppImage in latest release${NC}"
    echo "Please download manually from: https://github.com/$REPO/releases"
    exit 1
fi

echo -e "${GREEN}✓ Found version: $VERSION${NC}"
echo ""

# Create directories
echo "📁 Creating installation directories..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$DESKTOP_DIR"
mkdir -p "$ICON_DIR"

# Download AppImage
TEMP_FILE=$(mktemp)
echo "⬇️  Downloading Claude Desktop..."
if curl -L --progress-bar "$DOWNLOAD_URL" -o "$TEMP_FILE"; then
    echo -e "${GREEN}✓ Download complete${NC}"
else
    echo -e "${RED}Error: Download failed${NC}"
    rm -f "$TEMP_FILE"
    exit 1
fi

# Make executable
chmod +x "$TEMP_FILE"

# Move to install directory
INSTALL_PATH="$INSTALL_DIR/claude-desktop"
mv "$TEMP_FILE" "$INSTALL_PATH"
echo -e "${GREEN}✓ Installed to: $INSTALL_PATH${NC}"

# Download icon
echo "🎨 Downloading icon..."
ICON_URL="https://raw.githubusercontent.com/$REPO/master/public/claude-ai-icon.svg"
ICON_PATH="$ICON_DIR/claude-desktop.svg"
if curl -sL "$ICON_URL" -o "$ICON_PATH"; then
    echo -e "${GREEN}✓ Icon installed${NC}"
else
    echo -e "${YELLOW}Warning: Could not download icon${NC}"
fi

# Create desktop entry
echo "🖥️  Creating desktop entry..."
cat > "$DESKTOP_DIR/claude-desktop.desktop" << EOF
[Desktop Entry]
Name=Claude Desktop
Comment=Native desktop application for Claude AI
Exec=$INSTALL_PATH
Icon=claude-desktop
Type=Application
Categories=Network;InstantMessaging;
Terminal=false
StartupWMClass=claude-desktop
EOF

echo -e "${GREEN}✓ Desktop entry created${NC}"

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ Installation complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Claude Desktop has been installed to:"
echo "  $INSTALL_PATH"
echo ""
echo "You can now:"
echo "  • Search for 'Claude Desktop' in your application menu"
echo "  • Run from terminal: claude-desktop"
echo ""
echo "To uninstall, run:"
echo "  rm $INSTALL_PATH"
echo "  rm $DESKTOP_DIR/claude-desktop.desktop"
echo "  rm $ICON_PATH"
echo ""
