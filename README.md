# Claude Desktop for Linux (unofficial)

<p align="center">
  <img src="public/claude-ai-icon.svg" width="200" alt="Claude Desktop Icon">
</p>

<p align="center">
  A native Linux desktop application for Claude AI, built with Tauri and React.
</p>

## Features

- Native desktop wrapper for claude.ai
- System tray integration
- Quick access via tray icon
- Custom Claude branding and icon
- Fast and lightweight

---

## For Users

### Download

Download the latest AppImage from the [Releases](https://github.com/benfaerber/claude-desktop-for-linux/releases) page.

### Installation

1. Download the `.AppImage` file from releases
2. Make it executable:
   ```bash
   chmod +x Claude_*.AppImage
   ```
3. Run it:
   ```bash
   ./Claude_*.AppImage
   ```

### Optional: Add to Applications Menu

To add Claude Desktop to your applications menu:

```bash
# Move the AppImage to a permanent location
mkdir -p ~/.local/bin
mv Claude_*.AppImage ~/.local/bin/claude-desktop

# Create desktop entry
cat > ~/.local/share/applications/claude-desktop.desktop << 'EOF'
[Desktop Entry]
Name=Claude Desktop
Exec=/home/$USER/.local/bin/claude-desktop
Type=Application
Categories=Network;
Icon=claude
Terminal=false
EOF
```

### Usage

- **System Tray**: The app runs in your system tray
- **Left-click** the tray icon to open/show the window
- **Right-click** for menu options (Open Claude, Quit)

---

## For Developers

### Prerequisites

#### System Dependencies

Install the required Linux development libraries:

```bash
# Ubuntu/Debian
sudo apt install libwebkit2gtk-4.1-dev libjavascriptcoregtk-4.1-dev libsoup-3.0-dev librsvg2-dev libgtk-3-dev

# Fedora/RHEL
sudo dnf install webkit2gtk4.1-devel javascriptcoregtk4.1-devel libsoup3-devel librsvg2-devel gtk3-devel
```

#### Development Tools

- Node.js (v16 or higher)
- npm
- Rust (latest stable)

### Development Setup

1. Clone the repository:
```bash
git clone https://github.com/benfaerber/claude-desktop-for-linux
cd claude-desktop
```

2. Install dependencies:
```bash
npm install
```

### Development

Run the app in development mode with hot reload:

```bash
npm run tauri dev
```

### Building

Build the production version:

```bash
npm run tauri build
```

The AppImage will be created in `src-tauri/target/release/bundle/appimage/`

### Troubleshooting

**Missing dependencies**: If you get build errors about missing packages, ensure all system dependencies are installed (see Prerequisites).

**Icons not updating**: If you change icon files, trigger a rebuild:
```bash
touch src-tauri/src/lib.rs
```

---

## Tech Stack

- [Tauri](https://tauri.app/) - Desktop application framework
- [React](https://react.dev/) - UI framework
- [Vite](https://vitejs.dev/) - Build tool
- Rust - Backend

## License

MIT
