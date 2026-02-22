# Claude Desktop for Linux

A native Linux desktop app for [claude.ai](https://claude.ai), built with Electron and TypeScript.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/benfaerber/claude-desktop-for-linux/main/install.sh | bash
```

The installer auto-detects your system and installs the appropriate package:

| System | Format | Method |
|--------|--------|--------|
| Debian/Ubuntu | `.deb` | `dpkg` |
| Fedora/RHEL | `.rpm` | `rpm` |
| Other | `.AppImage` | Standalone binary |

## Manual Install

Download the latest `.deb` or `.AppImage` from [Releases](https://github.com/benfaerber/claude-desktop-for-linux/releases).

```bash
# Debian/Ubuntu
sudo dpkg -i claude-desktop_*_amd64.deb

# AppImage
chmod +x Claude\ Desktop-*.AppImage
./Claude\ Desktop-*.AppImage
```

## Features

- Wraps claude.ai in a native desktop window
- System tray with quick actions
- `Super+Shift+C` global shortcut to focus the window
- Persistent login sessions
- Window state remembered across restarts
- Close-to-tray (quit via tray menu or `Ctrl+Q`)
- External links open in your browser
- Single instance lock

## Build from Source

Requires [bun](https://bun.sh) and [Node.js](https://nodejs.org) 22+.

```bash
git clone https://github.com/benfaerber/claude-desktop-for-linux.git
cd claude-desktop-for-linux
bun install
bun run start
```

### Package for distribution

```bash
bun run dist            # AppImage + deb
bun run dist:deb        # deb only
bun run dist:appimage   # AppImage only
```

Output goes to `release/`.

### Install the built .deb

```bash
make install-deb
```

## Uninstall

```bash
sudo dpkg -r claude-desktop
```

## License

MIT
