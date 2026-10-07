"""Cuts the Steam and Google Play store graphics from the raw renders of tests/render_store_art.gd.

Usage (from the repository root):
    godot --path godot --script res://tests/render_store_art.gd -- --out=<abs path>/store/raw
    python scripts/store_art.py [--raw store/raw] [--out store]

Writes store/steam/* and store/play/* in the exact pixel sizes the stores ask for
(see docs/STORE_RELEASE.md). Needs Pillow.
"""
import argparse
import glob
import os

from PIL import Image, ImageDraw, ImageEnhance, ImageFilter


def load(raw, name):
    return Image.open(os.path.join(raw, name)).convert("RGBA")


def cover(img, size, focus=(0.5, 0.5)):
    """Scales img to fill size and crops around focus (0..1 of the source)."""
    w, h = size
    s = max(w / img.width, h / img.height)
    big = img.resize((max(w, round(img.width * s)), max(h, round(img.height * s))), Image.LANCZOS)
    x = min(max(round(big.width * focus[0] - w / 2), 0), big.width - w)
    y = min(max(round(big.height * focus[1] - h / 2), 0), big.height - h)
    return big.crop((x, y, x + w, y + h))


def trim(img):
    box = img.getchannel("A").getbbox()
    return img.crop(box) if box else img


def shade(img, side="bottom", strength=0.75, extent=0.55):
    """Darkens one edge so the logo stays readable on busy art."""
    w, h = img.size
    grad = Image.new("L", (w, h), 0)
    d = ImageDraw.Draw(grad)
    n = int((h if side in ("bottom", "top") else w) * extent)
    for i in range(n):
        a = int(255 * strength * (1 - i / n) ** 1.6)
        if side == "bottom":
            d.line([(0, h - 1 - i), (w, h - 1 - i)], fill=a)
        elif side == "top":
            d.line([(0, i), (w, i)], fill=a)
        elif side == "left":
            d.line([(i, 0), (i, h)], fill=a)
    black = Image.new("RGBA", (w, h), (0, 0, 0, 255))
    return Image.composite(black, img, grad)


def put_logo(img, logo, box):
    """Fits the trimmed logo into box (x, y, w, h), centred, with a soft dark glow behind it."""
    x, y, w, h = box
    s = min(w / logo.width, h / logo.height)
    lg = logo.resize((max(1, round(logo.width * s)), max(1, round(logo.height * s))), Image.LANCZOS)
    px = x + (w - lg.width) // 2
    py = y + (h - lg.height) // 2
    glow = Image.new("RGBA", img.size, (0, 0, 0, 0))
    alpha = lg.getchannel("A").point(lambda v: int(v * 0.7))
    glow.paste(Image.new("RGBA", lg.size, (0, 0, 0, 255)), (px, py), alpha)
    glow = glow.filter(ImageFilter.GaussianBlur(max(2, lg.height // 18)))
    out = Image.alpha_composite(img, glow)
    out.alpha_composite(lg, (px, py))
    return out


def save(img, path, rgb=True, quality=None):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    if rgb:
        img = img.convert("RGB")
    if path.endswith(".jpg"):
        img.convert("RGB").save(path, quality=quality or 92, optimize=True)
    else:
        img.save(path, optimize=True)
    print("WROTE", path, img.size)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--raw", default="store/raw")
    ap.add_argument("--out", default="store")
    a = ap.parse_args()
    wide = load(a.raw, "keyart_wide.png")
    tall = load(a.raw, "keyart_tall.png")
    face = load(a.raw, "icon_face.png")
    logo = trim(load(a.raw, "logo.png"))
    shots = sorted(glob.glob(os.path.join(a.raw, "shot_*.png")))
    steam = os.path.join(a.out, "steam")
    play = os.path.join(a.out, "play")

    def capsule(size, logo_frac=0.42, focus=(0.5, 0.45)):
        w, h = size
        img = shade(cover(wide, size, focus), "bottom", 0.8, 0.6)
        lh = int(h * logo_frac)
        return put_logo(img, logo, (int(w * 0.06), h - lh - int(h * 0.05), int(w * 0.88), lh))

    def portrait(size):
        w, h = size
        img = shade(cover(tall, size, (0.5, 0.42)), "bottom", 0.85, 0.5)
        lh = int(h * 0.24)
        return put_logo(img, logo, (int(w * 0.05), h - lh - int(h * 0.04), int(w * 0.9), lh))

    # ── Steam (Steamworks → Store-Seite → Grafische Elemente) ──
    save(capsule((920, 430)), os.path.join(steam, "header_capsule_920x430.png"))
    small = shade(cover(wide, (462, 174), (0.5, 0.4)), "bottom", 0.6, 1.0)
    save(put_logo(small, logo, (12, 8, 438, 158)), os.path.join(steam, "small_capsule_462x174.png"))
    save(capsule((1232, 706), 0.36), os.path.join(steam, "main_capsule_1232x706.png"))
    save(portrait((748, 896)), os.path.join(steam, "vertical_capsule_748x896.png"))
    bg = ImageEnhance.Brightness(cover(wide, (1438, 810)).filter(ImageFilter.GaussianBlur(6))).enhance(0.45)
    save(bg, os.path.join(steam, "page_background_1438x810.png"))
    # Library (Steamworks → Bibliotheksgrafiken)
    save(portrait((600, 900)), os.path.join(steam, "library_capsule_600x900.png"))
    save(capsule((920, 430)), os.path.join(steam, "library_header_920x430.png"))
    save(cover(wide, (3840, 1240), (0.5, 0.42)), os.path.join(steam, "library_hero_3840x1240.png"))
    lib_logo = Image.new("RGBA", (1280, 720), (0, 0, 0, 0))
    lib_logo.alpha_composite(logo.resize((1280, round(logo.height * 1280 / logo.width)), Image.LANCZOS)
                             if logo.width / logo.height > 1280 / 720 else
                             logo.resize((round(logo.width * 720 / logo.height), 720), Image.LANCZOS))
    save(trim(lib_logo), os.path.join(steam, "library_logo_transparent.png"), rgb=False)
    icon_path = os.path.join("godot", "icon_512.png")
    if os.path.exists(icon_path):
        face = Image.open(icon_path).convert("RGBA")
    else:
        face = load(a.raw, "icon_face.png")

    save(face.resize((184, 184), Image.LANCZOS), os.path.join(steam, "community_icon_184x184.jpg"))
    face.resize((256, 256), Image.LANCZOS).save(os.path.join(steam, "client_icon.ico"),
                                                sizes=[(16, 16), (32, 32), (48, 48), (64, 64), (256, 256)])
    print("WROTE", os.path.join(steam, "client_icon.ico"))
    
    # Process only canonical shots 01..08
    shot_files = [os.path.join(a.raw, "shot_%02d.png" % i) for i in range(1, 9)]
    for i, s in enumerate(shot_files, 1):
        if not os.path.exists(s): continue
        raw_img = Image.open(s).convert("RGBA")
        if raw_img.size != (1920, 1080):
            raw_img = raw_img.resize((1920, 1080), Image.LANCZOS)
        save(raw_img, os.path.join(steam, "screenshots", "screenshot_%02d_1920x1080.jpg" % i), rgb=True, quality=94)
        save(raw_img, os.path.join(play, "screenshots", "screenshot_%02d_1920x1080.png" % i), rgb=False)

    # ── Google Play (Play Console → Store-Eintrag → Grafiken) ──
    save(face.resize((512, 512), Image.LANCZOS), os.path.join(play, "app_icon_512x512.png"), rgb=False)  # 32-bit PNG
    feat = shade(cover(wide, (1024, 500), (0.5, 0.45)), "bottom", 0.8, 0.6)
    save(put_logo(feat, logo, (90, 270, 844, 200)), os.path.join(play, "feature_graphic_1024x500.png"))


if __name__ == "__main__":
    main()

