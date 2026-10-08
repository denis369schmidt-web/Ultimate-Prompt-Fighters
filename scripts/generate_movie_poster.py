"""Generates an authentic Hollywood Movie Poster from the cinematic clash plate.

Outputs:
  - scratch/movie_poster_16x9.png (1920x1080 Cinematic Billboard)
  - scratch/movie_poster_vertical.png (1200x1800 Theatrical One-Sheet Poster)
  - Also copied to Artifact directory for instant IDE preview.
"""

import os
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageEnhance

# ── Source Plate ──────────────────────────────────────────────────────────────
SOURCE_PLATE = "store/trailer/cinematics/cinematic_fighter_clash_1791379963009.jpg"
FONT_RUSSO = "godot/assets/fonts/RussoOne-Regular.ttf"
FONT_TEKO = "godot/assets/fonts/Teko.ttf"
FONT_ARIAL = "C:/Windows/Fonts/arialbd.ttf"
FONT_BAHN = "C:/Windows/Fonts/bahnschrift.ttf"

raw_img = Image.open(SOURCE_PLATE).convert("RGBA")
if raw_img.size != (1920, 1080):
    raw_img = raw_img.resize((1920, 1080), Image.LANCZOS)

# ── Fonts Setup ───────────────────────────────────────────────────────────────
font_tagline = ImageFont.truetype(FONT_BAHN, 24)
font_title_main = ImageFont.truetype(FONT_RUSSO, 96)
font_title_sub = ImageFont.truetype(FONT_RUSSO, 36)
font_starring = ImageFont.truetype(FONT_BAHN, 20)
font_credits_small = ImageFont.truetype(FONT_TEKO, 22)
font_credits_names = ImageFont.truetype(FONT_TEKO, 26)
font_release = ImageFont.truetype(FONT_RUSSO, 34)
font_studio = ImageFont.truetype(FONT_BAHN, 16)

# ── Bottom Vignette for Contrast ──────────────────────────────────────────────
def apply_bottom_vignette(img, height=480, max_alpha=230):
    w, h = img.size
    grad = Image.new("L", (w, h), 0)
    d = ImageDraw.Draw(grad)
    for i in range(height):
        factor = (1.0 - (i / float(height))) ** 1.6
        alpha = int(max_alpha * factor)
        d.line([(0, h - 1 - i), (w, h - 1 - i)], fill=alpha)
    black = Image.new("RGBA", (w, h), (4, 6, 12, 255))
    return Image.composite(black, img, grad)

def apply_top_vignette(img, height=220, max_alpha=180):
    w, h = img.size
    grad = Image.new("L", (w, h), 0)
    d = ImageDraw.Draw(grad)
    for i in range(height):
        factor = (1.0 - (i / float(height))) ** 1.5
        alpha = int(max_alpha * factor)
        d.line([(0, i), (w, i)], fill=alpha)
    black = Image.new("RGBA", (w, h), (4, 6, 12, 255))
    return Image.composite(black, img, grad)

# ── Draw Centered Text Helper ─────────────────────────────────────────────────
def draw_centered_text(draw, y, text, font, fill=(255, 255, 255, 255), shadow_color=(0, 0, 0, 200), shadow_offset=3):
    bbox = draw.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    cx = (1920 - tw) // 2
    if shadow_offset > 0:
        draw.text((cx + shadow_offset, y + shadow_offset), text, font=font, fill=shadow_color)
    draw.text((cx, y), text, font=font, fill=fill)
    return y + th

# ── Render 16:9 Cinematic Movie Poster ────────────────────────────────────────
print("Generating 16:9 Cinematic Movie Poster...")
poster16 = apply_bottom_vignette(raw_img, height=520, max_alpha=240)
poster16 = apply_top_vignette(poster16, height=200, max_alpha=160)

overlay = Image.new("RGBA", (1920, 1080), (0, 0, 0, 0))
d = ImageDraw.Draw(overlay)

# 1. Top Billing / Tagline
tagline_top = "A DENIS SCHMIDT CINEMATIC SPECTACLE"
draw_centered_text(d, 35, tagline_top, font_studio, fill=(180, 210, 240, 220), shadow_offset=2)

tagline_main = "WHEN LIGHTNING MEETS THE INFERNO · ONLY ONE REALM SURVIVES"
draw_centered_text(d, 65, tagline_main, font_tagline, fill=(255, 210, 120, 245), shadow_offset=2)

# 2. Main Title (Lower Third)
title_main = "RECKONING"
title_sub = "THUNDER  &  STONE"

# Title glow
glow_y = 660
bbox_m = d.textbbox((0, 0), title_main, font=font_title_main)
tw_m = bbox_m[2] - bbox_m[0]
cx_m = (1920 - tw_m) // 2

# Draw metallic layered text with orange/cyan rim highlight
for dx, dy in [(-3, 0), (3, 0), (0, -3), (0, 3), (-2, -2), (2, 2)]:
    d.text((cx_m + dx, glow_y + dy), title_main, font=font_title_main, fill=(10, 16, 28, 255))
# Core text
d.text((cx_m, glow_y), title_main, font=font_title_main, fill=(245, 248, 255, 255))

# Subtitle in golden amber
draw_centered_text(d, glow_y + 102, title_sub, font_title_sub, fill=(255, 175, 45, 255), shadow_color=(0, 0, 0, 255), shadow_offset=3)

# 3. Starring Section
starring_text = "Starring:  KAIRO VANCE   CYRUS BREN   ELENA ROSTOVA   MARCUS STONE"
draw_centered_text(d, 825, starring_text, font_starring, fill=(220, 235, 255, 240), shadow_offset=2)

# Thin cinematic horizontal divider
d.line([(460, 860), (1460, 860)], fill=(255, 180, 50, 140), width=1)

# 4. Hollywood Credit Block (Teko font, authentic density)
c_line1 = "WARNER BROS. PICTURES AND LEGENDARY PICTURES PRESENT A DENIS SCHMIDT FILM  \"RECKONING: THUNDER & STONE\""
c_line2 = "MUSIC BY HANS ZIMMER   COSTUME DESIGNER SARAH CONNOR   PRODUCTION DESIGNER ARTHUR MAX   EDITOR DAVID FINCHER"
c_line3 = "DIRECTOR OF PHOTOGRAPHY ROGER DEAKINS, ASC   VISUAL EFFECTS SUPERVISOR JOE LETTERI   CO-PRODUCER KATHLEEN KENNEDY"
c_line4 = "EXECUTIVE PRODUCERS CHRISTOPHER NOLAN  DENIS SCHMIDT   PRODUCED BY KEVIN FEIGE   SCREENPLAY BY JONATHAN NOLAN"
c_line5 = "DIRECTED BY DENIS SCHMIDT"

draw_centered_text(d, 872, c_line1, font_credits_small, fill=(190, 205, 220, 220), shadow_offset=1)
draw_centered_text(d, 896, c_line2, font_credits_small, fill=(180, 195, 210, 210), shadow_offset=1)
draw_centered_text(d, 920, c_line3, font_credits_small, fill=(180, 195, 210, 210), shadow_offset=1)
draw_centered_text(d, 944, c_line4, font_credits_small, fill=(180, 195, 210, 210), shadow_offset=1)
draw_centered_text(d, 968, c_line5, font_credits_names, fill=(240, 245, 255, 255), shadow_offset=1)

# 5. Badges (IMAX & DOLBY)
def draw_badge(draw, cx, cy, label):
    bw, bh = 76, 22
    draw.rectangle([(cx - bw//2, cy - bh//2), (cx + bw//2, cy + bh//2)], outline=(180, 200, 220, 200), width=1)
    bb = draw.textbbox((0, 0), label, font=font_studio)
    tw = bb[2] - bb[0]
    draw.text((cx - tw//2, cy - 9), label, font=font_studio, fill=(220, 235, 250, 240))

draw_badge(d, 380, 1030, "IMAX")
draw_badge(d, 1540, 1030, "DOLBY")

# 6. Release Note
release_text = "IN THEATERS & IMAX · SUMMER 2026"
draw_centered_text(d, 1012, release_text, font_release, fill=(255, 195, 55, 255), shadow_color=(0, 0, 0, 255), shadow_offset=3)

final_poster16 = Image.alpha_composite(poster16, overlay).convert("RGB")
os.makedirs("scratch", exist_ok=True)
final_poster16.save("scratch/movie_poster_16x9.png", quality=95)
print("Saved scratch/movie_poster_16x9.png")

# ── Render Vertical Theatrical One-Sheet (1200x1800, 2:3) ─────────────────────
print("Generating 2:3 Theatrical Movie Poster (1200x1800)...")
POSTER_W, POSTER_H = 1200, 1800
v_bg = Image.new("RGBA", (POSTER_W, POSTER_H), (4, 6, 12, 255))

# Scale & crop action plate to fill upper 75%
s = max(POSTER_W / float(raw_img.width), 1350 / float(raw_img.height))
rw = int(raw_img.width * s)
rh = int(raw_img.height * s)
scaled_plate = raw_img.resize((rw, rh), Image.LANCZOS)
# Center crop
cx_p = (rw - POSTER_W) // 2
crop_plate = scaled_plate.crop((cx_p, 0, cx_p + POSTER_W, 1400))
v_bg.paste(crop_plate, (0, 0))

# Gradient fade between plate and bottom credit area
grad_v = Image.new("L", (POSTER_W, POSTER_H), 0)
d_gv = ImageDraw.Draw(grad_v)
for y in range(800, POSTER_H):
    alpha = int(255 * min(1.0, ((y - 800) / 450.0) ** 1.4))
    d_gv.line([(0, y), (POSTER_W, y)], fill=alpha)
black_v = Image.new("RGBA", (POSTER_W, POSTER_H), (3, 5, 10, 255))
v_bg = Image.composite(black_v, v_bg, grad_v)

# Top fade
for y in range(250):
    alpha = int(180 * (1.0 - (y / 250.0)) ** 1.5)
    d_gv.line([(0, y), (POSTER_W, y)], fill=alpha)
v_bg = Image.composite(black_v, v_bg, grad_v)

overlay_v = Image.new("RGBA", (POSTER_W, POSTER_H), (0, 0, 0, 0))
dv = ImageDraw.Draw(overlay_v)

# Fonts for vertical
font_v_title = ImageFont.truetype(FONT_RUSSO, 110)
font_v_sub = ImageFont.truetype(FONT_RUSSO, 42)
font_v_tag = ImageFont.truetype(FONT_BAHN, 26)
font_v_star = ImageFont.truetype(FONT_BAHN, 22)
font_v_cred_sm = ImageFont.truetype(FONT_TEKO, 24)
font_v_cred_nm = ImageFont.truetype(FONT_TEKO, 28)
font_v_rel = ImageFont.truetype(FONT_RUSSO, 44)

def draw_v_centered(draw, y, text, font, fill, shadow_off=3):
    bb = draw.textbbox((0, 0), text, font=font)
    tw = bb[2] - bb[0]
    th = bb[3] - bb[1]
    cx = (POSTER_W - tw) // 2
    if shadow_off > 0:
        draw.text((cx + shadow_off, y + shadow_off), text, font=font, fill=(0, 0, 0, 220))
    draw.text((cx, y), text, font=font, fill=fill)
    return y + th

# Top Credits & Tagline
draw_v_centered(dv, 45, "A DENIS SCHMIDT CINEMATIC PRODUCTION", font_studio, fill=(180, 210, 240, 220), shadow_off=2)
draw_v_centered(dv, 85, "WHEN LIGHTNING MEETS THE INFERNO", font_v_tag, fill=(255, 210, 120, 255), shadow_off=2)
draw_v_centered(dv, 122, "ONLY ONE REALM SURVIVES", font_v_tag, fill=(255, 175, 45, 240), shadow_off=2)

# Title in center-lower area
draw_v_centered(dv, 1180, "RECKONING", font_v_title, fill=(245, 248, 255, 255), shadow_off=4)
draw_v_centered(dv, 1300, "THUNDER  &  STONE", font_v_sub, fill=(255, 180, 50, 255), shadow_off=3)

# Starring
draw_v_centered(dv, 1375, "Starring:  KAIRO VANCE   CYRUS BREN   ELENA ROSTOVA   MARCUS STONE", font_v_star, fill=(210, 230, 255, 230), shadow_off=2)

# Divider
dv.line([(250, 1425), (950, 1425)], fill=(255, 180, 50, 130), width=1)

# Credit block
draw_v_centered(dv, 1445, "WARNER BROS. PICTURES AND LEGENDARY PICTURES PRESENT A DENIS SCHMIDT FILM  \"RECKONING: THUNDER & STONE\"", font_v_cred_sm, fill=(190, 205, 220, 220), shadow_off=1)
draw_v_centered(dv, 1475, "MUSIC BY HANS ZIMMER   COSTUME DESIGNER SARAH CONNOR   PRODUCTION DESIGNER ARTHUR MAX   EDITOR DAVID FINCHER", font_v_cred_sm, fill=(180, 195, 210, 210), shadow_off=1)
draw_v_centered(dv, 1505, "DIRECTOR OF PHOTOGRAPHY ROGER DEAKINS, ASC   VISUAL EFFECTS SUPERVISOR JOE LETTERI   CO-PRODUCER KATHLEEN KENNEDY", font_v_cred_sm, fill=(180, 195, 210, 210), shadow_off=1)
draw_v_centered(dv, 1535, "EXECUTIVE PRODUCERS CHRISTOPHER NOLAN  DENIS SCHMIDT   PRODUCED BY KEVIN FEIGE   SCREENPLAY BY JONATHAN NOLAN", font_v_cred_sm, fill=(180, 195, 210, 210), shadow_off=1)
draw_v_centered(dv, 1565, "DIRECTED BY DENIS SCHMIDT", font_v_cred_nm, fill=(245, 250, 255, 255), shadow_off=1)

# Release Note
draw_v_centered(dv, 1630, "IN THEATERS & IMAX · NOVEMBER 2026", font_v_rel, fill=(255, 195, 55, 255), shadow_off=3)

# Badges
draw_badge(dv, 380, 1720, "IMAX")
draw_badge(dv, 820, 1720, "DOLBY")

final_vertical = Image.alpha_composite(v_bg, overlay_v).convert("RGB")
final_vertical.save("scratch/movie_poster_vertical.png", quality=95)
print("Saved scratch/movie_poster_vertical.png")

# Copy to artifacts directory
ART_DIR = r"C:\Users\schmidtdenis\.gemini\antigravity-ide\brain\296c1e2f-aa88-4cbf-97eb-8032653d3c4e"
final_poster16.save(os.path.join(ART_DIR, "movie_poster_16x9.png"), quality=95)
final_vertical.save(os.path.join(ART_DIR, "movie_poster_vertical.png"), quality=95)
print("Copied posters to artifact directory!")
