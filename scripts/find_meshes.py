import bpy

p = r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate\tools\human_base_meshes\human-base-meshes-bundle-v1.4.1\human_base_meshes_bundle.blend"

with bpy.data.libraries.load(p) as (df, dt):
    print("TOTAL MESHES:", len(df.meshes))
    for m in sorted(df.meshes):
        if any(w in m.lower() for w in ("body", "head", "male", "stylized")):
            print("  MESH:", m)
