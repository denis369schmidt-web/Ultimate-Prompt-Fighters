"""
Test script: Build an authentic anime head with UV-mapped face texture in Blender and render a close-up preview.
"""
import math
import sys
from pathlib import Path
import bpy
from mathutils import Vector

ROOT = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate")
sys.path.insert(0, str(ROOT / "scripts"))
from blender_common import (
    reset_scene, material, smooth, apply_transform, assign_material,
    setup_preview_camera, add_preview_lights, render_preview, PREVIEW_ROOT
)

def create_face_plate(name, center, size, texture_path):
    """
    Creates a curved 3D face plate mesh with chin taper and nose curve,
    with exact UV mapping for the face texture.
    """
    cx, cy, cz = center
    sx, sy, sz = size # half-extents, e.g. (9.0, 7.0, 11.0)

    # Build a grid of vertices curved around the face
    cols = 9
    rows = 11
    verts = []
    uvs = []

    for r in range(rows):
        v = r / (rows - 1) # 0 (chin) to 1 (forehead)
        # z from bottom to top
        z = cz - sz + v * (2.0 * sz)
        # chin taper: narrower at bottom
        taper_x = 0.65 + 0.35 * math.sin(v * math.pi * 0.5)
        # cheekbone fullness around mid-height (v ~ 0.4 - 0.6)
        cheek = 1.0 + 0.08 * math.sin(v * math.pi)

        for c in range(cols):
            u = c / (cols - 1) # 0 (left) to 1 (right)
            # angle around face from -70 deg to +70 deg
            angle = (u - 0.5) * math.radians(130.0)
            rx = sx * taper_x * cheek
            x = cx + rx * math.sin(angle)
            # curve forward in front
            depth_curve = sy * math.cos(angle)
            # slight nose protrusion around center (c=4, v=0.38)
            nose_bump = 0.0
            if abs(c - 4) <= 1 and abs(v - 0.38) < 0.12:
                nose_bump = 1.8 * (1.0 - abs(c - 4)) * (1.0 - abs(v - 0.38) / 0.12)

            y = cy - depth_curve - nose_bump
            verts.append((x, y, z))
            # UV mapping: center the face texture (u: 0.15 to 0.85, v: 0.15 to 0.85)
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
            # Face outward (-Y direction)
            faces.append((i0, i1, i2, i3))

    mesh = bpy.data.meshes.new(f"{name}_Mesh")
    mesh.from_pydata(verts, [], faces)
    mesh.update()

    # Assign UVs
    uv_layer = mesh.uv_layers.new(name="UVMap")
    for poly in mesh.polygons:
        for loop_idx in poly.loop_indices:
            vert_idx = mesh.loops[loop_idx].vertex_index
            uv_layer.data[loop_idx].uv = uvs[vert_idx]

    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    smooth(obj)

    # Create Material with Image Texture
    mat = bpy.data.materials.new(f"M_{name}")
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    links = mat.node_tree.links
    nodes.clear()

    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (600, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (200, 0)
    links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])

    tex_node = nodes.new("ShaderNodeTexImage"); tex_node.location = (-200, 0)
    if Path(texture_path).exists():
        tex_node.image = bpy.data.images.load(str(texture_path))
    links.new(tex_node.outputs["Color"], bsdf.inputs["Base Color"])

    bsdf.inputs["Roughness"].default_value = 0.45
    bsdf.inputs["Metallic"].default_value = 0.0
    for sskey in ("Subsurface Weight", "Subsurface"):
        if sskey in bsdf.inputs:
            bsdf.inputs[sskey].default_value = 0.25
            break

    assign_material(obj, mat)
    return obj

def test_render():
    reset_scene()
    face = create_face_plate(
        "Valkyrie_FacePlate",
        center=(0, -2.5, 168),
        size=(8.2, 5.5, 9.5),
        texture_path=ROOT / "godot" / "assets" / "textures" / "characters" / "face_valkyrie.png"
    )

    # Hair cap on BACK and TOP of head only
    hair_mat = material("M_TestHair", (0.96, 0.84, 0.38), metallic=0.1, roughness=0.3)
    bpy.ops.mesh.primitive_uv_sphere_add(segments=24, ring_count=16, location=(0, 3.5, 171))
    hair_cap = bpy.context.object
    hair_cap.scale = (8.8, 8.0, 9.8)
    apply_transform(hair_cap)
    smooth(hair_cap)
    assign_material(hair_cap, hair_mat)

    # Front bangs framing the forehead (above the eyes)
    bpy.ops.mesh.primitive_cube_add(size=2.0, location=(0, -7.5, 175.5), rotation=(math.radians(15), 0, 0))
    bang = bpy.context.object
    bang.scale = (7.5, 1.2, 2.2)
    apply_transform(bang)
    smooth(bang)
    assign_material(bang, hair_mat)

    # Side hair locks framing the cheeks
    for side in (-1, 1):
        bpy.ops.mesh.primitive_cube_add(size=2.0, location=(side * 8.6, -5.5, 166.0), rotation=(math.radians(8), math.radians(side * 8), math.radians(-side * 5)))
        lock = bpy.context.object
        lock.scale = (1.5, 2.0, 8.5)
        apply_transform(lock)
        smooth(lock)
        assign_material(lock, hair_mat)

    # Camera and Lights
    bpy.ops.object.camera_add(location=(0, -42, 168))
    cam = bpy.context.object
    cam.rotation_euler = (math.radians(90), 0, 0)
    cam.data.lens = 85
    bpy.context.scene.camera = cam

    # Bright key light right in front of face
    bpy.ops.object.light_add(type="AREA", location=(-15, -35, 176))
    l1 = bpy.context.object
    l1.data.energy = 8500
    l1.data.color = (1.0, 0.98, 0.94)
    l1.data.size = 25
    direction = Vector((0.0, -2.5, 168)) - l1.location
    l1.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()

    bpy.ops.object.light_add(type="AREA", location=(20, -30, 166))
    l2 = bpy.context.object
    l2.data.energy = 4500
    l2.data.color = (0.85, 0.92, 1.0)
    l2.data.size = 30
    direction = Vector((0.0, -2.5, 168)) - l2.location
    l2.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()

    # Warm rim light from behind
    bpy.ops.object.light_add(type="AREA", location=(0, 25, 185))
    l3 = bpy.context.object
    l3.data.energy = 12000
    l3.data.color = (1.0, 0.88, 0.5)

    render_preview("test_face_preview.png")
    print("TEST_FACE_RENDER_OK")

if __name__ == "__main__":
    test_render()
