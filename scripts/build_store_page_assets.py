"""Builds 100% Spec-Compliant AAA Store Graphics for Steam and Google Play.

Generates:
  Steamworks:
    - store/steam/header_capsule_920x430.png (920x430)
    - store/steam/main_capsule_1232x706.png (1232x706)
    - store/steam/small_capsule_462x174.png (462x174)
    - store/steam/vertical_capsule_748x896.png (748x896)
    - store/steam/library_capsule_600x900.png (600x900)
    - store/steam/library_header_920x430.png (920x430)
    - store/steam/library_hero_3840x1240.png (3840x1240, textless panoramic backdrop)
    - store/steam/library_logo_transparent.png (1280x720, transparent RGBA)
    - store/steam/page_background_1438x810.png (1438x810)
    - store/steam/community_icon_184x184.jpg (184x184)
    - store/steam/client_icon.ico (multi-resolution ICO)
    - store/steam/screenshots/*.jpg (8x 1080p marketing screenshots)
    - store/steam/screenshots_clean/*.jpg (8x 1080p raw screenshots)
  Google Play:
    - store/play/app_icon_512x512.png (512x512, 32-bit PNG)
    - store/play/feature_graphic_1024x500.png (1024x500, 24-bit PNG, no alpha)
    - store/play/screenshots/*.png (8x 1080p marketing screenshots)
    - store/play/screenshots_clean/*.png (8x 1080p raw screenshots)
  Upload Bundle:
    - store/upload_bundle/steam/
    - store/upload_bundle/google_play/
    - store/upload_bundle/UPLOAD_GUIDE.md
"""

import os
import shutil
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageEnhance

# ── Paths & Preloads ──────────────────────────────────────────────────────────
CINEMATICS_DIR = "store/trailer/cinematics"
P_CLASH = os.path.join(CINEMATICS_DIR, "aaa_intro_clash_1791363318116.jpg")
P_NINJA = os.path.join(CINEMATICS_DIR, "cinematic_fighter_clash_1791379963009.jpg")
P_ASTRAL = os.path.join(CINEMATICS_DIR, "cinematic_kalyx_vorruk_1791380008193.jpg")
P_DANTE = os.path.join(CINEMATICS_DIR, "cinematic_boss_dante_1791379983155.jpg")
P_EMBLEM = os.path.join(CINEMATICS_DIR, "aaa_intro_emblem_1791363346932.jpg")

P_ICON_512 = "godot/icon_512.png"
P_ROSTER_UI = "store/raw/shot_07_selection.png"
P_INTRO_BOOT = "store/raw/shot_08.png"

FONT_PATH = "godot/assets/fonts/RussoOne-Regular.ttf"
font_huge = ImageFont.truetype(FONT_PATH, 54)
font_title = ImageFont.truetype(FONT_PATH, 38)
font_tag = ImageFont.truetype(FONT_PATH, 24)
font_sub = ImageFont.truetype(FONT_PATH, 22)

# Output directories
DIR_STEAM = "store/steam"
DIR_PLAY = "store/play"
DIR_BUNDLE_STEAM = "store/upload_bundle/steam"
DIR_BUNDLE_PLAY = "store/upload_bundle/google_play"

for d in [DIR_STEAM, DIR_PLAY, DIR_BUNDLE_STEAM, DIR_BUNDLE_PLAY,
          os.path.join(DIR_STEAM, "screenshots"), os.path.join(DIR_STEAM, "screenshots_clean"),
          os.path.join(DIR_PLAY, "screenshots"), os.path.join(DIR_PLAY, "screenshots_clean"),
          os.path.join(DIR_BUNDLE_STEAM, "screenshots"), os.path.join(DIR_BUNDLE_PLAY, "screenshots")]:
    os.makedirs(d, exist_ok=True)

# ── Image Loading Helpers ─────────────────────────────────────────────────────
def load_img(path):
    return Image.open(path).convert("RGBA")

img_clash = load_img(P_CLASH)
img_ninja = load_img(P_NINJA)
img_astral = load_img(P_ASTRAL)
img_dante = load_img(P_DANTE)
img_emblem_full = load_img(P_EMBLEM)
img_icon = load_img(P_ICON_512)
img_roster = load_img(P_ROSTER_UI) if os.path.exists(P_ROSTER_UI) else img_ninja
img_intro = load_img(P_INTRO_BOOT) if os.path.exists(P_INTRO_BOOT) else img_clash

def cover(img, size, focus=(0.5, 0.5)):
    """Resize image to cover size completely with smart focal crop."""
    target_w, target_h = size
    s = max(target_w / float(img.width), target_h / float(img.height))
    nw = int(round(img.width * s))
    nh = int(round(img.height * s))
    resized = img.resize((nw, nh), Image.LANCZOS)
    
    cx = int(nw * focus[0])
    cy = int(nh * focus[1])
    
    x0 = max(0, min(nw - target_w, cx - target_w // 2))
    y0 = max(0, min(nh - target_h, cy - target_h // 2))
    return resized.crop((x0, y0, x0 + target_w, y0 + target_h))

def add_edge_vignette(img, strength=0.65, side="bottom", height_ratio=0.45):
    """Adds cinematic gradient darkness to an edge for supreme typography contrast."""
    w, h = img.size
    grad = Image.new("L", (w, h), 0)
    d = ImageDraw.Draw(grad)
    limit = int(h * height_ratio) if side in ("bottom", "top") else int(w * height_ratio)
    
    for i in range(limit):
        factor = (1.0 - (i / float(limit))) ** 1.5
        alpha = int(255 * strength * factor)
        if side == "bottom":
            d.line([(0, h - 1 - i), (w, h - 1 - i)], fill=alpha)
        elif side == "top":
            d.line([(0, i), (w, i)], fill=alpha)
        elif side == "left":
            d.line([(i, 0), (i, h)], fill=alpha)
        elif side == "right":
            d.line([(w - 1 - i, 0), (w - 1 - i, h)], fill=alpha)
            
    black = Image.new("RGBA", (w, h), (0, 0, 0, 255))
    return Image.composite(black, img, grad)

def add_radial_vignette(img, strength=0.7):
    """Cinematic corner darkness."""
    w, h = img.size
    Y, X = np.ogrid[:h, :w]
    cx, cy = w / 2.0, h / 2.0
    dist = np.sqrt(((X - cx) / cx)**2 + ((Y - cy) / cy)**2)
    v = np.clip((dist - 0.6) / 0.8, 0.0, 1.0) ** 1.8
    v_alpha = (v * 255 * strength).astype(np.uint8)
    mask = Image.fromarray(v_alpha, mode="L")
    black = Image.new("RGBA", (w, h), (4, 6, 12, 255))
    return Image.composite(black, img, mask)

# ── Build Transparent 3D Logo ─────────────────────────────────────────────────
print("Extracting and building transparent 3D Studio Logo...")
emblem_shield = img_icon # 512x512 crisp shield

# Text crop:
ew, eh = img_emblem_full.size
crop_text = img_emblem_full.crop((int(ew * 0.10), int(eh * 0.66), int(ew * 0.90), int(eh * 0.96)))
ct_w, ct_h = crop_text.size

t_arr = np.array(crop_text, dtype=np.float32)
lum = 0.299 * t_arr[:, :, 0] + 0.587 * t_arr[:, :, 1] + 0.114 * t_arr[:, :, 2]
alpha_t = np.clip((lum - 32.0) / 48.0, 0.0, 1.0)
alpha_t[lum > 85.0] = 1.0

Y_ct, X_ct = np.ogrid[:ct_h, :ct_w]
alpha_t = alpha_t * np.clip((Y_ct - 10.0) / 15.0, 0.0, 1.0)
text_rgba = Image.fromarray(np.dstack([t_arr[:, :, :3], alpha_t * 255.0]).astype(np.uint8), "RGBA")

# Build 1280x720 Library Logo
lib_logo_canvas = Image.new("RGBA", (1280, 720), (0, 0, 0, 0))
emb_target_h = 440
emb_target_w = int(emblem_shield.width * (emb_target_h / float(emblem_shield.height)))
emb_scaled = emblem_shield.resize((emb_target_w, emb_target_h), Image.LANCZOS)
lib_logo_canvas.alpha_composite(emb_scaled, ((1280 - emb_target_w) // 2, 25))

text_target_w = 1140
text_target_h = int(text_rgba.height * (text_target_w / float(text_rgba.width)))
text_scaled = text_rgba.resize((text_target_w, text_target_h), Image.LANCZOS)
lib_logo_canvas.alpha_composite(text_scaled, ((1280 - text_target_w) // 2, 440))

logo_shadow = Image.new("RGBA", (1280, 720), (0, 0, 0, 0))
shadow_alpha = lib_logo_canvas.getchannel("A").point(lambda a: int(a * 0.85))
logo_shadow.paste(Image.new("RGBA", (1280, 720), (2, 4, 10, 255)), (0, 0), shadow_alpha)
logo_shadow = logo_shadow.filter(ImageFilter.GaussianBlur(18))

final_lib_logo = Image.alpha_composite(logo_shadow, lib_logo_canvas)
final_lib_logo.save(os.path.join(DIR_STEAM, "library_logo_transparent.png"))
shutil.copyfile(os.path.join(DIR_STEAM, "library_logo_transparent.png"),
                os.path.join(DIR_BUNDLE_STEAM, "library_logo_transparent.png"))
print("Saved library_logo_transparent.png (1280x720)")

# Horizontal Logo only (for wide capsules)
horiz_logo_canvas = Image.new("RGBA", (text_target_w, text_target_h + 120), (0, 0, 0, 0))
mini_shield = emblem_shield.resize((150, 150), Image.LANCZOS)
horiz_logo_canvas.alpha_composite(mini_shield, ((text_target_w - 150) // 2, 0))
horiz_logo_canvas.alpha_composite(text_scaled, (0, 110))

def overlay_logo(bg, logo_img, box):
    """Pastes logo into box (x, y, w, h) with Gaussian ambient shadow."""
    x, y, target_w, target_h = box
    s = min(target_w / float(logo_img.width), target_h / float(logo_img.height))
    lw = int(round(logo_img.width * s))
    lh = int(round(logo_img.height * s))
    scaled_logo = logo_img.resize((lw, lh), Image.LANCZOS)
    
    px = x + (target_w - lw) // 2
    py = y + (target_h - lh) // 2
    
    glow = Image.new("RGBA", bg.size, (0, 0, 0, 0))
    alpha = scaled_logo.getchannel("A").point(lambda a: int(a * 0.90))
    glow.paste(Image.new("RGBA", (lw, lh), (0, 0, 0, 255)), (px, py), alpha)
    glow = glow.filter(ImageFilter.GaussianBlur(max(4, lh // 14)))
    
    res = Image.alpha_composite(bg, glow)
    res.alpha_composite(scaled_logo, (px, py))
    return res

# ── 1. Steam Header Capsule (920x430) ─────────────────────────────────────────
print("Building Header Capsule (920x430)...")
base = cover(img_ninja, (920, 430), focus=(0.55, 0.40))
base = add_edge_vignette(base, strength=0.88, side="bottom", height_ratio=0.55)
base = add_radial_vignette(base, strength=0.5)
header_cap = overlay_logo(base, horiz_logo_canvas, (40, 210, 840, 205))
header_cap.convert("RGB").save(os.path.join(DIR_STEAM, "header_capsule_920x430.png"))
header_cap.convert("RGB").save(os.path.join(DIR_STEAM, "library_header_920x430.png"))
shutil.copyfile(os.path.join(DIR_STEAM, "header_capsule_920x430.png"),
                os.path.join(DIR_BUNDLE_STEAM, "header_capsule_920x430.png"))
shutil.copyfile(os.path.join(DIR_STEAM, "library_header_920x430.png"),
                os.path.join(DIR_BUNDLE_STEAM, "library_header_920x430.png"))

# ── 2. Steam Main Capsule (1232x706) ──────────────────────────────────────────
print("Building Main Capsule (1232x706)...")
base = cover(img_ninja, (1232, 706), focus=(0.52, 0.42))
base = add_edge_vignette(base, strength=0.90, side="bottom", height_ratio=0.52)
base = add_radial_vignette(base, strength=0.55)
main_cap = overlay_logo(base, horiz_logo_canvas, (60, 350, 1112, 330))
main_cap.convert("RGB").save(os.path.join(DIR_STEAM, "main_capsule_1232x706.png"))
shutil.copyfile(os.path.join(DIR_STEAM, "main_capsule_1232x706.png"),
                os.path.join(DIR_BUNDLE_STEAM, "main_capsule_1232x706.png"))

# ── 3. Steam Small Capsule (462x174) ──────────────────────────────────────────
print("Building Small Capsule (462x174)...")
base = cover(img_clash, (462, 174), focus=(0.50, 0.50))
base = add_edge_vignette(base, strength=0.92, side="bottom", height_ratio=0.60)
base = add_radial_vignette(base, strength=0.45)
small_cap = overlay_logo(base, text_scaled, (20, 75, 422, 92))
small_cap.convert("RGB").save(os.path.join(DIR_STEAM, "small_capsule_462x174.png"))
shutil.copyfile(os.path.join(DIR_STEAM, "small_capsule_462x174.png"),
                os.path.join(DIR_BUNDLE_STEAM, "small_capsule_462x174.png"))

# ── 4. Steam Vertical Capsule (748x896) ───────────────────────────────────────
print("Building Vertical Capsule (748x896)...")
base = cover(img_emblem_full, (748, 896), focus=(0.50, 0.48))
base = add_radial_vignette(base, strength=0.45)
vert_cap = add_edge_vignette(base, strength=0.55, side="bottom", height_ratio=0.25)
vert_cap.convert("RGB").save(os.path.join(DIR_STEAM, "vertical_capsule_748x896.png"))
shutil.copyfile(os.path.join(DIR_STEAM, "vertical_capsule_748x896.png"),
                os.path.join(DIR_BUNDLE_STEAM, "vertical_capsule_748x896.png"))

# ── 5. Steam Library Capsule (600x900) ────────────────────────────────────────
print("Building Library Capsule (600x900)...")
base = cover(img_emblem_full, (600, 900), focus=(0.50, 0.48))
base = add_radial_vignette(base, strength=0.40)
lib_cap = add_edge_vignette(base, strength=0.50, side="bottom", height_ratio=0.25)
lib_cap.convert("RGB").save(os.path.join(DIR_STEAM, "library_capsule_600x900.png"))
shutil.copyfile(os.path.join(DIR_STEAM, "library_capsule_600x900.png"),
                os.path.join(DIR_BUNDLE_STEAM, "library_capsule_600x900.png"))

# ── 6. Steam Library Hero (3840x1240, STRICTLY NO TEXT) ────────────────────────
print("Building Panoramic Library Hero (3840x1240, textless)...")
hero = Image.new("RGBA", (3840, 1240), (6, 10, 18, 255))
panel_w = 1600
panel_h = 1240

p_left = cover(img_ninja, (panel_w, panel_h), focus=(0.35, 0.40))
p_center = cover(img_astral, (1800, panel_h), focus=(0.50, 0.50))
p_right = cover(img_dante, (panel_w, panel_h), focus=(0.50, 0.45))

def make_h_mask(w, h, fade_w=400, left_edge=True):
    arr = np.ones((h, w), dtype=np.float32)
    for x in range(fade_w):
        val = (x / float(fade_w)) ** 1.8
        if left_edge:
            arr[:, x] = val
        else:
            arr[:, w - 1 - x] = val
    return Image.fromarray((arr * 255).astype(np.uint8), mode="L")

hero.paste(p_center, (1020, 0))
m_left = make_h_mask(panel_w, panel_h, fade_w=500, left_edge=False)
hero.paste(p_left, (0, 0), m_left)
m_right = make_h_mask(panel_w, panel_h, fade_w=500, left_edge=True)
hero.paste(p_right, (3840 - panel_w, 0), m_right)

hero = add_edge_vignette(hero, strength=0.85, side="top", height_ratio=0.25)
hero = add_edge_vignette(hero, strength=0.85, side="bottom", height_ratio=0.25)
hero = add_radial_vignette(hero, strength=0.45)

hero.convert("RGB").save(os.path.join(DIR_STEAM, "library_hero_3840x1240.png"))
shutil.copyfile(os.path.join(DIR_STEAM, "library_hero_3840x1240.png"),
                os.path.join(DIR_BUNDLE_STEAM, "library_hero_3840x1240.png"))

# ── 7. Steam Page Background (1438x810) ───────────────────────────────────────
print("Building Steam Page Background (1438x810)...")
base = cover(img_astral, (1438, 810), focus=(0.50, 0.50))
enhancer = ImageEnhance.Brightness(base)
dimmed = enhancer.enhance(0.70)
dimmed = add_radial_vignette(dimmed, strength=0.85)
dimmed = add_edge_vignette(dimmed, strength=0.90, side="bottom", height_ratio=0.35)
dimmed = add_edge_vignette(dimmed, strength=0.90, side="top", height_ratio=0.25)
dimmed.convert("RGB").save(os.path.join(DIR_STEAM, "page_background_1438x810.png"))
shutil.copyfile(os.path.join(DIR_STEAM, "page_background_1438x810.png"),
                os.path.join(DIR_BUNDLE_STEAM, "page_background_1438x810.png"))

# ── 8. Google Play Feature Graphic (1024x500) ─────────────────────────────────
print("Building Google Play Feature Graphic (1024x500)...")
base = cover(img_ninja, (1024, 500), focus=(0.54, 0.40))
base = add_edge_vignette(base, strength=0.88, side="bottom", height_ratio=0.55)
base = add_radial_vignette(base, strength=0.5)
play_feature = overlay_logo(base, horiz_logo_canvas, (40, 240, 944, 250))
play_feature.convert("RGB").save(os.path.join(DIR_PLAY, "feature_graphic_1024x500.png"))
shutil.copyfile(os.path.join(DIR_PLAY, "feature_graphic_1024x500.png"),
                os.path.join(DIR_BUNDLE_PLAY, "feature_graphic_1024x500.png"))

# ── 9. Icons: Google Play (512x512) & Steam Community (184x184) & Client (.ico)
print("Building Icons (512x512, 184x184, .ico)...")
icon_512 = cover(img_icon, (512, 512), focus=(0.5, 0.5))
icon_512.save(os.path.join(DIR_PLAY, "app_icon_512x512.png"))
shutil.copyfile(os.path.join(DIR_PLAY, "app_icon_512x512.png"),
                os.path.join(DIR_BUNDLE_PLAY, "app_icon_512x512.png"))

icon_184 = icon_512.resize((184, 184), Image.LANCZOS)
icon_184.convert("RGB").save(os.path.join(DIR_STEAM, "community_icon_184x184.jpg"), quality=98)
shutil.copyfile(os.path.join(DIR_STEAM, "community_icon_184x184.jpg"),
                os.path.join(DIR_BUNDLE_STEAM, "community_icon_184x184.jpg"))

ico_sizes = [(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]
icon_512.save(os.path.join(DIR_STEAM, "client_icon.ico"), sizes=ico_sizes)
shutil.copyfile(os.path.join(DIR_STEAM, "client_icon.ico"),
                os.path.join(DIR_BUNDLE_STEAM, "client_icon.ico"))

# ── 10. Store Marketing Screenshots (1920x1080) ───────────────────────────────
print("Generating 8x AAA Marketing Screenshots (1920x1080)...")

def draw_screenshot_badge(base_img, tag, title, subtitle=None, accent_color=(56, 189, 248)):
    img = base_img.copy()
    overlay = Image.new("RGBA", img.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    
    box_w = 1480
    box_h = 135 if subtitle else 100
    box_x = 75
    box_y = 1080 - box_h - 65
    
    draw.rounded_rectangle([(box_x, box_y), (box_x + box_w, box_y + box_h)], radius=16,
                           fill=(6, 10, 20, 235),
                           outline=(accent_color[0], accent_color[1], accent_color[2], 230), width=3)
    
    draw.rounded_rectangle([(box_x + 6, box_y + 12), (box_x + 18, box_y + box_h - 12)], radius=4,
                           fill=(accent_color[0], accent_color[1], accent_color[2], 255))
    
    draw.text((box_x + 42, box_y + 14), tag.upper(), font=font_tag, fill=(160, 195, 245, 240))
    draw.text((box_x + 42, box_y + 45), title.upper(), font=font_title, fill=(255, 255, 255, 255))
    if subtitle:
        draw.text((box_x + 42, box_y + 96), subtitle.upper(), font=font_sub, fill=(accent_color[0], accent_color[1], accent_color[2], 245))
        
    return Image.alpha_composite(img, overlay)

screenshots_data = [
    {
        "id": "screenshot_01_1920x1080",
        "bg": cover(img_ninja, (1920, 1080), focus=(0.50, 0.45)),
        "tag": "/// 58 KÄMPFER & SIGNATUR-MOVES ///",
        "title": "BLITZSCHNELLE COMBOS · JUGGLES · PARRY",
        "sub": "VOLLE BEWEGUNGSFREIHEIT & TIEFE AUF JEDER PLATTFORM",
        "accent": (56, 189, 248)
    },
    {
        "id": "screenshot_02_1920x1080",
        "bg": cover(img_clash, (1920, 1080), focus=(0.50, 0.50)),
        "tag": "/// NEXT-GEN PLATFORM BRAWLER ///",
        "title": "WO JEDER PROMPT ZUM KÄMPFER WIRD",
        "sub": "UNBEGRENZTE ELEMENTARKRÄFTE & PHYSIK-BASIERTER KAMPF",
        "accent": (255, 176, 32)
    },
    {
        "id": "screenshot_03_1920x1080",
        "bg": cover(img_astral, (1920, 1080), focus=(0.50, 0.50)),
        "tag": "/// MYTHISCHE ARENEN ///",
        "title": "ASTRAL OBSIDIAN NEXUS · CHRONO-RINGE",
        "sub": "INTERAKTIVE HAZARDS, SCHWEBENDE MONOLITHEN & DYNAMISCHE SKYBOXES",
        "accent": (192, 132, 252)
    },
    {
        "id": "screenshot_04_1920x1080",
        "bg": cover(img_dante, (1920, 1080), focus=(0.50, 0.45)),
        "tag": "/// TITANISCHE BOSSKÄMPFE ///",
        "title": "DANTE INFERNUS · DIE UNYIELDING FLAME",
        "sub": "COLOSSAL SLAMS, ERDBEBEN & ZERSTÖRBARE ARENEN",
        "accent": (239, 68, 68)
    },
    {
        "id": "screenshot_05_1920x1080",
        "bg": cover(img_roster, (1920, 1080), focus=(0.50, 0.50)),
        "tag": "/// ESPORTS-GRADE SELECTION ///",
        "title": "14x4 KÄMPFER-GRID · ATTRIBUTE & PROFIL-SHOWCASE",
        "sub": "SAMURAI · NINJAS · GOLEMS · VALKYREN · DÄMONEN",
        "accent": (56, 189, 248)
    },
    {
        "id": "screenshot_06_1920x1080",
        "bg": cover(img_ninja, (1920, 1080), focus=(0.60, 0.40)),
        "tag": "/// MULTIPLAYER ACTION ///",
        "title": "LOKALER 4-SPIELER VERSUS & COUCH-BRAWL",
        "sub": "KAMPF MIT FREUNDEN AM PC, STEAM DECK ODER GEGEN SMARTE KI",
        "accent": (74, 222, 128)
    },
    {
        "id": "screenshot_07_1920x1080",
        "bg": cover(img_astral, (1920, 1080), focus=(0.35, 0.45)),
        "tag": "/// KREATIV-STUDIO ///",
        "title": "DIE FUSIONSKAMMER · EIGENE KÄMPFER ERSCHAFFEN",
        "sub": "MODULARE WAFFEN, RUNEN-KRÄFTE & INDIVIDUELLE ATTRIBUTE",
        "accent": (244, 114, 182)
    },
    {
        "id": "screenshot_08_1920x1080",
        "bg": cover(img_intro, (1920, 1080), focus=(0.50, 0.50)),
        "tag": "/// FAIRES FORTSCHRITTS-SYSTEM ///",
        "title": "100% TRANSPARENT · KEINE GACHA, KEINE LOOTBOXEN",
        "sub": "DIREKTE FREISCHALTUNGEN & VOLLER FOKUS AUF SKILL",
        "accent": (255, 215, 0)
    }
]

for item in screenshots_data:
    raw_img = item["bg"]
    badged_img = draw_screenshot_badge(raw_img, item["tag"], item["title"], item["sub"], item["accent"])
    
    clean_jpg = os.path.join(DIR_STEAM, "screenshots_clean", item["id"] + ".jpg")
    clean_png = os.path.join(DIR_PLAY, "screenshots_clean", item["id"] + ".png")
    raw_img.convert("RGB").save(clean_jpg, quality=95)
    raw_img.convert("RGB").save(clean_png)
    
    mkt_jpg = os.path.join(DIR_STEAM, "screenshots", item["id"] + ".jpg")
    mkt_png = os.path.join(DIR_PLAY, "screenshots", item["id"] + ".png")
    badged_img.convert("RGB").save(mkt_jpg, quality=95)
    badged_img.convert("RGB").save(mkt_png)
    
    shutil.copyfile(mkt_jpg, os.path.join(DIR_BUNDLE_STEAM, "screenshots", item["id"] + ".jpg"))
    shutil.copyfile(mkt_png, os.path.join(DIR_BUNDLE_PLAY, "screenshots", item["id"] + ".png"))
    print(f"Generated {item['id']}")

# ── 11. Write Store Upload Guide ──────────────────────────────────────────────
upload_guide_content = """# Store-Upload Checklist · Steam & Google Play

Alle Bild-Dateien in diesem Bundle wurden exakt nach den offiziellen Store-Spezifikationen von Valve (Steamworks) und Google Play Console im AAA-Standard generiert.

---

## 1. Steamworks Upload (partner.steamgames.com)

Gehe im Steamworks-Dashboard zu:
`Deine App` -> `Store-Seite bearbeiten` -> Tab `Grafik-Assets` & `Bibliothek-Assets`:

| Steamworks Feld | Dateipfad im Bundle | Pixelmaß | Anmerkung |
| :--- | :--- | :--- | :--- |
| **Haupt-Kapsel (Main Capsule)** | `steam/main_capsule_1232x706.png` | 1232 x 706 | Startseite & Sales-Events |
| **Header-Kapsel** | `steam/header_capsule_920x430.png` | 920 x 430 | Oben rechts auf der Store-Seite |
| **Kleine Kapsel (Small Capsule)** | `steam/small_capsule_462x174.png` | 462 x 174 | Suchleiste & Empfehlungen |
| **Vertikale Kapsel** | `steam/vertical_capsule_748x896.png` | 748 x 896 | Kategorie-Raster & Steam-App |
| **Seiten-Hintergrund** | `steam/page_background_1438x810.png` | 1438 x 810 | Atmosphärischer Hintergrund |
| **Bibliothek-Kapsel (Library Capsule)** | `steam/library_capsule_600x900.png` | 600 x 900 | 2:3 Cover im Steam-Client |
| **Bibliothek-Header** | `steam/library_header_920x430.png` | 920 x 430 | Bibliotheks-Detailansicht |
| **Bibliothek-Held (Library Hero)** | `steam/library_hero_3840x1240.png` | 3840 x 1240 | Textloser Panoramabackdrop |
| **Bibliothek-Logo (Transparent)** | `steam/library_logo_transparent.png`| 1280 x 720 | 32-Bit PNG mit Transparenz |
| **Community-Symbol** | `steam/community_icon_184x184.jpg` | 184 x 184 | Community Hub & Freunde |
| **Client-Symbol** | `steam/client_icon.ico` | Multi-ICO | Desktop-Icon & Windows-EXE |
| **Screenshots (8 Stück)** | `steam/screenshots/*.jpg` | 1920 x 1080 | 1080p Marketing-Screenshots |

---

## 2. Google Play Console Upload (play.google.com/console)

Gehe in der Play Console zu:
`Deine App` -> `Store-Präsenz` -> `Haupt-Store-Eintrag`:

| Google Play Feld | Dateipfad im Bundle | Pixelmaß | Vorgabe |
| :--- | :--- | :--- | :--- |
| **App-Symbol (App Icon)** | `google_play/app_icon_512x512.png` | 512 x 512 | 32-Bit PNG, max. 1 MB |
| **Vorstellungsgrafik (Feature Graphic)**| `google_play/feature_graphic_1024x500.png`| 1024 x 500 | 24-Bit PNG ohne Alpha |
| **Smartphone-Screenshots (8 Stück)**| `google_play/screenshots/*.png` | 1920 x 1080 | Mind. 4, ideal 8 im Querformat |
| **Tablet-Screenshots (7" & 10")** | dieselben `google_play/screenshots/*.png` | 1920 x 1080 | Erhöht Tablet-Sichtbarkeit |

---

## 3. Video-Trailer (Bereits gerendert)

- **Steam Trailer (MP4 & WebM)**:
  - `store/steam/trailer_1080p60.mp4` (H.264/AAC, 39.6 MB)
  - `store/steam/trailer_1080p60.webm` (VP9/Opus, 26.9 MB)
- **Google Play Trailer**:
  - YouTube-URL des Videos eintragen oder `store/play/trailer_1080p60.mp4` auf YouTube hochladen und verlinken.
"""

with open(os.path.join("store/upload_bundle", "UPLOAD_GUIDE.md"), "w", encoding="utf-8") as f:
    f.write(upload_guide_content)

print("=== ALL AAA STORE GRAPHICS GENERATED SUCCESSFULLY ===")
