"""Generate PBR Skin Textures for Akaza (Demon Slayer - Upper Moon 3).

Textures generated (1024x1024):
1. akaza_skin_albedo.png & akaza_skin_normal.png (Pale demonic skin with crisp blue criminal tattoo stripes)
2. akaza_haori_albedo.png & akaza_haori_normal.png (Deep reddish-purple textured haori vest cloth)
3. akaza_hakama_albedo.png & akaza_hakama_normal.png (Pleated white martial arts hakama cloth)
4. akaza_compass_albedo.png & akaza_compass_emission.png (Glowing cyan snowflake compass mandala)
"""
import math, numpy as np
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

OUT_DIR = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate\godot\assets\textures\skins")
OUT_DIR.mkdir(parents=True, exist_ok=True)

SIZE = 1024

def normal_from_height(h_arr, strength=2.5):
    dy, dx = np.gradient(h_arr.astype(float))
    norm_x = -dx * strength
    norm_y = -dy * strength
    norm_z = np.ones_like(h_arr, dtype=float) * 255.0
    mag = np.sqrt(norm_x**2 + norm_y**2 + norm_z**2)
    mag[mag == 0] = 1.0
    nx = ((norm_x / mag) * 0.5 + 0.5) * 255.0
    ny = ((norm_y / mag) * 0.5 + 0.5) * 255.0
    nz = ((norm_z / mag) * 0.5 + 0.5) * 255.0
    return Image.fromarray(np.stack([nx, ny, nz], axis=-1).astype(np.uint8))

print("1. Generating Akaza Pale Skin & Soryu Blue Tattoos...")
skin_base = Image.new("RGBA", (SIZE, SIZE), (225, 230, 240, 255))
d = ImageDraw.Draw(skin_base)

# Micro skin pores / texture
np_skin = np.random.normal(0, 4, (SIZE, SIZE)).astype(np.float32)
skin_arr = np.array(skin_base).astype(np.float32)
for c in range(3):
    skin_arr[:, :, c] = np.clip(skin_arr[:, :, c] + np_skin, 0, 255)
skin_base = Image.fromarray(skin_arr.astype(np.uint8))
d = ImageDraw.Draw(skin_base)

# Criminal tattoo markings (Deep vibrant blue with soft edge bleed)
# Horizontal armband stripes
for y in [180, 240, 300, 480, 540, 600, 780, 840]:
    d.line([(0, y), (SIZE, y)], fill=(18, 92, 224, 255), width=28)
    d.line([(0, y), (SIZE, y)], fill=(8, 55, 175, 255), width=16)

# Diagonal cross markings
d.line([(100, 0), (900, SIZE)], fill=(18, 92, 224, 255), width=24)
d.line([(900, 0), (100, SIZE)], fill=(18, 92, 224, 255), width=24)

skin_base.save(OUT_DIR / "akaza_skin_albedo.png")

# Skin normal
h_skin = np.zeros((SIZE, SIZE), dtype=np.uint8)
h_img = Image.fromarray(h_skin)
hd = ImageDraw.Draw(h_img)
for y in [180, 240, 300, 480, 540, 600, 780, 840]:
    hd.line([(0, y), (SIZE, y)], fill=180, width=28)
hd.line([(100, 0), (900, SIZE)], fill=180, width=24)
hd.line([(900, 0), (100, SIZE)], fill=180, width=24)
h_img = h_img.filter(ImageFilter.GaussianBlur(radius=2))
normal_from_height(np.array(h_img), strength=2.2).save(OUT_DIR / "akaza_skin_normal.png")

print("2. Generating Akaza Haori Vest Textures...")
haori = Image.new("RGBA", (SIZE, SIZE), (98, 22, 68, 255))
d_h = ImageDraw.Draw(haori)
# Woven cloth pattern
for i in range(0, SIZE, 8):
    d_h.line([(i, 0), (i, SIZE)], fill=(85, 18, 58, 255), width=1)
    d_h.line([(0, i), (SIZE, i)], fill=(110, 26, 76, 255), width=1)
haori.save(OUT_DIR / "akaza_haori_albedo.png")

h_haori = np.random.randint(120, 135, (SIZE, SIZE), dtype=np.uint8)
normal_from_height(h_haori, strength=1.4).save(OUT_DIR / "akaza_haori_normal.png")

print("3. Generating Akaza Hakama Pants Textures...")
hakama = Image.new("RGBA", (SIZE, SIZE), (235, 238, 244, 255))
d_k = ImageDraw.Draw(hakama)
# Vertical pleats and cloth weave
for x in range(0, SIZE, 48):
    d_k.line([(x, 0), (x, SIZE)], fill=(200, 205, 218, 255), width=6)
    d_k.line([(x + 2, 0), (x + 2, SIZE)], fill=(180, 186, 200, 255), width=2)
hakama.save(OUT_DIR / "akaza_hakama_albedo.png")

h_hakama = np.ones((SIZE, SIZE), dtype=np.uint8) * 128
for x in range(0, SIZE, 48):
    h_hakama[:, max(0, x-4):min(SIZE, x+4)] = 210
normal_from_height(h_hakama, strength=2.8).save(OUT_DIR / "akaza_hakama_normal.png")

print("4. Generating Destructive Death: Compass Needle (Hakai Satsu: Rashin) Mandala...")
compass_alb = Image.new("RGBA", (SIZE, SIZE), (10, 24, 45, 255))
compass_em  = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 255))
d_ca = ImageDraw.Draw(compass_alb)
d_ce = ImageDraw.Draw(compass_em)

cx, cy = SIZE // 2, SIZE // 2
# Outer runic rings
for r in [460, 430, 360, 280, 180, 80]:
    d_ca.ellipse([cx - r, cy - r, cx + r, cy + r], outline=(40, 195, 255, 255), width=8)
    d_ce.ellipse([cx - r, cy - r, cx + r, cy + r], outline=(60, 220, 255, 255), width=8)

# 12 Radiating snowflake compass arms
for a_idx in range(12):
    rad = a_idx * (2.0 * math.pi / 12.0)
    x2 = cx + int(math.cos(rad) * 460)
    y2 = cy + int(math.sin(rad) * 460)
    d_ca.line([(cx, cy), (x2, y2)], fill=(70, 215, 255, 255), width=10)
    d_ce.line([(cx, cy), (x2, y2)], fill=(90, 235, 255, 255), width=10)

    # Snowflake needle branches along the arms
    for d_dist in [180, 280, 380]:
        bx = cx + int(math.cos(rad) * d_dist)
        by = cy + int(math.sin(rad) * d_dist)
        for barb_ang in [rad + 0.6, rad - 0.6]:
            bbx = bx + int(math.cos(barb_ang) * 45)
            bby = by + int(math.sin(barb_ang) * 45)
            d_ca.line([(bx, by), (bbx, bby)], fill=(50, 205, 255, 255), width=6)
            d_ce.line([(bx, by), (bbx, bby)], fill=(70, 225, 255, 255), width=6)

# Center glowing kanji/compass core
d_ca.ellipse([cx - 40, cy - 40, cx + 40, cy + 40], fill=(90, 240, 255, 255))
d_ce.ellipse([cx - 40, cy - 40, cx + 40, cy + 40], fill=(120, 250, 255, 255))

compass_alb.save(OUT_DIR / "akaza_compass_albedo.png")
compass_em.save(OUT_DIR / "akaza_compass_emission.png")

print("=== ALL AKAZA PBR MAPS CREATED SUCCESSFULLY ===")
