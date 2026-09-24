"""Generate ultra high-fidelity PBR textures for Sonic the Hedgehog.
Includes Albedo, Normal and Emissive maps for fur, shoes, skin and buckles.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
import numpy as np
import math

OUT_DIR = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate\godot\assets\textures\skins")
OUT_DIR.mkdir(parents=True, exist_ok=True)

SIZE = 1024

def save_image(img: Image.Image, name: str):
    path = OUT_DIR / name
    img.save(path, format="PNG")
    print(f"[OK] Saved {name}")

def height_to_normal(height_arr: np.ndarray, strength: float = 2.5) -> Image.Image:
    # Compute Sobel gradients
    gy, gx = np.gradient(height_arr.astype(float))
    gx = gx * strength
    gy = gy * strength
    gz = np.ones_like(gx) * 255.0
    
    norm = np.sqrt(gx**2 + gy**2 + gz**2)
    nx = (gx / norm) * 127.5 + 128.0
    ny = (-gy / norm) * 127.5 + 128.0
    nz = (gz / norm) * 127.5 + 128.0
    
    normal_rgb = np.stack([nx, ny, nz], axis=-1).clip(0, 255).astype(np.uint8)
    return Image.fromarray(normal_rgb, mode="RGB")

# 1. SONIC FUR ALBEDO & NORMAL & EMISSION
print("Generating Sonic Fur Maps...")
fur_albedo = Image.new("RGB", (SIZE, SIZE), (13, 71, 187)) # Iconic Sonic Cobalt Blue
draw_fur = ImageDraw.Draw(fur_albedo)

# Add silky fur fiber directional streaks
np.random.seed(1991) # Sonic 1 debut year
height_fur = np.zeros((SIZE, SIZE), dtype=np.float32)

# Layer 1: Directional fur streaks
for _ in range(4000):
    x = np.random.randint(0, SIZE)
    y = np.random.randint(0, SIZE)
    length = np.random.randint(15, 45)
    angle = np.random.uniform(-0.3, 0.3) + math.pi * 0.5 # Flowing backwards
    x2 = int(x + math.cos(angle) * length)
    y2 = int(y + math.sin(angle) * length)
    
    val = np.random.randint(18, 48)
    color = (13 + val, 71 + val, min(255, 187 + val))
    draw_fur.line([(x, y), (x2, y2)], fill=color, width=np.random.randint(1, 3))

# Blend in smooth radial gradient highlights for curved hedgehog body
grad = np.fromfunction(lambda y, x: np.sin(x / SIZE * math.pi) * np.sin(y / SIZE * math.pi), (SIZE, SIZE))
fur_np = np.array(fur_albedo, dtype=np.float32)
for c in range(3):
    fur_np[:, :, c] = fur_np[:, :, c] * (0.80 + 0.35 * grad)
fur_albedo = Image.fromarray(fur_np.clip(0, 255).astype(np.uint8))
fur_albedo = fur_albedo.filter(ImageFilter.GaussianBlur(radius=0.8))
save_image(fur_albedo, "sonic_fur_albedo.png")

# Normal map for fur
fur_gray = np.array(fur_albedo.convert("L"), dtype=np.float32)
fur_normal = height_to_normal(fur_gray, strength=3.0)
save_image(fur_normal, "sonic_fur_normal.png")

# Sonic Quill Emission (Cyan chaos energy glow along quill tips)
quill_em = Image.new("RGB", (SIZE, SIZE), (0, 0, 0))
draw_em = ImageDraw.Draw(quill_em)
for y in range(0, SIZE, 64):
    for x in range(0, SIZE, 64):
        dist = math.sqrt((x - SIZE/2)**2 + (y - SIZE/2)**2)
        if dist > 260:
            intensity = int(min(255, (dist - 260) * 0.8))
            draw_em.ellipse([x-24, y-24, x+24, y+24], fill=(0, int(intensity*0.9), intensity))
quill_em = quill_em.filter(ImageFilter.GaussianBlur(radius=28))
save_image(quill_em, "sonic_quill_emission.png")


# 2. SONIC POWER SNEAKERS (Albedo, Normal, Buckle Emission)
print("Generating Sonic Sneaker Maps...")
shoe_albedo = Image.new("RGB", (SIZE, SIZE), (213, 0, 0)) # Bold Ferrari Red
draw_shoe = ImageDraw.Draw(shoe_albedo)

# White strap across center
draw_shoe.rectangle([0, int(SIZE*0.40), SIZE, int(SIZE*0.60)], fill=(245, 245, 248))
# Gold Buckle in middle-right
buckle_box = [int(SIZE*0.65), int(SIZE*0.35), int(SIZE*0.85), int(SIZE*0.65)]
draw_shoe.rectangle(buckle_box, fill=(245, 190, 24), outline=(180, 130, 10), width=12)
draw_shoe.rectangle([buckle_box[0]+28, buckle_box[1]+28, buckle_box[2]-28, buckle_box[3]-28], fill=(213, 0, 0))

# Dark grey rubber sole at bottom
draw_shoe.rectangle([0, int(SIZE*0.88), SIZE, SIZE], fill=(45, 48, 52))
# Tread lines
for tx in range(0, SIZE, 48):
    draw_shoe.line([(tx, int(SIZE*0.88)), (tx, SIZE)], fill=(25, 26, 28), width=8)

save_image(shoe_albedo, "sonic_shoe_albedo.png")

# Sneaker Normal map
shoe_gray = np.array(shoe_albedo.convert("L"), dtype=np.float32)
shoe_normal = height_to_normal(shoe_gray, strength=2.2)
save_image(shoe_normal, "sonic_shoe_normal.png")

# Buckle emission
buckle_em = Image.new("RGB", (SIZE, SIZE), (0, 0, 0))
draw_b_em = ImageDraw.Draw(buckle_em)
draw_b_em.rectangle(buckle_box, fill=(255, 200, 30))
buckle_em = buckle_em.filter(ImageFilter.GaussianBlur(radius=6))
save_image(buckle_em, "sonic_buckle_emission.png")


# 3. SONIC PEACH SKIN (Muzzle, Ears, Belly)
print("Generating Sonic Peach Skin...")
skin_albedo = Image.new("RGB", (SIZE, SIZE), (254, 208, 168)) # Warm peach
draw_skin = ImageDraw.Draw(skin_albedo)
# Soft skin grain & warm gradient
for _ in range(5000):
    sx = np.random.randint(0, SIZE)
    sy = np.random.randint(0, SIZE)
    v = np.random.randint(-6, 6)
    draw_skin.point((sx, sy), fill=(254 + v, 208 + v, 168 + v))
skin_albedo = skin_albedo.filter(ImageFilter.GaussianBlur(radius=1.0))
save_image(skin_albedo, "sonic_skin_albedo.png")

print("=== ALL SONIC PBR TEXTURES GENERATED SUCCESSFULLY ===")
