"""Generate UI Portraits for Blue-Eyes White Dragon (Yu-Gi-Oh)."""
import math, numpy as np
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate")
UI_DIR = ROOT / "godot/assets/textures/ui"
THUMB_DIR = ROOT / "godot/assets/textures/characters/thumbs"

for d in (UI_DIR, THUMB_DIR):
    d.mkdir(parents=True, exist_ok=True)

SIZE = 256
img = Image.new("RGBA", (SIZE, SIZE), (8, 14, 28, 255))
d = ImageDraw.Draw(img)

# 1. Dark electric cyan / lightning background radial vignette
for r in range(SIZE // 2, 0, -2):
    frac = r / (SIZE // 2)
    val_r = int(10 * (1.0 - frac) + 6 * frac)
    val_g = int(55 * (1.0 - frac) + 16 * frac)
    val_b = int(120 * (1.0 - frac) + 38 * frac)
    d.ellipse([128 - r, 128 - r, 128 + r, 128 + r], outline=(val_r, val_g, val_b, 255), width=2)

# Lightning discharge rays radiating outwards
cx, cy = 128, 120
for a_idx in range(16):
    rad = a_idx * (2.0 * math.pi / 16.0)
    x2 = cx + int(math.cos(rad) * 115)
    y2 = cy + int(math.sin(rad) * 115)
    d.line([(cx, cy), (x2, y2)], fill=(60, 200, 255, 80), width=2)

# 2. Large swept dragon horns (Arching back and out)
# Left Horn
d.polygon([(115, 90), (45, 20), (65, 55), (105, 105)], fill=(210, 225, 240, 255), outline=(150, 180, 210, 255))
# Right Horn
d.polygon([(141, 90), (211, 20), (191, 55), (151, 105)], fill=(210, 225, 240, 255), outline=(150, 180, 210, 255))

# Cheek horns
d.polygon([(90, 125), (25, 105), (55, 135), (95, 140)], fill=(200, 215, 230, 255), outline=(140, 170, 200, 255))
d.polygon([(166, 125), (231, 105), (201, 135), (161, 140)], fill=(200, 215, 230, 255), outline=(140, 170, 200, 255))

# Sinuous neck plates (Background of head)
d.polygon([(88, 185), (128, 160), (168, 185), (180, 256), (76, 256)], fill=(225, 235, 245, 255))
d.polygon([(102, 195), (128, 175), (154, 195), (160, 256), (96, 256)], fill=(190, 205, 225, 255))

# 3. Dragon Skull & Snout
# Cranium
d.polygon([(92, 95), (128, 70), (164, 95), (158, 145), (98, 145)], fill=(240, 245, 252, 255))
# Upper Snout wedge
d.polygon([(104, 105), (128, 170), (152, 105), (128, 85)], fill=(245, 248, 255, 255), outline=(180, 205, 230, 255))
# Lower Jaw with fangs
d.polygon([(112, 165), (128, 200), (144, 165)], fill=(185, 200, 220, 255))

# 4. Piercing Ice-Blue Eyes ("Eiskalten Blick")
# Glowing eye sockets
d.ellipse([94, 114, 116, 130], fill=(0, 220, 255, 255))
d.ellipse([140, 114, 162, 130], fill=(0, 220, 255, 255))
# Slit pupils with intense electric white glow
d.ellipse([102, 118, 108, 126], fill=(255, 255, 255, 255))
d.ellipse([148, 118, 154, 126], fill=(255, 255, 255, 255))

# Heavy dragon brow armor over eyes
d.polygon([(90, 112), (120, 118), (114, 106)], fill=(220, 230, 242, 255), outline=(160, 185, 215, 255))
d.polygon([(166, 112), (136, 118), (142, 106)], fill=(220, 230, 242, 255), outline=(160, 185, 215, 255))

# 5. Burst Stream energy spark at maw
d.ellipse([120, 168, 136, 184], fill=(120, 235, 255, 220))
d.ellipse([124, 172, 132, 180], fill=(255, 255, 255, 255))

# Save 256x256 UI Portrait
port_path = UI_DIR / "portrait_blue_eyes.png"
img.save(port_path, "PNG")
print(f"Saved: {port_path.name}")

# Save 64x64 Thumbnail
thumb = img.resize((64, 64), Image.Resampling.LANCZOS)
thumb_path = THUMB_DIR / "thumb_blue_eyes.png"
thumb.save(thumb_path, "PNG")
print(f"Saved: {thumb_path.name}")

print("=== Blue-Eyes portraits generated successfully! ===")
