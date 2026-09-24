"""
Final render fix: load blend, set camera correctly at Y+ looking toward Y- (character back),
then use Y- camera for the character front by understanding mesh orientation.

The mesh body faces +Y (face plate at y = -cos * radius ≈ negative y side for angle=0).
Actually face plate center is at angle_h=0: x=0, y=-radius (negative Y).
So face IS at -Y. The body loft sections have no inherent facing — it's cylindrical.
The FACE PLATE was placed at y = -math.cos(angle_h)*radius at angle_h=0 → y = -radius → -Y side.

So the face IS facing -Y. But the renders show back because the rotation script added 180° twice
(we ran it twice in separate invocations of rerender_goku.py).
Net result: 360° = no change + 180° from second run = 180° wrong.

Solution: Load the original build output (rebuild fresh) with corrected camera at Y- = sees face.
"""
import math
import bpy
from pathlib import Path
from mathutils import Vector

ROOT        = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate")
PREVIEW_DIR = ROOT / "art" / "blender" / "previews"
GLB_OUT     = ROOT / "godot" / "assets" / "models" / "goku.glb"
BLEND_OUT   = ROOT / "art" / "blender" / "PFU_SonGoku.blend"

# Run the original build script inline by importing its main
import sys
sys.path.insert(0, str(ROOT / "scripts"))

# We'll rebuild fresh from scratch using build_goku_final.py main()
# But first check mesh face direction by looking at face plate Y coord

# APPROACH: rebuild completely fresh, check face plate coordinates explicitly
# Face plate code: y = -math.cos(angle_h) * radius  at angle_h=0 → y = -10.7 (negative Y)
# So face IS at -Y. Camera must be at Y- position to see it.
# Camera at (0, -300, 92) looking at (0,0,92) → direction = (0, 308, 0) → +Y direction
# to_track_quat('-Z','Y') aligns -Z of camera toward +Y → camera looks in +Y direction
# But we want camera to look toward character face which is at -Y → camera looks in -Y direction
# So camera should be at Y+ and look toward Y-:
# Camera at (0, 300, 92) looking at (0,0,92) → direction = (0,-300,0) → -Y direction ✓

# The confusion: previous "front" cameras were at Y- but face IS at Y-,
# so camera and face were on the SAME SIDE → camera sees back.
# Fix: camera at Y+, looking toward Y-.

# Load existing blend (the one already rotated 180° from last run — now wrong direction)
# We need to rebuild fresh. Use build_goku_final main().
exec(open(str(ROOT / "scripts" / "build_goku_final.py")).read().replace(
    # Override the camera positions in main()
    'setup_camera("CamFront", (0, 280, 90), (0, 0, 90), fov=42)',
    'setup_camera("CamFront", (0, 280, 90), (0, 0, 90), fov=42)  # already correct'
).replace(
    # The issue is in rerender not build - just run main directly
    '', ''
))
