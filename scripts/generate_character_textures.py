"""
High-performance, reference-accurate character skin generator.
Uses NumPy for instant vectorized processing and clean fissure isolation.
"""

from __future__ import annotations

import math
from pathlib import Path
import numpy as np
from PIL import Image, ImageEnhance, ImageFilter, ImageOps

SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent
REF_DIR = PROJECT_ROOT.parent
GODOT_DIR = PROJECT_ROOT / "godot"
SKIN_DIR = GODOT_DIR / "assets" / "textures" / "skins"
CHAR_DIR = GODOT_DIR / "assets" / "textures" / "characters"

SKIN_DIR.mkdir(parents=True, exist_ok=True)
CHAR_DIR.mkdir(parents=True, exist_ok=True)


def numpy_seamless(img_np: np.ndarray, overlap_ratio: float = 0.25) -> np.ndarray:
    """Vectorized seamless crossfade for 2D/3D images."""
    h, w = img_np.shape[:2]
    ox = int(w * overlap_ratio)
    oy = int(h * overlap_ratio)
    out = img_np.copy()

    # Horizontal
    t_x = 0.5 - 0.5 * np.cos(np.pi * np.arange(ox) / ox)
    t_x = t_x.reshape((1, ox, 1)) if img_np.ndim == 3 else t_x.reshape((1, ox))
    out[:, :ox] = img_np[:, :ox] * t_x + img_np[:, w - ox:] * (1.0 - t_x)
    out[:, w - ox:] = out[:, :ox]

    # Vertical
    t_y = 0.5 - 0.5 * np.cos(np.pi * np.arange(oy) / oy)
    t_y = t_y.reshape((oy, 1, 1)) if img_np.ndim == 3 else t_y.reshape((oy, 1))
    out[:oy, :] = out[:oy, :] * t_y + out[h - oy:, :] * (1.0 - t_y)
    out[h - oy:, :] = out[:oy, :]

    return np.clip(out, 0, 255).astype(np.uint8)


def numpy_normal_map(gray_np: np.ndarray, strength: float = 3.5) -> np.ndarray:
    """Vectorized Scharr normal map generation."""
    h, w = gray_np.shape
    g = gray_np.astype(np.float32) / 255.0

    # Padded for boundary conditions
    pad = np.pad(g, ((1, 1), (1, 1)), mode='wrap')

    # Scharr kernel horizontal & vertical gradients
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

    dz = np.ones_like(dx)
    inv_len = 1.0 / np.sqrt(dx * dx + dy * dy + dz * dz)
    nx = -dx * inv_len
    ny = -dy * inv_len
    nz = dz * inv_len

    r = ((nx * 0.5 + 0.5) * 255.0).astype(np.uint8)
    g_ch = ((ny * 0.5 + 0.5) * 255.0).astype(np.uint8)
    b = ((nz * 0.5 + 0.5) * 255.0).astype(np.uint8)
    return np.stack([r, g_ch, b], axis=-1)


def save_dual_img(img: Image.Image, skin_name: str, char_name: str | None = None):
    img.save(SKIN_DIR / skin_name)
    if char_name:
        img.save(CHAR_DIR / char_name)


def generate_all():
    print("=== Generating Vectorized Reference Character Textures ===")

    # -------------------------------------------------------------------------
    # 1. GOLEM: VOLCANIC BASALT & MOLTEN CRACKS (bonkers_image_full-body_3d_character.png)
    # -------------------------------------------------------------------------
    g_ref = Image.open(REF_DIR / "bonkers_image_full-body_3d_character.png").convert("RGB")
    gw, gh = g_ref.size

    # Basalt rock crop
    r_crop = g_ref.crop((int(gw * 0.22), int(gh * 0.28), int(gw * 0.58), int(gh * 0.62))).resize((1024, 1024), Image.Resampling.LANCZOS)
    r_np = numpy_seamless(np.array(r_crop))
    rock_albedo = Image.fromarray(r_np)
    rock_albedo = ImageEnhance.Contrast(rock_albedo).enhance(1.25)
    save_dual_img(rock_albedo, "golem_lava_rock_albedo.png", "golem_rock_albedo.png")

    r_gray = np.array(rock_albedo.convert("L"))
    rock_norm = Image.fromarray(numpy_normal_map(r_gray, strength=4.0))
    save_dual_img(rock_norm, "golem_lava_rock_normal.png", "golem_rock_normal.png")

    r_rough = Image.fromarray(np.clip(255 - r_gray * 0.5, 80, 230).astype(np.uint8))
    save_dual_img(r_rough, "golem_lava_rock_roughness.png", "golem_rock_roughness.png")

    # Lava core & fissures: Clean crack isolation!
    c_crop = g_ref.crop((int(gw * 0.28), int(gh * 0.22), int(gw * 0.72), int(gh * 0.55))).resize((1024, 1024), Image.Resampling.LANCZOS)
    c_np = numpy_seamless(np.array(c_crop))
    lava_core = Image.fromarray(c_np)
    lava_core = ImageEnhance.Color(lava_core).enhance(2.0)
    save_dual_img(lava_core, "golem_lava_core_albedo.png", "golem_lava_albedo.png")

    # Emission: Fissure mask
    c_flt = c_np.astype(np.float32)
    cr, cg, cb = c_flt[:, :, 0], c_flt[:, :, 1], c_flt[:, :, 2]
    fissure = (cr > 130) & (cr > cb * 1.35) & ((cr + cg) > 210)

    em_np = np.zeros_like(c_np)
    em_np[fissure, 0] = np.clip(cr[fissure] * 1.4, 0, 255).astype(np.uint8)
    em_np[fissure, 1] = np.clip(cg[fissure] * 1.2, 0, 255).astype(np.uint8)
    em_np[fissure, 2] = np.clip(cb[fissure] * 0.3, 0, 255).astype(np.uint8)
    lava_em = Image.fromarray(em_np).filter(ImageFilter.GaussianBlur(1.0))
    save_dual_img(lava_em, "golem_lava_core_emission.png", "golem_lava_emission.png")
    print("  [OK] Lava Golem Basalt & Core textures created.")

    # -------------------------------------------------------------------------
    # 2. GOLEM: GLACIAL FROST TITAN (bonkers_image_full-body_3d_character (1).png)
    # -------------------------------------------------------------------------
    f_ref = Image.open(REF_DIR / "bonkers_image_full-body_3d_character (1).png").convert("RGB")
    fw, fh = f_ref.size

    f_crop = f_ref.crop((int(fw * 0.25), int(fh * 0.22), int(fw * 0.65), int(fh * 0.58))).resize((1024, 1024), Image.Resampling.LANCZOS)
    f_np = numpy_seamless(np.array(f_crop))
    frost_rock = Image.fromarray(f_np)
    frost_rock = ImageEnhance.Color(frost_rock).enhance(1.4)
    save_dual_img(frost_rock, "golem_frost_rock_albedo.png")

    f_gray = np.array(frost_rock.convert("L"))
    frost_norm = Image.fromarray(numpy_normal_map(f_gray, strength=3.6))
    save_dual_img(frost_norm, "golem_frost_rock_normal.png")

    # Frost Core
    fc_crop = f_ref.crop((int(fw * 0.32), int(fh * 0.22), int(fw * 0.68), int(fh * 0.52))).resize((1024, 1024), Image.Resampling.LANCZOS)
    fc_np = numpy_seamless(np.array(fc_crop))
    frost_core = Image.fromarray(fc_np)
    frost_core = ImageEnhance.Color(frost_core).enhance(2.0)
    save_dual_img(frost_core, "golem_frost_core_albedo.png")

    fc_flt = fc_np.astype(np.float32)
    fcr, fcg, fcb = fc_flt[:, :, 0], fc_flt[:, :, 1], fc_flt[:, :, 2]
    ice_fissure = (fcb > 115) & (fcb > fcr * 1.1) & ((fcb + fcg) > 220)

    fem_np = np.zeros_like(fc_np)
    fem_np[ice_fissure, 0] = np.clip(fcr[ice_fissure] * 0.5, 0, 255).astype(np.uint8)
    fem_np[ice_fissure, 1] = np.clip(fcg[ice_fissure] * 1.3, 0, 255).astype(np.uint8)
    fem_np[ice_fissure, 2] = np.clip(fcb[ice_fissure] * 1.5, 0, 255).astype(np.uint8)
    frost_em = Image.fromarray(fem_np).filter(ImageFilter.GaussianBlur(1.0))
    save_dual_img(frost_em, "golem_frost_core_emission.png")
    print("  [OK] Frost Titan textures created.")

    # -------------------------------------------------------------------------
    # 3. GOLEM: TOXIC SPORE HORROR (bonkers_image_full-body_3d_character (3).png)
    # -------------------------------------------------------------------------
    t_ref = Image.open(REF_DIR / "bonkers_image_full-body_3d_character (3).png").convert("RGB")
    tw, th = t_ref.size

    t_crop = t_ref.crop((int(tw * 0.28), int(th * 0.25), int(tw * 0.65), int(th * 0.6))).resize((1024, 1024), Image.Resampling.LANCZOS)
    t_np = numpy_seamless(np.array(t_crop))
    toxic_rock = Image.fromarray(t_np)
    save_dual_img(toxic_rock, "golem_toxic_rock_albedo.png")

    t_gray = np.array(toxic_rock.convert("L"))
    toxic_norm = Image.fromarray(numpy_normal_map(t_gray, strength=3.2))
    save_dual_img(toxic_norm, "golem_toxic_rock_normal.png")

    tc_crop = t_ref.crop((int(tw * 0.3), int(th * 0.65), int(tw * 0.7), int(th * 0.95))).resize((1024, 1024), Image.Resampling.LANCZOS)
    tc_np = numpy_seamless(np.array(tc_crop))
    toxic_core = Image.fromarray(tc_np)
    toxic_core = ImageEnhance.Color(toxic_core).enhance(2.2)
    save_dual_img(toxic_core, "golem_toxic_core_albedo.png")

    tc_flt = tc_np.astype(np.float32)
    tcr, tcg, tcb = tc_flt[:, :, 0], tc_flt[:, :, 1], tc_flt[:, :, 2]
    slime_fissure = (tcg > 115) & (tcg > tcb * 1.15) & (tcg > tcr * 1.1)

    tem_np = np.zeros_like(tc_np)
    tem_np[slime_fissure, 0] = np.clip(tcr[slime_fissure] * 0.6, 0, 255).astype(np.uint8)
    tem_np[slime_fissure, 1] = np.clip(tcg[slime_fissure] * 1.5, 0, 255).astype(np.uint8)
    tem_np[slime_fissure, 2] = np.clip(tcb[slime_fissure] * 0.2, 0, 255).astype(np.uint8)
    toxic_em = Image.fromarray(tem_np).filter(ImageFilter.GaussianBlur(1.0))
    save_dual_img(toxic_em, "golem_toxic_core_emission.png")
    print("  [OK] Toxic Spore textures created.")

    # -------------------------------------------------------------------------
    # 4. GOLEM: STORM THUNDER TITAN (bonkers_image_full-body_3d_character (4).png)
    # -------------------------------------------------------------------------
    s_ref = Image.open(REF_DIR / "bonkers_image_full-body_3d_character (4).png").convert("RGB")
    sw, sh = s_ref.size

    s_crop = s_ref.crop((int(sw * 0.28), int(sh * 0.25), int(sw * 0.72), int(sh * 0.65))).resize((1024, 1024), Image.Resampling.LANCZOS)
    s_np = numpy_seamless(np.array(s_crop))
    storm_rock = Image.fromarray(s_np)
    save_dual_img(storm_rock, "golem_storm_rock_albedo.png")

    s_gray = np.array(storm_rock.convert("L"))
    storm_norm = Image.fromarray(numpy_normal_map(s_gray, strength=3.4))
    save_dual_img(storm_norm, "golem_storm_rock_normal.png")

    sc_crop = s_ref.crop((int(sw * 0.22), int(sh * 0.25), int(sw * 0.78), int(sh * 0.58))).resize((1024, 1024), Image.Resampling.LANCZOS)
    sc_np = numpy_seamless(np.array(sc_crop))
    storm_core = Image.fromarray(sc_np)
    storm_core = ImageEnhance.Color(storm_core).enhance(2.0)
    save_dual_img(storm_core, "golem_storm_core_albedo.png")

    sc_flt = sc_np.astype(np.float32)
    scr, scg, scb = sc_flt[:, :, 0], sc_flt[:, :, 1], sc_flt[:, :, 2]
    lightning = (scr > 175) & (scg > 155) & (scb > 110)

    sem_np = np.zeros_like(sc_np)
    sem_np[lightning, 0] = np.clip(scr[lightning] * 1.3, 0, 255).astype(np.uint8)
    sem_np[lightning, 1] = np.clip(scg[lightning] * 1.25, 0, 255).astype(np.uint8)
    sem_np[lightning, 2] = np.clip(scb[lightning] * 0.8, 0, 255).astype(np.uint8)
    storm_em = Image.fromarray(sem_np).filter(ImageFilter.GaussianBlur(1.0))
    save_dual_img(storm_em, "golem_storm_core_emission.png")
    print("  [OK] Storm Thunder Titan textures created.")

    # -------------------------------------------------------------------------
    # 5. NINJA: SHADOW & VOLT ASSASSIN (bonkers_image_create_a_full-body (1).png)
    # -------------------------------------------------------------------------
    n_ref = Image.open(REF_DIR / "bonkers_image_create_a_full-body (1).png").convert("RGB")
    nw, nh = n_ref.size

    # Clean Kevlar / Carbon fiber texture synthesis
    # Micro-grid pattern
    grid = np.zeros((1024, 1024), dtype=np.float32)
    for y in range(1024):
        for x in range(1024):
            val = ((x % 8 < 4) ^ (y % 8 < 4)) * 25.0
            grid[y, x] = val

    # Tactical armor base from reference colors
    armor_base = np.zeros((1024, 1024, 3), dtype=np.float32)
    armor_base[:, :] = [32.0, 36.0, 44.0] # Gunmetal Kevlar
    armor_base += grid[:, :, np.newaxis]
    ninja_armor_np = np.clip(armor_base, 0, 255).astype(np.uint8)
    ninja_armor = Image.fromarray(ninja_armor_np)
    save_dual_img(ninja_armor, "ninja_shadow_armor_albedo.png", "ninja_armor_albedo.png")

    na_gray = np.array(ninja_armor.convert("L"))
    ninja_armor_norm = Image.fromarray(numpy_normal_map(na_gray, strength=2.8))
    save_dual_img(ninja_armor_norm, "ninja_shadow_armor_normal.png", "ninja_armor_normal.png")

    # Tactical cloth
    cloth_base = np.zeros((1024, 1024, 3), dtype=np.float32)
    cloth_base[:, :] = [22.0, 24.0, 30.0]
    cloth_grid = np.zeros((1024, 1024), dtype=np.float32)
    for y in range(1024):
        for x in range(1024):
            cloth_grid[y, x] = ((x % 4 < 2) ^ (y % 4 < 2)) * 18.0
    cloth_base += cloth_grid[:, :, np.newaxis]
    ninja_cloth = Image.fromarray(np.clip(cloth_base, 0, 255).astype(np.uint8))
    save_dual_img(ninja_cloth, "ninja_shadow_cloth_albedo.png", "ninja_cloth_albedo.png")

    # Cyan Lightning Blade (from reference dual blades)
    blade_crop = n_ref.crop((0, int(nh * 0.4), int(nw * 0.28), int(nh * 0.85))).resize((1024, 1024), Image.Resampling.LANCZOS)
    b_np = numpy_seamless(np.array(blade_crop))
    blade_albedo = Image.fromarray(b_np)
    blade_albedo = ImageEnhance.Color(blade_albedo).enhance(2.2)
    save_dual_img(blade_albedo, "ninja_shadow_blade_albedo.png", "ninja_blade_albedo.png")

    b_flt = b_np.astype(np.float32)
    br, bg, bb = b_flt[:, :, 0], b_flt[:, :, 1], b_flt[:, :, 2]
    plasma = (bb > 110) & ((bb + bg) > 220)
    bem_np = np.zeros_like(b_np)
    bem_np[plasma, 0] = np.clip(br[plasma] * 0.4, 0, 255).astype(np.uint8)
    bem_np[plasma, 1] = np.clip(bg[plasma] * 1.35, 0, 255).astype(np.uint8)
    bem_np[plasma, 2] = np.clip(bb[plasma] * 1.5, 0, 255).astype(np.uint8)
    blade_em = Image.fromarray(bem_np).filter(ImageFilter.GaussianBlur(1.0))
    save_dual_img(blade_em, "ninja_shadow_blade_emission.png", "ninja_blade_emission.png")
    print("  [OK] Ninja Shadow & Volt textures created.")

    # -------------------------------------------------------------------------
    # 6. NINJA: FIRE SHINOBI (bonkers_image_create_a_full-body.png)
    # -------------------------------------------------------------------------
    fire_base = np.zeros((1024, 1024, 3), dtype=np.float32)
    fire_base[:, :] = [42.0, 28.0, 24.0]
    fire_base += grid[:, :, np.newaxis]
    ninja_fire_armor = Image.fromarray(np.clip(fire_base, 0, 255).astype(np.uint8))
    save_dual_img(ninja_fire_armor, "ninja_fire_armor_albedo.png")

    nfa_gray = np.array(ninja_fire_armor.convert("L"))
    ninja_fire_norm = Image.fromarray(numpy_normal_map(nfa_gray, strength=2.8))
    save_dual_img(ninja_fire_norm, "ninja_fire_armor_normal.png")

    # Fire Blade
    fire_blade = ImageOps.colorize(blade_albedo.convert("L"), black="#160300", mid="#ff4d00", white="#ffeeaa")
    save_dual_img(fire_blade, "ninja_fire_blade_albedo.png")

    fb_np = np.array(fire_blade).astype(np.float32)
    fbr, fbg, fbb = fb_np[:, :, 0], fb_np[:, :, 1], fb_np[:, :, 2]
    fire_plasma = (fbr > 120) & (fbr > fbb * 1.4)
    fbem_np = np.zeros_like(fb_np, dtype=np.uint8)
    fbem_np[fire_plasma, 0] = np.clip(fbr[fire_plasma] * 1.4, 0, 255).astype(np.uint8)
    fbem_np[fire_plasma, 1] = np.clip(fbg[fire_plasma] * 1.1, 0, 255).astype(np.uint8)
    fbem_np[fire_plasma, 2] = np.clip(fbb[fire_plasma] * 0.3, 0, 255).astype(np.uint8)
    fire_blade_em = Image.fromarray(fbem_np).filter(ImageFilter.GaussianBlur(1.0))
    save_dual_img(fire_blade_em, "ninja_fire_blade_emission.png")
    print("  [OK] Ninja Fire Shinobi textures created.")

    # -------------------------------------------------------------------------
    # 7. NINJA: ARCTIC GHOST (bonkers_image_make_the_pink.png white armor)
    # -------------------------------------------------------------------------
    arctic_base = np.zeros((1024, 1024, 3), dtype=np.float32)
    arctic_base[:, :] = [185.0, 195.0, 205.0]
    arctic_base += grid[:, :, np.newaxis] * 0.5
    ninja_arctic_armor = Image.fromarray(np.clip(arctic_base, 0, 255).astype(np.uint8))
    save_dual_img(ninja_arctic_armor, "ninja_arctic_armor_albedo.png")

    naa_gray = np.array(ninja_arctic_armor.convert("L"))
    ninja_arctic_norm = Image.fromarray(numpy_normal_map(naa_gray, strength=2.6))
    save_dual_img(ninja_arctic_norm, "ninja_arctic_armor_normal.png")

    arctic_blade = ImageOps.colorize(blade_albedo.convert("L"), black="#020d18", mid="#50e5ff", white="#ffffff")
    save_dual_img(arctic_blade, "ninja_arctic_blade_albedo.png")
    arctic_blade_em = ImageOps.colorize(blade_em.convert("L"), black="#000000", white="#72f0ff")
    save_dual_img(arctic_blade_em, "ninja_arctic_blade_emission.png")
    print("  [OK] Ninja Arctic Ghost textures created.")

    # -------------------------------------------------------------------------
    # 8. NINJA: CRIMSON RONIN
    # -------------------------------------------------------------------------
    crimson_base = np.zeros((1024, 1024, 3), dtype=np.float32)
    crimson_base[:, :] = [38.0, 20.0, 26.0]
    crimson_base += grid[:, :, np.newaxis]
    ninja_crimson_armor = Image.fromarray(np.clip(crimson_base, 0, 255).astype(np.uint8))
    save_dual_img(ninja_crimson_armor, "ninja_crimson_armor_albedo.png")

    nca_gray = np.array(ninja_crimson_armor.convert("L"))
    ninja_crimson_norm = Image.fromarray(numpy_normal_map(nca_gray, strength=2.8))
    save_dual_img(ninja_crimson_norm, "ninja_crimson_armor_normal.png")

    crimson_blade = ImageOps.colorize(blade_albedo.convert("L"), black="#180004", mid="#ff1a3d", white="#ffeef0")
    save_dual_img(crimson_blade, "ninja_crimson_blade_albedo.png")
    crimson_blade_em = ImageOps.colorize(blade_em.convert("L"), black="#000000", white="#ff2b48")
    save_dual_img(crimson_blade_em, "ninja_crimson_blade_emission.png")
    print("  [OK] Ninja Crimson Ronin textures created.")

    print("ALL CHARACTER SKINS GENERATED SUCCESSFULLY.")


if __name__ == "__main__":
    generate_all()
