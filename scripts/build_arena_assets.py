import bpy
import math
from pathlib import Path

# Paths
ROOT = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate")
OUT_DIR = ROOT / "godot" / "assets" / "models" / "arenas"
OUT_DIR.mkdir(parents=True, exist_ok=True)

def reset_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    if bpy.context.scene.world is None:
        bpy.context.scene.world = bpy.data.worlds.new("World")

def create_pbr_mat(name, albedo_col, roughness=0.6, metallic=0.0, emit_col=None, emit_strength=0.0):
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

# ==============================================================================
# 1. ARENA PILLAR & BRAZIER (arena_pillar_brazier.glb)
# ==============================================================================
def build_pillar_brazier():
    reset_scene()
    m_stone = create_pbr_mat("Mat_StonePillar", (0.35, 0.36, 0.40), roughness=0.75, metallic=0.1)
    m_gold = create_pbr_mat("Mat_GoldTrim", (0.85, 0.65, 0.15), roughness=0.25, metallic=0.85)
    m_fire = create_pbr_mat("Mat_BrazierFire", (1.0, 0.45, 0.05), roughness=0.1, emit_col=(1.0, 0.4, 0.05), emit_strength=5.0)

    # Base Plinth
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0.3))
    base = bpy.context.active_object
    base.scale = (1.1, 1.1, 0.6)
    base.data.materials.append(m_stone)

    # Fluted Pillar shaft
    bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=0.42, depth=4.2, location=(0, 0, 2.7))
    shaft = bpy.context.active_object
    shaft.data.materials.append(m_stone)

    # Decorative Rings
    for z in [1.2, 2.7, 4.2]:
        bpy.ops.mesh.primitive_torus_add(major_radius=0.48, minor_radius=0.06, location=(0, 0, z))
        ring = bpy.context.active_object
        ring.data.materials.append(m_gold)

    # Capital bowl (brazier basin)
    bpy.ops.mesh.primitive_cone_add(vertices=16, radius1=0.85, radius2=0.45, depth=0.7, location=(0, 0, 5.1))
    bowl = bpy.context.active_object
    bowl.data.materials.append(m_gold)

    # Glowing Flame Core
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.45, location=(0, 0, 5.65))
    flame = bpy.context.active_object
    flame.scale = (1.0, 1.0, 1.4)
    flame.data.materials.append(m_fire)

    bpy.ops.object.select_all(action='SELECT')
    out_file = str(OUT_DIR / "arena_pillar_brazier.glb")
    bpy.ops.export_scene.gltf(filepath=out_file, export_format='GLB')
    print("Exported:", out_file)

# ==============================================================================
# 2. FLOATING RUNIC PLATFORM (arena_floating_platform.glb)
# ==============================================================================
def build_floating_platform():
    reset_scene()
    m_stone = create_pbr_mat("Mat_PlatStone", (0.22, 0.24, 0.28), roughness=0.65, metallic=0.2)
    m_rune = create_pbr_mat("Mat_RuneGlow", (0.1, 0.7, 1.0), roughness=0.1, emit_col=(0.2, 0.8, 1.0), emit_strength=4.5)
    m_crystal = create_pbr_mat("Mat_PowerCrystal", (0.2, 0.9, 1.0), roughness=0.15, metallic=0.3, emit_col=(0.1, 0.85, 1.0), emit_strength=6.0)

    # Main Slab
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0))
    slab = bpy.context.active_object
    slab.scale = (2.4, 1.2, 0.22)
    slab.data.materials.append(m_stone)

    # Under-slab tapered keel (floating island base)
    bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=1.1, radius2=0.05, depth=0.8, location=(0, 0, -0.45))
    keel = bpy.context.active_object
    keel.rotation_euler = (math.pi, 0, 0)
    keel.scale = (1.8, 0.9, 1.0)
    keel.data.materials.append(m_stone)

    # Runic side trims
    for side in [-0.58, 0.58]:
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, side, 0.05))
        trim = bpy.context.active_object
        trim.scale = (2.42, 0.04, 0.08)
        trim.data.materials.append(m_rune)

    # Floating power crystal beneath
    bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=0.22, depth=0.7, location=(0, 0, -1.0))
    cryst = bpy.context.active_object
    cryst.data.materials.append(m_crystal)

    bpy.ops.object.select_all(action='SELECT')
    out_file = str(OUT_DIR / "arena_floating_platform.glb")
    bpy.ops.export_scene.gltf(filepath=out_file, export_format='GLB')
    print("Exported:", out_file)

# ==============================================================================
# 3. JAPANESE TORII SHRINE GATE (arena_torii_gate.glb)
# ==============================================================================
def build_torii_gate():
    reset_scene()
    m_red = create_pbr_mat("Mat_ToriiRed", (0.85, 0.12, 0.08), roughness=0.55, metallic=0.05)
    m_black = create_pbr_mat("Mat_ToriiBlack", (0.08, 0.08, 0.10), roughness=0.4, metallic=0.2)
    m_gold = create_pbr_mat("Mat_ToriiGold", (0.9, 0.72, 0.18), roughness=0.25, metallic=0.85)

    # Two main pillars
    for x in [-3.2, 3.2]:
        bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=0.32, depth=6.5, location=(x, 0, 3.25))
        col = bpy.context.active_object
        col.rotation_euler = (0, -0.04 if x < 0 else 0.04, 0)
        col.data.materials.append(m_red)

        # Stone base plinth
        bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=0.48, depth=0.8, location=(x, 0, 0.4))
        pbase = bpy.context.active_object
        pbase.data.materials.append(m_black)

    # Lower crossbeam (Nuki)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 5.0))
    nuki = bpy.context.active_object
    nuki.scale = (7.6, 0.4, 0.3)
    nuki.data.materials.append(m_red)

    # Upper primary lintel (Kasagi & Shimaki)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 6.4))
    kasagi = bpy.context.active_object
    kasagi.scale = (8.8, 0.55, 0.45)
    kasagi.data.materials.append(m_red)

    # Black roof cap
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 6.68))
    cap = bpy.context.active_object
    cap.scale = (9.2, 0.65, 0.12)
    cap.data.materials.append(m_black)

    # Gold center tablet (Gakuzuka)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 5.7))
    tab = bpy.context.active_object
    tab.scale = (0.7, 0.35, 1.1)
    tab.data.materials.append(m_gold)

    bpy.ops.object.select_all(action='SELECT')
    out_file = str(OUT_DIR / "arena_torii_gate.glb")
    bpy.ops.export_scene.gltf(filepath=out_file, export_format='GLB')
    print("Exported:", out_file)

# ==============================================================================
# 4. CYBER / MYSTIC ENERGY PYLON (arena_energy_pylon.glb)
# ==============================================================================
def build_energy_pylon():
    reset_scene()
    m_metal = create_pbr_mat("Mat_PylonMetal", (0.12, 0.14, 0.18), roughness=0.35, metallic=0.88)
    m_neon = create_pbr_mat("Mat_PylonNeon", (0.1, 0.9, 0.8), roughness=0.1, emit_col=(0.1, 0.95, 0.85), emit_strength=5.5)

    # Base
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.65, depth=0.8, location=(0, 0, 0.4))
    base = bpy.context.active_object
    base.data.materials.append(m_metal)

    # Four arching conduits
    for rot in [0, math.pi * 0.5, math.pi, math.pi * 1.5]:
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 2.5))
        blade = bpy.context.active_object
        blade.scale = (0.12, 0.35, 3.8)
        blade.location = (math.cos(rot) * 0.42, math.sin(rot) * 0.42, 2.5)
        blade.rotation_euler = (0, 0, rot)
        blade.data.materials.append(m_metal)

    # Center floating energy core
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.22, depth=3.2, location=(0, 0, 2.5))
    core = bpy.context.active_object
    core.data.materials.append(m_neon)

    # Top emitter ring
    bpy.ops.mesh.primitive_torus_add(major_radius=0.52, minor_radius=0.08, location=(0, 0, 4.6))
    top_ring = bpy.context.active_object
    top_ring.data.materials.append(m_neon)

    bpy.ops.object.select_all(action='SELECT')
    out_file = str(OUT_DIR / "arena_energy_pylon.glb")
    bpy.ops.export_scene.gltf(filepath=out_file, export_format='GLB')
    print("Exported:", out_file)

if __name__ == "__main__":
    build_pillar_brazier()
    build_floating_platform()
    build_torii_gate()
    build_energy_pylon()
