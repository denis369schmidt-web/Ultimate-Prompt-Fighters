"""Shared deterministic Blender helpers for Prompt Fighter Ultimate."""

from __future__ import annotations

import math
from pathlib import Path

import bpy
from mathutils import Vector


PROJECT_ROOT = Path(__file__).resolve().parents[1]
BLEND_ROOT = PROJECT_ROOT / "art" / "blender"
EXPORT_ROOT = PROJECT_ROOT / "exports"
PREVIEW_ROOT = BLEND_ROOT / "previews"


def ensure_output_dirs() -> None:
    for path in (BLEND_ROOT, EXPORT_ROOT, PREVIEW_ROOT):
        path.mkdir(parents=True, exist_ok=True)


def reset_scene() -> None:
    bpy.ops.object.mode_set(mode="OBJECT") if bpy.context.object and bpy.context.object.mode != "OBJECT" else None
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for action in list(bpy.data.actions):
        bpy.data.actions.remove(action)
    for datablocks in (bpy.data.meshes, bpy.data.curves, bpy.data.armatures, bpy.data.materials, bpy.data.cameras, bpy.data.lights):
        for datablock in list(datablocks):
            if datablock.users == 0:
                datablocks.remove(datablock)
    scene = bpy.context.scene
    scene.unit_settings.system = "METRIC"
    scene.unit_settings.scale_length = 0.01
    scene.render.engine = "BLENDER_EEVEE_NEXT"
    scene.render.resolution_x = 1280
    scene.render.resolution_y = 720
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "PNG"
    scene.render.film_transparent = False
    scene.world.use_nodes = True
    background = scene.world.node_tree.nodes.get("Background")
    background.inputs["Color"].default_value = (0.025, 0.055, 0.12, 1.0)
    background.inputs["Strength"].default_value = 0.72
    scene.view_settings.look = "AgX - Medium High Contrast"
    scene.view_settings.exposure = 0.65


def material(name: str, base_color, metallic=0.0, roughness=0.55, emission=None, emission_strength=0.0):
    """Advanced PBR material with auto-SSS, clearcoat, anisotropy and noise-bump normals."""
    mat = bpy.data.materials.get(name) or bpy.data.materials.new(name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    links = mat.node_tree.links

    # Full node rebuild for clean advanced graph
    nodes.clear()
    out  = nodes.new("ShaderNodeOutputMaterial"); out.location  = (600, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (200, 0)
    links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])

    bsdf.inputs["Base Color"].default_value = (*base_color, 1.0)
    bsdf.inputs["Metallic"].default_value   = metallic
    bsdf.inputs["Roughness"].default_value  = roughness
    bsdf.inputs["IOR"].default_value        = 1.52

    # Emission
    if emission is not None:
        for ekey in ("Emission Color", "Emission"):
            if ekey in bsdf.inputs:
                bsdf.inputs[ekey].default_value = (*emission, 1.0); break
        if "Emission Strength" in bsdf.inputs:
            bsdf.inputs["Emission Strength"].default_value = emission_strength

    # Auto-SSS: warm skin tones (r > 0.35, low metallic, medium roughness)
    r, g, b = base_color[0], base_color[1], base_color[2]
    is_skin = (r > 0.35 and r > g * 1.15 and metallic < 0.1 and roughness > 0.35)
    if is_skin:
        sss_val = 0.30
        sss_rad = (1.0, 0.35, 0.12)
        for sskey in ("Subsurface Weight", "Subsurface"):
            if sskey in bsdf.inputs: bsdf.inputs[sskey].default_value = sss_val; break
        if "Subsurface Radius" in bsdf.inputs:
            try: bsdf.inputs["Subsurface Radius"].default_value = sss_rad
            except Exception: pass

    # Auto-Clearcoat: metallic surfaces get clearcoat lacquer
    if metallic > 0.4:
        cc_val = min(metallic * 0.7, 0.85)
        for cckey in ("Coat Weight", "Clearcoat"):
            if cckey in bsdf.inputs: bsdf.inputs[cckey].default_value = cc_val; break
        for ccrkey in ("Coat Roughness", "Clearcoat Roughness"):
            if ccrkey in bsdf.inputs: bsdf.inputs[ccrkey].default_value = roughness * 0.4; break
        # Anisotropy for brushed metal
        if "Anisotropic" in bsdf.inputs:
            bsdf.inputs["Anisotropic"].default_value = 0.55

    # Procedural noise bump normal (adds micro-surface detail to every material)
    tc    = nodes.new("ShaderNodeTexCoord"); tc.location    = (-600, -250)
    noise = nodes.new("ShaderNodeTexNoise"); noise.location = (-380, -250)
    noise.inputs["Scale"].default_value     = 22.0
    noise.inputs["Detail"].default_value    = 14.0
    noise.inputs["Roughness"].default_value = 0.60
    noise.inputs["Distortion"].default_value = 0.15
    bump  = nodes.new("ShaderNodeBump");     bump.location  = (-120, -250)
    # Strength: subtle for metals/emissives, visible for cloth/armour
    bump_str = 0.08 if (metallic > 0.5 or emission_strength > 1.0) else 0.28
    bump.inputs["Strength"].default_value  = bump_str
    bump.inputs["Distance"].default_value  = 0.6
    links.new(tc.outputs["UV"],       noise.inputs["Vector"])
    links.new(noise.outputs["Fac"],   bump.inputs["Height"])
    links.new(bump.outputs["Normal"], bsdf.inputs["Normal"])

    return mat


def assign_material(obj, mat) -> None:
    if obj.data and hasattr(obj.data, "materials"):
        obj.data.materials.append(mat)


def smooth(obj) -> None:
    if hasattr(obj.data, "polygons"):
        for polygon in obj.data.polygons:
            polygon.use_smooth = True


def apply_transform(obj) -> None:
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.select_set(False)


def uv_part(name, location, scale, mat, segments=16, rings=10):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segments, ring_count=rings, location=location)
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    apply_transform(obj)
    smooth(obj)
    assign_material(obj, mat)
    return obj


def ico_part(name, location, scale, mat, subdivisions=2):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=subdivisions, radius=1.0, location=location)
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    apply_transform(obj)
    smooth(obj)
    assign_material(obj, mat)
    return obj


def beveled_box(name, location, scale, mat, bevel=2.0, rotation=(0.0, 0.0, 0.0)):
    bpy.ops.mesh.primitive_cube_add(size=2.0, location=location, rotation=rotation)
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    apply_transform(obj)
    modifier = obj.modifiers.new("EdgeBevel", "BEVEL")
    modifier.width = bevel
    modifier.segments = 3
    modifier.profile = 0.7
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.modifier_apply(modifier=modifier.name)
    # Add SubSurf for smoother geometry
    sub = obj.modifiers.new("SubSurf", "SUBSURF")
    sub.levels = 1
    sub.render_levels = 1
    bpy.ops.object.modifier_apply(modifier=sub.name)
    smooth(obj)
    obj.select_set(False)
    assign_material(obj, mat)
    return obj


def cylinder_between(name, start, end, radius, mat, vertices=20):
    start_v = Vector(start)
    end_v = Vector(end)
    delta = end_v - start_v
    midpoint = (start_v + end_v) * 0.5
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=delta.length, location=midpoint)
    obj = bpy.context.object
    obj.name = name
    obj.rotation_mode = "QUATERNION"
    obj.rotation_quaternion = Vector((0, 0, 1)).rotation_difference(delta.normalized())
    obj.rotation_mode = "XYZ"
    apply_transform(obj)
    smooth(obj)
    assign_material(obj, mat)
    return obj


def blade_mesh(name, location, mirror, mat, glow_mat):
    side = float(mirror)
    vertices = [
        (-2, -1.5, 0), (2, -1.5, 0), (-2, 1.5, 0), (2, 1.5, 0),
        (-1, -1.0, -34), (1, -1.0, -34), (-1, 1.0, -34), (1, 1.0, -34),
        (0, -0.5, -43), (0, 0.5, -43),
    ]
    vertices = [(x * side + location[0], y + location[1], z + location[2]) for x, y, z in vertices]
    faces = [
        (0, 1, 3, 2), (4, 6, 7, 5), (0, 4, 5, 1), (2, 3, 7, 6),
        (0, 2, 6, 4), (1, 5, 7, 3), (4, 6, 9, 8), (5, 8, 9, 7),
    ]
    mesh = bpy.data.meshes.new(name + "Mesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    assign_material(obj, mat)
    assign_material(obj, glow_mat)
    for polygon in obj.data.polygons:
        if polygon.center.z < location[2] - 20:
            polygon.material_index = 1
    return obj


def create_armature(name: str, bones: dict[str, tuple[tuple[float, float, float], tuple[float, float, float], str | None]]):
    arm_data = bpy.data.armatures.new(name + "Data")
    armature = bpy.data.objects.new(name, arm_data)
    bpy.context.collection.objects.link(armature)
    bpy.context.view_layer.objects.active = armature
    armature.select_set(True)
    bpy.ops.object.mode_set(mode="EDIT")
    created = {}
    for bone_name, (head, tail, parent_name) in bones.items():
        bone = arm_data.edit_bones.new(bone_name)
        bone.head = head
        bone.tail = tail
        created[bone_name] = bone
    for bone_name, (_, _, parent_name) in bones.items():
        if parent_name:
            created[bone_name].parent = created[parent_name]
    bpy.ops.object.mode_set(mode="OBJECT")
    armature.select_set(False)
    armature.show_in_front = True
    return armature


def skin_rigid(obj, armature, bone_name: str) -> None:
    group = obj.vertex_groups.new(name=bone_name)
    group.add(list(range(len(obj.data.vertices))), 1.0, "REPLACE")
    modifier = obj.modifiers.new("PFU_Armature", "ARMATURE")
    modifier.object = armature
    obj.parent = armature


def add_action(armature, name: str, length: int, keyed_poses: list[tuple[int, dict]]):
    action = bpy.data.actions.new(name=name)
    action.use_fake_user = True
    armature.animation_data_create()
    armature.animation_data.action = action
    for pose_bone in armature.pose.bones:
        pose_bone.rotation_mode = "XYZ"
        pose_bone.rotation_euler = (0.0, 0.0, 0.0)
        pose_bone.location = (0.0, 0.0, 0.0)
    for frame, changes in keyed_poses:
        for bone_name, transform in changes.items():
            pose_bone = armature.pose.bones.get(bone_name)
            if not pose_bone:
                continue
            if "rot" in transform:
                pose_bone.rotation_euler = tuple(math.radians(value) for value in transform["rot"])
                pose_bone.keyframe_insert(data_path="rotation_euler", frame=frame, group=bone_name)
            if "loc" in transform:
                pose_bone.location = transform["loc"]
                pose_bone.keyframe_insert(data_path="location", frame=frame, group=bone_name)
    action.frame_range = (1, length)
    for fcurve in action.fcurves:
        for point in fcurve.keyframe_points:
            point.interpolation = "BEZIER"
    return action


def save_and_export(armature, blend_name: str, fbx_name: str) -> None:
    ensure_output_dirs()
    bpy.context.scene.frame_set(1)
    bpy.ops.wm.save_as_mainfile(filepath=str(BLEND_ROOT / blend_name))
    bpy.ops.object.select_all(action="DESELECT")
    armature.select_set(True)
    for obj in bpy.context.scene.objects:
        if obj.parent == armature or any(mod.type == "ARMATURE" and mod.object == armature for mod in obj.modifiers):
            obj.select_set(True)
    bpy.context.view_layer.objects.active = armature
    bpy.ops.export_scene.fbx(
        filepath=str(EXPORT_ROOT / fbx_name),
        use_selection=True,
        object_types={"ARMATURE", "MESH"},
        apply_unit_scale=True,
        apply_scale_options="FBX_SCALE_ALL",
        axis_forward="-Z",
        axis_up="Y",
        add_leaf_bones=False,
        bake_anim=True,
        bake_anim_use_all_actions=True,
        bake_anim_simplify_factor=0.0,
        path_mode="AUTO",
    )


def setup_preview_camera(target_z: float, distance: float, lens=52):
    bpy.ops.object.camera_add(location=(distance, -distance * 1.8, target_z))
    camera = bpy.context.object
    camera.name = "PFU_PreviewCamera"
    direction = Vector((0.0, 0.0, target_z)) - camera.location
    camera.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()
    camera.data.lens = lens
    bpy.context.scene.camera = camera
    return camera


def add_preview_lights(target_z: float, energy=3200):
    for name, location, color, power in (
        ("Key_Cool", (-220, -280, target_z + 120), (0.18, 0.45, 1.0), energy),
        ("Rim_Warm", (240, 80, target_z + 40), (1.0, 0.18, 0.04), energy * 0.8),
        ("Fill", (0, -80, target_z + 260), (0.25, 0.35, 0.55), energy * 0.55),
    ):
        bpy.ops.object.light_add(type="AREA", location=location)
        light = bpy.context.object
        light.name = name
        light.data.energy = power
        light.data.color = color
        light.data.shape = "DISK"
        light.data.size = 180
        direction = Vector((0.0, 0.0, target_z)) - light.location
        light.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()
    bpy.ops.object.light_add(type="SUN", location=(0, -100, target_z + 200))
    sun = bpy.context.object
    sun.name = "Preview_Sun"
    sun.data.energy = 2.4
    sun.data.color = (0.55, 0.68, 1.0)
    sun.rotation_euler = (math.radians(24), math.radians(-18), math.radians(-28))


def render_preview(filename: str) -> None:
    ensure_output_dirs()
    scene = bpy.context.scene
    scene.render.filepath = str(PREVIEW_ROOT / filename)
    bpy.ops.render.render(write_still=True)
