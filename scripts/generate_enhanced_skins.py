"""
Generate high-resolution (1024x1024) multi-skin textures and PBR maps
for characters in 'Ultimate Prompt Fighters' from reference artworks.
"""

import math
import os
from pathlib import Path
from PIL import Image, ImageEnhance, ImageFilter, ImageOps

SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent
REF_DIR = PROJECT_ROOT.parent
SKIN_DIR = PROJECT_ROOT / "godot" / "assets" / "textures" / "skins"
SKIN_DIR.mkdir(parents=True, exist_ok=True)


def find_ref_image(keyword: str, fallback_candidates: list[str] = None) -> Path:
    candidates = list(REF_DIR.glob(f"*{keyword}*.png"))
    if candidates:
        return candidates[0]
    if fallback_candidates:
        for fc in fallback_candidates:
            cand = list(REF_DIR.glob(f"*{fc}*.png"))
            if cand:
                return cand[0]
    all_png = list(REF_DIR.glob("*.png"))
    if all_png:
        return all_png[0]
    raise FileNotFoundError(f"No reference image found for keyword '{keyword}'")


def create_normal_map(gray_img: Image.Image, strength: float = 3.0) -> Image.Image:
    w, h = gray_img.size
    pixels = gray_img.load()
    norm_img = Image.new("RGB", (w, h))
    norm_pixels = norm_img.load()

    for y in range(h):
        y_prev = max(0, y - 1)
        y_next = min(h - 1, y + 1)
        for x in range(w):
            x_prev = max(0, x - 1)
            x_next = min(w - 1, x + 1)
            dx = (pixels[x_next, y] - pixels[x_prev, y]) / 255.0 * strength
            dy = (pixels[x, y_next] - pixels[x, y_prev]) / 255.0 * strength
            dz = 1.0
            length = math.sqrt(dx * dx + dy * dy + dz * dz)
            nx = -dx / length
            ny = -dy / length
            nz = dz / length
            r = int((nx * 0.5 + 0.5) * 255)
            g = int((ny * 0.5 + 0.5) * 255)
            b = int((nz * 0.5 + 0.5) * 255)
            norm_pixels[x, y] = (r, g, b)
    return norm_img


def make_seamless_tile(img: Image.Image) -> Image.Image:
    w, h = img.size
    base = img.copy()
    mirror_x = ImageOps.mirror(img)
    mask_x = Image.new("L", (w, h), 0)
    for x in range(w):
        val = int(255 * (0.5 - 0.5 * math.cos(math.pi * x / w)))
        for y in range(h):
            mask_x.putpixel((x, y), val)
    blended = Image.composite(base, mirror_x, mask_x)
    return blended


def generate_golem_skins():
    print("--- Generating High-Res Golem Skins ---")
    golem_ref = Image.open(find_ref_image("full-body_3d_character.png")).convert("RGB")
    gw, gh = golem_ref.size

    # --- SKIN 1: MOLTEN BASALT (LAVA) ---
    rock_patch = golem_ref.crop((int(gw * 0.2), int(gh * 0.3), int(gw * 0.5), int(gh * 0.6)))
    rock_patch = rock_patch.resize((1024, 1024), Image.Resampling.LANCZOS)
    lava_rock_albedo = make_seamless_tile(rock_patch)
    lava_rock_albedo.save(SKIN_DIR / "golem_lava_rock_albedo.png")

    lava_rock_norm = create_normal_map(lava_rock_albedo.convert("L"), strength=3.2)
    lava_rock_norm.save(SKIN_DIR / "golem_lava_rock_normal.png")

    lava_core = golem_ref.crop((int(gw * 0.32), int(gh * 0.28), int(gw * 0.68), int(gh * 0.64)))
    lava_core = lava_core.resize((1024, 1024), Image.Resampling.LANCZOS)
    lava_core = ImageEnhance.Color(lava_core).enhance(2.0)
    lava_core = ImageEnhance.Contrast(lava_core).enhance(1.6)
    lava_core.save(SKIN_DIR / "golem_lava_core_albedo.png")

    core_pix = lava_core.load()
    lava_em = Image.new("RGB", (1024, 1024))
    lem_pix = lava_em.load()
    for y in range(1024):
        for x in range(1024):
            r, g, b = core_pix[x, y]
            if r > 110 and r > b * 1.4:
                lem_pix[x, y] = (min(255, int(r * 1.3)), min(255, int(g * 1.1)), int(b * 0.4))
            else:
                lem_pix[x, y] = (0, 0, 0)
    lava_em = lava_em.filter(ImageFilter.GaussianBlur(1.5))
    lava_em.save(SKIN_DIR / "golem_lava_core_emission.png")

    # --- SKIN 2: GLACIAL FROST TITAN ---
    frost_ref = Image.open(find_ref_image("full-body_3d_character (1).png")).convert("RGB")
    fw, fh = frost_ref.size
    frost_patch = frost_ref.crop((int(fw * 0.25), int(fh * 0.3), int(fw * 0.55), int(fh * 0.6)))
    frost_patch = frost_patch.resize((1024, 1024), Image.Resampling.LANCZOS)
    frost_albedo = make_seamless_tile(frost_patch)
    frost_albedo = ImageEnhance.Color(frost_albedo).enhance(1.4)
    frost_albedo.save(SKIN_DIR / "golem_frost_rock_albedo.png")

    frost_norm = create_normal_map(frost_albedo.convert("L"), strength=3.0)
    frost_norm.save(SKIN_DIR / "golem_frost_rock_normal.png")

    # Frost Core (Ice crystal glow)
    frost_core = frost_ref.crop((int(fw * 0.35), int(fh * 0.15), int(fw * 0.65), int(fh * 0.45)))
    frost_core = frost_core.resize((1024, 1024), Image.Resampling.LANCZOS)
    frost_core = ImageEnhance.Color(frost_core).enhance(1.8)
    frost_core.save(SKIN_DIR / "golem_frost_core_albedo.png")

    fc_pix = frost_core.load()
    frost_em = Image.new("RGB", (1024, 1024))
    fem_pix = frost_em.load()
    for y in range(1024):
        for x in range(1024):
            r, g, b = fc_pix[x, y]
            if b > 120 and b > r:
                fem_pix[x, y] = (int(r * 0.6), min(255, int(g * 1.2)), min(255, int(b * 1.4)))
            else:
                fem_pix[x, y] = (0, 0, 0)
    frost_em = frost_em.filter(ImageFilter.GaussianBlur(1.5))
    frost_em.save(SKIN_DIR / "golem_frost_core_emission.png")

    # --- SKIN 3: TOXIC SPORE HORROR ---
    toxic_ref = Image.open(find_ref_image("full-body_3d_character (3).png")).convert("RGB")
    tw, th = toxic_ref.size
    toxic_patch = toxic_ref.crop((int(tw * 0.25), int(th * 0.35), int(tw * 0.55), int(th * 0.65)))
    toxic_patch = toxic_patch.resize((1024, 1024), Image.Resampling.LANCZOS)
    toxic_albedo = make_seamless_tile(toxic_patch)
    toxic_albedo.save(SKIN_DIR / "golem_toxic_rock_albedo.png")

    toxic_norm = create_normal_map(toxic_albedo.convert("L"), strength=2.8)
    toxic_norm.save(SKIN_DIR / "golem_toxic_rock_normal.png")

    # Toxic Acid Core (bright lime/acid glow)
    toxic_core = toxic_ref.crop((int(tw * 0.3), int(th * 0.6), int(tw * 0.7), int(th * 0.95)))
    toxic_core = toxic_core.resize((1024, 1024), Image.Resampling.LANCZOS)
    toxic_core = ImageEnhance.Color(toxic_core).enhance(2.2)
    toxic_core.save(SKIN_DIR / "golem_toxic_core_albedo.png")

    tc_pix = toxic_core.load()
    toxic_em = Image.new("RGB", (1024, 1024))
    tem_pix = toxic_em.load()
    for y in range(1024):
        for x in range(1024):
            r, g, b = tc_pix[x, y]
            if g > 110 and g > b * 1.1:
                tem_pix[x, y] = (int(r * 0.8), min(255, int(g * 1.4)), int(b * 0.3))
            else:
                tem_pix[x, y] = (0, 0, 0)
    toxic_em = toxic_em.filter(ImageFilter.GaussianBlur(1.5))
    toxic_em.save(SKIN_DIR / "golem_toxic_core_emission.png")

    # --- SKIN 4: OBSIDIAN CELESTIAL ---
    obsidian_albedo = ImageEnhance.Brightness(lava_rock_albedo).enhance(0.35)
    obsidian_albedo = ImageEnhance.Contrast(obsidian_albedo).enhance(1.4)
    obsidian_albedo.save(SKIN_DIR / "golem_celestial_rock_albedo.png")

    # Gold / Solar Core
    solar_core = ImageEnhance.Color(lava_core).enhance(1.8)
    solar_pix = solar_core.load()
    solar_em = Image.new("RGB", (1024, 1024))
    sem_pix = solar_em.load()
    for y in range(1024):
        for x in range(1024):
            r, g, b = solar_pix[x, y]
            if r > 100 and g > 70:
                sem_pix[x, y] = (min(255, int(r * 1.3)), min(255, int(g * 1.2)), int(b * 0.2))
            else:
                sem_pix[x, y] = (0, 0, 0)
    solar_em = solar_em.filter(ImageFilter.GaussianBlur(1.5))
    solar_em.save(SKIN_DIR / "golem_celestial_core_emission.png")
    solar_core.save(SKIN_DIR / "golem_celestial_core_albedo.png")

    print("  Golem skins generated: Lava, Frost, Toxic, Celestial.")


def generate_ninja_skins():
    print("--- Generating High-Res Ninja Skins ---")
    tech_ref = Image.open(find_ref_image("concept_art_generation..png")).convert("RGB")
    tw, th = tech_ref.size

    # --- SKIN 1: CYBER SHADOW (Dark Kevlar + Cyan Plasma) ---
    armor_crop = tech_ref.crop((int(tw * 0.35), int(th * 0.2), int(tw * 0.65), int(th * 0.5)))
    armor_crop = armor_crop.resize((1024, 1024), Image.Resampling.LANCZOS)
    ninja_shadow_albedo = make_seamless_tile(armor_crop)
    ninja_shadow_albedo = ImageEnhance.Brightness(ninja_shadow_albedo).enhance(0.5)
    ninja_shadow_albedo = ImageEnhance.Contrast(ninja_shadow_albedo).enhance(1.3)
    ninja_shadow_albedo.save(SKIN_DIR / "ninja_shadow_armor_albedo.png")

    ninja_shadow_norm = create_normal_map(ninja_shadow_albedo.convert("L"), strength=2.6)
    ninja_shadow_norm.save(SKIN_DIR / "ninja_shadow_armor_normal.png")

    # Cyan Energy Blade & Circuit Emission
    konzept = Image.open(find_ref_image("konzeptblatt")).convert("RGB")
    kw, kh = konzept.size
    blade_crop = konzept.crop((0, 0, int(kw * 0.33), int(kh * 0.33))).resize((1024, 1024), Image.Resampling.LANCZOS)
    blade_cyan_albedo = ImageEnhance.Color(blade_crop).enhance(1.8)
    blade_cyan_albedo.save(SKIN_DIR / "ninja_shadow_blade_albedo.png")

    bc_pix = blade_cyan_albedo.load()
    blade_cyan_em = Image.new("RGB", (1024, 1024))
    bem_pix = blade_cyan_em.load()
    for y in range(1024):
        for x in range(1024):
            r, g, b = bc_pix[x, y]
            if g > 90 and b > 110:
                bem_pix[x, y] = (int(r * 0.6), min(255, int(g * 1.3)), min(255, int(b * 1.4)))
            else:
                bem_pix[x, y] = (0, 0, 0)
    blade_cyan_em = blade_cyan_em.filter(ImageFilter.GaussianBlur(1.2))
    blade_cyan_em.save(SKIN_DIR / "ninja_shadow_blade_emission.png")

    # --- SKIN 2: CRIMSON RONIN (Matte Black + Blood Red Energy) ---
    ninja_crimson_armor = ImageEnhance.Brightness(ninja_shadow_albedo).enhance(0.7)
    ninja_crimson_armor.save(SKIN_DIR / "ninja_crimson_armor_albedo.png")

    blade_crimson_albedo = ImageOps.colorize(blade_crop.convert("L"), black="#100002", white="#ff2244")
    blade_crimson_albedo.save(SKIN_DIR / "ninja_crimson_blade_albedo.png")

    bcr_pix = blade_crimson_albedo.load()
    blade_crimson_em = Image.new("RGB", (1024, 1024))
    bcrem_pix = blade_crimson_em.load()
    for y in range(1024):
        for x in range(1024):
            r, g, b = bcr_pix[x, y]
            if r > 100:
                bcrem_pix[x, y] = (min(255, int(r * 1.4)), int(g * 0.3), int(b * 0.3))
            else:
                bcrem_pix[x, y] = (0, 0, 0)
    blade_crimson_em = blade_crimson_em.filter(ImageFilter.GaussianBlur(1.2))
    blade_crimson_em.save(SKIN_DIR / "ninja_crimson_blade_emission.png")

    # --- SKIN 3: ARCTIC GHOST (Silver/White Armor + Frost Glow) ---
    pink_ref = Image.open(find_ref_image("pink", ["concept_art_generation"])).convert("RGB")
    pw, ph = pink_ref.size
    white_crop = pink_ref.crop((int(pw * 0.1), int(ph * 0.2), int(pw * 0.4), int(ph * 0.5)))
    white_crop = white_crop.resize((1024, 1024), Image.Resampling.LANCZOS)
    ninja_arctic_armor = make_seamless_tile(white_crop)
    ninja_arctic_armor = ImageEnhance.Brightness(ninja_arctic_armor).enhance(1.1)
    ninja_arctic_armor = ImageEnhance.Contrast(ninja_arctic_armor).enhance(1.2)
    ninja_arctic_armor.save(SKIN_DIR / "ninja_arctic_armor_albedo.png")

    ninja_arctic_norm = create_normal_map(ninja_arctic_armor.convert("L"), strength=2.2)
    ninja_arctic_norm.save(SKIN_DIR / "ninja_arctic_armor_normal.png")

    # --- SKIN 4: VENOM MATRIX (Acid Green Glow) ---
    blade_venom_albedo = ImageOps.colorize(blade_crop.convert("L"), black="#001402", white="#44ff33")
    blade_venom_albedo.save(SKIN_DIR / "ninja_venom_blade_albedo.png")
    bv_pix = blade_venom_albedo.load()
    blade_venom_em = Image.new("RGB", (1024, 1024))
    bvem_pix = blade_venom_em.load()
    for y in range(1024):
        for x in range(1024):
            r, g, b = bv_pix[x, y]
            if g > 110:
                bvem_pix[x, y] = (int(r * 0.4), min(255, int(g * 1.5)), int(b * 0.3))
            else:
                bvem_pix[x, y] = (0, 0, 0)
    blade_venom_em = blade_venom_em.filter(ImageFilter.GaussianBlur(1.2))
    blade_venom_em.save(SKIN_DIR / "ninja_venom_blade_emission.png")

    print("  Ninja skins generated: Cyber Shadow, Crimson Ronin, Arctic Ghost, Venom Matrix.")


if __name__ == "__main__":
    generate_golem_skins()
    generate_ninja_skins()
    print("ALL_ENHANCED_SKINS_GENERATED_SUCCESSFULLY")
