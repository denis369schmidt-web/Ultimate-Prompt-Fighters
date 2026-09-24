import bpy, bmesh, math
from pathlib import Path
from mathutils import Vector

ROOT = Path(r'C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate')
BUNDLE_PATH = ROOT / 'tools/human_base_meshes/human-base-meshes-bundle-v1.4.1/human_base_meshes_bundle.blend'
CHAR_DIR = ROOT / 'art/characters/pain'
PREVIEW_DIR = CHAR_DIR / 'previews'
BLEND_OUT = CHAR_DIR / 'PFU_Pain.blend'
GLB_OUT = CHAR_DIR / 'pain.glb'
for d in (CHAR_DIR, PREVIEW_DIR): d.mkdir(parents=True, exist_ok=True)

# Scene reset
bpy.ops.wm.read_factory_settings(use_empty=True)
sc = bpy.context.scene
sc.unit_settings.system = 'METRIC'
if sc.world is None: sc.world = bpy.data.worlds.new('World')
sc.world.use_nodes = True
bg = sc.world.node_tree.nodes.get('Background')
if not bg:
    bg = sc.world.node_tree.nodes.new('ShaderNodeBackground')
    out = sc.world.node_tree.nodes.new('ShaderNodeOutputWorld')
    sc.world.node_tree.links.new(bg.outputs['Background'], out.inputs['Surface'])
bg.inputs['Color'].default_value = (0.03, 0.03, 0.05, 1.0)
bg.inputs['Strength'].default_value = 0.8
sc.render.engine = 'BLENDER_EEVEE_NEXT'
sc.render.resolution_x = 1280
sc.render.resolution_y = 1280
sc.view_settings.look = 'AgX - Medium High Contrast'
sc.view_settings.exposure = 0.5

# Helper: PBR material creator
def mat_pbr(name, col, rough=0.6, metal=0.0, emit=None, emit_str=0.0, sss=0.0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nodes = m.node_tree.nodes
    links = m.node_tree.links
    nodes.clear()
    out = nodes.new('ShaderNodeOutputMaterial'); out.location=(400,0)
    bsdf = nodes.new('ShaderNodeBsdfPrincipled'); bsdf.location=(0,0)
    links.new(bsdf.outputs['BSDF'], out.inputs['Surface'])
    bsdf.inputs['Base Color'].default_value = (*col, 1.0)
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Metallic'].default_value = metal
    for k in ('Subsurface Weight','Subsurface'):
        if k in bsdf.inputs: bsdf.inputs[k].default_value = sss; break
    if emit and emit_str > 0:
        if 'Emission Color' in bsdf.inputs: bsdf.inputs['Emission Color'].default_value = (*emit, 1.0); bsdf.inputs['Emission Strength'].default_value = emit_str
        elif 'Emission' in bsdf.inputs: bsdf.inputs['Emission'].default_value = (*emit, 1.0)
    return m

# Materials
M_SKIN = mat_pbr('Mat_Skin', (0.78, 0.62, 0.50), rough=0.58, sss=0.12)
M_CLOAK = mat_pbr('Mat_AkatsukiCloak', (0.035, 0.035, 0.04), rough=0.65)
M_CLOUD = mat_pbr('Mat_AkatsukiCloud', (0.80, 0.08, 0.06), rough=0.72)
M_HAIR = mat_pbr('Mat_OrangeHair', (0.85, 0.32, 0.04), rough=0.45, metal=0.08)
M_RINNEGAN = mat_pbr('Mat_Rinnegan', (0.38, 0.08, 0.65), rough=0.1, metal=0.2, emit=(0.5, 0.1, 0.9), emit_str=2.0)
M_PIERCE = mat_pbr('Mat_MetalPiercing', (0.75, 0.75, 0.72), rough=0.15, metal=0.95)
M_HEADBAND = mat_pbr('Mat_MetalHeadband', (0.60, 0.60, 0.58), rough=0.22, metal=0.88)
M_CLOTH = mat_pbr('Mat_DarkCloth', (0.08, 0.08, 0.10), rough=0.80)
M_CLAY = mat_pbr('Mat_Clay', (0.48, 0.49, 0.52), rough=0.40)

# Load body mesh
with bpy.data.libraries.load(str(BUNDLE_PATH), link=False) as (df, dt):
    dt.meshes = [m for m in df.meshes if m == 'GEO-body_male_stylized']
body_mesh = [m for m in dt.meshes if m.name == 'GEO-body_male_stylized'][0]
body = bpy.data.objects.new('Pain_Body', body_mesh)
bpy.context.scene.collection.objects.link(body)
body.data.materials.append(M_SKIN)
bpy.context.view_layer.objects.active = body
body.select_set(True)
bpy.ops.object.shade_smooth()
body.select_set(False)

# Subsurf modifier
mod = body.modifiers.new('Subd','SUBSURF')
mod.levels = 1; mod.render_levels = 1

print('[BODY] Body mesh loaded OK')

# HAIR SPIKES (14 orange spikes around head)
def add_hair_spike(name, loc, rot_euler, height=0.085, r1=0.018):
    bpy.ops.mesh.primitive_cone_add(radius1=r1, radius2=0.003, depth=height, location=loc)
    obj = bpy.context.active_object
    obj.name = name
    obj.rotation_euler = rot_euler
    obj.data.materials.append(M_HAIR)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.shade_smooth()
    return obj

import math
PI = math.pi
# Front spikes (longer, tilted forward)
for i in range(5):
    ang = (i - 2) * 0.25
    x = math.sin(ang) * 0.06
    y = -0.09 - math.cos(ang) * 0.015
    z = 1.695 + abs(i - 2) * 0.005
    add_hair_spike(f'Pain_Hair_F{i}', (x, y, z), (PI*0.22, 0, ang*0.5), height=0.092, r1=0.017)

# Side spikes
for side, sx in (('L', -1), ('R', 1)):
    for i in range(3):
        ang_side = sx * (0.55 + i * 0.28)
        x = math.sin(ang_side) * 0.10
        y = -0.02 + math.cos(ang_side) * 0.04
        z = 1.668 + i * 0.01
        add_hair_spike(f'Pain_Hair_{side}{i}', (x, y, z), (PI*0.18, ang_side * 0.5, 0), height=0.080, r1=0.015)

# Back spikes
for i in range(3):
    ang = (i - 1) * 0.30
    x = math.sin(ang) * 0.05
    z = 1.680
    add_hair_spike(f'Pain_Hair_B{i}', (x, 0.06, z), (-PI*0.20, 0, ang * 0.3), height=0.075, r1=0.014)

print('[HAIR] Orange spikes added OK')

# RINNEGAN EYES
for side, sx in (('L', -0.030), ('R', 0.030)):
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.016, location=(sx, -0.098, 1.638), segments=16, ring_count=12)
    eye = bpy.context.active_object
    eye.name = f'Pain_Eye_{side}'
    eye.data.materials.append(M_RINNEGAN)
    bpy.ops.object.shade_smooth()
    # Concentric rings (5 rings)
    for ring_i in range(5):
        mr = 0.005 + ring_i * 0.0018
        bpy.ops.mesh.primitive_torus_add(major_radius=mr, minor_radius=0.0013, location=(sx, -0.100, 1.638))
        ring_obj = bpy.context.active_object
        ring_obj.name = f'Pain_EyeRing_{side}_{ring_i}'
        ring_mat = mat_pbr(f'Mat_RinneganRing{ring_i}', (0.18, 0.02, 0.32), rough=0.2)
        ring_obj.data.materials.append(ring_mat)

print('[EYES] Rinnegan eyes added OK')

# PIERCINGS
pierce_locs = [
    ('Pain_Pierce_Nose',   (0.000, -0.104, 1.598)),
    ('Pain_Pierce_WL_U',  (-0.042, -0.097, 1.622)),
    ('Pain_Pierce_WR_U',  ( 0.042, -0.097, 1.622)),
    ('Pain_Pierce_WL_D',  (-0.048, -0.093, 1.605)),
    ('Pain_Pierce_WR_D',  ( 0.048, -0.093, 1.605)),
    ('Pain_Pierce_Chin',  (0.000, -0.100, 1.575)),
]
for pname, ploc in pierce_locs:
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.006, location=ploc, segments=10, ring_count=8)
    p = bpy.context.active_object
    p.name = pname
    p.data.materials.append(M_PIERCE)
    bpy.ops.object.shade_smooth()

# Ear rings
for side, sx in (('L', -0.092), ('R', 0.092)):
    bpy.ops.mesh.primitive_torus_add(major_radius=0.010, minor_radius=0.003, location=(sx, -0.025, 1.635))
    er = bpy.context.active_object
    er.name = f'Pain_EarRing_{side}'
    er.data.materials.append(M_PIERCE)

print('[PIERCINGS] Piercings added OK')

# HEADBAND (metal plate over forehead)
bm = bmesh.new()
verts = [
    bm.verts.new((-0.058, -0.102, 1.660)),
    bm.verts.new(( 0.058, -0.102, 1.660)),
    bm.verts.new(( 0.058, -0.100, 1.682)),
    bm.verts.new((-0.058, -0.100, 1.682)),
    bm.verts.new((-0.058, -0.088, 1.660)),
    bm.verts.new(( 0.058, -0.088, 1.660)),
    bm.verts.new(( 0.058, -0.086, 1.682)),
    bm.verts.new((-0.058, -0.086, 1.682)),
]
bm.faces.new([verts[0],verts[1],verts[2],verts[3]])
bm.faces.new([verts[4],verts[5],verts[6],verts[7]])
bm.faces.new([verts[0],verts[4],verts[7],verts[3]])
bm.faces.new([verts[1],verts[5],verts[6],verts[2]])
bm.faces.new([verts[0],verts[1],verts[5],verts[4]])
bm.faces.new([verts[3],verts[2],verts[6],verts[7]])
hbmesh = bpy.data.meshes.new('Pain_Headband')
bm.to_mesh(hbmesh); bm.free()
hband = bpy.data.objects.new('Pain_Headband', hbmesh)
bpy.context.scene.collection.objects.link(hband)
hband.data.materials.append(M_HEADBAND)
bpy.context.view_layer.objects.active = hband
bpy.ops.object.shade_smooth()

# AKATSUKI CLOAK (simple cylinder tube around body)
bm2 = bmesh.new()
segs = 20
levels = [
    (1.50, 0.195, 0.175, 35.0),  # Shoulders - collar transition (z, rx, ry, open_arc)
    (1.38, 0.212, 0.190, 40.0),  # Upper chest
    (1.20, 0.205, 0.185, 42.0),  # Chest
    (1.00, 0.195, 0.175, 45.0),  # Waist
    (0.75, 0.215, 0.192, 48.0),  # Hips
    (0.45, 0.235, 0.210, 50.0),  # Lower body
    (0.12, 0.265, 0.240, 52.0),  # Near floor
    (0.01, 0.270, 0.248, 55.0),  # Floor level (flare)
]
prev_ring = None
for z, rx, ry, open_deg in levels:
    ring = []
    open_rad = math.radians(open_deg)
    for i in range(segs):
        a = (i / segs) * 2 * math.pi
        # Skip front opening (V-neck area)
        if abs(a - math.pi) < open_rad:
            v = None
        else:
            v = bm2.verts.new((math.cos(a)*rx, math.sin(a)*ry, z))
        ring.append(v)
    if prev_ring:
        for i in range(segs):
            ni = (i+1) % segs
            p0, p1, c0, c1 = prev_ring[i], prev_ring[ni], ring[i], ring[ni]
            if p0 and p1 and c0 and c1:
                try: bm2.faces.new([p0, p1, c1, c0])
                except: pass
    prev_ring = ring

# High collar ring (above shoulders)
col_z_bot, col_z_top = 1.50, 1.60
rx_c, ry_c = 0.12, 0.10
col_bot = [bm2.verts.new((math.cos(2*math.pi*i/16)*rx_c, math.sin(2*math.pi*i/16)*ry_c, col_z_bot)) for i in range(16)]
col_top = [bm2.verts.new((math.cos(2*math.pi*i/16)*rx_c*0.85, math.sin(2*math.pi*i/16)*ry_c*0.85, col_z_top)) for i in range(16)]
for i in range(16):
    ni = (i+1)%16
    try: bm2.faces.new([col_bot[i], col_bot[ni], col_top[ni], col_top[i]])
    except: pass

cloak_mesh = bpy.data.meshes.new('Pain_Cloak')
bm2.to_mesh(cloak_mesh); bm2.free()
cloak = bpy.data.objects.new('Pain_Cloak', cloak_mesh)
bpy.context.scene.collection.objects.link(cloak)
cloak.data.materials.append(M_CLOAK)
bpy.context.view_layer.objects.active = cloak
bpy.ops.object.shade_smooth()
mod2 = cloak.modifiers.new('Subd','SUBSURF')
mod2.levels = 1; mod2.render_levels = 1

# Red Clouds on cloak (6 flat discs)
for ci in range(6):
    ang = ci * math.pi * 2 / 6 + math.pi * 0.1
    cx = math.cos(ang) * 0.21
    cy = math.sin(ang) * 0.19
    cz = 0.60 + (ci % 3) * 0.25
    bpy.ops.mesh.primitive_circle_add(radius=0.055, fill_type='NGON', location=(cx, cy, cz))
    cloud = bpy.context.active_object
    cloud.name = f'Pain_Cloud_{ci}'
    # Aim normal outward
    cloud.rotation_euler = (math.pi/2, 0, ang)
    cloud.data.materials.append(M_CLOUD)

print('[CLOAK] Akatsuki Cloak added OK')

# LIGHTING
for lname, lloc, lenergy, lcol in [
    ('Key',  (-1.5, -2.5, 2.2), 500, (1.00, 0.97, 0.93)),
    ('Fill', ( 2.0, -2.0, 1.5), 280, (0.85, 0.88, 1.00)),
    ('Rim',  ( 0.0,  2.5, 2.0), 420, (0.90, 0.60, 1.00)),
    ('Bot',  ( 0.0, -1.0, 0.1), 120, (0.88, 0.90, 1.00)),
]:
    ld = bpy.data.lights.new(lname, 'AREA')
    ld.energy = lenergy; ld.color = lcol; ld.size = 2.0
    lo = bpy.data.objects.new(lname, ld)
    bpy.context.scene.collection.objects.link(lo)
    lo.location = lloc
    direction = Vector((0, 0, 1.0)) - Vector(lloc)
    lo.rotation_euler = direction.to_track_quat('-Z','Y').to_euler()

# CAMERAS
def add_cam(name, loc, look, fov=42):
    cd = bpy.data.cameras.new(name)
    cd.angle = math.radians(fov)
    co = bpy.data.objects.new(name, cd)
    bpy.context.scene.collection.objects.link(co)
    co.location = loc
    direction = Vector(look) - Vector(loc)
    co.rotation_euler = direction.to_track_quat('-Z','Y').to_euler()
    return co

cam_f  = add_cam('Cam_F',  (0.0, -3.0, 1.05), (0,0,1.05), 42)
cam_s  = add_cam('Cam_S',  (3.0,  0.0, 1.05), (0,0,1.05), 42)
cam_b  = add_cam('Cam_B',  (0.0,  3.0, 1.05), (0,0,1.05), 42)
cam_34 = add_cam('Cam_34', (-2.0, -2.2, 1.22), (0,0,1.05), 44)
cam_cl = add_cam('Cam_CL', (-0.35,-1.0, 1.60), (0,0,1.58), 28)

# RENDER
def render_shot(cam, fname):
    bpy.context.scene.camera = cam
    bpy.context.scene.render.filepath = str(PREVIEW_DIR / fname)
    bpy.ops.render.render(write_still=True)
    print(f'[RENDERED] {fname}')

# Clay inspection
bpy.context.scene.view_layers[0].material_override = M_CLAY
render_shot(cam_f, 'pain_clay_front.png')
render_shot(cam_s, 'pain_clay_side.png')
render_shot(cam_b, 'pain_clay_back.png')
render_shot(cam_34,'pain_clay_34.png')
render_shot(cam_cl,'pain_clay_closeup.png')

# PBR full
bpy.context.scene.view_layers[0].material_override = None
render_shot(cam_f, 'pain_pbr_front.png')
render_shot(cam_s, 'pain_pbr_side.png')
render_shot(cam_b, 'pain_pbr_back.png')
render_shot(cam_34,'pain_pbr_34.png')
render_shot(cam_cl,'pain_pbr_closeup.png')

# Save
bpy.ops.wm.save_as_mainfile(filepath=str(BLEND_OUT))
print(f'[SAVED] {BLEND_OUT}')

# Export GLB
bpy.ops.object.select_all(action='DESELECT')
for obj in bpy.data.objects:
    if obj.type == 'MESH': obj.select_set(True)
bpy.ops.export_scene.gltf(filepath=str(GLB_OUT), use_selection=True, export_format='GLB', export_apply=True, export_yup=True)
print(f'[EXPORTED GLB] {GLB_OUT}')

# Verify
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=str(GLB_OUT))
verts = sum(len(o.data.vertices) for o in bpy.data.objects if o.type=='MESH')
faces = sum(len(o.data.polygons) for o in bpy.data.objects if o.type=='MESH')
print(f'[VERIFIED] {len([o for o in bpy.data.objects if o.type=="MESH"])} meshes, {verts:,} verts, {faces:,} faces')
print('=== Pain Build SUCCESSFUL ===')
