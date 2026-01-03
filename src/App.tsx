import { useEffect } from "react";
import { getCurrentWebviewWindow } from "@tauri-apps/api/webviewWindow";
import "./App.css";

function App() {
  useEffect(() => {
    const webview = getCurrentWebviewWindow();
    window.location.href = "https://claude.ai";
  }, []);

  return (
    <div className="app-container">
      <p>Loading Claude...</p>
    </div>
  );
}

export default App;
