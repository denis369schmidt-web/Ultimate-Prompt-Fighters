import bpy
import shutil
from pathlib import Path

ROOT = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate")
MODELS_DIR = ROOT / "godot/assets/models"
MODELS_DIR.mkdir(parents=True, exist_ok=True)

# 1. Copy already-GLB files directly
glb_sources = [
    ("art/characters/golden_golem.glb", "golden_golem.glb"),
    ("art/characters/tripo_fran_statue/tripo_fran_statue.glb", "tripo_fran_statue.glb"),
    ("art/characters/tripo_fantasy_female/tripo_fantasy_female.glb", "tripo_fantasy_female.glb"),
    ("art/characters/tripo_nyx_harvester/tripo_nyx_harvester.glb", "tripo_nyx_harvester.glb"),
    ("art/characters/tripo_cat_girl/tripo_cat_girl.glb", "tripo_cat_girl.glb"),
    ("art/characters/tripo_wooden_forest/tripo_wooden_forest.glb", "tripo_wooden_forest.glb"),
]

for src_rel, dst_name in glb_sources:
    src = ROOT / src_rel
    if src.exists():
        dst = MODELS_DIR / dst_name
        shutil.copy2(src, dst)
        print(f"[COPIED GLB] {src_rel} -> {dst_name} ({dst.stat().st_size} bytes)")

# 2. Convert FBX files to GLB using Blender
fbx_sources = [
    ("art/characters/golden_golem/golden_golem.fbx", "golden_golem_rigged.glb"),
    ("art/characters/tripo_dragon_blue/tripo_dragon_blue.fbx", "tripo_dragon_blue.glb"),
    ("art/characters/tripo_white_sci/tripo_white_sci.fbx", "tripo_white_sci.glb"),
    ("art/characters/tripo_skeleton_dog/tripo_skeleton_dog.fbx", "tripo_skeleton_dog.glb"),
    ("art/characters/tripo_quadruped_tree/tripo_quadruped_tree.fbx", "tripo_quadruped_tree.glb"),
    ("art/characters/tripo_nine_tailed/tripo_nine_tailed.fbx", "tripo_nine_tailed.glb"),
]

for src_rel, dst_name in fbx_sources:
    src = ROOT / src_rel
    if not src.exists():
        continue
    dst = MODELS_DIR / dst_name
    print(f"[CONVERTING FBX] {src_rel} -> {dst_name}...")
    
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.fbx(filepath=str(src))
    
    # Ensure correct forward axis and scale
    bpy.ops.export_scene.gltf(
        filepath=str(dst),
        export_format='GLB',
        use_selection=False,
        export_materials='EXPORT',
        export_animations=True,
        export_skins=True,
        export_morph=True
    )
    print(f"  [SAVED] {dst_name} ({dst.stat().st_size} bytes)")

print("\nALL MODELS CONVERTED AND DEPLOYED TO godot/assets/models/!")
