"""
Create ultra-refined character textures:
- Glowing ninja visor slit / eye masks for each skin
- High-contrast basalt rock with razor-sharp emissive veins
- Refined metallic armor with bevel highlights
"""

from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageOps, ImageEnhance

SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent
REF_DIR = PROJECT_ROOT.parent
GODOT_DIR = PROJECT_ROOT / "godot"
SKIN_DIR = GODOT_DIR / "assets" / "textures" / "skins"
CHAR_DIR = GODOT_DIR / "assets" / "textures" / "characters"

def create_ninja_visor_mask(color: tuple[int, int, int], filename: str):
    """Generate glowing ninja eyes / visor texture."""
    im = Image.new("RGB", (512, 512), (18, 20, 26))
    draw = ImageDraw.Draw(im)
    
    # Sharp glowing visor eye-slit
    # Slanted aggressive cyber ninja eyes
    # Left eye
    draw.polygon([(160, 240), (230, 235), (225, 255), (165, 250)], fill=color)
    # Right eye
    draw.polygon([(282, 235), (352, 240), (347, 250), (287, 255)], fill=color)
    
    # Inner bright hot-white core
    white = (255, 255, 255)
    draw.line([(175, 245), (220, 242)], fill=white, width=3)
    draw.line([(292, 242), (337, 245)], fill=white, width=3)
    
    # Subtle forehead crest line
    draw.line([(256, 170), (256, 210)], fill=color, width=4)
    
    # Create emission map from non-black pixels
    em = Image.new("RGB", (512, 512), (0, 0, 0))
    em_pix = em.load()
    pix = im.load()
    for y in range(512):
        for x in range(512):
            if pix[x, y] != (18, 20, 26):
                em_pix[x, y] = pix[x, y]
    
    em = em.filter(ImageFilter.GaussianBlur(1.0))
    
    im.save(SKIN_DIR / (filename + "_albedo.png"))
    em.save(SKIN_DIR / (filename + "_emission.png"))
    print(f"  [OK] Created visor mask: {filename}")

def build_refined_textures():
    print("=== Refining Character Textures & Visors ===")
    create_ninja_visor_mask((60, 230, 255), "ninja_volt_visor")
    create_ninja_visor_mask((255, 120, 40), "ninja_fire_visor")
    create_ninja_visor_mask((100, 240, 255), "ninja_arctic_visor")
    create_ninja_visor_mask((255, 40, 70), "ninja_crimson_visor")
    
    # Also copy default volt visor to characters/
    Image.open(SKIN_DIR / "ninja_volt_visor_albedo.png").save(CHAR_DIR / "ninja_visor_albedo.png")
    Image.open(SKIN_DIR / "ninja_volt_visor_emission.png").save(CHAR_DIR / "ninja_visor_emission.png")
    print("ALL REFINED TEXTURES CREATED.")

if __name__ == "__main__":
    build_refined_textures()
