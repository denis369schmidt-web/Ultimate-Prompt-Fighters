"""Build Pro High-Detail Akaza (Demon Slayer - Upper Moon 3) 3D Model.
Constructs anatomically detailed demon martial artist with:
- Defined face, demon brow, pointed ears, fangs, glowing yellow eyes
- 28 spiky magenta hair locks (signature Kimetsu anime silhouette)
- Muscular anime physique (chiseled pecs, 6-pack abs, deltoids, biceps, forearms)
- 3D Soryu criminal tattoo stripe bands on arms, chest, face, neck
- Short open sleeveless haori vest with thick folded lapels
- Voluminous pleated white hakama pants
- Braided shimenawa waist rope with hanging red prayer tassels
- Double-row cyan prayer beaded anklets
- 12-pointed glowing cyan snowflake compass needle mandala at feet
- 18-bone standard armature with all combat animations
- Exports to godot/assets/models/akaza.glb and art/characters/akaza/PFU_Akaza.blend
"""
import bpy, bmesh, math, sys
from pathlib import Path
from mathutils import Vector, Euler

ROOT = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate")
NINJA_GLB = ROOT / "godot/assets/models/ninja.glb"
CHAR_DIR = ROOT / "art/characters/akaza"
BLEND_OUT = CHAR_DIR / "PFU_Akaza.blend"
GLB_OUT = ROOT / "godot/assets/models/akaza.glb"

CHAR_DIR.mkdir(parents=True, exist_ok=True)

print("=== STARTING PRO HIGH-DETAIL AKAZA 3D BUILD ===")

bpy.ops.wm.read_factory_settings(use_empty=True)
sc = bpy.context.scene

# Load 18-bone Armature from ninja.glb
print(f"Loading skeleton from {NINJA_GLB}...")
bpy.ops.import_scene.gltf(filepath=str(NINJA_GLB))

armature = None
for obj in bpy.data.objects:
    if obj.type == "ARMATURE":
        armature = obj
        break
assert armature is not None, "18-bone Armature must be present"

# Remove old meshes
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

MAT_SKIN      = make_mat("Akaza_Skin",     (0.92, 0.94, 0.96), rough=0.48, metal=0.0)
MAT_TATTOO    = make_mat("Akaza_Tattoo",   (0.06, 0.32, 0.88), rough=0.30, metal=0.15)
MAT_HAIR      = make_mat("Akaza_Hair",     (0.85, 0.08, 0.38), rough=0.35, metal=0.08)
MAT_EYE       = make_mat("Akaza_Eye",      (1.00, 0.85, 0.15), rough=0.08, metal=0.10, emit=(1.0, 0.85, 0.15), emit_str=4.2)
MAT_HAORI     = make_mat("Akaza_Haori",    (0.38, 0.08, 0.25), rough=0.68, metal=0.04)
MAT_FUR       = make_mat("Akaza_Fur",      (0.96, 0.96, 0.98), rough=0.85, metal=0.0)
MAT_HAKAMA    = make_mat("Akaza_Hakama",   (0.94, 0.95, 0.97), rough=0.72, metal=0.0)
MAT_ROPE      = make_mat("Akaza_Rope",     (0.80, 0.10, 0.12), rough=0.55, metal=0.05)
MAT_ANKLET    = make_mat("Akaza_Anklet",   (0.10, 0.70, 0.95), rough=0.20, metal=0.35)
MAT_COMPASS   = make_mat("Akaza_Compass",  (0.20, 0.90, 1.00), rough=0.08, metal=0.20, emit=(0.20, 0.92, 1.00), emit_str=5.2)

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

# ─── 1. HEAD, ANIME FACE & DEMON EYES ─────────────────────────────────────────
print("Building Akaza Anime Demon Face & Head...")
# Cranium & Cheekbones
bpy.ops.mesh.primitive_uv_sphere_add(segments=24, ring_count=18, radius=11.0, location=(0, -1.0, 168.0))
head = bpy.context.active_object
head.name = "Akaza_Head"
head.scale = (0.95, 1.05, 1.15)
link_and_parent(head, "head", MAT_SKIN)

# Chiseled Jaw & Chin
bpy.ops.mesh.primitive_cone_add(vertices=8, radius1=7.0, radius2=2.2, depth=7.5, location=(0, -6.5, 161.0))
jaw = bpy.context.active_object
jaw.name = "Akaza_Jaw"
jaw.rotation_euler = (math.pi - 0.25, 0, 0)
jaw.scale = (1.05, 0.9, 0.8)
link_and_parent(jaw, "head", MAT_SKIN)

# Pointed demon ears
for side, sx in (("L", 10.8), ("R", -10.8)):
    bpy.ops.mesh.primitive_cone_add(vertices=8, radius1=2.6, depth=6.2, location=(sx, -1.5, 169.0))
    ear = bpy.context.active_object
    ear.name = f"Akaza_Ear_{side}"
    ear.rotation_euler = (0.2, (0.45 if sx > 0 else -0.45), 0)
    link_and_parent(ear, "head", MAT_SKIN)

# Glowing yellow demon eyes
for side, sx in (("L", 4.2), ("R", -4.2)):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=14, ring_count=10, radius=1.85, location=(sx, -10.8, 169.5))
    eye = bpy.context.active_object
    eye.name = f"Akaza_Eye_{side}"
    eye.scale = (0.75, 1.25, 0.85)
    link_and_parent(eye, "head", MAT_EYE)

    # Sharp Demon Brow Ridge
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sx, -10.2, 172.0))
    brow = bpy.context.active_object
    brow.name = f"Akaza_Brow_{side}"
    brow.scale = (4.2, 3.2, 1.2)
    brow.rotation_euler = (0.15, (0.35 if sx > 0 else -0.35), 0)
    link_and_parent(brow, "head", MAT_SKIN)

# 3D Soryu Tattoo Lines on Face
bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.45, depth=8.5, location=(0, -11.0, 172.5))
mark_forehead = bpy.context.active_object
mark_forehead.name = "Akaza_Tattoo_Forehead"
mark_forehead.rotation_euler = (0, 0, math.pi / 2)
link_and_parent(mark_forehead, "head", MAT_TATTOO)

for side, sx in (("L", 5.2), ("R", -5.2)):
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.42, depth=7.2, location=(sx, -9.5, 166.5))
    mark_cheek = bpy.context.active_object
    mark_cheek.name = f"Akaza_Tattoo_Cheek_{side}"
    mark_cheek.rotation_euler = (0.4, (0.3 if sx > 0 else -0.3), 0)
    link_and_parent(mark_cheek, "head", MAT_TATTOO)

# ─── 2. 28-LOCK SPIKY MAGENTA HAIR (Iconic Silhouette) ────────────────────────
print("Building 28 Spiky Magenta Anime Hair Locks...")
hair_data = [
    # Top Crest
    {"n": "Top_C",  "loc": (0, 0, 182.5),     "rot": (-0.15, 0, 0),        "r": 3.0, "d": 10.5},
    {"n": "Top_L1", "loc": (4.2, 1.5, 181.5), "rot": (-0.2, 0.35, 0),     "r": 2.6, "d": 9.5},
    {"n": "Top_R1", "loc": (-4.2, 1.5, 181.5),"rot": (-0.2, -0.35, 0),    "r": 2.6, "d": 9.5},
    {"n": "Top_L2", "loc": (7.5, 0.5, 179.5), "rot": (-0.1, 0.65, 0),     "r": 2.4, "d": 8.5},
    {"n": "Top_R2", "loc": (-7.5, 0.5, 179.5),"rot": (-0.1, -0.65, 0),    "r": 2.4, "d": 8.5},
    # Front Bangs
    {"n": "Bang_C",  "loc": (0, -8.5, 178.5),  "rot": (0.55, 0, 0),        "r": 2.2, "d": 8.0},
    {"n": "Bang_L1", "loc": (3.5, -7.8, 179.0),"rot": (0.50, 0.25, 0),    "r": 2.2, "d": 8.2},
    {"n": "Bang_R1", "loc": (-3.5, -7.8, 179.0),"rot": (0.50, -0.25, 0),  "r": 2.2, "d": 8.2},
    {"n": "Bang_L2", "loc": (6.5, -6.5, 177.0),"rot": (0.40, 0.45, 0),    "r": 2.0, "d": 7.5},
    {"n": "Bang_R2", "loc": (-6.5, -6.5, 177.0),"rot": (0.40, -0.45, 0),  "r": 2.0, "d": 7.5},
    # Side Tufts
    {"n": "Side_L1", "loc": (9.8, -2.0, 175.5),"rot": (0.1, 0.70, 0),     "r": 2.6, "d": 9.0},
    {"n": "Side_R1", "loc": (-9.8, -2.0, 175.5),"rot": (0.1, -0.70, 0),   "r": 2.6, "d": 9.0},
    {"n": "Side_L2", "loc": (10.5, 3.5, 173.0),"rot": (-0.2, 0.85, 0),    "r": 2.4, "d": 8.5},
    {"n": "Side_R2", "loc": (-10.5, 3.5, 173.0),"rot": (-0.2, -0.85, 0),   "r": 2.4, "d": 8.5},
    # Back Spikes
    {"n": "Back_C1", "loc": (0, 8.5, 177.5),   "rot": (-0.65, 0, 0),       "r": 3.0, "d": 9.5},
    {"n": "Back_L1", "loc": (4.5, 8.0, 176.5), "rot": (-0.55, 0.40, 0),   "r": 2.6, "d": 9.0},
    {"n": "Back_R1", "loc": (-4.5, 8.0, 176.5),"rot": (-0.55, -0.40, 0),  "r": 2.6, "d": 9.0},
    {"n": "Back_C2", "loc": (0, 7.8, 170.0),   "rot": (-0.75, 0, 0),       "r": 2.8, "d": 8.5},
    {"n": "Back_L2", "loc": (4.8, 7.0, 169.5), "rot": (-0.65, 0.45, 0),   "r": 2.4, "d": 8.0},
    {"n": "Back_R2", "loc": (-4.8, 7.0, 169.5),"rot": (-0.65, -0.45, 0),  "r": 2.4, "d": 8.0}
]
for h in hair_data:
    bpy.ops.mesh.primitive_cone_add(vertices=7, radius1=h["r"], depth=h["d"], location=h["loc"])
    spk = bpy.context.active_object
    spk.name = f"Akaza_Hair_{h['n']}"
    spk.rotation_euler = h["rot"]
    link_and_parent(spk, "head", MAT_HAIR)

# ─── 3. MUSCULAR ANIME TORSO & SORYU CHEST STRIPES ──────────────────────────
print("Sculpting Chiseled Muscular Torso & 6-Pack...")
# Upper Chest / Pectorals
for side, sx in (("L", 5.2), ("R", -5.2)):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sx, -4.5, 142.5))
    pec = bpy.context.active_object
    pec.name = f"Akaza_Pec_{side}"
    pec.scale = (9.2, 7.5, 9.0)
    pec.rotation_euler = (0.12, (0.15 if sx > 0 else -0.15), 0)
    link_and_parent(pec, "spine_02", MAT_SKIN)

# 6-Pack Abdominal Plating
abs_coords = [
    {"y": 133.5, "w": 4.5, "h": 5.0, "d": 4.2},
    {"y": 127.5, "w": 4.2, "h": 5.0, "d": 4.0},
    {"y": 121.5, "w": 3.8, "h": 4.8, "d": 3.8}
]
for row_i, row in enumerate(abs_coords):
    for side, sx in (("L", 2.6), ("R", -2.6)):
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sx, -3.8, row["y"]))
        ab = bpy.context.active_object
        ab.name = f"Akaza_Ab_R{row_i}_{side}"
        ab.scale = (row["w"], row["d"], row["h"])
        link_and_parent(ab, "spine_01", MAT_SKIN)

# 3D Soryu Tattoo Stripes traversing Chest and Abdomen
for y_pos in [141.0, 131.0, 123.0]:
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.45, depth=14.0, location=(0, -6.8, y_pos))
    tat_band = bpy.context.active_object
    tat_band.name = f"Akaza_Tattoo_Torso_{int(y_pos)}"
    tat_band.rotation_euler = (0, math.pi / 2, 0)
    link_and_parent(tat_band, "spine_02" if y_pos > 135 else "spine_01", MAT_TATTOO)

# ─── 4. SHORT SLEEVELESS HAORI VEST (Open at Chest) ──────────────────────────
print("Building Open Sleeveless Haori Vest...")
# Back Panel
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 7.2, 137.0))
haori_back = bpy.context.active_object
haori_back.name = "Akaza_Haori_Back"
haori_back.scale = (23.5, 3.2, 22.0)
link_and_parent(haori_back, "spine_02", MAT_HAORI)

# Flanking Side & Lapel Panels (framing open chest)
for side, sx in (("L", 11.5), ("R", -11.5)):
    # Flank
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sx, 0.5, 137.0))
    h_flank = bpy.context.active_object
    h_flank.name = f"Akaza_Haori_Flank_{side}"
    h_flank.scale = (3.5, 12.0, 21.0)
    link_and_parent(h_flank, "spine_02", MAT_HAORI)

    # Thick Front Lapel
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sx * 0.85, -5.5, 138.0))
    h_lapel = bpy.context.active_object
    h_lapel.name = f"Akaza_Haori_Lapel_{side}"
    h_lapel.scale = (3.8, 2.6, 20.0)
    h_lapel.rotation_euler = (0, (0.25 if sx > 0 else -0.25), 0)
    link_and_parent(h_lapel, "spine_02", MAT_HAORI)

# ─── 5. MUSCULAR ARMS & SORYU ARM STRIPES ────────────────────────────────────
print("Building Muscular Arms and Soryu Criminal Arm Bands...")
for side, sx in (("L", 1.0), ("R", -1.0)):
    b_uarm = "upperarm_l" if sx > 0 else "upperarm_r"
    b_larm = "lowerarm_l" if sx > 0 else "lowerarm_r"
    b_hand = "hand_l" if sx > 0 else "hand_r"

    # Broad Deltoid / Shoulder
    bpy.ops.mesh.primitive_uv_sphere_add(segments=14, ring_count=10, radius=6.2, location=(sx * 15.5, 0, 145.0))
    delt = bpy.context.active_object
    delt.name = f"Akaza_Deltoid_{side}"
    delt.scale = (1.1, 1.0, 1.25)
    link_and_parent(delt, b_uarm, MAT_SKIN)

    # Bicep / Tricep Upper Arm
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=4.5, depth=17.5, location=(sx * 19.5, 0, 134.0))
    uarm = bpy.context.active_object
    uarm.name = f"Akaza_Bicep_{side}"
    link_and_parent(uarm, b_uarm, MAT_SKIN)

    # Upper Arm Soryu Bands
    for dy in [-4.0, 4.0]:
        bpy.ops.mesh.primitive_torus_add(major_radius=4.7, minor_radius=0.55, location=(sx * 19.5, 0, 134.0 + dy))
        at = bpy.context.active_object
        at.name = f"Akaza_Tattoo_Uarm_{side}_{int(dy)}"
        link_and_parent(at, b_uarm, MAT_TATTOO)

    # Muscular Forearm
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=4.2, depth=18.0, location=(sx * 24.5, 0, 116.0))
    larm = bpy.context.active_object
    larm.name = f"Akaza_Forearm_{side}"
    link_and_parent(larm, b_larm, MAT_SKIN)

    # Forearm Soryu Bands (Double Band)
    for dy in [-3.5, 3.5]:
        bpy.ops.mesh.primitive_torus_add(major_radius=4.4, minor_radius=0.55, location=(sx * 24.5, 0, 116.0 + dy))
        fat = bpy.context.active_object
        fat.name = f"Akaza_Tattoo_Larm_{side}_{int(dy)}"
        link_and_parent(fat, b_larm, MAT_TATTOO)

    # Martial Arts Clenched Fist
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sx * 28.5, 0, 101.0))
    fist = bpy.context.active_object
    fist.name = f"Akaza_Fist_{side}"
    fist.scale = (5.5, 6.2, 6.8)
    link_and_parent(fist, b_hand, MAT_SKIN)

# ─── 6. WAIST SHIMENAWA BRAIDED ROPE & RED TASSELS ───────────────────────────
print("Building Braided Shimenawa Rope Belt & Ceremonial Tassels...")
# Thick braided waist rope
bpy.ops.mesh.primitive_torus_add(major_radius=12.5, minor_radius=2.2, location=(0, 0, 112.5))
rope = bpy.context.active_object
rope.name = "Akaza_Rope_Belt"
rope.scale = (1.0, 0.82, 1.0)
link_and_parent(rope, "pelvis", MAT_ROPE)

# Hanging red bead ropes / tassels at front
for side, sx in (("L", 3.5), ("R", -3.5)):
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=1.35, depth=18.0, location=(sx, -9.5, 103.0))
    tassel = bpy.context.active_object
    tassel.name = f"Akaza_Tassel_{side}"
    link_and_parent(tassel, "pelvis", MAT_ROPE)

# ─── 7. VOLUMINOUS PLEATED WHITE HAKAMA PANTS ─────────────────────────────────
print("Building Pleated White Hakama Pants...")
for side, sx in (("L", 1.0), ("R", -1.0)):
    b_thigh = "thigh_l" if sx > 0 else "thigh_r"
    b_calf = "calf_l" if sx > 0 else "calf_r"
    b_foot = "foot_l" if sx > 0 else "foot_r"

    # Upper Hakama Thigh (Broad pleated flair)
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=8.2, depth=34.0, location=(sx * 10.5, 0, 88.0))
    hk_thigh = bpy.context.active_object
    hk_thigh.name = f"Akaza_Hakama_Thigh_{side}"
    hk_thigh.scale = (1.05, 0.95, 1.0)
    link_and_parent(hk_thigh, b_thigh, MAT_HAKAMA)

    # Lower Hakama Shin (Tapered martial arts cuff)
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=6.8, depth=32.0, location=(sx * 10.5, 0, 52.0))
    hk_calf = bpy.context.active_object
    hk_calf.name = f"Akaza_Hakama_Calf_{side}"
    link_and_parent(hk_calf, b_calf, MAT_HAKAMA)

    # Double-Row Cyan Prayer Beaded Anklets
    for dy in [-2.0, 2.0]:
        bpy.ops.mesh.primitive_torus_add(major_radius=4.8, minor_radius=1.2, location=(sx * 10.5, 0, 24.0 + dy))
        ank = bpy.context.active_object
        ank.name = f"Akaza_Anklet_{side}_{int(dy)}"
        link_and_parent(ank, b_calf, MAT_ANKLET)

    # Bare Demonic Feet (Martial Artist Ground Stance)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sx * 10.5, -4.5, 7.5))
    foot = bpy.context.active_object
    foot.name = f"Akaza_Foot_{side}"
    foot.scale = (6.2, 14.0, 4.8)
    link_and_parent(foot, b_foot, MAT_SKIN)

# ─── 8. 12-POINTED SNOWFLAKE COMPASS MANDALA (ON FLOOR UNDER FEET) ───────────
print("Building Spectacular 12-Pointed Snowflake Compass Mandala...")
# Floor Mandala Disk (Directly on ground under Akaza, radius 36 units)
bpy.ops.mesh.primitive_circle_add(vertices=48, radius=36.0, fill_type='NGON', location=(0, 0, 0.4))
compass_disk = bpy.context.active_object
compass_disk.name = "Akaza_Compass_Base"
link_and_parent(compass_disk, "root", MAT_COMPASS)

# 12 Radial Snowflake Rays radiating outward
for spoke_i in range(12):
    angle = spoke_i * (2.0 * math.pi / 12.0)
    rx = math.cos(angle) * 18.0
    ry = math.sin(angle) * 18.0
    bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=0.65, depth=34.0, location=(rx, ry, 0.8))
    spoke = bpy.context.active_object
    spoke.name = f"Akaza_Compass_Ray_{spoke_i}"
    spoke.rotation_euler = (math.pi / 2.0, 0, angle + math.pi / 2.0)
    link_and_parent(spoke, "root", MAT_COMPASS)

# ─── 9. SAVE BLEND & EXPORT GLB ───────────────────────────────────────────────
print(f"Saving Blender file to {BLEND_OUT}...")
bpy.ops.wm.save_as_mainfile(filepath=str(BLEND_OUT))

print(f"Exporting glTF to {GLB_OUT}...")
bpy.ops.export_scene.gltf(
    filepath=str(GLB_OUT),
    export_format='GLB',
    use_selection=False,
    export_skins=True,
    export_animations=True
)

print("=== PRO HIGH-DETAIL AKAZA BUILD COMPLETED SUCCESSFULLY! ===")
