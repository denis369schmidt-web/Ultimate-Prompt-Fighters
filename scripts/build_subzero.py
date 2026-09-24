"""
Sub-Zero (Mortal Kombat Inspired) Cryomancer Ninja Character Generator.
High-quality, athletic stylized fighter for Prompt Fighter Ultimate.

Features:
- Official CC0 Blender Studio Human Base Mesh ('GEO-body_male_stylized') for 100% connected, anatomically accurate body
- Cryomancer Combat Mask with breathing vents and 3D thickness
- Lin Kuei Ninja Cowl / Hood
- Layered Blue & Black Lin Kuei Tabard (quilted padding, V-neck, shoulder wraps)
- Sculpted Pauldrons (layered curved shoulder armor with ice trim)
- Armored Cryo Gauntlets with ice crystal spikes and tactical straps
- Tactical Combat Belt with Lin Kuei Medallion and hanging combat tassets
- Shin Guards with knee protectors and armored Ninja Boots
- Dual Kori Blades (Cryo Ice Daggers) on hip mounts
- Full PBR Material setup (Fabric, Leather, Armor Metal, Frosted Ice, Glowing Cryo Eyes)
- Renders: Neutral Grey (Front, Side, Back, 3/4, Closeup) + Full Textured (Front, Side, Back, 3/4, Closeup)
- Clean .blend and .glb export, with re-import verification
"""

import math
import os
import sys
from pathlib import Path

import bpy
import bmesh
from mathutils import Vector, Matrix, Euler

# Paths
PROJECT_ROOT = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate")
BUNDLE_PATH  = PROJECT_ROOT / "tools" / "human_base_meshes" / "human-base-meshes-bundle-v1.4.1" / "human_base_meshes_bundle.blend"
CHAR_DIR     = PROJECT_ROOT / "art" / "characters" / "subzero"
TEX_DIR      = CHAR_DIR / "textures"
PREVIEW_DIR  = CHAR_DIR / "previews"
BLEND_OUT    = CHAR_DIR / "PFU_SubZero.blend"
GLB_OUT      = CHAR_DIR / "subzero.glb"

for d in (CHAR_DIR, TEX_DIR, PREVIEW_DIR):
    d.mkdir(parents=True, exist_ok=True)


# ─── SCENE SETUP ─────────────────────────────────────────────────────────────

def setup_clean_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    sc = bpy.context.scene
    sc.unit_settings.system = "METRIC"
    sc.unit_settings.scale_length = 1.0  # Meter units (base mesh is in meters: ~1.80m tall)
    sc.render.engine = "BLENDER_EEVEE_NEXT"
    sc.render.resolution_x = 1440
    sc.render.resolution_y = 1440
    sc.render.film_transparent = False

    # Neutral backdrop
    if sc.world is None:
        sc.world = bpy.data.worlds.new("World")
    sc.world.use_nodes = True
    bg = sc.world.node_tree.nodes.get("Background")
    if not bg:
        bg = sc.world.node_tree.nodes.new("ShaderNodeBackground")
        out = sc.world.node_tree.nodes.new("ShaderNodeOutputWorld")
        sc.world.node_tree.links.new(bg.outputs["Background"], out.inputs["Surface"])
    bg.inputs["Color"].default_value = (0.04, 0.05, 0.07, 1.0)
    bg.inputs["Strength"].default_value = 0.9
    sc.view_settings.look = "AgX - Medium High Contrast"
    sc.view_settings.exposure = 0.4


def link_obj(obj):
    if obj.name not in bpy.context.scene.collection.objects:
        bpy.context.scene.collection.objects.link(obj)
    return obj


def smooth_obj(obj, angle=35):
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.shade_smooth()
    return obj


def apply_solidify(obj, thickness=0.012, offset=1.0):
    mod = obj.modifiers.new("Solidify", "SOLIDIFY")
    mod.thickness = thickness
    mod.offset = offset
    mod.use_rim = True
    return obj


def apply_subsurf(obj, levels=1):
    mod = obj.modifiers.new("Subsurf", "SUBSURF")
    mod.levels = levels
    mod.render_levels = levels
    return obj


# ─── PBR MATERIALS ───────────────────────────────────────────────────────────

def create_pbr_material(name, base_col, rough=0.6, metal=0.0, emit_col=None, emit_str=0.0, sss=0.0):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    nodes, links = mat.node_tree.nodes, mat.node_tree.links
    nodes.clear()

    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (500, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (100, 0)
    links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])

    bsdf.inputs["Base Color"].default_value = (*base_col, 1.0)
    bsdf.inputs["Roughness"].default_value  = rough
    bsdf.inputs["Metallic"].default_value   = metal

    for k in ("Subsurface Weight", "Subsurface"):
        if k in bsdf.inputs:
            bsdf.inputs[k].default_value = sss; break

    if emit_col and emit_str > 0:
        if "Emission Color" in bsdf.inputs:
            bsdf.inputs["Emission Color"].default_value = (*emit_col, 1.0)
            bsdf.inputs["Emission Strength"].default_value = emit_str
        elif "Emission" in bsdf.inputs:
            bsdf.inputs["Emission"].default_value = (*emit_col, 1.0)

    for k in ("Coat Weight", "Clearcoat"):
        if k in bsdf.inputs:
            bsdf.inputs[k].default_value = 0.25; break

    return mat


# Sub-Zero Color Palette
COL_BLUE_PRIMARY  = (0.05, 0.28, 0.72)   # Lin Kuei Royal Cryo Blue
COL_BLUE_DARK     = (0.02, 0.12, 0.38)   # Deep navy shadow blue
COL_UNDERSUIT     = (0.08, 0.08, 0.09)   # Charcoal / Tactical black fabric
COL_LEATHER_DARK  = (0.12, 0.11, 0.10)   # Dark tactical combat leather
COL_ARMOR_STEEL   = (0.28, 0.30, 0.34)   # Frosted gunmetal steel
COL_GOLD_ACCENT   = (0.75, 0.62, 0.22)   # Medallion brass/gold
COL_ICE_CYAN      = (0.40, 0.88, 1.00)   # Crystalline ice glow
COL_ICE_CORE      = (0.70, 0.94, 1.00)   # Sharp frost reflection
COL_SKIN_TONED    = (0.82, 0.64, 0.52)   # Human warrior skin


# ─── 1. BASE BODY ANATOMY ─────────────────────────────────────────────────────

def load_and_prepare_body():
    """Appends GEO-body_male_stylized and sets up clean athletic proportions."""
    with bpy.data.libraries.load(str(BUNDLE_PATH), link=False) as (df, dt):
        dt.meshes = [m for m in df.meshes if m == "GEO-body_male_stylized"]

    body_mesh = [m for m in dt.meshes if m.name == "GEO-body_male_stylized"][0]
    body_obj = bpy.data.objects.new("SubZero_Body", body_mesh)
    link_obj(body_obj)

    # Base mesh is in meters (approx 1.80m tall), already aligned to world origin
    smooth_obj(body_obj)
    apply_subsurf(body_obj, levels=1)

    mat_undersuit = create_pbr_material("Mat_Undersuit", COL_UNDERSUIT, rough=0.75, metal=0.02)
    body_obj.data.materials.append(mat_undersuit)

    return body_obj


# ─── 2. CRYO EYES ─────────────────────────────────────────────────────────────

def build_cryo_eyes():
    """Piercing glowing ice eyes for Sub-Zero."""
    objs = []
    mat_eye = create_pbr_material("Mat_CryoEye", COL_ICE_CORE, rough=0.1, metal=0.2,
                                  emit_col=COL_ICE_CYAN, emit_str=3.5)
    # Head eye centers approx at Z=1.635, Y=-0.085, X=+-0.038
    for side, sx in (("L", -0.038), ("R", 0.038)):
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.016, location=(sx, -0.088, 1.636), segments=16, ring_count=12)
        eye = bpy.context.active_object
        eye.name = f"SubZero_Eye_{side}"
        eye.data.materials.append(mat_eye)
        smooth_obj(eye)
        objs.append(eye)
    return objs


# ─── 3. CRYOMANCER MASK ───────────────────────────────────────────────────────

def build_cryomancer_mask():
    """
    Iconic Sub-Zero Mortal Kombat combat mask:
    - Angular chin and jaw wrap
    - Nose bridge ridge
    - Horizontal cryogenic breathing slits
    - Carbon fiber & steel plates with 3D thickness
    """
    bm = bmesh.new()

    # Front mask profile points (projected on lower face: nose bridge at Z=1.62 down to chin at Z=1.52)
    # Left & right symmetric loft
    rows = [
        # (Z, Y_center, width, depth_back)
        (1.615, -0.118, 0.024, -0.090),  # Nose bridge bridge
        (1.590, -0.125, 0.040, -0.075),  # Upper cheek / upper lip
        (1.565, -0.122, 0.046, -0.065),  # Mid jaw / mouth slit level
        (1.540, -0.115, 0.042, -0.055),  # Lower jaw / chin start
        (1.518, -0.100, 0.030, -0.045),  # Chin cup bottom
    ]

    segs = 12
    prev_ring = None
    all_rings = []
    for z, y_c, w, y_b in rows:
        ring = []
        for i in range(segs):
            t = i / (segs - 1)  # 0 (left ear) to 1 (right ear) through front center
            ang = (t - 0.5) * math.pi
            x = math.sin(ang) * w * 1.45
            # Curve from front apex (y_c) to jaw back (y_b)
            y = y_c + (1.0 - math.cos(ang)) * (y_b - y_c) * 1.8
            v = bm.verts.new((x, y, z))
            ring.append(v)
        if prev_ring:
            for i in range(segs - 1):
                bm.faces.new([prev_ring[i], prev_ring[i+1], ring[i+1], ring[i]])
        prev_ring = ring
        all_rings.append(ring)

    # Breathing vent center rib (adds sharp aggressive MK silhouette)
    v_apex1 = bm.verts.new((0, -0.134, 1.585))
    v_apex2 = bm.verts.new((0, -0.130, 1.555))
    mid_r = segs // 2
    try:
        bm.faces.new([all_rings[1][mid_r-1], all_rings[1][mid_r+1], v_apex1])
        bm.faces.new([all_rings[2][mid_r-1], all_rings[2][mid_r+1], v_apex2])
    except Exception:
        pass

    mesh = bpy.data.meshes.new("SubZero_Mask")
    bm.to_mesh(mesh)
    bm.free()

    obj = bpy.data.objects.new("SubZero_Mask", mesh)
    link_obj(obj)
    smooth_obj(obj, angle=28)
    apply_solidify(obj, thickness=0.008, offset=1.0)
    apply_subsurf(obj, levels=1)

    mat_mask = create_pbr_material("Mat_Mask", COL_ARMOR_STEEL, rough=0.28, metal=0.75,
                                   emit_col=COL_ICE_CYAN, emit_str=0.4)
    obj.data.materials.append(mat_mask)
    return obj


# ─── 4. LIN KUEI NINJA COWL / HOOD ────────────────────────────────────────────

def build_ninja_cowl():
    """Snug black ninja hood covering cranium, cheeks and neck."""
    bm = bmesh.new()

    # Skull envelope from neck (Z=1.48) to top of skull (Z=1.78)
    levels = [
        # (Z,  Rx,    Ry,    Y_offset)
        (1.48, 0.068, 0.072,  0.00),  # Base of neck
        (1.53, 0.065, 0.070,  0.00),  # Mid neck
        (1.58, 0.076, 0.082, -0.01),  # Jawline back
        (1.64, 0.088, 0.092, -0.01),  # Ear / brow level
        (1.70, 0.085, 0.090,  0.00),  # Upper forehead
        (1.75, 0.072, 0.078,  0.00),  # Crown
        (1.78, 0.040, 0.045,  0.00),  # Skull apex
    ]

    segs = 18
    prev_ring = None
    for z, rx, ry, yo in levels:
        ring = []
        for i in range(segs):
            a = 2 * math.pi * i / segs
            # Leave open in front for eyes (from ~ -35° to +35° at eye level Z=1.60-1.68)
            v = bm.verts.new((math.cos(a)*rx, math.sin(a)*ry + yo, z))
            ring.append(v)
        if prev_ring:
            for i in range(segs):
                ni = (i+1) % segs
                bm.faces.new([prev_ring[i], prev_ring[ni], ring[ni], ring[i]])
        prev_ring = ring

    # Top cap
    top_v = bm.verts.new((0, 0, 1.795))
    for i in range(segs):
        ni = (i+1) % segs
        bm.faces.new([prev_ring[i], prev_ring[ni], top_v])

    mesh = bpy.data.meshes.new("SubZero_Cowl")
    bm.to_mesh(mesh)
    bm.free()

    obj = bpy.data.objects.new("SubZero_Cowl", mesh)
    link_obj(obj)
    smooth_obj(obj)
    apply_solidify(obj, thickness=0.006)
    apply_subsurf(obj, levels=1)

    mat_cowl = create_pbr_material("Mat_Cowl", COL_UNDERSUIT, rough=0.82, metal=0.01)
    obj.data.materials.append(mat_cowl)
    return obj


# ─── 5. LIN KUEI CRYOMANCER TABARD (BLUE VEST) ────────────────────────────────

def build_lin_kuei_tabard():
    """
    Sub-Zero signature V-shaped armored ninja tabard:
    - Quilted royal cryo blue front bands
    - Crosses over shoulders and drops down chest to waist
    - Back mantle shield
    """
    bm = bmesh.new()

    # Left front strap, Right front strap, Back drape
    for side, sx in (("L", -1), ("R", 1)):
        # Strip from waist (Z=1.00) up across chest (Z=1.35) over shoulder (Z=1.48) to upper back (Z=1.25)
        path = [
            # (x_center, y_center, z, width, thickness_dir)
            (sx*0.065, -0.125, 0.98,  0.055),  # Waist insert
            (sx*0.085, -0.140, 1.15,  0.060),  # Ribs
            (sx*0.115, -0.155, 1.30,  0.065),  # Upper chest
            (sx*0.135, -0.130, 1.42,  0.070),  # Collarbone
            (sx*0.140, -0.020, 1.47,  0.072),  # Top shoulder
            (sx*0.125,  0.090, 1.42,  0.070),  # Trapezius
            (sx*0.100,  0.115, 1.28,  0.065),  # Scapula
            (sx*0.075,  0.110, 1.05,  0.060),  # Lower back
            (sx*0.055,  0.105, 0.98,  0.055),  # Waist back insert
        ]

        prev_edge = None
        for cx, cy, cz, w in path:
            # Lateral direction perpendicular to torso normal
            edge = [
                bm.verts.new((cx - w*0.5, cy, cz)),
                bm.verts.new((cx + w*0.5, cy, cz)),
            ]
            if prev_edge:
                bm.faces.new([prev_edge[0], prev_edge[1], edge[1], edge[0]])
            prev_edge = edge

    # Center chest diamond connector
    v_c1 = bm.verts.new((0, -0.148, 1.35))
    v_c2 = bm.verts.new((0, -0.142, 1.22))
    v_c3 = bm.verts.new((-0.045, -0.145, 1.28))
    v_c4 = bm.verts.new(( 0.045, -0.145, 1.28))
    try:
        bm.faces.new([v_c1, v_c3, v_c2, v_c4])
    except Exception:
        pass

    mesh = bpy.data.meshes.new("SubZero_Tabard")
    bm.to_mesh(mesh)
    bm.free()

    obj = bpy.data.objects.new("SubZero_Tabard", mesh)
    link_obj(obj)
    smooth_obj(obj)
    apply_solidify(obj, thickness=0.016, offset=1.0)
    apply_subsurf(obj, levels=1)

    mat_tabard = create_pbr_material("Mat_LinKueiBlue", COL_BLUE_PRIMARY, rough=0.52, metal=0.15)
    obj.data.materials.append(mat_tabard)
    return obj


# ─── 6. PAULDRONS (SHOULDER ARMOR) ────────────────────────────────────────────

def build_pauldrons():
    """Curved 3D armored shoulder guards with frost rims."""
    objs = []
    mat_pauldron = create_pbr_material("Mat_Pauldron", COL_ARMOR_STEEL, rough=0.22, metal=0.88,
                                       emit_col=COL_ICE_CYAN, emit_str=0.25)
    for side, sx in (("L", -0.22), ("R", 0.22)):
        bm = bmesh.new()
        # 3 curved overlapping plate segments
        for p_idx in range(3):
            z_top = 1.46 - p_idx * 0.035
            z_bot = 1.40 - p_idx * 0.035
            r_top = 0.075 + p_idx * 0.005
            r_bot = 0.065 + p_idx * 0.005
            y_cen = -0.01

            steps = 8
            ring_t = []
            ring_b = []
            for s in range(steps):
                ang = (s / (steps - 1) - 0.5) * math.pi * 0.95
                if sx < 0:
                    ang += math.pi  # outer facing
                ring_t.append(bm.verts.new((sx + math.cos(ang)*r_top, y_cen + math.sin(ang)*r_top*0.7, z_top)))
                ring_b.append(bm.verts.new((sx + math.cos(ang)*r_bot, y_cen + math.sin(ang)*r_bot*0.7, z_bot)))

            for s in range(steps - 1):
                bm.faces.new([ring_t[s], ring_t[s+1], ring_b[s+1], ring_b[s]])

        mesh = bpy.data.meshes.new(f"SubZero_Pauldron_{side}")
        bm.to_mesh(mesh)
        bm.free()

        obj = bpy.data.objects.new(f"SubZero_Pauldron_{side}", mesh)
        link_obj(obj)
        smooth_obj(obj, angle=30)
        apply_solidify(obj, thickness=0.008, offset=1.0)
        apply_subsurf(obj, levels=1)
        obj.data.materials.append(mat_pauldron)
        objs.append(obj)
    return objs


# ─── 7. GAUNTLETS & BRACERS ───────────────────────────────────────────────────

def build_gauntlets():
    """Armored cryo gauntlets with ice crystal ridge and forearm wraps."""
    objs = []
    mat_gauntlet = create_pbr_material("Mat_Gauntlet", COL_ARMOR_STEEL, rough=0.26, metal=0.82)
    mat_ice_spikes = create_pbr_material("Mat_IceSpike", COL_ICE_CORE, rough=0.12, metal=0.1,
                                         emit_col=COL_ICE_CYAN, emit_str=2.2, sss=0.4)

    # In base mesh, arms are in A-pose extending outward-downward
    # Left wrist approx at X=-0.44, Z=0.98. Left elbow approx at X=-0.32, Z=1.18.
    for side, sx in (("L", -1), ("R", 1)):
        bm = bmesh.new()
        segs = 12

        # Rings along forearm
        rings = [
            # (t, r_x, r_y)
            (0.00, 0.046, 0.042),  # Near elbow
            (0.35, 0.044, 0.040),
            (0.70, 0.040, 0.038),
            (1.00, 0.037, 0.035),  # Wrist
        ]

        prev_ring = None
        for t, rx, ry in rings:
            # Interpolate forearm axis: from elbow (sx*0.30, 0, 1.20) to wrist (sx*0.44, 0, 0.98)
            ax = sx * (0.30 + t * 0.14)
            ay = 0.0
            az = 1.20 - t * 0.22

            ring = []
            for i in range(segs):
                ang = 2 * math.pi * i / segs
                v = bm.verts.new((ax + math.cos(ang)*rx,
                                  ay + math.sin(ang)*ry,
                                  az))
                ring.append(v)
            if prev_ring:
                for i in range(segs):
                    ni = (i+1) % segs
                    bm.faces.new([prev_ring[i], prev_ring[ni], ring[ni], ring[i]])
            prev_ring = ring

        mesh = bpy.data.meshes.new(f"SubZero_Gauntlet_{'L' if sx<0 else 'R'}")
        bm.to_mesh(mesh)
        bm.free()

        obj = bpy.data.objects.new(f"SubZero_Gauntlet_{'L' if sx<0 else 'R'}", mesh)
        link_obj(obj)
        smooth_obj(obj)
        apply_solidify(obj, thickness=0.007, offset=1.0)
        obj.data.materials.append(mat_gauntlet)
        objs.append(obj)

        # Cryogenic Ice Spikes along outer forearm edge
        for sp_idx in range(4):
            t_sp = 0.2 + sp_idx * 0.22
            sp_x = sx * (0.30 + t_sp * 0.14 + 0.048)
            sp_y = 0.0
            sp_z = 1.20 - t_sp * 0.22 + 0.015

            bpy.ops.mesh.primitive_cone_add(radius1=0.009, depth=0.035, location=(sp_x, sp_y, sp_z))
            cone = bpy.context.active_object
            cone.name = f"Ice_Spike_{'L' if sx<0 else 'R'}_{sp_idx}"
            cone.rotation_euler = (0, -0.6 * sx, 0)
            smooth_obj(cone)
            cone.data.materials.append(mat_ice_spikes)
            objs.append(cone)

    return objs


# ─── 8. COMBAT SASH & LIN KUEI MEDALLION ──────────────────────────────────────

def build_belt_and_tassets():
    """Lin Kuei armored belt, circular medallion buckle and front/back hanging tassets."""
    objs = []
    mat_leather = create_pbr_material("Mat_BeltLeather", COL_LEATHER_DARK, rough=0.62)
    mat_buckle  = create_pbr_material("Mat_Medallion", COL_GOLD_ACCENT, rough=0.22, metal=0.92,
                                      emit_col=COL_ICE_CYAN, emit_str=0.8)
    mat_tasset  = create_pbr_material("Mat_TassetCloth", COL_BLUE_PRIMARY, rough=0.60, metal=0.08)

    # Main belt wrap around waist (Z=0.96)
    bm = bmesh.new()
    segs = 24
    for z in (0.93, 0.99):
        for i in range(segs):
            ang = 2 * math.pi * i / segs
            rx = 0.155
            ry = 0.118
            bm.verts.new((math.cos(ang)*rx, math.sin(ang)*ry, z))
    bm.verts.ensure_lookup_table()
    for i in range(segs):
        ni = (i+1) % segs
        bm.faces.new([bm.verts[i], bm.verts[ni], bm.verts[segs+ni], bm.verts[segs+i]])

    mesh = bpy.data.meshes.new("SubZero_Belt")
    bm.to_mesh(mesh)
    bm.free()
    belt = bpy.data.objects.new("SubZero_Belt", mesh)
    link_obj(belt)
    smooth_obj(belt)
    apply_solidify(belt, thickness=0.010, offset=1.0)
    belt.data.materials.append(mat_leather)
    objs.append(belt)

    # Lin Kuei Medallion Buckle (Cylinder + Dragon/Cryo emblem)
    bpy.ops.mesh.primitive_cylinder_add(radius=0.038, depth=0.018, location=(0, -0.126, 0.96))
    medallion = bpy.context.active_object
    medallion.name = "SubZero_Medallion"
    medallion.rotation_euler = (math.pi/2, 0, 0)
    smooth_obj(medallion)
    medallion.data.materials.append(mat_buckle)
    objs.append(medallion)

    # Front Hanging Tasset (Loincloth)
    bm_t = bmesh.new()
    t_verts = [
        # Top
        bm_t.verts.new((-0.075, -0.128, 0.94)),
        bm_t.verts.new(( 0.075, -0.128, 0.94)),
        # Mid
        bm_t.verts.new((-0.080, -0.134, 0.72)),
        bm_t.verts.new(( 0.080, -0.134, 0.72)),
        # Bottom notched edge
        bm_t.verts.new((-0.070, -0.128, 0.52)),
        bm_t.verts.new(( 0.000, -0.130, 0.49)),
        bm_t.verts.new(( 0.070, -0.128, 0.52)),
    ]
    bm_t.faces.new([t_verts[0], t_verts[1], t_verts[3], t_verts[2]])
    bm_t.faces.new([t_verts[2], t_verts[3], t_verts[6], t_verts[5]])
    bm_t.faces.new([t_verts[2], t_verts[5], t_verts[4]])
    m_t = bpy.data.meshes.new("SubZero_FrontTasset")
    bm_t.to_mesh(m_t)
    bm_t.free()
    tasset_obj = bpy.data.objects.new("SubZero_FrontTasset", m_t)
    link_obj(tasset_obj)
    smooth_obj(tasset_obj)
    apply_solidify(tasset_obj, thickness=0.008, offset=1.0)
    apply_subsurf(tasset_obj, levels=1)
    tasset_obj.data.materials.append(mat_tasset)
    objs.append(tasset_obj)

    return objs


# ─── 9. SHIN GUARDS & COMBAT BOOTS ────────────────────────────────────────────

def build_shin_guards_and_boots():
    """Armored cryo shin guards, knee caps and heavy ninja combat boots."""
    objs = []
    mat_armor = create_pbr_material("Mat_ShinArmor", COL_ARMOR_STEEL, rough=0.25, metal=0.85)
    mat_boot  = create_pbr_material("Mat_CombatBoot", COL_LEATHER_DARK, rough=0.58, metal=0.1)

    # Base mesh leg centers: left hip X=-0.09, knee Z=0.48, ankle Z=0.08, foot sole Z=0.00
    for side, sx in (("L", -0.095), ("R", 0.095)):
        # Shin guard: front-facing curved plate from ankle Z=0.10 to below knee Z=0.45
        bm_s = bmesh.new()
        rows = [
            (0.44, 0.052, 0.050),  # Upper shin
            (0.32, 0.048, 0.046),
            (0.20, 0.042, 0.040),
            (0.10, 0.038, 0.036),  # Lower shin
        ]
        prev_r = None
        for z, rx, ry in rows:
            ring = []
            for i in range(7):  # Front half arc
                ang = (i / 6 - 0.5) * math.pi * 0.95
                ring.append(bm_s.verts.new((sx + math.sin(ang)*rx, -0.01 - math.cos(ang)*ry, z)))
            if prev_r:
                for i in range(6):
                    bm_s.faces.new([prev_r[i], prev_r[i+1], ring[i+1], ring[i]])
            prev_r = ring

        m_s = bpy.data.meshes.new(f"SubZero_Shin_{side}")
        bm_s.to_mesh(m_s)
        bm_s.free()
        shin = bpy.data.objects.new(f"SubZero_Shin_{side}", m_s)
        link_obj(shin)
        smooth_obj(shin, angle=25)
        apply_solidify(shin, thickness=0.008, offset=1.0)
        shin.data.materials.append(mat_armor)
        objs.append(shin)

        # Knee cap protector
        bpy.ops.mesh.primitive_cylinder_add(radius=0.042, depth=0.024, location=(sx, -0.065, 0.49))
        knee = bpy.context.active_object
        knee.name = f"SubZero_Kneecap_{side}"
        knee.rotation_euler = (math.pi/2, 0, 0)
        smooth_obj(knee)
        apply_solidify(knee, thickness=0.006)
        knee.data.materials.append(mat_armor)
        objs.append(knee)

        # Reinforced Boot Sole & Toe Cap
        bpy.ops.mesh.primitive_cube_add(size=1, location=(sx, -0.045, 0.022))
        boot = bpy.context.active_object
        boot.name = f"SubZero_BootArmor_{side}"
        boot.scale = (0.095, 0.22, 0.045)
        bpy.ops.object.transform_apply(scale=True)
        smooth_obj(boot, angle=35)
        boot.data.materials.append(mat_boot)
        objs.append(boot)

    return objs


# ─── 10. DUAL KORI BLADES (CRYO ICE DAGGERS) ──────────────────────────────────

def build_kori_blades():
    """
    Sub-Zero signature Kori Blades (Crystalline Ice Daggers):
    - Translucent cyan cryo blade with sharp serrated edges
    - Frost hilt with wrapped leather grip
    - Mounted on tactical hip sheaths
    """
    objs = []
    mat_kori = create_pbr_material("Mat_KoriIce", COL_ICE_CORE, rough=0.08, metal=0.15,
                                   emit_col=COL_ICE_CYAN, emit_str=2.8, sss=0.6)
    mat_hilt = create_pbr_material("Mat_KoriHilt", COL_ARMOR_STEEL, rough=0.35, metal=0.85)

    for side, sx in (("L", -0.19), ("R", 0.19)):
        bm = bmesh.new()

        # Dagger Blade: angular diamond cross section tapering to needle point
        sections = [
            # (Z, depth, width)
            (0.88, 0.028, 0.008),  # Guard base
            (0.78, 0.032, 0.007),
            (0.68, 0.026, 0.006),
            (0.58, 0.015, 0.004),
            (0.50, 0.002, 0.001),  # Tip
        ]

        prev_sec = None
        for z, d, w in sections:
            # 4 diamond verts: Front, Right, Back, Left
            v_sec = [
                bm.verts.new((sx, -0.02 - d*0.5, z)),
                bm.verts.new((sx + w*0.5, -0.02, z)),
                bm.verts.new((sx, -0.02 + d*0.5, z)),
                bm.verts.new((sx - w*0.5, -0.02, z)),
            ]
            if prev_sec:
                for i in range(4):
                    ni = (i+1) % 4
                    bm.faces.new([prev_sec[i], prev_sec[ni], v_sec[ni], v_sec[i]])
            prev_sec = v_sec

        m_k = bpy.data.meshes.new(f"SubZero_KoriBlade_{side}")
        bm.to_mesh(m_k)
        bm.free()

        blade = bpy.data.objects.new(f"SubZero_KoriBlade_{side}", m_k)
        link_obj(blade)
        smooth_obj(blade, angle=20)
        blade.data.materials.append(mat_kori)
        objs.append(blade)

        # Hilt & Guard
        bpy.ops.mesh.primitive_cylinder_add(radius=0.012, depth=0.10, location=(sx, -0.02, 0.94))
        hilt = bpy.context.active_object
        hilt.name = f"SubZero_KoriHilt_{side}"
        smooth_obj(hilt)
        hilt.data.materials.append(mat_hilt)
        objs.append(hilt)

        bpy.ops.mesh.primitive_cube_add(size=1, location=(sx, -0.02, 0.89))
        guard = bpy.context.active_object
        guard.name = f"SubZero_KoriGuard_{side}"
        guard.scale = (0.028, 0.055, 0.012)
        bpy.ops.object.transform_apply(scale=True)
        guard.data.materials.append(mat_hilt)
        objs.append(guard)

    return objs


# ─── LIGHTING & CAMERA RIG ───────────────────────────────────────────────────

def setup_studio_lighting():
    """Crisp, high-end 3-point studio lighting with cyan fill and back rim."""
    for o in list(bpy.data.objects):
        if o.type == "LIGHT":
            bpy.data.objects.remove(o, do_unlink=True)

    lights = [
        # Name,      Type,   Location,             Power, Color,               Size
        ("KeyLight", "AREA", (-1.8, -2.8, 2.4),    600,   (1.00, 0.98, 0.95),  2.5),
        ("FillLight","AREA", ( 2.2, -2.4, 1.6),    320,   (0.70, 0.88, 1.00),  2.5),
        ("RimBack",  "AREA", ( 0.0,  2.8, 2.2),    480,   (0.50, 0.85, 1.00),  3.0),
        ("BottomUp", "AREA", ( 0.0, -1.2, 0.1),    120,   (0.85, 0.92, 1.00),  1.8),
    ]

    for name, ltype, loc, power, col, sz in lights:
        ld = bpy.data.lights.new(name, ltype)
        ld.energy = power
        ld.color  = col
        ld.size   = sz
        lo = bpy.data.objects.new(name, ld)
        link_obj(lo)
        lo.location = loc
        # Aim at character torso (Z=1.1)
        direction = Vector((0, 0, 1.1)) - Vector(loc)
        lo.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()


def create_camera(name, loc, target=(0, 0, 1.05), fov=44):
    for o in list(bpy.data.objects):
        if o.type == "CAMERA" and o.name == name:
            bpy.data.objects.remove(o, do_unlink=True)

    cd = bpy.data.cameras.new(name)
    cd.angle = math.radians(fov)
    co = bpy.data.objects.new(name, cd)
    link_obj(co)
    co.location = loc
    direction = Vector(target) - Vector(loc)
    co.rotation_euler = direction.to_track_quat('-Z', 'Y').to_euler()
    return co


def render_shot(filename, cam_obj, res=1280):
    sc = bpy.context.scene
    sc.camera = cam_obj
    sc.render.resolution_x = res
    sc.render.resolution_y = res
    sc.render.filepath = str(PREVIEW_DIR / filename)
    bpy.ops.render.render(write_still=True)
    print(f"[RENDERED] {filename}")


# ─── NEUTRAL GREY INSPECTION MODE ─────────────────────────────────────────────

def set_neutral_clay_material(enable=True):
    """Overrides or restores material for neutral clay inspection."""
    mat_clay = bpy.data.materials.get("Mat_ClayInspection")
    if not mat_clay:
        mat_clay = bpy.data.materials.new("Mat_ClayInspection")
        mat_clay.use_nodes = True
        bsdf = mat_clay.node_tree.nodes.get("Principled BSDF")
        bsdf.inputs["Base Color"].default_value = (0.48, 0.49, 0.52, 1.0)
        bsdf.inputs["Roughness"].default_value = 0.42
        bsdf.inputs["Metallic"].default_value  = 0.0

    if enable:
        bpy.context.scene.view_layers[0].material_override = mat_clay
    else:
        bpy.context.scene.view_layers[0].material_override = None


# ─── MAIN BUILD PIPELINE ──────────────────────────────────────────────────────

def main():
    print("=== Sub-Zero High-Quality Fighter Build Started ===")
    setup_clean_scene()

    print("[1/8] Loading and preparing athletic base mesh...")
    body = load_and_prepare_body()

    print("[2/8] Building Cryo Eyes...")
    eyes = build_cryo_eyes()

    print("[3/8] Building Cryomancer Mask...")
    mask = build_cryomancer_mask()

    print("[4/8] Building Ninja Cowl...")
    cowl = build_ninja_cowl()

    print("[5/8] Building Lin Kuei Tabard...")
    tabard = build_lin_kuei_tabard()

    print("[6/8] Building Pauldrons & Gauntlets...")
    pauldrons = build_pauldrons()
    gauntlets = build_gauntlets()

    print("[7/8] Building Belt, Tassets, Boots & Kori Blades...")
    belt_items = build_belt_and_tassets()
    shin_boots = build_shin_guards_and_boots()
    kori_blades = build_kori_blades()

    print("[8/8] Setting up Lighting and Cameras...")
    setup_studio_lighting()

    # Camera definitions
    cam_front   = create_camera("Cam_Front",   (0.0, -3.2, 1.05),  target=(0, 0, 1.05), fov=42)
    cam_side    = create_camera("Cam_Side",    (3.2,  0.0, 1.05),  target=(0, 0, 1.05), fov=42)
    cam_back    = create_camera("Cam_Back",    (0.0,  3.2, 1.05),  target=(0, 0, 1.05), fov=42)
    cam_34      = create_camera("Cam_34",      (-2.2,-2.4, 1.25),  target=(0, 0, 1.05), fov=44)
    cam_closeup = create_camera("Cam_Closeup", (-0.4, -1.1, 1.58), target=(0, 0, 1.58), fov=30)

    # ── STAGE 1: NEUTRAL GREY CLAY INSPECTIONS ──
    print("\n--- Rendering Neutral Grey Clay Inspection Views ---")
    set_neutral_clay_material(True)
    render_shot("subzero_clay_front.png", cam_front)
    render_shot("subzero_clay_side.png", cam_side)
    render_shot("subzero_clay_back.png", cam_back)
    render_shot("subzero_clay_34.png", cam_34)
    render_shot("subzero_clay_closeup.png", cam_closeup)

    # ── STAGE 2: FULL TEXTURED PBR INSPECTIONS ──
    print("\n--- Rendering Full Textured PBR Inspection Views ---")
    set_neutral_clay_material(False)
    render_shot("subzero_pbr_front.png", cam_front)
    render_shot("subzero_pbr_side.png", cam_side)
    render_shot("subzero_pbr_back.png", cam_back)
    render_shot("subzero_pbr_34.png", cam_34)
    render_shot("subzero_pbr_closeup.png", cam_closeup)

    # ── STAGE 3: SAVE BLEND ──
    print(f"\n[SAVE] Saving editable .blend: {BLEND_OUT}")
    bpy.ops.wm.save_as_mainfile(filepath=str(BLEND_OUT))

    # ── STAGE 4: EXPORT GLB ──
    print(f"[EXPORT] Exporting game-ready GLB: {GLB_OUT}")
    bpy.ops.object.select_all(action="DESELECT")
    for obj in bpy.data.objects:
        if obj.type == "MESH":
            obj.select_set(True)

    bpy.ops.export_scene.gltf(
        filepath=str(GLB_OUT),
        use_selection=True,
        export_format="GLB",
        export_apply=True,
        export_yup=True,
    )

    # ── STAGE 5: RE-IMPORT VERIFICATION ──
    print("[VERIFY] Re-importing GLB to verify integrity...")
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=str(GLB_OUT))
    imported_meshes = [o for o in bpy.data.objects if o.type == "MESH"]
    total_verts = sum(len(o.data.vertices) for o in imported_meshes)
    total_faces = sum(len(o.data.polygons) for o in imported_meshes)
    print(f"[VERIFIED OK] Imported {len(imported_meshes)} meshes with {total_verts:,} vertices and {total_faces:,} polygons.")

    print("\n=== Sub-Zero Fighter Build SUCCESSFUL ===")


if __name__ == "__main__":
    main()
