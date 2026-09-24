"""High-fidelity, next-gen articulated Ninja and Golem generators matching reference concept art."""

from __future__ import annotations

import math
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
if str(SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPT_DIR))

import bpy
from mathutils import Vector

from blender_common import (
    BLEND_ROOT,
    EXPORT_ROOT,
    PREVIEW_ROOT,
    add_action,
    add_preview_lights,
    assign_material,
    cylinder_between,
    create_armature,
    ensure_output_dirs,
    ico_part,
    material,
    render_preview,
    reset_scene,
    save_and_export,
    skin_rigid,
    smooth,
    uv_part,
)


def smart_uv(obj):
    """Unwrap mesh using smart projection for clean texture mapping."""
    try:
        bpy.context.view_layer.objects.active = obj
        obj.select_set(True)
        bpy.ops.object.mode_set(mode="EDIT")
        bpy.ops.mesh.select_all(action="SELECT")
        bpy.ops.uv.smart_project(angle_limit=math.radians(66.0), island_margin=0.02)
        bpy.ops.object.mode_set(mode="OBJECT")
        obj.select_set(False)
    except Exception:
        pass


def beveled_part(name, location, scale, mat, bevel=1.5, segments=3, subsurf=False, rotation=(0.0, 0.0, 0.0)):
    """Create a beveled box with high-quality subdivision for smooth organic-mechanical forms."""
    bpy.ops.mesh.primitive_cube_add(size=2.0, location=location, rotation=rotation)
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    
    if bevel > 0.0:
        mod = obj.modifiers.new("Bevel", "BEVEL")
        mod.width = bevel
        mod.segments = max(segments, 3)  # Minimum 3 segments for smooth edges
        mod.profile = 0.7  # Slightly rounded profile
        bpy.ops.object.modifier_apply(modifier="Bevel")

    # Always add SubSurf for smooth geometry (level 2 for quality)
    sub = obj.modifiers.new("Subsurf", "SUBSURF")
    sub.levels = 2 if subsurf else 1
    sub.render_levels = 2 if subsurf else 1
    bpy.ops.object.modifier_apply(modifier="Subsurf")

    smooth(obj)
    smart_uv(obj)
    assign_material(obj, mat)
    obj.select_set(False)
    return obj


def faceted_rock(name, location, scale, mat, bevel=2.0, rotation=(0.0, 0.0, 0.0)):
    """Create an angular, faceted basalt rock plate for monolithic golem armor."""
    bpy.ops.mesh.primitive_cube_add(size=2.0, location=location, rotation=rotation)
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)

    if bevel > 0.0:
        mod = obj.modifiers.new("Bevel", "BEVEL")
        mod.width = bevel
        mod.segments = 1  # 1 segment produces sharp faceted rock bevels!
        bpy.ops.object.modifier_apply(modifier="Bevel")

    smooth(obj)
    smart_uv(obj)
    assign_material(obj, mat)
    obj.select_set(False)
    return obj


def create_face_plate(name, center, size, texture_name):
    """
    Creates a curved 3D face plate mesh with chin taper and nose curve,
    with exact UV mapping for the authentic face texture.
    """
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
                nose_bump = 1.8 * (1.0 - abs(c - 4)) * (1.0 - abs(v - 0.38) / 0.12)

            y = cy - depth_curve - nose_bump
            verts.append((x, y, z))
            tex_u = 0.15 + u * 0.70
            tex_v = 0.12 + v * 0.76
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
    smooth(obj)

    tex_path = SCRIPT_DIR.parent / "godot" / "assets" / "textures" / "characters" / texture_name
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

    bsdf.inputs["Roughness"].default_value = 0.45
    bsdf.inputs["Metallic"].default_value = 0.0
    for sskey in ("Subsurface Weight", "Subsurface"):
        if sskey in bsdf.inputs:
            bsdf.inputs[sskey].default_value = 0.25
            break

    assign_material(obj, mat)
    return obj


def fighter_bones(scale=1.0, wide=1.0):
    s = scale
    shoulder = 44 * wide * s
    hip = 20 * wide * s
    return {
        "root": ((0, 0, 0), (0, 0, 10 * s), None),
        "pelvis": ((0, 0, 86 * s), (0, 0, 104 * s), "root"),
        "spine_01": ((0, 0, 104 * s), (0, 0, 130 * s), "pelvis"),
        "spine_02": ((0, 0, 130 * s), (0, 0, 153 * s), "spine_01"),
        "neck": ((0, 0, 153 * s), (0, 0, 165 * s), "spine_02"),
        "head": ((0, 0, 165 * s), (0, 0, 184 * s), "neck"),
        "upperarm_l": ((8 * s, 0, 148 * s), (shoulder, 0, 132 * s), "spine_02"),
        "lowerarm_l": ((shoulder, 0, 132 * s), ((shoulder + 30 * s), 0, 108 * s), "upperarm_l"),
        "hand_l": (((shoulder + 30 * s), 0, 108 * s), ((shoulder + 38 * s), 0, 96 * s), "lowerarm_l"),
        "upperarm_r": ((-8 * s, 0, 148 * s), (-shoulder, 0, 132 * s), "spine_02"),
        "lowerarm_r": ((-shoulder, 0, 132 * s), (-(shoulder + 30 * s), 0, 108 * s), "upperarm_r"),
        "hand_r": ((-(shoulder + 30 * s), 0, 108 * s), (-(shoulder + 38 * s), 0, 96 * s), "lowerarm_r"),
        "thigh_l": ((hip, 0, 90 * s), (hip * 1.08, 0, 52 * s), "pelvis"),
        "calf_l": ((hip * 1.08, 0, 52 * s), (hip, 0, 15 * s), "thigh_l"),
        "foot_l": ((hip, 0, 15 * s), (hip, -17 * s, 6 * s), "calf_l"),
        "thigh_r": ((-hip, 0, 90 * s), (-hip * 1.08, 0, 52 * s), "pelvis"),
        "calf_r": ((-hip * 1.08, 0, 52 * s), (-hip, 0, 15 * s), "thigh_r"),
        "foot_r": ((-hip, 0, 15 * s), (-hip, -17 * s, 6 * s), "calf_r"),
    }


def add_combat_actions(armature, prefix, heavy=False):
    speed = 1.3 if heavy else 1.0
    if not heavy: # Ninja hero stance: wide agile martial stance, dual katanas ready
        add_action(armature, f"{prefix}_Idle", 48, [
            (1, {
                "spine_01": {"rot": (3, 0, 6)},
                "spine_02": {"rot": (4, 0, 5)},
                "head": {"rot": (-2, 0, -10)},
                "upperarm_l": {"rot": (-20, 8, 25)},
                "lowerarm_l": {"rot": (38, -12, 22)},
                "hand_l": {"rot": (8, 0, 10)},
                "upperarm_r": {"rot": (-24, -10, -26)},
                "lowerarm_r": {"rot": (42, 14, -24)},
                "hand_r": {"rot": (8, 0, -10)},
                "thigh_l": {"rot": (-10, 12, 10)},
                "calf_l": {"rot": (18, 0, -6)},
                "thigh_r": {"rot": (12, -12, -10)},
                "calf_r": {"rot": (12, 0, 6)},
            }),
            (24, {
                "spine_01": {"rot": (1, 0, 4), "loc": (0, 0, -1.2)},
                "spine_02": {"rot": (2, 0, 3)},
                "head": {"rot": (-1, 0, -8)},
                "upperarm_l": {"rot": (-17, 6, 22)},
                "lowerarm_l": {"rot": (34, -10, 20)},
                "upperarm_r": {"rot": (-20, -8, -23)},
                "lowerarm_r": {"rot": (38, 12, -21)},
                "thigh_l": {"rot": (-8, 12, 12)},
                "calf_l": {"rot": (20, 0, -6)},
            }),
            (48, {
                "spine_01": {"rot": (3, 0, 6)},
                "spine_02": {"rot": (4, 0, 5)},
                "head": {"rot": (-2, 0, -10)},
                "upperarm_l": {"rot": (-20, 8, 25)},
                "lowerarm_l": {"rot": (38, -12, 22)},
                "hand_l": {"rot": (8, 0, 10)},
                "upperarm_r": {"rot": (-24, -10, -26)},
                "lowerarm_r": {"rot": (42, 14, -24)},
                "hand_r": {"rot": (8, 0, -10)},
                "thigh_l": {"rot": (-10, 12, 10)},
                "calf_l": {"rot": (18, 0, -6)},
                "thigh_r": {"rot": (12, -12, -10)},
                "calf_r": {"rot": (12, 0, 6)},
            }),
        ])
    else: # Golem colossus stance: wide powerful ground stance, giant stone fists forward
        add_action(armature, f"{prefix}_Idle", 48, [
            (1, {
                "root": {"loc": (0, 0, -4)},
                "spine_01": {"rot": (6, 0, 0)},
                "spine_02": {"rot": (8, 0, 0)},
                "head": {"rot": (-10, 0, 0)},
                "upperarm_l": {"rot": (-22, 6, 18)},
                "lowerarm_l": {"rot": (32, -10, 15)},
                "upperarm_r": {"rot": (-22, -6, -18)},
                "lowerarm_r": {"rot": (32, 10, -15)},
                "thigh_l": {"rot": (-8, 14, -12)},
                "calf_l": {"rot": (26, 0, 6)},
                "thigh_r": {"rot": (-8, -14, 12)},
                "calf_r": {"rot": (26, 0, -6)},
            }),
            (24, {
                "root": {"loc": (0, 0, -2)},
                "spine_01": {"rot": (4, 0, 0)},
                "spine_02": {"rot": (6, 0, 0)},
                "head": {"rot": (-8, 0, 0)},
                "upperarm_l": {"rot": (-19, 5, 16)},
                "lowerarm_l": {"rot": (29, -8, 13)},
                "upperarm_r": {"rot": (-19, -5, -16)},
                "lowerarm_r": {"rot": (29, 8, -13)},
                "thigh_l": {"rot": (-7, 14, -12)},
                "calf_l": {"rot": (24, 0, 6)},
                "thigh_r": {"rot": (-7, -14, 12)},
                "calf_r": {"rot": (24, 0, -6)},
            }),
            (48, {
                "root": {"loc": (0, 0, -4)},
                "spine_01": {"rot": (6, 0, 0)},
                "spine_02": {"rot": (8, 0, 0)},
                "head": {"rot": (-10, 0, 0)},
                "upperarm_l": {"rot": (-22, 6, 18)},
                "lowerarm_l": {"rot": (32, -10, 15)},
                "upperarm_r": {"rot": (-22, -6, -18)},
                "lowerarm_r": {"rot": (32, 10, -15)},
                "thigh_l": {"rot": (-8, 14, -12)},
                "calf_l": {"rot": (26, 0, 6)},
                "thigh_r": {"rot": (-8, -14, 12)},
                "calf_r": {"rot": (26, 0, -6)},
            }),
        ])

    add_action(armature, f"{prefix}_Move", 24, [
        (1, {"thigh_l": {"rot": (24 / speed, 0, 0)}, "thigh_r": {"rot": (-24 / speed, 0, 0)}, "upperarm_l": {"rot": (-18, 0, 25)}, "upperarm_r": {"rot": (18, 0, -25)}}),
        (7, {"thigh_l": {"rot": (0, 0, 0)}, "thigh_r": {"rot": (0, 0, 0)}, "root": {"loc": (0, 0, 2)}}),
        (13, {"thigh_l": {"rot": (-24 / speed, 0, 0)}, "thigh_r": {"rot": (24 / speed, 0, 0)}, "upperarm_l": {"rot": (18, 0, 25)}, "upperarm_r": {"rot": (-18, 0, -25)}}),
        (19, {"thigh_l": {"rot": (0, 0, 0)}, "thigh_r": {"rot": (0, 0, 0)}, "root": {"loc": (0, 0, 2)}}),
        (24, {"thigh_l": {"rot": (24 / speed, 0, 0)}, "thigh_r": {"rot": (-24 / speed, 0, 0)}}),
    ])

    add_action(armature, f"{prefix}_LightAttack", 22, [
        (1, {"spine_02": {"rot": (0, 0, 0)}, "upperarm_r": {"rot": (-15, 0, -15)}}),
        (6, {"spine_02": {"rot": (-6, 10, 32 / speed)}, "upperarm_r": {"rot": (-40, 20, -70)}, "lowerarm_r": {"rot": (55, 25, -45)}}),
        (12, {"spine_02": {"rot": (10, -12, -38 / speed)}, "upperarm_r": {"rot": (38, -18, 60)}, "lowerarm_r": {"rot": (18, 0, 12)}}),
        (22, {"spine_02": {"rot": (0, 0, 0)}, "upperarm_r": {"rot": (-15, 0, -15)}}),
    ])

    add_action(armature, f"{prefix}_SpecialAttack", 36, [
        (1, {"root": {"loc": (0, 0, 0)}}),
        (10, {"root": {"loc": (0, 0, -5)}, "spine_02": {"rot": (-18, 0, 0)}, "upperarm_l": {"rot": (-75, 20, 40)}, "lowerarm_l": {"rot": (65, 0, 25)}, "upperarm_r": {"rot": (-75, -20, -40)}, "lowerarm_r": {"rot": (65, 0, -25)}}),
        (18, {"root": {"loc": (0, 0, 8 if not heavy else 3)}, "spine_02": {"rot": (24, 0, 0)}, "upperarm_l": {"rot": (68, -18, -45)}, "lowerarm_l": {"rot": (12, 0, -18)}, "upperarm_r": {"rot": (68, 18, 45)}, "lowerarm_r": {"rot": (12, 0, 18)}}),
        (36, {"root": {"loc": (0, 0, 0)}, "spine_02": {"rot": (0, 0, 0)}}),
    ])

    add_action(armature, f"{prefix}_HitReact", 18, [
        (1, {"spine_01": {"rot": (0, 0, 0)}}),
        (6, {"spine_01": {"rot": (-15 / speed, 0, 15)}, "head": {"rot": (14, 0, -15)}}),
        (18, {"spine_01": {"rot": (0, 0, 0)}, "head": {"rot": (0, 0, 0)}}),
    ])

    add_action(armature, f"{prefix}_Defeat", 50, [
        (1, {"root": {"loc": (0, 0, 0)}, "spine_01": {"rot": (0, 0, 0)}}),
        (24, {"root": {"loc": (0, -12, -22)}, "spine_01": {"rot": (60, 0, 15)}, "thigh_l": {"rot": (-35, 10, 12)}, "thigh_r": {"rot": (-20, -10, -12)}}),
        (50, {"root": {"loc": (0, -28, -48)}, "spine_01": {"rot": (85, 0, 15)}, "upperarm_l": {"rot": (30, 0, 40)}, "upperarm_r": {"rot": (-22, 0, -40)}}),
    ])

    add_action(armature, f"{prefix}_Victory", 54, [
        (1, {"upperarm_l": {"rot": (0, 0, 0)}, "upperarm_r": {"rot": (0, 0, 0)}}),
        (22, {"spine_02": {"rot": (-10, 0, 0)}, "upperarm_l": {"rot": (-105, 15, 25)}, "lowerarm_l": {"rot": (55, 0, 18)}, "upperarm_r": {"rot": (-115, -15, -25)}, "lowerarm_r": {"rot": (65, 0, -18)}}),
        (54, {"spine_02": {"rot": (-6, 0, 0)}, "upperarm_l": {"rot": (-110, 10, 20)}, "upperarm_r": {"rot": (-120, -10, -20)}, "head": {"rot": (-8, 0, 0)}}),
    ])


def build_tech_ninjato(name, location, mirror, armor_mat, cyan_mat, grip_mat, gold_mat):
    """Build high-tech curved shinobi ninjato dagger with glowing edge and circular power port."""
    side = float(mirror)
    mesh = bpy.data.meshes.new(name + "Mesh")
    num_seg = 10
    length = 62.0
    curve_depth = 5.0
    pts = []
    for i in range(num_seg):
        t = i / float(num_seg - 1)
        z = -t * length
        y = math.sin(t * math.pi) * curve_depth
        w = (1.0 - t * 0.28) * 2.6
        pts.append((z, y, w))

    verts = []
    faces = []
    for i, (bz, by, bw) in enumerate(pts):
        v_back = (0, by - bw * 0.45, bz)
        v_left = (side * 0.75, by, bz)
        v_right = (-side * 0.75, by, bz)
        v_edge = (0, by + bw, bz)
        idx = len(verts)
        verts.extend([v_back, v_left, v_right, v_edge])
        if i > 0:
            p = idx - 4
            faces.append((p, p + 1, idx + 1, idx))
            faces.append((p, idx, idx + 2, p + 2))
            faces.append((p + 1, p + 3, idx + 3, idx + 1))
            faces.append((p + 2, idx + 2, idx + 3, p + 3))

    tip_idx = len(verts)
    verts.append((0, pts[-1][1] + 1.2, pts[-1][0] - 5.5))
    last = tip_idx - 4
    faces.append((last, last + 1, tip_idx))
    faces.append((last, tip_idx, last + 2))
    faces.append((last + 1, last + 3, tip_idx))
    faces.append((last + 2, tip_idx, last + 3))

    world_verts = [(vx + location[0], vy + location[1], vz + location[2]) for vx, vy, vz in verts]
    mesh.from_pydata(world_verts, [], faces)
    mesh.update()
    
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    assign_material(obj, armor_mat)
    assign_material(obj, cyan_mat)
    for poly in obj.data.polygons:
        if poly.center.y > location[1]:
            poly.material_index = 1
    smooth(obj)
    smart_uv(obj)

    # Circular glowing cyber-power port at base of blade
    port = beveled_part(f"{name}_PowerPort", (location[0], location[1] - 0.5, location[2] - 3.0), (2.8, 2.8, 1.2), cyan_mat, bevel=0.4)
    port_rim = beveled_part(f"{name}_PortRim", (location[0], location[1] - 0.5, location[2] - 3.0), (3.6, 3.6, 0.8), gold_mat, bevel=0.3)

    tsuba = beveled_part(f"{name}_Tsuba", (location[0], location[1], location[2] + 1.2), (5.5, 7.5, 1.0), gold_mat, bevel=0.3)
    handle = cylinder_between(f"{name}_Handle", (location[0], location[1], location[2] + 2.0), (location[0], location[1], location[2] + 20.0), 2.2, grip_mat, vertices=12)
    smart_uv(handle)
    pommel = beveled_part(f"{name}_Pommel", (location[0], location[1], location[2] + 20.8), (2.6, 3.2, 2.0), gold_mat, bevel=0.4)
    ring = cylinder_between(f"{name}_PommelRing", (location[0], location[1] - 0.5, location[2] + 21.0), (location[0], location[1] - 0.5, location[2] + 26.0), 1.5, gold_mat, vertices=8)
    return obj, [port, port_rim, tsuba, handle, pommel, ring]


def build_holy_rapier(name, location, white_plate, gold, holy_glow, steel):
    """Build an elegant anime holy rapier with golden cup hilt and glowing crystal edge."""
    handle = cylinder_between(f"{name}_Handle", (location[0], location[1], location[2] + 2.0), (location[0], location[1], location[2] + 16.0), 1.6, white_plate, vertices=12)
    smart_uv(handle)
    pommel = beveled_part(f"{name}_Pommel", (location[0], location[1], location[2] + 16.8), (2.4, 2.4, 2.0), gold, bevel=0.4)
    pommel_gem = beveled_part(f"{name}_PommelGem", (location[0], location[1], location[2] + 18.0), (1.2, 1.2, 1.2), holy_glow, bevel=0.2)

    guard = beveled_part(f"{name}_Guard", (location[0], location[1] - 0.5, location[2] + 1.2), (5.5, 5.5, 2.5), gold, bevel=0.6, subsurf=True)
    guard_cross = beveled_part(f"{name}_Crossguard", (location[0], location[1], location[2] + 1.8), (8.5, 2.2, 1.2), gold, bevel=0.3)
    guard_gem = beveled_part(f"{name}_GuardGem", (location[0], location[1] - 2.8, location[2] + 1.2), (1.5, 1.5, 1.5), holy_glow, bevel=0.2)

    length = 68.0
    blade_spine = cylinder_between(f"{name}_Spine", (location[0], location[1], location[2]), (location[0], location[1], location[2] - length), 1.4, steel, vertices=8)
    smart_uv(blade_spine)

    edge_l = cylinder_between(f"{name}_EdgeL", (location[0] + 0.8, location[1], location[2] - 2), (location[0], location[1], location[2] - length), 0.7, holy_glow, vertices=6)
    edge_r = cylinder_between(f"{name}_EdgeR", (location[0] - 0.8, location[1], location[2] - 2), (location[0], location[1], location[2] - length), 0.7, holy_glow, vertices=6)
    tip = beveled_part(f"{name}_Tip", (location[0], location[1], location[2] - length - 2.5), (0.8, 0.8, 3.0), holy_glow, bevel=0.2)

    return blade_spine, [handle, pommel, pommel_gem, guard, guard_cross, guard_gem, edge_l, edge_r, tip]


def build_dragon_greatsword(name, location, titanium_mat, gold_mat, fire_glow, edge_mat):
    """Build a colossal Dragon Slayer greatsword with fuller runes and glowing plasma edge."""
    handle = cylinder_between(f"{name}_Handle", (location[0], location[1], location[2] + 2.0), (location[0], location[1], location[2] + 24.0), 2.2, titanium_mat, vertices=12)
    smart_uv(handle)
    pommel = beveled_part(f"{name}_Pommel", (location[0], location[1], location[2] + 25.2), (3.8, 3.8, 3.0), gold_mat, bevel=0.6)
    pommel_spike = beveled_part(f"{name}_PommelSpike", (location[0], location[1], location[2] + 28.0), (1.5, 1.5, 3.2), fire_glow, bevel=0.3)

    guard = beveled_part(f"{name}_Crossguard", (location[0], location[1], location[2] + 1.0), (14.0, 4.5, 3.2), gold_mat, bevel=0.8, subsurf=True)
    guard_core = beveled_part(f"{name}_GuardCore", (location[0], location[1] - 3.2, location[2] + 1.0), (3.2, 1.8, 3.2), fire_glow, bevel=0.4, rotation=(0, 0, math.radians(45)))

    length = 82.0
    width = 7.5
    blade = beveled_part(f"{name}_BladeMain", (location[0], location[1], location[2] - length * 0.5), (width, 2.2, length * 0.5), titanium_mat, bevel=0.8, subsurf=True)
    smart_uv(blade)

    rune_channel = beveled_part(f"{name}_RuneChannel", (location[0], location[1] - 0.8, location[2] - length * 0.48), (2.2, 1.2, length * 0.42), fire_glow, bevel=0.3)

    edge_l = cylinder_between(f"{name}_EdgeL", (location[0] + width * 0.9, location[1], location[2] - 2), (location[0] + width * 0.9, location[1], location[2] - length), 1.1, edge_mat, vertices=6)
    edge_r = cylinder_between(f"{name}_EdgeR", (location[0] - width * 0.9, location[1], location[2] - 2), (location[0] - width * 0.9, location[1], location[2] - length), 1.1, edge_mat, vertices=6)

    tip = beveled_part(f"{name}_BladeTip", (location[0], location[1], location[2] - length - 4.5), (width * 0.65, 1.8, 5.0), edge_mat, bevel=0.5)

    return blade, [handle, pommel, pommel_spike, guard, guard_core, rune_channel, edge_l, edge_r, tip]


def build_khopesh(name, location, gold_mat, lapis_mat, emerald_glow, plasma_edge, side=1):
    """Build an ornate Egyptian sickle sword (Khopesh) with radiant emerald plasma edge."""
    handle = cylinder_between(f"{name}_Handle", (location[0], location[1], location[2] + 1.0), (location[0], location[1], location[2] + 16.0), 1.9, gold_mat, vertices=12)
    smart_uv(handle)
    pommel = beveled_part(f"{name}_Pommel", (location[0], location[1], location[2] + 17.5), (3.2, 3.2, 2.5), gold_mat, bevel=0.5)
    pommel_gem = beveled_part(f"{name}_PommelGem", (location[0], location[1], location[2] + 19.2), (1.6, 1.6, 1.8), emerald_glow, bevel=0.3, rotation=(0, 0, math.radians(45)))

    guard = beveled_part(f"{name}_Crossguard", (location[0], location[1], location[2] + 0.5), (9.0, 3.8, 2.4), gold_mat, bevel=0.6, subsurf=True)
    guard_gem = beveled_part(f"{name}_GuardGem", (location[0], location[1] - 2.2, location[2] + 0.5), (2.4, 1.4, 2.4), emerald_glow, bevel=0.3, rotation=(0, 0, math.radians(45)))

    base_blade = beveled_part(f"{name}_BladeBase", (location[0], location[1], location[2] - 10.0), (3.8, 1.8, 10.0), lapis_mat, bevel=0.4, subsurf=True)
    smart_uv(base_blade)

    s1 = beveled_part(f"{name}_Sickle1", (location[0] + side * 1.5, location[1] - 6.0, location[2] - 24.0), (3.2, 1.6, 6.0), gold_mat, bevel=0.4, rotation=(math.radians(28), math.radians(side * 8), 0))
    smart_uv(s1)

    s2 = beveled_part(f"{name}_Sickle2", (location[0] + side * 2.8, location[1] - 16.5, location[2] - 29.5), (2.8, 1.4, 7.5), gold_mat, bevel=0.4, rotation=(math.radians(65), math.radians(side * 12), 0))
    smart_uv(s2)

    tip = beveled_part(f"{name}_SickleTip", (location[0] + side * 2.0, location[1] - 25.0, location[2] - 23.5), (2.2, 1.2, 5.0), plasma_edge, bevel=0.3, rotation=(math.radians(110), 0, 0))

    edge_cyl = cylinder_between(f"{name}_PlasmaEdge", (location[0] + side * 3.5, location[1] - 10.0, location[2] - 21.0), (location[0] + side * 2.8, location[1] - 24.0, location[2] - 28.0), 1.0, plasma_edge, vertices=6)

    rune = beveled_part(f"{name}_Rune", (location[0] + side * 1.0, location[1] - 10.0, location[2] - 22.0), (1.4, 0.8, 8.0), emerald_glow, bevel=0.2, rotation=(math.radians(45), 0, 0))

    return base_blade, [handle, pommel, pommel_gem, guard, guard_gem, s1, s2, tip, edge_cyl, rune]


def setup_hero_camera(target_z: float, distance: float, lens=52):
    bpy.ops.object.camera_add(location=(distance * 0.35, -distance * 1.5, target_z + 8))
    camera = bpy.context.object
    camera.name = "PFU_PreviewCamera"
    direction = Vector((0.0, 0.0, target_z)) - camera.location
    camera.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()
    camera.data.lens = lens
    bpy.context.scene.camera = camera
    return camera


# -----------------------------------------------------------------------------
# SHADOW NINJA BUILDER (Faithful to shadow_ninja_turnaround.png)
# -----------------------------------------------------------------------------
def build_ninja():
    reset_scene()
    armor = material("M_NinjaArmor", (0.12, 0.15, 0.20), metallic=0.68, roughness=0.28)
    cloth = material("M_NinjaCloth", (0.05, 0.06, 0.08), metallic=0.0, roughness=0.84)
    skin_mat = material("M_NinjaSkin", (0.72, 0.53, 0.44), metallic=0.0, roughness=0.55)
    hair_mat = material("M_NinjaHair", (0.02, 0.02, 0.03), metallic=0.1, roughness=0.40)
    sash_mat = material("M_NinjaSash", (0.10, 0.14, 0.25), metallic=0.05, roughness=0.75) # Indigo shinobi fabric
    cyan = material("M_NinjaElectric", (0.0, 0.8, 1.0), metallic=0.9, roughness=0.1, emission=(0.0, 0.95, 1.0), emission_strength=10.0)
    gold = material("M_NinjaGold", (0.85, 0.65, 0.20), metallic=0.92, roughness=0.22)
    visor_mat = material("M_NinjaVisor", (0.0, 0.9, 1.0), metallic=0.2, roughness=0.1, emission=(0.0, 1.0, 1.0), emission_strength=14.0)

    armature = create_armature("SK_Ninja", fighter_bones())
    parts = []

    def part(obj, bone):
        skin_rigid(obj, armature, bone)
        parts.append(obj)
        return obj

    # --- AUTHENTIC CYBER-SHINOBI FACE & HOOD ---
    face = create_face_plate("Ninja_FacePlate", (0, -2.5, 171), (8.6, 5.6, 10.2), "face_ninja.png")
    part(face, "head")

    head = uv_part("Ninja_Head", (0, 2.5, 172), (8.8, 8.2, 10.5), cloth)
    part(head, "head")

    cowl_neck = beveled_part("Ninja_CowlNeck", (0, 0.5, 160), (12.0, 11.5, 7.5), cloth, bevel=2.5, subsurf=True)
    part(cowl_neck, "head")

    # Forehead bandana with gold/steel clan plate
    bandana = beveled_part("Ninja_Bandana", (0, -1.2, 176.5), (12.5, 11.5, 2.6), sash_mat, bevel=0.8)
    part(bandana, "head")
    emblem = beveled_part("Ninja_ForeheadPlate", (0, -11.6, 176.8), (5.5, 1.0, 2.2), gold, bevel=0.4)
    part(emblem, "head")

    # Spiky anime hair cap on top of head
    hair_top = beveled_part("Ninja_Hair_Top", (0, 1.0, 180.5), (12.0, 11.5, 5.5), hair_mat, bevel=2.0, subsurf=True)
    part(hair_top, "head")

    # High stylish ponytail tied at crown of head
    ponytail_base = beveled_part("Ninja_Hair_PonyBase", (0, 9.0, 182.0), (3.5, 3.5, 3.5), gold, bevel=0.6)
    part(ponytail_base, "head")
    ponytail_main = beveled_part("Ninja_Hair_Ponytail", (0, 17.0, 186.0), (4.5, 8.5, 12.0), hair_mat, bevel=1.8, subsurf=True, rotation=(math.radians(-35), 0, 0))
    part(ponytail_main, "head")

    # Side bangs framing face
    for side in (-1, 1):
        bang = beveled_part(f"Ninja_Hair_Bang_{side}", (side * 9.5, -8.0, 171.0), (2.2, 3.5, 8.0), hair_mat, bevel=0.8, rotation=(math.radians(15), math.radians(side * 12), math.radians(-side * 8)))
        part(bang, "head")

    # Fluttering headband tails trailing off back
    tail1 = beveled_part("Ninja_Bandana_Tail1", (-3.0, 14, 167), (1.4, 2.0, 8.5), sash_mat, bevel=0.3, rotation=(math.radians(20), math.radians(-10), math.radians(8)))
    part(tail1, "head")
    tail2 = beveled_part("Ninja_Bandana_Tail2", (2.5, 15, 163), (1.3, 1.8, 10.5), sash_mat, bevel=0.3, rotation=(math.radians(25), math.radians(12), math.radians(-8)))
    part(tail2, "head")

    # --- TORSO, CHEST ARMOR & HARNESS ---
    part(uv_part("Ninja_Torso", (0, 0, 134), (21, 13, 23), cloth), "spine_01")
    
    # Layered chevron chest armor plates
    chest_l = beveled_part("Ninja_ChestArmor_L", (8.5, -6.8, 138), (9.0, 3.5, 11), armor, bevel=1.5, subsurf=True, rotation=(0, math.radians(-6), math.radians(10)))
    part(chest_l, "spine_02")
    chest_r = beveled_part("Ninja_ChestArmor_R", (-8.5, -6.8, 138), (9.0, 3.5, 11), armor, bevel=1.5, subsurf=True, rotation=(0, math.radians(6), math.radians(-10)))
    part(chest_r, "spine_02")
    chest_center = beveled_part("Ninja_ChestArmor_Center", (0, -7.5, 142), (4.5, 2.2, 7.5), cyan, bevel=0.6)
    part(chest_center, "spine_02")

    # Tactical harness cross-straps on back
    back_plate = beveled_part("Ninja_BackArmor", (0, 8.2, 138), (13, 3.0, 14), armor, bevel=1.5, subsurf=True)
    part(back_plate, "spine_02")
    back_node = beveled_part("Ninja_BackNode", (0, 10.0, 138), (3.2, 1.2, 3.2), cyan, bevel=0.4, rotation=(0, 0, math.radians(45)))
    part(back_node, "spine_02")

    # --- PELVIS, SASH & RUNNER ---
    part(uv_part("Ninja_Pelvis", (0, 0, 98), (19, 12, 15), cloth), "pelvis")
    sash = beveled_part("Ninja_SashBelt", (0, 0, 104), (21.5, 13.5, 5.5), sash_mat, bevel=1.2, subsurf=True)
    part(sash, "pelvis")
    belt_buckle = beveled_part("Ninja_BeltBuckle", (0, -13.6, 104), (4.0, 1.2, 3.2), gold, bevel=0.4)
    part(belt_buckle, "pelvis")

    # Central hanging sash runner cloth down front (matching turnaround)
    runner = beveled_part("Ninja_SashRunner", (0, -13.0, 84), (6.5, 1.2, 17.0), sash_mat, bevel=0.5, rotation=(math.radians(6), 0, 0))
    part(runner, "pelvis")

    for side in (-1, 1):
        hip_pouch = beveled_part(f"Ninja_Pouch_{side}", (side * 18, -10.5, 103), (3.8, 3.0, 4.5), armor, bevel=0.6)
        part(hip_pouch, "pelvis")

    # --- LIMBS, GAUNTLETS & DUAL TECH-NINJATO ---
    for side, suffix in ((1, "L"), (-1, "R")):
        upper_bone = "upperarm_l" if side > 0 else "upperarm_r"
        lower_bone = "lowerarm_l" if side > 0 else "lowerarm_r"
        hand_bone = "hand_l" if side > 0 else "hand_r"
        thigh_bone = "thigh_l" if side > 0 else "thigh_r"
        calf_bone = "calf_l" if side > 0 else "calf_r"
        foot_bone = "foot_l" if side > 0 else "foot_r"

        # 3 Tiered segmented shoulder pauldrons with glowing energy slits
        for p_idx, (p_off_x, p_off_z, p_sz) in enumerate([(22, 149, (12, 14, 5.5)), (30, 144, (10, 12, 4.8)), (37, 139, (8.5, 10, 4.2))]):
            pauldron = beveled_part(f"Ninja_ShoulderArmor_{suffix}_{p_idx}", (side * p_off_x, 0, p_off_z), p_sz, armor, bevel=1.2, subsurf=True, rotation=(0, math.radians(side * 10), math.radians(-side * (12 + p_idx * 5))))
            part(pauldron, upper_bone)

        # Muscular bare arm between shoulder sleeve and forearm gauntlet
        arm = cylinder_between(f"Ninja_UpperArm_{suffix}", (side * 13, 0, 147), (side * 44, 0, 132), 6.8, skin_mat)
        smart_uv(arm)
        part(arm, upper_bone)

        # Sleeve rim
        sleeve = beveled_part(f"Ninja_Sleeve_{suffix}", (side * 18, 0, 145), (6.5, 8.5, 4.5), cloth, bevel=0.8)
        part(sleeve, upper_bone)

        # Forearm with cyber-vambrace gauntlet
        forearm = cylinder_between(f"Ninja_Forearm_{suffix}", (side * 44, 0, 132), (side * 73, 0, 108), 6.2, cloth)
        smart_uv(forearm)
        part(forearm, lower_bone)

        bracer = beveled_part(f"Ninja_Bracer_{suffix}", (side * 58, -0.5, 120), (8.0, 7.0, 13), armor, bevel=1.5, subsurf=True, rotation=(0, 0, math.radians(-side * 36)))
        part(bracer, lower_bone)
        conduit = beveled_part(f"Ninja_Conduit_{suffix}", (side * 58, -4.6, 120), (2.6, 0.8, 11), cyan, bevel=0.3, rotation=(0, 0, math.radians(-side * 36)))
        part(conduit, lower_bone)

        hand = beveled_part(f"Ninja_Hand_{suffix}", (side * 77, 0, 103), (5.8, 6.2, 7.0), cloth, bevel=1.2, subsurf=True)
        part(hand, hand_bone)

        # DUAL HIGH-TECH CURVED NINJATO DAGGER WEAPONS
        blade_obj, k_parts = build_tech_ninjato(f"Ninja_Katana_{suffix}", (side * 78, -2, 98), side, armor, cyan, cloth, gold)
        part(blade_obj, hand_bone)
        for kp in k_parts:
            part(kp, hand_bone)

        # Lower body: Hakama pants into armored greaves
        thigh = cylinder_between(f"Ninja_Thigh_{suffix}", (side * 20, 0, 88), (side * 22, 0, 53), 9.8, cloth)
        smart_uv(thigh)
        part(thigh, thigh_bone)

        knee = beveled_part(f"Ninja_KneeGuard_{suffix}", (side * 22, -5.5, 52), (8.0, 5.0, 8.5), armor, bevel=1.5, subsurf=True)
        part(knee, calf_bone)

        shin = cylinder_between(f"Ninja_Shin_{suffix}", (side * 22, 0, 49), (side * 20, 0, 16), 8.2, cloth)
        smart_uv(shin)
        part(shin, calf_bone)

        # Armored shin greaves with glowing cyan accent notches
        greave = beveled_part(f"Ninja_Greave_{suffix}", (side * 21, -4.2, 33), (7.0, 3.5, 17), armor, bevel=1.0, subsurf=True)
        part(greave, calf_bone)
        greave_glow = beveled_part(f"Ninja_GreaveGlow_{suffix}", (side * 21, -6.2, 33), (2.0, 0.8, 10), cyan, bevel=0.2)
        part(greave_glow, calf_bone)

        foot = beveled_part(f"Ninja_Foot_{suffix}", (side * 20, -7, 8), (9.0, 16, 6.0), cloth, bevel=1.5, subsurf=True)
        part(foot, foot_bone)
        sole = beveled_part(f"Ninja_Sole_{suffix}", (side * 20, -7, 2.5), (9.8, 17, 1.8), armor, bevel=0.4)
        part(sole, foot_bone)

    add_combat_actions(armature, "Ninja", heavy=False)
    setup_hero_camera(110, 260, lens=52)
    add_preview_lights(110, energy=4000)
    render_preview("ninja_model_preview.png")
    save_and_export(armature, "PFU_ShadowNinja.blend", "PFU_ShadowNinja.fbx")
    print("NINJA_GEN_OK")


# -----------------------------------------------------------------------------
# LAVA GOLEM BUILDER (Faithful to lava_golem_turnaround.png)
# -----------------------------------------------------------------------------
def build_golem():
    reset_scene()
    rock = material("M_GolemRock", (0.13, 0.09, 0.07), metallic=0.15, roughness=0.82)
    rock_dark = material("M_GolemArmor", (0.08, 0.05, 0.04), metallic=0.25, roughness=0.72)
    lava = material("M_GolemLava", (0.50, 0.08, 0.01), metallic=0.0, roughness=0.2, emission=(1.0, 0.28, 0.02), emission_strength=10.0)
    core_mat = material("M_GolemCore", (0.9, 0.5, 0.1), metallic=0.0, roughness=0.1, emission=(1.0, 0.75, 0.15), emission_strength=14.0)

    armature = create_armature("SK_Golem", fighter_bones(scale=1.28, wide=1.22))
    parts = []

    def part(obj, bone):
        skin_rigid(obj, armature, bone)
        parts.append(obj)
        return obj

    # --- HEAD & 5-SPIKE BURNING CROWN ---
    head = faceted_rock("Golem_Head", (0, -2, 218), (19, 18, 18), rock_dark, bevel=4.5)
    part(head, "head")

    # Angled chiseled brow ridges
    brow_l = faceted_rock("Golem_Brow_L", (6.5, -13, 223), (8.5, 5.0, 4.2), rock_dark, bevel=1.2, rotation=(0, math.radians(-12), math.radians(10)))
    part(brow_l, "head")
    brow_r = faceted_rock("Golem_Brow_R", (-6.5, -13, 223), (8.5, 5.0, 4.2), rock_dark, bevel=1.2, rotation=(0, math.radians(12), math.radians(-10)))
    part(brow_r, "head")

    # Chiseled basalt jaw
    jaw = faceted_rock("Golem_Jaw", (0, -11, 206), (15, 9.0, 7.0), rock, bevel=2.0)
    part(jaw, "head")

    # Deep recessed glowing magma eyes
    for side in (-1, 1):
        eye = beveled_part(f"Golem_Eye_{side}", (side * 6.0, -14.2, 218.0), (3.2, 1.4, 1.8), lava, bevel=0.3, rotation=(0, math.radians(-side * 10), math.radians(side * 8)))
        part(eye, "head")

    # Blazing 5-spike magma flame crown (Iconic from turnaround reference)
    crown_spikes = [
        ("Center", (0, -1, 238), (5.2, 4.5, 14), 0, 0),
        ("L1", (8.0, 0, 236), (4.5, 4.0, 12), -10, 8),
        ("R1", (-8.0, 0, 236), (4.5, 4.0, 12), 10, -8),
        ("L2", (15.5, 2, 232), (4.0, 3.5, 10.5), -18, 15),
        ("R2", (-15.5, 2, 232), (4.0, 3.5, 10.5), 18, -15),
    ]
    for c_name, c_loc, c_scale, c_rot_y, c_rot_z in crown_spikes:
        spike = beveled_part(f"Golem_Crown_{c_name}", c_loc, c_scale, lava, bevel=1.0, subsurf=True, rotation=(math.radians(8), math.radians(c_rot_y), math.radians(c_rot_z)))
        part(spike, "head")

    # --- HULKING CHEST & CENTRAL MOLTEN FISSURE ---
    core = ico_part("Golem_Core", (0, -1, 172), (34, 25, 34), core_mat, subdivisions=2)
    smart_uv(core)
    part(core, "spine_01")

    # 4 Sculpted basalt pectoral & rib slabs framing central fissure
    pec_l = faceted_rock("Golem_Pectoral_L", (17, -13, 181), (18, 10, 18), rock_dark, bevel=3.5, rotation=(math.radians(-6), math.radians(-10), math.radians(6)))
    part(pec_l, "spine_02")
    pec_r = faceted_rock("Golem_Pectoral_R", (-17, -13, 181), (18, 10, 18), rock_dark, bevel=3.5, rotation=(math.radians(-6), math.radians(10), math.radians(-6)))
    part(pec_r, "spine_02")

    # Segmented abdominal stone plates
    for k, (y_off, z_off, sz) in enumerate([(-12, 156, (11, 6, 8)), (-10, 142, (10, 6, 7))]):
        for side in (-1, 1):
            ab = faceted_rock(f"Golem_Ab_{side}_{k}", (side * 9.5, y_off, z_off), sz, rock, bevel=1.8)
            part(ab, "spine_01")

    # Colossal trapezius rock hump & back carapace with spinal magma seam
    traps = faceted_rock("Golem_Trapezius", (0, 15, 195), (42, 22, 22), rock_dark, bevel=5.0)
    part(traps, "spine_02")
    carapace_l = faceted_rock("Golem_BackCarapace_L", (14, 16, 165), (15, 10, 24), rock, bevel=3.5)
    part(carapace_l, "spine_02")
    carapace_r = faceted_rock("Golem_BackCarapace_R", (-14, 16, 165), (15, 10, 24), rock, bevel=3.5)
    part(carapace_r, "spine_02")
    spine_magma = beveled_part("Golem_SpineMagma", (0, 17, 165), (3.0, 4.0, 25), lava, bevel=0.8)
    part(spine_magma, "spine_02")

    # Pelvis block
    pelvis = faceted_rock("Golem_Pelvis", (0, 0, 122), (32, 24, 16), rock_dark, bevel=4.0)
    part(pelvis, "pelvis")

    for side in (-1, 1):
        hip_plate = faceted_rock(f"Golem_HipPlate_{side}", (side * 34, 0, 122), (10, 20, 14), rock, bevel=2.5)
        part(hip_plate, "pelvis")

    # --- BOULDER SHOULDERS & MOUNTAIN-CRUSHING FISTS ---
    for side, suffix in ((1, "L"), (-1, "R")):
        upper_bone = "upperarm_l" if side > 0 else "upperarm_r"
        lower_bone = "lowerarm_l" if side > 0 else "lowerarm_r"
        hand_bone = "hand_l" if side > 0 else "hand_r"
        thigh_bone = "thigh_l" if side > 0 else "thigh_r"
        calf_bone = "calf_l" if side > 0 else "calf_r"
        foot_bone = "foot_l" if side > 0 else "foot_r"

        sh_main = faceted_rock(f"Golem_ShoulderMain_{suffix}", (side * 50, 0, 192), (28, 30, 25), rock_dark, bevel=5.0)
        part(sh_main, upper_bone)
        sh_spur = faceted_rock(f"Golem_ShoulderSpur_{suffix}", (side * 62, -2, 197), (12, 15, 10), rock, bevel=2.5, rotation=(0, 0, math.radians(-side * 22)))
        part(sh_spur, upper_bone)

        bicep = cylinder_between(f"Golem_Bicep_{suffix}", (side * 48, 0, 182), (side * 74, 0, 156), 18, rock)
        smart_uv(bicep)
        part(bicep, upper_bone)

        elbow_cap = faceted_rock(f"Golem_ElbowCap_{suffix}", (side * 79, 6, 154), (12, 8, 14), rock_dark, bevel=2.0)
        part(elbow_cap, lower_bone)

        forearm = cylinder_between(f"Golem_Forearm_{suffix}", (side * 76, 0, 154), (side * 102, 0, 126), 20, rock_dark)
        smart_uv(forearm)
        part(forearm, lower_bone)

        fissure = beveled_part(f"Golem_ForearmFissure_{suffix}", (side * 90, -6, 138), (6, 3, 16), lava, bevel=0.8, rotation=(0, 0, math.radians(-side * 32)))
        part(fissure, lower_bone)

        # GIANT MOUNTAIN CRUSHING STONE FIST
        fist = faceted_rock(f"Golem_FistBase_{suffix}", (side * 106, -2, 118), (21, 20, 20), rock_dark, bevel=4.5)
        part(fist, hand_bone)

        # 4 distinct heavy stone knuckles with glowing magma joints
        for k in range(4):
            kx = side * (101 + k * 4.2)
            ky = -14.5 + (k % 2) * 1.2
            kz = 125 - k * 4.2
            knuckle = faceted_rock(f"Golem_Knuckle_{suffix}_{k}", (kx, ky, kz), (4.8, 5.5, 5.2), rock, bevel=1.2)
            part(knuckle, hand_bone)
            k_glow = beveled_part(f"Golem_KnuckleGlow_{suffix}_{k}", (kx, ky - 2.8, kz), (2.8, 0.8, 3.2), lava, bevel=0.3)
            part(k_glow, hand_bone)

        thumb = faceted_rock(f"Golem_Thumb_{suffix}", (side * 96, -9, 123), (6.0, 8.5, 5.5), rock, bevel=1.5, rotation=(0, math.radians(-side * 16), math.radians(20)))
        part(thumb, hand_bone)

        # Chiseled faceted basalt rock plates & glowing magma seams on legs
        thigh_core = cylinder_between(f"Golem_ThighCore_{suffix}", (side * 27, 0, 112), (side * 29, 0, 68), 16, rock)
        smart_uv(thigh_core)
        part(thigh_core, thigh_bone)

        thigh_front = faceted_rock(f"Golem_ThighFront_{suffix}", (side * 28, -8.5, 90), (14, 6.0, 18), rock_dark, bevel=2.5)
        part(thigh_front, thigh_bone)

        thigh_side = faceted_rock(f"Golem_ThighSide_{suffix}", (side * 36, 0, 90), (6.5, 14, 18), rock, bevel=2.5)
        part(thigh_side, thigh_bone)

        thigh_fissure = beveled_part(f"Golem_ThighFissure_{suffix}", (side * 33, -6.0, 90), (3.0, 2.0, 16), lava, bevel=0.4)
        part(thigh_fissure, thigh_bone)

        # Chiseled basalt knee cap with glowing magma backing
        knee_glow = beveled_part(f"Golem_KneeGlow_{suffix}", (side * 29, -9.0, 66), (12, 4.0, 12), lava, bevel=0.5)
        part(knee_glow, calf_bone)
        knee_plate = faceted_rock(f"Golem_KneePlate_{suffix}", (side * 29, -12.5, 66), (15, 6.5, 15), rock_dark, bevel=3.0)
        part(knee_plate, calf_bone)

        # Muscular chiseled rock shins
        shin_core = cylinder_between(f"Golem_ShinCore_{suffix}", (side * 29, 0, 64), (side * 27, 0, 22), 17, rock_dark)
        smart_uv(shin_core)
        part(shin_core, calf_bone)

        shin_plate = faceted_rock(f"Golem_ShinPlate_{suffix}", (side * 29, -8.0, 42), (15, 6.5, 18), rock, bevel=2.8)
        part(shin_plate, calf_bone)

        shin_fissure = beveled_part(f"Golem_ShinFissure_{suffix}", (side * 34, -4.0, 42), (3.0, 2.5, 17), lava, bevel=0.5)
        part(shin_fissure, calf_bone)

        # Heavy faceted basalt foot with 3 chiseled rock talon toes
        foot = faceted_rock(f"Golem_Foot_{suffix}", (side * 28, -8, 12), (21, 24, 10), rock_dark, bevel=3.5)
        part(foot, foot_bone)

        for toe_idx in range(3):
            tx = side * (20 + toe_idx * 7.5)
            toe = faceted_rock(f"Golem_Toe_{suffix}_{toe_idx}", (tx, -25, 9), (5.2, 8.5, 6.5), rock, bevel=1.5)
            part(toe, foot_bone)
            toe_glow = beveled_part(f"Golem_ToeGlow_{suffix}_{toe_idx}", (tx, -20, 10), (3.0, 2.0, 4.0), lava, bevel=0.4)
            part(toe_glow, foot_bone)

    add_combat_actions(armature, "Golem", heavy=True)
    setup_hero_camera(135, 350, lens=55)
    add_preview_lights(135, energy=4600)
    render_preview("golem_model_preview.png")
    save_and_export(armature, "PFU_LavaGolem.blend", "PFU_LavaGolem.fbx")
    print("GOLEM_GEN_OK")


# -----------------------------------------------------------------------------
# MOE VALKYRIE BUILDER (Graceful anime paladin with wings and holy rapier)
# -----------------------------------------------------------------------------
def build_valkyrie():
    reset_scene()
    white_plate = material("M_ValkPlate", (0.92, 0.94, 0.98), metallic=0.65, roughness=0.22)
    gold = material("M_ValkGold", (0.95, 0.78, 0.22), metallic=0.92, roughness=0.18)
    skin_mat = material("M_ValkSkin", (0.92, 0.79, 0.73), metallic=0.0, roughness=0.48)
    hair_mat = material("M_ValkHair", (0.96, 0.84, 0.38), metallic=0.12, roughness=0.28)
    cloth_blue = material("M_ValkCloth", (0.10, 0.16, 0.35), metallic=0.05, roughness=0.72)
    glow_wings = material("M_ValkWings", (0.80, 0.92, 1.0), metallic=0.1, roughness=0.1, emission=(0.50, 0.85, 1.0), emission_strength=12.0)
    holy_glow = material("M_ValkHoly", (1.0, 0.88, 0.40), metallic=0.75, roughness=0.1, emission=(1.0, 0.82, 0.32), emission_strength=10.0)
    steel = material("M_ValkSteel", (0.80, 0.82, 0.88), metallic=0.92, roughness=0.15)
    eye_mat = material("M_ValkEye", (0.15, 0.55, 0.95), metallic=0.1, roughness=0.1, emission=(0.2, 0.6, 1.0), emission_strength=6.0)

    armature = create_armature("SK_Valkyrie", fighter_bones(scale=0.96, wide=0.88))
    parts = []

    def part(obj, bone):
        skin_rigid(obj, armature, bone)
        parts.append(obj)
        return obj

    # --- AUTHENTIC ANIME FACE, HEAD & TWIN-TAILS ---
    face = create_face_plate("Valkyrie_FacePlate", (0, -2.5, 168), (8.2, 5.5, 9.8), "face_valkyrie.png")
    part(face, "head")

    head = uv_part("Valkyrie_Head", (0, 2.5, 169), (8.6, 8.0, 10.0), skin_mat)
    part(head, "head")

    # Neck & Gorget
    neck = cylinder_between("Valkyrie_Neck", (0, 0, 155), (0, 0, 163), 4.2, skin_mat)
    smart_uv(neck)
    part(neck, "neck")
    gorget = beveled_part("Valkyrie_Gorget", (0, 0, 156), (5.8, 6.2, 2.5), gold, bevel=0.4)
    part(gorget, "neck")

    # Winged Holy Tiara / Circlet
    circlet = beveled_part("Valkyrie_TiaraBand", (0, -0.8, 174.5), (10.2, 10.6, 1.8), gold, bevel=0.3)
    part(circlet, "head")
    tiara_crest = beveled_part("Valkyrie_TiaraCrest", (0, -10.6, 176.0), (2.8, 1.0, 3.8), gold, bevel=0.4)
    part(tiara_crest, "head")
    tiara_gem = beveled_part("Valkyrie_TiaraGem", (0, -11.2, 176.0), (1.5, 0.8, 1.5), holy_glow, bevel=0.2)
    part(tiara_gem, "head")
    for side in (-1, 1):
        tiara_wing = beveled_part(f"Valkyrie_TiaraWing_{side}", (side * 9.8, -5.0, 177.5), (4.5, 1.0, 2.8), gold, bevel=0.3, rotation=(math.radians(15), math.radians(side * 25), math.radians(-side * 20)))
        part(tiara_wing, "head")

    # Anime Hair Cap & Front Bangs
    hair_cap = beveled_part("Valkyrie_HairCap", (0, 1.5, 172.5), (10.5, 11.2, 8.5), hair_mat, bevel=1.8, subsurf=True)
    part(hair_cap, "head")
    bang_center = beveled_part("Valkyrie_HairBangCenter", (0, -9.6, 174.2), (3.6, 1.5, 4.2), hair_mat, bevel=0.4, rotation=(math.radians(12), 0, 0))
    part(bang_center, "head")
    for side in (-1, 1):
        bang_side = beveled_part(f"Valkyrie_HairBang_{side}", (side * 5.2, -9.0, 173.0), (2.8, 1.4, 5.5), hair_mat, bevel=0.4, rotation=(math.radians(10), math.radians(side * 15), math.radians(-side * 10)))
        part(bang_side, "head")
        lock = beveled_part(f"Valkyrie_HairLock_{side}", (side * 8.5, -6.5, 164.0), (1.8, 2.2, 9.5), hair_mat, bevel=0.5, rotation=(math.radians(8), math.radians(side * 8), math.radians(-side * 5)))
        part(lock, "head")

    # Iconic Anime Twin-Tails
    for side, suffix in ((1, "L"), (-1, "R")):
        ribbon = beveled_part(f"Valkyrie_HairRibbon_{suffix}", (side * 9.5, 6.5, 174.0), (3.0, 3.0, 2.2), gold, bevel=0.4)
        part(ribbon, "head")
        ribbon_bow = beveled_part(f"Valkyrie_HairBow_{suffix}", (side * 11.5, 7.5, 174.0), (3.5, 1.2, 2.8), cloth_blue, bevel=0.3, rotation=(0, math.radians(side * 25), 0))
        part(ribbon_bow, "head")

        tail_top = beveled_part(f"Valkyrie_TwinTailTop_{suffix}", (side * 13.5, 9.5, 167.0), (3.2, 4.5, 8.5), hair_mat, bevel=1.2, subsurf=True, rotation=(math.radians(-15), math.radians(side * 20), math.radians(-side * 18)))
        part(tail_top, "head")
        tail_mid = beveled_part(f"Valkyrie_TwinTailMid_{suffix}", (side * 16.5, 12.0, 151.0), (2.8, 4.0, 11.0), hair_mat, bevel=1.0, subsurf=True, rotation=(math.radians(-25), math.radians(side * 14), math.radians(-side * 12)))
        part(tail_mid, "head")
        tail_tip = beveled_part(f"Valkyrie_TwinTailTip_{suffix}", (side * 18.0, 14.5, 134.0), (2.0, 3.2, 9.5), hair_mat, bevel=0.8, subsurf=True, rotation=(math.radians(-32), math.radians(side * 8), math.radians(-side * 8)))
        part(tail_tip, "head")

    # --- TORSO: CORSET, PALADIN CUIRASS & ETHEREAL WINGS ---
    waist = uv_part("Valkyrie_WaistCorset", (0, 0, 122), (13.5, 10.0, 14.0), cloth_blue)
    part(waist, "spine_01")
    corset_ribs = beveled_part("Valkyrie_CorsetBoning", (0, -8.6, 122), (9.0, 2.2, 10.0), gold, bevel=0.4)
    part(corset_ribs, "spine_01")

    cuirass = beveled_part("Valkyrie_Breastplate", (0, -2.0, 136), (15.5, 10.5, 12.5), white_plate, bevel=1.8, subsurf=True)
    part(cuirass, "spine_02")
    cuirass_trim = beveled_part("Valkyrie_BreastplateTrim", (0, -7.5, 138), (12.0, 3.0, 8.5), gold, bevel=0.6)
    part(cuirass_trim, "spine_02")
    heart_gem = beveled_part("Valkyrie_HeartGem", (0, -9.2, 137), (3.2, 1.5, 3.2), holy_glow, bevel=0.4, rotation=(0, 0, math.radians(45)))
    part(heart_gem, "spine_02")

    back_armor = beveled_part("Valkyrie_BackArmor", (0, 7.5, 136), (13.0, 3.5, 12.0), white_plate, bevel=1.5, subsurf=True)
    part(back_armor, "spine_02")
    wing_mount = beveled_part("Valkyrie_WingMount", (0, 9.5, 140), (7.0, 2.8, 5.0), gold, bevel=0.4)
    part(wing_mount, "spine_02")

    # RADIANT ETHEREAL LIGHT WINGS
    for side, suffix in ((1, "L"), (-1, "R")):
        wing_arch = beveled_part(f"Valkyrie_WingArch_{suffix}", (side * 18.0, 15.0, 152.0), (3.2, 2.2, 14.0), gold, bevel=0.5, rotation=(math.radians(20), math.radians(side * 35), math.radians(-side * 28)))
        part(wing_arch, "spine_02")

        for f_idx, (f_x, f_z, f_len, f_ang) in enumerate([
            (26.0, 168.0, 18.0, 42.0),
            (32.0, 158.0, 22.0, 32.0),
            (35.0, 146.0, 20.0, 18.0),
            (32.0, 134.0, 15.0, 5.0),
        ]):
            feather = beveled_part(f"Valkyrie_WingFeather_{suffix}_{f_idx}", (side * f_x, 16.5, f_z), (2.2, 0.8, f_len), glow_wings, bevel=0.4, rotation=(math.radians(15), math.radians(side * f_ang), math.radians(-side * (f_ang * 0.7))))
            part(feather, "spine_02")

    # --- PELVIS & BATTLE SKIRT / TASSETS ---
    part(uv_part("Valkyrie_Pelvis", (0, 0, 95), (15.5, 11.0, 11.0), cloth_blue), "pelvis")
    skirt_belt = beveled_part("Valkyrie_SkirtBelt", (0, 0, 101), (17.0, 12.0, 3.8), gold, bevel=0.5)
    part(skirt_belt, "pelvis")
    belt_gem = beveled_part("Valkyrie_BeltGem", (0, -11.5, 101), (2.5, 1.2, 2.5), holy_glow, bevel=0.3, rotation=(0, 0, math.radians(45)))
    part(belt_gem, "pelvis")

    tabard = beveled_part("Valkyrie_Tabard", (0, -11.0, 84), (5.5, 1.0, 14.0), cloth_blue, bevel=0.4, rotation=(math.radians(4), 0, 0))
    part(tabard, "pelvis")
    tabard_trim = beveled_part("Valkyrie_TabardTrim", (0, -11.5, 78), (4.5, 0.8, 2.2), gold, bevel=0.3)
    part(tabard_trim, "pelvis")

    for side in (-1, 1):
        tasset = beveled_part(f"Valkyrie_Tasset_{side}", (side * 15.5, 0, 88), (2.8, 9.5, 10.5), white_plate, bevel=1.0, subsurf=True, rotation=(0, 0, math.radians(-side * 14)))
        part(tasset, "pelvis")
        tasset_gold = beveled_part(f"Valkyrie_TassetGold_{side}", (side * 16.5, 0, 85), (1.5, 7.5, 2.2), gold, bevel=0.3, rotation=(0, 0, math.radians(-side * 14)))
        part(tasset_gold, "pelvis")

    # --- LIMBS, PAULDRONS & HOLY RAPIER ---
    for side, suffix in ((1, "L"), (-1, "R")):
        upper_bone = "upperarm_l" if side > 0 else "upperarm_r"
        lower_bone = "lowerarm_l" if side > 0 else "lowerarm_r"
        hand_bone = "hand_l" if side > 0 else "hand_r"
        thigh_bone = "thigh_l" if side > 0 else "thigh_r"
        calf_bone = "calf_l" if side > 0 else "calf_r"
        foot_bone = "foot_l" if side > 0 else "foot_r"

        pauldron = beveled_part(f"Valkyrie_Shoulder_{suffix}", (side * 22, 0, 145), (10.5, 11.5, 5.5), white_plate, bevel=1.2, subsurf=True, rotation=(0, 0, math.radians(-side * 18)))
        part(pauldron, upper_bone)
        pauldron_wing = beveled_part(f"Valkyrie_ShoulderWing_{suffix}", (side * 27, -1.0, 148), (6.5, 9.5, 2.8), gold, bevel=0.4, rotation=(0, math.radians(side * 12), math.radians(-side * 26)))
        part(pauldron_wing, upper_bone)

        bicep = cylinder_between(f"Valkyrie_UpperArm_{suffix}", (side * 12, 0, 144), (side * 38, 0, 131), 4.8, skin_mat)
        smart_uv(bicep)
        part(bicep, upper_bone)

        armlet = beveled_part(f"Valkyrie_Armlet_{suffix}", (side * 26, 0, 137), (5.5, 5.5, 2.0), gold, bevel=0.3)
        part(armlet, upper_bone)

        forearm = cylinder_between(f"Valkyrie_Forearm_{suffix}", (side * 38, 0, 131), (side * 64, 0, 109), 4.5, white_plate)
        smart_uv(forearm)
        part(forearm, lower_bone)

        vambrace = beveled_part(f"Valkyrie_Vambrace_{suffix}", (side * 50, -0.5, 120), (6.5, 5.8, 10.5), white_plate, bevel=1.0, subsurf=True)
        part(vambrace, lower_bone)
        vambrace_gold = beveled_part(f"Valkyrie_VambraceGold_{suffix}", (side * 50, -3.2, 120), (2.2, 0.8, 8.5), gold, bevel=0.2)
        part(vambrace_gold, lower_bone)

        hand = beveled_part(f"Valkyrie_Hand_{suffix}", (side * 68, 0, 104), (4.5, 5.0, 5.5), white_plate, bevel=0.8, subsurf=True)
        part(hand, hand_bone)

        if side < 0: # Right hand holds holy rapier
            rapier_blade, rapier_parts = build_holy_rapier("Valkyrie_Rapier", (side * 69, -2, 99), white_plate, gold, holy_glow, steel)
            part(rapier_blade, hand_bone)
            for rp in rapier_parts:
                part(rp, hand_bone)

        thigh = cylinder_between(f"Valkyrie_Thigh_{suffix}", (side * 17, 0, 86), (side * 18, 0, 52), 7.8, white_plate)
        smart_uv(thigh)
        part(thigh, thigh_bone)
        thigh_ribbon = beveled_part(f"Valkyrie_ThighRibbon_{suffix}", (side * 17, 0, 84), (8.6, 8.6, 2.2), gold, bevel=0.3)
        part(thigh_ribbon, thigh_bone)

        knee = beveled_part(f"Valkyrie_KneeGuard_{suffix}", (side * 18, -4.5, 51), (6.2, 4.0, 6.5), gold, bevel=0.8, subsurf=True)
        part(knee, calf_bone)
        knee_gem = beveled_part(f"Valkyrie_KneeGem_{suffix}", (side * 18, -6.2, 51), (1.5, 0.8, 1.5), holy_glow, bevel=0.2)
        part(knee_gem, calf_bone)

        shin = cylinder_between(f"Valkyrie_Shin_{suffix}", (side * 18, 0, 48), (side * 17, 0, 16), 6.5, white_plate)
        smart_uv(shin)
        part(shin, calf_bone)
        greave = beveled_part(f"Valkyrie_Greave_{suffix}", (side * 18, -3.2, 33), (5.5, 2.8, 14), white_plate, bevel=0.8, subsurf=True)
        part(greave, calf_bone)
        greave_trim = beveled_part(f"Valkyrie_GreaveTrim_{suffix}", (side * 18, -4.6, 33), (1.8, 0.6, 9.0), gold, bevel=0.2)
        part(greave_trim, calf_bone)

        foot = beveled_part(f"Valkyrie_Foot_{suffix}", (side * 17, -5, 8), (6.8, 14, 5.0), white_plate, bevel=1.0, subsurf=True)
        part(foot, foot_bone)
        sole = beveled_part(f"Valkyrie_Sole_{suffix}", (side * 17, -5, 2.2), (7.5, 15, 1.6), gold, bevel=0.3)
        part(sole, foot_bone)
        heel_wing = beveled_part(f"Valkyrie_HeelWing_{suffix}", (side * 22, 2.0, 12), (4.5, 1.0, 2.8), gold, bevel=0.2, rotation=(math.radians(20), math.radians(side * 25), math.radians(-side * 15)))
        part(heel_wing, foot_bone)

    add_combat_actions(armature, "Valkyrie", heavy=False)
    setup_hero_camera(110, 260, lens=52)
    add_preview_lights(110, energy=4000)
    render_preview("valkyrie_model_preview.png")
    save_and_export(armature, "PFU_MoeValkyrie.blend", "PFU_MoeValkyrie.fbx")
    print("VALKYRIE_GEN_OK")


# -----------------------------------------------------------------------------
# CYBER DRAGON SLAYER BUILDER (Menacing horned dragon knight with greatsword & tail)
# -----------------------------------------------------------------------------
def build_dragon():
    reset_scene()
    obsidian_scales = material("M_DragonScales", (0.04, 0.04, 0.05), metallic=0.45, roughness=0.35)
    titanium_dark = material("M_DragonTitanium", (0.08, 0.10, 0.14), metallic=0.85, roughness=0.22)
    gold_trim = material("M_DragonGold", (0.92, 0.72, 0.18), metallic=0.95, roughness=0.18)
    fire_glow = material("M_DragonFire", (1.0, 0.32, 0.05), metallic=0.5, roughness=0.1, emission=(1.0, 0.35, 0.05), emission_strength=12.0)
    plasma_edge = material("M_DragonPlasma", (1.0, 0.55, 0.1), metallic=0.9, roughness=0.05, emission=(1.0, 0.65, 0.15), emission_strength=15.0)
    visor_glow = material("M_DragonVisor", (1.0, 0.15, 0.05), metallic=0.2, roughness=0.1, emission=(1.0, 0.15, 0.05), emission_strength=14.0)
    mane_mat = material("M_DragonMane", (0.12, 0.05, 0.05), metallic=0.2, roughness=0.45)

    armature = create_armature("SK_Dragon", fighter_bones(scale=1.06, wide=1.05))
    parts = []

    def part(obj, bone):
        skin_rigid(obj, armature, bone)
        parts.append(obj)
        return obj

    # --- AUTHENTIC DRAGON WARRIOR FACE & HELM ---
    face = create_face_plate("Dragon_FacePlate", (0, -2.5, 172), (8.8, 5.8, 10.5), "face_dragon.png")
    part(face, "head")

    head = uv_part("Dragon_HeadBase", (0, 2.5, 173), (9.0, 8.5, 10.5), titanium_dark)
    part(head, "head")

    jaw_guard = beveled_part("Dragon_JawGuard", (0, -6.8, 163), (8.0, 4.2, 3.5), gold_trim, bevel=0.8, subsurf=True)
    part(jaw_guard, "head")

    crest = beveled_part("Dragon_ForeheadCrest", (0, -11.5, 178), (3.5, 2.2, 5.0), gold_trim, bevel=0.6, rotation=(math.radians(18), 0, 0))
    part(crest, "head")

    # Sweeping Curved Obsidian Dragon Horns
    for side, suffix in ((1, "L"), (-1, "R")):
        h_base = beveled_part(f"Dragon_HornBase_{suffix}", (side * 8.5, -2.0, 182), (3.2, 4.0, 5.0), gold_trim, bevel=0.6, rotation=(math.radians(15), math.radians(side * 24), math.radians(-side * 15)))
        part(h_base, "head")
        h_mid = beveled_part(f"Dragon_HornMid_{suffix}", (side * 14.5, 6.0, 189), (2.8, 3.5, 9.5), obsidian_scales, bevel=0.8, subsurf=True, rotation=(math.radians(-25), math.radians(side * 32), math.radians(-side * 22)))
        part(h_mid, "head")
        h_tip = beveled_part(f"Dragon_HornTip_{suffix}", (side * 19.5, 18.0, 196), (1.8, 2.2, 8.5), obsidian_scales, bevel=0.5, subsurf=True, rotation=(math.radians(-42), math.radians(side * 22), math.radians(-side * 14)))
        part(h_tip, "head")
        h_ring = beveled_part(f"Dragon_HornRing_{suffix}", (side * 18.0, 14.0, 193), (2.2, 2.6, 1.5), gold_trim, bevel=0.2, rotation=(math.radians(-35), math.radians(side * 26), math.radians(-side * 18)))
        part(h_ring, "head")

    # Flowing Cyber-Dragon Mane
    for m_idx, (m_x, m_y, m_z, m_sz, m_rot) in enumerate([
        (0.0, 13.0, 176.0, (3.5, 4.0, 14.0), (math.radians(-28), 0, 0)),
        (4.5, 12.0, 172.0, (2.8, 3.2, 16.0), (math.radians(-32), math.radians(10), math.radians(-6))),
        (-4.5, 12.0, 172.0, (2.8, 3.2, 16.0), (math.radians(-32), math.radians(-10), math.radians(6))),
        (7.5, 10.0, 166.0, (2.2, 2.8, 18.0), (math.radians(-38), math.radians(18), math.radians(-12))),
        (-7.5, 10.0, 166.0, (2.2, 2.8, 18.0), (math.radians(-38), math.radians(-18), math.radians(12))),
    ]):
        mane = beveled_part(f"Dragon_Mane_{m_idx}", (m_x, m_y, m_z), m_sz, mane_mat, bevel=0.8, subsurf=True, rotation=m_rot)
        part(mane, "head")

    neck = cylinder_between("Dragon_Neck", (0, 0, 156), (0, 0, 166), 5.5, titanium_dark)
    smart_uv(neck)
    part(neck, "neck")

    # --- TORSO: SCALED DRAGON CUIRASS & DRAGON HEARTH CORE ---
    torso_base = uv_part("Dragon_TorsoBase", (0, 0, 135), (20, 13, 22), titanium_dark)
    part(torso_base, "spine_01")

    chest_scale_l = beveled_part("Dragon_ChestScale_L", (9.0, -7.5, 140), (10.0, 3.8, 12.0), obsidian_scales, bevel=1.5, subsurf=True, rotation=(0, math.radians(-8), math.radians(12)))
    part(chest_scale_l, "spine_02")
    chest_scale_r = beveled_part("Dragon_ChestScale_R", (-9.0, -7.5, 140), (10.0, 3.8, 12.0), obsidian_scales, bevel=1.5, subsurf=True, rotation=(0, math.radians(8), math.radians(-12)))
    part(chest_scale_r, "spine_02")

    core_crest = beveled_part("Dragon_CoreCrest", (0, -8.8, 142), (6.5, 2.2, 8.5), gold_trim, bevel=0.5, rotation=(0, 0, math.radians(45)))
    part(core_crest, "spine_02")
    core_flame = beveled_part("Dragon_CoreFlame", (0, -10.2, 142), (3.8, 1.2, 5.0), fire_glow, bevel=0.3, rotation=(0, 0, math.radians(45)))
    part(core_flame, "spine_02")

    back_carapace = beveled_part("Dragon_BackCarapace", (0, 8.5, 140), (14.0, 3.5, 15.0), obsidian_scales, bevel=1.8, subsurf=True)
    part(back_carapace, "spine_02")
    for s_idx in range(3):
        spine_fin = beveled_part(f"Dragon_SpineFin_{s_idx}", (0, 12.5 + s_idx * 1.5, 132 + s_idx * 9), (1.5, 3.5, 4.5), gold_trim, bevel=0.3, rotation=(math.radians(-25), 0, 0))
        part(spine_fin, "spine_02")

    # --- PELVIS & ARTICULATED DRAGON TAIL ---
    pelvis_base = uv_part("Dragon_PelvisBase", (0, 0, 98), (18, 13, 14), titanium_dark)
    part(pelvis_base, "pelvis")

    belt = beveled_part("Dragon_WarBelt", (0, 0, 104), (20.5, 14.0, 4.5), gold_trim, bevel=0.6)
    part(belt, "pelvis")

    # Articulated Multi-Segmented Dragon Tail
    tail_pts = [
        (0.0, 15.0, 96.0, (4.5, 5.5, 5.5), math.radians(-18)),
        (0.0, 24.0, 88.0, (4.0, 5.0, 6.0), math.radians(-32)),
        (0.0, 34.0, 76.0, (3.5, 4.5, 6.5), math.radians(-45)),
        (0.0, 44.0, 60.0, (3.0, 3.8, 7.0), math.radians(-38)),
        (0.0, 51.0, 43.0, (2.2, 3.0, 7.5), math.radians(-22)),
    ]
    for t_idx, (tx, ty, tz, tsz, tang) in enumerate(tail_pts):
        tail_seg = beveled_part(f"Dragon_TailSeg_{t_idx}", (tx, ty, tz), tsz, obsidian_scales, bevel=0.8, subsurf=True, rotation=(tang, 0, 0))
        part(tail_seg, "pelvis")
        t_glow = beveled_part(f"Dragon_TailGlow_{t_idx}", (tx, ty, tz + 2.5), (tsz[0] * 0.5, tsz[1] * 0.4, 2.0), fire_glow, bevel=0.2, rotation=(tang, 0, 0))
        part(t_glow, "pelvis")
        t_fin = beveled_part(f"Dragon_TailFin_{t_idx}", (tx, ty + 2.8, tz + 4.5), (0.8, 2.8, 3.8), gold_trim, bevel=0.2, rotation=(tang - math.radians(15), 0, 0))
        part(t_fin, "pelvis")

    tail_spear = beveled_part("Dragon_TailSpear", (0, 55.0, 26.0), (3.2, 1.2, 9.0), gold_trim, bevel=0.4, rotation=(math.radians(10), 0, 0))
    part(tail_spear, "pelvis")
    tail_blade_l = beveled_part("Dragon_TailBladeL", (3.0, 55.0, 28.0), (1.0, 2.5, 6.0), fire_glow, bevel=0.2, rotation=(math.radians(10), math.radians(25), 0))
    part(tail_blade_l, "pelvis")
    tail_blade_r = beveled_part("Dragon_TailBladeR", (-3.0, 55.0, 28.0), (1.0, 2.5, 6.0), fire_glow, bevel=0.2, rotation=(math.radians(10), math.radians(-25), 0))
    part(tail_blade_r, "pelvis")

    # --- LIMBS, PAULDRONS & GREATSWORD ---
    for side, suffix in ((1, "L"), (-1, "R")):
        upper_bone = "upperarm_l" if side > 0 else "upperarm_r"
        lower_bone = "lowerarm_l" if side > 0 else "lowerarm_r"
        hand_bone = "hand_l" if side > 0 else "hand_r"
        thigh_bone = "thigh_l" if side > 0 else "thigh_r"
        calf_bone = "calf_l" if side > 0 else "calf_r"
        foot_bone = "foot_l" if side > 0 else "foot_r"

        p_main = beveled_part(f"Dragon_Pauldron_{suffix}", (side * 25, 0, 148), (12.0, 13.0, 6.0), obsidian_scales, bevel=1.5, subsurf=True, rotation=(0, 0, math.radians(-side * 18)))
        part(p_main, upper_bone)
        p_blade = beveled_part(f"Dragon_PauldronBlade_{suffix}", (side * 34, -2.0, 153), (8.5, 12.0, 3.2), gold_trim, bevel=0.5, rotation=(0, math.radians(side * 15), math.radians(-side * 30)))
        part(p_blade, upper_bone)
        p_glow = beveled_part(f"Dragon_PauldronGlow_{suffix}", (side * 28, -5.2, 149), (3.0, 1.2, 7.0), fire_glow, bevel=0.3, rotation=(0, 0, math.radians(-side * 22)))
        part(p_glow, upper_bone)

        bicep = cylinder_between(f"Dragon_Bicep_{suffix}", (side * 14, 0, 146), (side * 42, 0, 132), 6.2, titanium_dark)
        smart_uv(bicep)
        part(bicep, upper_bone)

        forearm = cylinder_between(f"Dragon_Forearm_{suffix}", (side * 42, 0, 132), (side * 70, 0, 108), 5.8, titanium_dark)
        smart_uv(forearm)
        part(forearm, lower_bone)

        vambrace = beveled_part(f"Dragon_Vambrace_{suffix}", (side * 56, -0.5, 120), (8.0, 7.2, 11.5), obsidian_scales, bevel=1.2, subsurf=True)
        part(vambrace, lower_bone)
        v_spike = beveled_part(f"Dragon_VambraceSpike_{suffix}", (side * 56, 7.5, 120), (2.0, 5.0, 7.0), gold_trim, bevel=0.4, rotation=(math.radians(-20), 0, 0))
        part(v_spike, lower_bone)

        hand = beveled_part(f"Dragon_Hand_{suffix}", (side * 74, 0, 103), (5.5, 6.0, 6.5), titanium_dark, bevel=1.0, subsurf=True)
        part(hand, hand_bone)
        for k_idx in range(3):
            claw = beveled_part(f"Dragon_Claw_{suffix}_{k_idx}", (side * (71 + k_idx * 3.0), -6.5, 101), (1.6, 3.2, 2.5), gold_trim, bevel=0.3)
            part(claw, hand_bone)

        # DRAGON SLAYER GREATSWORD (In right hand)
        if side < 0:
            gs_main, gs_parts = build_dragon_greatsword("Dragon_Greatsword", (side * 76, -2, 98), titanium_dark, gold_trim, fire_glow, plasma_edge)
            part(gs_main, hand_bone)
            for gsp in gs_parts:
                part(gsp, hand_bone)

        thigh = cylinder_between(f"Dragon_Thigh_{suffix}", (side * 20, 0, 88), (side * 22, 0, 53), 9.2, titanium_dark)
        smart_uv(thigh)
        part(thigh, thigh_bone)
        thigh_plate = beveled_part(f"Dragon_ThighPlate_{suffix}", (side * 21, -6.5, 72), (7.5, 4.0, 13.0), obsidian_scales, bevel=1.0, subsurf=True)
        part(thigh_plate, thigh_bone)

        knee = beveled_part(f"Dragon_KneeGuard_{suffix}", (side * 22, -6.0, 52), (8.5, 5.5, 8.5), gold_trim, bevel=1.2, subsurf=True)
        part(knee, calf_bone)
        knee_horn = beveled_part(f"Dragon_KneeHorn_{suffix}", (side * 22, -10.5, 54), (2.8, 4.8, 4.5), obsidian_scales, bevel=0.4, rotation=(math.radians(20), 0, 0))
        part(knee_horn, calf_bone)

        shin = cylinder_between(f"Dragon_Shin_{suffix}", (side * 22, 0, 49), (side * 20, 0, 16), 7.8, titanium_dark)
        smart_uv(shin)
        part(shin, calf_bone)
        shin_plate = beveled_part(f"Dragon_ShinPlate_{suffix}", (side * 21, -4.8, 33), (7.0, 3.8, 15.0), obsidian_scales, bevel=1.0, subsurf=True)
        part(shin_plate, calf_bone)
        shin_ridge = beveled_part(f"Dragon_ShinRidge_{suffix}", (side * 21, -8.0, 33), (2.2, 1.2, 11.0), fire_glow, bevel=0.2)
        part(shin_ridge, calf_bone)

        foot = beveled_part(f"Dragon_Foot_{suffix}", (side * 20, -7, 8), (8.5, 17.0, 6.0), obsidian_scales, bevel=1.2, subsurf=True)
        part(foot, foot_bone)
        sole = beveled_part(f"Dragon_Sole_{suffix}", (side * 20, -7, 2.2), (9.2, 18.0, 1.8), gold_trim, bevel=0.4)
        part(sole, foot_bone)
        for toe_idx in range(3):
            toe_claw = beveled_part(f"Dragon_Toe_{suffix}_{toe_idx}", (side * (16 + toe_idx * 4.0), -23, 5.5), (2.0, 4.5, 3.2), gold_trim, bevel=0.3)
            part(toe_claw, foot_bone)
        heel_talon = beveled_part(f"Dragon_HeelTalon_{suffix}", (side * 20, 8.5, 10.0), (2.2, 4.5, 3.5), gold_trim, bevel=0.3, rotation=(math.radians(-25), 0, 0))
        part(heel_talon, foot_bone)

    add_combat_actions(armature, "Dragon", heavy=False)
    setup_hero_camera(120, 290, lens=50)
    add_preview_lights(120, energy=4400)
    render_preview("dragon_model_preview.png")
    save_and_export(armature, "PFU_CyberDragon.blend", "PFU_CyberDragon.fbx")
    print("DRAGON_GEN_OK")


# -----------------------------------------------------------------------------
# CYBER ANUBIS BUILDER (Jackal God of the Underworld with Dual Khopesh)
# -----------------------------------------------------------------------------
def build_anubis():
    reset_scene()
    gold_royal = material("M_AnubisGold", (0.95, 0.76, 0.20), metallic=0.96, roughness=0.15)
    lapis_blue = material("M_AnubisLapis", (0.06, 0.16, 0.45), metallic=0.35, roughness=0.32)
    obsidian_black = material("M_AnubisObsidian", (0.04, 0.04, 0.05), metallic=0.75, roughness=0.22)
    emerald_glow = material("M_AnubisEmerald", (0.10, 1.0, 0.55), metallic=0.4, roughness=0.08, emission=(0.12, 1.0, 0.60), emission_strength=14.0)
    plasma_edge = material("M_AnubisPlasma", (0.15, 1.0, 0.70), metallic=0.9, roughness=0.04, emission=(0.2, 1.0, 0.75), emission_strength=16.0)

    armature = create_armature("SK_Anubis", fighter_bones(scale=1.04, wide=1.02))
    parts = []

    def part(obj, bone):
        skin_rigid(obj, armature, bone)
        parts.append(obj)
        return obj

    # --- AUTHENTIC ANUBIS JACKAL VISAGE & NEMES ---
    face = create_face_plate("Anubis_FacePlate", (0, -2.5, 172), (8.5, 5.5, 10.2), "face_anubis.png")
    part(face, "head")

    head = uv_part("Anubis_HeadBase", (0, 2.5, 173), (8.8, 8.5, 10.5), obsidian_black)
    part(head, "head")

    muzzle = beveled_part("Anubis_Muzzle", (0, -9.5, 169.0), (4.5, 7.5, 4.2), obsidian_black, bevel=0.8, subsurf=True, rotation=(math.radians(8), 0, 0))
    part(muzzle, "head")
    nose = beveled_part("Anubis_Nose", (0, -16.5, 170.2), (2.4, 2.0, 1.8), gold_royal, bevel=0.3)
    part(nose, "head")

    fang_l = beveled_part("Anubis_Fang_L", (1.8, -15.5, 167.5), (0.6, 1.0, 1.8), gold_royal, bevel=0.2)
    part(fang_l, "head")
    fang_r = beveled_part("Anubis_Fang_R", (-1.8, -15.5, 167.5), (0.6, 1.0, 1.8), gold_royal, bevel=0.2)
    part(fang_r, "head")

    uraeus = beveled_part("Anubis_Uraeus", (0, -10.5, 179.0), (2.8, 2.2, 4.5), gold_royal, bevel=0.4, rotation=(math.radians(16), 0, 0))
    part(uraeus, "head")
    uraeus_eye = beveled_part("Anubis_UraeusGem", (0, -11.8, 180.5), (1.4, 1.0, 1.4), emerald_glow, bevel=0.2)
    part(uraeus_eye, "head")

    for side, suffix in ((1, "L"), (-1, "R")):
        e_base = beveled_part(f"Anubis_EarBase_{suffix}", (side * 7.5, 0, 183), (3.2, 4.2, 5.5), gold_royal, bevel=0.6, rotation=(0, math.radians(side * 14), math.radians(-side * 12)))
        part(e_base, "head")
        e_mid = beveled_part(f"Anubis_EarMid_{suffix}", (side * 10.5, 2.0, 192), (2.8, 3.8, 9.0), obsidian_black, bevel=0.7, subsurf=True, rotation=(math.radians(-10), math.radians(side * 18), math.radians(-side * 15)))
        part(e_mid, "head")
        e_inner = beveled_part(f"Anubis_EarInner_{suffix}", (side * 9.8, -1.0, 192), (1.8, 1.2, 7.5), gold_royal, bevel=0.3, rotation=(math.radians(-10), math.radians(side * 18), math.radians(-side * 15)))
        part(e_inner, "head")
        e_tip = beveled_part(f"Anubis_EarTip_{suffix}", (side * 13.5, 4.5, 203), (1.6, 2.2, 7.5), obsidian_black, bevel=0.4, subsurf=True, rotation=(math.radians(-14), math.radians(side * 16), math.radians(-side * 14)))
        part(e_tip, "head")
        e_glow = beveled_part(f"Anubis_EarGlow_{suffix}", (side * 13.0, 1.5, 202), (0.8, 0.8, 6.0), emerald_glow, bevel=0.2, rotation=(math.radians(-14), math.radians(side * 16), math.radians(-side * 14)))
        part(e_glow, "head")

    for n_side, n_suf in ((1, "L"), (-1, "R")):
        nemes_front = beveled_part(f"Anubis_NemesFront_{n_suf}", (n_side * 10.5, -3.0, 166.0), (3.2, 5.5, 12.0), lapis_blue, bevel=0.6, rotation=(math.radians(12), math.radians(n_side * 10), 0))
        part(nemes_front, "head")
        nemes_trim = beveled_part(f"Anubis_NemesTrim_{n_suf}", (n_side * 10.8, -4.5, 160.0), (2.6, 1.0, 4.0), gold_royal, bevel=0.3)
        part(nemes_trim, "head")

    nemes_back = beveled_part("Anubis_NemesBack", (0, 10.0, 168.0), (14.0, 3.5, 14.0), lapis_blue, bevel=0.8, subsurf=True, rotation=(math.radians(-15), 0, 0))
    part(nemes_back, "head")

    neck = cylinder_between("Anubis_Neck", (0, 0, 156), (0, 0, 166), 5.2, obsidian_black)
    smart_uv(neck)
    part(neck, "neck")

    # --- TORSO: EGYPTIAN WESEKH COLLAR & RADIANT SCARAB CORE ---
    torso_base = uv_part("Anubis_TorsoBase", (0, 0, 135), (19, 12, 22), obsidian_black)
    part(torso_base, "spine_01")

    collar = beveled_part("Anubis_WesekhCollar", (0, -2.0, 148), (22.0, 15.0, 4.2), gold_royal, bevel=1.0, subsurf=True)
    part(collar, "spine_02")
    collar_lapis = beveled_part("Anubis_CollarLapis", (0, -3.5, 148), (19.5, 13.0, 2.5), lapis_blue, bevel=0.6)
    part(collar_lapis, "spine_02")

    scarab_body = beveled_part("Anubis_ScarabBody", (0, -8.5, 141), (5.5, 2.4, 7.5), gold_royal, bevel=0.6, subsurf=True)
    part(scarab_body, "spine_02")
    scarab_core = beveled_part("Anubis_ScarabCore", (0, -9.8, 141), (3.4, 1.4, 4.8), emerald_glow, bevel=0.3, rotation=(0, 0, math.radians(45)))
    part(scarab_core, "spine_02")
    scarab_wing_l = beveled_part("Anubis_ScarabWing_L", (6.5, -8.0, 142), (6.5, 1.8, 4.5), lapis_blue, bevel=0.4, rotation=(0, math.radians(-10), math.radians(18)))
    part(scarab_wing_l, "spine_02")
    scarab_wing_r = beveled_part("Anubis_ScarabWing_R", (-6.5, -8.0, 142), (6.5, 1.8, 4.5), lapis_blue, bevel=0.4, rotation=(0, math.radians(10), math.radians(-18)))
    part(scarab_wing_r, "spine_02")

    back_plate = beveled_part("Anubis_BackPlate", (0, 8.0, 140), (13.0, 3.2, 16.0), gold_royal, bevel=1.2, subsurf=True)
    part(back_plate, "spine_02")

    # --- PELVIS, SHENDYT BATTLE KILT & JACKAL TAIL ---
    pelvis = uv_part("Anubis_PelvisBase", (0, 0, 98), (17, 12, 13), obsidian_black)
    part(pelvis, "pelvis")

    belt = beveled_part("Anubis_PharaohBelt", (0, 0, 104), (19.5, 13.5, 4.2), gold_royal, bevel=0.5)
    part(belt, "pelvis")
    belt_buckle = beveled_part("Anubis_BeltBuckle", (0, -7.5, 103), (4.5, 2.2, 4.5), gold_royal, bevel=0.4, rotation=(0, 0, math.radians(45)))
    part(belt_buckle, "pelvis")
    belt_gem = beveled_part("Anubis_BeltGem", (0, -8.6, 103), (2.2, 1.2, 2.2), emerald_glow, bevel=0.2, rotation=(0, 0, math.radians(45)))
    part(belt_gem, "pelvis")

    tabard = beveled_part("Anubis_Tabard", (0, -7.0, 86), (5.5, 1.2, 15.0), lapis_blue, bevel=0.4, rotation=(math.radians(4), 0, 0))
    part(tabard, "pelvis")
    tabard_trim = beveled_part("Anubis_TabardTrim", (0, -7.8, 79), (4.5, 0.8, 2.2), gold_royal, bevel=0.3)
    part(tabard_trim, "pelvis")

    tail_pts = [
        (0.0, 13.0, 97.0, (3.5, 4.5, 5.0), math.radians(-22)),
        (0.0, 20.0, 89.0, (3.2, 4.0, 5.5), math.radians(-38)),
        (0.0, 27.0, 77.0, (2.8, 3.5, 6.0), math.radians(-48)),
        (0.0, 32.0, 62.0, (2.4, 3.0, 6.5), math.radians(-32)),
    ]
    for t_idx, (tx, ty, tz, tsz, tang) in enumerate(tail_pts):
        tail_seg = beveled_part(f"Anubis_TailSeg_{t_idx}", (tx, ty, tz), tsz, obsidian_black, bevel=0.7, subsurf=True, rotation=(tang, 0, 0))
        part(tail_seg, "pelvis")
        t_ring = beveled_part(f"Anubis_TailRing_{t_idx}", (tx, ty, tz), (tsz[0] * 1.15, tsz[1] * 1.15, 1.2), gold_royal, bevel=0.2, rotation=(tang, 0, 0))
        part(t_ring, "pelvis")

    tail_tip = beveled_part("Anubis_TailTip", (0.0, 34.0, 48.0), (1.8, 2.4, 6.0), emerald_glow, bevel=0.3, rotation=(math.radians(-15), 0, 0))
    part(tail_tip, "pelvis")

    # --- LIMBS, PAULDRONS & DUAL KHOPESH ---
    for side, suffix in ((1, "L"), (-1, "R")):
        upper_bone = "upperarm_l" if side > 0 else "upperarm_r"
        lower_bone = "lowerarm_l" if side > 0 else "lowerarm_r"
        hand_bone = "hand_l" if side > 0 else "hand_r"
        thigh_bone = "thigh_l" if side > 0 else "thigh_r"
        calf_bone = "calf_l" if side > 0 else "calf_r"
        foot_bone = "foot_l" if side > 0 else "foot_r"

        pauldron = beveled_part(f"Anubis_Pauldron_{suffix}", (side * 23, 0, 146), (10.5, 11.5, 5.5), gold_royal, bevel=1.2, subsurf=True, rotation=(0, 0, math.radians(-side * 18)))
        part(pauldron, upper_bone)
        p_gem = beveled_part(f"Anubis_PauldronGem_{suffix}", (side * 26, -4.5, 148), (2.8, 1.2, 5.5), emerald_glow, bevel=0.3, rotation=(0, 0, math.radians(-side * 20)))
        part(p_gem, upper_bone)

        bicep = cylinder_between(f"Anubis_Bicep_{suffix}", (side * 14, 0, 145), (side * 39, 0, 132), 5.5, obsidian_black)
        smart_uv(bicep)
        part(bicep, upper_bone)

        forearm = cylinder_between(f"Anubis_Forearm_{suffix}", (side * 39, 0, 132), (side * 64, 0, 110), 5.0, obsidian_black)
        smart_uv(forearm)
        part(forearm, lower_bone)

        vambrace = beveled_part(f"Anubis_Vambrace_{suffix}", (side * 52, 0, 120), (7.0, 6.5, 10.0), gold_royal, bevel=1.0, subsurf=True)
        part(vambrace, lower_bone)
        v_rune = beveled_part(f"Anubis_VambraceRune_{suffix}", (side * 52, -4.0, 120), (2.0, 1.0, 6.0), emerald_glow, bevel=0.2)
        part(v_rune, lower_bone)

        hand = beveled_part(f"Anubis_Hand_{suffix}", (side * 68, 0, 105), (5.0, 5.5, 5.8), gold_royal, bevel=0.8, subsurf=True)
        part(hand, hand_bone)

        # DUAL DIVINE KHOPESH (One in each hand!)
        kh_main, kh_parts = build_khopesh(f"Anubis_Khopesh_{suffix}", (side * 70, -2, 100), gold_royal, lapis_blue, emerald_glow, plasma_edge, side=side)
        part(kh_main, hand_bone)
        for kp in kh_parts:
            part(kp, hand_bone)

        thigh = cylinder_between(f"Anubis_Thigh_{suffix}", (side * 18, 0, 88), (side * 20, 0, 53), 8.0, obsidian_black)
        smart_uv(thigh)
        part(thigh, thigh_bone)
        thigh_guard = beveled_part(f"Anubis_ThighGuard_{suffix}", (side * 19, -5.5, 72), (6.5, 3.2, 12.0), gold_royal, bevel=0.8, subsurf=True)
        part(thigh_guard, thigh_bone)

        knee = beveled_part(f"Anubis_KneeGuard_{suffix}", (side * 20, -5.0, 52), (7.5, 4.8, 7.5), gold_royal, bevel=1.0, subsurf=True)
        part(knee, calf_bone)
        knee_gem = beveled_part(f"Anubis_KneeGem_{suffix}", (side * 20, -8.0, 52), (2.0, 1.2, 2.0), emerald_glow, bevel=0.2, rotation=(0, 0, math.radians(45)))
        part(knee_gem, calf_bone)

        shin = cylinder_between(f"Anubis_Shin_{suffix}", (side * 20, 0, 49), (side * 18, 0, 16), 6.8, obsidian_black)
        smart_uv(shin)
        part(shin, calf_bone)
        shin_plate = beveled_part(f"Anubis_ShinPlate_{suffix}", (side * 19, -4.2, 33), (6.0, 3.2, 14.0), gold_royal, bevel=0.8, subsurf=True)
        part(shin_plate, calf_bone)
        shin_rune = beveled_part(f"Anubis_ShinRune_{suffix}", (side * 19, -6.5, 33), (1.8, 1.0, 10.0), emerald_glow, bevel=0.2)
        part(shin_rune, calf_bone)

        foot = beveled_part(f"Anubis_Foot_{suffix}", (side * 18, -6, 8), (7.5, 16.0, 5.5), gold_royal, bevel=1.0, subsurf=True)
        part(foot, foot_bone)
        sole = beveled_part(f"Anubis_Sole_{suffix}", (side * 18, -6, 2.0), (8.0, 17.0, 1.6), lapis_blue, bevel=0.3)
        part(sole, foot_bone)

    add_combat_actions(armature, "Anubis", heavy=False)
    setup_hero_camera(120, 280, lens=50)
    add_preview_lights(120, energy=4400)
    render_preview("anubis_model_preview.png")
    save_and_export(armature, "PFU_CyberAnubis.blend", "PFU_CyberAnubis.fbx")
    print("ANUBIS_GEN_OK")


def _advanced_material(name, base_color, metallic=0.0, roughness=0.35,
                        emission=None, emission_strength=0.0,
                        subsurface=0.0, subsurface_radius=(1.0, 0.2, 0.1),
                        anisotropic=0.0, clearcoat=0.0, clearcoat_roughness=0.1,
                        ior=1.45, specular=0.5):
    """Advanced PBR with subsurface scattering, anisotropy, clearcoat and procedural bump."""
    mat = bpy.data.materials.get(name) or bpy.data.materials.new(name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    links = mat.node_tree.links
    nodes.clear()
    out  = nodes.new("ShaderNodeOutputMaterial"); out.location  = (400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (0,   0)
    links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])
    bsdf.inputs["Base Color"].default_value = (*base_color, 1.0)
    bsdf.inputs["Metallic"].default_value   = metallic
    bsdf.inputs["Roughness"].default_value  = roughness
    bsdf.inputs["IOR"].default_value        = ior
    for skey in ("Specular IOR Level", "Specular"):
        if skey in bsdf.inputs: bsdf.inputs[skey].default_value = specular; break
    for sskey in ("Subsurface Weight", "Subsurface"):
        if sskey in bsdf.inputs: bsdf.inputs[sskey].default_value = subsurface; break
    if "Subsurface Radius" in bsdf.inputs:
        try: bsdf.inputs["Subsurface Radius"].default_value = subsurface_radius
        except Exception: pass
    if "Anisotropic" in bsdf.inputs: bsdf.inputs["Anisotropic"].default_value = anisotropic
    for cckey in ("Coat Weight", "Clearcoat"):
        if cckey in bsdf.inputs: bsdf.inputs[cckey].default_value = clearcoat; break
    for ccrkey in ("Coat Roughness", "Clearcoat Roughness"):
        if ccrkey in bsdf.inputs: bsdf.inputs[ccrkey].default_value = clearcoat_roughness; break
    if emission is not None:
        for ekey in ("Emission Color", "Emission"):
            if ekey in bsdf.inputs: bsdf.inputs[ekey].default_value = (*emission, 1.0); break
        if "Emission Strength" in bsdf.inputs: bsdf.inputs["Emission Strength"].default_value = emission_strength
    # Procedural noise normal detail
    tc    = nodes.new("ShaderNodeTexCoord"); tc.location    = (-700, -200)
    noise = nodes.new("ShaderNodeTexNoise"); noise.location = (-500, -200)
    noise.inputs["Scale"].default_value = 18.0; noise.inputs["Detail"].default_value = 12.0
    noise.inputs["Roughness"].default_value = 0.65
    bump  = nodes.new("ShaderNodeBump");     bump.location  = (-200, -200)
    bump.inputs["Strength"].default_value = 0.35; bump.inputs["Distance"].default_value = 0.8
    links.new(tc.outputs["UV"],       noise.inputs["Vector"])
    links.new(noise.outputs["Fac"],   bump.inputs["Height"])
    links.new(bump.outputs["Normal"], bsdf.inputs["Normal"])
    return mat


def _iridescent_crystal_material(name, base_color=(0.05, 0.08, 0.18)):
    """Iridescent crystal: shifts colour with viewing angle like a soap bubble."""
    mat = bpy.data.materials.get(name) or bpy.data.materials.new(name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes; links = mat.node_tree.links; nodes.clear()
    out  = nodes.new("ShaderNodeOutputMaterial"); out.location  = (700,  0)
    mix  = nodes.new("ShaderNodeMixShader");      mix.location  = (500,  0)
    links.new(mix.outputs["Shader"], out.inputs["Surface"])
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (200,  120)
    bsdf.inputs["Base Color"].default_value = (*base_color, 1.0)
    bsdf.inputs["Metallic"].default_value   = 0.0
    bsdf.inputs["Roughness"].default_value  = 0.04
    bsdf.inputs["IOR"].default_value        = 2.42
    for cckey in ("Coat Weight", "Clearcoat"):
        if cckey in bsdf.inputs: bsdf.inputs[cckey].default_value = 1.0; break
    for ccrkey in ("Coat Roughness", "Clearcoat Roughness"):
        if ccrkey in bsdf.inputs: bsdf.inputs[ccrkey].default_value = 0.02; break
    for ekey in ("Emission Color", "Emission"):
        if ekey in bsdf.inputs: bsdf.inputs[ekey].default_value = (0.3, 0.6, 1.0, 1.0); break
    if "Emission Strength" in bsdf.inputs: bsdf.inputs["Emission Strength"].default_value = 0.6
    # Iridescence gradient via facing angle
    lw = nodes.new("ShaderNodeLayerWeight"); lw.location = (-200, -120)
    lw.inputs["Blend"].default_value = 0.35
    ramp = nodes.new("ShaderNodeValToRGB");  ramp.location = (0, -200)
    ramp.color_ramp.interpolation = "LINEAR"
    iris_stops = [(0.0,(0.8,0.1,0.9,1.0)),(0.25,(0.1,0.3,1.0,1.0)),
                  (0.5,(0.0,1.0,0.7,1.0)),(0.75,(1.0,0.8,0.1,1.0)),(1.0,(1.0,0.2,0.1,1.0))]
    while len(ramp.color_ramp.elements) < len(iris_stops):
        ramp.color_ramp.elements.new(0.5)
    for i,(pos,col) in enumerate(iris_stops):
        ramp.color_ramp.elements[i].position = pos
        ramp.color_ramp.elements[i].color    = col
    em = nodes.new("ShaderNodeEmission"); em.location = (200, -200)
    em.inputs["Strength"].default_value = 1.8
    links.new(lw.outputs["Facing"],    ramp.inputs["Fac"])
    links.new(ramp.outputs["Color"],   em.inputs["Color"])
    # Noise normal
    tc    = nodes.new("ShaderNodeTexCoord"); tc.location    = (-600, -350)
    noise = nodes.new("ShaderNodeTexNoise"); noise.location = (-400, -350)
    noise.inputs["Scale"].default_value = 24.0; noise.inputs["Detail"].default_value = 16.0
    bump  = nodes.new("ShaderNodeBump");     bump.location  = (-100, -350)
    bump.inputs["Strength"].default_value = 0.6
    links.new(tc.outputs["UV"],       noise.inputs["Vector"])
    links.new(noise.outputs["Fac"],   bump.inputs["Height"])
    links.new(bump.outputs["Normal"], bsdf.inputs["Normal"])
    fresnel = nodes.new("ShaderNodeFresnel"); fresnel.location = (300, -60)
    fresnel.inputs["IOR"].default_value = 1.8
    links.new(fresnel.outputs["Fac"],        mix.inputs["Fac"])
    links.new(bsdf.outputs["BSDF"],          mix.inputs[1])
    links.new(em.outputs["Emission"],        mix.inputs[2])
    return mat


def build_void_lance(name, location, crystal_mat, glow_mat):
    """Dual-ended energy lance with crystal facets and plasma core."""
    parts = []
    shaft = beveled_part(f"{name}_Shaft", location, (3.0, 3.0, 70.0), crystal_mat, bevel=0.5, subsurf=True)
    parts.append(shaft)
    for i, z_off in enumerate([-28, -14, 0, 14, 28]):
        ring = beveled_part(f"{name}_Ring{i}",
                            (location[0], location[1], location[2]+z_off),
                            (4.2, 4.2, 3.5), crystal_mat, bevel=0.8, subsurf=True,
                            rotation=(0, 0, math.radians(45)))
        parts.append(ring)
    tip = beveled_part(f"{name}_Tip", (location[0], location[1], location[2]+72),
                       (2.5, 2.5, 18.0), glow_mat, bevel=0.4, subsurf=True,
                       rotation=(0, 0, math.radians(22)))
    parts.append(tip)
    core = beveled_part(f"{name}_Core", location, (1.2, 1.2, 68.0), glow_mat, bevel=0.1)
    parts.append(core)
    return parts


def build_specter():
    """
    Void Specter — crystalline phantom warrior with next-gen PBR materials:
    iridescent crystal armour, SSS skin, anisotropic trim, clearcoat pauldrons,
    noise-bump normals on every surface. Wields a dual-ended Void Lance.
    """
    reset_scene()
    ensure_output_dirs()

    crystal_body  = _iridescent_crystal_material("M_SpecterCrystal",  (0.04, 0.06, 0.16))
    crystal_armor = _iridescent_crystal_material("M_SpecterArmor",    (0.06, 0.03, 0.14))
    void_glow     = _advanced_material("M_SpecterGlow",
                        base_color=(0.05, 0.0, 0.25), metallic=0.0, roughness=0.02,
                        emission=(0.45, 0.15, 1.0), emission_strength=8.0, ior=1.1)
    plasma_core   = _advanced_material("M_SpecterPlasma",
                        base_color=(0.02, 0.0, 0.18), metallic=0.0, roughness=0.0,
                        emission=(0.6, 0.2, 1.0), emission_strength=14.0, ior=1.05)
    phantom_skin  = _advanced_material("M_SpecterSkin",
                        base_color=(0.08, 0.10, 0.28), metallic=0.0, roughness=0.60,
                        subsurface=0.45, subsurface_radius=(0.6, 0.4, 1.2),
                        clearcoat=0.3, clearcoat_roughness=0.2, ior=1.38)
    aniso_trim    = _advanced_material("M_SpecterTrim",
                        base_color=(0.55, 0.45, 0.85), metallic=1.0, roughness=0.12,
                        anisotropic=0.85, clearcoat=0.8, clearcoat_roughness=0.05,
                        ior=2.5, specular=0.9)
    eye_glow      = _advanced_material("M_SpecterEye",
                        base_color=(0.0, 0.0, 0.0), metallic=0.0, roughness=0.0,
                        emission=(0.5, 0.0, 1.0), emission_strength=20.0)

    armature = create_armature("SK_Specter", fighter_bones(scale=1.02, wide=0.96))

    def part(obj, bone_name):
        skin_rigid(obj, armature, bone_name)

    # Head
    skull = beveled_part("Specter_Skull", (0, 0, 175), (10.5, 10.0, 11.5), crystal_body, bevel=2.0, subsurf=True)
    part(skull, "head")
    skull_inner = beveled_part("Specter_SkullInner", (0, 0, 175), (8.0, 7.5, 9.5), void_glow, bevel=1.0)
    part(skull_inner, "head")
    for side, sx in ((1, 4.5), (-1, -4.5)):
        sfx = "L" if side > 0 else "R"
        eye = beveled_part(f"Specter_Eye_{sfx}", (sx, -8.0, 177), (2.8, 1.0, 2.8), eye_glow, bevel=0.3)
        part(eye, "head")
        cheek = beveled_part(f"Specter_Cheek_{sfx}", (sx*1.6, -3.0, 171), (3.5, 2.5, 4.0), aniso_trim, bevel=0.6, subsurf=True)
        part(cheek, "head")
    crest = beveled_part("Specter_Crest", (0, 0, 185), (7.0, 3.0, 8.0), crystal_armor, bevel=1.5, subsurf=True)
    part(crest, "head")
    for i, (px, pz) in enumerate([(-3, 196), (0, 202), (3, 196)]):
        sp = beveled_part(f"Specter_CrestSpike{i}", (px, 0, pz), (1.8, 1.2, 6.0+i*2), void_glow, bevel=0.2, subsurf=True)
        part(sp, "head")

    # Neck
    neck = cylinder_between("Specter_Neck", (0,0,153), (0,0,167), 6.0, phantom_skin)
    part(neck, "neck")
    collar = beveled_part("Specter_Collar", (0,0,157), (9.0,9.0,4.0), aniso_trim, bevel=0.8)
    part(collar, "neck")

    # Torso
    chest = beveled_part("Specter_Chest", (0,0,130), (18.0,11.0,20.0), crystal_armor, bevel=2.5, subsurf=True)
    part(chest, "spine_02")
    chest_gem = beveled_part("Specter_ChestGem", (0,-10.5,134), (6.0,1.0,6.0), plasma_core, bevel=0.3, rotation=(0,0,math.radians(45)))
    part(chest_gem, "spine_02")
    for i, x in enumerate([-12, 12]):
        rib = beveled_part(f"Specter_Rib{i}", (x,-8.0,128), (3.5,1.2,14.0), void_glow, bevel=0.3)
        part(rib, "spine_02")
    abdomen = beveled_part("Specter_Abdomen", (0,0,108), (14.0,9.0,14.0), crystal_body, bevel=2.0, subsurf=True)
    part(abdomen, "spine_01")
    for i, x in enumerate([-8, 0, 8]):
        abp = beveled_part(f"Specter_AbPlate{i}", (x,-8.5,108), (3.8,1.0,4.5), aniso_trim, bevel=0.4)
        part(abp, "spine_01")
    belt = beveled_part("Specter_Belt", (0,0,92), (15.5,9.5,5.0), aniso_trim, bevel=1.0)
    part(belt, "pelvis")
    pelvis = beveled_part("Specter_Pelvis", (0,0,87), (13.0,8.5,6.5), crystal_armor, bevel=1.5, subsurf=True)
    part(pelvis, "pelvis")
    for sx, sfx in ((14, "L"), (-14, "R")):
        hg = beveled_part(f"Specter_HipGem{sfx}", (sx,-7,90), (2.5,1.0,2.5), plasma_core, bevel=0.2, rotation=(0,0,math.radians(45)))
        part(hg, "pelvis")

    # Pauldrons with crystal wing shards
    for side, sfx, ubone in ((1,"L","upperarm_l"),(-1,"R","upperarm_r")):
        px = side * 50
        paul = beveled_part(f"Specter_Pauldron_{sfx}", (px,0,148), (14.0,9.0,18.0), crystal_armor, bevel=2.5, subsurf=True)
        part(paul, ubone)
        pgem = beveled_part(f"Specter_PaulGem_{sfx}", (px,-9.0,152), (4.0,1.0,4.0), plasma_core, bevel=0.3, rotation=(0,0,math.radians(45)))
        part(pgem, ubone)
        for i, z in enumerate([143, 148, 153]):
            ws = beveled_part(f"Specter_WingShard_{sfx}_{i}",
                              (px+side*(8+i*6), -2.0, z), (3.5+i, 1.8, 9.0-i*1.5),
                              void_glow, bevel=0.4, subsurf=True,
                              rotation=(0, 0, math.radians(side*(-15-i*8))))
            part(ws, ubone)

    # Arms
    for side, sfx, ubone, lbone, hbone in (
            (1,"L","upperarm_l","lowerarm_l","hand_l"),
            (-1,"R","upperarm_r","lowerarm_r","hand_r")):
        sw = side
        ux, lx, hx = sw*46, sw*70, sw*84
        ua = cylinder_between(f"Specter_UpperArm_{sfx}", (sw*28,0,142), (ux,0,126), 6.5, phantom_skin)
        part(ua, ubone)
        ug = beveled_part(f"Specter_ElbowGuard_{sfx}", (ux,0,126), (8.0,8.0,6.0), crystal_armor, bevel=1.2, subsurf=True)
        part(ug, ubone)
        eg = beveled_part(f"Specter_ElbowGem_{sfx}", (ux,-8.0,126), (2.2,1.0,2.2), plasma_core, bevel=0.2, rotation=(0,0,math.radians(45)))
        part(eg, ubone)
        la = cylinder_between(f"Specter_LowerArm_{sfx}", (ux,0,124), (lx,0,108), 5.8, phantom_skin)
        part(la, lbone)
        fg = beveled_part(f"Specter_ForeGuard_{sfx}", (sw*58,0,116), (5.0,6.0,14.0), crystal_armor, bevel=1.0, subsurf=True)
        part(fg, lbone)
        hand = beveled_part(f"Specter_Hand_{sfx}", (hx,0,100), (6.5,5.0,9.0), crystal_body, bevel=1.5, subsurf=True)
        part(hand, hbone)
        kg = beveled_part(f"Specter_KnuckleGem_{sfx}", (hx,-5.5,100), (1.8,0.8,1.8), plasma_core, bevel=0.15)
        part(kg, hbone)

    # Void Lance in right hand
    for lp in build_void_lance("VoidLance", (-86, 0, 50), crystal_armor, plasma_core):
        part(lp, "hand_r")

    # Legs
    for side, sfx, thbone, cfbone, ftbone in (
            (1,"L","thigh_l","calf_l","foot_l"),
            (-1,"R","thigh_r","calf_r","foot_r")):
        sw = side
        th = cylinder_between(f"Specter_Thigh_{sfx}", (sw*20,0,86), (sw*22,0,52), 9.0, phantom_skin)
        smart_uv(th); part(th, thbone)
        tp = beveled_part(f"Specter_ThighPlate_{sfx}", (sw*22,-6.0,70), (8.0,3.5,14.0), crystal_armor, bevel=1.2, subsurf=True)
        part(tp, thbone)
        tg = beveled_part(f"Specter_ThighGem_{sfx}", (sw*22,-9.0,70), (2.0,1.0,2.0), plasma_core, bevel=0.15)
        part(tg, thbone)
        kc = beveled_part(f"Specter_Knee_{sfx}", (sw*22,-6.5,52), (8.5,5.5,8.5), crystal_armor, bevel=1.5, subsurf=True)
        part(kc, cfbone)
        kg = beveled_part(f"Specter_KneeGem_{sfx}", (sw*22,-10.5,52), (2.5,1.0,2.5), plasma_core, bevel=0.2, rotation=(0,0,math.radians(45)))
        part(kg, cfbone)
        sh = cylinder_between(f"Specter_Shin_{sfx}", (sw*22,0,50), (sw*20,0,16), 7.2, phantom_skin)
        smart_uv(sh); part(sh, cfbone)
        sp = beveled_part(f"Specter_ShinPlate_{sfx}", (sw*20,-5.5,33), (6.5,3.5,16.0), crystal_armor, bevel=1.0, subsurf=True)
        part(sp, cfbone)
        sr = beveled_part(f"Specter_ShinRune_{sfx}", (sw*20,-8.5,33), (1.5,0.8,12.0), void_glow, bevel=0.15)
        part(sr, cfbone)
        ft = beveled_part(f"Specter_Foot_{sfx}", (sw*19,-7,8), (8.0,17.0,5.5), crystal_armor, bevel=1.5, subsurf=True)
        part(ft, ftbone)
        sl = beveled_part(f"Specter_Sole_{sfx}", (sw*19,-7,2.0), (8.5,18.0,1.5), aniso_trim, bevel=0.3)
        part(sl, ftbone)

    add_combat_actions(armature, "Specter", heavy=False)
    setup_hero_camera(120, 280, lens=50)
    add_preview_lights(120, energy=5000)
    render_preview("specter_model_preview.png")
    save_and_export(armature, "PFU_VoidSpecter.blend", "PFU_VoidSpecter.fbx")
    print("SPECTER_GEN_OK")


def _feather_material(name, base_color=(0.65, 0.12, 0.02)):
    """Iridescent feather: layered color shift + fine noise detail."""
    mat = bpy.data.materials.get(name) or bpy.data.materials.new(name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes; links = mat.node_tree.links; nodes.clear()
    out  = nodes.new("ShaderNodeOutputMaterial"); out.location  = (800, 0)
    mix  = nodes.new("ShaderNodeMixShader");      mix.location  = (600, 0)
    links.new(mix.outputs["Shader"], out.inputs["Surface"])
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (200, 120)
    bsdf.inputs["Base Color"].default_value = (*base_color, 1.0)
    bsdf.inputs["Metallic"].default_value   = 0.35
    bsdf.inputs["Roughness"].default_value  = 0.18
    bsdf.inputs["IOR"].default_value        = 1.85
    for cckey in ("Coat Weight", "Clearcoat"):
        if cckey in bsdf.inputs: bsdf.inputs[cckey].default_value = 0.9; break
    for ccrkey in ("Coat Roughness", "Clearcoat Roughness"):
        if ccrkey in bsdf.inputs: bsdf.inputs[ccrkey].default_value = 0.04; break
    if "Anisotropic" in bsdf.inputs: bsdf.inputs["Anisotropic"].default_value = 0.7
    # Feather iridescence via facing-angle
    lw = nodes.new("ShaderNodeLayerWeight"); lw.location = (-200, -100)
    lw.inputs["Blend"].default_value = 0.4
    ramp = nodes.new("ShaderNodeValToRGB"); ramp.location = (0, -180)
    ramp.color_ramp.interpolation = "LINEAR"
    stops = [(0.0,(0.9,0.15,0.02,1)),(0.3,(1.0,0.5,0.05,1)),(0.55,(1.0,0.85,0.2,1)),
             (0.8,(0.9,0.3,0.6,1)),(1.0,(0.4,0.1,0.7,1))]
    while len(ramp.color_ramp.elements) < len(stops):
        ramp.color_ramp.elements.new(0.5)
    for i,(pos,col) in enumerate(stops):
        ramp.color_ramp.elements[i].position = pos
        ramp.color_ramp.elements[i].color = col
    emit = nodes.new("ShaderNodeEmission"); emit.location = (200, -180)
    emit.inputs["Strength"].default_value = 1.2
    links.new(lw.outputs["Facing"], ramp.inputs["Fac"])
    links.new(ramp.outputs["Color"], emit.inputs["Color"])
    fresnel = nodes.new("ShaderNodeFresnel"); fresnel.location = (350, -40)
    fresnel.inputs["IOR"].default_value = 1.6
    links.new(fresnel.outputs["Fac"], mix.inputs["Fac"])
    links.new(bsdf.outputs["BSDF"], mix.inputs[1])
    links.new(emit.outputs["Emission"], mix.inputs[2])
    # Fine feather noise normal
    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-600, -350)
    n1 = nodes.new("ShaderNodeTexNoise"); n1.location = (-400, -350)
    n1.inputs["Scale"].default_value = 45.0; n1.inputs["Detail"].default_value = 16.0
    n1.inputs["Roughness"].default_value = 0.8
    n2 = nodes.new("ShaderNodeTexNoise"); n2.location = (-400, -500)
    n2.inputs["Scale"].default_value = 12.0; n2.inputs["Detail"].default_value = 8.0
    add = nodes.new("ShaderNodeMath"); add.location = (-200, -400); add.operation = "ADD"
    bump = nodes.new("ShaderNodeBump"); bump.location = (-50, -400)
    bump.inputs["Strength"].default_value = 0.55
    links.new(tc.outputs["UV"], n1.inputs["Vector"])
    links.new(tc.outputs["UV"], n2.inputs["Vector"])
    links.new(n1.outputs["Fac"], add.inputs[0])
    links.new(n2.outputs["Fac"], add.inputs[1])
    links.new(add.outputs["Value"], bump.inputs["Height"])
    links.new(bump.outputs["Normal"], bsdf.inputs["Normal"])
    return mat


def _molten_material(name, base=(0.85, 0.55, 0.08), emission=(1.0, 0.4, 0.05), strength=6.0):
    """Molten gold/lava material with veined emission."""
    mat = bpy.data.materials.get(name) or bpy.data.materials.new(name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes; links = mat.node_tree.links; nodes.clear()
    out  = nodes.new("ShaderNodeOutputMaterial"); out.location = (600, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (200, 0)
    links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])
    bsdf.inputs["Base Color"].default_value = (*base, 1.0)
    bsdf.inputs["Metallic"].default_value = 0.92
    bsdf.inputs["Roughness"].default_value = 0.08
    if "Anisotropic" in bsdf.inputs: bsdf.inputs["Anisotropic"].default_value = 0.6
    for cckey in ("Coat Weight", "Clearcoat"):
        if cckey in bsdf.inputs: bsdf.inputs[cckey].default_value = 0.95; break
    for ekey in ("Emission Color", "Emission"):
        if ekey in bsdf.inputs: bsdf.inputs[ekey].default_value = (*emission, 1.0); break
    if "Emission Strength" in bsdf.inputs: bsdf.inputs["Emission Strength"].default_value = strength
    tc = nodes.new("ShaderNodeTexCoord"); tc.location = (-500, -200)
    noise = nodes.new("ShaderNodeTexNoise"); noise.location = (-300, -200)
    noise.inputs["Scale"].default_value = 30.0; noise.inputs["Detail"].default_value = 14.0
    bump = nodes.new("ShaderNodeBump"); bump.location = (-50, -200)
    bump.inputs["Strength"].default_value = 0.25
    links.new(tc.outputs["UV"], noise.inputs["Vector"])
    links.new(noise.outputs["Fac"], bump.inputs["Height"])
    links.new(bump.outputs["Normal"], bsdf.inputs["Normal"])
    return mat


def build_phoenix_glaive(name, location, blade_mat, shaft_mat, fire_mat):
    """Double-bladed phoenix glaive with flame core."""
    parts = []
    shaft = cylinder_between(f"{name}_Shaft", (location[0], location[1], location[2]-35),
                             (location[0], location[1], location[2]+35), 2.2, shaft_mat, vertices=12)
    smart_uv(shaft); parts.append(shaft)
    for i, zo in enumerate([-18, -6, 6, 18]):
        r = beveled_part(f"{name}_Ring{i}", (location[0], location[1], location[2]+zo),
                         (3.5, 3.5, 2.5), blade_mat, bevel=0.6, subsurf=True, rotation=(0,0,math.radians(45)))
        parts.append(r)
    # Top blade
    tb = beveled_part(f"{name}_TopBlade", (location[0], location[1], location[2]+45),
                      (4.5, 2.0, 20.0), blade_mat, bevel=0.5, subsurf=True)
    parts.append(tb)
    tf = beveled_part(f"{name}_TopFlame", (location[0], location[1], location[2]+55),
                      (2.0, 1.0, 14.0), fire_mat, bevel=0.2, subsurf=True)
    parts.append(tf)
    # Bottom blade
    bb = beveled_part(f"{name}_BotBlade", (location[0], location[1], location[2]-45),
                      (4.5, 2.0, 20.0), blade_mat, bevel=0.5, subsurf=True)
    parts.append(bb)
    bf = beveled_part(f"{name}_BotFlame", (location[0], location[1], location[2]-55),
                      (2.0, 1.0, 14.0), fire_mat, bevel=0.2, subsurf=True)
    parts.append(bf)
    core = beveled_part(f"{name}_Core", location, (1.0, 1.0, 60.0), fire_mat, bevel=0.1)
    parts.append(core)
    return parts


def build_phoenix():
    """
    PHOENIX EMPRESS — the most detailed character in the game.
    Layered feather armor with iridescent color shift, molten gold anisotropic trim,
    fire-wing pauldrons, lava-vein emission nodes, dual noise normals on every surface,
    and 100+ geometry parts. Wields a double-bladed Phoenix Glaive.
    """
    reset_scene()
    ensure_output_dirs()

    # Materials — 9 unique advanced shaders
    feather_red    = _feather_material("M_PhoenixFeather",   (0.72, 0.10, 0.02))
    feather_gold   = _feather_material("M_PhoenixFeatherGold",(0.85, 0.55, 0.08))
    feather_deep   = _feather_material("M_PhoenixFeatherDeep",(0.55, 0.04, 0.12))
    molten_gold    = _molten_material("M_PhoenixGold",       (0.88, 0.62, 0.10), (1.0, 0.6, 0.1), 5.0)
    lava_vein      = _molten_material("M_PhoenixLava",       (0.15, 0.02, 0.0),  (1.0, 0.25, 0.02), 14.0)
    fire_glow      = _advanced_material("M_PhoenixFire",
                        base_color=(0.1, 0.0, 0.0), metallic=0.0, roughness=0.0,
                        emission=(1.0, 0.45, 0.05), emission_strength=18.0, ior=1.05)
    skin_warm      = _advanced_material("M_PhoenixSkin",
                        base_color=(0.78, 0.52, 0.38), metallic=0.0, roughness=0.55,
                        subsurface=0.50, subsurface_radius=(1.2, 0.5, 0.15),
                        clearcoat=0.2, ior=1.40)
    eye_fire       = _advanced_material("M_PhoenixEye",
                        base_color=(0.0, 0.0, 0.0), metallic=0.0, roughness=0.0,
                        emission=(1.0, 0.6, 0.0), emission_strength=25.0)
    obsidian       = _advanced_material("M_PhoenixObsidian",
                        base_color=(0.03, 0.02, 0.04), metallic=0.85, roughness=0.10,
                        clearcoat=0.9, clearcoat_roughness=0.03, anisotropic=0.7, ior=2.2)

    armature = create_armature("SK_Phoenix", fighter_bones(scale=1.05, wide=1.02))

    def part(obj, bone_name):
        skin_rigid(obj, armature, bone_name)

    # ── HEAD: authentic empress face & crest feathers ────────────────────
    face = create_face_plate("Phoenix_FacePlate", (0, -2.2, 178), (8.8, 5.5, 10.5), "face_phoenix.png")
    part(face, "head")

    skull = uv_part("Phx_Skull", (0, 2.5, 179), (8.8, 8.2, 10.2), feather_deep)
    part(skull, "head")
    for side,sx in ((1,4.8),(-1,-4.8)):
        sfx = "L" if side>0 else "R"
        horn = beveled_part(f"Phx_Horn_{sfx}", (sx*6,0,188), (1.5,1.5,10.0), molten_gold, bevel=0.3, subsurf=True,
                            rotation=(0, math.radians(side*-20), 0))
        part(horn, "head")
    # Crest feathers (5 layered)
    for i in range(5):
        z = 190 + i*5
        sz = 8.0 - i*1.0
        f_mat = feather_gold if i % 2 == 0 else feather_red
        feather = beveled_part(f"Phx_CrestFeather{i}", (0, 2.0+i, z), (3.0-i*0.3, 1.0, sz),
                               f_mat, bevel=0.3, subsurf=True, rotation=(math.radians(-15-i*5), 0, 0))
        part(feather, "head")
    crown = beveled_part("Phx_Crown", (0,0,186), (11.0,4.0,3.5), molten_gold, bevel=1.0, subsurf=True)
    part(crown, "head")
    crown_gem = beveled_part("Phx_CrownGem", (0,-4.5,186), (3.0,1.0,3.0), fire_glow, bevel=0.3,
                             rotation=(0,0,math.radians(45)))
    part(crown_gem, "head")

    # ── NECK ─────────────────────────────────────────────────────────────
    neck = cylinder_between("Phx_Neck", (0,0,155), (0,0,170), 6.5, skin_warm)
    part(neck, "neck")
    gorget = beveled_part("Phx_Gorget", (0,0,158), (10.0,10.0,5.0), feather_deep, bevel=1.0, subsurf=True)
    part(gorget, "neck")
    gorget_trim = beveled_part("Phx_GorgetTrim", (0,0,155), (11.0,11.0,1.5), molten_gold, bevel=0.4)
    part(gorget_trim, "neck")

    # ── TORSO: layered feather chest plate ───────────────────────────────
    chest = beveled_part("Phx_Chest", (0,0,133), (19.0,12.0,21.0), feather_red, bevel=2.8, subsurf=True)
    part(chest, "spine_02")
    chest_layer2 = beveled_part("Phx_ChestInner", (0,-7,134), (14.0,2.5,16.0), feather_deep, bevel=1.5, subsurf=True)
    part(chest_layer2, "spine_02")
    for i,x in enumerate([-10, 0, 10]):
        vent = beveled_part(f"Phx_ChestVent{i}", (x,-11.0,132), (3.0,0.8,8.0), lava_vein, bevel=0.2)
        part(vent, "spine_02")
    chest_gem = beveled_part("Phx_ChestGem", (0,-12.0,137), (5.5,1.5,5.5), fire_glow, bevel=0.4,
                             rotation=(0,0,math.radians(45)))
    part(chest_gem, "spine_02")
    chest_trim = beveled_part("Phx_ChestTrim", (0,-11.5,133), (18.0,0.8,2.0), molten_gold, bevel=0.3)
    part(chest_trim, "spine_02")

    abdomen = beveled_part("Phx_Abdomen", (0,0,110), (15.0,10.0,15.0), feather_red, bevel=2.2, subsurf=True)
    part(abdomen, "spine_01")
    for i,x in enumerate([-8, 0, 8]):
        scale = beveled_part(f"Phx_Scale{i}", (x,-9.0,110), (4.0,1.2,5.0), feather_gold, bevel=0.5, subsurf=True)
        part(scale, "spine_01")
    ab_trim = beveled_part("Phx_AbTrim", (0,-9.5,105), (14.0,0.8,1.5), molten_gold, bevel=0.2)
    part(ab_trim, "spine_01")

    belt = beveled_part("Phx_Belt", (0,0,95), (16.5,10.0,5.5), molten_gold, bevel=1.2, subsurf=True)
    part(belt, "pelvis")
    belt_gem = beveled_part("Phx_BeltGem", (0,-9.5,95), (3.5,1.0,3.5), fire_glow, bevel=0.3,
                            rotation=(0,0,math.radians(45)))
    part(belt_gem, "pelvis")
    pelvis = beveled_part("Phx_Pelvis", (0,0,88), (14.0,9.0,7.0), feather_deep, bevel=1.8, subsurf=True)
    part(pelvis, "pelvis")
    # Tassets (hanging armor skirt)
    for side, sfx in ((1,"L"),(-1,"R")):
        for j in range(3):
            tx = side * (8 + j*5)
            tasset = beveled_part(f"Phx_Tasset{sfx}{j}", (tx,-4,84), (4.0,1.5,8.0+j), feather_gold, bevel=0.5, subsurf=True)
            part(tasset, "pelvis")

    # ── FIRE WING PAULDRONS ──────────────────────────────────────────────
    for side, sfx, ubone in ((1,"L","upperarm_l"),(-1,"R","upperarm_r")):
        px = side * 52
        paul = beveled_part(f"Phx_Pauldron_{sfx}", (px,0,150), (15.0,10.0,20.0), feather_red, bevel=2.8, subsurf=True)
        part(paul, ubone)
        paul_trim = beveled_part(f"Phx_PaulTrim_{sfx}", (px,-10,152), (14.0,0.8,1.5), molten_gold, bevel=0.3)
        part(paul_trim, ubone)
        paul_gem = beveled_part(f"Phx_PaulGem_{sfx}", (px,-10,154), (3.5,1.0,3.5), fire_glow, bevel=0.3,
                                rotation=(0,0,math.radians(45)))
        part(paul_gem, ubone)
        # Fire wing feathers (5 per side)
        for i in range(5):
            wing_len = 12.0 - i*1.2
            wing_x = px + side*(10+i*7)
            wing_z = 148 + i*2
            angle = math.radians(side*(-12 - i*10))
            w_mat = feather_gold if i < 2 else (fire_glow if i == 4 else feather_red)
            wing = beveled_part(f"Phx_Wing_{sfx}_{i}", (wing_x, -2, wing_z),
                                (4.0+i*0.5, 1.5, wing_len), w_mat, bevel=0.4, subsurf=True,
                                rotation=(0, 0, angle))
            part(wing, ubone)
        # Lava veins on pauldron
        for i in range(2):
            vein = beveled_part(f"Phx_PaulVein_{sfx}_{i}", (px+side*(3+i*5),-8,148+i*4),
                                (1.0,0.5,10.0), lava_vein, bevel=0.1)
            part(vein, ubone)

    # ── ARMS ─────────────────────────────────────────────────────────────
    for side, sfx, ubone, lbone, hbone in (
            (1,"L","upperarm_l","lowerarm_l","hand_l"),
            (-1,"R","upperarm_r","lowerarm_r","hand_r")):
        sw = side
        ux, lx, hx = sw*48, sw*74, sw*88
        ua = cylinder_between(f"Phx_UpperArm_{sfx}", (sw*30,0,144), (ux,0,128), 7.0, skin_warm)
        part(ua, ubone)
        elbow = beveled_part(f"Phx_Elbow_{sfx}", (ux,0,128), (8.5,8.5,6.5), feather_red, bevel=1.4, subsurf=True)
        part(elbow, ubone)
        eg = beveled_part(f"Phx_ElbowGem_{sfx}", (ux,-8.5,128), (2.5,1.0,2.5), fire_glow, bevel=0.2,
                          rotation=(0,0,math.radians(45)))
        part(eg, ubone)
        la = cylinder_between(f"Phx_LowerArm_{sfx}", (ux,0,126), (lx,0,110), 6.2, skin_warm)
        part(la, lbone)
        bracer = beveled_part(f"Phx_Bracer_{sfx}", (sw*60,0,118), (5.5,6.5,15.0), feather_gold, bevel=1.0, subsurf=True)
        part(bracer, lbone)
        bracer_trim = beveled_part(f"Phx_BracerTrim_{sfx}", (sw*60,-6.5,118), (5.0,0.5,1.5), molten_gold, bevel=0.2)
        part(bracer_trim, lbone)
        hand = beveled_part(f"Phx_Hand_{sfx}", (hx,0,102), (7.0,5.5,9.5), skin_warm, bevel=1.5, subsurf=True)
        part(hand, hbone)
        gauntlet = beveled_part(f"Phx_Gauntlet_{sfx}", (hx,-3,102), (6.0,3.5,8.0), obsidian, bevel=0.8, subsurf=True)
        part(gauntlet, hbone)
        knuckle = beveled_part(f"Phx_Knuckle_{sfx}", (hx,-6,102), (2.0,0.8,2.0), fire_glow, bevel=0.15)
        part(knuckle, hbone)

    # ── PHOENIX GLAIVE (right hand) ──────────────────────────────────────
    for lp in build_phoenix_glaive("PhxGlaive", (-90, 0, 52), feather_gold, obsidian, fire_glow):
        part(lp, "hand_r")

    # ── LEGS ─────────────────────────────────────────────────────────────
    for side, sfx, thbone, cfbone, ftbone in (
            (1,"L","thigh_l","calf_l","foot_l"),
            (-1,"R","thigh_r","calf_r","foot_r")):
        sw = side
        th = cylinder_between(f"Phx_Thigh_{sfx}", (sw*21,0,88), (sw*23,0,54), 9.5, skin_warm)
        smart_uv(th); part(th, thbone)
        thigh_plate = beveled_part(f"Phx_ThighPlate_{sfx}", (sw*23,-6.5,72), (8.5,4.0,15.0), feather_red, bevel=1.4, subsurf=True)
        part(thigh_plate, thbone)
        thigh_trim = beveled_part(f"Phx_ThighTrim_{sfx}", (sw*23,-9.5,72), (7.5,0.5,1.5), molten_gold, bevel=0.2)
        part(thigh_trim, thbone)
        tg = beveled_part(f"Phx_ThighGem_{sfx}", (sw*23,-10.0,72), (2.2,1.0,2.2), fire_glow, bevel=0.15,
                          rotation=(0,0,math.radians(45)))
        part(tg, thbone)
        knee = beveled_part(f"Phx_Knee_{sfx}", (sw*23,-7,54), (9.0,6.0,9.0), feather_deep, bevel=1.8, subsurf=True)
        part(knee, cfbone)
        knee_gem = beveled_part(f"Phx_KneeGem_{sfx}", (sw*23,-11,54), (2.8,1.0,2.8), fire_glow, bevel=0.2,
                                rotation=(0,0,math.radians(45)))
        part(knee_gem, cfbone)
        shin = cylinder_between(f"Phx_Shin_{sfx}", (sw*23,0,52), (sw*21,0,16), 7.8, skin_warm)
        smart_uv(shin); part(shin, cfbone)
        greave = beveled_part(f"Phx_Greave_{sfx}", (sw*21,-6,34), (7.0,4.0,17.0), feather_gold, bevel=1.2, subsurf=True)
        part(greave, cfbone)
        greave_trim = beveled_part(f"Phx_GreaveTrim_{sfx}", (sw*21,-9,34), (6.0,0.5,1.5), molten_gold, bevel=0.2)
        part(greave_trim, cfbone)
        shin_vein = beveled_part(f"Phx_ShinVein_{sfx}", (sw*21,-9,34), (1.2,0.5,14.0), lava_vein, bevel=0.1)
        part(shin_vein, cfbone)
        foot = beveled_part(f"Phx_Foot_{sfx}", (sw*20,-7,8), (8.5,18.0,6.0), feather_red, bevel=1.8, subsurf=True)
        part(foot, ftbone)
        sole = beveled_part(f"Phx_Sole_{sfx}", (sw*20,-7,2), (9.0,19.0,1.8), obsidian, bevel=0.4)
        part(sole, ftbone)
        # Talon claw detail
        for ci in range(3):
            claw = beveled_part(f"Phx_Claw_{sfx}_{ci}", (sw*(18+ci*2),-18,4), (1.2,3.5,1.0), molten_gold,
                                bevel=0.2, rotation=(math.radians(15),0,0))
            part(claw, ftbone)

    add_combat_actions(armature, "Phoenix", heavy=False)
    setup_hero_camera(125, 290, lens=48)
    add_preview_lights(125, energy=6000)
    render_preview("phoenix_model_preview.png")
    save_and_export(armature, "PFU_PhoenixEmpress.blend", "PFU_PhoenixEmpress.fbx")
    print("PHOENIX_GEN_OK")


def build_goku():
    """
    SON GOKU (Ultra Ego / Super Saiyan Ultra with Purple Hair).
    Authentic Toriyama Dragon Ball aesthetic:
    - Iconic Goku spiked hair (massive curved spikes + 3 front bangs) in radiant purple (#9b30ff)
    - Authentic UV-mapped anime face plate with Toriyama eyes, furrowed brow & smirk
    - Orange Turtle School Gi with V-neck cutout revealing navy blue undershirt
    - Toned muscular bare anime arms
    - Navy blue sash belt with tied knot & hanging tails
    - Baggy orange martial arts pants with fabric folds
    - Navy blue wristbands & martial arts boots with red laces
    - Red Power Pole (Nyoi-bo) with gold caps
    """
    reset_scene()
    ensure_output_dirs()

    hair_purple = _advanced_material("M_GokuHair",
        base_color=(0.42, 0.08, 0.75), metallic=0.35, roughness=0.18,
        anisotropic=0.85, clearcoat=1.0, clearcoat_roughness=0.04,
        emission=(0.32, 0.05, 0.60), emission_strength=0.6)
    gi_orange = _advanced_material("M_GokuGi",
        base_color=(0.95, 0.32, 0.10), metallic=0.02, roughness=0.80,
        subsurface=0.10, ior=1.45)
    navy_blue = _advanced_material("M_GokuNavy",
        base_color=(0.08, 0.12, 0.42), metallic=0.04, roughness=0.75)
    skin_toned = _advanced_material("M_GokuSkin",
        base_color=(0.85, 0.62, 0.48), metallic=0.0, roughness=0.52,
        subsurface=0.45, subsurface_radius=(1.1, 0.45, 0.15),
        clearcoat=0.25, clearcoat_roughness=0.10, ior=1.42)
    staff_red = _advanced_material("M_GokuStaff",
        base_color=(0.75, 0.12, 0.12), metallic=0.85, roughness=0.15,
        clearcoat=0.8)
    gold_trim = _advanced_material("M_GokuGold",
        base_color=(0.95, 0.78, 0.20), metallic=0.96, roughness=0.15)
    ki_glow = _advanced_material("M_GokuKi",
        base_color=(0.1, 0.0, 0.2), metallic=0.0, roughness=0.0,
        emission=(0.75, 0.25, 1.0), emission_strength=16.0)

    armature = create_armature("SK_Goku", fighter_bones(scale=1.04, wide=1.04))

    def part(obj, bone_name):
        skin_rigid(obj, armature, bone_name)

    # ── HEAD: AUTHENTIC GOKU FACE & PURPLE SPIKED HAIR ──────────────────
    face = create_face_plate("Goku_FacePlate", (0, -2.5, 168), (8.5, 5.5, 10.0), "face_goku.png")
    part(face, "head")

    skull = uv_part("Goku_Skull", (0, 2.5, 169), (8.6, 8.0, 10.0), skin_toned)
    part(skull, "head")

    # Iconic 3 Front Forehead Bangs (framing forehead above the eyes so face is clearly visible)
    bang_center = beveled_part("Goku_Bang_Center", (0, -7.5, 175.5), (2.0, 2.5, 3.8), hair_purple, bevel=0.4,
                              rotation=(math.radians(18), 0, 0))
    part(bang_center, "head")
    bang_left = beveled_part("Goku_Bang_L", (-5.2, -6.8, 175.0), (1.8, 2.2, 3.6), hair_purple, bevel=0.4,
                             rotation=(math.radians(16), math.radians(-18), math.radians(12)))
    part(bang_left, "head")
    bang_right = beveled_part("Goku_Bang_R", (5.2, -6.8, 175.0), (1.8, 2.2, 3.6), hair_purple, bevel=0.4,
                              rotation=(math.radians(16), math.radians(18), math.radians(-12)))
    part(bang_right, "head")

    # Iconic Massive Sweeping Goku Spikes (Left & Right Fanning Tufts)
    spike_l1 = beveled_part("Goku_Spike_L1", (-14.0, 1.0, 184.0), (4.5, 4.2, 12.0), hair_purple, bevel=0.8, subsurf=True,
                            rotation=(math.radians(-10), math.radians(-38), math.radians(25)))
    part(spike_l1, "head")
    spike_l2 = beveled_part("Goku_Spike_L2", (-18.0, 3.0, 173.0), (4.0, 4.5, 13.5), hair_purple, bevel=0.8, subsurf=True,
                            rotation=(math.radians(-15), math.radians(-52), math.radians(12)))
    part(spike_l2, "head")
    spike_l3 = beveled_part("Goku_Spike_L3", (-15.0, 5.0, 162.0), (3.6, 4.0, 11.5), hair_purple, bevel=0.7, subsurf=True,
                            rotation=(math.radians(-22), math.radians(-44), math.radians(-15)))
    part(spike_l3, "head")

    spike_r1 = beveled_part("Goku_Spike_R1", (14.0, 1.0, 185.0), (4.5, 4.2, 12.0), hair_purple, bevel=0.8, subsurf=True,
                            rotation=(math.radians(-10), math.radians(38), math.radians(-25)))
    part(spike_r1, "head")
    spike_r2 = beveled_part("Goku_Spike_R2", (18.0, 3.0, 174.0), (4.0, 4.5, 13.5), hair_purple, bevel=0.8, subsurf=True,
                            rotation=(math.radians(-15), math.radians(52), math.radians(-12)))
    part(spike_r2, "head")

    spike_top = beveled_part("Goku_Spike_Top", (0, 3.5, 194.0), (4.8, 4.5, 14.0), hair_purple, bevel=0.8, subsurf=True,
                             rotation=(math.radians(-12), 0, 0))
    part(spike_top, "head")
    spike_top_l = beveled_part("Goku_Spike_TopL", (-6.5, 4.0, 190.0), (4.2, 4.0, 12.5), hair_purple, bevel=0.7, subsurf=True,
                               rotation=(math.radians(-15), math.radians(-18), math.radians(12)))
    part(spike_top_l, "head")
    spike_top_r = beveled_part("Goku_Spike_TopR", (6.5, 4.0, 190.0), (4.2, 4.0, 12.5), hair_purple, bevel=0.7, subsurf=True,
                               rotation=(math.radians(-15), math.radians(18), math.radians(-12)))
    part(spike_top_r, "head")

    # ── NECK & GI COLLAR ────────────────────────────────────────────────
    neck = cylinder_between("Goku_Neck", (0, 0, 153), (0, 0, 165), 5.5, skin_toned)
    smart_uv(neck); part(neck, "neck")

    # ── TORSO: TURTLE GI WITH V-NECK & NAVY UNDERSHIRT ──────────────────
    undershirt = beveled_part("Goku_Undershirt", (0, 0, 135), (14.0, 9.5, 15.0), navy_blue, bevel=1.8, subsurf=True)
    part(undershirt, "spine_02")

    gi_chest = beveled_part("Goku_Gi_Chest", (0, 0.5, 134), (18.5, 11.5, 20.0), gi_orange, bevel=2.4, subsurf=True)
    part(gi_chest, "spine_02")

    lapel_l = beveled_part("Goku_Lapel_L", (-5.5, -11.0, 140.0), (4.5, 1.8, 14.0), gi_orange, bevel=0.4,
                           rotation=(math.radians(12), math.radians(-18), math.radians(15)))
    part(lapel_l, "spine_02")
    lapel_r = beveled_part("Goku_Lapel_R", (5.5, -11.0, 140.0), (4.5, 1.8, 14.0), gi_orange, bevel=0.4,
                           rotation=(math.radians(12), math.radians(18), math.radians(-15)))
    part(lapel_r, "spine_02")

    kanji_badge = beveled_part("Goku_Kanji_Badge", (-7.5, -11.8, 141.0), (2.8, 0.6, 2.8), gold_trim, bevel=0.2)
    part(kanji_badge, "spine_02")

    gi_ab = beveled_part("Goku_Gi_Ab", (0, 0, 112), (15.5, 9.5, 14.0), gi_orange, bevel=2.0, subsurf=True)
    part(gi_ab, "spine_01")

    belt = beveled_part("Goku_Belt_Main", (0, 0, 96), (16.8, 10.2, 5.5), navy_blue, bevel=1.2, subsurf=True)
    part(belt, "pelvis")
    belt_knot = beveled_part("Goku_Belt_Knot", (-14.0, -4.5, 95.0), (3.5, 3.2, 4.0), navy_blue, bevel=0.6)
    part(belt_knot, "pelvis")
    sash_tail1 = beveled_part("Goku_Sash_Tail1", (-14.5, -5.0, 83.0), (2.2, 1.5, 12.0), navy_blue, bevel=0.3,
                              rotation=(math.radians(8), 0, math.radians(-10)))
    part(sash_tail1, "pelvis")
    sash_tail2 = beveled_part("Goku_Sash_Tail2", (-13.0, -4.5, 80.0), (2.0, 1.4, 14.0), navy_blue, bevel=0.3,
                              rotation=(math.radians(12), 0, math.radians(8)))
    part(sash_tail2, "pelvis")

    # ── ARMS: TONED MUSCULAR ANIME ARMS & NAVY WRISTBANDS ───────────────
    for side, sfx, ubone, lbone, hbone in (
            (1, "L", "upperarm_l", "lowerarm_l", "hand_l"),
            (-1, "R", "upperarm_r", "lowerarm_r", "hand_r")):
        sw = side
        ux, lx, hx = sw * 48, sw * 74, sw * 88

        cuff = beveled_part(f"Goku_Gi_Cuff_{sfx}", (sw * 34, 0, 143), (6.5, 9.0, 6.0), gi_orange, bevel=1.0, subsurf=True)
        part(cuff, ubone)

        bicep = cylinder_between(f"Goku_UpperArm_{sfx}", (sw * 34, 0, 142), (ux, 0, 128), 7.5, skin_toned)
        smart_uv(bicep); part(bicep, ubone)

        elbow = beveled_part(f"Goku_Elbow_{sfx}", (ux, 0, 128), (7.0, 7.0, 6.0), skin_toned, bevel=1.2, subsurf=True)
        part(elbow, ubone)

        forearm = cylinder_between(f"Goku_LowerArm_{sfx}", (ux, 0, 126), (lx, 0, 110), 6.8, skin_toned)
        smart_uv(forearm); part(forearm, lbone)

        wristband = beveled_part(f"Goku_Wristband_{sfx}", (sw * 64, 0, 114), (6.2, 6.2, 10.5), navy_blue, bevel=0.8, subsurf=True)
        part(wristband, lbone)
        wrist_trim = beveled_part(f"Goku_WristTrim_{sfx}", (sw * 64, 0, 119), (6.5, 6.5, 1.4), gold_trim, bevel=0.2)
        part(wrist_trim, lbone)

        hand = beveled_part(f"Goku_Hand_{sfx}", (hx, 0, 102), (7.2, 6.0, 9.5), skin_toned, bevel=1.4, subsurf=True)
        part(hand, hbone)

    # ── POWER POLE (NYOI-BŌ) ON RIGHT HAND ──────────────────────────────
    pole_shaft = cylinder_between("Goku_Pole_Shaft", (-88, 0, 30), (-88, 0, 170), 2.2, staff_red, vertices=12)
    smart_uv(pole_shaft); part(pole_shaft, "hand_r")
    pole_cap_top = beveled_part("Goku_Pole_CapTop", (-88, 0, 172), (2.8, 2.8, 3.0), gold_trim, bevel=0.5)
    part(pole_cap_top, "hand_r")
    pole_cap_bot = beveled_part("Goku_Pole_CapBot", (-88, 0, 28), (2.8, 2.8, 3.0), gold_trim, bevel=0.5)
    part(pole_cap_bot, "hand_r")
    ki_ball = beveled_part("Goku_Ki_Aura", (-88, 0, 176), (2.2, 2.2, 2.2), ki_glow, bevel=0.4)
    part(ki_ball, "hand_r")

    # ── LEGS: BAGGY MARTIAL ARTS PANTS & MARTIAL ARTS BOOTS ─────────────
    for side, sfx, thbone, cfbone, ftbone in (
            (1, "L", "thigh_l", "calf_l", "foot_l"),
            (-1, "R", "thigh_r", "calf_r", "foot_r")):
        sw = side

        thigh = cylinder_between(f"Goku_Pants_Thigh_{sfx}", (sw * 21, 0, 88), (sw * 23, 0, 54), 10.5, gi_orange)
        smart_uv(thigh); part(thigh, thbone)
        thigh_fold = beveled_part(f"Goku_PantsFold_{sfx}", (sw * 22, -2.5, 70), (10.0, 9.5, 12.0), gi_orange, bevel=2.0, subsurf=True)
        part(thigh_fold, thbone)

        knee = beveled_part(f"Goku_Knee_{sfx}", (sw * 23, -2.0, 54), (9.0, 8.5, 7.5), gi_orange, bevel=1.5, subsurf=True)
        part(knee, cfbone)

        calf = cylinder_between(f"Goku_Pants_Calf_{sfx}", (sw * 23, 0, 52), (sw * 21, 0, 22), 9.2, gi_orange)
        smart_uv(calf); part(calf, cfbone)

        boot_shaft = cylinder_between(f"Goku_Boot_Shaft_{sfx}", (sw * 21, 0, 24), (sw * 21, 0, 10), 8.0, navy_blue)
        smart_uv(boot_shaft); part(boot_shaft, cfbone)
        boot_lace = beveled_part(f"Goku_Boot_Lace_{sfx}", (sw * 21, -7.5, 18), (2.2, 1.2, 9.0), staff_red, bevel=0.2)
        part(boot_lace, cfbone)

        foot = beveled_part(f"Goku_Foot_{sfx}", (sw * 20, -6, 7), (8.5, 17.5, 6.0), navy_blue, bevel=1.8, subsurf=True)
        part(foot, ftbone)
        sole = beveled_part(f"Goku_Sole_{sfx}", (sw * 20, -6, 1.8), (9.0, 18.0, 1.8), hair_purple, bevel=0.3)
        part(sole, ftbone)

    add_combat_actions(armature, "Goku", heavy=False)
    setup_hero_camera(120, 280, lens=48)
    add_preview_lights(120, energy=5500)
    render_preview("goku_model_preview.png")
    save_and_export(armature, "PFU_SonGoku.blend", "PFU_SonGoku.fbx")
    print("GOKU_GEN_OK")


if __name__ == "__main__":
    import sys
    if "--only-ninja" in sys.argv:
        build_ninja()
    elif "--only-golem" in sys.argv:
        build_golem()
    elif "--only-valkyrie" in sys.argv:
        build_valkyrie()
    elif "--only-dragon" in sys.argv:
        build_dragon()
    elif "--only-anubis" in sys.argv:
        build_anubis()
    elif "--only-specter" in sys.argv:
        build_specter()
    elif "--only-phoenix" in sys.argv:
        build_phoenix()
    elif "--only-goku" in sys.argv:
        build_goku()
    else:
        build_ninja()
        build_golem()
        build_valkyrie()
        build_dragon()
        build_anubis()
        build_specter()
        build_phoenix()
        build_goku()
    print("ALL_PFU_FIGHTERS_READY")
