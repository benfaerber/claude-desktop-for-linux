import { BrowserWindow, screen } from "electron";
import fs from "fs";
import path from "path";
import { app } from "electron";

interface Bounds {
  x: number;
  y: number;
  width: number;
  height: number;
}

interface StoredState {
  bounds: Bounds;
  maximized: boolean;
}

export class WindowState {
  private state: StoredState;
  private stateFile: string;
  private saveTimeout: ReturnType<typeof setTimeout> | null = null;

  private boundsValidated = false;

  constructor(opts: { defaultWidth: number; defaultHeight: number }) {
    this.stateFile = path.join(
      app.getPath("userData"),
      "window-state.json"
    );

    this.state = this.load() ?? {
      bounds: {
        x: 0,
        y: 0,
        width: opts.defaultWidth,
        height: opts.defaultHeight,
      },
      maximized: false,
    };
  }

  getBounds(): Bounds {
    if (!this.boundsValidated) {
      this.ensureBoundsVisible();
      this.boundsValidated = true;
    }
    return { ...this.state.bounds };
  }

  isMaximized(): boolean {
    return this.state.maximized;
  }

  save(window: BrowserWindow) {
    if (this.saveTimeout) clearTimeout(this.saveTimeout);

    this.saveTimeout = setTimeout(() => {
      if (window.isDestroyed()) return;

      this.state.maximized = window.isMaximized();
      if (!this.state.maximized) {
        this.state.bounds = window.getBounds();
      }

      try {
        fs.writeFileSync(this.stateFile, JSON.stringify(this.state));
      } catch {
        // ignore write errors
      }
    }, 500);
  }

  private load(): StoredState | null {
    try {
      const data = fs.readFileSync(this.stateFile, "utf-8");
      return JSON.parse(data);
    } catch {
      return null;
    }
  }

  private ensureBoundsVisible() {
    const displays = screen.getAllDisplays();
    const visible = displays.some((display) => {
      const area = display.workArea;
      return (
        this.state.bounds.x >= area.x - 100 &&
        this.state.bounds.y >= area.y - 100 &&
        this.state.bounds.x < area.x + area.width - 100 &&
        this.state.bounds.y < area.y + area.height - 100
      );
    });

    if (!visible) {
      const primary = screen.getPrimaryDisplay();
      this.state.bounds.x = Math.round(
        (primary.workArea.width - this.state.bounds.width) / 2
      );
      this.state.bounds.y = Math.round(
        (primary.workArea.height - this.state.bounds.height) / 2
      );
    }
  }
}
