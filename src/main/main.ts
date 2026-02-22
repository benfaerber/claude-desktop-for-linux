import {
  app,
  BrowserWindow,
  globalShortcut,
  Menu,
  NativeImage,
  nativeImage,
  session,
  shell,
  Tray,
} from "electron";
import path from "path";
import { WindowState } from "./window-state";

const CLAUDE_URL = "https://claude.ai";
let isQuitting = false;

const ALLOWED_ORIGINS = [
  "https://claude.ai",
  "https://auth.anthropic.com",
  "https://accounts.google.com",
  "https://login.microsoftonline.com",
  "https://appleid.apple.com",
  "https://www.icloud.com",
];

function isAllowedUrl(url: string): boolean {
  try {
    const parsed = new URL(url);
    return ALLOWED_ORIGINS.some(
      (origin) =>
        parsed.origin === origin ||
        parsed.hostname.endsWith(".claude.ai") ||
        parsed.hostname.endsWith(".anthropic.com") ||
        parsed.hostname.endsWith(".google.com") ||
        parsed.hostname.endsWith(".googleapis.com") ||
        parsed.hostname.endsWith(".microsoftonline.com") ||
        parsed.hostname.endsWith(".apple.com") ||
        parsed.hostname.endsWith(".icloud.com")
    );
  } catch {
    return false;
  }
}

class ClaudeDesktop {
  private mainWindow: BrowserWindow | null = null;
  private tray: Tray | null = null;
  private windowState!: WindowState;

  async start() {
    await app.whenReady();

    this.windowState = new WindowState({
      defaultWidth: 1200,
      defaultHeight: 800,
    });

    this.createWindow();
    this.createTray();
    this.registerShortcuts();
    this.setupAppEvents();
  }

  private createWindow() {
    const bounds = this.windowState.getBounds();
    const persistentSession = session.fromPartition("persist:claude");

    this.spoofUserAgent(persistentSession);

    this.mainWindow = new BrowserWindow({
      ...bounds,
      minWidth: 480,
      minHeight: 600,
      title: "Claude Desktop",
      icon: this.getIconPath(),
      autoHideMenuBar: true,
      webPreferences: {
        preload: path.join(__dirname, "..", "preload", "preload.js"),
        contextIsolation: true,
        nodeIntegration: false,
        spellcheck: true,
        session: persistentSession,
      },
    });

    if (this.windowState.isMaximized()) {
      this.mainWindow.maximize();
    }

    this.mainWindow.loadURL(CLAUDE_URL);
    this.setupWindowEvents();
    this.setupWebContentsEvents();
    this.buildMenu();
  }

  private spoofUserAgent(ses: Electron.Session) {
    const chromeVersion = process.versions.chrome;
    const userAgent = `Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/${chromeVersion} Safari/537.36`;

    ses.webRequest.onBeforeSendHeaders((details, callback) => {
      details.requestHeaders["User-Agent"] = userAgent;
      callback({ requestHeaders: details.requestHeaders });
    });
  }

  private setupWindowEvents() {
    if (!this.mainWindow) return;

    this.mainWindow.on("close", (event) => {
      if (!isQuitting) {
        event.preventDefault();
        this.mainWindow?.hide();
      }
    });

    this.mainWindow.on("resize", () => this.saveWindowState());
    this.mainWindow.on("move", () => this.saveWindowState());
    this.mainWindow.on("maximize", () => this.saveWindowState());
    this.mainWindow.on("unmaximize", () => this.saveWindowState());
  }

  private setupWebContentsEvents() {
    if (!this.mainWindow) return;
    const wc = this.mainWindow.webContents;

    wc.setWindowOpenHandler(({ url }) => {
      if (isAllowedUrl(url)) {
        return { action: "allow" };
      }
      shell.openExternal(url);
      return { action: "deny" };
    });

    wc.on("did-fail-load", (_event, errorCode, errorDescription) => {
      if (errorCode === -3) return;
      console.error(`Failed to load: ${errorDescription} (${errorCode})`);
    });

    wc.on("page-title-updated", (_event, title) => {
      this.mainWindow?.setTitle(title || "Claude Desktop");
    });

    wc.on("will-navigate", (_event, url) => {
      if (isAllowedUrl(url)) return;
      _event.preventDefault();
      shell.openExternal(url);
    });
  }

  private buildMenu() {
    const template: Electron.MenuItemConstructorOptions[] = [
      {
        label: "File",
        submenu: [
          {
            label: "New Conversation",
            accelerator: "CmdOrCtrl+N",
            click: () => this.mainWindow?.loadURL(CLAUDE_URL),
          },
          { type: "separator" },
          {
            label: "Quit",
            accelerator: "CmdOrCtrl+Q",
            click: () => {
              isQuitting = true;
              app.quit();
            },
          },
        ],
      },
      {
        label: "Edit",
        submenu: [
          { role: "undo" },
          { role: "redo" },
          { type: "separator" },
          { role: "cut" },
          { role: "copy" },
          { role: "paste" },
          { role: "selectAll" },
        ],
      },
      {
        label: "View",
        submenu: [
          { role: "reload" },
          { role: "forceReload" },
          { type: "separator" },
          { role: "resetZoom" },
          { role: "zoomIn" },
          { role: "zoomOut" },
          { type: "separator" },
          { role: "togglefullscreen" },
          { type: "separator" },
          { role: "toggleDevTools" },
        ],
      },
    ];

    Menu.setApplicationMenu(Menu.buildFromTemplate(template));
  }

  private createTray() {
    const icon = this.getTrayIcon();
    if (!icon) return;

    this.tray = new Tray(icon);
    this.tray.setToolTip("Claude Desktop");

    const contextMenu = Menu.buildFromTemplate([
      {
        label: "Show Claude",
        click: () => this.showWindow(),
      },
      {
        label: "New Conversation",
        click: () => {
          this.showWindow();
          this.mainWindow?.loadURL(CLAUDE_URL);
        },
      },
      { type: "separator" },
      {
        label: "Quit",
        click: () => {
          isQuitting = true;
          app.quit();
        },
      },
    ]);

    this.tray.setContextMenu(contextMenu);
    this.tray.on("click", () => this.showWindow());
  }

  private registerShortcuts() {
    globalShortcut.register("Super+Shift+C", () => {
      this.showWindow();
    });
  }

  private setupAppEvents() {
    app.on("activate", () => this.showWindow());

    app.on("before-quit", () => {
      isQuitting = true;
    });

    app.on("second-instance", () => {
      this.showWindow();
    });

    app.on("will-quit", () => {
      globalShortcut.unregisterAll();
    });
  }

  private showWindow() {
    if (!this.mainWindow) return;

    if (this.mainWindow.isMinimized()) {
      this.mainWindow.restore();
    }
    this.mainWindow.show();
    this.mainWindow.focus();
  }

  private saveWindowState() {
    if (!this.mainWindow) return;
    this.windowState.save(this.mainWindow);
  }

  private getIconPath(): string {
    return path.join(__dirname, "..", "..", "assets", "icons", "icon.png");
  }

  private getTrayIcon(): NativeImage | null {
    try {
      const iconPath = path.join(
        __dirname,
        "..",
        "..",
        "assets",
        "icons",
        "tray-icon.png"
      );
      return nativeImage.createFromPath(iconPath);
    } catch {
      return null;
    }
  }
}

const gotLock = app.requestSingleInstanceLock();
if (!gotLock) {
  app.quit();
} else {
  new ClaudeDesktop().start();
}
