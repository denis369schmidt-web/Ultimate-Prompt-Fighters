"""Build Blue-Eyes White Dragon (Yu-Gi-Oh) 3D Model with 18-Bone Standard Rig.
Uses Blender 4.5.5 LTS headless to construct geometry, attach PBR materials,
parent to standard armature, and export to godot/assets/models/blue_eyes.glb.
"""
import bpy, bmesh, math, sys
from pathlib import Path
from mathutils import Vector, Euler

ROOT = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate")
NINJA_GLB = ROOT / "godot/assets/models/ninja.glb"
OUT_BLEND = ROOT / "art/characters/blue_eyes/PFU_BlueEyes.blend"
OUT_GLB = ROOT / "godot/assets/models/blue_eyes.glb"

OUT_BLEND.parent.mkdir(parents=True, exist_ok=True)
OUT_GLB.parent.mkdir(parents=True, exist_ok=True)

# ─── RESET SCENE ─────────────────────────────────────────────────────────────
bpy.ops.wm.read_factory_settings(use_empty=True)
sc = bpy.context.scene

# ─── IMPORT BASE ARMATURE FROM NINJA.GLB ──────────────────────────────────────
print(f"Loading base armature from: {NINJA_GLB}")
bpy.ops.import_scene.gltf(filepath=str(NINJA_GLB))

armatures = [o for o in bpy.data.objects if o.type == "ARMATURE"]
if not armatures:
    print("ERROR: No armature found in ninja.glb!")
    sys.exit(1)

armature = armatures[0]
armature.name = "Armature_BlueEyes"
print(f"Armature ready: {armature.name} with {len(armature.data.bones)} bones")

# Remove existing ninja mesh objects
for m in [o for o in bpy.data.objects if o.type == "MESH"]:
    bpy.data.objects.remove(m, do_unlink=True)

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

MAT_SCALE        = make_mat("BlueEyes_Scale",       (0.92, 0.95, 0.98), rough=0.32, metal=0.25)
MAT_CHEST        = make_mat("BlueEyes_ChestPlate",  (0.82, 0.86, 0.94), rough=0.42, metal=0.15)
MAT_HORN         = make_mat("BlueEyes_Horn",        (0.78, 0.84, 0.92), rough=0.18, metal=0.75)
MAT_EYE          = make_mat("BlueEyes_Eye",         (0.08, 0.78, 1.00), rough=0.08, metal=0.20, emit=(0.0, 0.85, 1.0), emit_str=4.8)
MAT_WING_MEMB    = make_mat("BlueEyes_WingMemb",    (0.80, 0.88, 0.98), rough=0.50, metal=0.08)
MAT_CLAW         = make_mat("BlueEyes_Claw",        (0.95, 0.97, 1.00), rough=0.12, metal=0.45)
MAT_BURST_STREAM = make_mat("BlueEyes_BurstStream", (0.35, 0.92, 1.00), rough=0.08, metal=0.20, emit=(0.20, 0.95, 1.0), emit_str=5.5)

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

# ─── 1. DRAGON HEAD, HORNS & PIERCING BLUE EYES ─────────────────────────────
print("Building Blue-Eyes Dragon Head, Crest Horns & Cold Eyes...")
# Cranium (Back of head)
bpy.ops.mesh.primitive_uv_sphere_add(segments=18, ring_count=14, radius=9.5, location=(0, -4.0, 171.0))
cranium = bpy.context.active_object
cranium.name = "BlueEyes_Cranium"
cranium.scale = (1.05, 1.35, 0.95)
link_and_parent(cranium, "head", MAT_SCALE)

# Upper Snout / Draconic Muzzle
bpy.ops.mesh.primitive_cone_add(vertices=10, radius1=6.5, radius2=2.2, depth=16.0, location=(0, -16.0, 169.5))
snout = bpy.context.active_object
snout.name = "BlueEyes_Snout"
snout.rotation_euler = (math.pi / 2.0 - 0.12, 0, 0)
snout.scale = (1.1, 0.75, 1.0)
link_and_parent(snout, "head", MAT_SCALE)

# Lower Mandible / Jaw
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -13.5, 164.5))
jaw = bpy.context.active_object
jaw.name = "BlueEyes_Jaw"
jaw.scale = (7.5, 14.0, 3.2)
jaw.rotation_euler = (0.15, 0, 0)
link_and_parent(jaw, "head", MAT_SCALE)

# Piercing Ice-Blue Eyes (Legendary Cold Gaze)
for side, sx in (("L", 4.8), ("R", -4.8)):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=8, radius=2.1, location=(sx, -11.5, 172.5))
    eye = bpy.context.active_object
    eye.name = f"BlueEyes_Eye_{side}"
    eye.scale = (0.75, 1.35, 0.85)
    eye.rotation_euler = (0.1, (0.3 if sx > 0 else -0.3), 0)
    link_and_parent(eye, "head", MAT_EYE)

    # Sharp Brow Ridge over each eye
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sx, -10.5, 174.5))
    brow = bpy.context.active_object
    brow.name = f"BlueEyes_Brow_{side}"
    brow.scale = (3.5, 7.5, 1.6)
    brow.rotation_euler = (0.15, (0.35 if sx > 0 else -0.35), 0)
    link_and_parent(brow, "head", MAT_HORN)

# Swept-Back Main Dragon Horns (Majestic Crown)
for side, sx in (("L", 5.5), ("R", -5.5)):
    # Large main horn
    bpy.ops.mesh.primitive_cone_add(vertices=8, radius1=2.8, radius2=0.3, depth=22.0, location=(sx, 8.5, 180.0))
    horn = bpy.context.active_object
    horn.name = f"BlueEyes_Horn_Main_{side}"
    horn.rotation_euler = (-0.75, (0.35 if sx > 0 else -0.35), 0)
    link_and_parent(horn, "head", MAT_HORN)

    # Cheek Horn Spike
    bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=1.9, radius2=0.2, depth=11.0, location=(sx * 1.55, 1.5, 168.0))
    chorn = bpy.context.active_object
    chorn.name = f"BlueEyes_Horn_Cheek_{side}"
    chorn.rotation_euler = (-0.35, (0.65 if sx > 0 else -0.65), 0)
    link_and_parent(chorn, "head", MAT_HORN)

# Burst Stream of Destruction Particle Core in maw
bpy.ops.mesh.primitive_uv_sphere_add(segments=14, ring_count=10, radius=2.6, location=(0, -12.5, 167.0))
maw_core = bpy.context.active_object
maw_core.name = "BlueEyes_BurstStream_Core"
link_and_parent(maw_core, "head", MAT_BURST_STREAM)

# Forward-projecting Burst Stream Beam (Visible during SpecialAttack)
bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=4.5, depth=42.0, location=(0, -36.0, 168.0))
burst_beam = bpy.context.active_object
burst_beam.name = "BlueEyes_BurstStream_Beam"
burst_beam.rotation_euler = (math.pi / 2.0, 0, 0)
link_and_parent(burst_beam, "head", MAT_BURST_STREAM)

# ─── 2. DRAGON NECK & DORSAL SPINES ─────────────────────────────────────────
print("Building Sinuous Dragon Neck & Dorsal Crest...")
for ni, nz in enumerate([158.0, 150.0]):
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=5.8 - ni * 0.4, depth=10.0, location=(0, -1.0 - ni * 0.5, nz))
    n_seg = bpy.context.active_object
    n_seg.name = f"BlueEyes_NeckSeg_{ni}"
    n_seg.rotation_euler = (0.15, 0, 0)
    link_and_parent(n_seg, "neck", MAT_SCALE)

    # Neck dorsal spike
    bpy.ops.mesh.primitive_cone_add(vertices=5, radius1=1.8, depth=7.5, location=(0, 4.5, nz))
    n_spk = bpy.context.active_object
    n_spk.name = f"BlueEyes_NeckSpike_{ni}"
    n_spk.rotation_euler = (-0.55, 0, 0)
    link_and_parent(n_spk, "neck", MAT_HORN)

# ─── 3. TORSO, UNDERBELLY PLATES & BACK SPINES ──────────────────────────────
print("Building Torso, Underbelly Armor Plates & Backbone Fins...")
# Upper Chest / Spine_02
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 138.0))
chest = bpy.context.active_object
chest.name = "BlueEyes_Chest"
chest.scale = (28.0, 18.0, 20.0)
link_and_parent(chest, "spine_02", MAT_SCALE)

# Segmented silver underbelly plates
for pi, pz in enumerate([144.0, 137.0, 130.0]):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -8.6, pz))
    uplate = bpy.context.active_object
    uplate.name = f"BlueEyes_UnderbellyPlate_{pi}"
    uplate.scale = (16.0 - pi * 1.5, 3.5, 5.5)
    link_and_parent(uplate, "spine_02", MAT_CHEST)

# Backbone dorsal spines (Spine_02)
for bi, bz in enumerate([146.0, 138.0, 130.0]):
    bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=2.4, depth=11.0, location=(0, 9.8, bz))
    b_spk = bpy.context.active_object
    b_spk.name = f"BlueEyes_BackSpike_{bi}"
    b_spk.rotation_euler = (-0.45, 0, 0)
    link_and_parent(b_spk, "spine_02", MAT_HORN)

# Lower Torso / Spine_01 (Abdominals)
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 116.0))
abs_mesh = bpy.context.active_object
abs_mesh.name = "BlueEyes_Abdominals"
abs_mesh.scale = (22.0, 15.0, 18.0)
link_and_parent(abs_mesh, "spine_01", MAT_SCALE)

# Pelvis
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 94.0))
pelv = bpy.context.active_object
pelv.name = "BlueEyes_Pelvis"
pelv.scale = (24.0, 17.0, 16.0)
link_and_parent(pelv, "pelvis", MAT_SCALE)

# ─── 4. MAJESTIC DRAGON WINGS (LARGE WINGSPAN) ──────────────────────────────
print("Building Swept Dragon Wings & Translucent Membranes...")
for side, sx in (("L", 1), ("R", -1)):
    side_code = "l" if sx > 0 else "r"
    # Wing arm shoulder joint / upper strut
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=2.6, depth=28.0, location=(sx * 22.0, 12.0, 148.0))
    w_arm = bpy.context.active_object
    w_arm.name = f"BlueEyes_WingArm_{side_code.upper()}"
    w_arm.rotation_euler = (-0.35, sx * 0.75, sx * 0.25)
    link_and_parent(w_arm, "spine_02", MAT_SCALE)

    # Wing Elbow Carpal Joint with thumb claw
    bpy.ops.mesh.primitive_uv_sphere_add(segments=8, ring_count=6, radius=3.2, location=(sx * 36.0, 16.0, 162.0))
    w_joint = bpy.context.active_object
    w_joint.name = f"BlueEyes_WingJoint_{side_code.upper()}"
    link_and_parent(w_joint, "spine_02", MAT_SCALE)

    bpy.ops.mesh.primitive_cone_add(vertices=5, radius1=1.4, depth=7.0, location=(sx * 37.0, 14.5, 166.0))
    w_claw = bpy.context.active_object
    w_claw.name = f"BlueEyes_WingClaw_{side_code.upper()}"
    w_claw.rotation_euler = (0.3, sx * 0.4, 0)
    link_and_parent(w_claw, "spine_02", MAT_CLAW)

    # 3 Wing Finger Bone Struts
    finger_params = [
        {"name": "Top", "len": 36.0, "rad": 1.6, "rot": (-0.20, sx * 0.45, 0), "off": (sx * 52.0, 20.0, 180.0)},
        {"name": "Mid", "len": 40.0, "rad": 1.5, "rot": (-0.10, sx * 0.95, 0), "off": (sx * 58.0, 22.0, 160.0)},
        {"name": "Low", "len": 34.0, "rad": 1.4, "rot": (0.05, sx * 1.35, 0),  "off": (sx * 52.0, 22.0, 142.0)},
    ]
    for fp in finger_params:
        bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=fp["rad"], depth=fp["len"], location=fp["off"])
        f_obj = bpy.context.active_object
        f_obj.name = f"BlueEyes_WingFinger_{fp['name']}_{side_code.upper()}"
        f_obj.rotation_euler = fp["rot"]
        link_and_parent(f_obj, "spine_02", MAT_HORN)

    # Wing Membrane Panel (Large aerodynamic sail)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sx * 50.0, 21.0, 160.0))
    memb = bpy.context.active_object
    memb.name = f"BlueEyes_WingMembrane_{side_code.upper()}"
    memb.scale = (32.0, 0.45, 34.0)
    memb.rotation_euler = (-0.12, sx * 0.25, 0)
    link_and_parent(memb, "spine_02", MAT_WING_MEMB)

# ─── 5. FOREARMS & DRAGON TALON CLAWS ───────────────────────────────────────
print("Building Dragon Forearms & White Claws...")
for side, sx in (("L", 1), ("R", -1)):
    side_code = "l" if sx > 0 else "r"
    # Upper arm
    bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=4.6, depth=22.0, location=(sx * 26.0, 0, 138.0))
    u_arm = bpy.context.active_object
    u_arm.name = f"BlueEyes_UpperArm_{side_code.upper()}"
    u_arm.rotation_euler = (0, sx * 0.38, 0)
    link_and_parent(u_arm, f"upperarm_{side_code}", MAT_SCALE)

    # Forearm with elbow ridge
    bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=4.0, depth=22.0, location=(sx * 56.0, 0, 120.0))
    f_arm = bpy.context.active_object
    f_arm.name = f"BlueEyes_Forearm_{side_code.upper()}"
    f_arm.rotation_euler = (0, sx * 0.65, 0)
    link_and_parent(f_arm, f"lowerarm_{side_code}", MAT_SCALE)

    # Dragon Hand with 3 Curved White Talons
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sx * 80.0, 0, 96.0))
    hand = bpy.context.active_object
    hand.name = f"BlueEyes_Hand_{side_code.upper()}"
    hand.scale = (8.0, 7.5, 7.5)
    link_and_parent(hand, f"hand_{side_code}", MAT_SCALE)

    for ci, cy in enumerate([-3.2, 0.0, 3.2]):
        bpy.ops.mesh.primitive_cone_add(vertices=5, radius1=1.4, depth=7.5, location=(sx * 86.0, cy, 93.0))
        t_claw = bpy.context.active_object
        t_claw.name = f"BlueEyes_HandClaw_{side_code.upper()}_{ci}"
        t_claw.rotation_euler = (0, sx * 0.75, 0)
        link_and_parent(t_claw, f"hand_{side_code}", MAT_CLAW)

# ─── 6. POWERFUL DRAGON LEGS & GROUND TALONS ────────────────────────────────
print("Building Muscular Dragon Legs & Predatory Talons...")
for side, sx in (("L", 1), ("R", -1)):
    side_code = "l" if sx > 0 else "r"
    # Dragon Thigh
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=7.8, depth=32.0, location=(sx * 16.0, 0, 72.0))
    thigh = bpy.context.active_object
    thigh.name = f"BlueEyes_Thigh_{side_code.upper()}"
    link_and_parent(thigh, f"thigh_{side_code}", MAT_SCALE)

    # Knee armor spike
    bpy.ops.mesh.primitive_cone_add(vertices=5, radius1=2.2, depth=8.0, location=(sx * 16.0, -8.2, 58.0))
    k_spk = bpy.context.active_object
    k_spk.name = f"BlueEyes_KneeSpike_{side_code.upper()}"
    k_spk.rotation_euler = (0.55, 0, 0)
    link_and_parent(k_spk, f"thigh_{side_code}", MAT_HORN)

    # Dragon Calf / Shin
    bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=5.2, depth=32.0, location=(sx * 18.0, 0, 32.0))
    calf = bpy.context.active_object
    calf.name = f"BlueEyes_Calf_{side_code.upper()}"
    link_and_parent(calf, f"calf_{side_code}", MAT_SCALE)

    # Dragon Foot Base
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sx * 18.0, -5.5, 6.0))
    foot = bpy.context.active_object
    foot.name = f"BlueEyes_Foot_{side_code.upper()}"
    foot.scale = (8.5, 17.5, 5.5)
    link_and_parent(foot, f"foot_{side_code}", MAT_SCALE)

    # 3 Forward Talons
    for ti, tx in enumerate([-2.8, 0.0, 2.8]):
        bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=1.6, depth=9.5, location=(sx * 18.0 + tx, -16.0, 3.5))
        f_claw = bpy.context.active_object
        f_claw.name = f"BlueEyes_FootTalon_Fwd_{side_code.upper()}_{ti}"
        f_claw.rotation_euler = (math.pi / 2.0 - 0.2, 0, 0)
        link_and_parent(f_claw, f"foot_{side_code}", MAT_CLAW)

    # 1 Rear Dewclaw
    bpy.ops.mesh.primitive_cone_add(vertices=5, radius1=1.4, depth=7.0, location=(sx * 18.0, 5.5, 3.5))
    r_claw = bpy.context.active_object
    r_claw.name = f"BlueEyes_FootTalon_Rear_{side_code.upper()}"
    r_claw.rotation_euler = (-math.pi / 2.0 + 0.25, 0, 0)
    link_and_parent(r_claw, f"foot_{side_code}", MAT_CLAW)

# ─── 7. DRAGON TAIL WITH SPADE BLADE TIP ────────────────────────────────────
print("Building Sinuous Dragon Tail & Blade Tip...")
tail_segments = [
    {"y": 14.0, "z": 88.0, "r": 6.2, "d": 18.0, "rot": (-0.45, 0, 0)},
    {"y": 28.0, "z": 78.0, "r": 5.0, "d": 20.0, "rot": (-0.55, 0, 0)},
    {"y": 44.0, "z": 66.0, "r": 3.8, "d": 22.0, "rot": (-0.65, 0, 0)},
    {"y": 60.0, "z": 54.0, "r": 2.5, "d": 22.0, "rot": (-0.55, 0, 0)},
]
for ti, tp in enumerate(tail_segments):
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=tp["r"], depth=tp["d"], location=(0, tp["y"], tp["z"]))
    t_seg = bpy.context.active_object
    t_seg.name = f"BlueEyes_TailSeg_{ti}"
    t_seg.rotation_euler = tp["rot"]
    link_and_parent(t_seg, "pelvis", MAT_SCALE)

    # Tail dorsal fin spike
    bpy.ops.mesh.primitive_cone_add(vertices=5, radius1=1.6, depth=7.5, location=(0, tp["y"] - 1.5, tp["z"] + tp["r"] + 2.0))
    t_spk = bpy.context.active_object
    t_spk.name = f"BlueEyes_TailSpike_{ti}"
    t_spk.rotation_euler = (-0.75, 0, 0)
    link_and_parent(t_spk, "pelvis", MAT_HORN)

# Diamond-shaped Spade Dragon Blade at tip of tail
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 72.0, 44.0))
t_blade = bpy.context.active_object
t_blade.name = "BlueEyes_TailBlade"
t_blade.scale = (7.5, 14.0, 1.2)
t_blade.rotation_euler = (-0.55, 0, math.pi / 4.0)
link_and_parent(t_blade, "pelvis", MAT_HORN)

print(f"Saving blend file to: {OUT_BLEND}")
bpy.ops.wm.save_as_mainfile(filepath=str(OUT_BLEND))

bpy.ops.object.select_all(action='DESELECT')
for obj in bpy.data.objects:
    if obj.type in ("ARMATURE", "MESH"):
        obj.select_set(True)

bpy.ops.export_scene.gltf(
    filepath=str(OUT_GLB),
    use_selection=True,
    export_format='GLB',
    export_apply=False,
    export_animations=True,
    export_skins=True,
    export_yup=True
)

print("=== Blue-Eyes White Dragon 3D build completed successfully! ===")
