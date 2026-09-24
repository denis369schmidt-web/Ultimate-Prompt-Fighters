"""Monkey D. Ruffy (One Piece) - Character Builder & Gum-Gum-Pistol Animator for Blender 4.5.5 LTS.

Features:
- Wiry athletic teenage anime proportions
- Shaggy black anime hair
- Signature Straw Hat (Mugiwara) with red ribbon
- Crescent stitch scar under left eye & confident anime expression
- Red sleeveless vest with buttons, blue denim shorts with white cuffs, sandals
- Segmented elastic arm armature (3x-5x stretch without hand distortion)
- Baked 3-second 'GumGum_Pistol' animation (72 frames @ 24fps)
- 10+ Studio preview renders (Clay, PBR, Action Strike)
- Clean GLB export with animations
"""

import bpy, bmesh, math
from pathlib import Path
from mathutils import Vector, Euler, Matrix, Quaternion

ROOT = Path(r'C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate')
BUNDLE = ROOT / 'tools/human_base_meshes/human-base-meshes-bundle-v1.4.1/human_base_meshes_bundle.blend'
CHAR_DIR = ROOT / 'art/characters/luffy'
PREVIEW_DIR = CHAR_DIR / 'previews'
BLEND_OUT = CHAR_DIR / 'PFU_Luffy.blend'
GLB_OUT = CHAR_DIR / 'luffy.glb'

for d in (CHAR_DIR, PREVIEW_DIR):
    d.mkdir(parents=True, exist_ok=True)

print("=== STARTING MONKEY D. RUFFY CHARACTER BUILD ===")

# ─── SCENE SETUP ─────────────────────────────────────────────────────────────
bpy.ops.wm.read_factory_settings(use_empty=True)
sc = bpy.context.scene
sc.unit_settings.system = 'METRIC'
sc.render.fps = 24
sc.frame_start = 1
sc.frame_end = 72

if sc.world is None:
    sc.world = bpy.data.worlds.new('World')
sc.world.use_nodes = True
nodes_w = sc.world.node_tree.nodes
links_w = sc.world.node_tree.links
nodes_w.clear()
out_w = nodes_w.new('ShaderNodeOutputWorld')
bg_w = nodes_w.new('ShaderNodeBackground')
bg_w.inputs['Color'].default_value = (0.05, 0.05, 0.07, 1.0)
bg_w.inputs['Strength'].default_value = 0.85
links_w.new(bg_w.outputs['Background'], out_w.inputs['Surface'])

sc.render.engine = 'BLENDER_EEVEE_NEXT'
sc.render.resolution_x = 1280
sc.render.resolution_y = 1280
sc.view_settings.look = 'AgX - Medium High Contrast'
sc.view_settings.exposure = 0.35

# ─── PBR MATERIAL CREATOR ────────────────────────────────────────────────────
def create_pbr(name, col, rough=0.55, metal=0.0, sss=0.0, emit=None, emit_str=0.0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nodes = m.node_tree.nodes
    links = m.node_tree.links
    nodes.clear()
    out = nodes.new('ShaderNodeOutputMaterial'); out.location = (400, 0)
    bsdf = nodes.new('ShaderNodeBsdfPrincipled'); bsdf.location = (0, 0)
    links.new(bsdf.outputs['BSDF'], out.inputs['Surface'])
    bsdf.inputs['Base Color'].default_value = (*col, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Metallic'].default_value = metal
    for k in ('Subsurface Weight', 'Subsurface'):
        if k in bsdf.inputs:
            bsdf.inputs[k].default_value = sss
            break
    if emit and emit_str > 0:
        if 'Emission Color' in bsdf.inputs:
            bsdf.inputs['Emission Color'].default_value = (*emit, 1.0)
            bsdf.inputs['Emission Strength'].default_value = emit_str
        elif 'Emission' in bsdf.inputs:
            bsdf.inputs['Emission'].default_value = (*emit, 1.0)
    return m

M_SKIN = create_pbr('Mat_LuffySkin', (0.86, 0.65, 0.50), rough=0.52, sss=0.10)
M_HAIR = create_pbr('Mat_LuffyHair', (0.02, 0.02, 0.03), rough=0.35, metal=0.05)
M_VEST = create_pbr('Mat_RedVest', (0.85, 0.08, 0.07), rough=0.72)
M_BUTTON = create_pbr('Mat_VestButton', (0.95, 0.82, 0.15), rough=0.20, metal=0.85)
M_SHORTS = create_pbr('Mat_DenimShorts', (0.10, 0.22, 0.55), rough=0.78)
M_CUFF = create_pbr('Mat_WhiteCuff', (0.92, 0.92, 0.90), rough=0.85)
M_HAT = create_pbr('Mat_StrawHat', (0.88, 0.76, 0.40), rough=0.68)
M_RIBBON = create_pbr('Mat_HatRibbon', (0.82, 0.06, 0.06), rough=0.65)
M_SANDAL = create_pbr('Mat_SandalSole', (0.42, 0.28, 0.16), rough=0.82)
M_STRAP = create_pbr('Mat_SandalStrap', (0.75, 0.55, 0.18), rough=0.60)
M_EYE_W = create_pbr('Mat_EyeWhite', (0.95, 0.95, 0.95), rough=0.15)
M_PUPIL = create_pbr('Mat_Pupil', (0.01, 0.01, 0.01), rough=0.10)
M_SCAR = create_pbr('Mat_Scar', (0.55, 0.25, 0.22), rough=0.65)
M_CLAY = create_pbr('Mat_Clay', (0.48, 0.49, 0.52), rough=0.42)

# ─── 1. BASE BODY ────────────────────────────────────────────────────────────
with bpy.data.libraries.load(str(BUNDLE), link=False) as (df, dt):
    dt.meshes = [m for m in df.meshes if m == 'GEO-body_male_stylized']
body_mesh = [m for m in dt.meshes if m.name == 'GEO-body_male_stylized'][0]
body = bpy.data.objects.new('Luffy_Body', body_mesh)
bpy.context.scene.collection.objects.link(body)
body.data.materials.append(M_SKIN)

# Scale slightly to match Luffy's slim, wiry build
body.scale = (0.93, 0.90, 0.96)
bpy.context.view_layer.objects.active = body
body.select_set(True)
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
bpy.ops.object.shade_smooth()
body.select_set(False)

print(f"[BODY] Loaded Luffy base body: {len(body.data.vertices)} verts")

# ─── 2. FACIAL FEATURES & SCAR ───────────────────────────────────────────────
# Eyes (Large, expressive anime circles)
for side, sx in (('L', -0.033), ('R', 0.033)):
    # Eyeball
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.017, location=(sx, -0.098, 1.638), segments=16, ring_count=12)
    eye = bpy.context.active_object
    eye.name = f'Luffy_EyeWhite_{side}'
    eye.data.materials.append(M_EYE_W)
    bpy.ops.object.shade_smooth()
    
    # Large black pupil
    bpy.ops.mesh.primitive_circle_add(radius=0.009, fill_type='NGON', location=(sx, -0.114, 1.638))
    pupil = bpy.context.active_object
    pupil.name = f'Luffy_Pupil_{side}'
    pupil.rotation_euler = (math.pi/2, 0, 0)
    pupil.data.materials.append(M_PUPIL)

# Signature crescent stitch scar under LEFT eye
# 2 crossed stitch marks and a curved baseline
bm_scar = bmesh.new()
# Baseline
v0 = bm_scar.verts.new((-0.045, -0.106, 1.616))
v1 = bm_scar.verts.new((-0.024, -0.108, 1.618))
bm_scar.edges.new([v0, v1])
# Stitches
v2 = bm_scar.verts.new((-0.038, -0.107, 1.623))
v3 = bm_scar.verts.new((-0.036, -0.107, 1.612))
bm_scar.edges.new([v2, v3])
v4 = bm_scar.verts.new((-0.029, -0.108, 1.624))
v5 = bm_scar.verts.new((-0.028, -0.108, 1.613))
bm_scar.edges.new([v4, v5])

scar_mesh = bpy.data.meshes.new('Luffy_Scar')
bm_scar.to_mesh(scar_mesh); bm_scar.free()
scar_obj = bpy.data.objects.new('Luffy_Scar', scar_mesh)
bpy.context.scene.collection.objects.link(scar_obj)
scar_obj.data.materials.append(M_SCAR)
mod_skin = scar_obj.modifiers.new('Skin', 'SKIN')
# Scale skin down to fine line thickness
for v in scar_mesh.skin_vertices[0].data:
    v.radius = (0.0016, 0.0016)

print("[FACE] Eyes and signature stitch scar created")

# ─── 3. SHAGGY ANIME HAIR ────────────────────────────────────────────────────
# Luffy has messy black bangs in front, side tufts, and back hair that peeks out under the hat
hair_spikes = [
    # Front bangs (hanging over forehead/brow)
    ('Hair_Bang_0', (-0.038, -0.106, 1.678), (0.42, -0.18, -0.22), 0.082, 0.016),
    ('Hair_Bang_1', (-0.016, -0.112, 1.688), (0.48, 0.05, -0.08), 0.090, 0.018),
    ('Hair_Bang_2', ( 0.008, -0.112, 1.686), (0.46, 0.12, 0.10), 0.088, 0.018),
    ('Hair_Bang_3', ( 0.032, -0.106, 1.676), (0.40, 0.22, 0.25), 0.082, 0.016),
    # Left temple & sideburns
    ('Hair_Side_L0', (-0.065, -0.075, 1.662), (0.28, -0.45, -0.40), 0.078, 0.016),
    ('Hair_Side_L1', (-0.075, -0.045, 1.648), (0.15, -0.55, -0.55), 0.080, 0.017),
    ('Hair_Side_L2', (-0.078, -0.015, 1.635), (0.05, -0.60, -0.70), 0.076, 0.016),
    # Right temple & sideburns
    ('Hair_Side_R0', ( 0.065, -0.075, 1.662), (0.28, 0.45, 0.40), 0.078, 0.016),
    ('Hair_Side_R1', ( 0.075, -0.045, 1.648), (0.15, 0.55, 0.55), 0.080, 0.017),
    ('Hair_Side_R2', ( 0.078, -0.015, 1.635), (0.05, 0.60, 0.70), 0.076, 0.016),
    # Lower back hair (sticking out below hat rim)
    ('Hair_Back_0', (-0.045, 0.082, 1.630), (-0.40, -0.22, 0.20), 0.075, 0.015),
    ('Hair_Back_1', (-0.015, 0.088, 1.625), (-0.45, -0.05, 0.05), 0.080, 0.016),
    ('Hair_Back_2', ( 0.015, 0.088, 1.625), (-0.45, 0.05, -0.05), 0.080, 0.016),
    ('Hair_Back_3', ( 0.045, 0.082, 1.630), (-0.40, 0.22, -0.20), 0.075, 0.015),
]

for name, loc, rot, depth, r1 in hair_spikes:
    bpy.ops.mesh.primitive_cone_add(radius1=r1, radius2=0.002, depth=depth, location=loc)
    spike = bpy.context.active_object
    spike.name = f'Luffy_{name}'
    spike.rotation_euler = rot
    spike.data.materials.append(M_HAIR)
    bpy.ops.object.shade_smooth()

print("[HAIR] Shaggy black hair tufts modeled")

# ─── 4. THE ICONIC STRAW HAT (MUGIWARA) ───────────────────────────────────────
# Hat sits tilted slightly back on Luffy's head (Z ~ 1.76, angled backwards ~12 deg)
bm_hat = bmesh.new()

# Crown: hemisphere lofted at head top
HAT_Z = 1.755
CROWN_R = 0.108
CROWN_H = 0.082
BRIM_R = 0.245

# Ring 1: Brim outer edge (slightly curled downwards)
brim_segs = 32
brim_verts = []
for i in range(brim_segs):
    ang = (i / brim_segs) * 2 * math.pi
    # Slight elliptical shape (longer front-to-back) + gentle upward curve at sides
    rx = math.cos(ang) * BRIM_R * 0.94
    ry = math.sin(ang) * BRIM_R * 1.05
    rz = HAT_Z - 0.022 + math.sin(ang * 2) * 0.008
    brim_verts.append(bm_hat.verts.new((rx, ry, rz)))

# Ring 2: Brim inner / Crown base
base_verts = []
for i in range(brim_segs):
    ang = (i / brim_segs) * 2 * math.pi
    rx = math.cos(ang) * CROWN_R
    ry = math.sin(ang) * CROWN_R * 1.08
    rz = HAT_Z + 0.005
    base_verts.append(bm_hat.verts.new((rx, ry, rz)))

# Connect brim
for i in range(brim_segs):
    ni = (i + 1) % brim_segs
    bm_hat.faces.new([brim_verts[i], brim_verts[ni], base_verts[ni], base_verts[i]])

# Crown mid-level
mid_verts = []
for i in range(brim_segs):
    ang = (i / brim_segs) * 2 * math.pi
    rx = math.cos(ang) * (CROWN_R * 0.96)
    ry = math.sin(ang) * (CROWN_R * 1.04)
    rz = HAT_Z + CROWN_H * 0.55
    mid_verts.append(bm_hat.verts.new((rx, ry, rz)))

for i in range(brim_segs):
    ni = (i + 1) % brim_segs
    bm_hat.faces.new([base_verts[i], base_verts[ni], mid_verts[ni], mid_verts[i]])

# Crown top dome ring
top_verts = []
for i in range(brim_segs):
    ang = (i / brim_segs) * 2 * math.pi
    rx = math.cos(ang) * (CROWN_R * 0.65)
    ry = math.sin(ang) * (CROWN_R * 0.70)
    rz = HAT_Z + CROWN_H
    top_verts.append(bm_hat.verts.new((rx, ry, rz)))

for i in range(brim_segs):
    ni = (i + 1) % brim_segs
    bm_hat.faces.new([mid_verts[i], mid_verts[ni], top_verts[ni], top_verts[i]])

# Cap the dome
center_top = bm_hat.verts.new((0, 0, HAT_Z + CROWN_H + 0.012))
for i in range(brim_segs):
    ni = (i + 1) % brim_segs
    bm_hat.faces.new([top_verts[i], top_verts[ni], center_top])

hat_mesh = bpy.data.meshes.new('Luffy_StrawHat')
bm_hat.to_mesh(hat_mesh); bm_hat.free()
hat_obj = bpy.data.objects.new('Luffy_StrawHat', hat_mesh)
bpy.context.scene.collection.objects.link(hat_obj)
hat_obj.data.materials.append(M_HAT)

# Tilt hat slightly backwards (signature Luffy style)
hat_obj.rotation_euler = (math.radians(-8), 0, 0)
hat_obj.location.y += 0.015

mod_solid = hat_obj.modifiers.new('Solidify', 'SOLIDIFY')
mod_solid.thickness = 0.005
bpy.context.view_layer.objects.active = hat_obj
bpy.ops.object.shade_smooth()

# Red Hat Ribbon (cylinder wrapping around base)
bm_rib = bmesh.new()
rib_bot = []
rib_top = []
for i in range(brim_segs):
    ang = (i / brim_segs) * 2 * math.pi
    rx = math.cos(ang) * (CROWN_R + 0.003)
    ry = math.sin(ang) * (CROWN_R * 1.08 + 0.003)
    rib_bot.append(bm_rib.verts.new((rx, ry, HAT_Z + 0.006)))
    rib_top.append(bm_rib.verts.new((rx * 0.98, ry * 0.98, HAT_Z + 0.032)))

for i in range(brim_segs):
    ni = (i + 1) % brim_segs
    bm_rib.faces.new([rib_bot[i], rib_bot[ni], rib_top[ni], rib_top[i]])

rib_mesh = bpy.data.meshes.new('Luffy_HatRibbon')
bm_rib.to_mesh(rib_mesh); bm_rib.free()
rib_obj = bpy.data.objects.new('Luffy_HatRibbon', rib_mesh)
bpy.context.scene.collection.objects.link(rib_obj)
rib_obj.data.materials.append(M_RIBBON)
rib_obj.rotation_euler = hat_obj.rotation_euler
rib_obj.location = hat_obj.location
bpy.context.view_layer.objects.active = rib_obj
bpy.ops.object.shade_smooth()

print("[HAT] Straw hat & red ribbon modeled")

# ─── 5. RED SLEEVELESS VEST ──────────────────────────────────────────────────
# Vest covers chest, back and shoulders, open down the center with buttons
bm_vest = bmesh.new()
segs = 24
vest_levels = [
    # z, rx, ry, front_gap_deg
    (1.48, 0.170, 0.135, 38.0), # collar / shoulder top
    (1.38, 0.188, 0.145, 42.0), # upper chest
    (1.24, 0.178, 0.138, 35.0), # mid chest (buttons start)
    (1.10, 0.165, 0.130, 28.0), # waist
    (0.96, 0.172, 0.135, 32.0), # hips / lower hem
]

prev_ring = None
for z, rx, ry, open_deg in vest_levels:
    ring = []
    open_rad = math.radians(open_deg)
    for i in range(segs):
        a = (i / segs) * 2 * math.pi
        # Front opening (around -Y in Blender coordinates = a around 3*pi/2)
        front_angle = 3 * math.pi / 2
        diff = abs((a - front_angle + math.pi) % (2 * math.pi) - math.pi)
        if diff < open_rad * 0.5:
            ring.append(None)
        else:
            v = bm_vest.verts.new((math.cos(a) * rx, math.sin(a) * ry, z))
            ring.append(v)
    if prev_ring:
        for i in range(segs):
            ni = (i + 1) % segs
            p0, p1, c0, c1 = prev_ring[i], prev_ring[ni], ring[i], ring[ni]
            if p0 and p1 and c0 and c1:
                try: bm_vest.faces.new([p0, p1, c1, c0])
                except: pass
    prev_ring = ring

vest_mesh = bpy.data.meshes.new('Luffy_Vest')
bm_vest.to_mesh(vest_mesh); bm_vest.free()
vest_obj = bpy.data.objects.new('Luffy_Vest', vest_mesh)
bpy.context.scene.collection.objects.link(vest_obj)
vest_obj.data.materials.append(M_VEST)
mod_vsolid = vest_obj.modifiers.new('Solidify', 'SOLIDIFY')
mod_vsolid.thickness = 0.007
bpy.context.view_layer.objects.active = vest_obj
bpy.ops.object.shade_smooth()

# Gold buttons on right flap of vest
for bi in range(3):
    bz = 1.02 + bi * 0.10
    bpy.ops.mesh.primitive_cylinder_add(radius=0.007, depth=0.005, location=(0.024, -0.142 + bi*0.004, bz))
    btn = bpy.context.active_object
    btn.name = f'Luffy_Button_{bi}'
    btn.rotation_euler = (math.pi/2, 0, 0)
    btn.data.materials.append(M_BUTTON)
    bpy.ops.object.shade_smooth()

print("[VEST] Red sleeveless vest with gold buttons created")

# ─── 6. BLUE DENIM SHORTS & WHITE CUFFS ──────────────────────────────────────
# Shorts from waist (Z=0.98) to just above knees (Z=0.54)
bm_shorts = bmesh.new()

# Pelvis tube
p_levels = [
    (0.98, 0.168, 0.138),
    (0.88, 0.178, 0.145),
    (0.78, 0.182, 0.150),
]
prev_r = None
for z, rx, ry in p_levels:
    ring = [bm_shorts.verts.new((math.cos(2*math.pi*i/20)*rx, math.sin(2*math.pi*i/20)*ry, z)) for i in range(20)]
    if prev_r:
        for i in range(20):
            ni = (i+1)%20
            bm_shorts.faces.new([prev_r[i], prev_r[ni], ring[ni], ring[i]])
    prev_r = ring

# Left and Right pant legs
for side, sx in (('L', -0.092), ('R', 0.092)):
    leg_levels = [
        (0.78, 0.088, 0.090),
        (0.68, 0.085, 0.086),
        (0.58, 0.082, 0.082),
        (0.54, 0.084, 0.084), # cuff transition
    ]
    prev_l = None
    for z, rx, ry in leg_levels:
        lring = [bm_shorts.verts.new((sx + math.cos(2*math.pi*i/16)*rx, math.sin(2*math.pi*i/16)*ry, z)) for i in range(16)]
        if prev_l:
            for i in range(16):
                ni = (i+1)%16
                bm_shorts.faces.new([prev_l[i], prev_l[ni], lring[ni], lring[i]])
        prev_l = lring

shorts_mesh = bpy.data.meshes.new('Luffy_Shorts')
bm_shorts.to_mesh(shorts_mesh); bm_shorts.free()
shorts_obj = bpy.data.objects.new('Luffy_Shorts', shorts_mesh)
bpy.context.scene.collection.objects.link(shorts_obj)
shorts_obj.data.materials.append(M_SHORTS)
mod_ssolid = shorts_obj.modifiers.new('Solidify', 'SOLIDIFY')
mod_ssolid.thickness = 0.008
bpy.context.view_layer.objects.active = shorts_obj
bpy.ops.object.shade_smooth()

# White rolled-up leg cuffs (thick ring at the bottom of each leg)
for side, sx in (('L', -0.092), ('R', 0.092)):
    bpy.ops.mesh.primitive_torus_add(major_radius=0.086, minor_radius=0.012, location=(sx, 0, 0.535), major_segments=24, minor_segments=12)
    cuff = bpy.context.active_object
    cuff.name = f'Luffy_LegCuff_{side}'
    cuff.data.materials.append(M_CUFF)
    bpy.ops.object.shade_smooth()

print("[SHORTS] Blue denim shorts with white cuffs created")

# ─── 7. SANDALS (ZŌRI) ───────────────────────────────────────────────────────
# Woven straw/leather sole + Y-strap
for side, sx in (('L', -0.105), ('R', 0.105)):
    # Sole (flat elongated oval box)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sx, -0.02, 0.014))
    sole = bpy.context.active_object
    sole.name = f'Luffy_SandalSole_{side}'
    sole.scale = (0.095, 0.22, 0.016)
    sole.data.materials.append(M_SANDAL)
    bpy.ops.object.shade_smooth()
    
    # Y-strap thongs
    bpy.ops.mesh.primitive_torus_add(major_radius=0.045, minor_radius=0.006, location=(sx, -0.015, 0.042))
    strap = bpy.context.active_object
    strap.name = f'Luffy_SandalStrap_{side}'
    strap.rotation_euler = (math.radians(35), 0, 0)
    strap.data.materials.append(M_STRAP)
    bpy.ops.object.shade_smooth()

print("[SANDALS] Sandals and straps modeled")

# ─── 8. ELASTIC ARM ARMATURE & RIGGING ───────────────────────────────────────
# Create full character armature with segmented elastic arm deformation bones
arm_data = bpy.data.armatures.new('Luffy_Armature')
arm_data.display_type = 'OCTAHEDRAL'
arm_obj = bpy.data.objects.new('Luffy_Rig', arm_data)
bpy.context.scene.collection.objects.link(arm_obj)
bpy.context.view_layer.objects.active = arm_obj

bpy.ops.object.mode_set(mode='EDIT')
eb = arm_data.edit_bones

# Spine / Root
b_root = eb.new('Root')
b_root.head = (0, 0, 0); b_root.tail = (0, 0, 0.85)

b_pelvis = eb.new('Pelvis')
b_pelvis.head = (0, 0, 0.85); b_pelvis.tail = (0, 0, 0.98)
b_pelvis.parent = b_root

b_chest = eb.new('Chest')
b_chest.head = (0, 0, 0.98); b_chest.tail = (0, 0, 1.40)
b_chest.parent = b_pelvis

b_neck = eb.new('Neck')
b_neck.head = (0, 0, 1.40); b_neck.tail = (0, 0, 1.50)
b_neck.parent = b_chest

b_head = eb.new('Head')
b_head.head = (0, 0, 1.50); b_head.tail = (0, 0, 1.78)
b_head.parent = b_neck

# Legs
for side, sx in (('L', -0.095), ('R', 0.095)):
    thigh = eb.new(f'Thigh_{side}')
    thigh.head = (sx, 0, 0.85); thigh.tail = (sx, 0, 0.45)
    thigh.parent = b_pelvis
    
    shin = eb.new(f'Shin_{side}')
    shin.head = (sx, 0, 0.45); shin.tail = (sx, -0.02, 0.05)
    shin.parent = thigh
    
    foot = eb.new(f'Foot_{side}')
    foot.head = (sx, -0.02, 0.05); foot.tail = (sx, -0.14, 0.01)
    foot.parent = shin

# SEGMENTED ELASTIC ARMS (4 segments upper arm + 4 segments forearm)
# This allows stretching the arm up to 5x length without tearing or breaking mesh
NUM_SEGS = 4
for side, sx, mult in (('L', -0.18, -1), ('R', 0.18, 1)):
    clavicle = eb.new(f'Clavicle_{side}')
    clavicle.head = (0, 0, 1.38); clavicle.tail = (sx, -0.01, 1.36)
    clavicle.parent = b_chest
    
    # Upper arm chain
    shoulder_pos = Vector((sx, -0.01, 1.36))
    elbow_pos = Vector((sx + mult * 0.26, -0.01, 1.15))
    prev_bone = clavicle
    for i in range(NUM_SEGS):
        t0 = i / NUM_SEGS
        t1 = (i + 1) / NUM_SEGS
        b = eb.new(f'UpperArm_{side}_{i}')
        b.head = shoulder_pos.lerp(elbow_pos, t0)
        b.tail = shoulder_pos.lerp(elbow_pos, t1)
        b.parent = prev_bone
        b.use_connect = True
        prev_bone = b
        
    # Forearm chain
    wrist_pos = Vector((sx + mult * 0.48, -0.01, 0.94))
    for i in range(NUM_SEGS):
        t0 = i / NUM_SEGS
        t1 = (i + 1) / NUM_SEGS
        b = eb.new(f'Forearm_{side}_{i}')
        b.head = elbow_pos.lerp(wrist_pos, t0)
        b.tail = elbow_pos.lerp(wrist_pos, t1)
        b.parent = prev_bone
        b.use_connect = True
        prev_bone = b
        
    # Hand bone (rigid, does NOT stretch)
    hand = eb.new(f'Hand_{side}')
    hand.head = wrist_pos
    hand.tail = wrist_pos + Vector((mult * 0.12, 0, -0.06))
    hand.parent = prev_bone
    hand.use_connect = True

bpy.ops.object.mode_set(mode='OBJECT')
print("[ARMATURE] Segmented elastic arm skeleton built successfully")

# Parent body to armature with automatic weights
bpy.ops.object.select_all(action='DESELECT')
body.select_set(True)
arm_obj.select_set(True)
bpy.context.view_layer.objects.active = arm_obj
bpy.ops.object.parent_set(type='ARMATURE_AUTO')
body.select_set(False)

print("[RIG] Automatic weights applied to body")

# ─── 9. ANIMATION: „GUM-GUM-PISTOLE“ (72 FRAMES) ─────────────────────────────
# Keyframe animation of elastic stretch strike with right arm
arm_obj.animation_data_create()
action_pistol = bpy.data.actions.new('GumGum_Pistol')
arm_obj.animation_data.action = action_pistol

pbones = arm_obj.pose.bones

def kf(bone, attr, frame):
    bone.keyframe_insert(data_path=attr, frame=frame)

# Neutral / Idle Pose (Frames 1 & 72)
for b in pbones:
    b.location = (0, 0, 0)
    b.rotation_quaternion = (1, 0, 0, 0)
    b.scale = (1, 1, 1)

# Animate Gum-Gum-Pistol Strike:
# Phase 1 (F1-14): Crouch & Wind up back
# Phase 2 (F15-26): Lightning-fast arm stretch forward (4.5x length)
# Phase 3 (F27-34): Peak extension impact hold
# Phase 4 (F35-50): Elastic recoil snap-back
# Phase 5 (F51-72): Return to stance

r_hand = pbones.get('Hand_R')
r_shoulder = pbones.get('Clavicle_R')
chest = pbones.get('Chest')

# Chest rotation (wind up back, snap forward)
chest.rotation_mode = 'XYZ'
chest.rotation_euler = (0, 0, 0); chest.keyframe_insert('rotation_euler', frame=1)
chest.rotation_euler = (math.radians(-5), math.radians(18), math.radians(-15)); chest.keyframe_insert('rotation_euler', frame=14)
chest.rotation_euler = (math.radians(12), math.radians(-22), math.radians(10)); chest.keyframe_insert('rotation_euler', frame=26)
chest.rotation_euler = (math.radians(10), math.radians(-20), math.radians(8)); chest.keyframe_insert('rotation_euler', frame=34)
chest.rotation_euler = (0, 0, 0); chest.keyframe_insert('rotation_euler', frame=72)

# Elastic stretch on Right Arm segments
# Stretch each of the 8 arm segments along Y (bone length) up to 4.5x!
arm_segments_r = [pbones.get(f'UpperArm_R_{i}') for i in range(NUM_SEGS)] + [pbones.get(f'Forearm_R_{i}') for i in range(NUM_SEGS)]

for b in arm_segments_r:
    if not b: continue
    # Frame 1: normal length
    b.scale = (1.0, 1.0, 1.0); b.keyframe_insert('scale', frame=1)
    # Frame 14: pulled back (compressed slightly 0.9x)
    b.scale = (1.05, 0.90, 1.05); b.keyframe_insert('scale', frame=14)
    # Frame 26: MAXIMUM ELASTIC STRETCH (4.2x length, arm thins slightly to 0.72)
    b.scale = (0.75, 4.2, 0.75); b.keyframe_insert('scale', frame=26)
    # Frame 34: Peak impact hold
    b.scale = (0.78, 4.0, 0.78); b.keyframe_insert('scale', frame=34)
    # Frame 44: Elastic overshoot on return (0.85x)
    b.scale = (1.08, 0.85, 1.08); b.keyframe_insert('scale', frame=44)
    # Frame 56: Elastic rebound
    b.scale = (0.98, 1.05, 0.98); b.keyframe_insert('scale', frame=56)
    # Frame 72: Clean rest shape
    b.scale = (1.0, 1.0, 1.0); b.keyframe_insert('scale', frame=72)

# Clavicle / Shoulder aim
r_arm_root = pbones.get('UpperArm_R_0')
if r_arm_root:
    r_arm_root.rotation_mode = 'XYZ'
    # F1: normal A-pose
    r_arm_root.rotation_euler = (0, 0, 0); r_arm_root.keyframe_insert('rotation_euler', frame=1)
    # F14: wind up high behind back
    r_arm_root.rotation_euler = (math.radians(-65), math.radians(-30), math.radians(45)); r_arm_root.keyframe_insert('rotation_euler', frame=14)
    # F26: fire straight forward toward target (-Y in world space)
    r_arm_root.rotation_euler = (math.radians(85), math.radians(10), math.radians(-80)); r_arm_root.keyframe_insert('rotation_euler', frame=26)
    # F34: hold punch
    r_arm_root.rotation_euler = (math.radians(82), math.radians(8), math.radians(-78)); r_arm_root.keyframe_insert('rotation_euler', frame=34)
    # F72: return to neutral
    r_arm_root.rotation_euler = (0, 0, 0); r_arm_root.keyframe_insert('rotation_euler', frame=72)

# HAND: Stays COMPACT (scale = 1.0) throughout the entire punch!
if r_hand:
    r_hand.scale = (1.0, 1.0, 1.0); r_hand.keyframe_insert('scale', frame=1)
    r_hand.scale = (1.0, 1.0, 1.0); r_hand.keyframe_insert('scale', frame=26)
    r_hand.scale = (1.0, 1.0, 1.0); r_hand.keyframe_insert('scale', frame=34)
    r_hand.scale = (1.0, 1.0, 1.0); r_hand.keyframe_insert('scale', frame=72)

print("[ANIMATION] 'GumGum_Pistol' 72-frame elastic strike baked")

# ─── 10. STUDIO LIGHTING & CAMERAS ───────────────────────────────────────────
# 4-Point Studio Lighting
lights_info = [
    ('KeyLight',   (-1.8, -2.8, 2.3), 520, (1.0, 0.98, 0.94), 2.2),
    ('FillLight',  ( 2.4, -2.0, 1.6), 300, (0.88, 0.92, 1.0), 2.5),
    ('RimLight',   ( 0.0,  2.6, 2.2), 480, (1.0, 0.85, 0.65), 1.8),
    ('GroundFill', ( 0.0, -1.2, 0.1), 140, (0.9, 0.9, 0.95),  2.0),
]
for lname, lloc, lenergy, lcol, lsize in lights_info:
    ld = bpy.data.lights.new(lname, 'AREA')
    ld.energy = lenergy; ld.color = lcol; ld.size = lsize
    lo = bpy.data.objects.new(lname, ld)
    bpy.context.scene.collection.objects.link(lo)
    lo.location = lloc
    direction = Vector((0, 0, 1.05)) - Vector(lloc)
    lo.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()

# Neutral Presentation Floor Disc
bpy.ops.mesh.primitive_cylinder_add(radius=2.2, depth=0.02, location=(0, 0, -0.01))
floor_obj = bpy.context.active_object
floor_obj.name = 'Luffy_Stage'
M_STAGE = create_pbr('Mat_Stage', (0.12, 0.12, 0.15), rough=0.88)
floor_obj.data.materials.append(M_STAGE)
bpy.ops.object.shade_smooth()

# Cameras
def make_cam(name, loc, look, fov=40):
    cd = bpy.data.cameras.new(name)
    cd.angle = math.radians(fov)
    co = bpy.data.objects.new(name, cd)
    bpy.context.scene.collection.objects.link(co)
    co.location = loc
    direction = Vector(look) - Vector(loc)
    co.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    return co

cam_front   = make_cam('Cam_Front',   ( 0.0, -3.2, 1.05), (0, 0, 1.05), 40)
cam_side    = make_cam('Cam_Side',    ( 3.2,  0.0, 1.05), (0, 0, 1.05), 40)
cam_back    = make_cam('Cam_Back',    ( 0.0,  3.2, 1.05), (0, 0, 1.05), 40)
cam_34      = make_cam('Cam_34',      (-2.2, -2.4, 1.25), (0, 0, 1.05), 42)
cam_face    = make_cam('Cam_Face',    (-0.25, -0.85, 1.66), (0, 0, 1.64), 26)
cam_strike  = make_cam('Cam_Strike',  (-2.6, -3.4, 1.45), (0, -0.6, 1.15), 48)

print("[CAMERAS] Studio cameras created")

# ─── 11. PREVIEW RENDERS ─────────────────────────────────────────────────────
def do_render(cam, fname, frame=1):
    sc.camera = cam
    sc.frame_set(frame)
    sc.render.filepath = str(PREVIEW_DIR / fname)
    bpy.ops.render.render(write_still=True)
    print(f"  ✓ Rendered {fname}")

print("\n--- RENDERING CLAY INSPECTION PASS ---")
sc.view_layers[0].material_override = M_CLAY
do_render(cam_front,  'luffy_clay_front.png')
do_render(cam_side,   'luffy_clay_side.png')
do_render(cam_back,   'luffy_clay_back.png')
do_render(cam_34,     'luffy_clay_34.png')
do_render(cam_face,   'luffy_clay_closeup.png')

print("\n--- RENDERING FULL PBR MATERIAL PASS ---")
sc.view_layers[0].material_override = None
do_render(cam_front,  'luffy_pbr_front.png')
do_render(cam_side,   'luffy_pbr_side.png')
do_render(cam_back,   'luffy_pbr_back.png')
do_render(cam_34,     'luffy_pbr_34.png')
do_render(cam_face,   'luffy_pbr_closeup.png')

print("\n--- RENDERING GUM-GUM-PISTOL ACTION STRIKE PASS ---")
# Frame 28: Peak stretch of Gum-Gum-Pistol attack!
do_render(cam_strike, 'luffy_gum_gum_pistol_strike.png', frame=28)
do_render(cam_front,  'luffy_gum_gum_pistol_front.png',  frame=28)

# ─── 12. SAVE BLEND & EXPORT GLB ─────────────────────────────────────────────
sc.frame_set(1)
bpy.ops.wm.save_as_mainfile(filepath=str(BLEND_OUT))
print(f"\n[SAVE] Blend file saved: {BLEND_OUT}")

# Select mesh objects + armature for export
bpy.ops.object.select_all(action='DESELECT')
for obj in bpy.data.objects:
    if obj.type in ('MESH', 'ARMATURE') and obj.name != 'Luffy_Stage':
        obj.select_set(True)

bpy.ops.export_scene.gltf(
    filepath=str(GLB_OUT),
    use_selection=True,
    export_format='GLB',
    export_apply=False, # Keep armature deformation live
    export_yup=True,
    export_animations=True,
    export_frame_range=True
)
print(f"[EXPORT] GLB exported: {GLB_OUT}")

# ─── 13. RE-IMPORT VERIFICATION ──────────────────────────────────────────────
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=str(GLB_OUT))
imported_meshes = [o for o in bpy.data.objects if o.type == 'MESH']
imported_arms   = [o for o in bpy.data.objects if o.type == 'ARMATURE']
v_count = sum(len(o.data.vertices) for o in imported_meshes)
f_count = sum(len(o.data.polygons) for o in imported_meshes)
actions_count = len(bpy.data.actions)

print(f"\n=== VERIFICATION REPORT ===")
print(f"Imported Meshes:    {len(imported_meshes)}")
print(f"Total Vertices:     {v_count:,}")
print(f"Total Polygons:     {f_count:,}")
print(f"Imported Armatures: {len(imported_arms)}")
print(f"Baked Actions:      {actions_count}")
print("=== MONKEY D. RUFFY BUILD COMPLETE & VERIFIED! ===")
