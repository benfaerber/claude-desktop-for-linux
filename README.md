# Claude Desktop

A native Linux desktop application for Claude AI, built with Tauri and React.

## Features

- Native desktop wrapper for claude.ai
- System tray integration
- Quick access via tray icon
- Custom Claude branding and icon
- Fast and lightweight

## Prerequisites

### System Dependencies

Install the required Linux development libraries:

```bash
# Ubuntu/Debian
sudo apt install libwebkit2gtk-4.1-dev libjavascriptcoregtk-4.1-dev libsoup-3.0-dev librsvg2-dev libgtk-3-dev

# Fedora/RHEL
sudo dnf install webkit2gtk4.1-devel javascriptcoregtk4.1-devel libsoup3-devel librsvg2-devel gtk3-devel
```

### Development Tools

- Node.js (v16 or higher)
- npm
- Rust (latest stable)

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd claude-desktop
```

2. Install dependencies:
```bash
npm install
```

## Development

Run the app in development mode with hot reload:

```bash
npm run tauri dev
```

## Building

Build the production version:

```bash
npm run tauri build
```

The AppImage will be created in `src-tauri/target/release/bundle/appimage/`

### Missing dependencies
If you get build errors about missing packages, ensure all system dependencies are installed (see Prerequisites).

## Tech Stack

- [Tauri](https://tauri.app/) - Desktop application framework
- [React](https://react.dev/) - UI framework
- [Vite](https://vitejs.dev/) - Build tool
- Rust - Backend

## License

MIT
