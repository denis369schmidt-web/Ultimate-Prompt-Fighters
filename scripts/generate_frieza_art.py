"""Generate HD Visual Art, UI Portrait & MK Thumbnail for Final Form Frieza:
Emperor of the Universe (Purple Gem Head Dome, Crimson Eyes, Death Beam & Supernova Flare)
"""
import math, numpy as np
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate")
UI_DIR = ROOT / "godot/assets/textures/ui"
THUMB_DIR = ROOT / "godot/assets/textures/characters/thumbs"

UI_DIR.mkdir(parents=True, exist_ok=True)
THUMB_DIR.mkdir(parents=True, exist_ok=True)

SIZE_PORTRAIT = 512
SIZE_THUMB = 256

def draw_vignette(img, border_color, glow_color):
    draw = ImageDraw.Draw(img)
    w, h = img.size
    for b in range(6):
        alpha = int(255 * (1.0 - b / 6.0))
        draw.rectangle([b, b, w - 1 - b, h - 1 - b], outline=(*glow_color, alpha))
    draw.rectangle([0, 0, w - 1, h - 1], outline=(*border_color, 255), width=3)
    return img

def frieza_art(d, S):
    cx, cy = S // 2, S // 2
    # Sleek White Bio-Carapace Head
    d.ellipse([cx - 85, cy - 100, cx + 85, cy + 65], fill=(245, 245, 250, 255))
    
    # Polished Purple Gem Skull Dome
    d.ellipse([cx - 65, cy - 95, cx + 65, cy - 25], fill=(130, 25, 185, 255), outline=(90, 10, 130), width=3)
    # Gem Gleam Highlight
    d.ellipse([cx - 40, cy - 85, cx - 15, cy - 65], fill=(210, 140, 255, 220))
    
    # Ear Indentation Vent Disks
    d.ellipse([cx - 88, cy - 15, cx - 74, cy + 15], fill=(120, 20, 170, 255), outline=(80, 10, 120), width=2)
    d.ellipse([cx + 74, cy - 15, cx + 88, cy + 15], fill=(120, 20, 170, 255), outline=(80, 10, 120), width=2)
    
    # Piercing Crimson Eyes with Eyeliner Lines
    d.polygon([(cx - 48, cy - 15), (cx - 18, cy - 8), (cx - 32, cy + 4)], fill=(235, 20, 45, 255))
    d.polygon([(cx + 48, cy - 15), (cx + 18, cy - 8), (cx + 32, cy + 4)], fill=(235, 20, 45, 255))
    # Vertical Cheek Eyeliner Stripes
    d.line([(cx - 32, cy + 5), (cx - 32, cy + 45)], fill=(30, 30, 35), width=4)
    d.line([(cx + 32, cy + 5), (cx + 32, cy + 45)], fill=(30, 30, 35), width=4)
    # Cold Smirking Lips
    d.line([(cx - 22, cy + 40), (cx, cy + 45), (cx + 25, cy + 38)], fill=(120, 20, 170), width=3)

    # Torso & Purple Chest Shield
    d.rectangle([cx - 75, cy + 65, cx + 75, cy + 180], fill=(240, 240, 245, 255))
    d.ellipse([cx - 35, cy + 75, cx + 35, cy + 145], fill=(130, 25, 185, 255), outline=(90, 10, 130), width=3)
    
    # Purple Shoulder Capes
    d.ellipse([cx - 110, cy + 65, cx - 60, cy + 115], fill=(130, 25, 185, 255))
    d.ellipse([cx + 60, cy + 65, cx + 110, cy + 115], fill=(130, 25, 185, 255))

    # Right Hand DEATH BEAM Ray & Spark Flare
    bx, by = cx + 120, cy + 70
    for ray in range(8):
        ang = ray * (math.pi * 2.0 / 8.0)
        d.line([(bx, by), (bx + math.cos(ang) * 55, by + math.sin(ang) * 55)], fill=(255, 60, 120, 220), width=3)
    d.ellipse([bx - 18, by - 18, bx + 18, by + 18], fill=(255, 30, 80, 255))
    d.ellipse([bx - 8, by - 8, bx + 8, by + 8], fill=(255, 220, 240, 255))
    # Piercing Laser Beam line extending left
    d.line([(bx, by), (0, by - 20)], fill=(255, 50, 110, 240), width=6)

    # OVERHEAD SUPERNOVA / DEATH BALL (Golden Orange/Red Sun)
    sx, sy = cx - 120, cy - 120
    for r in range(80, 20, -10):
        alpha = int(180 * (r / 80.0))
        d.ellipse([sx - r, sy - r, sx + r, sy + r], fill=(255, 120 - r, 30, alpha))
    d.ellipse([sx - 35, sy - 35, sx + 35, sy + 35], fill=(255, 200, 50, 255))

def generate():
    print("Generating Frieza HD Portrait & Thumbnail...")
    p_img = Image.new("RGBA", (SIZE_PORTRAIT, SIZE_PORTRAIT), (25, 10, 35, 255))
    d = ImageDraw.Draw(p_img)

    # Background gradient
    for y in range(SIZE_PORTRAIT):
        t = y / float(SIZE_PORTRAIT)
        r = int(25 * (1 - t) + 70 * t)
        g = int(10 * (1 - t) + 15 * t)
        b = int(35 * (1 - t) + 85 * t)
        d.line([(0, y), (SIZE_PORTRAIT, y)], fill=(r, g, b, 255))

    # Imperial Aura Rings
    for rad in range(70, 230, 18):
        alpha = int(max(0, 180 - rad * 0.7))
        d.ellipse([SIZE_PORTRAIT // 2 - rad, SIZE_PORTRAIT // 2 - rad, SIZE_PORTRAIT // 2 + rad, SIZE_PORTRAIT // 2 + rad], outline=(180, 50, 240, alpha), width=3)

    frieza_art(d, SIZE_PORTRAIT)
    draw_vignette(p_img, (180, 40, 220), (255, 80, 160))

    port_path = UI_DIR / "portrait_frieza.png"
    p_img.save(port_path)
    print(f"Saved: {port_path}")

    t_img = p_img.resize((SIZE_THUMB, SIZE_THUMB), Image.Resampling.LANCZOS)
    draw_vignette(t_img, (180, 40, 220), (255, 80, 160))
    thumb_path = THUMB_DIR / "thumb_frieza.png"
    t_img.save(thumb_path)
    print(f"Saved: {thumb_path}")

if __name__ == "__main__":
    generate()
