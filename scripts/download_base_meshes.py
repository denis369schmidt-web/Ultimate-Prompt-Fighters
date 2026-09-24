import os
import zipfile
from pathlib import Path
import requests

ROOT = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate")
DEST_DIR = ROOT / "tools" / "human_base_meshes"
DEST_DIR.mkdir(parents=True, exist_ok=True)
ZIP_FILE = DEST_DIR / "human_base_meshes_v1.4.1.zip"

url = "https://download.blender.org/demo/asset-bundles/human-base-meshes/human-base-meshes-bundle-v1.4.1.zip"

print(f"Downloading Blender Studio Human Base Meshes (48 MB)...")
with requests.get(url, stream=True, timeout=30) as r:
    r.raise_for_status()
    total = int(r.headers.get("content-length", 0))
    downloaded = 0
    with open(ZIP_FILE, "wb") as f:
        for chunk in r.iter_content(chunk_size=1024 * 512):
            if chunk:
                f.write(chunk)
                downloaded += len(chunk)
                percent = (downloaded / total) * 100 if total else 0
                print(f"  Downloaded {downloaded // (1024*1024)}MB / {total // (1024*1024)}MB ({percent:.1f}%)", end="\r")

print(f"\nDownload finished! Extracting to {DEST_DIR}...")
with zipfile.ZipFile(ZIP_FILE, "r") as z:
    z.extractall(DEST_DIR)

print("Extracted files:")
for item in DEST_DIR.rglob("*.blend"):
    print(" ", item.relative_to(DEST_DIR))

print("BLENDER_BASE_MESHES_DOWNLOAD_OK")
