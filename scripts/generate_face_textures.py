"""
Generate authentic, high-resolution (1024x1024) character face and skin textures.
Features:
- Anime facial features: layered multi-tone irises, pupils, specular glints, bold lash lines, eyelids
- Soft airbrushed cheek blush, delicate nose highlights, glossy lips
- Cybernetics, gold filigree, masks, markings, and high-detail PBR accents
"""

import math
import numpy as np
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate")
GODOT_TEX = ROOT / "godot" / "assets" / "textures" / "characters"
ART_TEX = ROOT / "art" / "textures" / "faces"
GODOT_TEX.mkdir(parents=True, exist_ok=True)
ART_TEX.mkdir(parents=True, exist_ok=True)


def create_valkyrie_face():
    """Beautiful radiant anime paladin face (Valkyrie Aura)."""
    size = 1024
    img = Image.new("RGBA", (size, size), (252, 235, 228, 255))
    draw = ImageDraw.Draw(img)

    # Soft ambient facial shading (subtle gradient towards chin and sides)
    for r in range(400, 550, 5):
        alpha = int((r - 400) * 0.35)
        # soft shadow around edge of face
        draw.ellipse((512 - r, 512 - r + 30, 512 + r, 512 + r + 30), outline=(230, 205, 195, alpha), width=5)

    # Rosy airbrushed cheek blush
    blush_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    bdraw = ImageDraw.Draw(blush_layer)
    bdraw.ellipse((270, 540, 430, 640), fill=(255, 140, 150, 110))
    bdraw.ellipse((594, 540, 754, 640), fill=(255, 140, 150, 110))
    # Extra cute blush strokes
    for i in range(3):
        bdraw.line([(310 + i * 25, 595), (325 + i * 25, 575)], fill=(255, 100, 120, 140), width=4)
        bdraw.line([(634 + i * 25, 595), (649 + i * 25, 575)], fill=(255, 100, 120, 140), width=4)
    blush_layer = blush_layer.filter(ImageFilter.GaussianBlur(22))
    img.alpha_composite(blush_layer)
    draw = ImageDraw.Draw(img)

    # Eyes (Symmetrical: left around x=360, right around x=664, y=470)
    for center_x, flip in [(360, -1), (664, 1)]:
        cy = 470
        ew, eh = 85, 115

        # Sclera (eye white)
        draw.ellipse((center_x - ew, cy - eh, center_x + ew, cy + eh), fill=(250, 252, 255, 255))
        # Upper shadow inside sclera
        draw.chord((center_x - ew, cy - eh, center_x + ew, cy + eh), 180, 360, fill=(215, 225, 240, 180))

        # Iris: outer ring (deep sapphire)
        iw, ih = 65, 95
        draw.ellipse((center_x - iw, cy - ih + 5, center_x + iw, cy + ih + 5), fill=(20, 50, 140, 255))
        # Iris: mid gradient (vibrant electric azure)
        draw.ellipse((center_x - iw + 8, cy - ih + 18, center_x + iw - 8, cy + ih - 2), fill=(35, 130, 235, 255))
        # Iris: lower bright highlight crescent (celestial cyan)
        draw.ellipse((center_x - iw + 16, cy + 10, center_x + iw - 16, cy + ih - 8), fill=(100, 215, 255, 255))
        # Pupil: dark navy/black
        draw.ellipse((center_x - 22, cy - 30, center_x + 22, cy + 30), fill=(8, 15, 45, 255))

        # Big anime specular glints (top-right and lower-left)
        draw.ellipse((center_x + flip * 15 - 16, cy - 45 - 20, center_x + flip * 15 + 16, cy - 45 + 20), fill=(255, 255, 255, 255))
        draw.ellipse((center_x - flip * 18 - 8, cy + 25 - 10, center_x - flip * 18 + 8, cy + 25 + 10), fill=(255, 255, 255, 220))
        draw.ellipse((center_x + flip * 22, cy + 15, center_x + flip * 22 + 6, cy + 15 + 6), fill=(255, 255, 255, 200))

        # Bold upper anime lash line (thick black curve with elegant wing)
        lash_pts = [
            (center_x - ew - 15, cy - 10),
            (center_x - ew + 10, cy - eh + 10),
            (center_x, cy - eh - 8),
            (center_x + ew - 10, cy - eh + 15),
            (center_x + ew + 20, cy - 5),
            (center_x + ew + 32, cy - 25), # winged tip
        ]
        if flip == -1: # mirror for left eye
            lash_pts = [(center_x - (p[0] - center_x), p[1]) for p in lash_pts]
        draw.line(lash_pts, fill=(25, 20, 30, 255), width=10, joint="curve")
        # Eyelash strands
        wing_tip = lash_pts[-1]
        draw.line([lash_pts[-2], (wing_tip[0] + flip * 8, wing_tip[1] - 8)], fill=(25, 20, 30, 255), width=6)

        # Lower lash line (soft, subtle)
        draw.arc((center_x - ew + 15, cy - eh + 30, center_x + ew - 15, cy + eh + 5), 20, 160, fill=(90, 75, 85, 220), width=4)

        # Double eyelid crease line
        draw.arc((center_x - ew + 10, cy - eh - 35, center_x + ew - 10, cy - eh + 15), 200, 340, fill=(180, 140, 135, 200), width=4)

        # Elegant golden blonde arched eyebrow
        brow_pts = [
            (center_x - flip * 75, cy - eh - 55),
            (center_x - flip * 15, cy - eh - 75),
            (center_x + flip * 55, cy - eh - 80),
            (center_x + flip * 95, cy - eh - 60),
        ]
        draw.line(brow_pts, fill=(225, 185, 75, 255), width=8, joint="curve")

    # Delicate anime nose (subtle nostril/tip shadow and white highlight)
    draw.ellipse((508, 608, 516, 616), fill=(210, 165, 155, 220))
    draw.line([(510, 560), (510, 605)], fill=(255, 255, 255, 120), width=3) # bridge highlight

    # Glossy anime lips (soft pink gradient with cupid's bow and shine)
    draw.arc((475, 680, 549, 715), 20, 160, fill=(220, 125, 135, 255), width=6) # mouth line
    # Lower lip soft pink fullness
    lip_fill = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    ldraw = ImageDraw.Draw(lip_fill)
    ldraw.ellipse((482, 698, 542, 725), fill=(245, 140, 155, 140))
    ldraw.ellipse((502, 706, 522, 716), fill=(255, 255, 255, 180)) # lip shine
    lip_fill = lip_fill.filter(ImageFilter.GaussianBlur(4))
    img.alpha_composite(lip_fill)
    draw = ImageDraw.Draw(img)

    # Forehead winged golden tiara circlet decoration
    draw.rectangle((100, 180, 924, 230), fill=(245, 200, 60, 255))
    draw.line([(100, 180), (924, 180)], fill=(255, 240, 140, 255), width=5) # highlight
    draw.line([(100, 230), (924, 230)], fill=(180, 130, 20, 255), width=5)  # shadow
    # Center holy sapphire jewel
    draw.polygon([(512, 160), (545, 205), (512, 250), (479, 205)], fill=(40, 150, 255, 255))
    draw.polygon([(512, 175), (535, 205), (512, 235), (489, 205)], fill=(130, 220, 255, 255))

    return img


def create_ninja_face():
    """Authentic cyber-shinobi face (Volt Shadow): tactical visor optics & dark fabric mask."""
    size = 1024
    img = Image.new("RGBA", (size, size), (25, 30, 42, 255)) # Dark stealth background
    draw = ImageDraw.Draw(img)

    # Skin visible in eye band area (y: 350 - 580)
    skin_band = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(skin_band)
    sdraw.rectangle((160, 360, 864, 580), fill=(215, 175, 150, 255))
    # Soft skin shading
    sdraw.rectangle((160, 360, 864, 400), fill=(185, 145, 120, 180))
    sdraw.rectangle((160, 540, 864, 580), fill=(175, 135, 110, 180))
    skin_band = skin_band.filter(ImageFilter.GaussianBlur(8))
    img.alpha_composite(skin_band)
    draw = ImageDraw.Draw(img)

    # Glowing Cyan Tactical Assassin Eyes (y = 470)
    for center_x, flip in [(370, -1), (654, 1)]:
        cy = 470
        ew, eh = 75, 55

        # Eye socket shadow
        draw.ellipse((center_x - ew - 10, cy - eh - 10, center_x + ew + 10, cy + eh + 10), fill=(40, 35, 45, 200))

        # Sharp cyber iris: glowing electric cyan
        draw.polygon([
            (center_x - ew, cy),
            (center_x - 10, cy - eh + 10),
            (center_x + ew - 10, cy - 5),
            (center_x + 10, cy + eh - 15)
        ], fill=(0, 230, 255, 255))

        # Core bright plasma slit
        draw.ellipse((center_x - 28, cy - 14, center_x + 28, cy + 14), fill=(200, 255, 255, 255))
        draw.line([(center_x - 45, cy), (center_x + 45, cy)], fill=(255, 255, 255, 255), width=5)

        # Heavy angled ninja eye liner (sharp angular slit)
        draw.line([
            (center_x - flip * 85, cy + 10),
            (center_x - flip * 20, cy - 35),
            (center_x + flip * 80, cy - 25),
            (center_x + flip * 105, cy - 5)
        ], fill=(12, 14, 18, 255), width=10)

        # Intense furrowed brow
        draw.line([
            (center_x - flip * 70, cy - 55),
            (center_x - flip * 10, cy - 65),
            (center_x + flip * 85, cy - 50)
        ], fill=(20, 22, 28, 255), width=12)

        # Tactical HUD markings beneath eye (cyan telemetry lines)
        draw.line([(center_x - 40, cy + 38), (center_x + 30, cy + 38)], fill=(0, 220, 255, 200), width=3)
        draw.line([(center_x + 30, cy + 38), (center_x + 45, cy + 50)], fill=(0, 220, 255, 200), width=3)
        draw.rectangle((center_x - 35, cy + 45, center_x - 20, cy + 50), fill=(0, 240, 255, 220))

    # Forehead Hitai-ate Bandana Plate (Metal Protector)
    draw.rectangle((120, 160, 904, 340), fill=(45, 52, 65, 255)) # Steel plate
    draw.rectangle((120, 160, 904, 180), fill=(140, 155, 175, 255)) # Top bevel highlight
    draw.rectangle((120, 320, 904, 340), fill=(25, 30, 40, 255))   # Bottom bevel shadow
    # Corner rivets
    for rx, ry in [(160, 200), (864, 200), (160, 300), (864, 300)]:
        draw.ellipse((rx - 12, ry - 12, rx + 12, ry + 12), fill=(180, 195, 210, 255))
        draw.ellipse((rx - 8, ry - 8, rx + 8, ry + 8), fill=(30, 35, 45, 255))
    # Engraved Clan Emblem (Golden Lightning / Shuriken Kanji)
    draw.polygon([(512, 190), (560, 250), (512, 310), (464, 250)], fill=(245, 195, 50, 255))
    draw.polygon([(512, 210), (540, 250), (512, 290), (484, 250)], fill=(30, 35, 45, 255))
    draw.line([(512, 185), (512, 315)], fill=(255, 220, 90, 255), width=5)

    # Shinobi Half-Mask (Lower Face y: 570 - 1000)
    draw.rectangle((140, 570, 884, 1000), fill=(18, 20, 26, 255))
    # Mask edge seams with double stitching
    draw.line([(140, 570), (884, 570)], fill=(80, 95, 120, 255), width=8)
    draw.line([(140, 582), (884, 582)], fill=(35, 40, 50, 255), width=4)
    # Hexagonal breath ventilation grille in center
    for row in range(5):
        for col in range(7):
            gx = 430 + col * 24 + (12 if row % 2 else 0)
            gy = 680 + row * 22
            draw.ellipse((gx - 6, gy - 6, gx + 6, gy + 6), fill=(0, 220, 255, 180)) # Glowing blue intake
            draw.ellipse((gx - 4, gy - 4, gx + 4, gy + 4), fill=(10, 15, 22, 255))

    return img


def create_phoenix_face():
    """Regal Phoenix Empress face: amber-gold fiery eyes, golden forehead crest, ruby lips."""
    size = 1024
    img = Image.new("RGBA", (size, size), (252, 228, 214, 255))
    draw = ImageDraw.Draw(img)

    # Warm radiant peach blush
    blush = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    bdraw = ImageDraw.Draw(blush)
    bdraw.ellipse((250, 530, 440, 640), fill=(255, 130, 90, 110))
    bdraw.ellipse((584, 530, 774, 640), fill=(255, 130, 90, 110))
    blush = blush.filter(ImageFilter.GaussianBlur(24))
    img.alpha_composite(blush)
    draw = ImageDraw.Draw(img)

    # Fierce amber/ruby eyes
    for center_x, flip in [(360, -1), (664, 1)]:
        cy = 475
        ew, eh = 82, 105

        # Sclera
        draw.ellipse((center_x - ew, cy - eh, center_x + ew, cy + eh), fill=(255, 252, 250, 255))
        draw.chord((center_x - ew, cy - eh, center_x + ew, cy + eh), 180, 360, fill=(240, 210, 200, 160))

        # Iris: fiery crimson outer ring
        iw, ih = 62, 88
        draw.ellipse((center_x - iw, cy - ih + 8, center_x + iw, cy + ih + 8), fill=(185, 20, 10, 255))
        # Mid iris: brilliant molten gold/amber
        draw.ellipse((center_x - iw + 8, cy - ih + 18, center_x + iw - 8, cy + ih), fill=(255, 160, 20, 255))
        # Lower radiant highlight
        draw.ellipse((center_x - iw + 16, cy + 12, center_x + iw - 16, cy + ih - 6), fill=(255, 230, 110, 255))
        # Pupil: deep volcanic ruby
        draw.ellipse((center_x - 18, cy - 25, center_x + 18, cy + 25), fill=(40, 5, 5, 255))

        # Glints
        draw.ellipse((center_x + flip * 14 - 14, cy - 42 - 16, center_x + flip * 14 + 14, cy - 42 + 16), fill=(255, 255, 255, 255))
        draw.ellipse((center_x - flip * 16 - 6, cy + 22 - 7, center_x - flip * 16 + 6, cy + 22 + 7), fill=(255, 255, 255, 210))

        # Crimson phoenix wing eyeliner extending outward
        draw.line([
            (center_x - flip * 80, cy),
            (center_x - flip * 10, cy - eh + 5),
            (center_x + flip * 75, cy - eh + 20),
            (center_x + flip * 125, cy - 35) # dramatic winged flare
        ], fill=(160, 15, 20, 255), width=12)
        # Inner black lash line
        draw.line([
            (center_x - flip * 75, cy),
            (center_x, cy - eh + 8),
            (center_x + flip * 85, cy - 5)
        ], fill=(20, 15, 15, 255), width=7)

        # Eyebrows (sharp arch in warm dark auburn)
        draw.line([
            (center_x - flip * 70, cy - eh - 50),
            (center_x, cy - eh - 72),
            (center_x + flip * 90, cy - eh - 55)
        ], fill=(120, 35, 20, 255), width=8)

    # Forehead Golden Phoenix Crest (Flame Mark)
    f_mark = [
        (512, 220), (528, 270), (548, 290), (524, 310),
        (512, 360), (500, 310), (476, 290), (496, 270)
    ]
    draw.polygon(f_mark, fill=(245, 195, 45, 255))
    draw.ellipse((504, 280, 520, 296), fill=(255, 50, 20, 255)) # ruby center gem

    # Nose
    draw.ellipse((508, 610, 516, 618), fill=(215, 150, 130, 220))

    # Bold Ruby Lips
    draw.arc((472, 682, 552, 720), 20, 160, fill=(185, 25, 40, 255), width=7)
    # Upper lip fullness
    draw.polygon([(485, 690), (502, 680), (512, 686), (522, 680), (539, 690), (512, 695)], fill=(215, 40, 60, 230))
    # Lower lip fullness & shine
    draw.ellipse((484, 698, 540, 728), fill=(230, 50, 70, 200))
    draw.ellipse((504, 706, 520, 716), fill=(255, 210, 215, 220)) # shine

    # Golden crown rim across top
    draw.rectangle((80, 140, 944, 190), fill=(235, 185, 40, 255))
    draw.line([(80, 140), (944, 140)], fill=(255, 235, 120, 255), width=5)

    return img


def create_dragon_face():
    """Fierce Cyber Dragon Slayer face: amber reptilian eyes, draconic war paint, scale armor."""
    size = 1024
    img = Image.new("RGBA", (size, size), (220, 180, 155, 255)) # Weathered warrior skin
    draw = ImageDraw.Draw(img)

    # Draconic Crimson War Paint across cheeks
    war_paint = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    wdraw = ImageDraw.Draw(war_paint)
    for flip in [-1, 1]:
        cx = 512 + flip * 220
        wdraw.polygon([(cx, 520), (cx + flip * 140, 480), (cx + flip * 180, 510), (cx + flip * 20, 560)], fill=(190, 25, 20, 200))
        wdraw.line([(cx - flip * 30, 545), (cx + flip * 120, 520)], fill=(255, 60, 30, 220), width=6)
    war_paint = war_paint.filter(ImageFilter.GaussianBlur(5))
    img.alpha_composite(war_paint)
    draw = ImageDraw.Draw(img)

    # Fierce Dragon Eyes (Golden Slit Eyes)
    for center_x, flip in [(360, -1), (664, 1)]:
        cy = 470
        ew, eh = 85, 75

        # Dark eye socket
        draw.ellipse((center_x - ew - 5, cy - eh - 5, center_x + ew + 5, cy + eh + 5), fill=(45, 35, 30, 255))
        # Fiery amber sclera
        draw.ellipse((center_x - ew, cy - eh, center_x + ew, cy + eh), fill=(255, 185, 35, 255))

        # Vertical dragon slit pupil
        draw.polygon([
            (center_x, cy - eh + 15),
            (center_x + 12, cy),
            (center_x, cy + eh - 15),
            (center_x - 12, cy)
        ], fill=(15, 10, 8, 255))
        # Inner slit plasma glow
        draw.line([(center_x, cy - eh + 25), (center_x, cy + eh - 25)], fill=(255, 90, 10, 255), width=4)

        # Glints
        draw.ellipse((center_x + flip * 18 - 8, cy - 25 - 8, center_x + flip * 18 + 8, cy - 25 + 8), fill=(255, 255, 255, 255))

        # Heavy battle-hardened brows and scars
        draw.line([
            (center_x - flip * 80, cy - 45),
            (center_x, cy - 65),
            (center_x + flip * 85, cy - 45)
        ], fill=(45, 30, 25, 255), width=14)

    # Dragon battle scar across right cheek (with molten gold seam)
    draw.line([(600, 380), (680, 590)], fill=(120, 30, 20, 220), width=8)
    draw.line([(602, 382), (678, 588)], fill=(255, 185, 30, 240), width=3) # molten gold crack

    # Nose
    draw.ellipse((506, 605, 518, 617), fill=(160, 110, 90, 255))

    # Resolute mouth
    draw.line([(460, 695), (564, 695)], fill=(90, 45, 40, 255), width=6)

    # Dragonscale Armor Gorget on lower face / neck
    draw.rectangle((100, 780, 924, 1000), fill=(30, 32, 38, 255))
    # Scales
    for row in range(3):
        for col in range(9):
            sx = 160 + col * 80 + (40 if row % 2 else 0)
            sy = 820 + row * 60
            draw.polygon([(sx, sy), (sx + 35, sy + 45), (sx - 35, sy + 45)], fill=(45, 48, 58, 255))
            draw.line([(sx, sy), (sx + 35, sy + 45)], fill=(245, 190, 45, 255), width=3) # Gold scale rim

    return img


def create_anubis_face():
    """Sleek Egyptian Jackal deity face: matte obsidian, golden Horus eyeliner, lapis eyes."""
    size = 1024
    img = Image.new("RGBA", (size, size), (20, 22, 28, 255)) # Matte Obsidian Black
    draw = ImageDraw.Draw(img)

    # Eyes of Horus: Golden Egyptian eyeliner & glowing lapis cyan eyes
    for center_x, flip in [(350, -1), (674, 1)]:
        cy = 470
        ew, eh = 85, 60

        # Celestial Lapis Lazuli / Cyan glowing iris
        draw.ellipse((center_x - ew, cy - eh, center_x + ew, cy + eh), fill=(0, 210, 255, 255))
        # Inner white plasma core
        draw.ellipse((center_x - 30, cy - 18, center_x + 30, cy + 18), fill=(210, 255, 255, 255))

        # Pure Royal Gold Egyptian Eyeliner (Eye of Horus styling)
        draw.line([
            (center_x - flip * 80, cy),
            (center_x, cy - eh - 12),
            (center_x + flip * 85, cy - 8),
            (center_x + flip * 135, cy - 25), # long regal wing
            (center_x + flip * 165, cy - 20)
        ], fill=(245, 200, 50, 255), width=14)
        # Teardrop line beneath eye
        draw.line([
            (center_x, cy + eh),
            (center_x + flip * 15, cy + eh + 50),
            (center_x + flip * 10, cy + eh + 90)
        ], fill=(245, 200, 50, 255), width=10)

    # Royal Golden Headdress (Nemes stripes on upper head)
    for i in range(7):
        y = 120 + i * 35
        col = (245, 200, 50, 255) if i % 2 == 0 else (20, 60, 140, 255) # Gold & Royal Lapis
        draw.rectangle((100, y, 924, y + 30), fill=col)

    # Golden Jackal Snout Line & Fangs
    draw.polygon([(512, 580), (540, 720), (512, 770), (484, 720)], fill=(32, 35, 45, 255))
    draw.line([(512, 580), (512, 770)], fill=(245, 200, 50, 255), width=4)
    # Golden fangs
    draw.polygon([(465, 740), (480, 785), (495, 740)], fill=(245, 205, 60, 255))
    draw.polygon([(529, 740), (544, 785), (559, 740)], fill=(245, 205, 60, 255))

    return img


def generate_all_textures():
    print("Generating authentic character face textures...")
    valkyrie = create_valkyrie_face()
    ninja = create_ninja_face()
    phoenix = create_phoenix_face()
    dragon = create_dragon_face()
    anubis = create_anubis_face()

    textures = {
        "face_valkyrie.png": valkyrie,
        "face_ninja.png": ninja,
        "face_phoenix.png": phoenix,
        "face_dragon.png": dragon,
        "face_anubis.png": anubis,
    }

    for name, img in textures.items():
        # Save to art
        p1 = ART_TEX / name
        img.save(p1, "PNG")
        # Save to godot textures
        p2 = GODOT_TEX / name
        img.save(p2, "PNG")
        print(f"  [OK] Saved {name} -> {p2} ({p2.stat().st_size} bytes)")

    print("ALL_FACE_TEXTURES_GENERATED_OK")


if __name__ == "__main__":
    generate_all_textures()
