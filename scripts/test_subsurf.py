import bpy

# Quick test of subsurf on beveled box
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.mesh.primitive_cube_add(size=2.0, location=(0, 0, 0))
obj = bpy.context.object
mod_bev = obj.modifiers.new("Bevel", "BEVEL")
mod_bev.width = 0.4
mod_bev.segments = 2
bpy.ops.object.modifier_apply(modifier="Bevel")

mod_sub = obj.modifiers.new("Subsurf", "SUBSURF")
mod_sub.levels = 1
bpy.ops.object.modifier_apply(modifier="Subsurf")

for poly in obj.data.polygons:
    poly.use_smooth = True

print("VERTS:", len(obj.data.vertices), "POLYS:", len(obj.data.polygons))
print("TEST_SUBSURF_OK")
