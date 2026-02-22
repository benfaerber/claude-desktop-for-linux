import { execSync } from "child_process";
import { existsSync } from "fs";

const sizes = [16, 32, 48, 64, 128, 256, 512];
const src = "assets/icons/icon.svg";
const traySource = "assets/icons/tray-icon.svg";

if (!existsSync(src)) {
  console.error(`Source icon not found: ${src}`);
  process.exit(1);
}

for (const size of sizes) {
  const out = `assets/icons/${size}x${size}.png`;
  execSync(`convert -background none "${src}" -resize ${size}x${size} "${out}"`);
  console.log(`Generated ${out}`);
}

execSync(`convert -background none "${src}" -resize 512x512 "assets/icons/icon.png"`);
console.log("Generated assets/icons/icon.png");

execSync(`convert -background none "${traySource}" -resize 24x24 "assets/icons/tray-icon.png"`);
console.log("Generated assets/icons/tray-icon.png");

console.log("Done.");
