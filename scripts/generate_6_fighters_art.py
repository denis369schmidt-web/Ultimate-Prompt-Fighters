"""Generate HD Visual Art, UI Portraits & MK Thumbnails for the 6 New Anime Legends:
1. Naruto Uzumaki (Orange/Cyan Glow, Konoha Headband, Rasengan Vortex)
2. Vegeta (Royal Navy/Gold Glow, Saiyan Pride, Final Flash Aura)
3. Roronoa Zoro (Emerald Wind Slash, Santoryu 3-Katana Silhouette, Golden Earrings)
4. Saitama (Hero Yellow/Crimson, Serious Punch Shockwave Burst)
5. Tanjiro Kamado (Hinokami Kagura Sun Fire Dragon & Green Checkered Haori)
6. Sasuke Uchiha (Chidori Azure Lightning, Crimson Sharingan & Uchiha Crest)
"""
import math, numpy as np
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate")
UI_DIR = ROOT / "godot/assets/textures/ui"
THUMB_DIR = ROOT / "godot/assets/textures/characters/thumbs"
SKINS_DIR = ROOT / "godot/assets/textures/skins"

UI_DIR.mkdir(parents=True, exist_ok=True)
THUMB_DIR.mkdir(parents=True, exist_ok=True)
SKINS_DIR.mkdir(parents=True, exist_ok=True)

SIZE_PORTRAIT = 512
SIZE_THUMB = 256

def draw_vignette(img, border_color, glow_color):
    draw = ImageDraw.Draw(img)
    w, h = img.size
    # Multi-layer outer glowing border
    for b in range(6):
        alpha = int(255 * (1.0 - b / 6.0))
        draw.rectangle([b, b, w - 1 - b, h - 1 - b], outline=(*glow_color, alpha))
    draw.rectangle([0, 0, w - 1, h - 1], outline=(*border_color, 255), width=3)
    return img

def create_fighter_art(id_name, bg_grad, fg_colors, symbols_func):
    # 1. PORTRAIT (512x512)
    p_img = Image.new("RGBA", (SIZE_PORTRAIT, SIZE_PORTRAIT), bg_grad[0])
    p_draw = ImageDraw.Draw(p_img)
    
    # Background gradient & radial burst
    for y in range(SIZE_PORTRAIT):
        t = y / float(SIZE_PORTRAIT)
        r = int(bg_grad[0][0] * (1 - t) + bg_grad[1][0] * t)
        g = int(bg_grad[0][1] * (1 - t) + bg_grad[1][1] * t)
        b = int(bg_grad[0][2] * (1 - t) + bg_grad[1][2] * t)
        p_draw.line([(0, y), (SIZE_PORTRAIT, y)], fill=(r, g, b, 255))
        
    # Radial Energy Ring
    center = (SIZE_PORTRAIT // 2, SIZE_PORTRAIT // 2)
    for rad in range(60, 240, 15):
        alpha = int(max(0, 180 - rad * 0.7))
        p_draw.ellipse([center[0] - rad, center[1] - rad, center[0] + rad, center[1] + rad], outline=(*fg_colors["glow"], alpha), width=3)
        
    # Dynamic signature motifs & character silhouette shapes
    symbols_func(p_draw, SIZE_PORTRAIT, fg_colors)
    
    # Border & Polish
    draw_vignette(p_img, fg_colors["accent"], fg_colors["glow"])
    port_path = UI_DIR / f"portrait_{id_name}.png"
    p_img.save(port_path)
    print(f"Saved portrait: {port_path}")
    
    # 2. THUMBNAIL (256x256)
    t_img = p_img.resize((SIZE_THUMB, SIZE_THUMB), Image.Resampling.LANCZOS)
    draw_vignette(t_img, fg_colors["accent"], fg_colors["glow"])
    thumb_path = THUMB_DIR / f"thumb_{id_name}.png"
    t_img.save(thumb_path)
    print(f"Saved thumbnail: {thumb_path}")

# --- 1. NARUTO MOTIFS ---
def naruto_art(d, S, col):
    cx, cy = S // 2, S // 2
    # Spiky Yellow Hair Silhouette
    for sp_i in range(16):
        ang = (sp_i / 16.0) * math.pi * 2.0
        r_inner = S * 0.22
        r_outer = S * 0.44 + (sp_i % 3) * 20
        px1 = cx + math.cos(ang - 0.15) * r_inner
        py1 = cy + math.sin(ang - 0.15) * r_inner - 20
        px2 = cx + math.cos(ang + 0.15) * r_inner
        py2 = cy + math.sin(ang + 0.15) * r_inner - 20
        px3 = cx + math.cos(ang) * r_outer
        py3 = cy + math.sin(ang) * r_outer - 40
        d.polygon([(px1, py1), (px2, py2), (px3, py3)], fill=(255, 215, 20, 230))
        
    # Face & Konoha Headband
    d.ellipse([cx - 70, cy - 70, cx + 70, cy + 70], fill=(245, 200, 165, 255))
    d.rectangle([cx - 75, cy - 45, cx + 75, cy - 10], fill=(20, 45, 120, 255))
    d.rounded_rectangle([cx - 50, cy - 42, cx + 50, cy - 13], radius=6, fill=(220, 225, 235, 255), outline=(150, 155, 170), width=2)
    # Leaf symbol in plate
    d.ellipse([cx - 10, cy - 32, cx + 10, cy - 23], outline=(60, 65, 80), width=3)
    d.line([(cx + 8, cy - 32), (cx + 22, cy - 38)], fill=(60, 65, 80), width=3)
    
    # Whiskers
    for sy in [-12, 0, 12]:
        d.line([(cx - 45, cy + 15 + sy), (cx - 15, cy + 12 + sy)], fill=(120, 60, 40), width=3)
        d.line([(cx + 15, cy + 12 + sy), (cx + 45, cy + 15 + sy)], fill=(120, 60, 40), width=3)
        
    # Rotating Rasengan Spiral Vortex
    for ring in range(5):
        rr = 35 + ring * 12
        d.arc([cx + 70 - rr, cy + 80 - rr, cx + 70 + rr, cy + 80 + rr], start=ring * 50, end=ring * 50 + 260, fill=(80, 220, 255, 220), width=4)
    d.ellipse([cx + 70 - 25, cy + 80 - 25, cx + 70 + 25, cy + 80 + 25], fill=(200, 245, 255, 240))

# --- 2. VEGETA MOTIFS ---
def vegeta_art(d, S, col):
    cx, cy = S // 2, S // 2
    # Towering Flame Hair Silhouette
    for sp_i in range(18):
        ang = -math.pi * 0.9 + (sp_i / 17.0) * math.pi * 0.8
        r_inner = S * 0.2
        r_outer = S * 0.48 + (sp_i % 4) * 22
        px1 = cx + math.cos(ang - 0.12) * r_inner
        py1 = cy + math.sin(ang - 0.12) * r_inner - 20
        px2 = cx + math.cos(ang + 0.12) * r_inner
        py2 = cy + math.sin(ang + 0.12) * r_inner - 20
        px3 = cx + math.cos(ang) * r_outer
        py3 = cy - S * 0.46 - (sp_i % 3) * 25
        d.polygon([(px1, py1), (px2, py2), (px3, py3)], fill=(15, 18, 30, 245))
        
    # Saiyan Widow's Peak & Face
    d.polygon([(cx - 65, cy - 25), (cx, cy - 45), (cx + 65, cy - 25), (cx + 45, cy + 60), (cx - 45, cy + 60)], fill=(245, 202, 170, 255))
    
    # Saiyan Royal Battle Armor (Gold & White Plates)
    d.rectangle([cx - 85, cy + 70, cx + 85, cy + 180], fill=(235, 235, 245, 255), outline=(180, 180, 195), width=3)
    for ry in [95, 120, 145]:
        d.rounded_rectangle([cx - 55, cy + ry, cx + 55, cy + ry + 16], radius=4, fill=(245, 185, 30, 255))
    # Golden Final Flash Energy Sparks
    for spk in range(12):
        s_ang = spk * (math.pi * 2.0 / 12.0)
        sx = cx + math.cos(s_ang) * 160
        sy = cy + math.sin(s_ang) * 160
        d.line([(cx, cy), (sx, sy)], fill=(255, 240, 80, 180), width=3)

# --- 3. ZORO MOTIFS ---
def zoro_art(d, S, col):
    cx, cy = S // 2, S // 2
    # Moss Green Hair
    d.ellipse([cx - 75, cy - 90, cx + 75, cy + 20], fill=(55, 160, 75, 255))
    # Face & Eye Scar
    d.polygon([(cx - 60, cy - 30), (cx + 60, cy - 30), (cx + 45, cy + 65), (cx - 45, cy + 65)], fill=(245, 198, 162, 255))
    d.line([(cx - 28, cy - 20), (cx - 20, cy + 30)], fill=(180, 50, 40), width=4) # Scar
    
    # 3 Golden Hoop Earrings
    for ei in range(3):
        d.ellipse([cx + 62, cy + 10 + ei * 14, cx + 74, cy + 22 + ei * 14], outline=(245, 205, 30), width=3)
        
    # Santoryu Wado Ichimonji Katana clamped in mouth
    d.rectangle([cx - 180, cy + 42, cx + 180, cy + 54], fill=(240, 242, 248, 255), outline=(180, 185, 200), width=2) # Blade
    d.rectangle([cx - 35, cy + 38, cx + 35, cy + 58], fill=(255, 255, 255, 255), outline=(40, 40, 40), width=2) # Tsuka
    
    # Emerald Green Wind Slashes (Tornado Slash Arc)
    for ai in range(3):
        rr = 130 + ai * 30
        d.arc([cx - rr, cy - rr, cx + rr, cy + rr], start=-30 + ai * 25, end=140 + ai * 25, fill=(60, 245, 130, 230), width=6)

# --- 4. SAITAMA MOTIFS ---
def saitama_art(d, S, col):
    cx, cy = S // 2, S // 2
    # White Superhero Cape flowing behind
    d.polygon([(cx - 160, cy - 40), (cx + 160, cy - 40), (cx + 200, S), (cx - 200, S)], fill=(245, 245, 250, 255))
    # Perfectly Shined Bald Head with Highlight
    d.ellipse([cx - 85, cy - 110, cx + 85, cy + 60], fill=(248, 205, 172, 255))
    # Head Gleam / Shine
    d.ellipse([cx - 45, cy - 95, cx - 15, cy - 70], fill=(255, 255, 255, 220))
    # Serious Face expression (bold eyebrows & stern eyes)
    d.line([(cx - 50, cy - 25), (cx - 15, cy - 18)], fill=(40, 40, 40), width=5)
    d.line([(cx + 15, cy - 18), (cx + 50, cy - 25)], fill=(40, 40, 40), width=5)
    d.ellipse([cx - 38, cy - 12, cx - 22, cy - 2], fill=(20, 20, 20))
    d.ellipse([cx + 22, cy - 12, cx + 38, cy - 2], fill=(20, 20, 20))
    
    # Yellow Suit & Big Red Glove with Serious Punch Shockwave
    d.rectangle([cx - 90, cy + 60, cx + 90, cy + 180], fill=(245, 210, 20, 255))
    d.ellipse([cx + 40, cy + 60, cx + 160, cy + 180], fill=(220, 30, 30, 255), outline=(150, 10, 10), width=4)
    # Gigantic Shockwave Rings
    for sw in range(4):
        sr = 70 + sw * 28
        d.ellipse([cx + 100 - sr, cy + 120 - sr, cx + 100 + sr, cy + 120 + sr], outline=(255, 255, 220, 230 - sw * 50), width=5)

# --- 5. TANJIRO MOTIFS ---
def tanjiro_art(d, S, col):
    cx, cy = S // 2, S // 2
    # Burgundy Swept Hair
    d.ellipse([cx - 75, cy - 85, cx + 75, cy + 25], fill=(115, 30, 38, 255))
    # Face & Scar
    d.polygon([(cx - 60, cy - 30), (cx + 60, cy - 30), (cx + 45, cy + 65), (cx - 45, cy + 65)], fill=(245, 198, 165, 255))
    d.polygon([(cx - 45, cy - 22), (cx - 20, cy - 35), (cx - 30, cy - 8)], fill=(160, 40, 35, 255)) # Flame Scar
    
    # Hanafuda Earrings
    for side, sx in [(-1, cx - 68), (1, cx + 60)]:
        d.rectangle([sx, cy + 15, sx + 16, cy + 48], fill=(245, 245, 250, 255), outline=(30, 30, 30), width=2)
        d.ellipse([sx + 3, cy + 20, sx + 13, cy + 30], fill=(220, 40, 30))
        
    # Checkered Green & Black Haori Pattern
    cw = 32
    for row in range(4):
        for col_i in range(8):
            color = (35, 155, 90, 255) if (row + col_i) % 2 == 0 else (20, 20, 25, 255)
            d.rectangle([col_i * cw, cy + 70 + row * cw, (col_i + 1) * cw, cy + 70 + (row + 1) * cw], fill=color)
            
    # Hinokami Kagura Sun Fire Dragon wrapping across portrait
    for fi in range(24):
        ang = fi * 0.35
        fx = cx + math.cos(ang) * (80 + fi * 5)
        fy = cy + math.sin(ang) * (70 + fi * 3)
        fr = 14 + (fi % 4) * 4
        d.ellipse([fx - fr, fy - fr, fx + fr, fy + fr], fill=(255, 100 + fi * 5, 20, 210))

# --- 6. SASUKE MOTIFS ---
def sasuke_art(d, S, col):
    cx, cy = S // 2, S // 2
    # Raven Black Spiky Hair framing face
    for sp_i in range(16):
        ang = (sp_i / 16.0) * math.pi * 2.0
        r_inner = S * 0.2
        r_outer = S * 0.42 + (sp_i % 3) * 18
        px1 = cx + math.cos(ang - 0.15) * r_inner
        py1 = cy + math.sin(ang - 0.15) * r_inner - 20
        px2 = cx + math.cos(ang + 0.15) * r_inner
        py2 = cy + math.sin(ang + 0.15) * r_inner - 20
        px3 = cx + math.cos(ang) * r_outer
        py3 = cy + math.sin(ang) * r_outer - 35
        d.polygon([(px1, py1), (px2, py2), (px3, py3)], fill=(18, 22, 38, 250))
        
    # Pale Face & Glowing Crimson Sharingan
    d.polygon([(cx - 55, cy - 25), (cx + 55, cy - 25), (cx + 42, cy + 65), (cx - 42, cy + 65)], fill=(245, 202, 172, 255))
    # Right eye: Sharingan (Crimson with Tomoe)
    d.ellipse([cx + 12, cy - 10, cx + 34, cy + 12], fill=(225, 25, 25, 255), outline=(120, 10, 10), width=2)
    d.ellipse([cx + 20, cy - 2, cx + 26, cy + 4], fill=(10, 10, 10))
    # Left eye: Rinnegan Purple
    d.ellipse([cx - 34, cy - 10, cx - 12, cy + 12], fill=(160, 90, 220, 255), outline=(90, 40, 140), width=2)
    
    # High Collar Shirt & Purple Shimenawa Rope Belt
    d.rectangle([cx - 75, cy + 70, cx + 75, cy + 180], fill=(225, 230, 240, 255))
    d.rectangle([cx - 85, cy + 130, cx + 85, cy + 165], fill=(130, 60, 185, 255), outline=(80, 30, 120), width=3)
    
    # Crackling Chidori (1000 Birds) Azure Lightning Ball & Electric Sparks
    for bolt in range(16):
        bx = cx - 110
        by = cy + 110
        for b_step in range(4):
            nbx = bx + np.random.randint(-25, 25)
            nby = by + np.random.randint(-25, 25)
            d.line([(bx, by), (nbx, nby)], fill=(90, 220, 255, 230), width=3)
            bx, by = nbx, nby
    d.ellipse([cx - 135, cy + 85, cx - 85, cy + 135], fill=(220, 245, 255, 240))

# ==============================================================================
# EXECUTE ALL 6 ARTSETS
# ==============================================================================
if __name__ == "__main__":
    print("==================================================")
    print("GENERATING HD ARTSETS & PORTRAITS FOR 6 FIGHTERS")
    print("==================================================")
    
    # 1. Naruto
    create_fighter_art(
        "naruto",
        [(25, 15, 8), (70, 35, 10)],
        {"accent": (255, 140, 20), "glow": (60, 210, 255)},
        naruto_art
    )
    # 2. Vegeta
    create_fighter_art(
        "vegeta",
        [(10, 14, 35), (25, 45, 95)],
        {"accent": (245, 195, 30), "glow": (255, 235, 80)},
        vegeta_art
    )
    # 3. Zoro
    create_fighter_art(
        "zoro",
        [(8, 25, 15), (20, 65, 35)],
        {"accent": (45, 215, 95), "glow": (80, 255, 140)},
        zoro_art
    )
    # 4. Saitama
    create_fighter_art(
        "saitama",
        [(35, 12, 10), (95, 25, 15)],
        {"accent": (255, 215, 20), "glow": (255, 80, 60)},
        saitama_art
    )
    # 5. Tanjiro
    create_fighter_art(
        "tanjiro",
        [(15, 28, 20), (35, 80, 50)],
        {"accent": (255, 85, 20), "glow": (40, 220, 110)},
        tanjiro_art
    )
    # 6. Sasuke
    create_fighter_art(
        "sasuke",
        [(15, 10, 30), (45, 20, 80)],
        {"accent": (80, 210, 255), "glow": (180, 80, 255)},
        sasuke_art
    )
    print("==================================================")
    print("ALL 6 ARTSETS SUCCESSFULLY GENERATED!")
    print("==================================================")
