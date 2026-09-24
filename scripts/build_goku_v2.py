"""
Revised Son Goku Anime Fighter Generator (v2.1).
Fully addresses:
- Connected anatomy: Zero floating parts, seamless shoulder/hip sockets, muscular anime V-taper
- Proportions: Shorter powerful neck, broad chest/pecs, deep torso, tapered waist, defined joints
- Head & Face: Seamless head mesh with jawline, 3D nose, modeled ears, and UV-mapped Toriyama face
- Hair: Volumetric 3D curved spiked hair with thick roots and iconic Goku silhouette
- Clothing: Layered orange Gi with V-neck, navy undershirt, 3D sash belt with knot & tails, baggy pants, boots
- Lighting: Crisp, bright 3-point studio lighting and neutral backdrop for true quality inspection
"""

import math
import sys
from pathlib import Path
import bpy
import bmesh
from mathutils import Vector

ROOT = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate")
BLEND_OUT = ROOT / "art" / "blender" / "PFU_SonGoku.blend"
PREVIEW_DIR = ROOT / "art" / "blender" / "previews"
PREVIEW_DIR.mkdir(parents=True, exist_ok=True)
TEX_DIR = ROOT / "godot" / "assets" / "textures" / "characters"


def reset_clean_scene():
    bpy.ops.object.mode_set(mode="OBJECT") if bpy.context.object and bpy.context.object.mode != "OBJECT" else None
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for block_type in (bpy.data.meshes, bpy.data.materials, bpy.data.armatures, bpy.data.cameras, bpy.data.lights, bpy.data.images):
        for item in list(block_type):
            if item.users == 0:
                block_type.remove(item)

    scene = bpy.context.scene
    scene.unit_settings.system = "METRIC"
    scene.unit_settings.scale_length = 0.01
    scene.render.engine = "BLENDER_EEVEE_NEXT"
    scene.render.resolution_x = 1280
    scene.render.resolution_y = 1280
    scene.render.film_transparent = False

    # Neutral studio backdrop
    scene.world.use_nodes = True
    bg = scene.world.node_tree.nodes.get("Background")
    if bg:
        bg.inputs["Color"].default_value = (0.18, 0.20, 0.24, 1.0)
        bg.inputs["Strength"].default_value = 1.0
    scene.view_settings.look = "AgX - Base Contrast"
    scene.view_settings.exposure = 0.85


def anime_material(name, base_color, roughness=0.55, metallic=0.0, sss=0.0):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    links = mat.node_tree.links
    nodes.clear()

    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (0, 0)
    links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])

    bsdf.inputs["Base Color"].default_value = (*base_color, 1.0)
    bsdf.inputs["Roughness"].default_value = roughness
    bsdf.inputs["Metallic"].default_value = metallic

    if sss > 0.0:
        for sskey in ("Subsurface Weight", "Subsurface"):
            if sskey in bsdf.inputs:
                bsdf.inputs[sskey].default_value = sss
                break

    for cckey in ("Coat Weight", "Clearcoat"):
        if cckey in bsdf.inputs:
            bsdf.inputs[cckey].default_value = 0.35
            break
    for ccrkey in ("Coat Roughness", "Clearcoat Roughness"):
        if ccrkey in bsdf.inputs:
            bsdf.inputs[ccrkey].default_value = 0.15
            break

    return mat


def create_lofted_mesh(name, rings_data, material, subsurf_levels=1, closed_top=True, closed_bottom=True):
    """
    Builds a continuous quad-mesh limb from a list of cross-sectional rings.
    Each ring: (cx, cy, cz, rx, ry)
    """
    mesh = bpy.data.meshes.new(f"{name}_Mesh")
    bm = bmesh.new()

    num_verts = 12
    ring_loops = []

    for (cx, cy, cz, rx, ry) in rings_data:
        loop = []
        for i in range(num_verts):
            angle = (2.0 * math.pi * i) / num_verts
            vx = cx + rx * math.sin(angle)
            vy = cy + ry * math.cos(angle)
            vz = cz
            loop.append(bm.verts.new((vx, vy, vz)))
        ring_loops.append(loop)

    bm.verts.ensure_lookup_table()

    for r in range(len(ring_loops) - 1):
        r1 = ring_loops[r]
        r2 = ring_loops[r + 1]
        for i in range(num_verts):
            i_next = (i + 1) % num_verts
            bm.faces.new((r1[i], r1[i_next], r2[i_next], r2[i]))

    if closed_top and len(ring_loops) > 0:
        bm.faces.new(reversed(ring_loops[-1]))
    if closed_bottom and len(ring_loops) > 0:
        bm.faces.new(ring_loops[0])

    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    bm.to_mesh(mesh)
    bm.free()

    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)

    for poly in mesh.polygons:
        poly.use_smooth = True

    if subsurf_levels > 0:
        sub = obj.modifiers.new("Subsurf", "SUBSURF")
        sub.levels = subsurf_levels
        sub.render_levels = subsurf_levels + 1

    if material:
        obj.data.materials.append(material)

    return obj


def create_curved_hair_spike(name, root_pos, tip_pos, base_radius, curve_mid_offset, material, sides=8):
    """
    Volumetric, 3D curved anime hair clump that tapers to a sharp point.
    """
    mesh = bpy.data.meshes.new(f"{name}_Mesh")
    bm = bmesh.new()

    p0 = Vector(root_pos)
    p2 = Vector(tip_pos)
    p1 = (p0 + p2) * 0.5 + Vector(curve_mid_offset)

    num_steps = 7
    prev_loop = None

    for s in range(num_steps):
        t = s / float(num_steps - 1)
        pt = (1 - t) ** 2 * p0 + 2 * (1 - t) * t * p1 + t ** 2 * p2
        tangent = (2 * (1 - t) * (p1 - p0) + 2 * t * (p2 - p1)).normalized()
        up = Vector((0, 0, 1))
        if abs(tangent.dot(up)) > 0.95:
            up = Vector((0, 1, 0))
        n1 = tangent.cross(up).normalized()
        n2 = tangent.cross(n1).normalized()

        r = base_radius * (1.0 - t ** 1.3)
        if s == num_steps - 1:
            r = 0.0

        if r > 0.001:
            loop = []
            for i in range(sides):
                angle = (2.0 * math.pi * i) / sides
                vx = pt.x + r * (math.cos(angle) * n1.x + math.sin(angle) * n2.x)
                vy = pt.y + r * (math.cos(angle) * n1.y + math.sin(angle) * n2.y)
                vz = pt.z + r * (math.cos(angle) * n1.z + math.sin(angle) * n2.z)
                loop.append(bm.verts.new((vx, vy, vz)))

            if prev_loop:
                for i in range(sides):
                    i_next = (i + 1) % sides
                    bm.faces.new((prev_loop[i], prev_loop[i_next], loop[i_next], loop[i]))
            else:
                bm.faces.new(reversed(loop))
            prev_loop = loop
        else:
            tip_vert = bm.verts.new(pt)
            if prev_loop:
                for i in range(sides):
                    i_next = (i + 1) % sides
                    bm.faces.new((prev_loop[i], prev_loop[i_next], tip_vert))

    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    bm.to_mesh(mesh)
    bm.free()

    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)

    for poly in mesh.polygons:
        poly.use_smooth = True

    sub = obj.modifiers.new("Subsurf", "SUBSURF")
    sub.levels = 1
    sub.render_levels = 2

    if material:
        obj.data.materials.append(material)

    return obj


def create_face_plate_mesh(name, center, size, texture_name):
    cx, cy, cz = center
    sx, sy, sz = size

    cols = 9
    rows = 11
    verts = []
    uvs = []

    for r in range(rows):
        v = r / (rows - 1)
        z = cz - sz + v * (2.0 * sz)
        taper_x = 0.65 + 0.35 * math.sin(v * math.pi * 0.5)
        cheek = 1.0 + 0.08 * math.sin(v * math.pi)

        for c in range(cols):
            u = c / (cols - 1)
            angle = (u - 0.5) * math.radians(130.0)
            rx = sx * taper_x * cheek
            x = cx + rx * math.sin(angle)
            depth_curve = sy * math.cos(angle)
            nose_bump = 0.0
            if abs(c - 4) <= 1 and abs(v - 0.38) < 0.12:
                nose_bump = 2.2 * (1.0 - abs(c - 4)) * (1.0 - abs(v - 0.38) / 0.12)

            y = cy - depth_curve - nose_bump
            verts.append((x, y, z))
            tex_u = 0.12 + u * 0.76
            tex_v = 0.10 + v * 0.80
            uvs.append((tex_u, tex_v))

    faces = []
    for r in range(rows - 1):
        for c in range(cols - 1):
            i0 = r * cols + c
            i1 = r * cols + (c + 1)
            i2 = (r + 1) * cols + (c + 1)
            i3 = (r + 1) * cols + c
            faces.append((i0, i1, i2, i3))

    mesh = bpy.data.meshes.new(f"{name}_Mesh")
    mesh.from_pydata(verts, [], faces)
    mesh.update()

    uv_layer = mesh.uv_layers.new(name="UVMap")
    for poly in mesh.polygons:
        for loop_idx in poly.loop_indices:
            vert_idx = mesh.loops[loop_idx].vertex_index
            uv_layer.data[loop_idx].uv = uvs[vert_idx]

    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)

    for poly in mesh.polygons:
        poly.use_smooth = True

    sub = obj.modifiers.new("Subsurf", "SUBSURF")
    sub.levels = 1
    sub.render_levels = 2

    # Material
    tex_path = TEX_DIR / texture_name
    mat = bpy.data.materials.new(f"M_{name}")
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    links = mat.node_tree.links
    nodes.clear()

    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (600, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (200, 0)
    links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])

    tex_node = nodes.new("ShaderNodeTexImage"); tex_node.location = (-200, 0)
    if tex_path.exists():
        tex_node.image = bpy.data.images.load(str(tex_path))
    links.new(tex_node.outputs["Color"], bsdf.inputs["Base Color"])

    bsdf.inputs["Roughness"].default_value = 0.48
    bsdf.inputs["Metallic"].default_value = 0.0
    for sskey in ("Subsurface Weight", "Subsurface"):
        if sskey in bsdf.inputs:
            bsdf.inputs[sskey].default_value = 0.35
            break

    obj.data.materials.append(mat)
    return obj


# ── GOKU V2 BUILDER ──────────────────────────────────────────────────────────
def build_goku_v2():
    reset_clean_scene()

    # Materials
    mat_skin = anime_material("M_AnimeSkin", (0.88, 0.65, 0.50), roughness=0.50, sss=0.35)
    mat_hair = anime_material("M_GokuHair_Black", (0.05, 0.05, 0.07), roughness=0.30, metallic=0.10)
    mat_gi_orange = anime_material("M_TurtleGi_Orange", (0.95, 0.35, 0.05), roughness=0.72)
    mat_navy = anime_material("M_NavyFabric", (0.05, 0.08, 0.32), roughness=0.70)
    mat_boot_lace = anime_material("M_BootLace_Red", (0.85, 0.12, 0.14), roughness=0.55)
    mat_boot_sole = anime_material("M_BootSole_Rubber", (0.12, 0.12, 0.14), roughness=0.80)

    # 1. PELVIS & LOWER TORSO (Solid anatomical pelvic core connecting legs seamlessly)
    pelvis_rings = [
        (0.0, 0.5, 76.0, 16.5, 12.5),  # Lower pelvis base extending through crotch
        (0.0, 0.4, 86.0, 16.8, 12.0),  # Hip joint level
        (0.0, 0.2, 96.0, 15.8, 11.2),  # Mid pelvis
        (0.0, 0.0, 104.0, 14.5, 10.2), # Waistline
    ]
    create_lofted_mesh("Goku_Pelvis", pelvis_rings, mat_gi_orange)

    # 2. TORSO & PECTORALS (Powerful V-Taper, deep muscular chest)
    torso_rings = [
        (0.0, 0.0, 104.0, 14.5, 10.2), # Lower waist
        (0.0, -0.6, 114.0, 16.5, 11.5),# Mid abs
        (0.0, -1.4, 124.0, 19.5, 13.0),# Ribcage
        (0.0, -2.4, 134.0, 23.5, 15.0),# Pectorals / Broadest chest
        (0.0, -1.5, 144.0, 24.5, 14.2),# Clavicle & Trapezius shoulder span
        (0.0, 0.0, 150.0, 10.5, 8.5),  # Neck base
    ]
    create_lofted_mesh("Goku_Torso", torso_rings, mat_gi_orange)

    # 3. NAVY UNDERSHIRT (Visible in V-neck opening)
    undershirt_rings = [
        (0.0, -1.5, 124.0, 9.5, 7.5),
        (0.0, -2.2, 135.0, 11.8, 9.0),
        (0.0, -1.2, 148.0, 10.5, 8.2),
    ]
    create_lofted_mesh("Goku_Undershirt", undershirt_rings, mat_navy)

    # 4. GI LAPELS (Overlapping fabric folds around V-neck)
    for side in (-1, 1):
        sw = side
        sfx = "L" if side < 0 else "R"
        lapel_rings = [
            (sw * 3.2, -11.5, 122.0, 3.2, 1.6),
            (sw * 6.8, -13.8, 133.0, 4.2, 2.0),
            (sw * 13.0, -12.0, 143.0, 5.0, 2.4),
            (sw * 18.0, -7.0, 148.0, 5.2, 2.6),
        ]
        create_lofted_mesh(f"Goku_Lapel_{sfx}", lapel_rings, mat_gi_orange)

    # 5. SASH BELT (Volumetric 3D band wrapping the waist with knot and tails)
    belt_rings = [
        (0.0, 0.2, 96.0, 17.0, 12.5),
        (0.0, 0.0, 102.0, 17.5, 12.8),
        (0.0, -0.2, 107.0, 16.5, 12.0),
    ]
    create_lofted_mesh("Goku_Sash_Band", belt_rings, mat_navy)

    # Belt knot on left hip
    knot_rings = [
        (-14.0, -8.0, 100.0, 3.0, 3.0),
        (-15.0, -8.8, 102.5, 3.8, 3.5),
        (-14.2, -8.2, 105.0, 2.8, 2.8),
    ]
    create_lofted_mesh("Goku_Sash_Knot", knot_rings, mat_navy)

    # Flowing sash tails down left thigh
    create_curved_hair_spike("Goku_Sash_Tail1", (-14.5, -8.5, 101.0), (-16.5, -7.5, 78.0), 2.8, (-2.5, 0.5, -11.0), mat_navy, sides=6)
    create_curved_hair_spike("Goku_Sash_Tail2", (-13.5, -8.0, 100.0), (-14.5, -7.0, 75.0), 2.2, (-1.2, 0.5, -12.0), mat_navy, sides=6)

    # 6. NECK & HEAD (Powerful, proportional neck sitting in trapezius)
    neck_rings = [
        (0.0, 0.0, 147.0, 6.8, 6.2),
        (0.0, -0.2, 153.0, 6.2, 5.8),
        (0.0, -0.4, 158.0, 5.8, 5.4),
    ]
    create_lofted_mesh("Goku_Neck", neck_rings, mat_skin)

    # Continuous sculpted head & cranium
    head_rings = [
        (0.0, -2.8, 156.0, 3.2, 2.8),  # Chin
        (0.0, -2.2, 160.0, 6.5, 5.5),  # Jawline
        (0.0, -1.0, 165.0, 8.8, 8.0),  # Mouth & cheeks
        (0.0, 0.2, 171.0, 9.2, 8.8),   # Eye & brow level
        (0.0, 1.2, 177.0, 8.8, 8.8),   # Temple & forehead
        (0.0, 1.8, 182.0, 7.8, 8.0),   # Cranium / crown
    ]
    create_lofted_mesh("Goku_Cranium", head_rings, mat_skin)

    # 3D Anime Nose
    nose_rings = [
        (0.0, -9.2, 166.0, 0.3, 0.4),  # Sharp tip
        (0.0, -8.2, 166.8, 0.9, 0.8),
        (0.0, -6.8, 168.0, 1.4, 1.2),  # Bridge
    ]
    create_lofted_mesh("Goku_Nose_3D", nose_rings, mat_skin)

    # 3D Ears (Left & Right)
    for side in (-1, 1):
        sw = side
        sfx = "L" if side < 0 else "R"
        ear_rings = [
            (sw * 8.6, 0.2, 163.0, 1.2, 1.0),
            (sw * 10.2, 0.8, 166.5, 1.6, 2.4),
            (sw * 8.8, 1.0, 170.0, 1.2, 1.2),
        ]
        create_lofted_mesh(f"Goku_Ear_{sfx}", ear_rings, mat_skin)

    # Authentic Toriyama Face Plate (Eyes, Brows, Smirk, Cheek lines)
    create_face_plate_mesh("Goku_FacePlate", (0.0, -2.5, 165.5), (8.5, 5.5, 9.5), "face_goku.png")

    # 7. VOLUMETRIC 3D GOKU SPIKED HAIR (Iconic asymmetrical silhouette, thick roots)
    # A) Forehead Bangs framing face
    create_curved_hair_spike("Goku_Bang_Center", (0.0, -3.5, 177.0), (-0.5, -9.5, 172.5), 2.8, (0.0, -4.0, 0.5), mat_hair)
    create_curved_hair_spike("Goku_Bang_L", (-4.0, -3.0, 176.0), (-7.5, -8.8, 171.5), 2.5, (-2.0, -3.5, 0.5), mat_hair)
    create_curved_hair_spike("Goku_Bang_R", (4.0, -3.0, 176.0), (7.0, -8.5, 172.0), 2.5, (2.0, -3.5, 0.5), mat_hair)

    # B) 4 Massive Swept Left Spikes (Goku signature silhouette)
    create_curved_hair_spike("Goku_Spike_L_Top", (-6.0, 0.5, 179.0), (-24.0, 1.5, 195.0), 4.8, (-10.0, 0.5, 9.0), mat_hair)
    create_curved_hair_spike("Goku_Spike_L_MidHigh", (-7.5, 1.5, 174.0), (-28.0, 2.5, 183.0), 4.5, (-12.0, 1.0, 4.0), mat_hair)
    create_curved_hair_spike("Goku_Spike_L_MidLow", (-8.0, 2.5, 168.0), (-25.0, 3.5, 171.0), 4.2, (-10.0, 1.5, -1.0), mat_hair)
    create_curved_hair_spike("Goku_Spike_L_Bottom", (-7.0, 3.5, 162.0), (-19.0, 4.5, 160.0), 3.6, (-7.0, 1.5, -4.0), mat_hair)

    # C) 3 Right Swept Spikes
    create_curved_hair_spike("Goku_Spike_R_Top", (6.0, 0.5, 179.0), (22.0, 1.5, 193.0), 4.5, (9.0, 0.5, 8.0), mat_hair)
    create_curved_hair_spike("Goku_Spike_R_Mid", (7.5, 2.0, 173.0), (26.0, 2.5, 179.0), 4.4, (11.0, 1.0, 2.0), mat_hair)
    create_curved_hair_spike("Goku_Spike_R_Bottom", (7.0, 3.0, 165.0), (18.0, 3.5, 166.0), 3.8, (7.0, 1.0, -2.0), mat_hair)

    # D) Crown Spikes (Top Volume)
    create_curved_hair_spike("Goku_Crown_Main", (0.0, 2.0, 181.0), (0.0, 2.0, 206.0), 5.2, (0.0, 1.0, 14.0), mat_hair)
    create_curved_hair_spike("Goku_Crown_L", (-3.8, 2.0, 180.0), (-10.0, 2.5, 201.0), 4.6, (-4.0, 1.0, 11.0), mat_hair)
    create_curved_hair_spike("Goku_Crown_R", (3.8, 2.0, 180.0), (9.5, 2.5, 200.0), 4.6, (4.0, 1.0, 11.0), mat_hair)

    # 8. ARMS (Seamlessly connected: Shoulder Cuff -> Bicep -> Elbow -> Forearm -> Wristband -> Hand)
    for side in (-1, 1):
        sw = side
        sfx = "L" if side < 0 else "R"

        # Orange Sleeveless Gi Shoulder Cuff (Overhanging the deltoid)
        cuff_rings = [
            (sw * 16.0, -1.0, 146.0, 6.0, 6.5),
            (sw * 21.0, -0.5, 142.0, 7.2, 7.0),
            (sw * 25.0, 0.0, 136.0, 6.5, 6.2),
        ]
        create_lofted_mesh(f"Goku_ShoulderCuff_{sfx}", cuff_rings, mat_gi_orange)

        # Muscular Arm (Bicep -> Elbow -> Forearm -> Wrist, seamless socket)
        arm_rings = [
            (sw * 19.0, -0.2, 142.0, 5.8, 5.5), # Deep inside shoulder socket
            (sw * 25.0, 0.0, 135.0, 5.6, 5.2),  # Upper bicep
            (sw * 32.0, 0.2, 126.0, 5.5, 5.0),  # Bicep peak
            (sw * 38.0, 0.0, 118.0, 4.6, 4.2),  # Elbow joint
            (sw * 45.0, -0.2, 110.0, 4.8, 4.4), # Forearm muscle belly
            (sw * 51.0, 0.0, 104.0, 4.0, 3.8),  # Wrist
        ]
        create_lofted_mesh(f"Goku_Arm_{sfx}", arm_rings, mat_skin)

        # Navy Blue Wristband (Chunky fabric wrapping wrist)
        wrist_rings = [
            (sw * 47.0, 0.0, 107.0, 4.8, 4.6),
            (sw * 52.0, 0.0, 103.0, 4.6, 4.4),
        ]
        create_lofted_mesh(f"Goku_Wristband_{sfx}", wrist_rings, mat_navy)

        # Anime Martial Arts Fist / Hand (Connected to wristband)
        hand_rings = [
            (sw * 53.0, 0.0, 102.0, 3.6, 3.4),
            (sw * 58.0, -0.4, 97.0, 4.4, 2.8), # Knuckles
            (sw * 61.0, -0.6, 93.0, 3.5, 2.0), # Folded fingers
        ]
        create_lofted_mesh(f"Goku_Hand_{sfx}", hand_rings, mat_skin)

    # 9. LEGS (Socketed directly into pelvis, baggy pants with realistic gathering)
    for side in (-1, 1):
        sw = side
        sfx = "L" if side < 0 else "R"
        lx = sw * 9.5

        # Baggy Orange Pants (Volumetric fabric with knee gathering & ankle tuck)
        pants_rings = [
            (lx, 0.4, 88.0, 9.8, 9.5),   # Deep socketed inside pelvis
            (lx, 0.0, 78.0, 11.2, 10.8), # Upper thigh fabric fullness
            (lx, -0.4, 66.0, 10.6, 10.2),# Mid thigh
            (lx, -0.8, 52.0, 9.0, 8.6),  # Knee fold / gathering
            (lx, -0.3, 38.0, 10.0, 9.5), # Calf volume
            (lx, 0.0, 26.0, 8.6, 8.2),   # Lower leg puff
            (lx, 0.0, 20.0, 7.0, 6.6),   # Ankle tuck into boot cuff
        ]
        create_lofted_mesh(f"Goku_Pants_{sfx}", pants_rings, mat_gi_orange)

        # Martial Arts Boots (Navy blue shaft with folded cuff, red lace & sole)
        boot_shaft_rings = [
            (lx, 0.0, 22.0, 7.2, 7.0),  # Top folded boot cuff
            (lx, 0.0, 14.0, 6.2, 5.8),  # Boot ankle
            (lx, -1.8, 7.0, 5.8, 6.5),  # Instep
        ]
        create_lofted_mesh(f"Goku_BootShaft_{sfx}", boot_shaft_rings, mat_navy)

        # Foot
        foot_rings = [
            (lx, -2.5, 7.0, 5.4, 6.2),
            (lx, -7.5, 3.5, 5.2, 9.0),  # Foot arch
            (lx, -12.5, 2.0, 4.6, 6.5), # Toe cap
        ]
        create_lofted_mesh(f"Goku_BootFoot_{sfx}", foot_rings, mat_navy)

        # Red Boot Lacing
        lace_rings = [
            (lx, -7.2, 19.0, 0.9, 0.7),
            (lx, -8.0, 12.0, 1.0, 0.8),
            (lx, -9.5, 5.5, 0.9, 0.7),
        ]
        create_lofted_mesh(f"Goku_BootLace_{sfx}", lace_rings, mat_boot_lace)

        # Dark Boot Sole
        sole_rings = [
            (lx, -7.0, 1.5, 5.6, 9.6),
            (lx, -7.0, -0.2, 5.8, 10.0),
        ]
        create_lofted_mesh(f"Goku_BootSole_{sfx}", sole_rings, mat_boot_sole)

    # 10. STUDIO LIGHTING (Bright, crisp, balanced for silhouette & form evaluation)
    bpy.ops.object.light_add(type="AREA", location=(-60, -140, 160))
    l_key = bpy.context.object; l_key.name = "Key_Light"
    l_key.data.energy = 22000; l_key.data.size = 90
    l_key.data.color = (1.0, 0.98, 0.95)
    l_key.rotation_euler = (math.radians(52), 0, math.radians(-22))

    bpy.ops.object.light_add(type="AREA", location=(80, -110, 140))
    l_fill = bpy.context.object; l_fill.name = "Fill_Light"
    l_fill.data.energy = 10000; l_fill.data.size = 120
    l_fill.data.color = (0.90, 0.95, 1.0)
    l_fill.rotation_euler = (math.radians(45), 0, math.radians(35))

    bpy.ops.object.light_add(type="AREA", location=(0, 110, 185))
    l_rim = bpy.context.object; l_rim.name = "Rim_Light"
    l_rim.data.energy = 16000; l_rim.data.size = 110
    l_rim.data.color = (1.0, 0.95, 0.88)
    l_rim.rotation_euler = (math.radians(-42), 0, math.radians(180))

    # Save to main blend file
    bpy.ops.wm.save_as_mainfile(filepath=str(BLEND_OUT))
    print(f"PFU_GOKU_V2_SAVED: {BLEND_OUT}")

    # Render 3 true inspection views
    bpy.ops.object.camera_add(location=(0, -250, 112))
    cam = bpy.context.object; cam.name = "Inspect_Camera"
    cam.rotation_euler = (math.radians(90), 0, 0)
    cam.data.lens = 52
    bpy.context.scene.camera = cam

    # 1) FRONT VIEW
    bpy.context.scene.render.filepath = str(PREVIEW_DIR / "goku_v2_front.png")
    bpy.ops.render.render(write_still=True)
    print("RENDER_FRONT_OK")

    # 2) SIDE VIEW
    cam.location = (250, 0, 112)
    cam.rotation_euler = (math.radians(90), 0, math.radians(90))
    bpy.context.scene.render.filepath = str(PREVIEW_DIR / "goku_v2_side.png")
    bpy.ops.render.render(write_still=True)
    print("RENDER_SIDE_OK")

    # 3) DREIVIERTELANSICHT (3/4 Perspective)
    cam.location = (-150, -200, 130)
    target = Vector((0.0, 0.0, 110.0))
    direction = target - cam.location
    cam.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()
    cam.data.lens = 55
    bpy.context.scene.render.filepath = str(PREVIEW_DIR / "goku_v2_perspective.png")
    bpy.ops.render.render(write_still=True)
    print("RENDER_PERSPECTIVE_OK")

    # Main preview
    bpy.context.scene.render.filepath = str(PREVIEW_DIR / "goku_model_preview.png")
    bpy.ops.render.render(write_still=True)
    print("ALL_V2_INSPECTION_RENDERS_DONE")


if __name__ == "__main__":
    build_goku_v2()
