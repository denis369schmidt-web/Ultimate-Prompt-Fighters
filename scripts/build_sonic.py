"""Sonic the Hedgehog - High-Quality 3D Character Builder for Blender 4.5.5 LTS.

Features:
- Stylized iconic Sonic proportions (quills, peach muzzle, emerald eyes)
- 6 dynamic curved head quills + back spines + hedgehog tail
- Peach belly patch, peach arms and white cartoon gloves with rolled cuffs
- Signature Red Power Sneakers with white strap, gold buckle and rubber soles
- Standard 18-bone rigged skeleton compatible with all game combat animations
- Sonic Spin-Dash special sphere mesh for ultra-fast homing attack
- PBR materials assigned with matching naming conventions
- Export to godot/assets/models/sonic.glb
"""
import bpy, bmesh, math
from pathlib import Path
from mathutils import Vector, Matrix, Euler

ROOT = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate")
NINJA_GLB = ROOT / "godot/assets/models/ninja.glb"
CHAR_DIR = ROOT / "art/characters/sonic"
PREVIEWS = CHAR_DIR / "previews"
BLEND_OUT = CHAR_DIR / "PFU_Sonic.blend"
GLB_OUT = ROOT / "godot/assets/models/sonic.glb"

for d in (CHAR_DIR, PREVIEWS):
    d.mkdir(parents=True, exist_ok=True)

print("=== STARTING SONIC THE HEDGEHOG 3D BUILD ===")

# Reset Blender
bpy.ops.wm.read_factory_settings(use_empty=True)
sc = bpy.context.scene
sc.unit_settings.system = 'METRIC'

# Load Base 18-bone Rig and Animations from ninja.glb
print(f"Loading 18-bone skeleton from {NINJA_GLB}...")
bpy.ops.import_scene.gltf(filepath=str(NINJA_GLB))

armature = None
for obj in bpy.data.objects:
    if obj.type == "ARMATURE":
        armature = obj
        break
assert armature is not None, "18-bone Armature must be present"

# Delete ninja meshes, preserve armature and animation data
mesh_objs = [o for o in bpy.data.objects if o.type == "MESH"]
for m in mesh_objs:
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

MAT_BLUE_FUR  = make_mat("Sonic_Fur",    (0.05, 0.28, 0.73), rough=0.38, metal=0.08)
MAT_PEACH     = make_mat("Sonic_Skin",   (0.98, 0.81, 0.65), rough=0.52, metal=0.0)
MAT_RED_SHOE  = make_mat("Sonic_Shoe",   (0.85, 0.05, 0.05), rough=0.35, metal=0.15)
MAT_WHITE     = make_mat("Sonic_Glove",  (0.95, 0.95, 0.97), rough=0.65, metal=0.02)
MAT_GOLD      = make_mat("Sonic_Buckle", (0.95, 0.78, 0.12), rough=0.18, metal=0.92, emit=(1.0, 0.8, 0.1), emit_str=1.2)
MAT_EYE_GREEN = make_mat("Sonic_Eye",    (0.0, 0.85, 0.35),  rough=0.12, metal=0.10, emit=(0.0, 0.9, 0.4), emit_str=2.0)
MAT_BLACK     = make_mat("Sonic_Nose",   (0.02, 0.02, 0.03), rough=0.15, metal=0.20)
MAT_SPIN_GLOW = make_mat("Sonic_Spin",   (0.1, 0.6, 1.0),    rough=0.05, metal=0.50, emit=(0.1, 0.7, 1.0), emit_str=4.5)

# Helper: link object and parent to bone
def link_and_parent(obj, bone_name, mat=None):
    if obj.name not in sc.collection.objects:
        sc.collection.objects.link(obj)
    if mat:
        obj.data.materials.append(mat)
    # Set parent to armature with vertex group
    obj.parent = armature
    mod = obj.modifiers.new("Armature", "ARMATURE")
    mod.object = armature
    # Create single vertex group for rigid part binding
    vg = obj.vertex_groups.new(name=bone_name)
    all_indices = list(range(len(obj.data.vertices)))
    if all_indices:
        vg.add(all_indices, 1.0, 'REPLACE')
    # Shade smooth
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.shade_smooth()
    obj.select_set(False)
    return obj

# ─── 1. SONIC HEAD & QUILLS ───
print("Building Sonic Head & Quills...")
# Spherical head
bpy.ops.mesh.primitive_uv_sphere_add(segments=24, ring_count=16, radius=0.22, location=(0, 0, 1.38))
head = bpy.context.active_object
head.name = "Sonic_Head"
head.scale = (1.0, 1.05, 1.0)
link_and_parent(head, "Head", MAT_BLUE_FUR)

# 6 Large Curved Sonic Quills
quill_data = [
    # Top pair
    {"name": "Sonic_Quill_Top_L", "loc": (-0.08, 0.12, 1.48), "rot": (-0.45, 0.22, 0.0), "scale": (0.07, 0.07, 0.32)},
    {"name": "Sonic_Quill_Top_R", "loc": ( 0.08, 0.12, 1.48), "rot": (-0.45, -0.22, 0.0), "scale": (0.07, 0.07, 0.32)},
    # Mid pair
    {"name": "Sonic_Quill_Mid_L", "loc": (-0.11, 0.14, 1.38), "rot": (-0.25, 0.30, 0.0), "scale": (0.07, 0.07, 0.36)},
    {"name": "Sonic_Quill_Mid_R", "loc": ( 0.11, 0.14, 1.38), "rot": (-0.25, -0.30, 0.0), "scale": (0.07, 0.07, 0.36)},
    # Bottom pair
    {"name": "Sonic_Quill_Bot_L", "loc": (-0.07, 0.12, 1.28), "rot": (-0.05, 0.20, 0.0), "scale": (0.06, 0.06, 0.28)},
    {"name": "Sonic_Quill_Bot_R", "loc": ( 0.07, 0.12, 1.28), "rot": (-0.05, -0.20, 0.0), "scale": (0.06, 0.06, 0.28)},
]
for q in quill_data:
    bpy.ops.mesh.primitive_cone_add(vertices=16, radius1=q["scale"][0], radius2=0.005, depth=q["scale"][2], location=q["loc"])
    cone = bpy.context.active_object
    cone.name = q["name"]
    cone.rotation_euler = q["rot"]
    link_and_parent(cone, "Head", MAT_BLUE_FUR)

# Sonic Ears (Triangular cones at top sides)
for side, sx in (("L", -0.13), ("R", 0.13)):
    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.06, depth=0.10, location=(sx, -0.02, 1.55))
    ear = bpy.context.active_object
    ear.name = f"Sonic_Ear_{side}"
    ear.rotation_euler = (0.2, -0.3 if sx < 0 else 0.3, 0)
    link_and_parent(ear, "Head", MAT_BLUE_FUR)

    # Inner Ear (Peach)
    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.038, depth=0.08, location=(sx, -0.032, 1.55))
    inner = bpy.context.active_object
    inner.name = f"Sonic_InnerEar_{side}"
    inner.rotation_euler = (0.2, -0.3 if sx < 0 else 0.3, 0)
    link_and_parent(inner, "Head", MAT_PEACH)

# Peach Muzzle / Snout
bpy.ops.mesh.primitive_uv_sphere_add(segments=20, ring_count=12, radius=0.13, location=(0, -0.12, 1.34))
muzzle = bpy.context.active_object
muzzle.name = "Sonic_Muzzle"
muzzle.scale = (1.1, 0.85, 0.8)
link_and_parent(muzzle, "Head", MAT_PEACH)

# Black Button Nose
bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=8, radius=0.024, location=(0, -0.22, 1.38))
nose = bpy.context.active_object
nose.name = "Sonic_Nose"
link_and_parent(nose, "Head", MAT_BLACK)

# Eyes & Emerald Irises
for side, sx in (("L", -0.06), ("R", 0.06)):
    # Eye White
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=12, radius=0.055, location=(sx, -0.15, 1.44))
    eye_w = bpy.context.active_object
    eye_w.name = f"Sonic_EyeWhite_{side}"
    eye_w.scale = (0.75, 0.5, 1.1)
    link_and_parent(eye_w, "Head", MAT_WHITE)

    # Emerald Iris / Pupil
    bpy.ops.mesh.primitive_cylinder_add(radius=0.024, depth=0.015, location=(sx*0.85, -0.18, 1.44))
    iris = bpy.context.active_object
    iris.name = f"Sonic_Iris_{side}"
    iris.rotation_euler = (math.pi/2, 0, 0)
    link_and_parent(iris, "Head", MAT_EYE_GREEN)

# ─── 2. TORSO & PEACH BELLY ───
print("Building Sonic Torso & Peach Belly...")
bpy.ops.mesh.primitive_uv_sphere_add(segments=20, ring_count=14, radius=0.20, location=(0, 0, 1.05))
torso = bpy.context.active_object
torso.name = "Sonic_Torso"
torso.scale = (0.9, 0.85, 1.1)
link_and_parent(torso, "Spine", MAT_BLUE_FUR)

# Peach Belly patch
bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=12, radius=0.16, location=(0, -0.08, 1.05))
belly = bpy.context.active_object
belly.name = "Sonic_Belly"
belly.scale = (0.85, 0.45, 1.05)
link_and_parent(belly, "Spine", MAT_PEACH)

# Back spines (2 small quills on back)
for y_z, sy in [(-0.16, 1.10), (-0.14, 0.98)]:
    bpy.ops.mesh.primitive_cone_add(vertices=12, radius1=0.045, depth=0.16, location=(0, 0.16, sy))
    b_cone = bpy.context.active_object
    b_cone.name = f"Sonic_BackSpine_{int(sy*100)}"
    b_cone.rotation_euler = (-0.6, 0, 0)
    link_and_parent(b_cone, "Spine", MAT_BLUE_FUR)

# Tail
bpy.ops.mesh.primitive_cone_add(vertices=8, radius1=0.03, depth=0.10, location=(0, 0.16, 0.88))
tail = bpy.context.active_object
tail.name = "Sonic_Tail"
tail.rotation_euler = (-0.8, 0, 0)
link_and_parent(tail, "Hips", MAT_BLUE_FUR)

# ─── 3. ARMS, GLOVES & WHITE CUFFS ───
print("Building Sonic Arms & Gloves...")
for side, sx in (("L", -1), ("R", 1)):
    b_arm = "UpperArm.L" if sx < 0 else "UpperArm.R"
    b_fore = "Forearm.L" if sx < 0 else "Forearm.R"
    b_hand = "Hand.L" if sx < 0 else "Hand.R"

    # Slender Peach Upper Arm
    bpy.ops.mesh.primitive_cylinder_add(radius=0.038, depth=0.22, location=(sx*0.24, 0, 1.02))
    u_arm = bpy.context.active_object
    u_arm.name = f"Sonic_UpperArm_{'L' if sx < 0 else 'R'}"
    link_and_parent(u_arm, b_arm, MAT_PEACH)

    # Slender Peach Forearm
    bpy.ops.mesh.primitive_cylinder_add(radius=0.034, depth=0.20, location=(sx*0.38, 0, 0.90))
    f_arm = bpy.context.active_object
    f_arm.name = f"Sonic_Forearm_{'L' if sx < 0 else 'R'}"
    link_and_parent(f_arm, b_fore, MAT_PEACH)

    # Thick White Glove Cuff (Donut ring torus)
    bpy.ops.mesh.primitive_torus_add(major_radius=0.055, minor_radius=0.022, location=(sx*0.48, 0, 0.82))
    cuff = bpy.context.active_object
    cuff.name = f"Sonic_GloveCuff_{'L' if sx < 0 else 'R'}"
    cuff.rotation_euler = (0, math.pi/2, 0)
    link_and_parent(cuff, b_hand, MAT_WHITE)

    # White Cartoon Glove Fist
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=12, radius=0.075, location=(sx*0.54, 0, 0.80))
    glove = bpy.context.active_object
    glove.name = f"Sonic_Glove_{'L' if sx < 0 else 'R'}"
    link_and_parent(glove, b_hand, MAT_WHITE)

# ─── 4. LEGS, SOCKS & RED POWER SNEAKERS ───
print("Building Sonic Legs & Power Sneakers...")
for side, sx in (("L", -1), ("R", 1)):
    b_thigh = "Thigh.L" if sx < 0 else "Thigh.R"
    b_shin  = "Shin.L" if sx < 0 else "Shin.R"
    b_foot  = "Foot.L" if sx < 0 else "Foot.R"

    # Blue Thigh
    bpy.ops.mesh.primitive_cylinder_add(radius=0.042, depth=0.28, location=(sx*0.11, 0, 0.72))
    thigh = bpy.context.active_object
    thigh.name = f"Sonic_Thigh_{'L' if sx < 0 else 'R'}"
    link_and_parent(thigh, b_thigh, MAT_BLUE_FUR)

    # Blue Shin
    bpy.ops.mesh.primitive_cylinder_add(radius=0.038, depth=0.28, location=(sx*0.11, 0, 0.44))
    shin = bpy.context.active_object
    shin.name = f"Sonic_Shin_{'L' if sx < 0 else 'R'}"
    link_and_parent(shin, b_shin, MAT_BLUE_FUR)

    # White Sock Cuff (Torus at ankle)
    bpy.ops.mesh.primitive_torus_add(major_radius=0.065, minor_radius=0.026, location=(sx*0.11, 0, 0.25))
    sock = bpy.context.active_object
    sock.name = f"Sonic_SockCuff_{'L' if sx < 0 else 'R'}"
    link_and_parent(sock, b_foot, MAT_WHITE)

    # Red Power Sneaker Main Body
    bpy.ops.mesh.primitive_uv_sphere_add(segments=18, ring_count=12, radius=0.12, location=(sx*0.11, -0.06, 0.12))
    shoe = bpy.context.active_object
    shoe.name = f"Sonic_Shoe_{'L' if sx < 0 else 'R'}"
    shoe.scale = (0.75, 1.4, 0.75)
    link_and_parent(shoe, b_foot, MAT_RED_SHOE)

    # White Strap across shoe
    bpy.ops.mesh.primitive_cylinder_add(radius=0.092, depth=0.05, location=(sx*0.11, -0.06, 0.13))
    strap = bpy.context.active_object
    strap.name = f"Sonic_ShoeStrap_{'L' if sx < 0 else 'R'}"
    strap.scale = (0.78, 1.42, 0.78)
    link_and_parent(strap, b_foot, MAT_WHITE)

    # Golden Buckle on outer side of shoe
    buckle_x = sx * 0.185
    bpy.ops.mesh.primitive_cube_add(size=0.048, location=(buckle_x, -0.06, 0.14))
    buckle = bpy.context.active_object
    buckle.name = f"Sonic_Buckle_{'L' if sx < 0 else 'R'}"
    buckle.scale = (0.3, 1.0, 1.0)
    link_and_parent(buckle, b_foot, MAT_GOLD)

# ─── 5. SONIC SPIN-DASH SPHERE (Special Attack VFX Mesh) ───
print("Building Sonic Spin-Dash Sphere...")
bpy.ops.mesh.primitive_uv_sphere_add(segments=24, ring_count=16, radius=0.34, location=(0, 0, 1.0))
spin = bpy.context.active_object
spin.name = "Sonic_SpinSphere"
link_and_parent(spin, "Spine", MAT_SPIN_GLOW)
spin.hide_render = False

# Save Blender File
print(f"Saving .blend project to {BLEND_OUT}...")
bpy.ops.wm.save_as_mainfile(filepath=str(BLEND_OUT))

# Export Game-Ready GLB
print(f"Exporting GLB to {GLB_OUT}...")
bpy.ops.object.select_all(action='DESELECT')
for obj in bpy.data.objects:
    if obj.type in ("ARMATURE", "MESH"):
        obj.select_set(True)

bpy.ops.export_scene.gltf(
    filepath=str(GLB_OUT),
    use_selection=True,
    export_format='GLB',
    export_apply=True,
    export_yup=True,
    export_animations=True
)

print("=== SONIC THE HEDGEHOG BUILD COMPLETE ===")
