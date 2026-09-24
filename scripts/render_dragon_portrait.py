import bpy, math
from mathutils import Vector

ROOT = r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate"
blend_path = ROOT + r"\art\blender\PFU_CyberDragon.blend"
out_final = ROOT + r"\godot\assets\textures\ui\portrait_dragon.png"

bpy.ops.wm.open_mainfile(filepath=blend_path)
sc = bpy.context.scene
sc.render.resolution_x = 512
sc.render.resolution_y = 512
sc.render.film_transparent = False
sc.world.use_nodes = True
bg = sc.world.node_tree.nodes.get("Background")
if bg:
    bg.inputs["Color"].default_value = (0.02, 0.02, 0.04, 1.0)
    bg.inputs["Strength"].default_value = 0.8

# Camera looking at upper body bust & horned helm
bpy.ops.object.camera_add(location=(16, -95, 172))
cam = bpy.context.object
target = Vector((0, -4, 166))
direction = target - cam.location
cam.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()
cam.data.lens = 65
sc.camera = cam

# Extra portrait lighting
bpy.ops.object.light_add(type="AREA", location=(-45, -65, 195))
key = bpy.context.object
key.data.energy = 2400
key.data.color = (1.0, 0.85, 0.65)
key.data.size = 55

bpy.ops.object.light_add(type="AREA", location=(45, 25, 180))
rim = bpy.context.object
rim.data.energy = 3200
rim.data.color = (1.0, 0.35, 0.05) # Fiery vermilion rim light
rim.data.size = 50

sc.render.filepath = out_final
bpy.ops.render.render(write_still=True)
print("DRAGON_PORTRAIT_RENDERED")
