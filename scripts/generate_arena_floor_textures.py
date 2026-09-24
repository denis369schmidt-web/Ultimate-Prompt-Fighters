"""Generate high-resolution seamless arena floor textures from reference artwork."""

from pathlib import Path
import numpy as np
from PIL import Image, ImageEnhance, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
ARENA_TEX_DIR = ROOT / "godot" / "assets" / "textures" / "arenas"
ARENA_TEX_DIR.mkdir(parents=True, exist_ok=True)

REF_IMG = ROOT / "art" / "references" / "broken_moonkeep_arena.png"


def make_seamless(img_np: np.ndarray, overlap: float = 0.22) -> np.ndarray:
    """Seamless crossfade on both axes."""
    h, w = img_np.shape[:2]
    ox = int(w * overlap)
    oy = int(h * overlap)
    out = img_np.copy()

    # Horizontal blend
    tx = 0.5 - 0.5 * np.cos(np.pi * np.arange(ox) / ox)
    if img_np.ndim == 3:
        tx = tx.reshape((1, ox, 1))
    out[:, :ox] = img_np[:, :ox] * tx + img_np[:, w - ox:] * (1.0 - tx)
    out[:, w - ox:] = out[:, :ox]

    # Vertical blend
    ty = 0.5 - 0.5 * np.cos(np.pi * np.arange(oy) / oy)
    if img_np.ndim == 3:
        ty = ty.reshape((oy, 1, 1))
    out[:oy, :] = img_np[:oy, :] * ty + img_np[h - oy:, :] * (1.0 - ty)
    out[h - oy:, :] = out[:oy, :]

    return np.clip(out, 0, 255).astype(np.uint8)


def calc_normal(gray_np: np.ndarray, strength: float = 2.8) -> np.ndarray:
    """Generate tangent-space normal map."""
    h, w = gray_np.shape
    g = gray_np.astype(np.float32) / 255.0
    pad = np.pad(g, ((1, 1), (1, 1)), mode='wrap')

    # Scharr filter
    dx = (
        3.0 * (pad[0:h, 2:w+2] - pad[0:h, 0:w]) +
        10.0 * (pad[1:h+1, 2:w+2] - pad[1:h+1, 0:w]) +
        3.0 * (pad[2:h+2, 2:w+2] - pad[2:h+2, 0:w])
    ) / 32.0 * strength

    dy = (
        3.0 * (pad[2:h+2, 0:w] - pad[0:h, 0:w]) +
        10.0 * (pad[2:h+2, 1:w+1] - pad[0:h, 1:w+1]) +
        3.0 * (pad[2:h+2, 2:w+2] - pad[0:h, 2:w+2])
    ) / 32.0 * strength

    dz = np.ones((h, w), dtype=np.float32)
    norm = np.sqrt(dx * dx + dy * dy + dz * dz)
    nx = (dx / norm * 0.5 + 0.5) * 255.0
    ny = (dy / norm * 0.5 + 0.5) * 255.0
    nz = (dz / norm * 0.5 + 0.5) * 255.0

    return np.dstack([nx, ny, nz]).clip(0, 255).astype(np.uint8)


def build_stone_floor():
    print("Extracting pure horizontal stone pavement slabs from reference...")
    ref = Image.open(REF_IMG).convert("RGB")
    
    # Pure horizontal paving slab region: y: 648 to 748, x: 320 to 1600
    strip1 = ref.crop((320, 650, 1600, 750))
    # Stack two slightly offset strips to form a 1024x1024 slab grid
    w, h = strip1.size
    half1 = strip1.resize((1024, 512), Image.Resampling.LANCZOS)
    
    strip2 = ref.crop((240, 650, 1520, 750))
    half2 = strip2.resize((1024, 512), Image.Resampling.LANCZOS)
    
    combined = Image.new("RGB", (1024, 1024))
    combined.paste(half1, (0, 0))
    combined.paste(half2, (0, 512))

    # Neutral color balancing for versatile arena lighting
    enhancer = ImageEnhance.Color(combined)
    balanced = enhancer.enhance(0.40) # Muted slate stone
    enhancer = ImageEnhance.Brightness(balanced)
    balanced = enhancer.enhance(0.85)
    enhancer = ImageEnhance.Contrast(balanced)
    balanced = enhancer.enhance(1.25)
    enhancer = ImageEnhance.Sharpness(balanced)
    balanced = enhancer.enhance(1.4)

    arr = np.array(balanced)
    seamless_arr = make_seamless(arr, overlap=0.20)
    stone_albedo = Image.fromarray(seamless_arr)
    stone_albedo.save(ARENA_TEX_DIR / "floor_stone_albedo.png")
    print("Saved floor_stone_albedo.png")

    # Normal map
    gray = np.array(stone_albedo.convert("L"))
    norm_arr = calc_normal(gray, strength=3.0)
    Image.fromarray(norm_arr).save(ARENA_TEX_DIR / "floor_stone_normal.png")
    print("Saved floor_stone_normal.png")


def build_lava_floor():
    print("Generating cracked volcanic magma floor...")
    # Base dark basalt rock from stone floor
    stone = Image.open(ARENA_TEX_DIR / "floor_stone_albedo.png").convert("RGB")
    enhancer = ImageEnhance.Color(stone)
    dark_rock = enhancer.enhance(0.0) # Complete monochrome basalt
    enhancer = ImageEnhance.Brightness(dark_rock)
    dark_rock = enhancer.enhance(0.28) # Deep black volcanic basalt
    enhancer = ImageEnhance.Contrast(dark_rock)
    dark_rock = enhancer.enhance(1.4)

    rock_arr = np.array(dark_rock, dtype=np.float32)
    h, w, _ = rock_arr.shape

    # Tectonic fissure network matching slab edges
    gray_rock = np.array(dark_rock.convert("L"), dtype=np.float32) / 255.0
    edges = np.clip(1.0 - np.abs(gray_rock - 0.25) * 6.0, 0.0, 1.0)
    edges = np.power(edges, 2.5)

    # Fiery magma color palette
    lava_r = np.clip(edges * 2.2, 0.0, 1.0) * 255.0
    lava_g = np.clip(edges * 1.1 - 0.15, 0.0, 1.0) * 255.0
    lava_b = np.clip(edges * 0.4 - 0.25, 0.0, 1.0) * 200.0
    lava_col = np.dstack([lava_r, lava_g, lava_b])

    # Blend rock with lava
    mask = edges[:, :, np.newaxis]
    albedo = rock_arr * (1.0 - mask * 0.9) + lava_col * mask
    albedo = np.clip(albedo, 0, 255).astype(np.uint8)

    lava_albedo = Image.fromarray(make_seamless(albedo, overlap=0.20))
    lava_albedo.save(ARENA_TEX_DIR / "floor_lava_albedo.png")
    print("Saved floor_lava_albedo.png")

    # Emission texture (pure glowing cracks)
    em_r = np.clip(edges * 2.5, 0.0, 1.0) * 255.0
    em_g = np.clip(edges * 1.3 - 0.1, 0.0, 1.0) * 255.0
    em_b = np.clip(edges * 0.5 - 0.2, 0.0, 1.0) * 220.0
    emission = np.dstack([em_r, em_g, em_b]) * mask
    lava_em = Image.fromarray(make_seamless(np.clip(emission, 0, 255).astype(np.uint8), overlap=0.20))
    lava_em.save(ARENA_TEX_DIR / "floor_lava_emission.png")
    print("Saved floor_lava_emission.png")

    # Normal map
    gray = np.array(lava_albedo.convert("L"))
    norm_arr = calc_normal(gray, strength=3.2)
    Image.fromarray(norm_arr).save(ARENA_TEX_DIR / "floor_lava_normal.png")
    print("Saved floor_lava_normal.png")


if __name__ == "__main__":
    build_stone_floor()
    build_lava_floor()
    print("REFINED_ARENA_FLOOR_TEXTURES_READY")
