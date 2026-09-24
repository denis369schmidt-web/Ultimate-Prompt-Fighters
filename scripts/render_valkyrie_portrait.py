import bpy, math
from mathutils import Vector

ROOT = r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate"
blend_path = ROOT + r"\art\blender\PFU_MoeValkyrie.blend"
out_raw = ROOT + r"\godot\assets\textures\ui\portrait_valkyrie_raw.png"
out_final = ROOT + r"\godot\assets\textures\ui\portrait_valkyrie.png"

bpy.ops.wm.open_mainfile(filepath=blend_path)
sc = bpy.context.scene
sc.render.resolution_x = 512
sc.render.resolution_y = 512
sc.render.film_transparent = False
sc.world.use_nodes = True
bg = sc.world.node_tree.nodes.get("Background")
if bg:
    bg.inputs["Color"].default_value = (0.02, 0.04, 0.08, 1.0)
    bg.inputs["Strength"].default_value = 0.8

# Camera looking at upper body bust
bpy.ops.object.camera_add(location=(14, -85, 152))
cam = bpy.context.object
target = Vector((0, 0, 146))
direction = target - cam.location
cam.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()
cam.data.lens = 70
sc.camera = cam

# Extra portrait lighting
bpy.ops.object.light_add(type="AREA", location=(-40, -60, 180))
key = bpy.context.object
key.data.energy = 2200
key.data.color = (1.0, 0.95, 0.85)
key.data.size = 60

bpy.ops.object.light_add(type="AREA", location=(40, 20, 170))
rim = bpy.context.object
rim.data.energy = 2800
rim.data.color = (0.3, 0.7, 1.0)
rim.data.size = 50

sc.render.filepath = out_raw
bpy.ops.render.render(write_still=True)
print("RAW_PORTRAIT_RENDERED")
