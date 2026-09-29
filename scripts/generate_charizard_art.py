"""Generate HD Visual Art, UI Portrait & MK Thumbnail for Charizard (Glurak):
Flame Dragon (Dual Horns, Cream Underbelly, Crimson Wings, White Talons & Tail Flame)
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

def charizard_art(d, S):
    cx, cy = S // 2, S // 2
    scale = S / 512.0

    # 1. Background Crimson Wing in silhouette
    wing_pts = [
        (cx - int(40 * scale), cy - int(20 * scale)),
        (cx + int(60 * scale), cy - int(190 * scale)),
        (cx + int(190 * scale), cy - int(220 * scale)),
        (cx + int(240 * scale), cy - int(130 * scale)),
        (cx + int(190 * scale), cy - int(70 * scale)),
        (cx + int(220 * scale), cy + int(10 * scale)),
        (cx + int(160 * scale), cy + int(40 * scale)),
        (cx + int(110 * scale), cy + int(30 * scale)),
        (cx + int(50 * scale), cy + int(60 * scale))
    ]
    d.polygon(wing_pts, fill=(185, 42, 38, 255))
    # Wing structural bone struts
    d.line([(cx - int(30 * scale), cy - int(10 * scale)), (cx + int(60 * scale), cy - int(190 * scale)), (cx + int(190 * scale), cy - int(220 * scale))], fill=(235, 110, 30), width=int(10 * scale))
    d.line([(cx + int(60 * scale), cy - int(190 * scale)), (cx + int(190 * scale), cy - int(70 * scale))], fill=(225, 100, 25), width=int(6 * scale))
    d.line([(cx + int(60 * scale), cy - int(190 * scale)), (cx + int(160 * scale), cy + int(40 * scale))], fill=(225, 100, 25), width=int(6 * scale))

    # 2. Torso & Cream Chest
    d.ellipse([cx - int(110 * scale), cy + int(60 * scale), cx + int(120 * scale), cy + int(260 * scale)], fill=(242, 120, 34, 255))
    # Cream Chest / Underbelly Plate
    d.ellipse([cx - int(75 * scale), cy + int(75 * scale), cx + int(45 * scale), cy + int(250 * scale)], fill=(248, 225, 148, 255))

    # Dorsal Spines on back
    for sy, sx in [(cy + int(70 * scale), cx + int(90 * scale)), (cy + int(115 * scale), cx + int(105 * scale)), (cy + int(165 * scale), cx + int(112 * scale))]:
        d.polygon([(sx, sy), (sx + int(25 * scale), sy - int(15 * scale)), (sx + int(5 * scale), sy + int(20 * scale))], fill=(230, 105, 25))

    # 3. Robust Neck
    d.polygon([
        (cx - int(65 * scale), cy + int(75 * scale)),
        (cx + int(45 * scale), cy + int(70 * scale)),
        (cx + int(25 * scale), cy - int(50 * scale)),
        (cx - int(55 * scale), cy - int(45 * scale))
    ], fill=(242, 120, 34, 255))
    # Cream Throat Strip
    d.polygon([
        (cx - int(65 * scale), cy + int(75 * scale)),
        (cx - int(20 * scale), cy + int(72 * scale)),
        (cx - int(25 * scale), cy - int(42 * scale)),
        (cx - int(55 * scale), cy - int(45 * scale))
    ], fill=(248, 225, 148, 255))

    # 4. Swept-Back Dual Horns
    # Left Horn (behind)
    d.polygon([
        (cx + int(10 * scale), cy - int(60 * scale)),
        (cx + int(85 * scale), cy - int(135 * scale)),
        (cx + int(70 * scale), cy - int(145 * scale)),
        (cx - int(5 * scale), cy - int(75 * scale))
    ], fill=(225, 100, 26, 255))
    d.ellipse([cx + int(65 * scale), cy - int(152 * scale), cx + int(90 * scale), cy - int(132 * scale)], fill=(225, 100, 26, 255))

    # Right Horn (foreground)
    d.polygon([
        (cx - int(25 * scale), cy - int(70 * scale)),
        (cx + int(45 * scale), cy - int(150 * scale)),
        (cx + int(28 * scale), cy - int(160 * scale)),
        (cx - int(42 * scale), cy - int(85 * scale))
    ], fill=(242, 120, 34, 255))
    d.ellipse([cx + int(25 * scale), cy - int(166 * scale), cx + int(52 * scale), cy - int(144 * scale)], fill=(242, 120, 34, 255))

    # 5. Head Skull & Snout
    # Skull
    d.ellipse([cx - int(70 * scale), cy - int(95 * scale), cx + int(35 * scale), cy - int(15 * scale)], fill=(242, 120, 34, 255))
    # Snout
    d.polygon([
        (cx - int(55 * scale), cy - int(70 * scale)),
        (cx - int(165 * scale), cy - int(45 * scale)),
        (cx - int(160 * scale), cy - int(15 * scale)),
        (cx - int(40 * scale), cy - int(20 * scale))
    ], fill=(242, 120, 34, 255))
    # Nostril
    d.ellipse([cx - int(150 * scale), cy - int(42 * scale), cx - int(135 * scale), cy - int(32 * scale)], fill=(80, 25, 15, 255))

    # Open Lower Jaw
    d.polygon([
        (cx - int(50 * scale), cy - int(15 * scale)),
        (cx - int(140 * scale), cy + int(15 * scale)),
        (cx - int(120 * scale), cy + int(42 * scale)),
        (cx - int(35 * scale), cy + int(20 * scale))
    ], fill=(235, 110, 30, 255))
    # Cream Chin
    d.ellipse([cx - int(85 * scale), cy + int(18 * scale), cx - int(30 * scale), cy + int(42 * scale)], fill=(248, 225, 148, 255))

    # Mouth Interior (dark red)
    d.polygon([
        (cx - int(45 * scale), cy - int(12 * scale)),
        (cx - int(135 * scale), cy + int(10 * scale)),
        (cx - int(40 * scale), cy + int(15 * scale))
    ], fill=(95, 22, 28, 255))

    # Sharp White Conical Teeth
    # Upper Teeth
    for tx in [cx - int(150 * scale), cx - int(125 * scale), cx - int(100 * scale), cx - int(75 * scale)]:
        d.polygon([(tx, cy - int(18 * scale)), (tx + int(10 * scale), cy - int(18 * scale)), (tx + int(5 * scale), cy - int(2 * scale))], fill=(248, 248, 244, 255))
    # Lower Teeth
    for tx in [cx - int(130 * scale), cx - int(105 * scale), cx - int(80 * scale)]:
        d.polygon([(tx, cy + int(12 * scale)), (tx + int(10 * scale), cy + int(12 * scale)), (tx + int(5 * scale), cy - int(4 * scale))], fill=(248, 248, 244, 255))

    # 6. Eye & Piercing Red Iris
    d.polygon([
        (cx - int(80 * scale), cy - int(65 * scale)),
        (cx - int(45 * scale), cy - int(75 * scale)),
        (cx - int(35 * scale), cy - int(55 * scale)),
        (cx - int(65 * scale), cy - int(50 * scale))
    ], fill=(45, 18, 12, 255))
    # Red Iris
    d.ellipse([cx - int(68 * scale), cy - int(70 * scale), cx - int(42 * scale), cy - int(52 * scale)], fill=(235, 25, 35, 255))
    # Black Pupil Slit
    d.ellipse([cx - int(58 * scale), cy - int(68 * scale), cx - int(50 * scale), cy - int(54 * scale)], fill=(15, 10, 15, 255))
    # White Eye Reflection
    d.ellipse([cx - int(62 * scale), cy - int(66 * scale), cx - int(56 * scale), cy - int(60 * scale)], fill=(255, 255, 255, 255))
    # Brow Ridge
    d.line([(cx - int(85 * scale), cy - int(70 * scale)), (cx - int(32 * scale), cy - int(80 * scale))], fill=(210, 90, 20), width=int(5 * scale))

    # 7. Foreground Arm & 3 White Claws
    d.ellipse([cx - int(90 * scale), cy + int(110 * scale), cx - int(25 * scale), cy + int(175 * scale)], fill=(242, 120, 34, 255))
    # 3 Curved White Hand Claws
    for ci, (cax, cay) in enumerate([(-105, 150), (-110, 168), (-95, 185)]):
        d.polygon([
            (cx + int(cax * scale), cy + int(cay * scale)),
            (cx + int((cax - 22) * scale), cy + int((cay + 5) * scale)),
            (cx + int((cax - 5) * scale), cy + int((cay + 12) * scale))
        ], fill=(248, 248, 244, 255))

    # 8. Blazing Tail Flame in Bottom Right
    flame_cx, flame_cy = cx + int(160 * scale), cy + int(150 * scale)
    # Flame Outer Aura
    for r, col in [(65, (255, 60, 10, 90)), (50, (255, 120, 20, 140)), (35, (255, 190, 30, 200)), (18, (255, 240, 150, 255))]:
        d.ellipse([flame_cx - int(r * scale), flame_cy - int(r * scale * 1.5), flame_cx + int(r * scale), flame_cy + int(r * scale * 0.8)], fill=col)

def create_charizard_art():
    # 1. UI Portrait (512x512)
    p_img = Image.new("RGBA", (SIZE_PORTRAIT, SIZE_PORTRAIT), (0, 0, 0, 0))
    # Epic infernal gradient background
    bg = Image.new("RGBA", (SIZE_PORTRAIT, SIZE_PORTRAIT))
    bg_draw = ImageDraw.Draw(bg)
    for y in range(SIZE_PORTRAIT):
        t = y / float(SIZE_PORTRAIT)
        r = int(35 + t * 45)
        g = int(12 + t * 20)
        b = int(18 + t * 15)
        bg_draw.line([(0, y), (SIZE_PORTRAIT, y)], fill=(r, g, b, 255))
    
    # Blazing glow circle behind Charizard
    glow = Image.new("RGBA", (SIZE_PORTRAIT, SIZE_PORTRAIT), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    for r in range(220, 0, -10):
        alpha = int(90 * (1.0 - r / 220.0))
        glow_draw.ellipse([256 - r, 240 - r, 256 + r, 240 + r], fill=(255, 100, 20, alpha))
    glow = glow.filter(ImageFilter.GaussianBlur(15))
    bg = Image.alpha_composite(bg, glow)

    # Render Charizard
    fg = Image.new("RGBA", (SIZE_PORTRAIT, SIZE_PORTRAIT), (0, 0, 0, 0))
    fg_draw = ImageDraw.Draw(fg)
    charizard_art(fg_draw, SIZE_PORTRAIT)
    p_img = Image.alpha_composite(bg, fg)

    # Polished Border
    p_img = draw_vignette(p_img, (255, 120, 20), (255, 60, 10))
    portrait_out = UI_DIR / "portrait_charizard.png"
    p_img.save(portrait_out, "PNG")
    print(f"SAVED PORTRAIT: {portrait_out} ({portrait_out.stat().st_size} bytes)")

    # 2. MK Thumbnail (256x256)
    t_img = Image.new("RGBA", (SIZE_THUMB, SIZE_THUMB), (0, 0, 0, 0))
    t_bg = Image.new("RGBA", (SIZE_THUMB, SIZE_THUMB))
    t_bg_draw = ImageDraw.Draw(t_bg)
    for y in range(SIZE_THUMB):
        t = y / float(SIZE_THUMB)
        r = int(40 + t * 50)
        g = int(15 + t * 25)
        b = int(20 + t * 15)
        t_bg_draw.line([(0, y), (SIZE_THUMB, y)], fill=(r, g, b, 255))
    
    t_glow = Image.new("RGBA", (SIZE_THUMB, SIZE_THUMB), (0, 0, 0, 0))
    t_glow_draw = ImageDraw.Draw(t_glow)
    for r in range(110, 0, -5):
        alpha = int(90 * (1.0 - r / 110.0))
        t_glow_draw.ellipse([128 - r, 120 - r, 128 + r, 120 + r], fill=(255, 110, 25, alpha))
    t_glow = t_glow.filter(ImageFilter.GaussianBlur(8))
    t_bg = Image.alpha_composite(t_bg, t_glow)

    t_fg = Image.new("RGBA", (SIZE_THUMB, SIZE_THUMB), (0, 0, 0, 0))
    t_fg_draw = ImageDraw.Draw(t_fg)
    charizard_art(t_fg_draw, SIZE_THUMB)
    t_img = Image.alpha_composite(t_bg, t_fg)

    t_img = draw_vignette(t_img, (255, 140, 30), (255, 80, 15))
    thumb_out = THUMB_DIR / "thumb_charizard.png"
    t_img.save(thumb_out, "PNG")
    print(f"SAVED THUMB: {thumb_out} ({thumb_out.stat().st_size} bytes)")
    print("=== CHARIZARD 2D ART ASSETS GENERATED SUCCESSFULLY ===")

if __name__ == "__main__":
    create_charizard_art()
