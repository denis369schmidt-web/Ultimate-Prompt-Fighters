"""Generate High-Fidelity PBR Skins & Portraits for Blue-Eyes Dragon & Akaza.
Vectorized with NumPy for maximum visual fidelity and performance.
"""
import math, numpy as np
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

SKINS_DIR = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate\godot\assets\textures\skins")
UI_DIR = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate\godot\assets\textures\ui")
THUMB_DIR = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate\godot\assets\textures\characters\thumbs")

SKINS_DIR.mkdir(parents=True, exist_ok=True)
UI_DIR.mkdir(parents=True, exist_ok=True)
THUMB_DIR.mkdir(parents=True, exist_ok=True)

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

print("1. Generating Akaza High-Fidelity PBR Skins...")
# A. Akaza Porcelain Demon Skin & Deep Soryu Tattoos
skin_img = Image.new("RGBA", (SIZE, SIZE), (230, 235, 245, 255))
d = ImageDraw.Draw(skin_img)
# Subtle skin noise
noise = np.random.normal(0, 3.5, (SIZE, SIZE)).astype(np.float32)
s_arr = np.array(skin_img).astype(np.float32)
for c in range(3):
    s_arr[:, :, c] = np.clip(s_arr[:, :, c] + noise, 0, 255)
skin_img = Image.fromarray(s_arr.astype(np.uint8))
d = ImageDraw.Draw(skin_img)

# Deep Navy Criminal Tattoo Stripes with soft cyan outer aura
h_skin = np.zeros((SIZE, SIZE), dtype=np.uint8)
h_img = Image.fromarray(h_skin)
hd = ImageDraw.Draw(h_img)

stripes_y = [140, 200, 260, 420, 480, 540, 700, 760, 820]
for y in stripes_y:
    d.line([(0, y), (SIZE, y)], fill=(0, 160, 255, 120), width=34)
    d.line([(0, y), (SIZE, y)], fill=(8, 48, 160, 255), width=24)
    d.line([(0, y), (SIZE, y)], fill=(4, 25, 95, 255), width=14)
    hd.line([(0, y), (SIZE, y)], fill=200, width=24)

# Angular Soryu glyphs & cross stripes
d.line([(120, 0), (900, SIZE)], fill=(8, 48, 160, 255), width=20)
d.line([(900, 0), (120, SIZE)], fill=(8, 48, 160, 255), width=20)
hd.line([(120, 0), (900, SIZE)], fill=190, width=20)
hd.line([(900, 0), (120, SIZE)], fill=190, width=20)

skin_img.save(SKINS_DIR / "akaza_skin_albedo.png")
normal_from_height(np.array(h_img), strength=2.2).save(SKINS_DIR / "akaza_skin_normal.png")

# B. Akaza Haori (Rich Plum/Crimson Woven Cloth)
haori = Image.new("RGBA", (SIZE, SIZE), (88, 18, 54, 255))
hd_draw = ImageDraw.Draw(haori)
# Woven twill pattern
yy, xx = np.mgrid[0:SIZE, 0:SIZE]
twill = ((xx + yy) % 6 < 3).astype(np.float32) * 16.0
h_arr = np.array(haori).astype(np.float32)
for c in range(3):
    h_arr[:, :, c] = np.clip(h_arr[:, :, c] + twill, 0, 255)
# Golden/Crimson edge borders
for y in [30, SIZE - 30]:
    h_arr[y-6:y+6, :, 0] = 210
    h_arr[y-6:y+6, :, 1] = 160
    h_arr[y-6:y+6, :, 2] = 40
haori_out = Image.fromarray(h_arr.astype(np.uint8))
haori_out.save(SKINS_DIR / "akaza_haori_albedo.png")
normal_from_height(twill * 10, strength=1.5).save(SKINS_DIR / "akaza_haori_normal.png")

# C. Akaza Hakama (Pleated Martial Arts White Fabric)
hakama = Image.new("RGBA", (SIZE, SIZE), (242, 244, 248, 255))
pleats = (np.sin(xx * 0.05) * 18.0).astype(np.float32)
hk_arr = np.array(hakama).astype(np.float32)
for c in range(3):
    hk_arr[:, :, c] = np.clip(hk_arr[:, :, c] + pleats, 0, 255)
hk_out = Image.fromarray(hk_arr.astype(np.uint8))
hk_out.save(SKINS_DIR / "akaza_hakama_albedo.png")
normal_from_height(pleats * 8, strength=2.5).save(SKINS_DIR / "akaza_hakama_normal.png")

# D. Akaza 12-Pointed Snowflake Compass Mandala (Jutsushiki Tenkai)
compass_alb = Image.new("RGBA", (SIZE, SIZE), (10, 25, 45, 255))
compass_em = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 255))
ca = ImageDraw.Draw(compass_alb)
ce = ImageDraw.Draw(compass_em)

center = (SIZE // 2, SIZE // 2)
# Concentric glowing rings
for r, w in [(460, 6), (420, 4), (280, 5), (140, 4), (60, 6)]:
    bbox = [center[0] - r, center[1] - r, center[0] + r, center[1] + r]
    ca.ellipse(bbox, outline=(30, 210, 255, 255), width=w)
    ce.ellipse(bbox, outline=(0, 230, 255, 255), width=w)

# 12 Compass Snowflake Spokes
for i in range(12):
    angle = i * (2.0 * math.pi / 12.0)
    cos_a = math.cos(angle)
    sin_a = math.sin(angle)
    p2 = (center[0] + cos_a * 460, center[1] + sin_a * 460)
    ca.line([center, p2], fill=(20, 200, 255, 255), width=6)
    ce.line([center, p2], fill=(0, 240, 255, 255), width=6)

    # Snowflake branch chevrons
    for dist in [200, 320, 400]:
        bx = center[0] + cos_a * dist
        by = center[1] + sin_a * dist
        for side in [-0.55, 0.55]:
            b_angle = angle + side
            b_end = (bx + math.cos(b_angle) * 45, by + math.sin(b_angle) * 45)
            ca.line([(bx, by), b_end], fill=(50, 220, 255, 255), width=4)
            ce.line([(bx, by), b_end], fill=(0, 235, 255, 255), width=4)

compass_em = compass_em.filter(ImageFilter.GaussianBlur(radius=2))
compass_alb.save(SKINS_DIR / "akaza_compass_albedo.png")
compass_em.save(SKINS_DIR / "akaza_compass_emission.png")

print("2. Generating Blue-Eyes White Dragon High-Fidelity PBR Skins...")
# A. Platinum-White Crystal Scales
scale_alb = Image.new("RGBA", (SIZE, SIZE), (238, 244, 252, 255))
yy, xx = np.mgrid[0:SIZE, 0:SIZE]
hex_pattern = (np.sin(xx * 0.12) * np.cos(yy * 0.12) * 24.0).astype(np.float32)
sc_arr = np.array(scale_alb).astype(np.float32)
sc_arr[:, :, 0] = np.clip(sc_arr[:, :, 0] + hex_pattern * 0.7, 0, 255)
sc_arr[:, :, 1] = np.clip(sc_arr[:, :, 1] + hex_pattern * 0.85, 0, 255)
sc_arr[:, :, 2] = np.clip(sc_arr[:, :, 2] + hex_pattern * 1.1, 0, 255) # Icy tint
Image.fromarray(sc_arr.astype(np.uint8)).save(SKINS_DIR / "blue_eyes_scale_albedo.png")
normal_from_height(hex_pattern * 8.0, strength=2.2).save(SKINS_DIR / "blue_eyes_scale_normal.png")

# B. Cerulean Wing Membrane
wing_alb = Image.new("RGBA", (SIZE, SIZE), (80, 155, 230, 255))
veins = (np.sin(xx * 0.04 + np.cos(yy * 0.03) * 3.0) * 22.0).astype(np.float32)
w_arr = np.array(wing_alb).astype(np.float32)
w_arr[:, :, 0] = np.clip(w_arr[:, :, 0] + veins * 0.5, 0, 255)
w_arr[:, :, 1] = np.clip(w_arr[:, :, 1] + veins * 0.8, 0, 255)
w_arr[:, :, 2] = np.clip(w_arr[:, :, 2] + veins * 1.0, 0, 255)
Image.fromarray(w_arr.astype(np.uint8)).save(SKINS_DIR / "blue_eyes_wing_albedo.png")
normal_from_height(veins * 6.0, strength=1.8).save(SKINS_DIR / "blue_eyes_wing_normal.png")

# C. Icy Azure Underbelly Plate
chest_alb = Image.new("RGBA", (SIZE, SIZE), (200, 222, 245, 255))
seg_ridges = (np.cos(yy * 0.08) * 28.0).astype(np.float32)
c_arr = np.array(chest_alb).astype(np.float32)
for c in range(3):
    c_arr[:, :, c] = np.clip(c_arr[:, :, c] + seg_ridges, 0, 255)
Image.fromarray(c_arr.astype(np.uint8)).save(SKINS_DIR / "blue_eyes_chest_albedo.png")
normal_from_height(seg_ridges * 7.0, strength=2.4).save(SKINS_DIR / "blue_eyes_chest_normal.png")

# D. Burst Stream of Destruction Plasma Beam
burst_alb = Image.new("RGBA", (SIZE, SIZE), (210, 245, 255, 255))
burst_em = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 255))
ba = ImageDraw.Draw(burst_alb)
be = ImageDraw.Draw(burst_em)

for step in range(SIZE // 2, 0, -16):
    alpha = int(255 * (1.0 - (step / (SIZE // 2))))
    ba.ellipse([SIZE//2 - step, SIZE//2 - step, SIZE//2 + step, SIZE//2 + step],
               fill=(140, 220, 255, 60), outline=(180, 240, 255, 120))
    be.ellipse([SIZE//2 - step, SIZE//2 - step, SIZE//2 + step, SIZE//2 + step],
               fill=(int(20 * (1 - step/(SIZE//2))), int(180 * (1 - step/(SIZE//2))), int(255 * (1 - step/(SIZE//2))), 255))

burst_alb.save(SKINS_DIR / "blue_eyes_burst_albedo.png")
burst_em.save(SKINS_DIR / "blue_eyes_burst_emission.png")

print("3. Generating High-Res UI Portraits & Thumbnails...")
# Portrait Akaza
p_akaza = Image.new("RGBA", (256, 256), (15, 20, 32, 255))
pad = ImageDraw.Draw(p_akaza)
# Glowing cyan background burst
for r in range(120, 20, -10):
    pad.ellipse([128 - r, 128 - r, 128 + r, 128 + r], fill=(10, 50 + (120-r), 90 + (120-r), 255))
# Spiky magenta hair silhouette
pad.polygon([(128, 22), (105, 55), (120, 65), (90, 75), (105, 95), (151, 95), (166, 75), (136, 65), (151, 55)], fill=(217, 4, 82, 255))
# Pale demonic head & ears
pad.polygon([(78, 115), (95, 120), (95, 150), (78, 142)], fill=(235, 240, 248, 255)) # ear L
pad.polygon([(178, 115), (161, 120), (161, 150), (178, 142)], fill=(235, 240, 248, 255)) # ear R
pad.ellipse([92, 85, 164, 172], fill=(235, 240, 248, 255))
# Navy face tattoos
pad.line([(128, 92), (128, 128)], fill=(8, 48, 160, 255), width=4)
pad.line([(102, 128), (154, 128)], fill=(8, 48, 160, 255), width=4)
pad.line([(100, 145), (124, 154)], fill=(8, 48, 160, 255), width=3)
pad.line([(156, 145), (132, 154)], fill=(8, 48, 160, 255), width=3)
# Piercing gold eyes
pad.ellipse([106, 122, 118, 134], fill=(255, 200, 20, 255), outline=(180, 80, 0, 255))
pad.ellipse([138, 122, 150, 134], fill=(255, 200, 20, 255), outline=(180, 80, 0, 255))
pad.line([(112, 124), (112, 132)], fill=(40, 10, 0, 255), width=2)
pad.line([(144, 124), (144, 132)], fill=(40, 10, 0, 255), width=2)
# Plum Haori vest collar
pad.polygon([(75, 195), (105, 165), (128, 185), (151, 165), (181, 195), (181, 256), (75, 256)], fill=(97, 20, 60, 255))
pad.line([(105, 165), (128, 185)], fill=(220, 180, 50, 255), width=3)
pad.line([(151, 165), (128, 185)], fill=(220, 180, 50, 255), width=3)
p_akaza.save(UI_DIR / "portrait_akaza.png")
p_akaza.resize((128, 128), Image.Resampling.LANCZOS).save(THUMB_DIR / "thumb_akaza.png")

# Portrait Blue-Eyes White Dragon
p_be = Image.new("RGBA", (256, 256), (10, 18, 30, 255))
pbd = ImageDraw.Draw(p_be)
# Cold cerulean aurora background
for r in range(120, 20, -10):
    pbd.ellipse([128 - r, 128 - r, 128 + r, 128 + r], fill=(5, 35 + (120-r), 65 + (120-r), 255))
# Sweeping dragon horn crests
pbd.polygon([(128, 70), (70, 25), (105, 85)], fill=(195, 218, 245, 255), outline=(130, 175, 225, 255))
pbd.polygon([(128, 70), (186, 25), (151, 85)], fill=(195, 218, 245, 255), outline=(130, 175, 225, 255))
# Cheek horn spines
pbd.polygon([(75, 120), (35, 105), (82, 140)], fill=(185, 208, 235, 255))
pbd.polygon([(181, 120), (221, 105), (174, 140)], fill=(185, 208, 235, 255))
# Aerodynamic dragon skull & muzzle
pbd.polygon([(128, 75), (85, 115), (100, 195), (128, 215), (156, 195), (171, 115)], fill=(240, 246, 255, 255), outline=(170, 205, 245, 255))
# Underbelly plate
pbd.polygon([(112, 175), (128, 210), (144, 175), (128, 160)], fill=(185, 215, 245, 255))
# Piercing Ice-Blue Eyes (Legendary Cold Gaze)
pbd.polygon([(100, 125), (118, 120), (114, 132), (98, 134)], fill=(100, 225, 255, 255), outline=(0, 180, 245, 255))
pbd.polygon([(156, 125), (138, 120), (142, 132), (158, 134)], fill=(100, 225, 255, 255), outline=(0, 180, 245, 255))
pbd.ellipse([106, 124, 112, 130], fill=(255, 255, 255, 255))
pbd.ellipse([144, 124, 150, 130], fill=(255, 255, 255, 255))
# Razor upper fangs
pbd.polygon([(108, 190), (112, 204), (116, 190)], fill=(255, 255, 255, 255))
pbd.polygon([(140, 190), (144, 204), (148, 190)], fill=(255, 255, 255, 255))

p_be.save(UI_DIR / "portrait_blue_eyes.png")
p_be.resize((128, 128), Image.Resampling.LANCZOS).save(THUMB_DIR / "thumb_blue_eyes.png")

print("=== ALL PRO PBR SKINS AND PORTRAITS GENERATED SUCCESSFULLY! ===")
