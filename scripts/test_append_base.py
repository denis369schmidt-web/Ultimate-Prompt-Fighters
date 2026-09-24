import bpy
from pathlib import Path

blend_path = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate\tools\human_base_meshes\human-base-meshes-bundle-v1.4.1\human_base_meshes_bundle.blend")

bpy.ops.wm.read_factory_settings(use_empty=True)

# Append stylized_body_male
with bpy.data.libraries.load(str(blend_path), link=False) as (df, dt):
    dt.objects = [o for o in df.objects if o in ("stylized_body_male", "stylized_head", "stylized_hand", "stylized_foot")]

for obj in dt.objects:
    bpy.context.scene.collection.objects.link(obj)
    print("APPENDED:", obj.name, "DIMENSIONS:", obj.dimensions, "LOCATION:", obj.location)

bpy.ops.wm.save_as_mainfile(filepath=r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate\art\blender\test_append.blend")
print("TEST_APPEND_OK")
