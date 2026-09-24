import bpy

p = r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate\tools\human_base_meshes\human-base-meshes-bundle-v1.4.1\human_base_meshes_bundle.blend"

with bpy.data.libraries.load(p) as (df, dt):
    for o in sorted(df.objects):
        if any(w in o.lower() for w in ("body", "head", "ninja", "male", "torso", "arm", "leg", "geo-")) and not any(w in o.lower() for w in ("skeleton", "distal", "proximal", "meta", "cervical", "lumbar", "thoracic")):
            print("CANDIDATE:", o)
