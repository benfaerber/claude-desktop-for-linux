import { useEffect } from "react";
import "./App.css";

function App() {
  useEffect(() => {
    window.location.replace("https://claude.ai");
  }, []);

  return (
    <div className="app-container">
      <p>Loading Claude...</p>
    </div>
  );
}

export default App;
