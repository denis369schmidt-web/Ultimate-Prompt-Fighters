"""Generates tileable PBR texture sets for the arenas.

For every material: <name>_albedo.png, <name>_normal.png (OpenGL / Y+), <name>_rough.png,
and for glowing materials <name>_emission.png. All maps tile seamlessly.
Output: godot/assets/textures/arenas/pbr/

Usage: python scripts/generate_arena_textures.py [name ...]
"""
import os
import sys

import numpy as np
from PIL import Image

S = 1024
OUT = os.path.join(os.path.dirname(__file__), "..", "godot", "assets", "textures", "arenas", "pbr")


def hexc(h):
    h = h.lstrip("#")
    return np.array([int(h[i:i + 2], 16) / 255.0 for i in (0, 2, 4)], np.float32)


def noise(rng, cells, octaves=5, size=S):
    """Fractal value noise, tileable in x and y."""
    out = np.zeros((size, size), np.float32)
    amp, total = 1.0, 0.0
    for o in range(octaves):
        c = cells * 2 ** o
        grid = rng.random((c, c)).astype(np.float32)
        t = np.linspace(0, c, size, endpoint=False)
        i0 = np.floor(t).astype(int) % c
        i1 = (i0 + 1) % c
        f = t - np.floor(t)
        f = f * f * (3 - 2 * f)
        a = grid[i0][:, i0]
        b = grid[i0][:, i1]
        cc = grid[i1][:, i0]
        d = grid[i1][:, i1]
        top = a + (b - a) * f[None, :]
        bot = cc + (d - cc) * f[None, :]
        out += amp * (top + (bot - top) * f[:, None])
        total += amp
        amp *= 0.5
    return out / total


def voronoi(rng, cells, size=S):
    """Tileable Voronoi: returns F1, F2 distances (in cell units) and cell id."""
    pts = rng.random((cells, cells, 2)).astype(np.float32)
    ys, xs = np.mgrid[0:size, 0:size].astype(np.float32) * (cells / size)
    cx = np.floor(xs).astype(int)
    cy = np.floor(ys).astype(int)
    f1 = np.full((size, size), 9.0, np.float32)
    f2 = np.full((size, size), 9.0, np.float32)
    cid = np.zeros((size, size), np.int32)
    for dy in (-1, 0, 1):
        for dx in (-1, 0, 1):
            nx = cx + dx
            ny = cy + dy
            p = pts[ny % cells, nx % cells]
            px = nx + p[..., 0]
            py = ny + p[..., 1]
            d = np.sqrt((xs - px) ** 2 + (ys - py) ** 2)
            ids = (ny % cells) * cells + (nx % cells)
            closer = d < f1
            f2 = np.where(closer, f1, np.minimum(f2, d))
            cid = np.where(closer, ids, cid)
            f1 = np.where(closer, d, f1)
    return f1, f2, cid


def tiles(rng, nx, ny, stagger=0.5, mortar=0.035, size=S, random_len=False):
    """Brick/tile layout: returns edge distance (0 at mortar) and per-tile random value."""
    ys, xs = np.mgrid[0:size, 0:size].astype(np.float32) / size
    row = np.floor(ys * ny).astype(int)
    shift = (row % 2) * stagger if not random_len else rng.random(ny)[row % ny]
    u = xs * nx + shift
    col = np.floor(u).astype(int)
    fu = u - np.floor(u)
    fv = ys * ny - row
    edge = np.minimum(np.minimum(fu, 1 - fu) / nx * size, np.minimum(fv, 1 - fv) / ny * size) / size
    rnd = rng.random((ny, nx + 2)).astype(np.float32)
    tile_rand = rnd[row % ny, col % (nx + 2)]
    return edge, tile_rand, mortar


def normal_from_height(h, strength):
    dx = (np.roll(h, -1, 1) - np.roll(h, 1, 1)) * strength
    dy = (np.roll(h, -1, 0) - np.roll(h, 1, 0)) * strength
    n = np.dstack([-dx, dy, np.ones_like(h)])
    n /= np.linalg.norm(n, axis=2, keepdims=True)
    return n * 0.5 + 0.5


def save(name, kind, arr):
    arr = np.clip(arr, 0, 1)
    mode = "L" if arr.ndim == 2 else "RGB"
    img = Image.fromarray((arr * 255).astype(np.uint8), mode)
    if kind == "rough": img = img.resize((512, 512), Image.LANCZOS)
    img.save(os.path.join(OUT, "%s_%s.png" % (name, kind)), optimize=True)


def finish(name, albedo, height, rough, nstrength=6.0, emission=None):
    save(name, "albedo", albedo)
    save(name, "normal", normal_from_height(height, nstrength))
    save(name, "rough", rough)
    if emission is not None: save(name, "emission", emission)
    print("wrote", name)


def mix(a, b, t):
    return a + (b - a) * t[..., None]


def stone_tiles(rng):
    edge, tr, m = tiles(rng, 4, 4, 0.5, 0.02)
    grit = noise(rng, 16, 6)
    big = noise(rng, 4, 4)
    bevel = np.clip(edge / 0.02, 0, 1) ** 0.5
    base = mix(hexc("3d3434"), hexc("6b5b58"), tr * 0.7 + big * 0.3)
    col = base * (0.8 + grit[..., None] * 0.35)
    col = mix(hexc("140d0d"), col, bevel)
    cracks = np.clip(1 - np.abs(noise(rng, 10, 4) - 0.5) * 40, 0, 1) * (tr > 0.6)
    col = col * (1 - cracks[..., None] * 0.5)
    h = bevel * 0.8 + grit * 0.25 - cracks * 0.2
    finish("stone_tiles", col, h, 0.72 + grit * 0.2 - bevel * 0.05, 7.0)


def basalt(rng):
    f1, f2, cid = voronoi(rng, 7)
    crack = np.clip(1 - (f2 - f1) * 9, 0, 1)
    grit = noise(rng, 20, 6)
    tone = (cid * 0.6180339 % 1.0).astype(np.float32)
    col = mix(hexc("141112"), hexc("2c2524"), tone * 0.6 + grit * 0.4)
    col = col * (1 - crack[..., None] * 0.8)
    glow = np.clip(crack * 1.6 - 0.35, 0, 1) ** 1.5 * (0.6 + noise(rng, 8, 3) * 0.6)
    col = col + glow[..., None] * hexc("ff4a10") * 0.6
    em = glow[..., None] * hexc("ff6a1a")
    h = (1 - crack) * 0.9 + grit * 0.3
    finish("basalt", col, h, 0.85 - glow * 0.4, 9.0, em)


def marble(rng):
    edge, tr, m = tiles(rng, 2, 2, 0.0, 0.004)
    ys, xs = np.mgrid[0:S, 0:S].astype(np.float32) / S
    turb = noise(rng, 4, 6)
    veins = np.abs(np.sin((xs * 2 + ys * 3 + turb * 3.5) * np.pi * 2))
    veins = np.clip(1 - veins * 5, 0, 1) ** 2
    fine = np.abs(np.sin((xs * 5 - ys * 2 + noise(rng, 6, 5) * 4) * np.pi * 2))
    fine = np.clip(1 - fine * 12, 0, 1) * 0.5
    col = mix(hexc("e9e4dc"), hexc("f8f5ef"), noise(rng, 8, 4))
    col = mix(col, hexc("8f8a86"), np.clip(veins + fine, 0, 1) * 0.8)
    seam = np.clip(edge / 0.004, 0, 1)
    col = col * (0.75 + 0.25 * seam[..., None])
    finish("marble", col, seam * 0.4 + turb * 0.05, 0.18 + (1 - seam) * 0.4, 2.5)


def wood(rng):
    edge, tr, m = tiles(rng, 3, 10, 0.0, 0.01, random_len=True)
    ys, xs = np.mgrid[0:S, 0:S].astype(np.float32) / S
    grain_n = noise(rng, 6, 5)
    grain = np.sin((ys * 10 * 12 + grain_n * 6 + tr * 20) * np.pi) * 0.5 + 0.5
    col = mix(hexc("3b2616"), hexc("7a5230"), tr * 0.6 + grain * 0.4)
    weather = noise(rng, 5, 5)
    col = mix(col, hexc("6b6660"), np.clip(weather - 0.55, 0, 1) * 1.5)
    bevel = np.clip(edge / 0.01, 0, 1) ** 0.6
    col = col * (0.25 + 0.75 * bevel[..., None])
    nails = np.zeros((S, S), np.float32)
    for r in range(10):
        for x in (0.02, 0.35, 0.68):
            cy, cx = int((r + 0.5) / 10 * S), int((x + rng.random() * 0.02) * S)
            yy, xx = np.ogrid[-cy:S - cy, -cx:S - cx]
            nails = np.maximum(nails, np.clip(1 - np.sqrt(xx * xx + yy * yy) / 5, 0, 1))
    col = mix(col, hexc("22201e"), nails)
    finish("wood_planks", col, bevel * 0.7 + grain * 0.15 + nails * 0.3, 0.72 + grain * 0.1, 5.0)


def sandstone(rng):
    edge, tr, m = tiles(rng, 6, 12, 0.5, 0.012)
    grit = noise(rng, 24, 6)
    pits = np.clip((noise(rng, 30, 3) - 0.62) * 6, 0, 1)
    col = mix(hexc("b08a5a"), hexc("d9b884"), tr * 0.6 + grit * 0.4)
    col = col * (1 - pits[..., None] * 0.25)
    bevel = np.clip(edge / 0.012, 0, 1) ** 0.5
    col = mix(hexc("5a4630"), col, bevel)
    finish("sandstone", col, bevel * 0.7 + grit * 0.3 - pits * 0.2, 0.9 - grit * 0.05, 6.0)


def mossy(rng):
    f1, f2, cid = voronoi(rng, 6)
    edge = np.clip((f2 - f1) * 6, 0, 1) ** 0.5
    grit = noise(rng, 18, 6)
    tone = (cid * 0.618 % 1.0).astype(np.float32)
    col = mix(hexc("4a4f48"), hexc("737a70"), tone * 0.5 + grit * 0.5)
    moss = np.clip((noise(rng, 5, 5) + (1 - edge) * 0.35 - 0.55) * 3.5, 0, 1)
    mcol = mix(hexc("27451f"), hexc("4f7a2c"), noise(rng, 30, 3))
    col = mix(col * (0.4 + 0.6 * edge[..., None]), mcol, moss)
    finish("mossy_stone", col, edge * 0.8 + grit * 0.2 + moss * 0.15, 0.85 - moss * 0.1, 7.0)


def ice(rng):
    f1, f2, cid = voronoi(rng, 5)
    crack = np.clip(1 - (f2 - f1) * 14, 0, 1)
    depth = noise(rng, 6, 5)
    col = mix(hexc("7fb8d8"), hexc("e8f6ff"), depth * 0.7 + 0.2)
    col = mix(col, hexc("ffffff"), crack * 0.7)
    frost = np.clip((noise(rng, 20, 4) - 0.5) * 3, 0, 1)
    col = mix(col, hexc("f4fbff"), frost * 0.5)
    finish("ice", col, depth * 0.3 - crack * 0.3 + frost * 0.2, 0.08 + frost * 0.5, 3.0)


def metal(rng):
    edge, tr, m = tiles(rng, 4, 4, 0.0, 0.006)
    ys, xs = np.mgrid[0:S, 0:S].astype(np.float32) / S
    col = mix(hexc("1c2129"), hexc("2d3440"), tr * 0.6 + noise(rng, 12, 4) * 0.4)
    seam = np.clip(edge / 0.006, 0, 1)
    rivets = np.zeros((S, S), np.float32)
    for gy in range(4):
        for gx in range(4):
            for (ox, oy) in ((0.03, 0.03), (0.97, 0.03), (0.03, 0.97), (0.97, 0.97)):
                cy, cx = int((gy + oy) / 4 * S), int((gx + ox) / 4 * S)
                yy, xx = np.ogrid[-cy:S - cy, -cx:S - cx]
                rivets = np.maximum(rivets, np.clip(1 - np.sqrt(xx * xx + yy * yy) / 7, 0, 1))
    scratches = np.zeros((S, S), np.float32)
    for k in range(160):
        x0, y0 = rng.random() * S, rng.random() * S
        ang = rng.random() * np.pi
        ln = rng.random() * 90 + 20
        for t in np.linspace(0, ln, int(ln)):
            px, py = int(x0 + np.cos(ang) * t) % S, int(y0 + np.sin(ang) * t) % S
            scratches[py, px] = 1.0
    col = col * (0.45 + 0.55 * seam[..., None]) + scratches[..., None] * 0.18 + rivets[..., None] * 0.25
    wet = np.clip((noise(rng, 4, 4) - 0.5) * 4, 0, 1)
    rough = 0.55 - wet * 0.45 - scratches * 0.1
    finish("metal_panels", col, seam * 0.5 + rivets * 0.6 - scratches * 0.1, rough, 5.0)


MATERIALS = {"stone_tiles": stone_tiles, "basalt": basalt, "marble": marble, "wood_planks": wood,
             "sandstone": sandstone, "mossy_stone": mossy, "ice": ice, "metal_panels": metal}

if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    names = sys.argv[1:] or list(MATERIALS)
    for i, n in enumerate(names):
        MATERIALS[n](np.random.default_rng(300 + list(MATERIALS).index(n)))
