import math
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate")
GODOT_TEX = ROOT / "godot" / "assets" / "textures" / "characters"
ART_TEX = ROOT / "art" / "textures" / "faces"


def create_goku_face():
    """Authentic Dragon Ball Son Goku face: Toriyama eyes, intense brow lines, determined smirk."""
    size = 1024
    img = Image.new("RGBA", (size, size), (250, 222, 198, 255)) # Healthy martial artist tan skin
    draw = ImageDraw.Draw(img)

    # Soft ambient jaw shading
    shade = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(shade)
    sdraw.polygon([(250, 720), (512, 940), (774, 720), (512, 850)], fill=(220, 185, 160, 90))
    shade = shade.filter(ImageFilter.GaussianBlur(14))
    img.alpha_composite(shade)
    draw = ImageDraw.Draw(img)

    # Dragon Ball Eyes (Angular, sharp bottom-cut, intense focus)
    for center_x, flip in [(365, -1), (659, 1)]:
        cy = 475
        ew, eh = 80, 85

        # Eye white (sclera)
        draw.polygon([
            (center_x - flip * 80, cy - 35),
            (center_x, cy - eh + 15),
            (center_x + flip * 80, cy - 45),
            (center_x + flip * 75, cy + 20),
            (center_x - flip * 10, cy + 35),
            (center_x - flip * 70, cy + 15)
        ], fill=(255, 255, 255, 255))

        # Sharp Iris / Pupil: Pure intense Toriyama black with silver-purple reflection (Ultra Ego style)
        draw.polygon([
            (center_x - flip * 15, cy - 35),
            (center_x + flip * 25, cy - 35),
            (center_x + flip * 22, cy + 20),
            (center_x - flip * 12, cy + 20)
        ], fill=(130, 40, 210, 255)) # Glowing purple outer rim
        draw.ellipse((center_x - 14, cy - 25, center_x + 14, cy + 12), fill=(15, 10, 25, 255))
        # White highlight glint
        draw.ellipse((center_x + flip * 5 - 4, cy - 18 - 4, center_x + flip * 5 + 4, cy - 18 + 4), fill=(255, 255, 255, 255))

        # Heavy Black Dragon Ball Eye Outlines
        # Top heavy lash line
        draw.line([
            (center_x - flip * 85, cy - 32),
            (center_x - flip * 10, cy - eh + 12),
            (center_x + flip * 85, cy - 45)
        ], fill=(15, 12, 18, 255), width=10)

        # Bottom corner outline
        draw.line([
            (center_x - flip * 65, cy + 18),
            (center_x - flip * 10, cy + 36),
            (center_x + flip * 75, cy + 20)
        ], fill=(15, 12, 18, 255), width=7)

        # Outer vertical corner
        draw.line([
            (center_x + flip * 85, cy - 45),
            (center_x + flip * 75, cy + 20)
        ], fill=(15, 12, 18, 255), width=6)

        # Intense Dragon Ball Furrowed Eyebrow (Vibrant Deep Purple)
        brow_pts = [
            (center_x - flip * 85, cy - eh - 15),
            (center_x - flip * 10, cy - eh - 32),
            (center_x + flip * 90, cy - eh - 10)
        ]
        draw.line(brow_pts, fill=(125, 25, 215, 255), width=14, joint="curve")
        draw.line(brow_pts, fill=(60, 10, 110, 255), width=4, joint="curve") # dark bottom ridge

        # Eye socket lower contour line
        draw.line([(center_x - flip * 40, cy + 50), (center_x + flip * 45, cy + 42)], fill=(200, 160, 135, 220), width=4)

    # Iconic Toriyama Brow Tension Lines (Between the eyes, center x=512)
    draw.line([(500, 400), (500, 460)], fill=(185, 140, 115, 255), width=4)
    draw.line([(524, 400), (524, 460)], fill=(185, 140, 115, 255), width=4)
    draw.line([(505, 430), (519, 430)], fill=(185, 140, 115, 255), width=3)

    # Iconic Dragon Ball Nose (Triangular angled nose shadow and bridge point)
    draw.polygon([(512, 580), (528, 620), (508, 624)], fill=(185, 135, 110, 255))
    draw.line([(512, 580), (528, 620)], fill=(140, 95, 75, 255), width=4)

    # Goku's Confident Saiyan Smirk / Mouth
    draw.line([(445, 705), (512, 700), (575, 688)], fill=(45, 25, 25, 255), width=7)
    draw.line([(572, 688), (580, 682)], fill=(45, 25, 25, 255), width=5) # smirk corner upturn
    draw.line([(485, 725), (535, 725)], fill=(195, 145, 120, 255), width=5) # lower lip shadow line

    # Cheek muscle accent lines
    draw.line([(310, 560), (330, 575)], fill=(210, 165, 140, 200), width=4)
    draw.line([(714, 560), (694, 575)], fill=(210, 165, 140, 200), width=4)

    return img


if __name__ == "__main__":
    img = create_goku_face()
    p1 = ART_TEX / "face_goku.png"
    p2 = GODOT_TEX / "face_goku.png"
    img.save(p1, "PNG")
    img.save(p2, "PNG")
    print(f"GOKU_FACE_SAVED_OK: {p2}")
