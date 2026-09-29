import bpy
import math
from pathlib import Path

ROOT = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate")
OUT_DIR = ROOT / "godot" / "assets" / "models" / "items"
OUT_DIR.mkdir(parents=True, exist_ok=True)

def reset_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    if bpy.context.scene.world is None:
        bpy.context.scene.world = bpy.data.worlds.new("World")

def create_pbr_mat(name, albedo_col, roughness=0.3, metallic=0.0, emit_col=None, emit_strength=0.0):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial")
    bsdf = nodes.new("ShaderNodeBsdfPrincipled")
    mat.node_tree.links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])
    bsdf.inputs["Base Color"].default_value = (*albedo_col, 1.0)
    bsdf.inputs["Roughness"].default_value = roughness
    bsdf.inputs["Metallic"].default_value = metallic
    if emit_col and emit_strength > 0:
        if "Emission Color" in bsdf.inputs:
            bsdf.inputs["Emission Color"].default_value = (*emit_col, 1.0)
            bsdf.inputs["Emission Strength"].default_value = emit_strength
        elif "Emission" in bsdf.inputs:
            bsdf.inputs["Emission"].default_value = (*emit_col, 1.0)
    return mat

# 1. INVULNERABLE STAR
def build_star():
    reset_scene()
    m_gold = create_pbr_mat("Mat_StarGold", (1.0, 0.85, 0.1), roughness=0.15, metallic=0.7, emit_col=(1.0, 0.85, 0.15), emit_strength=4.0)
    bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=0.45, depth=0.18, location=(0, 0, 0))
    star = bpy.context.active_object
    star.data.materials.append(m_gold)
    # Give star points by adding angled spikes
    for i in range(5):
        angle = i * (2 * math.pi / 5)
        bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.22, radius2=0.02, depth=0.55, location=(math.cos(angle)*0.45, math.sin(angle)*0.45, 0))
        cone = bpy.context.active_object
        cone.rotation_euler = (0, math.pi*0.5, angle)
        cone.data.materials.append(m_gold)

    bpy.ops.object.select_all(action='SELECT')
    out_file = str(OUT_DIR / "item_invulnerable_star.glb")
    bpy.ops.export_scene.gltf(filepath=out_file, export_format='GLB')
    print("Exported:", out_file)

# 2. TITAN MUSHROOM / CRYSTAL
def build_titan_shroom():
    reset_scene()
    m_stem = create_pbr_mat("Mat_Stem", (0.95, 0.95, 0.9), roughness=0.4)
    m_cap = create_pbr_mat("Mat_TitanCap", (0.95, 0.15, 0.1), roughness=0.2, emit_col=(1.0, 0.3, 0.1), emit_strength=2.5)
    m_spots = create_pbr_mat("Mat_Spots", (1.0, 1.0, 1.0), roughness=0.2, emit_col=(1.0, 1.0, 0.8), emit_strength=3.0)

    # Stem
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.25, depth=0.5, location=(0, 0, 0.25))
    stem = bpy.context.active_object
    stem.data.materials.append(m_stem)

    # Cap
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=10, radius=0.55, location=(0, 0, 0.55))
    cap = bpy.context.active_object
    cap.scale = (1.0, 1.0, 0.65)
    cap.data.materials.append(m_cap)

    # White spots
    for ang in [0, 1.25, 2.5, 3.75, 5.0]:
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.12, location=(math.cos(ang)*0.42, math.sin(ang)*0.42, 0.62))
        spot = bpy.context.active_object
        spot.data.materials.append(m_spots)

    bpy.ops.object.select_all(action='SELECT')
    out_file = str(OUT_DIR / "item_titan_mushroom.glb")
    bpy.ops.export_scene.gltf(filepath=out_file, export_format='GLB')
    print("Exported:", out_file)

# 3. SPEED BOOTS / LIGHTNING TALISMAN
def build_speed_talisman():
    reset_scene()
    m_gold = create_pbr_mat("Mat_WingGold", (1.0, 0.8, 0.2), roughness=0.2, metallic=0.9)
    m_light = create_pbr_mat("Mat_Lightning", (0.2, 0.9, 1.0), roughness=0.1, emit_col=(0.2, 0.95, 1.0), emit_strength=5.0)

    # Center lightning bolt
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.28, depth=0.2, location=(0, 0, 0))
    core = bpy.context.active_object
    core.data.materials.append(m_light)

    # Wings on sides
    for side in [-1, 1]:
        for w_y in [-0.15, 0.05, 0.25]:
            bpy.ops.mesh.primitive_cube_add(size=0.3, location=(side * 0.45, w_y, w_y * 0.5))
            w = bpy.context.active_object
            w.scale = (0.2, 1.2, 0.2)
            w.rotation_euler = (0, side * 0.4, side * 0.3)
            w.data.materials.append(m_gold)

    bpy.ops.object.select_all(action='SELECT')
    out_file = str(OUT_DIR / "item_speed_boots.glb")
    bpy.ops.export_scene.gltf(filepath=out_file, export_format='GLB')
    print("Exported:", out_file)

# 4. SMASH HAMMER
def build_smash_hammer():
    reset_scene()
    m_handle = create_pbr_mat("Mat_Handle", (0.35, 0.2, 0.1), roughness=0.6)
    m_head = create_pbr_mat("Mat_HammerHead", (0.85, 0.7, 0.15), roughness=0.2, metallic=0.9, emit_col=(1.0, 0.6, 0.1), emit_strength=2.0)

    # Shaft
    bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=0.07, depth=1.1, location=(0, 0, 0))
    handle = bpy.context.active_object
    handle.data.materials.append(m_handle)

    # Hammer Head
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.55))
    head = bpy.context.active_object
    head.scale = (0.45, 0.9, 0.45)
    head.data.materials.append(m_head)

    # Side impact studs
    for s in [-0.5, 0.5]:
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.18, depth=0.15, location=(0, s, 0.55))
        stud = bpy.context.active_object
        stud.rotation_euler = (math.pi*0.5, 0, 0)
        stud.data.materials.append(m_head)

    bpy.ops.object.select_all(action='SELECT')
    out_file = str(OUT_DIR / "item_smash_hammer.glb")
    bpy.ops.export_scene.gltf(filepath=out_file, export_format='GLB')
    print("Exported:", out_file)

# 5. HEALTH HEART
def build_health_heart():
    reset_scene()
    m_heart = create_pbr_mat("Mat_Heart", (1.0, 0.05, 0.2), roughness=0.15, metallic=0.1, emit_col=(1.0, 0.15, 0.3), emit_strength=4.0)

    # Two upper lobes
    for x in [-0.2, 0.2]:
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.26, location=(x, 0, 0.18))
        lobe = bpy.context.active_object
        lobe.data.materials.append(m_heart)

    # Lower tapered body
    bpy.ops.mesh.primitive_cone_add(vertices=16, radius1=0.45, radius2=0.02, depth=0.65, location=(0, 0, -0.15))
    cone = bpy.context.active_object
    cone.rotation_euler = (math.pi, 0, 0)
    cone.data.materials.append(m_heart)

    bpy.ops.object.select_all(action='SELECT')
    out_file = str(OUT_DIR / "item_health_heart.glb")
    bpy.ops.export_scene.gltf(filepath=out_file, export_format='GLB')
    print("Exported:", out_file)

# 6. FREEZE CRYO ORB
def build_freeze_orb():
    reset_scene()
    m_ice = create_pbr_mat("Mat_IceOrb", (0.3, 0.85, 1.0), roughness=0.08, metallic=0.2, emit_col=(0.2, 0.9, 1.0), emit_strength=4.5)
    m_spikes = create_pbr_mat("Mat_IceSpikes", (0.6, 0.95, 1.0), roughness=0.1, emit_col=(0.4, 0.95, 1.0), emit_strength=5.5)

    # Central Sphere
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.38, location=(0, 0, 0))
    sphere = bpy.context.active_object
    sphere.data.materials.append(m_ice)

    # Ice Spikes
    for i in range(8):
        ang_z = i * (math.pi / 4)
        ang_y = (i % 2) * (math.pi / 4) - math.pi/8
        dx = math.cos(ang_z) * math.cos(ang_y) * 0.38
        dy = math.sin(ang_z) * math.cos(ang_y) * 0.38
        dz = math.sin(ang_y) * 0.38
        bpy.ops.mesh.primitive_cone_add(vertices=5, radius1=0.12, radius2=0.01, depth=0.35, location=(dx, dy, dz))
        cone = bpy.context.active_object
        cone.rotation_euler = (0, -ang_y + math.pi*0.5, ang_z)
        cone.data.materials.append(m_spikes)

    bpy.ops.object.select_all(action='SELECT')
    out_file = str(OUT_DIR / "item_freeze_orb.glb")
    bpy.ops.export_scene.gltf(filepath=out_file, export_format='GLB')
    print("Exported:", out_file)

if __name__ == "__main__":
    build_star()
    build_titan_shroom()
    build_speed_talisman()
    build_smash_hammer()
    build_health_heart()
    build_freeze_orb()
