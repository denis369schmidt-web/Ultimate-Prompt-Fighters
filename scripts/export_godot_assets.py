"""Convert existing editable Blender assets to Godot glTF without modifying sources."""
from pathlib import Path
import bpy

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "godot" / "assets" / "models"
OUT.mkdir(parents=True, exist_ok=True)

for source, target in (("PFU_ShadowNinja", "ninja"), ("PFU_LavaGolem", "golem"), ("PFU_MoeValkyrie", "valkyrie"), ("PFU_CyberDragon", "dragon"), ("PFU_CyberAnubis", "anubis"), ("PFU_VoidSpecter", "specter"), ("PFU_PhoenixEmpress", "phoenix"), ("PFU_BrokenMoonkeep", "arena")):
    bpy.ops.wm.open_mainfile(filepath=str(ROOT / "art" / "blender" / (source + ".blend")))
    for obj in list(bpy.context.scene.objects):
        if obj.type in {"LIGHT", "CAMERA"}:
            bpy.data.objects.remove(obj, do_unlink=True)
    for arm in [o for o in bpy.context.scene.objects if o.type == "ARMATURE"]:
        # Every action starts from a fully keyed neutral pose: no pose leakage across clips.
        actions = list(bpy.data.actions)
        for action in actions:
            arm.animation_data.action = action
            existing = {fc.data_path for fc in action.fcurves}
            for bone in arm.pose.bones:
                bone.rotation_mode = "XYZ"
                for prop in ("rotation_euler", "location"):
                    path = bone.path_from_id(prop)
                    if path not in existing:
                        setattr(bone, prop, (0, 0, 0))
                        bone.keyframe_insert(data_path=prop, frame=1, group=bone.name)
        arm.animation_data.action = next(a for a in actions if a.name.endswith("Idle"))
    bpy.context.scene.frame_set(1)
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.export_scene.gltf(filepath=str(OUT / (target + ".glb")), export_format="GLB",
        use_selection=True, export_animations=target != "arena", export_animation_mode="ACTIONS",
        export_frame_range=False, export_yup=True, export_cameras=False, export_lights=False)
    print("PFU_GLB_EXPORTED", target)
