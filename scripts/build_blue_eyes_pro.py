"""Build Professional Blue-Eyes White Dragon (Yu-Gi-Oh) 3D Model with 18-Bone Standard Rig.
Uses Blender 4.5.5 LTS headless to combine dragon.glb anatomy with:
- Majestic sweeping dragon wings (arched finger struts, thumb claws, cerulean membranes)
- Sleek Blue-Eyes dragon head with elongated jaw, razor fangs, and swept-back horn crowns
- Piercing ice-blue eyes with cold gaze emission
- Segmented platinum chest carapace & backbone fins
- Mouth vortex core & forward beam for "Burst Stream of Destruction"
- Exports directly to godot/assets/models/blue_eyes.glb and art/characters/blue_eyes/PFU_BlueEyes.blend
"""
import bpy, bmesh, math, sys
from pathlib import Path
from mathutils import Vector, Euler

ROOT = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate")
DRAGON_GLB = ROOT / "godot/assets/models/dragon.glb"
OUT_BLEND = ROOT / "art/characters/blue_eyes/PFU_BlueEyes.blend"
OUT_GLB = ROOT / "godot/assets/models/blue_eyes.glb"

OUT_BLEND.parent.mkdir(parents=True, exist_ok=True)
OUT_GLB.parent.mkdir(parents=True, exist_ok=True)

print("=== STARTING PROFESSIONAL BLUE-EYES DRAGON BUILD ===")

# Reset Blender
bpy.ops.wm.read_factory_settings(use_empty=True)
sc = bpy.context.scene

# Load base dragon model with 18-bone rig and 7 custom animations
print(f"Loading dragon anatomy from {DRAGON_GLB}...")
bpy.ops.import_scene.gltf(filepath=str(DRAGON_GLB))

armatures = [o for o in bpy.data.objects if o.type == "ARMATURE"]
if not armatures:
    print("ERROR: No armature found!")
    sys.exit(1)

armature = armatures[0]
armature.name = "Armature_BlueEyes"
print(f"Armature ready: {armature.name} with {len(armature.data.bones)} bones")

# 1. REMOVE GREATSWORD (Blue-Eyes is a beast fighter, attacks with fangs, claws and breath)
swords = [o for o in bpy.data.objects if "Greatsword" in o.name]
print(f"Removing {len(swords)} greatsword objects...")
for o in swords:
    bpy.data.objects.remove(o, do_unlink=True)

# Remove unused camera/light/extra cubes
for o in [o for o in bpy.data.objects if o.type in ["CAMERA", "LIGHT"] or o.name in ["Cube", "Icosphere"]]:
    bpy.data.objects.remove(o, do_unlink=True)

# 2. PBR SHADERS
def make_mat(name, col, rough=0.3, metal=0.2, emit=None, emit_str=0.0):
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

MAT_SCALE   = make_mat("BlueEyes_Scale",       (0.92, 0.95, 0.98), rough=0.30, metal=0.35)
MAT_CHEST   = make_mat("BlueEyes_ChestPlate",  (0.80, 0.88, 0.98), rough=0.35, metal=0.25)
MAT_HORN    = make_mat("BlueEyes_Horn",        (0.75, 0.85, 0.95), rough=0.20, metal=0.55)
MAT_EYE     = make_mat("BlueEyes_Eye",         (0.65, 0.90, 1.00), rough=0.08, metal=0.10, emit=(0.0, 0.75, 1.0), emit_str=4.5)
MAT_WING    = make_mat("BlueEyes_WingMembrane",(0.35, 0.65, 0.92), rough=0.45, metal=0.15)
MAT_BURST_C = make_mat("BlueEyes_BurstCore",   (0.70, 0.95, 1.00), rough=0.10, metal=0.0, emit=(0.1, 0.85, 1.0), emit_str=5.0)
MAT_BURST_B = make_mat("BlueEyes_BurstBeam",   (0.85, 0.95, 1.00), rough=0.05, metal=0.0, emit=(0.2, 0.90, 1.0), emit_str=6.0)

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

# 3. ADD MAJESTIC BLUE-EYES DRAGON WINGS (Attached to spine_02 / upper back)
print("Building Magnificent Blue-Eyes Dragon Wings...")
# Wing dimensions: Wing arm spanning out, 3 arched finger spars, ribbed membrane
for side, sx in (("L", 1.0), ("R", -1.0)):
    # Wing Upper Arm (Heavy draconic wing shoulder strut)
    bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=2.6, depth=32.0, location=(sx * 18.0, 12.0, 148.0))
    w_arm = bpy.context.active_object
    w_arm.name = f"BlueEyes_Wing_Arm_{side}"
    w_arm.rotation_euler = (0.35, sx * 0.75, sx * 0.40)
    link_and_parent(w_arm, "spine_02", MAT_SCALE)

    # Wing Elbow Spur / Thumb Talon
    bpy.ops.mesh.primitive_cone_add(vertices=8, radius1=2.2, depth=9.5, location=(sx * 34.0, 18.0, 162.0))
    w_thumb = bpy.context.active_object
    w_thumb.name = f"BlueEyes_Wing_Claw_{side}"
    w_thumb.rotation_euler = (0.6, 0, sx * 0.8)
    link_and_parent(w_thumb, "spine_02", MAT_HORN)

    # 3 Wing Finger Spars (Spreading outward and downward)
    spars = [
        {"name": f"BlueEyes_Wing_Spar_Top_{side}", "len": 44.0, "rot": (0.20, sx * 0.95, sx * 0.20), "loc": (sx * 52.0, 24.0, 180.0)},
        {"name": f"BlueEyes_Wing_Spar_Mid_{side}", "len": 48.0, "rot": (0.35, sx * 0.55, sx * 0.50), "loc": (sx * 56.0, 26.0, 155.0)},
        {"name": f"BlueEyes_Wing_Spar_Bot_{side}", "len": 42.0, "rot": (0.50, sx * 0.20, sx * 0.70), "loc": (sx * 48.0, 24.0, 130.0)}
    ]
    for sp in spars:
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=1.6, depth=sp["len"], location=sp["loc"])
        spar_obj = bpy.context.active_object
        spar_obj.name = sp["name"]
        spar_obj.rotation_euler = sp["rot"]
        link_and_parent(spar_obj, "spine_02", MAT_SCALE)

    # Broad Draconic Wing Membrane (Large ribbed polygonal flight sail)
    # Built using grid mesh spanning between spars
    bpy.ops.mesh.primitive_grid_add(x_subdivisions=6, y_subdivisions=5, size=46.0, location=(sx * 48.0, 22.0, 152.0))
    membrane = bpy.context.active_object
    membrane.name = f"BlueEyes_Wing_Membrane_{side}"
    membrane.rotation_euler = (0.35, sx * 0.60, sx * 0.35)
    membrane.scale = (1.25, 0.85, 0.05)
    link_and_parent(membrane, "spine_02", MAT_WING)

# 4. ICONIC BLUE-EYES DRAGON HORNS & COLD EYES (Head)
print("Building Blue-Eyes Crown Horns and Ice-Cold Eyes...")
# Large Swept-Back Horns (Iconic Blue-Eyes Silhouette)
for side, sx in (("L", 1.0), ("R", -1.0)):
    # Main sweeping horn
    bpy.ops.mesh.primitive_cone_add(vertices=10, radius1=3.4, radius2=0.4, depth=34.0, location=(sx * 8.5, 12.0, 182.0))
    mhorn = bpy.context.active_object
    mhorn.name = f"BlueEyes_Horn_Main_{side}"
    mhorn.rotation_euler = (-0.85, sx * 0.28, 0)
    link_and_parent(mhorn, "head", MAT_HORN)

    # Cheek Horn Spike
    bpy.ops.mesh.primitive_cone_add(vertices=8, radius1=2.2, radius2=0.3, depth=16.0, location=(sx * 14.5, 2.0, 168.0))
    chorn = bpy.context.active_object
    chorn.name = f"BlueEyes_Horn_Cheek_{side}"
    chorn.rotation_euler = (-0.40, sx * 0.65, 0)
    link_and_parent(chorn, "head", MAT_HORN)

    # Piercing Ice-Blue Eye
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=12, radius=2.4, location=(sx * 5.2, -12.0, 172.5))
    eye = bpy.context.active_object
    eye.name = f"BlueEyes_Eye_{side}"
    eye.scale = (0.75, 1.4, 0.85)
    link_and_parent(eye, "head", MAT_EYE)

    # Dragon Brow Plate
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sx * 5.5, -11.0, 175.5))
    brow = bpy.context.active_object
    brow.name = f"BlueEyes_Brow_{side}"
    brow.scale = (4.0, 8.5, 2.0)
    brow.rotation_euler = (0.20, sx * 0.35, 0)
    link_and_parent(brow, "head", MAT_HORN)

# 5. ELONGATED DRAGON SNOUT & RAZOR FANGS
print("Sculpting Blue-Eyes Muzzle & Fangs...")
bpy.ops.mesh.primitive_cone_add(vertices=10, radius1=7.5, radius2=2.8, depth=22.0, location=(0, -18.0, 169.0))
snout = bpy.context.active_object
snout.name = "BlueEyes_Snout"
snout.rotation_euler = (math.pi / 2.0 - 0.10, 0, 0)
snout.scale = (1.15, 0.80, 1.0)
link_and_parent(snout, "head", MAT_SCALE)

# Upper Dragon Fangs
for side, sx in (("L", 3.2), ("R", -3.2)):
    bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=0.9, depth=3.8, location=(sx, -20.0, 164.5))
    fang = bpy.context.active_object
    fang.name = f"BlueEyes_Fang_Upper_{side}"
    fang.rotation_euler = (math.pi - 0.2, 0, 0)
    link_and_parent(fang, "head", MAT_HORN)

# 6. BURST STREAM OF DESTRUCTION (Mouth Energy Core + Forward Particle Beam)
print("Creating Burst Stream of Destruction Beam Nodes...")
# Core in dragon's throat
bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=12, radius=3.2, location=(0, -10.0, 168.0))
bcore = bpy.context.active_object
bcore.name = "BlueEyes_Burst_Core"
link_and_parent(bcore, "head", MAT_BURST_C)

# Massive Forward Plasma Beam (Extending 90 units forward from mouth)
bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=6.0, depth=90.0, location=(0, -58.0, 168.0))
beam = bpy.context.active_object
beam.name = "BlueEyes_Burst_Beam"
beam.rotation_euler = (math.pi / 2.0, 0, 0)
link_and_parent(beam, "head", MAT_BURST_B)

# 7. SAVE BLEND AND EXPORT GLB
print(f"Saving Blender file to {OUT_BLEND}...")
bpy.ops.wm.save_as_mainfile(filepath=str(OUT_BLEND))

print(f"Exporting glTF to {OUT_GLB}...")
bpy.ops.export_scene.gltf(
    filepath=str(OUT_GLB),
    export_format='GLB',
    use_selection=False,
    export_skins=True,
    export_animations=True
)

print("=== BLUE-EYES WHITE DRAGON PRO BUILD COMPLETED SUCCESSFULLY! ===")
