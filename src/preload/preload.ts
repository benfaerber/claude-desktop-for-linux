import { contextBridge, ipcRenderer } from "electron";

contextBridge.exposeInMainWorld("claudeDesktop", {
  platform: process.platform,
  onNotification: (callback: (title: string, body: string) => void) => {
    ipcRenderer.on("notification", (_event, title, body) => {
      callback(title, body);
    });
  },
});
