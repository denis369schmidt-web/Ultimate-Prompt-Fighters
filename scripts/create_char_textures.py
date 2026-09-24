# -*- coding: utf-8 -*-
import sys, subprocess, random, math
from pathlib import Path
try:
    from PIL import Image, ImageDraw, ImageFilter
except ImportError:
    subprocess.check_call([sys.executable, '-m', 'pip', 'install', 'pillow', '--quiet'])
    from PIL import Image, ImageDraw, ImageFilter

OUT = Path(r'C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate\godot\assets\textures\skins')
OUT.mkdir(parents=True, exist_ok=True)

# --- SUB-ZERO ARMOR TEXTURE (512x512) ---
img = Image.new('RGB', (512, 512), (15, 25, 55))
draw = ImageDraw.Draw(img)
for y in range(0, 512, 32):
    draw.rectangle([0, y, 511, y+2], fill=(8, 15, 38))
    draw.rectangle([0, y+28, 511, y+30], fill=(40, 65, 120))
for x in range(0, 512, 64):
    draw.rectangle([x, 0, x+1, 511], fill=(8, 15, 38))
for y in range(100, 200, 8):
    alpha = int(20 * (1 - abs(y - 150) / 50.0))
    draw.rectangle([150, y, 362, y+6], fill=(25+alpha, 45+alpha, 90+alpha))
for i in range(40):
    random.seed(i * 7)
    x = random.randint(20, 490)
    y = random.randint(20, 490)
    r = random.randint(2, 5)
    draw.ellipse([x-r, y-r, x+r, y+r], fill=(100, 220, 255))
img = img.filter(ImageFilter.GaussianBlur(0.8))
img.save(str(OUT / 'subzero_armor_albedo.png'))
print('Saved subzero_armor_albedo.png')

# --- SUB-ZERO ICE EMISSION (512x512) ---
img2 = Image.new('RGB', (512, 512), (0, 0, 0))
draw2 = ImageDraw.Draw(img2)
for i in range(20):
    random.seed(i * 13 + 100)
    x1 = random.randint(0, 512)
    y1 = random.randint(0, 512)
    x2 = x1 + random.randint(-80, 80)
    y2 = y1 + random.randint(-80, 80)
    brightness = random.randint(150, 255)
    draw2.line([x1, y1, x2, y2], fill=(brightness//4, brightness, 255), width=2)
for i in range(8):
    random.seed(i * 31)
    x = random.randint(50, 460)
    y = random.randint(50, 460)
    draw2.ellipse([x-15, y-15, x+15, y+15], fill=(50, 200, 255))
    draw2.ellipse([x-8, y-8, x+8, y+8], fill=(150, 230, 255))
img2 = img2.filter(ImageFilter.GaussianBlur(1.5))
img2.save(str(OUT / 'subzero_ice_emission.png'))
print('Saved subzero_ice_emission.png')

# --- PAIN CLOAK TEXTURE (512x512) ---
img3 = Image.new('RGB', (512, 512), (12, 12, 14))
draw3 = ImageDraw.Draw(img3)
for y in range(0, 512, 3):
    brightness = 14 if y % 6 == 0 else 16
    draw3.rectangle([0, y, 511, y+1], fill=(brightness, brightness, brightness+2))
for x in range(0, 512, 48):
    for y in range(0, 512):
        fold = int(4 * math.sin(x/30.0 + y/80.0))
        px = min(x+20, 511)
        current = img3.getpixel((px, y))
        new_val = tuple(min(255, max(0, c + fold)) for c in current)
        draw3.point((px, y), fill=new_val)
cloud_positions = [(80, 120), (250, 200), (400, 150), (150, 350), (350, 380)]
for cx, cy in cloud_positions:
    draw3.ellipse([cx-35, cy-18, cx+35, cy+18], fill=(140, 15, 10))
    for bx in [-20, 0, 20]:
        draw3.ellipse([cx+bx-14, cy-28, cx+bx+14, cy], fill=(140, 15, 10))
    draw3.ellipse([cx-36, cy-19, cx+36, cy+19], outline=(200, 20, 15), width=2)
img3.save(str(OUT / 'pain_cloak_albedo.png'))
print('Saved pain_cloak_albedo.png')

# --- PAIN RINNEGAN EMISSION (256x256) ---
img4 = Image.new('RGB', (256, 256), (10, 0, 20))
draw4 = ImageDraw.Draw(img4)
cx, cy = 128, 128
for r in range(120, 0, -1):
    intensity = int(180 * (1 - r/120.0))
    color = (intensity//3, 0, intensity)
    draw4.ellipse([cx-r, cy-r, cx+r, cy+r], fill=color)
for ring in range(1, 7):
    rr = ring * 16
    draw4.ellipse([cx-rr, cy-rr, cx+rr, cy+rr], outline=(180, 30, 220), width=2)
draw4.ellipse([cx-8, cy-8, cx+8, cy+8], fill=(220, 100, 255))
img4 = img4.filter(ImageFilter.GaussianBlur(1.2))
img4.save(str(OUT / 'pain_rinnegan_emission.png'))
print('Saved pain_rinnegan_emission.png')

# --- GOKU GI TEXTURE (512x512) ---
img5 = Image.new('RGB', (512, 512), (200, 75, 20))
draw5 = ImageDraw.Draw(img5)
for y in range(0, 512, 4):
    for x in range(0, 512, 4):
        grain = int(8 * math.sin(x/3.0) * math.cos(y/3.0))
        px5 = img5.getpixel((x, y))
        new_c = tuple(min(255, max(0, c + grain)) for c in px5)
        draw5.point((x, y), fill=new_c)
for x in range(0, 512, 60):
    for y in range(512):
        fold = int(-15 * abs(math.sin(x/40.0 + y/100.0)))
        px5 = img5.getpixel((min(x+10, 511), y))
        new_c = tuple(min(255, max(0, c + fold)) for c in px5)
        draw5.point((min(x+10, 511), y), fill=new_c)
img5.save(str(OUT / 'goku_gi_albedo.png'))
print('Saved goku_gi_albedo.png')

print('=== ALL TEXTURES CREATED ===')
