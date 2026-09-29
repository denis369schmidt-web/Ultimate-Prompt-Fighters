"""Generates the blood textures used by hits and finishers.

blood_drop.png   – soft droplet sprite for particles (white-ish core so it can be tinted)
blood_pool.png   – top-down pool/splat decal with alpha (dark red, glossy highlights)
screen_blood.png – full-screen overlay: splatter around the edges, transparent centre
Output: godot/assets/textures/vfx/

Usage: python scripts/generate_gore_textures.py
"""
import os

import numpy as np
from PIL import Image, ImageFilter

OUT = os.path.join(os.path.dirname(__file__), "..", "godot", "assets", "textures", "vfx")
rng = np.random.default_rng(66)


def blob_field(w, h, blobs):
    """Sum of soft circles -> 0..1 field."""
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    f = np.zeros((h, w), np.float32)
    for (cx, cy, r) in blobs:
        d = np.sqrt((xx - cx) ** 2 + (yy - cy) ** 2)
        f = np.maximum(f, np.clip(1.0 - d / r, 0, 1))
    return f


def save_rgba(rgb, alpha, name):
    img = np.dstack([np.clip(rgb, 0, 1), np.clip(alpha, 0, 1)])
    Image.fromarray((img * 255).astype(np.uint8), "RGBA").save(os.path.join(OUT, name), optimize=True)
    print("wrote", name)


def drop():
    s = 64
    f = blob_field(s, s, [(32, 34, 26), (32, 22, 16)])
    a = np.clip(f * 2.2, 0, 1) ** 1.2
    rgb = np.dstack([np.full((s, s), 1.0), 0.9 * (1 - f) + 0.1, 0.9 * (1 - f) + 0.1])
    save_rgba(rgb, a, "blood_drop.png")


def pool():
    s = 512
    blobs = [(256, 256, 150)]
    for k in range(40):
        ang = rng.uniform(0, 2 * np.pi)
        dist = rng.uniform(80, 230)
        blobs.append((256 + np.cos(ang) * dist, 256 + np.sin(ang) * dist, rng.uniform(8, 45)))
    for k in range(120):
        ang = rng.uniform(0, 2 * np.pi)
        dist = rng.uniform(150, 250)
        blobs.append((256 + np.cos(ang) * dist, 256 + np.sin(ang) * dist, rng.uniform(2, 9)))
    f = blob_field(s, s, blobs)
    a = np.clip(f * 6.0, 0, 1)
    img = Image.fromarray((a * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(1.2))
    a = np.asarray(img).astype(np.float32) / 255.0
    noise = rng.random((s, s)).astype(np.float32)
    noise = np.asarray(Image.fromarray((noise * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(6))).astype(np.float32) / 255.0
    base = np.array([0.33, 0.01, 0.02])
    dark = np.array([0.12, 0.0, 0.01])
    t = np.clip(f * 1.3, 0, 1)[..., None]
    rgb = dark + (base - dark) * (1 - t) + (noise[..., None] - 0.5) * 0.08
    # glossy highlights
    hl = np.clip((noise - 0.62) * 8, 0, 1) * np.clip(f * 3 - 0.5, 0, 1)
    rgb = rgb + hl[..., None] * np.array([0.45, 0.2, 0.2])
    save_rgba(rgb, a * 0.96, "blood_pool.png")


def screen():
    w, h = 1280, 720
    blobs = []
    for k in range(70):
        edge = rng.integers(0, 4)
        if edge == 0: x, y = rng.uniform(0, w), rng.uniform(0, 90)
        elif edge == 1: x, y = rng.uniform(0, w), rng.uniform(h - 90, h)
        elif edge == 2: x, y = rng.uniform(0, 110), rng.uniform(0, h)
        else: x, y = rng.uniform(w - 110, w), rng.uniform(0, h)
        r = rng.uniform(10, 70)
        blobs.append((x, y, r))
        for j in range(6):
            blobs.append((x + rng.normal(0, r * 1.4), y + rng.normal(0, r * 1.4), rng.uniform(2, 9)))
    # drips
    for k in range(18):
        x = rng.uniform(0, w)
        y0 = rng.uniform(0, 60)
        for j in range(int(rng.uniform(10, 40))):
            blobs.append((x + rng.normal(0, 1), y0 + j * 4, 5 - j * 0.08))
    f = blob_field(w, h, blobs)
    a = np.clip(f * 5.0, 0, 1)
    rgb = np.dstack([0.42 - f * 0.18, np.full((h, w), 0.0), np.full((h, w), 0.02)])
    save_rgba(rgb, a * 0.92, "screen_blood.png")


if __name__ == "__main__":
    drop()
    pool()
    screen()
