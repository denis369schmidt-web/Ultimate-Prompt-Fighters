"""Generate UI Portraits for Akaza (Demon Slayer - Upper Moon Three / Hakuji)."""
import math, numpy as np
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate")
UI_DIR = ROOT / "godot/assets/textures/ui"
THUMB_DIR = ROOT / "godot/assets/textures/characters/thumbs"

for d in (UI_DIR, THUMB_DIR):
    d.mkdir(parents=True, exist_ok=True)

SIZE = 256
img = Image.new("RGBA", (SIZE, SIZE), (16, 12, 28, 255))
d = ImageDraw.Draw(img)

# Dark blood/compass vignette gradient
for r in range(SIZE // 2, 0, -2):
    frac = r / (SIZE // 2)
    val_r = int(55 * (1.0 - frac) + 18 * frac)
    val_g = int(18 * (1.0 - frac) + 12 * frac)
    val_b = int(75 * (1.0 - frac) + 28 * frac)
    d.ellipse([128 - r, 128 - r, 128 + r, 128 + r], outline=(val_r, val_g, val_b, 255), width=2)

# Glowing Compass Needle snowflake mandala in background
cx, cy = 128, 128
for a_idx in range(12):
    rad = a_idx * (2.0 * math.pi / 12.0)
    x2 = cx + int(math.cos(rad) * 110)
    y2 = cy + int(math.sin(rad) * 110)
    d.line([(cx, cy), (x2, y2)], fill=(40, 180, 240, 90), width=3)

# Shoulders & Haori vest
d.polygon([(40, 256), (90, 205), (166, 205), (216, 256)], fill=(95, 20, 65, 255))
# White fur collar
d.ellipse([75, 185, 181, 225], fill=(235, 235, 245, 255))
d.ellipse([92, 192, 164, 230], fill=(95, 20, 65, 255))

# Neck with tattoo ring
d.rectangle([112, 160, 144, 205], fill=(225, 230, 240, 255))
d.rectangle([112, 178, 144, 186], fill=(18, 92, 224, 255))

# Head / Jaw
d.polygon([(90, 120), (128, 175), (166, 120), (160, 90), (96, 90)], fill=(225, 230, 240, 255))
d.ellipse([88, 70, 168, 150], fill=(225, 230, 240, 255))

# Blue Criminal Tattoos across cheeks and chin
d.line([(128, 145), (128, 175)], fill=(18, 92, 224, 255), width=4)
d.line([(100, 125), (120, 145)], fill=(18, 92, 224, 255), width=4)
d.line([(156, 125), (136, 145)], fill=(18, 92, 224, 255), width=4)
d.line([(114, 88), (142, 88)], fill=(18, 92, 224, 255), width=5)

# Golden Demon Eyes
d.ellipse([103, 108, 119, 122], fill=(255, 215, 20, 255))
d.ellipse([137, 108, 153, 122], fill=(255, 215, 20, 255))
d.ellipse([108, 112, 114, 118], fill=(30, 10, 60, 255))
d.ellipse([142, 112, 148, 118], fill=(30, 10, 60, 255))

# Spiky Magenta/Pink Hair
hair_poly = [
    (128, 40), (142, 60), (165, 45), (160, 75), (185, 70), (170, 95), (182, 110),
    (168, 120), (162, 140), (150, 85), (138, 70), (128, 80), (118, 70), (106, 85),
    (94, 140), (88, 120), (74, 110), (86, 95), (71, 70), (96, 75), (91, 45), (114, 60)
]
d.polygon(hair_poly, fill=(225, 28, 105, 255))

# Outer gold/blood border
d.rectangle([2, 2, SIZE - 3, SIZE - 3], outline=(230, 180, 45, 255), width=3)
d.rectangle([6, 6, SIZE - 7, SIZE - 7], outline=(95, 20, 65, 180), width=2)

img.save(UI_DIR / "portrait_akaza.png")
thumb = img.resize((128, 128), Image.Resampling.LANCZOS)
thumb.save(THUMB_DIR / "thumb_akaza.png")

print("Generated portrait_akaza.png & thumb_akaza.png successfully!")
