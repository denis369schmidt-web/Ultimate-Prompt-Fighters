import math
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

out_dir = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate\godot\assets\textures\vfx")
out_dir.mkdir(parents=True, exist_ok=True)

def create_slash(filename, color_core, color_glow, curve_dir=1):
    w, h = 512, 512
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Multi-layered crescent slash arc
    steps = 180
    cx, cy = 256, 256
    r = 200

    # Wide glow layer
    for i in range(steps):
        angle = math.radians(20 + i * 0.9 * curve_dir)
        thick = math.sin(i / steps * math.pi) * 36
        x = cx + math.cos(angle) * r
        y = cy + math.sin(angle) * (r * 0.8)
        alpha = int(220 * math.sin(i / steps * math.pi))
        col = (*color_glow, alpha)
        draw.ellipse([x - thick, y - thick, x + thick, y + thick], fill=col)

    # Core sharp blade layer
    for i in range(steps):
        angle = math.radians(20 + i * 0.9 * curve_dir)
        thick = math.sin(i / steps * math.pi) * 12
        x = cx + math.cos(angle) * r
        y = cy + math.sin(angle) * (r * 0.8)
        alpha = int(255 * math.sin(i / steps * math.pi))
        col = (*color_core, alpha)
        draw.ellipse([x - thick, y - thick, x + thick, y + thick], fill=col)

    # Blur slightly for smooth glow
    glow = img.filter(ImageFilter.GaussianBlur(radius=6))
    final = Image.alpha_composite(glow, img)
    final.save(out_dir / filename)
    print(f"Generated {filename}")

def create_beam(filename, color_core, color_glow):
    w, h = 512, 256
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Horizontal piercing energy beam with tapering head
    for x in range(w):
        progress = x / w
        thick_glow = (32 + math.sin(progress * math.pi) * 28)
        alpha = int(240 * (1.0 - progress * 0.4))
        draw.line([(x, 128 - thick_glow), (x, 128 + thick_glow)], fill=(*color_glow, alpha), width=2)

    for x in range(w):
        progress = x / w
        thick_core = (12 + math.sin(progress * math.pi) * 10)
        alpha = int(255 * (1.0 - progress * 0.2))
        draw.line([(x, 128 - thick_core), (x, 128 + thick_core)], fill=(*color_core, alpha), width=2)

    glow = img.filter(ImageFilter.GaussianBlur(radius=8))
    final = Image.alpha_composite(glow, img)
    final.save(out_dir / filename)
    print(f"Generated {filename}")

def create_shockwave(filename, color_core, color_glow):
    w, h = 512, 512
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = 256, 256

    # Concentric expanding energy shockwaves
    for r in [60, 120, 180, 220]:
        thick = 14
        alpha = int(255 * (1.0 - r / 250.0))
        draw.ellipse([cx - r, cy - r, cx + r, cy + r], outline=(*color_glow, alpha), width=thick)
        draw.ellipse([cx - r, cy - r, cx + r, cy + r], outline=(*color_core, alpha), width=6)

    # Radial pressure spikes
    for a_deg in range(0, 360, 15):
        rad = math.radians(a_deg)
        x1 = cx + math.cos(rad) * 40
        y1 = cy + math.sin(rad) * 40
        x2 = cx + math.cos(rad) * 235
        y2 = cy + math.sin(rad) * 235
        draw.line([(x1, y1), (x2, y2)], fill=(*color_core, 180), width=4)

    glow = img.filter(ImageFilter.GaussianBlur(radius=6))
    final = Image.alpha_composite(glow, img)
    final.save(out_dir / filename)
    print(f"Generated {filename}")

def create_spiral(filename, color_core, color_glow):
    w, h = 512, 512
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = 256, 256

    # Swirling vortex spirals
    for arm in range(4):
        offset = arm * (math.pi / 2.0)
        points = []
        for t in range(120):
            theta = offset + t * 0.12
            r = t * 1.8 + 10
            x = cx + math.cos(theta) * r
            y = cy + math.sin(theta) * r
            points.append((x, y))
        for idx in range(len(points) - 1):
            alpha = int(255 * (idx / len(points)))
            draw.line([points[idx], points[idx+1]], fill=(*color_glow, alpha), width=18)
            draw.line([points[idx], points[idx+1]], fill=(*color_core, alpha), width=8)

    # Core orb
    draw.ellipse([cx - 45, cy - 45, cx + 45, cy + 45], fill=(*color_core, 255))
    glow = img.filter(ImageFilter.GaussianBlur(radius=8))
    final = Image.alpha_composite(glow, img)
    final.save(out_dir / filename)
    print(f"Generated {filename}")

def create_lightning(filename, color_core, color_glow):
    w, h = 512, 512
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = 256, 256

    import random
    random.seed(42)

    for branch in range(8):
        angle = branch * (2 * math.pi / 8.0)
        cur_x, cur_y = cx, cy
        for step in range(12):
            next_dist = (step + 1) * 18
            cur_angle = angle + random.uniform(-0.35, 0.35)
            nx = cx + math.cos(cur_angle) * next_dist
            ny = cy + math.sin(cur_angle) * next_dist
            alpha = int(255 * (1.0 - step / 14.0))
            draw.line([(cur_x, cur_y), (nx, ny)], fill=(*color_glow, alpha), width=12)
            draw.line([(cur_x, cur_y), (nx, ny)], fill=(*color_core, alpha), width=5)
            cur_x, cur_y = nx, ny

    glow = img.filter(ImageFilter.GaussianBlur(radius=6))
    final = Image.alpha_composite(glow, img)
    final.save(out_dir / filename)
    print(f"Generated {filename}")

def create_crystal(filename, color_core, color_glow):
    w, h = 512, 512
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = 256, 256

    for a_deg in range(0, 360, 30):
        rad = math.radians(a_deg)
        length = 210 if a_deg % 60 == 0 else 140
        tip_x = cx + math.cos(rad) * length
        tip_y = cy + math.sin(rad) * length
        p_left_x = cx + math.cos(rad - 0.15) * (length * 0.4)
        p_left_y = cy + math.sin(rad - 0.15) * (length * 0.4)
        p_right_x = cx + math.cos(rad + 0.15) * (length * 0.4)
        p_right_y = cy + math.sin(rad + 0.15) * (length * 0.4)

        poly = [(cx, cy), (p_left_x, p_left_y), (tip_x, tip_y), (p_right_x, p_right_y)]
        draw.polygon(poly, fill=(*color_glow, 190), outline=(*color_core, 255))

    glow = img.filter(ImageFilter.GaussianBlur(radius=6))
    final = Image.alpha_composite(glow, img)
    final.save(out_dir / filename)
    print(f"Generated {filename}")

# Generate all 12 assets
create_slash("slash_katana.png", (255, 255, 255), (100, 200, 255))
create_slash("slash_ice.png", (220, 250, 255), (60, 180, 255))
create_slash("slash_fire.png", (255, 240, 180), (255, 90, 20))
create_slash("slash_wind.png", (230, 255, 240), (50, 230, 140))
create_slash("slash_blood.png", (255, 180, 180), (220, 20, 40))

create_beam("blast_beam_wide.png", (255, 255, 255), (40, 170, 255))
create_beam("blast_beam_needle.png", (255, 220, 255), (200, 30, 230))
create_shockwave("blast_shockwave.png", (240, 240, 255), (180, 140, 255))
create_spiral("blast_spiral.png", (255, 255, 255), (50, 160, 255))

create_shockwave("impact_heavy_punch.png", (255, 255, 255), (255, 180, 50))
create_lightning("impact_lightning_strike.png", (255, 255, 255), (70, 220, 255))
create_crystal("impact_ice_spikes.png", (240, 255, 255), (80, 200, 255))
print("ALL 12 VFX ASSETS READY!")
