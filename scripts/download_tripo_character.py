import urllib.request
import ssl
import json
from pathlib import Path
from PIL import Image

ROOT = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate")
CHAR_DIR = ROOT / "art/characters/golden_golem"
CHAR_DIR.mkdir(parents=True, exist_ok=True)

with open(ROOT / "tripo_detail_api.json", "r", encoding="utf-8") as f:
    data = json.load(f)

d = data["data"]
fbx_url = d["operator"]["model_url"]
img_url = d["biz_info"]["display_image"]

print("FBX URL:", fbx_url[:80])
print("IMG URL:", img_url)

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

# Download FBX
fbx_path = CHAR_DIR / "golden_golem.fbx"
print("Downloading FBX to", fbx_path)
req = urllib.request.Request(fbx_url, headers={"User-Agent": "Mozilla/5.0"})
with urllib.request.urlopen(req, context=ctx, timeout=30) as resp:
    content = resp.read()
    with open(fbx_path, "wb") as f:
        f.write(content)
print(f"Downloaded FBX: {len(content)} bytes")

# Download Preview Image
webp_path = CHAR_DIR / "preview.webp"
print("Downloading Preview to", webp_path)
req2 = urllib.request.Request(img_url, headers={"User-Agent": "Mozilla/5.0"})
with urllib.request.urlopen(req2, context=ctx, timeout=30) as resp:
    img_data = resp.read()
    with open(webp_path, "wb") as f:
        f.write(img_data)
print(f"Downloaded WebP: {len(img_data)} bytes")

# Convert to UI Portraits
img = Image.open(webp_path).convert("RGBA")
# Square crop center
w, h = img.size
min_d = min(w, h)
left = (w - min_d) // 2
top = (h - min_d) // 2
img_crop = img.crop((left, top, left + min_d, top + min_d))

p_512 = img_crop.resize((512, 512), Image.Resampling.LANCZOS)
p_256 = img_crop.resize((256, 256), Image.Resampling.LANCZOS)

portrait_out = ROOT / "godot/assets/textures/ui/portrait_golden_golem.png"
thumb_out = ROOT / "godot/assets/textures/characters/thumbs/thumb_golden_golem.png"
portrait_out.parent.mkdir(parents=True, exist_ok=True)
thumb_out.parent.mkdir(parents=True, exist_ok=True)

p_512.save(portrait_out)
p_256.save(thumb_out)
print("Saved portraits:", portrait_out, thumb_out)
