"""
Generate PBR textures, sky panoramas, floor textures, UI portraits, and VFX
directly from reference concept artwork in 'Ultimate Prompt Fighters'.
"""

import math
import os
from pathlib import Path
from PIL import Image, ImageEnhance, ImageFilter, ImageOps

# Source and Target paths
SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent
REF_DIR = PROJECT_ROOT.parent # c:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters
TEX_DIR = PROJECT_ROOT / "godot" / "assets" / "textures"

CHAR_TEX = TEX_DIR / "characters"
ARENA_TEX = TEX_DIR / "arenas"
UI_TEX = TEX_DIR / "ui"
VFX_TEX = TEX_DIR / "vfx"

for d in [CHAR_TEX, ARENA_TEX, UI_TEX, VFX_TEX]:
    d.mkdir(parents=True, exist_ok=True)


def find_ref_image(keyword: str, fallback_candidates: list[str] = None) -> Path:
    """Find the best matching reference PNG file in REF_DIR."""
    candidates = list(REF_DIR.glob(f"*{keyword}*.png"))
    if candidates:
        return candidates[0]
    if fallback_candidates:
        for fc in fallback_candidates:
            cand = list(REF_DIR.glob(f"*{fc}*.png"))
            if cand:
                return cand[0]
    # Fallback to any PNG
    all_png = list(REF_DIR.glob("*.png"))
    if all_png:
        return all_png[0]
    raise FileNotFoundError(f"No reference image found for keyword '{keyword}'")


def create_normal_map(gray_img: Image.Image, strength: float = 2.0) -> Image.Image:
    """Generate an RGB normal map from a grayscale height/luminance image using Sobel-like gradients."""
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

            # Horizontal & Vertical gradients
            dx = (pixels[x_next, y] - pixels[x_prev, y]) / 255.0 * strength
            dy = (pixels[x, y_next] - pixels[x, y_prev]) / 255.0 * strength

            # Normal vector: (-dx, -dy, 1.0) normalized
            dz = 1.0
            length = math.sqrt(dx * dx + dy * dy + dz * dz)
            nx = -dx / length
            ny = -dy / length
            nz = dz / length

            # Map [-1, 1] to [0, 255]
            r = int((nx * 0.5 + 0.5) * 255)
            g = int((ny * 0.5 + 0.5) * 255)
            b = int((nz * 0.5 + 0.5) * 255)
            norm_pixels[x, y] = (r, g, b)

    return norm_img


def make_seamless_tile(img: Image.Image, blend_fraction: float = 0.2) -> Image.Image:
    """Make an image seamlessly tileable by blend-overlapping edges."""
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


def generate_character_textures():
    print("--- Generating Character Textures ---")

    # 1. Golem Textures
    # Reference: bonkers_image_full-body_3d_character.png & bonkers_image_gameplay_action_shot.png
    golem_ref_path = find_ref_image("full-body_3d_character.png", ["full-body", "action_shot"])
    golem_img = Image.open(golem_ref_path).convert("RGB")
    gw, gh = golem_img.size

    # Extract Rock / Basalt texture patch from golem armor/body
    rock_patch = golem_img.crop((int(gw * 0.25), int(gh * 0.35), int(gw * 0.45), int(gh * 0.55)))
    rock_patch = rock_patch.resize((512, 512), Image.Resampling.LANCZOS)
    rock_albedo = make_seamless_tile(rock_patch)
    rock_albedo.save(CHAR_TEX / "golem_rock_albedo.png")

    # Rock Normal Map & Roughness
    rock_gray = rock_albedo.convert("L")
    rock_norm = create_normal_map(rock_gray, strength=2.5)
    rock_norm.save(CHAR_TEX / "golem_rock_normal.png")

    # Roughness: Darker where cracks are (smoother), lighter on rough stone
    rock_rough = ImageOps.invert(rock_gray)
    rock_rough = ImageEnhance.Contrast(rock_rough).enhance(1.4)
    rock_rough.save(CHAR_TEX / "golem_rock_roughness.png")

    # Dark Armor Rock
    dark_armor = ImageEnhance.Brightness(rock_albedo).enhance(0.45)
    dark_armor = ImageEnhance.Contrast(dark_armor).enhance(1.3)
    dark_armor.save(CHAR_TEX / "golem_armor_albedo.png")

    # Lava Glow / Core Texture
    # Extract glowing lava chest region
    lava_patch = golem_img.crop((int(gw * 0.35), int(gh * 0.30), int(gw * 0.65), int(gh * 0.60)))
    lava_patch = lava_patch.resize((512, 512), Image.Resampling.LANCZOS)
    lava_albedo = ImageEnhance.Color(lava_patch).enhance(1.8)
    lava_albedo = ImageEnhance.Contrast(lava_albedo).enhance(1.5)
    lava_albedo.save(CHAR_TEX / "golem_lava_albedo.png")

    # Lava Emission Map: Isolate high red/yellow intensity
    lava_pixels = lava_albedo.load()
    lava_emission = Image.new("RGB", (512, 512))
    lem_pixels = lava_emission.load()
    for y in range(512):
        for x in range(512):
            r, g, b = lava_pixels[x, y]
            # Lava has high R and substantial G, lower B
            if r > 120 and (r > b * 1.5):
                lem_pixels[x, y] = (r, g, int(b * 0.5))
            else:
                lem_pixels[x, y] = (0, 0, 0)
    lava_emission = lava_emission.filter(ImageFilter.GaussianBlur(1.0))
    lava_emission.save(CHAR_TEX / "golem_lava_emission.png")

    print("  Created Golem textures: rock albedo, normal, roughness, armor albedo, lava albedo, lava emission.")

    # 2. Ninja Textures
    # Reference: bonkers_image_erstelle_ein_konzeptblatt.png & concept_art_generation..png
    ninja_ref_path = find_ref_image("konzeptblatt", ["concept_art", "pink"])
    ninja_img = Image.open(ninja_ref_path).convert("RGB")
    nw, nh = ninja_img.size

    # Electric Blade Glow (upper left in concept sheet)
    blade_patch = ninja_img.crop((0, 0, int(nw * 0.33), int(nh * 0.33)))
    blade_patch = blade_patch.resize((512, 512), Image.Resampling.LANCZOS)
    blade_albedo = ImageEnhance.Color(blade_patch).enhance(1.6)
    blade_albedo.save(CHAR_TEX / "ninja_blade_albedo.png")

    # Electric Emission: Cyan glow isolation
    blade_emission = Image.new("RGB", (512, 512))
    be_pixels = blade_emission.load()
    bp_pixels = blade_albedo.load()
    for y in range(512):
        for x in range(512):
            r, g, b = bp_pixels[x, y]
            if g > 100 and b > 120:
                be_pixels[x, y] = (int(r * 0.8), g, b)
            else:
                be_pixels[x, y] = (0, 0, 0)
    blade_emission = blade_emission.filter(ImageFilter.GaussianBlur(1.0))
    blade_emission.save(CHAR_TEX / "ninja_blade_emission.png")

    # Ninja Dark Armor / Fabric Patch
    tech_ref_path = find_ref_image("concept_art_generation..png", ["concept_art_generation", "konzeptblatt"])
    tech_img = Image.open(tech_ref_path).convert("RGB")
    tw, th = tech_img.size
    armor_patch = tech_img.crop((int(tw * 0.40), int(th * 0.25), int(tw * 0.60), int(th * 0.45)))
    armor_patch = armor_patch.resize((512, 512), Image.Resampling.LANCZOS)
    ninja_armor = ImageEnhance.Brightness(armor_patch).enhance(0.55)
    ninja_armor = ImageEnhance.Color(ninja_armor).enhance(0.8)
    ninja_armor = make_seamless_tile(ninja_armor)
    ninja_armor.save(CHAR_TEX / "ninja_armor_albedo.png")

    # Ninja Armor Normal & Roughness
    ninja_gray = ninja_armor.convert("L")
    ninja_norm = create_normal_map(ninja_gray, strength=2.0)
    ninja_norm.save(CHAR_TEX / "ninja_armor_normal.png")

    ninja_cloth = ImageEnhance.Brightness(ninja_armor).enhance(0.4)
    ninja_cloth.save(CHAR_TEX / "ninja_cloth_albedo.png")

    print("  Created Ninja textures: armor albedo, normal, cloth albedo, blade albedo, blade emission.")


def generate_arena_textures():
    print("--- Generating Arena Textures & Panoramas ---")

    arenas = [
        {
            "id": "blood_moon",
            "name": "Blood Moon Terrace",
            "file": "bonkers_image_jetzt_bau_im.png",
            "fallback": "jetzt_bau_im",
            "env_light": (0.8, 0.2, 0.25),
        },
        {
            "id": "volcano_sanctum",
            "name": "Volcanic Dragon Sanctum",
            "file": "bonkers_image_create_a_breathtaking.png",
            "fallback": "breathtaking",
            "env_light": (1.0, 0.4, 0.1),
        },
        {
            "id": "imperial_colosseum",
            "name": "Imperial Colosseum",
            "file": "p9E4sxtRVEcTEeTSquAbX8DlNMR2_b33e4848-7f8f-4df1-afe0-9e0b9ed6b2d2.png",
            "fallback": "p9E4",
            "env_light": (1.0, 0.85, 0.65),
        },
        {
            "id": "pirate_galleon",
            "name": "Pirate Galleon Dock",
            "file": "bonkers_image_create_a_high-quality.png",
            "fallback": "high-quality",
            "env_light": (0.4, 0.8, 0.9),
        },
        {
            "id": "gladiator_fortress",
            "name": "Gladiator Bastion",
            "file": "bonkers_image_create_a_spectacular.png",
            "fallback": "spectacular",
            "env_light": (0.9, 0.75, 0.5),
        },
        {
            "id": "mystic_grove",
            "name": "Bioluminescent Grove",
            "file": "bonkers_image_erstelle_ein_professionelles (3).png",
            "fallback": "professionelles (3)",
            "env_light": (0.2, 0.85, 0.7),
        },
    ]

    for arena in arenas:
        try:
            path = find_ref_image(arena["fallback"])
            img = Image.open(path).convert("RGB")
            # Format skybox panorama texture (2048 x 1024)
            panorama = img.resize((2048, 1024), Image.Resampling.LANCZOS)
            panorama = ImageEnhance.Sharpness(panorama).enhance(1.2)
            panorama.save(ARENA_TEX / f"sky_{arena['id']}.png")

            # Format arena thumbnail for selection UI (384 x 216, 16:9)
            thumb = img.resize((384, 216), Image.Resampling.LANCZOS)
            thumb = ImageEnhance.Color(thumb).enhance(1.25)
            thumb = ImageEnhance.Contrast(thumb).enhance(1.15)
            thumb.save(UI_TEX / f"thumb_{arena['id']}.png")

            print(f"  Created Arena: {arena['name']} -> sky_{arena['id']}.png, thumb_{arena['id']}.png")
        except Exception as e:
            print(f"  Error creating arena {arena['id']}: {e}")

    # Generate Floor Textures
    # 1. Volcanic / Lava Ground Slabs
    try:
        lava_ground_path = find_ref_image("gameplay_action_shot.png", ["action_shot", "full-body"])
        lg_img = Image.open(lava_ground_path).convert("RGB")
        w, h = lg_img.size
        floor_crop = lg_img.crop((int(w * 0.1), int(h * 0.65), int(w * 0.9), int(h * 0.95)))
        floor_crop = floor_crop.resize((1024, 1024), Image.Resampling.LANCZOS)
        floor_albedo = make_seamless_tile(floor_crop)
        floor_albedo.save(ARENA_TEX / "floor_lava_albedo.png")

        # Normal map & Emission for glowing cracks in the floor
        fg_gray = floor_albedo.convert("L")
        fg_norm = create_normal_map(fg_gray, strength=3.0)
        fg_norm.save(ARENA_TEX / "floor_lava_normal.png")

        fg_pix = floor_albedo.load()
        fg_em = Image.new("RGB", (1024, 1024))
        fg_em_pix = fg_em.load()
        for y in range(1024):
            for x in range(1024):
                r, g, b = fg_pix[x, y]
                if r > 140 and (r > b * 1.6):
                    fg_em_pix[x, y] = (r, g, int(b * 0.5))
                else:
                    fg_em_pix[x, y] = (0, 0, 0)
        fg_em.save(ARENA_TEX / "floor_lava_emission.png")
        print("  Created Floor: floor_lava_albedo.png, normal, emission.")
    except Exception as e:
        print(f"  Error generating lava floor: {e}")

    # 2. Ancient Colosseum Stone Floor
    try:
        colo_path = find_ref_image("p9E4")
        c_img = Image.open(colo_path).convert("RGB")
        w, h = c_img.size
        stone_crop = c_img.crop((int(w * 0.15), int(h * 0.68), int(w * 0.85), int(h * 0.98)))
        stone_crop = stone_crop.resize((1024, 1024), Image.Resampling.LANCZOS)
        stone_albedo = make_seamless_tile(stone_crop)
        stone_albedo.save(ARENA_TEX / "floor_stone_albedo.png")
        stone_norm = create_normal_map(stone_albedo.convert("L"), strength=2.2)
        stone_norm.save(ARENA_TEX / "floor_stone_normal.png")
        print("  Created Floor: floor_stone_albedo.png, normal.")
    except Exception as e:
        print(f"  Error generating stone floor: {e}")


def generate_portraits():
    print("--- Generating Fighter Portraits ---")

    fighters = [
        {
            "id": "golem",
            "name": "Cinder Bastion (Pyros)",
            "file": "bonkers_image_full-body_3d_character.png",
            "crop": (0.35, 0.04, 0.65, 0.34),
        },
        {
            "id": "ninja",
            "name": "Volt Shadow (Kage)",
            "file": "bonkers_image_erstelle_ein_konzeptblatt.png",
            "crop": (0.35, 0.02, 0.65, 0.32),
        },
        {
            "id": "frost",
            "name": "Glacius (Frost Titan)",
            "file": "bonkers_image_full-body_3d_character (1).png",
            "crop": (0.38, 0.08, 0.64, 0.34),
        },
        {
            "id": "storm",
            "name": "Voltar (Storm Deity)",
            "file": "bonkers_image___animation__.png",
            "crop": (0.36, 0.06, 0.64, 0.34),
        },
        {
            "id": "toxic",
            "name": "Blight (Spore Horror)",
            "file": "bonkers_image_full-body_3d_character (3).png",
            "crop": (0.36, 0.04, 0.64, 0.32),
        },
        {
            "id": "cyber",
            "name": "Apex (Cyber Commando)",
            "file": "bonkers_image_concept_art_generation..png",
            "crop": (0.38, 0.06, 0.62, 0.30),
        },
    ]

    for f in fighters:
        try:
            path = REF_DIR / f["file"]
            if not path.exists():
                path = find_ref_image(f["id"])
            img = Image.open(path).convert("RGB")
            w, h = img.size
            cx1, cy1, cx2, cy2 = f["crop"]
            crop_rect = (int(w * cx1), int(h * cy1), int(w * cx2), int(h * cy2))
            bust = img.crop(crop_rect)
            bust = bust.resize((256, 256), Image.Resampling.LANCZOS)
            bust = ImageEnhance.Contrast(bust).enhance(1.2)
            bust = ImageEnhance.Color(bust).enhance(1.15)
            bust = ImageEnhance.Sharpness(bust).enhance(1.3)

            frame = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
            frame.paste(bust.convert("RGBA"), (0, 0))
            draw_border = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
            dpix = draw_border.load()
            for y in range(256):
                for x in range(256):
                    if x < 4 or x > 251 or y < 4 or y > 251:
                        dpix[x, y] = (50, 180, 255, 220) if "ninja" in f["id"] or "frost" in f["id"] or "storm" in f["id"] else (255, 140, 50, 220)
            final_portrait = Image.alpha_composite(frame, draw_border)
            final_portrait.save(UI_TEX / f"portrait_{f['id']}.png")
            print(f"  Created Portrait: portrait_{f['id']}.png ({f['name']})")
        except Exception as e:
            print(f"  Error creating portrait for {f['id']}: {e}")


def generate_vfx_textures():
    print("--- Generating VFX Textures ---")
    size = 128
    spark = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    sp_pixels = spark.load()
    cx, cy = size / 2, size / 2
    for y in range(size):
        for x in range(size):
            dx = abs(x - cx)
            dy = abs(y - cy)
            dist = math.sqrt(dx * dx + dy * dy)
            star_val = max(0.0, 1.0 - (dx * dy) / 120.0 - dist / 55.0)
            if star_val > 0:
                alpha = int(min(255, star_val * 255 * 1.5))
                sp_pixels[x, y] = (255, 240, 200, alpha)
    spark = spark.filter(ImageFilter.GaussianBlur(0.8))
    spark.save(VFX_TEX / "hit_spark.png")

    ember = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    em_pix = ember.load()
    for y in range(64):
        for x in range(64):
            d = math.sqrt((x - 32) ** 2 + (y - 32) ** 2)
            if d < 30:
                alpha = int(255 * max(0.0, (1.0 - d / 30.0) ** 2))
                em_pix[x, y] = (255, 120, 20, alpha)
    ember.save(VFX_TEX / "lava_ember.png")

    elec = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    el_pix = elec.load()
    for y in range(64):
        for x in range(64):
            d = math.sqrt((x - 32) ** 2 + (y - 32) ** 2)
            if d < 30:
                alpha = int(255 * max(0.0, (1.0 - d / 30.0) ** 2))
                el_pix[x, y] = (60, 220, 255, alpha)
    elec.save(VFX_TEX / "electric_spark.png")
    print("  Created VFX: hit_spark.png, lava_ember.png, electric_spark.png.")


if __name__ == "__main__":
    generate_character_textures()
    generate_arena_textures()
    generate_portraits()
    generate_vfx_textures()
    print("ALL_TEXTURES_GENERATED_SUCCESSFULLY")
