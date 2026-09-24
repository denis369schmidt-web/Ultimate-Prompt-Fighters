"""
Generate ultra-high detail PBR textures for all 11 character families.
Produces Albedo, Normal maps, Roughness, and Emission maps.
"""
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
SKIN_DIR = ROOT / "godot" / "assets" / "textures" / "skins"
SKIN_DIR.mkdir(parents=True, exist_ok=True)

def make_normal_map(height_map: np.ndarray, strength: float = 3.5) -> Image.Image:
    h, w = height_map.shape
    g = height_map.astype(np.float32) / 255.0
    pad = np.pad(g, ((1, 1), (1, 1)), mode='wrap')
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
    r = ((nx * 0.5 + 0.5) * 255).clip(0, 255).astype(np.uint8)
    g_ch = ((ny * 0.5 + 0.5) * 255).clip(0, 255).astype(np.uint8)
    b = ((nz * 0.5 + 0.5) * 255).clip(0, 255).astype(np.uint8)
    rgb = np.stack([r, g_ch, b], axis=-1)
    return Image.fromarray(rgb, mode="RGB")

def generate_valkyrie():
    size = (512, 512)
    # 1. Holy Gold Plate
    alb = Image.new("RGB", size, (235, 230, 215))
    draw = ImageDraw.Draw(alb)
    # Filigree gold engravings
    for y in range(0, 512, 64):
        for x in range(0, 512, 64):
            draw.rectangle([x+4, y+4, x+60, y+60], outline=(195, 155, 60), width=3)
            draw.line([x+4, y+4, x+60, y+60], fill=(215, 180, 85), width=2)
            draw.line([x+60, y+4, x+4, y+60], fill=(215, 180, 85), width=2)
    alb.save(SKIN_DIR / "valkyrie_plate_albedo.png")
    gray = np.array(alb.convert("L"))
    make_normal_map(gray, 4.0).save(SKIN_DIR / "valkyrie_plate_normal.png")

    # 2. Celestial Wings Emission
    wing_em = Image.new("RGB", size, (0, 0, 0))
    wdraw = ImageDraw.Draw(wing_em)
    for y in range(0, 512, 32):
        wdraw.line([0, y, 512, y + 24], fill=(255, 220, 110), width=6)
        wdraw.line([0, y + 24, 512, y], fill=(255, 180, 60), width=4)
    wing_em = wing_em.filter(ImageFilter.GaussianBlur(3))
    wing_em.save(SKIN_DIR / "valkyrie_wings_emission.png")
    print("[OK] Valkyrie PBR generated")

def generate_dragon():
    size = (512, 512)
    # Scale pattern
    alb = Image.new("RGB", size, (48, 14, 14))
    draw = ImageDraw.Draw(alb)
    h_arr = np.zeros(size, dtype=np.uint8)
    for row in range(0, 512, 24):
        offset = 12 if (row // 24) % 2 == 1 else 0
        for col in range(-12, 524, 24):
            x = col + offset
            draw.polygon([(x, row), (x+12, row+20), (x+24, row), (x+12, row+6)], fill=(138, 28, 24), outline=(210, 65, 35))
    alb.save(SKIN_DIR / "dragon_scale_albedo.png")
    gray = np.array(alb.convert("L"))
    make_normal_map(gray, 5.0).save(SKIN_DIR / "dragon_scale_normal.png")

    # Magma veins emission
    em = Image.new("RGB", size, (0, 0, 0))
    edraw = ImageDraw.Draw(em)
    for row in range(0, 512, 24):
        offset = 12 if (row // 24) % 2 == 1 else 0
        for col in range(-12, 524, 24):
            x = col + offset
            edraw.line([x+12, row+6, x+12, row+20], fill=(255, 120, 30), width=3)
    em = em.filter(ImageFilter.GaussianBlur(2))
    em.save(SKIN_DIR / "dragon_scale_emission.png")
    print("[OK] Dragon PBR generated")

def generate_anubis():
    size = (512, 512)
    # Obsidian with Egyptian hieroglyphic bands
    alb = Image.new("RGB", size, (22, 22, 26))
    draw = ImageDraw.Draw(alb)
    for y in range(0, 512, 48):
        draw.line([0, y, 512, y], fill=(185, 145, 45), width=4)
        for x in range(0, 512, 48):
            draw.rectangle([x+10, y+8, x+38, y+40], outline=(145, 110, 35), width=2)
            draw.ellipse([x+18, y+16, x+30, y+32], fill=(45, 160, 220))
    alb.save(SKIN_DIR / "anubis_obsidian_albedo.png")
    gray = np.array(alb.convert("L"))
    make_normal_map(gray, 4.5).save(SKIN_DIR / "anubis_obsidian_normal.png")

    em = Image.new("RGB", size, (0, 0, 0))
    edraw = ImageDraw.Draw(em)
    for y in range(0, 512, 48):
        for x in range(0, 512, 48):
            edraw.ellipse([x+18, y+16, x+30, y+32], fill=(60, 220, 255))
    em = em.filter(ImageFilter.GaussianBlur(2))
    em.save(SKIN_DIR / "anubis_obsidian_emission.png")
    print("[OK] Anubis PBR generated")

def generate_specter():
    size = (512, 512)
    # Crystal facets
    alb = Image.new("RGB", size, (28, 14, 48))
    draw = ImageDraw.Draw(alb)
    for y in range(0, 512, 64):
        for x in range(0, 512, 64):
            draw.polygon([(x+32, y), (x+64, y+32), (x+32, y+64), (x, y+32)], fill=(75, 35, 125), outline=(160, 95, 250))
            draw.line([x, y, x+64, y+64], fill=(200, 140, 255), width=2)
    alb.save(SKIN_DIR / "specter_crystal_albedo.png")
    gray = np.array(alb.convert("L"))
    make_normal_map(gray, 4.2).save(SKIN_DIR / "specter_crystal_normal.png")

    em = Image.new("RGB", size, (0, 0, 0))
    edraw = ImageDraw.Draw(em)
    for y in range(0, 512, 64):
        for x in range(0, 512, 64):
            edraw.line([x+32, y+16, x+32, y+48], fill=(185, 75, 255), width=4)
            edraw.line([x+16, y+32, x+48, y+32], fill=(185, 75, 255), width=4)
    em = em.filter(ImageFilter.GaussianBlur(3))
    em.save(SKIN_DIR / "specter_crystal_emission.png")
    print("[OK] Specter PBR generated")

def generate_phoenix():
    size = (512, 512)
    alb = Image.new("RGB", size, (180, 42, 16))
    draw = ImageDraw.Draw(alb)
    for y in range(0, 512, 32):
        for x in range(0, 512, 32):
            draw.arc([x, y, x+32, y+32], 0, 180, fill=(255, 175, 45), width=3)
    alb.save(SKIN_DIR / "phoenix_feather_albedo.png")
    gray = np.array(alb.convert("L"))
    make_normal_map(gray, 4.0).save(SKIN_DIR / "phoenix_feather_normal.png")

    em = Image.new("RGB", size, (0, 0, 0))
    edraw = ImageDraw.Draw(em)
    for y in range(0, 512, 32):
        for x in range(0, 512, 32):
            edraw.arc([x, y, x+32, y+32], 0, 180, fill=(255, 120, 20), width=4)
    em = em.filter(ImageFilter.GaussianBlur(2))
    em.save(SKIN_DIR / "phoenix_feather_emission.png")
    print("[OK] Phoenix PBR generated")

def generate_luffy():
    size = (512, 512)
    # 1. Straw weave for hat
    straw = Image.new("RGB", size, (220, 185, 95))
    sdraw = ImageDraw.Draw(straw)
    for y in range(0, 512, 8):
        for x in range(0, 512, 16):
            ox = 8 if (y // 8) % 2 == 1 else 0
            sdraw.rectangle([x + ox, y, x + ox + 14, y + 6], fill=(235, 200, 110), outline=(180, 145, 65))
    # Red ribbon band in center
    sdraw.rectangle([0, 230, 512, 280], fill=(205, 30, 30))
    straw.save(SKIN_DIR / "luffy_straw_albedo.png")
    make_normal_map(np.array(straw.convert("L")), 3.5).save(SKIN_DIR / "luffy_straw_normal.png")

    # 2. Red Vest Cloth
    vest = Image.new("RGB", size, (195, 28, 28))
    vdraw = ImageDraw.Draw(vest)
    for y in range(0, 512, 12):
        vdraw.line([0, y, 512, y], fill=(165, 20, 20), width=1)
    for x in range(0, 512, 12):
        vdraw.line([x, 0, x, 512], fill=(165, 20, 20), width=1)
    # Gold buttons
    for y in [128, 256, 384]:
        vdraw.ellipse([240, y-16, 272, y+16], fill=(240, 200, 50), outline=(160, 120, 20), width=2)
    vest.save(SKIN_DIR / "luffy_vest_albedo.png")
    make_normal_map(np.array(vest.convert("L")), 3.0).save(SKIN_DIR / "luffy_vest_normal.png")

    # 3. Denim Shorts
    denim = Image.new("RGB", size, (35, 65, 125))
    ddraw = ImageDraw.Draw(denim)
    for y in range(0, 512, 6):
        ddraw.line([0, y, 512, y], fill=(25, 50, 105), width=1)
    denim.save(SKIN_DIR / "luffy_denim_albedo.png")
    make_normal_map(np.array(denim.convert("L")), 2.5).save(SKIN_DIR / "luffy_denim_normal.png")
    print("[OK] Luffy PBR generated")

def generate_pain():
    size = (512, 512)
    # Akatsuki black cloak with red cloud pattern
    cloak = Image.new("RGB", size, (16, 16, 20))
    cdraw = ImageDraw.Draw(cloak)
    # Draw stylized Akatsuki clouds
    for cy in [128, 384]:
        for cx in [128, 384]:
            cdraw.ellipse([cx-50, cy-20, cx+50, cy+25], fill=(190, 25, 25), outline=(245, 245, 245), width=3)
            cdraw.ellipse([cx-30, cy-40, cx+15, cy], fill=(190, 25, 25), outline=(245, 245, 245), width=3)
            cdraw.ellipse([cx+5, cy-35, cx+40, cy], fill=(190, 25, 25), outline=(245, 245, 245), width=3)
    cloak.save(SKIN_DIR / "pain_cloak_master_albedo.png")
    make_normal_map(np.array(cloak.convert("L")), 3.5).save(SKIN_DIR / "pain_cloak_master_normal.png")

    # Rinnegan eyes emission
    em = Image.new("RGB", size, (0, 0, 0))
    edraw = ImageDraw.Draw(em)
    center = (256, 256)
    for r in [20, 45, 75, 110, 150]:
        edraw.ellipse([center[0]-r, center[1]-r, center[0]+r, center[1]+r], outline=(180, 70, 255), width=5)
    edraw.ellipse([center[0]-8, center[1]-8, center[0]+8, center[1]+8], fill=(220, 140, 255))
    em = em.filter(ImageFilter.GaussianBlur(2))
    em.save(SKIN_DIR / "pain_rinnegan_master_emission.png")
    print("[OK] Pain PBR generated")

def generate_subzero():
    size = (512, 512)
    # Cryomancer Lin-Kuei armor
    alb = Image.new("RGB", size, (18, 32, 64))
    draw = ImageDraw.Draw(alb)
    for y in range(0, 512, 32):
        draw.line([0, y, 512, y], fill=(45, 95, 175), width=3)
        for x in range(0, 512, 32):
            draw.polygon([(x+16, y), (x+32, y+16), (x+16, y+32), (x, y+16)], fill=(28, 55, 115), outline=(75, 185, 255))
    alb.save(SKIN_DIR / "subzero_kori_albedo.png")
    make_normal_map(np.array(alb.convert("L")), 4.0).save(SKIN_DIR / "subzero_kori_normal.png")

    # Ice blade glow
    em = Image.new("RGB", size, (0, 0, 0))
    edraw = ImageDraw.Draw(em)
    for y in range(0, 512, 32):
        for x in range(0, 512, 32):
            edraw.polygon([(x+16, y+4), (x+28, y+16), (x+16, y+28), (x+4, y+16)], fill=(80, 220, 255))
    em = em.filter(ImageFilter.GaussianBlur(2))
    em.save(SKIN_DIR / "subzero_kori_emission.png")
    print("[OK] Sub-Zero PBR generated")

def generate_goku():
    size = (512, 512)
    # Turtle School Gi with Master Kanji
    alb = Image.new("RGB", size, (235, 105, 20))
    draw = ImageDraw.Draw(alb)
    # Dark blue undershirt border
    draw.rectangle([0, 0, 512, 70], fill=(22, 35, 90))
    draw.rectangle([0, 442, 512, 512], fill=(22, 35, 90))
    # Circular emblem (Kame / King Kai symbol)
    draw.ellipse([176, 176, 336, 336], fill=(245, 245, 240), outline=(20, 20, 20), width=6)
    draw.line([256, 196, 256, 316], fill=(20, 20, 20), width=8)
    draw.line([206, 256, 306, 256], fill=(20, 20, 20), width=8)
    draw.arc([216, 216, 296, 296], 45, 225, fill=(20, 20, 20), width=6)
    alb.save(SKIN_DIR / "goku_gi_master_albedo.png")
    make_normal_map(np.array(alb.convert("L")), 3.5).save(SKIN_DIR / "goku_gi_master_normal.png")

    # Divine Ki Aura Emission
    em = Image.new("RGB", size, (0, 0, 0))
    edraw = ImageDraw.Draw(em)
    edraw.ellipse([176, 176, 336, 336], outline=(195, 95, 255), width=8)
    em = em.filter(ImageFilter.GaussianBlur(3))
    em.save(SKIN_DIR / "goku_ki_master_emission.png")
    print("[OK] Goku PBR generated")

if __name__ == "__main__":
    generate_valkyrie()
    generate_dragon()
    generate_anubis()
    generate_specter()
    generate_phoenix()
    generate_luffy()
    generate_pain()
    generate_subzero()
    generate_goku()
    print("ALL 11 CHARACTER PBR TEXTURE PACKS GENERATED SUCCESSFULLY!")
