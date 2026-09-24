"""Render an icon/portrait for Sonic the Hedgehog (256x256 RGBA)."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
import math

OUT = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate\godot\assets\textures\ui\portrait_sonic.png")

img = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# Dynamic circular badge background
draw.ellipse([8, 8, 248, 248], fill=(10, 25, 65, 230), outline=(0, 220, 255, 255), width=4)

# Sonic Head base (Cobalt Blue)
head_box = [60, 48, 200, 188]
draw.ellipse(head_box, fill=(13, 71, 187, 255))

# Signature Sonic Quills (Large curved spines extending backwards)
quills = [
    # Top Quill
    [(110, 52), (18, 12), (75, 75)],
    # Mid Quill
    [(80, 85), (8, 68), (65, 120)],
    # Bottom Quill
    [(72, 130), (12, 145), (78, 172)],
]
for pts in quills:
    draw.polygon(pts, fill=(13, 71, 187, 255))

# Ear (Top Right)
ear_outer = [(165, 52), (205, 18), (195, 70)]
draw.polygon(ear_outer, fill=(13, 71, 187, 255))
ear_inner = [(170, 50), (198, 28), (190, 65)]
draw.polygon(ear_inner, fill=(254, 208, 168, 255))

# Peach Muzzle / Snout
muzzle = [115, 105, 218, 185]
draw.ellipse(muzzle, fill=(254, 208, 168, 255))

# Black round nose
draw.ellipse([198, 118, 218, 138], fill=(15, 15, 20, 255))
# Nose highlight
draw.ellipse([202, 122, 208, 128], fill=(240, 240, 255, 255))

# Smug confident mouth
draw.arc([140, 140, 195, 175], start=10, end=140, fill=(40, 20, 10, 255), width=3)

# Big expressive eyes (Connected mono-eye style with divider)
eye_white = [125, 65, 185, 125]
draw.ellipse(eye_white, fill=(250, 250, 255, 255), outline=(10, 30, 80, 255), width=2)

# Emerald Green Iris
draw.ellipse([150, 75, 175, 115], fill=(0, 210, 100, 255))
# Black pupil
draw.ellipse([156, 82, 172, 108], fill=(5, 10, 15, 255))
# Catchlight glints
draw.ellipse([159, 85, 165, 92], fill=(255, 255, 255, 255))

# Gold Ring Speed Icon accent in bottom corner
ring_box = [182, 182, 240, 240]
draw.ellipse(ring_box, outline=(255, 215, 0, 255), width=6)

img.save(OUT, format="PNG")
print(f"[OK] Saved Sonic portrait to {OUT}")
