"""Generate 1024x1024 PBR Texture Maps for Blue-Eyes White Dragon with NumPy vectorization."""
import numpy as np
from pathlib import Path
from PIL import Image, ImageFilter

ROOT = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate")
SKINS_DIR = ROOT / "godot/assets/textures/skins"
SKINS_DIR.mkdir(parents=True, exist_ok=True)

SIZE = 1024

def save(img: Image.Image, filename: str):
    p = SKINS_DIR / filename
    img.save(p, "PNG")
    print(f"Saved: {p.name}")

y_coords, x_coords = np.mgrid[0:SIZE, 0:SIZE]

# ─── 1. DRAGON SCALE (Pearl-White Iridescent with subtle blue specular) ─────
freq = 16.0
fx = (x_coords / SIZE) * freq * np.pi * 2.0
fy = (y_coords / SIZE) * freq * np.pi * 2.0
val = (np.sin(fx) * np.cos(fy) + np.sin(fx * 0.5 + fy * 0.866)) * 0.5
v_u8 = np.clip(238 + val * 16, 220, 255).astype(np.uint8)

scale_arr = np.zeros((SIZE, SIZE, 4), dtype=np.uint8)
scale_arr[..., 0] = v_u8
scale_arr[..., 1] = np.clip(v_u8.astype(int) + 2, 0, 255).astype(np.uint8)
scale_arr[..., 2] = np.clip(v_u8.astype(int) + 6, 0, 255).astype(np.uint8)
scale_arr[..., 3] = 255

norm_arr = np.zeros((SIZE, SIZE, 4), dtype=np.uint8)
norm_arr[..., 0] = np.clip(128 + np.cos(fx) * 35.0, 0, 255).astype(np.uint8)
norm_arr[..., 1] = np.clip(128 + np.sin(fy) * 35.0, 0, 255).astype(np.uint8)
norm_arr[..., 2] = 235
norm_arr[..., 3] = 255

img_scale_alb = Image.fromarray(scale_arr, "RGBA")
img_scale_nrm = Image.fromarray(norm_arr, "RGBA").filter(ImageFilter.GaussianBlur(1.0))
save(img_scale_alb, "blue_eyes_scale_albedo.png")
save(img_scale_nrm, "blue_eyes_scale_normal.png")

# ─── 2. WING MEMBRANE (Pale Blue / White Sail with wing venation lines) ─────
tx = x_coords / SIZE
ty = y_coords / SIZE
vein = np.sin((tx * 14.0 + np.sin(ty * 8.0) * 1.5) * np.pi) * 0.5 + 0.5
base_col = (210 + (1.0 - ty * 0.25) * 35.0 + vein * 8.0).astype(int)

wing_arr = np.zeros((SIZE, SIZE, 4), dtype=np.uint8)
wing_arr[..., 0] = np.clip(base_col - 15, 180, 255).astype(np.uint8)
wing_arr[..., 1] = np.clip(base_col + 2, 0, 255).astype(np.uint8)
wing_arr[..., 2] = np.clip(base_col + 15, 0, 255).astype(np.uint8)
wing_arr[..., 3] = 255

wing_norm = np.zeros((SIZE, SIZE, 4), dtype=np.uint8)
wing_norm[..., 0] = np.clip(128 + (vein - 0.5) * 45.0, 0, 255).astype(np.uint8)
wing_norm[..., 1] = np.clip(128 + np.cos(ty * 12.0) * 20.0, 0, 255).astype(np.uint8)
wing_norm[..., 2] = 240
wing_norm[..., 3] = 255

img_wing_alb = Image.fromarray(wing_arr, "RGBA")
img_wing_nrm = Image.fromarray(wing_norm, "RGBA").filter(ImageFilter.GaussianBlur(1.5))
save(img_wing_alb, "blue_eyes_wing_albedo.png")
save(img_wing_nrm, "blue_eyes_wing_normal.png")

# ─── 3. CHEST UNDERBELLY PLATES (Segmented Platinum Silver Armor) ───────────
rib = np.sin((y_coords / SIZE) * 24.0 * np.pi)
curve = 1.0 - np.abs(x_coords / SIZE - 0.5) * 1.2
val_chest = (205 + rib * 22.0 * curve).astype(int)

chest_arr = np.zeros((SIZE, SIZE, 4), dtype=np.uint8)
chest_arr[..., 0] = np.clip(val_chest, 0, 255).astype(np.uint8)
chest_arr[..., 1] = np.clip(val_chest + 4, 0, 255).astype(np.uint8)
chest_arr[..., 2] = np.clip(val_chest + 12, 0, 255).astype(np.uint8)
chest_arr[..., 3] = 255

chest_norm = np.zeros((SIZE, SIZE, 4), dtype=np.uint8)
chest_norm[..., 0] = 128
chest_norm[..., 1] = np.clip(128 + rib * 55.0, 0, 255).astype(np.uint8)
chest_norm[..., 2] = 230
chest_norm[..., 3] = 255

img_chest_alb = Image.fromarray(chest_arr, "RGBA")
img_chest_nrm = Image.fromarray(chest_norm, "RGBA").filter(ImageFilter.GaussianBlur(1.2))
save(img_chest_alb, "blue_eyes_chest_albedo.png")
save(img_chest_nrm, "blue_eyes_chest_normal.png")

# ─── 4. BURST STREAM OF DESTRUCTION (Cyan/White High-Energy Beam Emission) ──
core_y = 1.0 - np.abs(y_coords / SIZE - 0.5) * 2.0
pulse = np.sin((x_coords / SIZE) * 32.0 * np.pi) * 0.2 + 0.8
glow = np.clip(core_y * pulse * 255, 0, 255).astype(np.uint8)

beam_arr = np.zeros((SIZE, SIZE, 4), dtype=np.uint8)
beam_arr[..., 0] = np.clip(glow.astype(int) * 0.7 + 70, 0, 255).astype(np.uint8)
beam_arr[..., 1] = np.clip(glow.astype(int) * 0.95 + 10, 0, 255).astype(np.uint8)
beam_arr[..., 2] = 255
beam_arr[..., 3] = 255

beam_em = np.zeros((SIZE, SIZE, 4), dtype=np.uint8)
beam_em[..., 0] = (glow.astype(int) * 0.6).astype(np.uint8)
beam_em[..., 1] = (glow.astype(int) * 0.95).astype(np.uint8)
beam_em[..., 2] = glow
beam_em[..., 3] = 255

img_beam_alb = Image.fromarray(beam_arr, "RGBA")
img_beam_em  = Image.fromarray(beam_em, "RGBA").filter(ImageFilter.GaussianBlur(2.0))
save(img_beam_alb, "blue_eyes_burst_albedo.png")
save(img_beam_em,  "blue_eyes_burst_emission.png")

print("=== All Blue-Eyes PBR maps generated successfully! ===")
