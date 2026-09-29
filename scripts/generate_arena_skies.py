"""Generates the arena sky panoramas (equirectangular, seamless horizontally).

Each arena gets a calm, readable backdrop: color gradient, sun or moon with glow,
optional stars, nebula and clouds, three layers of mountain silhouettes fading into
haze, and an arena-specific horizon (lava glow, sea, glowing forest).
Output: godot/assets/textures/arenas/sky2_<id>.png

Usage: python scripts/generate_arena_skies.py
"""
import math
import os

import numpy as np
from PIL import Image

W, H = 2048, 1024
HORIZON = 0.52          # fraction of the height where the horizon sits
OUT = os.path.join(os.path.dirname(__file__), "..", "godot", "assets", "textures", "arenas")


def hex_rgb(h):
    h = h.lstrip("#")
    return np.array([int(h[i:i + 2], 16) / 255.0 for i in (0, 2, 4)])


def periodic_noise(rng, w, h, cells_x, cells_y, octaves=5):
    """Fractal value noise, tileable along x."""
    out = np.zeros((h, w))
    amp, total = 1.0, 0.0
    for o in range(octaves):
        cx, cy = cells_x * 2 ** o, cells_y * 2 ** o
        grid = rng.random((cy + 1, cx))
        xs = np.linspace(0, cx, w, endpoint=False)
        ys = np.linspace(0, cy, h)
        x0 = np.floor(xs).astype(int) % cx
        x1 = (x0 + 1) % cx
        y0 = np.clip(np.floor(ys).astype(int), 0, cy - 1)
        y1 = y0 + 1
        fx = xs - np.floor(xs)
        fy = ys - np.floor(ys)
        fx = fx * fx * (3 - 2 * fx)
        fy = fy * fy * (3 - 2 * fy)
        a = grid[y0][:, x0]
        b = grid[y0][:, x1]
        c = grid[y1][:, x0]
        d = grid[y1][:, x1]
        top = a + (b - a) * fx[None, :]
        bot = c + (d - c) * fx[None, :]
        out += amp * (top + (bot - top) * fy[:, None])
        total += amp
        amp *= 0.5
    return out / total


def ridge_line(rng, w, base, height, cells, octaves=6):
    """1D tileable mountain profile (fraction of image height, measured upwards)."""
    n = periodic_noise(rng, w, 2, cells, 1, octaves)[0]
    n = (n - n.min()) / (n.max() - n.min() + 1e-9)
    return base + n ** 1.6 * height


def disk(img, cx, cy, radius, color, glow_radius, glow_strength):
    yy, xx = np.mgrid[0:H, 0:W]
    dx = np.minimum(np.abs(xx - cx), W - np.abs(xx - cx))
    d = np.sqrt(dx ** 2 + (yy - cy) ** 2)
    glow = np.exp(-(d / glow_radius) ** 2) * glow_strength
    img += glow[..., None] * color
    core = np.clip((radius - d) / 2.5, 0, 1)
    img[:] = img * (1 - core[..., None]) + core[..., None] * color * 1.15
    return d


def build(cfg, seed):
    rng = np.random.default_rng(seed)
    v = np.linspace(0, 1, H)[:, None]
    img = np.zeros((H, W, 3))
    zen, mid, hor = hex_rgb(cfg["zenith"]), hex_rgb(cfg["mid"]), hex_rgb(cfg["horizon"])
    # Sky gradient: zenith -> mid -> horizon, then ground haze below.
    t = np.clip(v / HORIZON, 0, 1)
    upper = np.where(t < 0.6, 0, 1)
    g1 = zen + (mid - zen) * np.clip(t / 0.6, 0, 1)[..., None]
    g2 = mid + (hor - mid) * np.clip((t - 0.6) / 0.4, 0, 1)[..., None]
    img[:] = np.where(upper[..., None] == 0, g1, g2)
    below = v > HORIZON
    ground = hex_rgb(cfg["ground"])
    k = np.clip((v - HORIZON) / (1 - HORIZON), 0, 1) ** 0.5
    rows_below = below[:, 0]
    img[rows_below] = (hor + (ground - hor) * k[rows_below])[:, None, :]

    sky_mask = (v < HORIZON).astype(float)
    if cfg.get("stars"):
        stars = rng.random((H, W)) > 0.9985
        bright = rng.random((H, W)) * stars
        fade = np.clip(1 - v / (HORIZON * 0.9), 0, 1)
        img += (bright * fade * sky_mask)[..., None] * np.array([1.0, 0.95, 0.9]) * 1.2
    if cfg.get("nebula"):
        n = periodic_noise(rng, W, H, 6, 3, 6)
        n = np.clip((n - 0.45) * 2.4, 0, 1) ** 2
        fade = np.clip(1 - v / HORIZON, 0, 1) * sky_mask
        img += (n * fade)[..., None] * hex_rgb(cfg["nebula"]) * 0.55
    if cfg.get("clouds"):
        n = periodic_noise(rng, W, H, 8, 6, 6)
        band = np.exp(-((v - HORIZON * 0.62) / 0.14) ** 2)
        c = np.clip((n - 0.5) * 3.0, 0, 1) * band * sky_mask
        img = img * (1 - c[..., None] * 0.75) + c[..., None] * hex_rgb(cfg["clouds"]) * 0.75

    # Sun / moon, centred on the direction the battle camera looks at.
    sx, sy = cfg["sun_u"] * W, (HORIZON - cfg["sun_elev"]) * H
    disk(img, sx, sy, cfg["sun_r"], hex_rgb(cfg["sun"]), cfg["sun_r"] * 5.5, cfg.get("sun_glow", 0.6))
    if cfg.get("moon_detail"):
        n = periodic_noise(rng, W, H, 90, 45, 3)
        yy, xx = np.mgrid[0:H, 0:W]
        d = np.sqrt((xx - sx) ** 2 + (yy - sy) ** 2)
        inside = (d < cfg["sun_r"] - 1)
        img[inside] *= (0.82 + 0.3 * n[inside])[..., None]

    # Mountain layers, far (hazy) to near (dark).
    haze = hex_rgb(cfg["haze"])
    rock = hex_rgb(cfg["rock"])
    rows = np.arange(H)[:, None]
    for layer, (height, cells, mix) in enumerate([] if cfg.get("city") else [(0.10, 5, 0.75), (0.075, 8, 0.45), (0.045, 13, 0.15)]):
        prof = ridge_line(rng, W, 0.004, height * cfg.get("mountain_scale", 1.0), cells)
        top_px = (HORIZON - prof) * H
        mask = (rows >= top_px[None, :]) & (rows <= HORIZON * H + 4)
        col = rock + (haze - rock) * mix
        # Slight vertical gradient inside the silhouette.
        shade = np.clip((rows - top_px[None, :]) / 60.0, 0, 1)
        layer_col = col[None, None, :] * (1.0 - 0.25 * shade[..., None])
        img = np.where(mask[..., None], layer_col, img)
        if cfg.get("rim") and layer == 1:
            # Moonlit rim only on the middle ridge, soft.
            edge = mask & (rows <= top_px[None, :] + 1)
            img[edge] = img[edge] * 0.7 + hex_rgb(cfg["rim"]) * 0.3

    if cfg.get("aurora"):
        xs = np.linspace(0, 1, W, endpoint=False)[None, :]
        n = periodic_noise(rng, W, H, 5, 3, 4)
        for band, (col, off) in enumerate([("5eead4", 0.0), ("a78bfa", 0.33), ("34d399", 0.66)]):
            wave = HORIZON * (0.45 + 0.12 * band) + 0.05 * np.sin((xs * 3 + off + n * 0.6) * 2 * np.pi)
            curtain = np.exp(-((v - wave) / 0.05) ** 2) * (0.55 + 0.45 * np.sin(xs * 90 + n * 20))
            img += (curtain * sky_mask)[..., None] * hex_rgb(col) * 0.55
    if cfg.get("city"):
        # Skyline: layered buildings with lit windows instead of mountains.
        for layer, (hmax, width, shade) in enumerate([(0.2, 60, 0.55), (0.14, 90, 0.3), (0.09, 120, 0.1)]):
            x = 0
            while x < W:
                bw = int(rng.integers(width // 2, width))
                bh = rng.uniform(0.3, 1.0) * hmax
                top = int((HORIZON - bh) * H)
                col = hex_rgb(cfg["rock"]) + (hex_rgb(cfg["haze"]) - hex_rgb(cfg["rock"])) * shade
                img[top:int(HORIZON * H) + 2, x:x + bw] = col
                lit = rng.random(((int(HORIZON * H) - top) // 8 + 1, bw // 6 + 1)) > 0.72
                for wy in range(lit.shape[0]):
                    for wx in range(lit.shape[1]):
                        if lit[wy, wx]:
                            yy, xx = top + 4 + wy * 8, x + 2 + wx * 6
                            wcol = hex_rgb(["ffd27a", "7df9ff", "ff5ecf"][int(rng.integers(0, 3))]) * (0.6 + 0.4 * (2 - layer) / 2)
                            img[yy:yy + 3, xx:xx + 2] = wcol
                x += bw + int(rng.integers(0, 6))

    # Arena-specific horizon features.
    hy = int(HORIZON * H)
    if cfg.get("lava"):
        glow = np.exp(-((v - HORIZON) / 0.035) ** 2)
        n = periodic_noise(rng, W, H, 30, 4, 4)
        img += (glow * (0.5 + n))[..., None] * hex_rgb(cfg["lava"]) * 0.9
    if cfg.get("sea"):
        sea = v > HORIZON
        n = periodic_noise(rng, W, H, 120, 60, 3)
        waves = (np.sin(rows * 0.9 + n * 12) * 0.5 + 0.5) * 0.08
        sea_col = hex_rgb(cfg["sea"])
        refl = np.exp(-((np.arange(W)[None, :] - sx) / 60.0) ** 2) * np.clip(1 - (v - HORIZON) * 3, 0, 1)
        img = np.where(sea[..., None], sea_col * (0.8 + waves[..., None]) + refl[..., None] * hex_rgb(cfg["sun"]) * 0.5, img)
    if cfg.get("fireflies"):
        dots = rng.random((H, W)) > 0.9993
        band = (v > HORIZON - 0.12) & (v < HORIZON + 0.1)
        img += (dots & band)[..., None] * hex_rgb(cfg["fireflies"]) * 1.5

    # Soft vignette so the backdrop never competes with the fighters.
    img *= 0.92
    img = np.clip(img, 0, 1) ** (1 / 1.05)
    return Image.fromarray((img * 255).astype(np.uint8), "RGB")


ARENAS = {
    "blood_moon": dict(zenith="0b0612", mid="3a0f22", horizon="a13a3a", ground="1a0b10", haze="7a2a34", rock="160912",
                       sun="ffd9c4", sun_u=0.5, sun_elev=0.22, sun_r=58, sun_glow=0.55, moon_detail=True,
                       stars=True, nebula="7a1f4a", rim="ff6d5b"),
    "volcano_sanctum": dict(zenith="120604", mid="4a1506", horizon="c2410c", ground="1c0805", haze="6b2410", rock="140604",
                            sun="ffb45a", sun_u=0.5, sun_elev=0.10, sun_r=40, sun_glow=0.8, nebula="7c2d12",
                            lava="ff5a1f", rim="ff8a3d", mountain_scale=1.5),
    "imperial_colosseum": dict(zenith="1e4f8f", mid="5b8fc9", horizon="f4c98a", ground="7a5a3c", haze="b9a58e", rock="5a4a3c",
                               sun="fff4d6", sun_u=0.5, sun_elev=0.30, sun_r=34, sun_glow=0.9, clouds="fff3e6"),
    "pirate_galleon": dict(zenith="0f2a4a", mid="3b6f9a", horizon="f0a868", ground="0d2436", haze="5f7f99", rock="1c2f40",
                           sun="ffd08a", sun_u=0.5, sun_elev=0.07, sun_r=46, sun_glow=1.0, clouds="ffd9b0",
                           sea="12405e", mountain_scale=0.5),
    "gladiator_fortress": dict(zenith="2b2d42", mid="6d597a", horizon="e0a36b", ground="3a2e25", haze="8d7466", rock="2a2320",
                               sun="ffe2b8", sun_u=0.5, sun_elev=0.18, sun_r=38, sun_glow=0.75, clouds="f2c7a5",
                               mountain_scale=1.2),
    "mystic_grove": dict(zenith="04121a", mid="0b3a3f", horizon="2dd4bf", ground="041a17", haze="0f766e", rock="031512",
                         sun="c7fff4", sun_u=0.5, sun_elev=0.24, sun_r=44, sun_glow=0.6, moon_detail=True,
                         stars=True, nebula="0e7490", fireflies="a7f3d0", rim="5eead4"),
    "frozen_summit": dict(zenith="020617", mid="0f2a4a", horizon="7dd3fc", ground="dbeafe", haze="94a3b8", rock="1e293b",
                          sun="e0f2fe", sun_u=0.5, sun_elev=0.28, sun_r=30, sun_glow=0.45, moon_detail=True,
                          stars=True, aurora=True, rim="e0f2fe", mountain_scale=1.8),
    "neon_metropolis": dict(zenith="05010f", mid="2a0b4a", horizon="ff3d9a", ground="0b0418", haze="5b21b6", rock="0a0714",
                            sun="ff9bd2", sun_u=0.5, sun_elev=0.16, sun_r=52, sun_glow=0.7, nebula="7c3aed", city=True),
}

if __name__ == "__main__":
    for i, (name, cfg) in enumerate(ARENAS.items()):
        path = os.path.join(OUT, "sky2_%s.png" % name)
        build(cfg, 1000 + i).save(path, optimize=True)
        print("wrote", os.path.normpath(path))
