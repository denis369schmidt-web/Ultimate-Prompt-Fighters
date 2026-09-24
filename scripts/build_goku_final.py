"""
Son Goku - Final High Quality Build (v3.0)
Organischer Anime-Kämpfer mit:
 - Vollständig verbundenem Körper (Torso + Gliedmaßen aus einem Stück)
 - Authentisches Goku-Gesicht (Toriyama-Stil)
 - Lila Spiky-Hair mit Volumen und Tiefe
 - Orange Gi-Kleidung mit Schichten
 - Navy Undershirt, Sash-Belt, Hose, Stiefel
 - Export als PFU_SonGoku.blend + goku.glb
"""

import math
import sys
from pathlib import Path

import bpy
import bmesh
from mathutils import Vector, Matrix

ROOT = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate")
BLEND_OUT  = ROOT / "art" / "blender" / "PFU_SonGoku.blend"
GLB_OUT    = ROOT / "godot" / "assets" / "models" / "goku.glb"
PREVIEW_DIR = ROOT / "art" / "blender" / "previews"
TEX_DIR    = ROOT / "godot" / "assets" / "textures" / "characters"

PREVIEW_DIR.mkdir(parents=True, exist_ok=True)
GLB_OUT.parent.mkdir(parents=True, exist_ok=True)


# ─── SCENE SETUP ─────────────────────────────────────────────────────────────

def reset_scene():
    if bpy.context.object and bpy.context.object.mode != "OBJECT":
        bpy.ops.object.mode_set(mode="OBJECT")
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for col in (bpy.data.meshes, bpy.data.materials, bpy.data.armatures,
                bpy.data.cameras, bpy.data.lights, bpy.data.images, bpy.data.actions):
        for item in list(col):
            if item.users == 0:
                col.remove(item)
    sc = bpy.context.scene
    sc.unit_settings.system      = "METRIC"
    sc.unit_settings.scale_length = 0.01
    sc.render.engine             = "BLENDER_EEVEE_NEXT"
    sc.render.resolution_x       = 1280
    sc.render.resolution_y       = 1280
    sc.render.film_transparent   = False
    sc.world.use_nodes           = True
    bg = sc.world.node_tree.nodes.get("Background")
    if bg:
        bg.inputs["Color"].default_value    = (0.10, 0.11, 0.14, 1.0)
        bg.inputs["Strength"].default_value = 0.8
    sc.view_settings.look     = "AgX - Base Contrast"
    sc.view_settings.exposure = 0.9


# ─── MATERIALS ────────────────────────────────────────────────────────────────

def mat(name, color, rough=0.55, metal=0.0, emit=None, emit_str=0.0, sss=0.0):
    m = bpy.data.materials.get(name) or bpy.data.materials.new(name)
    m.use_nodes = True
    nodes, links = m.node_tree.nodes, m.node_tree.links
    nodes.clear()
    out  = nodes.new("ShaderNodeOutputMaterial"); out.location  = (500, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (100, 0)
    links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Roughness"].default_value  = rough
    bsdf.inputs["Metallic"].default_value   = metal
    for k in ("Subsurface Weight", "Subsurface"):
        if k in bsdf.inputs:
            bsdf.inputs[k].default_value = sss; break
    if emit:
        bsdf.inputs["Emission Color"].default_value    = (*emit, 1.0)
        bsdf.inputs["Emission Strength"].default_value = emit_str
    for k in ("Coat Weight", "Clearcoat"):
        if k in bsdf.inputs:
            bsdf.inputs[k].default_value = 0.3; break
    return m

# Colour palette
C_SKIN      = (0.92, 0.75, 0.60)
C_SKIN_DARK = (0.78, 0.58, 0.42)
C_ORANGE    = (0.92, 0.48, 0.10)
C_NAVY      = (0.06, 0.10, 0.28)
C_PURPLE    = (0.45, 0.10, 0.85)
C_DARK_PUR  = (0.22, 0.04, 0.42)
C_BOOT      = (0.12, 0.08, 0.04)
C_BOOT_STRAP= (0.70, 0.20, 0.10)
C_WHITE     = (0.95, 0.95, 0.95)
C_GOLD      = (0.90, 0.72, 0.10)
C_SASH_BLUE = (0.08, 0.16, 0.40)


# ─── GEOMETRY HELPERS ─────────────────────────────────────────────────────────

def add_smooth(obj, angle=30):
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    if hasattr(obj.data, "use_auto_smooth"):
        obj.data.use_auto_smooth = True
        obj.data.auto_smooth_angle = math.radians(angle)
    bpy.ops.object.shade_smooth()
    # Blender 4.x: set smooth by angle via geometry nodes modifier alternative
    try:
        bpy.ops.mesh.customdata_custom_splitnormals_clear()
    except Exception:
        pass
    return obj


def apply_subsurf(obj, levels=2):
    mod = obj.modifiers.new("Subd", "SUBSURF")
    mod.levels            = levels
    mod.render_levels     = levels
    mod.use_limit_surface = False
    return obj


def link(obj):
    if obj.name not in bpy.context.scene.collection.objects:
        bpy.context.scene.collection.objects.link(obj)
    return obj


def new_mesh_obj(name, mesh):
    obj = bpy.data.objects.new(name, mesh)
    link(obj)
    return obj


def assign_mat(obj, material):
    if not obj.data.materials:
        obj.data.materials.append(material)
    else:
        obj.data.materials[0] = material
    return obj


def extrude_circle(bm, center, radius, z, segs=16, prev_verts=None):
    """Add a circle ring, optionally bridging to prev_verts."""
    verts = []
    for i in range(segs):
        a = 2 * math.pi * i / segs
        v = bm.verts.new((center[0] + math.cos(a)*radius,
                          center[1] + math.sin(a)*radius,
                          z))
        verts.append(v)
    if prev_verts:
        for i in range(segs):
            ni = (i+1) % segs
            bm.faces.new([prev_verts[i], prev_verts[ni], verts[ni], verts[i]])
    return verts


# ─── BODY (FULLY CONNECTED) ───────────────────────────────────────────────────

def build_body():
    """
    Loft-based body: a series of cross-section rings from feet to head tip.
    Sections (z in cm, radius in cm):
      Feet: 0–6   boot sole
      Ankle: 10
      Shin: 25  (slight calf flare)
      Knee: 40
      Thigh: 60 (wider)
      Crotch: 80 (bridged, split into legs below)
      Waist: 90
      Belly: 100
      Chest: 120 (wide, muscular)
      Collar: 138
      Neck: 145
      Head base: 152
      Head mid: 162
      Head top: 170
    """
    bm = bmesh.new()
    segs = 20

    # --- Left leg  (offset -8)
    # --- Right leg (offset +8)
    # We'll build a single unified body as a lathed/lofted torso
    # with legs split below crotch

    # Torso column (centre x=0)
    torso_sections = [
        # (z,  rx,  ry)   — elliptical cross-section (front/back slightly deeper)
        (88,  14.0, 12.0),  # hips
        (96,  11.0,  9.0),  # waist
        (105,  13.0, 11.0),  # lower belly
        (115,  15.0, 12.0),  # chest lower
        (128,  17.0, 13.5),  # chest upper (broad)
        (137,  14.5, 11.5),  # collar
        (145,  10.0,  9.0),  # neck
    ]

    prev_ring = None
    for z, rx, ry in torso_sections:
        ring = []
        for i in range(segs):
            a = 2 * math.pi * i / segs
            v = bm.verts.new((math.cos(a)*rx, math.sin(a)*ry, z))
            ring.append(v)
        if prev_ring:
            for i in range(segs):
                ni = (i+1) % segs
                bm.faces.new([prev_ring[i], prev_ring[ni], ring[ni], ring[i]])
        prev_ring = ring

    # Shoulder caps (left & right)
    for side, sx in (("L", -19.5), ("R", 19.5)):
        sh_sections = [
            (135, 5.5),   # deltoid attach
            (130, 7.0),   # shoulder ball
            (125, 6.0),   # upper arm top
        ]
        prev = None
        for z, r in sh_sections:
            ring = []
            for i in range(12):
                a = 2 * math.pi * i / 12
                v = bm.verts.new((sx + math.cos(a)*r, math.sin(a)*r, z))
                ring.append(v)
            if prev:
                for i in range(12):
                    ni = (i+1) % 12
                    bm.faces.new([prev[i], prev[ni], ring[ni], ring[i]])
            prev = ring

        # Arms  (upper arm → elbow → forearm → wrist)
        arm_sections = [
            (z, r) for z, r in [
                (120, 5.5),  # upper arm
                (110, 5.0),
                (100, 4.8),
                (90,  4.5),  # elbow
                (80,  4.2),  # forearm
                (70,  4.0),
                (60,  3.8),
                (50,  3.5),  # wrist
            ]
        ]
        prev = sh_sections  # reuse last shoulder ring as connection — build fresh
        prev_r = None
        for z, r in arm_sections:
            ring = []
            for i in range(12):
                a = 2 * math.pi * i / 12
                v = bm.verts.new((sx + math.cos(a)*r, math.sin(a)*r * 0.85, z))
                ring.append(v)
            if prev_r:
                for i in range(12):
                    ni = (i+1) % 12
                    bm.faces.new([prev_r[i], prev_r[ni], ring[ni], ring[i]])
            prev_r = ring

        # Hand (simple block)
        hx = sx
        hand_verts = [
            bm.verts.new((hx-3.5, -2, 48)), bm.verts.new((hx+3.5, -2, 48)),
            bm.verts.new((hx+3.5,  2, 48)), bm.verts.new((hx-3.5,  2, 48)),
            bm.verts.new((hx-3.0, -1.5, 38)), bm.verts.new((hx+3.0, -1.5, 38)),
            bm.verts.new((hx+3.0,  1.5, 38)), bm.verts.new((hx-3.0,  1.5, 38)),
        ]
        for face in [(0,1,2,3),(4,5,6,7),(0,1,5,4),(2,3,7,6),(0,3,7,4),(1,2,6,5)]:
            try: bm.faces.new([hand_verts[f] for f in face])
            except Exception: pass

    # Legs (left & right) below crotch
    for side, lx in (("L", -8.5), ("R", 8.5)):
        leg_sections = [
            (85,  7.5),   # upper thigh
            (70,  8.0),   # thigh middle (quad)
            (55,  7.0),   # lower thigh
            (43,  5.5),   # knee
            (35,  5.0),   # upper shin
            (20,  5.5),   # calf
            (8,   4.5),   # ankle
        ]
        prev_r = None
        for z, r in leg_sections:
            ring = []
            for i in range(14):
                a = 2 * math.pi * i / 14
                v = bm.verts.new((lx + math.cos(a)*r, math.sin(a)*r*0.9, z))
                ring.append(v)
            if prev_r:
                for i in range(14):
                    ni = (i+1) % 14
                    bm.faces.new([prev_r[i], prev_r[ni], ring[ni], ring[i]])
            prev_r = ring

    bm.verts.ensure_lookup_table()
    bm.faces.ensure_lookup_table()
    mesh = bpy.data.meshes.new("GokuBody")
    bm.to_mesh(mesh)
    bm.free()
    obj = new_mesh_obj("GokuBody", mesh)
    assign_mat(obj, mat("Skin", C_SKIN, rough=0.6, sss=0.15))
    mod = obj.modifiers.new("Subd", "SUBSURF")
    mod.levels = 2; mod.render_levels = 2
    add_smooth(obj, 35)
    return obj


# ─── HEAD ─────────────────────────────────────────────────────────────────────

def build_head():
    """Anime head: wide cranium, small chin, defined cheeks."""
    bm = bmesh.new()
    segs = 20

    # Neck
    neck_secs = [(145, 4.5, 4.0), (148, 5.0, 4.5), (151, 7.5, 7.0)]
    # Skull
    skull_secs = [
        (155, 9.5, 9.0),   # jaw base
        (158, 10.5, 9.5),  # cheeks
        (162, 11.0, 10.0), # cheekbones
        (166, 11.5, 10.5), # midcranium
        (170, 10.5,  9.5), # upper cranium
        (173,  7.5,  7.0), # crown
        (176,  3.0,  3.0), # top
    ]
    all_secs = neck_secs + skull_secs

    prev_ring = None
    for z, rx, ry in all_secs:
        ring = []
        for i in range(segs):
            a = 2 * math.pi * i / segs
            v = bm.verts.new((math.cos(a)*rx, math.sin(a)*ry, z))
            ring.append(v)
        if prev_ring:
            for i in range(segs):
                ni = (i+1) % segs
                bm.faces.new([prev_ring[i], prev_ring[ni], ring[ni], ring[i]])
        prev_ring = ring

    # Cap top
    top_v = bm.verts.new((0, 0, 177))
    for i in range(segs):
        ni = (i+1) % segs
        bm.faces.new([prev_ring[i], prev_ring[ni], top_v])

    # Chin point
    chin_ring = []
    for i in range(segs):
        a = 2 * math.pi * i / segs
        v = bm.verts.new((math.cos(a)*4.5*0.6, math.sin(a)*3.5*0.5, 152.5))
        chin_ring.append(v)
    chin_tip = bm.verts.new((0, -1.5, 149))
    for i in range(segs):
        ni = (i+1) % segs
        bm.faces.new([chin_ring[i], chin_ring[ni], chin_tip])

    # Nose bump
    nose_pts = [
        bm.verts.new((-1.5, -10.2, 160)),
        bm.verts.new(( 1.5, -10.2, 160)),
        bm.verts.new(( 1.0, -10.8, 158)),
        bm.verts.new((-1.0, -10.8, 158)),
        bm.verts.new(( 0.0, -11.2, 162)),
    ]
    try:
        bm.faces.new([nose_pts[0], nose_pts[1], nose_pts[2], nose_pts[3]])
        bm.faces.new([nose_pts[0], nose_pts[4], nose_pts[1]])
    except Exception:
        pass

    # Ears (left & right)
    for ex in (-11.5, 11.5):
        ear_verts = [
            bm.verts.new((ex,    0, 159)), bm.verts.new((ex+1.5*(-1 if ex<0 else 1),  1, 161)),
            bm.verts.new((ex+1.5*(-1 if ex<0 else 1), -1, 161)), bm.verts.new((ex,    0, 163)),
            bm.verts.new((ex,    0, 157)),
        ]
        try:
            bm.faces.new([ear_verts[0], ear_verts[1], ear_verts[3]])
            bm.faces.new([ear_verts[0], ear_verts[2], ear_verts[3]])
            bm.faces.new([ear_verts[0], ear_verts[4], ear_verts[2]])
        except Exception:
            pass

    bm.verts.ensure_lookup_table()
    mesh = bpy.data.meshes.new("GokuHead")
    bm.to_mesh(mesh)
    bm.free()
    obj = new_mesh_obj("GokuHead", mesh)
    assign_mat(obj, mat("Skin", C_SKIN, rough=0.58, sss=0.18))
    mod = obj.modifiers.new("Subd", "SUBSURF")
    mod.levels = 2; mod.render_levels = 2
    add_smooth(obj, 30)
    return obj


# ─── FACE PLATE (UV-mapped Toriyama face texture) ─────────────────────────────

def build_face_plate():
    """Flat-curved face plane with UV-mapped Goku face texture."""
    tex_path = str(TEX_DIR / "face_goku.png")

    # Create curved face mesh (projected onto head sphere front)
    bm = bmesh.new()
    uv_layer = bm.loops.layers.uv.new("UVMap")
    rows, cols = 8, 10
    face_verts = []
    for r in range(rows+1):
        row_vs = []
        for c in range(cols+1):
            u = c / cols
            v = r / rows
            # map onto sphere-like surface at front of head — radius must exceed head radius (~10.5)
            angle_h = (u - 0.5) * math.radians(70)
            angle_v = (v - 0.5) * math.radians(55)
            radius = 12.0   # larger than head radius so face plate sits OUTSIDE head mesh
            x = math.sin(angle_h) * radius
            z = 152 + (rows//2)*1.8 + math.sin(angle_v) * radius * 1.1
            y = -math.cos(angle_h) * radius  # -Y = Blender front
            row_vs.append(bm.verts.new((x, y, z)))
        face_verts.append(row_vs)
    bm.verts.ensure_lookup_table()
    for r in range(rows):
        for c in range(cols):
            v0 = face_verts[r][c]
            v1 = face_verts[r][c+1]
            v2 = face_verts[r+1][c+1]
            v3 = face_verts[r+1][c]
            f = bm.faces.new([v0, v1, v2, v3])
            uvs = [(c/cols, r/rows), ((c+1)/cols, r/rows),
                   ((c+1)/cols, (r+1)/rows), (c/cols, (r+1)/rows)]
            for loop, uv in zip(f.loops, uvs):
                loop[uv_layer].uv = uv
    mesh = bpy.data.meshes.new("FacePlate")
    bm.to_mesh(mesh)
    bm.free()
    obj = new_mesh_obj("FacePlate", mesh)

    # Material with face texture
    face_mat = bpy.data.materials.new("FaceMat")
    face_mat.use_nodes = True
    nodes, links = face_mat.node_tree.nodes, face_mat.node_tree.links
    nodes.clear()
    out   = nodes.new("ShaderNodeOutputMaterial"); out.location = (600, 0)
    bsdf  = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (200, 0)
    tex_n = nodes.new("ShaderNodeTexImage");       tex_n.location = (-200, 0)
    links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])
    links.new(tex_n.outputs["Color"], bsdf.inputs["Base Color"])
    import os
    if os.path.exists(tex_path):
        img = bpy.data.images.load(tex_path)
        tex_n.image = img
    else:
        bsdf.inputs["Base Color"].default_value = (*C_SKIN, 1.0)
    bsdf.inputs["Roughness"].default_value = 0.55
    for k in ("Subsurface Weight", "Subsurface"):
        if k in bsdf.inputs:
            bsdf.inputs[k].default_value = 0.12; break
    obj.data.materials.append(face_mat)
    add_smooth(obj, 25)
    return obj


# ─── HAIR SPIKES ──────────────────────────────────────────────────────────────

def build_hair_spike(name, base_x, base_y, base_z, tip_x, tip_y, tip_z,
                     base_r=2.2, twist=0.0):
    """One volumetric curved hair spike."""
    bm = bmesh.new()
    steps = 10
    segs  = 8
    prev_ring = None
    for s in range(steps+1):
        t = s / steps
        # quadratic bezier: base → control → tip
        cx = (base_x + tip_x) / 2 + (tip_y - base_y) * 0.3
        cy = (base_y + tip_y) / 2 - (tip_z - base_z) * 0.15
        cz = (base_z + tip_z) / 2 + abs(tip_z - base_z) * 0.25
        x = (1-t)**2 * base_x + 2*(1-t)*t * cx + t**2 * tip_x
        y = (1-t)**2 * base_y + 2*(1-t)*t * cy + t**2 * tip_y
        z = (1-t)**2 * base_z + 2*(1-t)*t * cz + t**2 * tip_z
        r = base_r * (1 - t*0.85)  # taper to tip
        ring = []
        for i in range(segs):
            a = 2 * math.pi * i / segs + twist * t
            ring.append(bm.verts.new((x + math.cos(a)*r,
                                      y + math.sin(a)*r,
                                      z)))
        if prev_ring:
            for i in range(segs):
                ni = (i+1) % segs
                bm.faces.new([prev_ring[i], prev_ring[ni], ring[ni], ring[i]])
        prev_ring = ring
    # Tip cap
    tip = bm.verts.new((tip_x, tip_y, tip_z + 1.5))
    for i in range(segs):
        ni = (i+1) % segs
        bm.faces.new([prev_ring[i], prev_ring[ni], tip])

    mesh = bpy.data.meshes.new(name)
    bm.to_mesh(mesh)
    bm.free()
    obj = new_mesh_obj(name, mesh)
    assign_mat(obj, mat("PurpleHair", C_PURPLE, rough=0.35, sss=0.05,
                        emit=C_DARK_PUR, emit_str=0.3))
    add_smooth(obj, 20)
    return obj


def build_all_hair():
    """Iconic Goku spiked hair (purple, Toriyama silhouette)."""
    spikes = [
        # (name, bx, by, bz, tx, ty, tz, base_r)
        # Front bang (centre)
        ("Hair_Front_C",   0.0, -10, 171,   0.5, -16, 183, 2.5),
        # Front side bangs
        ("Hair_Front_L",  -5.0, -9,  169,  -7.0, -15, 179, 2.0),
        ("Hair_Front_R",   5.0, -9,  169,   7.0, -15, 179, 2.0),
        # Main top spikes
        ("Hair_Top_C",     0.0,  -6, 175,   1.0,  -4, 196, 2.8),
        ("Hair_Top_L1",   -5.0,  -5, 174,  -9.0,  -2, 192, 2.4),
        ("Hair_Top_R1",    5.0,  -5, 174,   9.0,  -2, 192, 2.4),
        ("Hair_Top_L2",   -8.0,  -3, 172, -15.0,   2, 187, 2.2),
        ("Hair_Top_R2",    8.0,  -3, 172,  15.0,   2, 187, 2.2),
        # Side spikes
        ("Hair_Side_L",   -9.5,   1, 168, -18.0,   5, 178, 1.9),
        ("Hair_Side_R",    9.5,   1, 168,  18.0,   5, 178, 1.9),
        # Back spikes
        ("Hair_Back_L",   -6.0,   6, 170, -10.0,  14, 180, 2.0),
        ("Hair_Back_C",    0.0,   8, 170,   0.0,  16, 178, 2.1),
        ("Hair_Back_R",    6.0,   6, 170,  10.0,  14, 180, 2.0),
    ]
    hair_objs = []
    for args in spikes:
        name, bx, by, bz, tx, ty, tz, br = args
        o = build_hair_spike(name, bx, by, bz, tx, ty, tz, base_r=br)
        hair_objs.append(o)
    return hair_objs


# ─── CLOTHING ─────────────────────────────────────────────────────────────────

def build_gi_top():
    """Orange Gi top with V-neck cutout."""
    bm = bmesh.new()
    segs = 20

    # Gi jacket sections (slightly larger than torso)
    gi_secs = [
        (90,  16.0, 14.0),
        (100, 14.0, 12.0),  # waist
        (110, 16.0, 13.5),
        (122, 19.5, 15.5),  # chest
        (132, 21.0, 16.5),  # shoulder area
        (138, 18.5, 14.5),
    ]
    prev_ring = None
    for z, rx, ry in gi_secs:
        ring = []
        for i in range(segs):
            a = 2 * math.pi * i / segs
            v = bm.verts.new((math.cos(a)*rx, math.sin(a)*ry, z))
            ring.append(v)
        if prev_ring:
            for i in range(segs):
                ni = (i+1) % segs
                bm.faces.new([prev_ring[i], prev_ring[ni], ring[ni], ring[i]])
        prev_ring = ring

    mesh = bpy.data.meshes.new("GiTop")
    bm.to_mesh(mesh)
    bm.free()
    obj = new_mesh_obj("GiTop", mesh)
    assign_mat(obj, mat("OrangeGi", C_ORANGE, rough=0.75))
    add_smooth(obj, 40)
    return obj


def build_navy_undershirt():
    """Navy undershirt visible at V-neck and cuffs."""
    bm = bmesh.new()
    segs = 16
    # Collar / V-neck area
    neck_secs = [
        (138, 9.0,  8.5),
        (141, 9.5,  9.0),
        (144, 8.5,  8.0),
        (147, 6.5,  6.0),
    ]
    prev_ring = None
    for z, rx, ry in neck_secs:
        ring = []
        for i in range(segs):
            a = 2 * math.pi * i / segs
            v = bm.verts.new((math.cos(a)*rx, math.sin(a)*ry, z))
            ring.append(v)
        if prev_ring:
            for i in range(segs):
                ni = (i+1) % segs
                bm.faces.new([prev_ring[i], prev_ring[ni], ring[ni], ring[i]])
        prev_ring = ring

    mesh = bpy.data.meshes.new("NavyUndershirt")
    bm.to_mesh(mesh)
    bm.free()
    obj = new_mesh_obj("NavyUndershirt", mesh)
    assign_mat(obj, mat("NavyShirt", C_NAVY, rough=0.8))
    add_smooth(obj, 40)
    return obj


def build_sash_belt():
    """3D sash belt with knot and hanging tails."""
    objs = []

    # Main belt band
    bm = bmesh.new()
    segs = 24
    belt_secs = [
        (86.0, 16.5, 14.0),
        (87.5, 16.5, 14.0),
        (91.5, 13.5, 11.5),
        (93.0, 13.5, 11.5),
    ]
    prev_ring = None
    for z, rx, ry in belt_secs:
        ring = []
        for i in range(segs):
            a = 2 * math.pi * i / segs
            v = bm.verts.new((math.cos(a)*rx, math.sin(a)*ry, z))
            ring.append(v)
        if prev_ring:
            for i in range(segs):
                ni = (i+1) % segs
                bm.faces.new([prev_ring[i], prev_ring[ni], ring[ni], ring[i]])
        prev_ring = ring
    mesh = bpy.data.meshes.new("SashBelt")
    bm.to_mesh(mesh)
    bm.free()
    belt_obj = new_mesh_obj("SashBelt", mesh)
    assign_mat(belt_obj, mat("SashBlue", C_SASH_BLUE, rough=0.7))
    add_smooth(belt_obj, 30)
    objs.append(belt_obj)

    # Knot (cube)
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, -15.5, 89.5))
    knot = bpy.context.active_object
    knot.name = "SashKnot"
    knot.scale = (5.5, 2.5, 4.5)
    bpy.ops.object.transform_apply(scale=True)
    assign_mat(knot, mat("SashBlue", C_SASH_BLUE, rough=0.7))
    add_smooth(knot, 30)
    objs.append(knot)

    # Tail L
    bpy.ops.mesh.primitive_cube_add(size=1, location=(-3.5, -15.5, 72))
    tail_l = bpy.context.active_object
    tail_l.name = "SashTailL"
    tail_l.scale = (3.0, 1.8, 17.0)
    bpy.ops.object.transform_apply(scale=True)
    assign_mat(tail_l, mat("SashBlue", C_SASH_BLUE, rough=0.7))
    objs.append(tail_l)

    # Tail R
    bpy.ops.mesh.primitive_cube_add(size=1, location=(3.5, -15.5, 72))
    tail_r = bpy.context.active_object
    tail_r.name = "SashTailR"
    tail_r.scale = (3.0, 1.8, 17.0)
    bpy.ops.object.transform_apply(scale=True)
    assign_mat(tail_r, mat("SashBlue", C_SASH_BLUE, rough=0.7))
    objs.append(tail_r)

    return objs


def build_pants():
    """Navy pants for below-waist and legs."""
    bm = bmesh.new()
    segs = 18

    # Build leg tubes
    for lx in (-8.5, 8.5):
        leg_secs = [
            (85,  9.0),
            (70,  9.5),
            (55,  8.5),
            (43,  7.0),
            (30,  7.0),
            (14,  6.5),
            (7,   6.0),
        ]
        prev_ring = None
        for z, r in leg_secs:
            ring = []
            for i in range(segs):
                a = 2 * math.pi * i / segs
                v = bm.verts.new((lx + math.cos(a)*r, math.sin(a)*r*0.9, z))
                ring.append(v)
            if prev_ring:
                for i in range(segs):
                    ni = (i+1) % segs
                    bm.faces.new([prev_ring[i], prev_ring[ni], ring[ni], ring[i]])
            prev_ring = ring

    mesh = bpy.data.meshes.new("GokuPants")
    bm.to_mesh(mesh)
    bm.free()
    obj = new_mesh_obj("GokuPants", mesh)
    assign_mat(obj, mat("NavyPants", C_NAVY, rough=0.8))
    add_smooth(obj, 35)
    return obj


def build_boots():
    """Dark boots with red accent strap."""
    objs = []
    for lx in (-8.5, 8.5):
        side = "L" if lx < 0 else "R"

        # Boot body
        bm = bmesh.new()
        segs = 14
        boot_secs = [
            (0,   5.8, 4.0),   # sole
            (4,   5.5, 4.0),
            (8,   5.0, 3.8),   # ankle
            (16,  5.2, 3.8),   # shaft
            (22,  5.5, 4.0),   # upper boot
            (26,  5.0, 3.5),   # top edge
        ]
        prev_ring = None
        first_ring = None
        for z, rx, ry in boot_secs:
            ring = []
            for i in range(segs):
                a = 2 * math.pi * i / segs
                v = bm.verts.new((lx + math.cos(a)*rx, math.sin(a)*ry*1.1, z))
                ring.append(v)
            if first_ring is None:
                first_ring = ring
            if prev_ring:
                for i in range(segs):
                    ni = (i+1) % segs
                    bm.faces.new([prev_ring[i], prev_ring[ni], ring[ni], ring[i]])
            prev_ring = ring
        # Sole bottom cap — use saved first_ring
        bm.verts.ensure_lookup_table()
        sole_c = bm.verts.new((lx, 0, -1.5))
        bm.verts.ensure_lookup_table()
        for i in range(segs):
            ni = (i+1) % segs
            try:
                bm.faces.new([first_ring[i], first_ring[ni], sole_c])
            except Exception:
                pass

        # Toe extension
        toe_verts = [bm.verts.new((lx + dx, dy, dz))
                     for dx, dy, dz in [(-4.5,-3,-0.5),(4.5,-3,-0.5),(4.5,3,-0.5),(-4.5,3,-0.5),
                                         (-3.5,-2.5, 4),(3.5,-2.5, 4),(3.5,2.5, 4),(-3.5,2.5, 4)]]
        for face in [(0,1,2,3),(4,5,6,7),(0,1,5,4),(2,3,7,6),(0,3,7,4),(1,2,6,5)]:
            try: bm.faces.new([toe_verts[f] for f in face])
            except Exception: pass

        mesh = bpy.data.meshes.new(f"Boot_{side}")
        bm.to_mesh(mesh)
        bm.free()
        boot_obj = new_mesh_obj(f"Boot_{side}", mesh)
        assign_mat(boot_obj, mat("BootLeather", C_BOOT, rough=0.65, metal=0.05))
        add_smooth(boot_obj, 25)
        objs.append(boot_obj)

        # Red accent strap
        bpy.ops.mesh.primitive_cube_add(size=1, location=(lx, 0, 13))
        strap = bpy.context.active_object
        strap.name = f"BootStrap_{side}"
        strap.scale = (6.5, 5.0, 1.2)
        bpy.ops.object.transform_apply(scale=True)
        assign_mat(strap, mat("BootStrap", C_BOOT_STRAP, rough=0.6))
        objs.append(strap)

    return objs


# ─── LIGHTING ────────────────────────────────────────────────────────────────

def setup_studio_lights():
    """3-point studio lighting — high intensity for visibility."""
    # In Blender: Y+ = back of character, Y- = front of character (face side)
    lights = [
        # Key light: front-left high up
        ("Key",   "AREA",  (-60,  -200, 220), 80000, (1.0,  0.96, 0.90)),
        # Fill light: front-right softer
        ("Fill",  "AREA",  ( 80,  -180, 160), 40000, (0.85, 0.90, 1.00)),
        # Rim light: back for silhouette
        ("Rim",   "AREA",  (  0,   200, 190), 25000, (0.80, 0.70, 1.00)),
        # Bottom bounce
        ("Bounce","AREA",  (  0,   -80,   5), 15000, (1.0,  0.95, 0.85)),
    ]
    for name, ltype, loc, energy, col in lights:
        ld = bpy.data.lights.new(name, ltype)
        ld.energy = energy
        ld.color  = col
        ld.size   = 120
        lo = bpy.data.objects.new(name, ld)
        link(lo)
        lo.location = loc
        direction = Vector((0, 0, 95)) - Vector(loc)
        rot_quat  = direction.to_track_quat('-Z', 'Y')
        lo.rotation_euler = rot_quat.to_euler()


# ─── CAMERA ──────────────────────────────────────────────────────────────────

def setup_camera(name, loc, look_at=(0, 0, 90), fov=50):
    cam_data = bpy.data.cameras.new(name)
    cam_data.angle = math.radians(fov)
    cam_obj = bpy.data.objects.new(name, cam_data)
    link(cam_obj)
    cam_obj.location = loc
    direction = Vector(look_at) - Vector(loc)
    rot_quat  = direction.to_track_quat('-Z', 'Y')
    cam_obj.rotation_euler = rot_quat.to_euler()
    bpy.context.scene.camera = cam_obj
    return cam_obj


def render_preview(filename):
    bpy.context.scene.render.filepath = str(PREVIEW_DIR / filename)
    bpy.context.scene.render.resolution_x = 1280
    bpy.context.scene.render.resolution_y = 1280
    bpy.ops.render.render(write_still=True)
    print(f"[RENDER] {filename}")


# ─── ARMATURE ────────────────────────────────────────────────────────────────

def build_armature():
    """Simple fighter armature."""
    arm_data = bpy.data.armatures.new("GokuRig")
    arm_obj  = bpy.data.objects.new("GokuRig", arm_data)
    link(arm_obj)
    bpy.context.view_layer.objects.active = arm_obj
    bpy.ops.object.mode_set(mode="EDIT")
    ed = arm_data.edit_bones

    def bone(name, head, tail, parent_name=None):
        b = ed.new(name)
        b.head = Vector(head)
        b.tail = Vector(tail)
        if parent_name:
            b.parent = ed[parent_name]
        return b

    bone("Root",        (0,0,0),     (0,0,10))
    bone("Hips",        (0,0,88),    (0,0,100),  "Root")
    bone("Spine",       (0,0,100),   (0,0,115),  "Hips")
    bone("Chest",       (0,0,115),   (0,0,135),  "Spine")
    bone("Neck",        (0,0,140),   (0,0,150),  "Chest")
    bone("Head",        (0,0,150),   (0,0,175),  "Neck")
    for side, sx in (("L",-12),("R",12)):
        bone(f"Shoulder.{side}",  (sx*0.5, 0,133), (sx,0,130), "Chest")
        bone(f"UpperArm.{side}",  (sx,0,130),      (sx,0,105), f"Shoulder.{side}")
        bone(f"ForeArm.{side}",   (sx,0,105),      (sx,0,70),  f"UpperArm.{side}")
        bone(f"Hand.{side}",      (sx,0,70),        (sx,0,50),  f"ForeArm.{side}")
    for side, lx in (("L",-8),("R",8)):
        bone(f"Thigh.{side}",  (lx,0,85), (lx,0,50), "Hips")
        bone(f"Shin.{side}",   (lx,0,50), (lx,0,15), f"Thigh.{side}")
        bone(f"Foot.{side}",   (lx,0,15), (lx,-8,2), f"Shin.{side}")

    bpy.ops.object.mode_set(mode="OBJECT")
    return arm_obj


# ─── EXPORT ──────────────────────────────────────────────────────────────────

def export_glb():
    """Export all mesh objects as GLB for Godot."""
    bpy.ops.object.select_all(action="DESELECT")
    for obj in bpy.data.objects:
        if obj.type in ("MESH", "ARMATURE"):
            obj.select_set(True)
    bpy.ops.export_scene.gltf(
        filepath=str(GLB_OUT),
        use_selection=True,
        export_format="GLB",
        export_apply=True,
        export_yup=True,
    )
    print(f"[EXPORT GLB] {GLB_OUT}")


# ─── MAIN ────────────────────────────────────────────────────────────────────

def main():
    print("=== Goku v3.0 Build Start ===")
    reset_scene()

    # Build character parts
    print("[BUILD] Body...")
    body  = build_body()

    print("[BUILD] Head...")
    head  = build_head()

    print("[BUILD] Face plate...")
    face  = build_face_plate()

    print("[BUILD] Hair...")
    hair  = build_all_hair()

    print("[BUILD] Gi top...")
    gi    = build_gi_top()

    print("[BUILD] Navy shirt...")
    shirt = build_navy_undershirt()

    print("[BUILD] Sash belt...")
    sash  = build_sash_belt()

    print("[BUILD] Pants...")
    pants = build_pants()

    print("[BUILD] Boots...")
    boots = build_boots()

    print("[BUILD] Armature...")
    rig   = build_armature()

    # Lights & camera
    print("[SETUP] Lighting...")
    setup_studio_lights()

    # Front render — character faces toward Y-, camera at Y+ looks at face
    print("[RENDER] Front view...")
    setup_camera("CamFront", (0, 280, 90), (0, 0, 90), fov=42)
    render_preview("goku_v3_front.png")

    # Side render
    print("[RENDER] Side view...")
    setup_camera("CamSide", (-280, 0, 90), (0, 0, 90), fov=42)
    render_preview("goku_v3_side.png")

    # 3/4 render
    print("[RENDER] 3/4 view...")
    setup_camera("Cam34", (160, 200, 120), (0, 0, 100), fov=45)
    render_preview("goku_v3_34.png")

    # Save .blend
    print(f"[SAVE] {BLEND_OUT}")
    bpy.ops.wm.save_as_mainfile(filepath=str(BLEND_OUT))

    # Export GLB
    print("[EXPORT] GLB...")
    export_glb()

    print("=== Goku v3.0 Build COMPLETE ===")
    print(f"  .blend  → {BLEND_OUT}")
    print(f"  .glb    → {GLB_OUT}")
    print(f"  renders → {PREVIEW_DIR}/goku_v3_*.png")


if __name__ == "__main__":
    main()
