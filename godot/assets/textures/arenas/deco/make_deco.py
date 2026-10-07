"""Draws the arena decoration textures (own work, CC0 like the rest of the generated art).

Neon signs, graffiti, stadium crowd and shoji paper. Fonts: Russo One and Teko (SIL OFL 1.1,
godot/assets/fonts/); rendering text into a picture is allowed by the OFL.
No real brands or logos: all names are generic German shop words.
Usage: python godot/assets/textures/arenas/deco/make_deco.py
"""
import math
import os
import random

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
FONTS = os.path.join(HERE, "..", "..", "..", "fonts")
RUSSO = os.path.join(FONTS, "RussoOne-Regular.ttf")
TEKO = os.path.join(FONTS, "Teko.ttf")
rnd = random.Random(7)


def glow_layer(mask, color, blur_big=18, blur_small=5):
    """Neon tube look: wide soft halo, tight glow, white-hot core."""
    w, h = mask.size
    black = Image.new("RGB", (w, h), (0, 0, 0))
    out = black.copy()
    for radius, gain in ((blur_big, 0.9), (blur_small, 1.0)):
        m = mask.filter(ImageFilter.GaussianBlur(radius)).point(lambda v, g=gain: min(255, int(v * 1.6 * g)))
        out = ImageChops.add(out, Image.composite(Image.new("RGB", (w, h), color), black, m))
    core = mask.filter(ImageFilter.GaussianBlur(1.2))
    hot = tuple(int(c * 0.35 + 255 * 0.65) for c in color)
    return Image.composite(Image.new("RGB", (w, h), hot), out, core)


def tube_text(size_px, text, font_path, size, stroke, vertical=False):
    w, h = size_px
    mask = Image.new("L", (w, h), 0)
    d = ImageDraw.Draw(mask)
    f = ImageFont.truetype(font_path, size)
    if vertical:
        step = (h - 60) / len(text)
        for k, ch in enumerate(text):
            bb = d.textbbox((0, 0), ch, font=f)
            x = (w - (bb[2] - bb[0])) / 2 - bb[0]
            y = 30 + k * step + (step - (bb[3] - bb[1])) / 2 - bb[1]
            d.text((x, y), ch, font=f, fill=0, stroke_width=stroke, stroke_fill=255)
    else:
        while size > 30 and d.textbbox((0, 0), text, font=f, stroke_width=stroke)[2] > w - 110:
            size -= 4
            f = ImageFont.truetype(font_path, size)
        bb = d.textbbox((0, 0), text, font=f)
        x = (w - (bb[2] - bb[0])) / 2 - bb[0]
        y = (h - (bb[3] - bb[1])) / 2 - bb[1]
        d.text((x, y), text, font=f, fill=0, stroke_width=stroke, stroke_fill=255)
    return mask


def frame_mask(size, inset, radius, width):
    m = Image.new("L", size, 0)
    ImageDraw.Draw(m).rounded_rectangle((inset, inset, size[0] - inset, size[1] - inset), radius, outline=255, width=width)
    return m


def neon_atlas():
    """2048x1024: top half 4x2 horizontal signs (512x256), bottom half 8 vertical signs (256x512)."""
    atlas = Image.new("RGB", (2048, 1024), (0, 0, 0))
    horiz = [("RAMEN", (255, 70, 160)), ("BAR", (40, 220, 255)), ("HOTEL", (255, 200, 60)), ("24/7", (120, 255, 140)),
             ("KARAOKE", (190, 90, 255)), ("SPIELHALLE", (255, 120, 60)), ("NUDELN", (60, 200, 255)), ("TATTOO", (255, 60, 90))]
    for k, (word, col) in enumerate(horiz):
        cw, ch = 512, 256
        size = 150 if len(word) <= 5 else (110 if len(word) <= 7 else 74)
        m = tube_text((cw, ch), word, RUSSO, size, 4)
        m = ImageChops.lighter(m, frame_mask((cw, ch), 26, 28, 5))
        if k % 3 == 0:
            ImageDraw.Draw(m).line((150, ch - 52, cw - 150, ch - 52), fill=255, width=5)
        atlas.paste(glow_layer(m, col), ((k % 4) * cw, (k // 4) * ch))
    vert = [("HOTEL", (255, 80, 170)), ("BAR", (50, 230, 255)), ("KAFFEE", (255, 190, 70)), ("RAMEN", (255, 90, 90)),
            ("DOJO", (140, 255, 170)), ("NEON", (200, 110, 255)), ("ZIMMER", (90, 170, 255)), ("OFFEN", (255, 140, 60))]
    for k, (word, col) in enumerate(vert):
        cw, ch = 256, 512
        m = tube_text((cw, ch), word, TEKO, int(min(150, 470 / len(word) * 1.15)), 4, vertical=True)
        m = ImageChops.lighter(m, frame_mask((cw, ch), 18, 20, 5))
        atlas.paste(glow_layer(m, col, 14, 4), (k * cw, 512))
    atlas.save(os.path.join(HERE, "neon_signs.png"))


def graffiti_atlas():
    """1024x1024 RGBA, 2x2 pieces: bubble letters with outline, shadow, drips, tags."""
    img = Image.new("RGBA", (1024, 1024), (0, 0, 0, 0))
    pieces = [("KO!", [(255, 70, 160), (255, 210, 60)]), ("RISS", [(60, 220, 255), (160, 90, 255)]),
              ("FIGHT", [(255, 120, 40), (255, 230, 90)]), ("PROMPT", [(120, 255, 120), (40, 180, 255)])]
    for k, (word, cols) in enumerate(pieces):
        cell = Image.new("RGBA", (512, 512), (0, 0, 0, 0))
        fs = 170 if len(word) <= 4 else (118 if len(word) == 5 else 96)
        f = ImageFont.truetype(RUSSO, fs)
        so, si = int(fs * 0.1), max(3, int(fs * 0.03))
        d = ImageDraw.Draw(cell)
        bb = d.textbbox((0, 0), word, font=f)
        x = (512 - (bb[2] - bb[0])) / 2 - bb[0]
        y = (512 - (bb[3] - bb[1])) / 2 - bb[1] - 20
        d.text((x + 12, y + 14), word, font=f, fill=(10, 10, 20, 230), stroke_width=so + 2, stroke_fill=(10, 10, 20, 230))
        d.text((x, y), word, font=f, fill=(0, 0, 0, 255), stroke_width=so, stroke_fill=(15, 15, 22, 255))
        fill_mask = Image.new("L", (512, 512), 0)
        ImageDraw.Draw(fill_mask).text((x, y), word, font=f, fill=255, stroke_width=si, stroke_fill=255)
        grad = Image.new("RGBA", (512, 512))
        gd = ImageDraw.Draw(grad)
        for yy in range(512):
            t = min(1.0, max(0.0, (yy - y) / max(1, bb[3] - bb[1] + 40)))
            c = tuple(int(cols[0][i] * (1 - t) + cols[1][i] * t) for i in range(3))
            gd.line((0, yy, 512, yy), fill=c + (255,))
        cell = Image.composite(grad, cell, fill_mask)
        d = ImageDraw.Draw(cell)
        for s in range(6):
            hx = x + rnd.uniform(0.1, 0.9) * (bb[2] - bb[0])
            d.line((hx, y + 30, hx + 18, y + 30), fill=(255, 255, 255, 220), width=6)
        for s in range(5):
            dx = x + rnd.uniform(0.05, 0.95) * (bb[2] - bb[0])
            dy = y + (bb[3] - bb[1]) + 10
            ln = rnd.uniform(30, 110)
            d.line((dx, dy, dx, dy + ln), fill=cols[1] + (255,), width=7)
            d.ellipse((dx - 6, dy + ln - 4, dx + 6, dy + ln + 8), fill=cols[1] + (255,))
        tf = ImageFont.truetype(TEKO, 60)
        d.text((40 + rnd.uniform(0, 200), 400), rnd.choice(["zx9", "nova", "kruemel", "ok"]), font=tf, fill=(240, 240, 240, 235))
        for s in range(4):
            cx, cy, r = rnd.uniform(40, 470), rnd.uniform(30, 120), rnd.uniform(10, 22)
            pts = [(cx + math.cos(a * math.pi / 5) * (r if a % 2 == 0 else r * 0.45),
                    cy + math.sin(a * math.pi / 5) * (r if a % 2 == 0 else r * 0.45)) for a in range(10)]
            d.polygon(pts, fill=(255, 255, 255, 230))
        noise = Image.effect_noise((512, 512), 60).filter(ImageFilter.GaussianBlur(1.5)).point(lambda v: 255 if v > 70 else int(v * 3.6))
        cell.putalpha(ImageChops.multiply(cell.split()[3], noise))
        img.paste(cell, ((k % 2) * 512, (k // 2) * 512))
    img.save(os.path.join(HERE, "graffiti.png"))


def crowd():
    """1024x256 RGBA tile: three rows of spectators (heads, shoulders, raised arms, scarves)."""
    w, h = 1024, 256
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    shirts = [(200, 40, 50), (40, 90, 200), (230, 200, 60), (240, 240, 240), (40, 40, 48), (60, 160, 90), (230, 120, 40), (120, 60, 160)]
    skins = [(240, 200, 170), (200, 150, 110), (150, 100, 70), (95, 60, 40), (230, 180, 140)]
    hairs = [(30, 22, 18), (80, 50, 30), (200, 170, 100), (20, 20, 20), (120, 120, 120)]
    for row in range(3):
        base = 100 + row * 70
        x = -10 + row * 13
        while x < w + 10:
            sw = rnd.randint(30, 40)
            col = rnd.choice(shirts)
            shade = tuple(int(c * (0.65 + row * 0.15)) for c in col)
            d.rounded_rectangle((x, base, x + sw, base + 90), 12, fill=shade + (255,))
            skin = tuple(int(c * (0.7 + row * 0.12)) for c in rnd.choice(skins))
            hr = rnd.randint(10, 13)
            cx = x + sw / 2
            d.ellipse((cx - hr, base - 2 * hr + 4, cx + hr, base + 6), fill=skin + (255,))
            hair = tuple(int(c * (0.7 + row * 0.12)) for c in rnd.choice(hairs))
            d.chord((cx - hr, base - 2 * hr + 2, cx + hr, base + 2), 180, 360, fill=hair + (255,))
            if rnd.random() < 0.3:
                ax = x + (sw if rnd.random() < 0.5 else 0)
                d.line((ax, base + 15, ax + rnd.uniform(-10, 10), base - 45), fill=shade + (255,), width=9)
                d.ellipse((ax - 7, base - 55, ax + 7, base - 41), fill=skin + (255,))
            if rnd.random() < 0.15:
                sc = rnd.choice(shirts)
                d.rectangle((x - 10, base - 40, x + sw + 30, base - 26), fill=sc + (255,))
            x += sw + rnd.randint(-2, 6)
    img.save(os.path.join(HERE, "crowd.png"))


def shoji():
    """512x512 shoji screen: warm paper with fibres, dark wooden lattice (kumiko)."""
    w = 512
    paper = Image.effect_noise((w, w), 18).convert("L").filter(ImageFilter.GaussianBlur(0.8))
    img = Image.merge("RGB", [paper.point(lambda v: 200 + v // 8), paper.point(lambda v: 180 + v // 9), paper.point(lambda v: 130 + v // 10)])
    d = ImageDraw.Draw(img)
    for k in range(60):
        x, y = rnd.uniform(0, w), rnd.uniform(0, w)
        d.line((x, y, x + rnd.uniform(-30, 30), y + rnd.uniform(-8, 8)), fill=(235, 220, 175), width=1)
    wood = (58, 36, 22)
    for k in range(5):
        x = k * w / 4
        d.rectangle((x - 7, 0, x + 7, w), fill=wood)
    for k in range(7):
        y = k * w / 6
        d.rectangle((0, y - 6, w, y + 6), fill=wood)
    img.save(os.path.join(HERE, "shoji.png"))


if __name__ == "__main__":
    neon_atlas()
    graffiti_atlas()
    crowd()
    shoji()
    print("ok")
