import bpy
from pathlib import Path

blend_path = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate\tools\human_base_meshes\human-base-meshes-bundle-v1.4.1\human_base_meshes_bundle.blend")

with bpy.data.libraries.load(str(blend_path)) as (df, dt):
    print("TOTAL OBJECTS:", len(df.objects))
    for name in sorted(df.objects):
        print("  OBJ:", name)
