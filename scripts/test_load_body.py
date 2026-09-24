import bpy
from pathlib import Path

p = r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate\tools\human_base_meshes\human-base-meshes-bundle-v1.4.1\human_base_meshes_bundle.blend"
preview_dir = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate\art\blender\previews")
preview_dir.mkdir(parents=True, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)

with bpy.data.libraries.load(p, link=False) as (df, dt):
    dt.meshes = [m for m in df.meshes if m in ("GEO-body_male_stylized", "Eye - Stylized", "GEO-head_stylized.eye.L", "GEO-head_stylized.eye.R")]

body_mesh = [m for m in dt.meshes if m.name == "GEO-body_male_stylized"][0]
body_obj = bpy.data.objects.new("Base_Body", body_mesh)
bpy.context.scene.collection.objects.link(body_obj)

print("UV LAYERS:", [uv.name for uv in body_mesh.uv_layers])

# Neutral grey studio material
mat = bpy.data.materials.new("NeutralGrey")
mat.use_nodes = True
bsdf = mat.node_tree.nodes.get("Principled BSDF")
bsdf.inputs["Base Color"].default_value = (0.5, 0.5, 0.5, 1.0)
bsdf.inputs["Roughness"].default_value = 0.4
body_obj.data.materials.append(mat)

# Studio lighting
key = bpy.data.lights.new("Key", "AREA")
key.energy = 500
key.size = 2.0
key_obj = bpy.data.objects.new("Key", key)
key_obj.location = (1.5, -2.5, 2.5)
bpy.context.scene.collection.objects.link(key_obj)

fill = bpy.data.lights.new("Fill", "AREA")
fill.energy = 250
fill.size = 2.0
fill_obj = bpy.data.objects.new("Fill", fill)
fill_obj.location = (-2.0, -2.0, 1.5)
bpy.context.scene.collection.objects.link(fill_obj)

rim = bpy.data.lights.new("Rim", "AREA")
rim.energy = 400
rim.size = 2.0
rim_obj = bpy.data.objects.new("Rim", rim)
rim_obj.location = (0.0, 2.5, 2.2)
bpy.context.scene.collection.objects.link(rim_obj)

# Camera
cam_data = bpy.data.cameras.new("Cam")
cam_data.lens = 50
cam_obj = bpy.data.objects.new("Cam", cam_data)
cam_obj.location = (0, -3.2, 1.1)
cam_obj.rotation_euler = (1.5708, 0, 0)
bpy.context.scene.collection.objects.link(cam_obj)
bpy.context.scene.camera = cam_obj

bpy.context.scene.render.resolution_x = 1024
bpy.context.scene.render.resolution_y = 1024
bpy.context.scene.render.filepath = str(preview_dir / "base_mesh_neutral.png")
bpy.ops.render.render(write_still=True)
print("BASE_MESH_RENDERED")
