"""Akaza (Demon Slayer - Upper Moon Three / Hakuji) 3D Character Builder.

Features:
- Athletic martial artist anatomy (Soryu style)
- Signature blue criminal tattoos (forearms, bicep rings, torso, face)
- Spiky magenta/pink hair
- Yellow demonic eyes with cyan sclera
- Cropped dark purple/magenta sleeveless haori vest with white fur collar
- Loose white hakama martial artist pants
- Crimson braided rope belt with prayer bead tassels
- Blue beaded anklets on bare feet
- 12-pointed Destructive Death: Compass Needle (Hakai Satsu: Rashin) ground snowflake decal
- Standardized 18-bone rigged skeleton compatible with all Godot combat animations
- Full PBR materials
- Export to godot/assets/models/akaza.glb and art/characters/akaza/PFU_Akaza.blend
"""
import bpy, bmesh, math
from pathlib import Path
from mathutils import Vector, Matrix, Euler

ROOT = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate")
NINJA_GLB = ROOT / "godot/assets/models/ninja.glb"
CHAR_DIR = ROOT / "art/characters/akaza"
PREVIEWS = CHAR_DIR / "previews"
BLEND_OUT = CHAR_DIR / "PFU_Akaza.blend"
GLB_OUT = ROOT / "godot/assets/models/akaza.glb"

for d in (CHAR_DIR, PREVIEWS):
    d.mkdir(parents=True, exist_ok=True)

print("=== STARTING AKAZA 3D CHARACTER BUILD ===")

# Reset Blender
bpy.ops.wm.read_factory_settings(use_empty=True)
sc = bpy.context.scene
sc.unit_settings.system = 'METRIC'

# Load 18-bone Armature from ninja.glb
print(f"Loading base skeleton from {NINJA_GLB}...")
bpy.ops.import_scene.gltf(filepath=str(NINJA_GLB))

armature = None
for obj in bpy.data.objects:
    if obj.type == "ARMATURE":
        armature = obj
        break
assert armature is not None, "18-bone Armature must be present"

# Remove old ninja meshes, preserve armature and actions
for m in [o for o in bpy.data.objects if o.type == "MESH"]:
    bpy.data.objects.remove(m, do_unlink=True)

print(f"Armature ready: {armature.name} with {len(armature.data.bones)} bones")

# ─── PBR MATERIALS ───────────────────────────────────────────────────────────
def make_mat(name, col, rough=0.5, metal=0.0, emit=None, emit_str=0.0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nodes = m.node_tree.nodes
    links = m.node_tree.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (0, 0)
    links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])
    bsdf.inputs["Base Color"].default_value = (*col, 1.0)
    bsdf.inputs["Roughness"].default_value = rough
    bsdf.inputs["Metallic"].default_value = metal
    if emit and emit_str > 0:
        if "Emission Color" in bsdf.inputs:
            bsdf.inputs["Emission Color"].default_value = (*emit, 1.0)
            bsdf.inputs["Emission Strength"].default_value = emit_str
        elif "Emission" in bsdf.inputs:
            bsdf.inputs["Emission"].default_value = (*emit, 1.0)
    return m

MAT_SKIN      = make_mat("Akaza_Skin",     (0.88, 0.90, 0.94), rough=0.52, metal=0.0)
MAT_TATTOO    = make_mat("Akaza_Tattoo",   (0.08, 0.35, 0.85), rough=0.35, metal=0.15)
MAT_HAIR      = make_mat("Akaza_Hair",     (0.88, 0.12, 0.42), rough=0.38, metal=0.08)
MAT_EYE       = make_mat("Akaza_Eye",      (1.00, 0.82, 0.10), rough=0.10, metal=0.20, emit=(1.0, 0.85, 0.15), emit_str=3.0)
MAT_HAORI     = make_mat("Akaza_Haori",    (0.40, 0.10, 0.28), rough=0.68, metal=0.04)
MAT_FUR       = make_mat("Akaza_Fur",      (0.96, 0.96, 0.98), rough=0.85, metal=0.0)
MAT_HAKAMA    = make_mat("Akaza_Hakama",   (0.92, 0.93, 0.95), rough=0.72, metal=0.0)
MAT_ROPE      = make_mat("Akaza_Rope",     (0.82, 0.10, 0.12), rough=0.60, metal=0.05)
MAT_ANKLET    = make_mat("Akaza_Anklet",   (0.12, 0.45, 0.90), rough=0.25, metal=0.35)
MAT_COMPASS   = make_mat("Akaza_Compass",  (0.20, 0.85, 1.00), rough=0.08, metal=0.30, emit=(0.20, 0.90, 1.00), emit_str=4.8)

# Helper: link object and parent to bone
def link_and_parent(obj, bone_name, mat=None):
    if obj.name not in sc.collection.objects:
        sc.collection.objects.link(obj)
    if mat:
        obj.data.materials.append(mat)
    obj.parent = armature
    mod = obj.modifiers.new("Armature", "ARMATURE")
    mod.object = armature
    vg = obj.vertex_groups.new(name=bone_name)
    all_indices = list(range(len(obj.data.vertices)))
    if all_indices:
        vg.add(all_indices, 1.0, 'REPLACE')
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.shade_smooth()
    obj.select_set(False)
    return obj

# ─── 1. HEAD, HAIR & DEMON FACE ─────────────────────────────────────────────
print("Building Akaza Head, Face and Hair...")
# Head sphere
bpy.ops.mesh.primitive_uv_sphere_add(segments=20, ring_count=16, radius=11.5, location=(0, 0, 168.0))
head = bpy.context.active_object
head.name = "Akaza_Head"
head.scale = (0.95, 1.05, 1.15)
link_and_parent(head, "head", MAT_SKIN)

# Pointed demon ears
for side, sx in (("L", 11.2), ("R", -11.2)):
    bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=2.8, depth=5.8, location=(sx, -1.0, 169.0))
    ear = bpy.context.active_object
    ear.name = f"Akaza_Ear_{side}"
    ear.rotation_euler = (0.2, (0.45 if sx > 0 else -0.45), 0)
    link_and_parent(ear, "head", MAT_SKIN)

# Eyes (Yellow glowing demon eyes)
for side, sx in (("L", 4.2), ("R", -4.2)):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=8, radius=1.75, location=(sx, -10.8, 169.5))
    eye = bpy.context.active_object
    eye.name = f"Akaza_Eye_{side}"
    link_and_parent(eye, "head", MAT_EYE)

# Facial Criminal Tattoo Lines (Blue marks across face and forehead)
bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.45, depth=8.0, location=(0, -11.0, 172.5))
mark_forehead = bpy.context.active_object
mark_forehead.name = "Akaza_Tattoo_Forehead"
mark_forehead.rotation_euler = (0, 0, math.pi / 2)
link_and_parent(mark_forehead, "head", MAT_TATTOO)

for side, sx in (("L", 5.2), ("R", -5.2)):
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.40, depth=6.5, location=(sx, -9.5, 166.5))
    mark_cheek = bpy.context.active_object
    mark_cheek.name = f"Akaza_Tattoo_Cheek_{side}"
    mark_cheek.rotation_euler = (0.4, (0.3 if sx > 0 else -0.3), 0)
    link_and_parent(mark_cheek, "head", MAT_TATTOO)

# Spiky Magenta/Pink Hair (16 stylized 3D hair clumps)
hair_spikes = [
    # Top crown
    {"name": "Akaza_Hair_Top_C",  "loc": (0, 0, 181.5),     "rot": (-0.1, 0, 0),         "r": 3.2, "d": 9.5},
    {"name": "Akaza_Hair_Top_L",  "loc": (4.5, 1.0, 180.5), "rot": (-0.2, 0.35, 0),     "r": 2.8, "d": 8.5},
    {"name": "Akaza_Hair_Top_R",  "loc": (-4.5, 1.0, 180.5),"rot": (-0.2, -0.35, 0),    "r": 2.8, "d": 8.5},
    # Front bangs
    {"name": "Akaza_Hair_Bang_L", "loc": (3.2, -7.5, 178.0),"rot": (0.45, 0.20, 0),     "r": 2.4, "d": 7.5},
    {"name": "Akaza_Hair_Bang_R", "loc": (-3.2, -7.5, 178.0),"rot": (0.45, -0.20, 0),   "r": 2.4, "d": 7.5},
    {"name": "Akaza_Hair_Bang_C", "loc": (0, -8.5, 177.5),  "rot": (0.50, 0, 0),         "r": 2.2, "d": 7.0},
    # Sides
    {"name": "Akaza_Hair_Side_L", "loc": (8.8, -2.5, 175.0),"rot": (0.1, 0.55, 0),      "r": 2.8, "d": 8.0},
    {"name": "Akaza_Hair_Side_R", "loc": (-8.8, -2.5, 175.0),"rot": (0.1, -0.55, 0),    "r": 2.8, "d": 8.0},
    # Back spikes
    {"name": "Akaza_Hair_Back_1", "loc": (0, 7.5, 176.0),   "rot": (-0.55, 0, 0),        "r": 3.0, "d": 8.5},
    {"name": "Akaza_Hair_Back_L", "loc": (5.2, 6.5, 174.5), "rot": (-0.45, 0.40, 0),    "r": 2.8, "d": 8.0},
    {"name": "Akaza_Hair_Back_R", "loc": (-5.2, 6.5, 174.5),"rot": (-0.45, -0.40, 0),   "r": 2.8, "d": 8.0},
    {"name": "Akaza_Hair_Low_L",  "loc": (7.0, 4.5, 168.0), "rot": (-0.25, 0.50, 0),    "r": 2.5, "d": 7.2},
    {"name": "Akaza_Hair_Low_R",  "loc": (-7.0, 4.5, 168.0),"rot": (-0.25, -0.50, 0),   "r": 2.5, "d": 7.2},
]
for h in hair_spikes:
    bpy.ops.mesh.primitive_cone_add(vertices=8, radius1=h["r"], radius2=0.2, depth=h["d"], location=h["loc"])
    spk = bpy.context.active_object
    spk.name = h["name"]
    spk.rotation_euler = h["rot"]
    link_and_parent(spk, "head", MAT_HAIR)

# Neck
bpy.ops.mesh.primitive_cylinder_add(vertices=14, radius=6.2, depth=12.0, location=(0, 0, 156.0))
neck = bpy.context.active_object
neck.name = "Akaza_Neck"
link_and_parent(neck, "neck", MAT_SKIN)

# Neck Tattoo Ring
bpy.ops.mesh.primitive_torus_add(major_radius=6.4, minor_radius=0.45, location=(0, 0, 156.0))
neck_ring = bpy.context.active_object
neck_ring.name = "Akaza_Tattoo_NeckRing"
link_and_parent(neck_ring, "neck", MAT_TATTOO)

# ─── 2. TORSO, PECTORALS, HAORI & TATTOOS ────────────────────────────────────
print("Building Akaza Torso, Haori Vest & Soryu Tattoos...")
# Upper Chest / Spine_02
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 140.0))
chest = bpy.context.active_object
chest.name = "Akaza_Chest"
chest.scale = (26.0, 15.0, 18.0)
link_and_parent(chest, "spine_02", MAT_SKIN)

# Pectoral definition
for side, sx in (("L", 6.5), ("R", -6.5)):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sx, -7.2, 142.0))
    pec = bpy.context.active_object
    pec.name = f"Akaza_Pectoral_{side}"
    pec.scale = (10.5, 3.5, 8.5)
    link_and_parent(pec, "spine_02", MAT_SKIN)

# Chest Soryu Tattoos (Crossing blue stripes over chest)
for side, sx in (("L", 5.0), ("R", -5.0)):
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.55, depth=14.0, location=(sx, -8.2, 142.0))
    t_chest = bpy.context.active_object
    t_chest.name = f"Akaza_Tattoo_Chest_{side}"
    t_chest.rotation_euler = (0, (0.35 if sx > 0 else -0.35), 0)
    link_and_parent(t_chest, "spine_02", MAT_TATTOO)

# Lower Torso / Spine_01 (Abdominals)
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 118.0))
abs_mesh = bpy.context.active_object
abs_mesh.name = "Akaza_Abdominals"
abs_mesh.scale = (21.0, 13.5, 17.0)
link_and_parent(abs_mesh, "spine_01", MAT_SKIN)

# Torso Center Tattoo Stripe
bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.6, depth=18.0, location=(0, -7.0, 120.0))
t_abs = bpy.context.active_object
t_abs.name = "Akaza_Tattoo_Abs"
link_and_parent(t_abs, "spine_01", MAT_TATTOO)

# Sleeveless Cropped Haori Vest (Dark reddish-purple)
# Left vest side
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(12.0, -1.0, 138.0))
haori_l = bpy.context.active_object
haori_l.name = "Akaza_Haori_L"
haori_l.scale = (5.5, 17.5, 22.0)
link_and_parent(haori_l, "spine_02", MAT_HAORI)

# Right vest side
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(-12.0, -1.0, 138.0))
haori_r = bpy.context.active_object
haori_r.name = "Akaza_Haori_R"
haori_r.scale = (5.5, 17.5, 22.0)
link_and_parent(haori_r, "spine_02", MAT_HAORI)

# Haori Back panel
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 7.8, 138.0))
haori_back = bpy.context.active_object
haori_back.name = "Akaza_Haori_Back"
haori_back.scale = (25.0, 3.5, 22.0)
link_and_parent(haori_back, "spine_02", MAT_HAORI)

# Fluffy White Fur Collar around neck/shoulders
bpy.ops.mesh.primitive_torus_add(major_radius=13.0, minor_radius=2.8, location=(0, 1.5, 149.0))
fur_collar = bpy.context.active_object
fur_collar.name = "Akaza_FurCollar"
fur_collar.scale = (1.05, 0.95, 0.85)
link_and_parent(fur_collar, "spine_02", MAT_FUR)

# ─── 3. ARMS, FOREARM WRAPS & TATTOO RINGS ──────────────────────────────────
print("Building Akaza Arms, Soryu Markings & Clenched Fists...")
for side, sx in (("L", 1), ("R", -1)):
    side_code = "l" if sx > 0 else "r"
    # Upper arm
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=4.6, depth=24.0, location=(sx * 26.0, 0, 140.0))
    u_arm = bpy.context.active_object
    u_arm.name = f"Akaza_UpperArm_{side_code.upper()}"
    u_arm.rotation_euler = (0, sx * 0.38, 0)
    link_and_parent(u_arm, f"upperarm_{side_code}", MAT_SKIN)

    # 3 Bicep tattoo rings
    for ri, rz in enumerate([-6.0, 0.0, 6.0]):
        bpy.ops.mesh.primitive_torus_add(major_radius=4.8, minor_radius=0.45, location=(sx * 26.0, 0, 140.0 + rz))
        t_ring = bpy.context.active_object
        t_ring.name = f"Akaza_Tattoo_ArmRing_{side_code.upper()}_{ri}"
        t_ring.rotation_euler = (0, sx * 0.38, 0)
        link_and_parent(t_ring, f"upperarm_{side_code}", MAT_TATTOO)

    # Forearm
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=4.2, depth=24.0, location=(sx * 58.0, 0, 120.0))
    f_arm = bpy.context.active_object
    f_arm.name = f"Akaza_Forearm_{side_code.upper()}"
    f_arm.rotation_euler = (0, sx * 0.65, 0)
    link_and_parent(f_arm, f"lowerarm_{side_code}", MAT_SKIN)

    # Forearm criminal tattoo spiral / wrap
    for wi, wz in enumerate([-7.0, -2.0, 3.0, 8.0]):
        bpy.ops.mesh.primitive_torus_add(major_radius=4.4, minor_radius=0.45, location=(sx * 58.0, 0, 120.0 + wz))
        t_wrap = bpy.context.active_object
        t_wrap.name = f"Akaza_Tattoo_ForearmWrap_{side_code.upper()}_{wi}"
        t_wrap.rotation_euler = (0, sx * 0.65, 0)
        link_and_parent(t_wrap, f"lowerarm_{side_code}", MAT_TATTOO)

    # Clenched Martial Arts Fist
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sx * 82.0, 0, 94.0))
    fist = bpy.context.active_object
    fist.name = f"Akaza_Fist_{side_code.upper()}"
    fist.scale = (8.2, 7.5, 7.8)
    link_and_parent(fist, f"hand_{side_code}", MAT_SKIN)

# ─── 4. PELVIS, SHIMENAWA ROPE BELT & HAKAMA PANTS ──────────────────────────
print("Building Pelvis, Shimenawa Rope Belt & Hakama Pants...")
# Pelvis core
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 95.0))
pelv = bpy.context.active_object
pelv.name = "Akaza_Pelvis"
pelv.scale = (23.0, 15.0, 14.0)
link_and_parent(pelv, "pelvis", MAT_HAKAMA)

# Crimson Braided Rope Belt (Shimenawa) around waist
bpy.ops.mesh.primitive_torus_add(major_radius=14.0, minor_radius=2.5, location=(0, 0, 99.0))
rope = bpy.context.active_object
rope.name = "Akaza_RopeBelt"
rope.scale = (1.05, 0.95, 1.0)
link_and_parent(rope, "pelvis", MAT_ROPE)

# Prayer Bead Tassels hanging in front
for bi, bz in enumerate([-3.0, -7.0, -11.0]):
    for side, sx in (("L", 3.2), ("R", -3.2)):
        bpy.ops.mesh.primitive_uv_sphere_add(segments=10, ring_count=8, radius=1.65, location=(sx, -13.5, 99.0 + bz))
        bead = bpy.context.active_object
        bead.name = f"Akaza_RopeBead_{side}_{bi}"
        link_and_parent(bead, "pelvis", MAT_ROPE)

# Hakama Pleated Pants (Upper Thighs)
for side, sx in (("L", 1), ("R", -1)):
    side_code = "l" if sx > 0 else "r"
    # Wide Hakama Thigh
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=7.8, depth=32.0, location=(sx * 16.0, 0, 72.0))
    h_thigh = bpy.context.active_object
    h_thigh.name = f"Akaza_Hakama_Thigh_{side_code.upper()}"
    link_and_parent(h_thigh, f"thigh_{side_code}", MAT_HAKAMA)

    # Hakama Calf cuff (Rolled up just below knee)
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=6.5, depth=14.0, location=(sx * 18.0, 0, 48.0))
    h_cuff = bpy.context.active_object
    h_cuff.name = f"Akaza_Hakama_Cuff_{side_code.upper()}"
    link_and_parent(h_cuff, f"calf_{side_code}", MAT_HAKAMA)

    # Bare Lower Calf / Shin
    bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=4.2, depth=22.0, location=(sx * 19.5, 0, 28.0))
    bare_calf = bpy.context.active_object
    bare_calf.name = f"Akaza_BareShin_{side_code.upper()}"
    link_and_parent(bare_calf, f"calf_{side_code}", MAT_SKIN)

    # Blue Beaded Anklet
    bpy.ops.mesh.primitive_torus_add(major_radius=4.6, minor_radius=0.9, location=(sx * 19.8, 0, 16.0))
    anklet = bpy.context.active_object
    anklet.name = f"Akaza_Anklet_{side_code.upper()}"
    link_and_parent(anklet, f"foot_{side_code}", MAT_ANKLET)

    # Bare Martial Artist Foot
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sx * 19.8, -5.5, 6.0))
    foot = bpy.context.active_object
    foot.name = f"Akaza_BareFoot_{side_code.upper()}"
    foot.scale = (7.2, 16.5, 5.5)
    link_and_parent(foot, f"foot_{side_code}", MAT_SKIN)

# ─── 5. DESTRUCTIVE DEATH: COMPASS NEEDLE (GROUND SNOWFLAKE DECAL) ───────────
print("Building 12-pointed Destructive Death: Compass Needle Ground Decal...")
# Center compass hub
bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=32.0, depth=0.2, location=(0, 0, 0.4))
compass_hub = bpy.context.active_object
compass_hub.name = "Akaza_CompassNeedle"
link_and_parent(compass_hub, "root", MAT_COMPASS)

# 12 Radiating Snowflake Needles / Petals
for ni in range(12):
    ang = ni * (2.0 * math.pi / 12.0)
    nx = math.cos(ang) * 45.0
    ny = math.sin(ang) * 45.0
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(nx, ny, 0.5))
    needle = bpy.context.active_object
    needle.name = f"Akaza_CompassPetal_{ni}"
    needle.scale = (2.2, 28.0, 0.15)
    needle.rotation_euler = (0, 0, ang + math.pi / 2.0)
    link_and_parent(needle, "root", MAT_COMPASS)

print("All Akaza meshes created and parented to 18-bone armature successfully.")

# ─── SAVE BLEND AND EXPORT GLB ───────────────────────────────────────────────
bpy.ops.wm.save_as_mainfile(filepath=str(BLEND_OUT))
print(f"Saved .blend to {BLEND_OUT}")

bpy.ops.object.select_all(action='DESELECT')
for obj in bpy.data.objects:
    if obj.type in ("ARMATURE", "MESH"):
        obj.select_set(True)

bpy.ops.export_scene.gltf(
    filepath=str(GLB_OUT),
    use_selection=True,
    export_format='GLB',
    export_apply=False,
    export_animations=True,
    export_skins=True,
    export_yup=True
)
print(f"Exported Akaza GLB to {GLB_OUT}")
print("=== AKAZA BUILD COMPLETED SUCCESSFULLY ===")
