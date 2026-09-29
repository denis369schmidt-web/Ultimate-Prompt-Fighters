"""Build Pro High-Detail Final Form Frieza (Dragon Ball Z - Emperor of the Universe).
Constructs anatomically detailed Final Form Frieza with:
- Streamlined bio-armor white carapace head with glossy purple skull dome
- Piercing crimson eyes with signature black vertical eyeliner marks
- Polished purple biomechanical gem shields on shoulders, chest, and shins
- Long segmented prehensile reptile whip tail curving behind pelvis
- Right hand Death Beam: Crimson laser beam sphere with electric sparks
- Overhead floating Death Ball / Supernova energy sphere
- 18-bone standard combat armature parented with combat animations
- Exports to godot/assets/models/frieza.glb and art/characters/frieza/PFU_Frieza.blend
"""
import bpy, bmesh, math, sys, os
from pathlib import Path
from mathutils import Vector, Euler

ROOT = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate")
NINJA_GLB = ROOT / "godot/assets/models/ninja.glb"
MODELS_DIR = ROOT / "godot/assets/models"
ART_DIR = ROOT / "art/characters/frieza"

MODELS_DIR.mkdir(parents=True, exist_ok=True)
ART_DIR.mkdir(parents=True, exist_ok=True)

def make_mat(name, col, rough=0.35, metal=0.0, emit=None, emit_str=0.0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nodes = m.node_tree.nodes
    links = m.node_tree.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (0, 0)
    links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])
    bsdf.inputs["Base Color"].default_value = (*col, 1.0)
    bsdf.inputs["Roughness"].default_value = rough
    bsdf.inputs["Metallic"].default_value = metal
    if emit and emit_str > 0:
        if "Emission Color" in bsdf.inputs:
            bsdf.inputs["Emission Color"].default_value = (*emit, 1.0)
            bsdf.inputs["Emission Strength"].default_value = emit_str
        elif "Emission" in bsdf.inputs:
            bsdf.inputs["Emission"].default_value = (*emit, 1.0)
    return m

def build_frieza():
    print("=== STARTING PRO FRIEZA (FINAL FORM) 3D BUILD ===")
    bpy.ops.wm.read_factory_settings(use_empty=True)
    sc = bpy.context.scene

    # Load 18-bone rig from ninja.glb
    bpy.ops.import_scene.gltf(filepath=str(NINJA_GLB))
    armature = None
    for obj in bpy.data.objects:
        if obj.type == "ARMATURE":
            armature = obj
            break
    assert armature is not None, "18-bone Armature must be present"

    # Remove old meshes
    for m in [o for o in bpy.data.objects if o.type == "MESH"]:
        bpy.data.objects.remove(m, do_unlink=True)

    def link_and_parent(obj, bone_name, mat=None):
        if obj.name not in sc.collection.objects:
            sc.collection.objects.link(obj)
        if mat:
            obj.data.materials.append(mat)
        obj.parent = armature
        mod = obj.modifiers.new("Armature", "ARMATURE")
        mod.object = armature
        vg = obj.vertex_groups.new(name=bone_name)
        all_indices = list(range(len(obj.data.vertices)))
        if all_indices:
            vg.add(all_indices, 1.0, 'REPLACE')
        bpy.context.view_layer.objects.active = obj
        obj.select_set(True)
        bpy.ops.object.shade_smooth()
        obj.select_set(False)
        return obj

    # PBR Materials
    M_WHITE = make_mat("Frieza_WhiteSkin", (0.95, 0.95, 0.98), rough=0.28, metal=0.05)
    M_PURPLE_GEM = make_mat("Frieza_PurpleGem", (0.50, 0.08, 0.72), rough=0.15, metal=0.25, emit=(0.45, 0.05, 0.65), emit_str=1.2)
    M_EYE_RED = make_mat("Frieza_EyeRed", (0.95, 0.08, 0.12), rough=0.1, emit=(1.0, 0.08, 0.12), emit_str=5.0)
    M_EYELINER = make_mat("Frieza_Eyeliner", (0.05, 0.05, 0.06), rough=0.4)
    M_DEATH_BEAM = make_mat("Frieza_DeathBeam", (1.0, 0.10, 0.35), rough=0.05, emit=(1.0, 0.12, 0.40), emit_str=8.5)
    M_SUPERNOVA = make_mat("Frieza_Supernova", (1.0, 0.42, 0.05), rough=0.08, emit=(1.0, 0.45, 0.08), emit_str=7.0)

    # 1. HEAD & SKULL GEM
    # Base head sphere (sleek bio-carapace)
    bpy.ops.mesh.primitive_uv_sphere_add(segments=18, ring_count=14, radius=7.8, location=(0, 0, 147.0))
    head = bpy.context.active_object
    head.scale = (0.96, 1.04, 1.14)
    link_and_parent(head, "head", M_WHITE)

    # Iconic Purple Skull Plate (Smooth dome atop head)
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=12, radius=6.8, location=(0, 0, 151.0))
    skull_gem = bpy.context.active_object
    skull_gem.scale = (0.92, 0.98, 0.75)
    link_and_parent(skull_gem, "head", M_PURPLE_GEM)

    # Red Emperor Eyes
    for side, sx in [("L", 1.0), ("R", -1.0)]:
        bpy.ops.mesh.primitive_uv_sphere_add(segments=8, ring_count=6, radius=1.1, location=(sx * 2.8, -7.4, 147.0))
        eye = bpy.context.active_object
        link_and_parent(eye, "head", M_EYE_RED)

        # Signature vertical eyeliner stripe down cheeks
        bpy.ops.mesh.primitive_cylinder_add(vertices=4, radius=0.35, depth=4.5, location=(sx * 2.8, -7.5, 144.0))
        liner = bpy.context.active_object
        link_and_parent(liner, "head", M_EYELINER)

        # Ear hole bio-vent indentations
        bpy.ops.mesh.primitive_torus_add(major_radius=1.8, minor_radius=0.45, location=(sx * 7.6, 0.5, 147.0))
        ear = bpy.context.active_object
        ear.rotation_euler = (0, math.pi / 2.0, 0)
        link_and_parent(ear, "head", M_PURPLE_GEM)

    # 2. TORSO & PURPLE CHEST GEM
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=8.8, depth=24.0, location=(0, 0, 126.0))
    torso = bpy.context.active_object
    torso.scale = (1.12, 0.88, 1.0)
    link_and_parent(torso, "spine_01", M_WHITE)

    # Oval Purple Bio-Gem in center of chest
    bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=10, radius=4.5, location=(0, -7.6, 131.0))
    chest_gem = bpy.context.active_object
    chest_gem.scale = (1.2, 0.5, 1.6)
    link_and_parent(chest_gem, "spine_02", M_PURPLE_GEM)

    # 3. SHOULDERS WITH PURPLE BIO-CAPS
    for side, sx in [("l", 1.0), ("r", -1.0)]:
        # Upper Arm
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=3.8, depth=17.0, location=(sx * 13.8, 0, 126.0))
        ua = bpy.context.active_object
        link_and_parent(ua, f"upperarm_{side}", M_WHITE)

        # Purple Shoulder Guard
        bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=8, radius=4.8, location=(sx * 13.8, 0, 134.0))
        sh_gem = bpy.context.active_object
        sh_gem.scale = (1.1, 0.95, 0.85)
        link_and_parent(sh_gem, f"upperarm_{side}", M_PURPLE_GEM)

        # Forearm
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=3.4, depth=16.0, location=(sx * 22.5, 0, 112.0))
        fa = bpy.context.active_object
        link_and_parent(fa, f"lowerarm_{side}", M_WHITE)

        # Purple Forearm Bracer Section
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=3.7, depth=8.0, location=(sx * 22.5, 0, 110.0))
        wrist_gem = bpy.context.active_object
        link_and_parent(wrist_gem, f"lowerarm_{side}", M_PURPLE_GEM)

        # 3-Clawed Hand
        bpy.ops.mesh.primitive_uv_sphere_add(segments=8, ring_count=6, radius=3.0, location=(sx * 28.5, 0, 102.0))
        hand = bpy.context.active_object
        link_and_parent(hand, f"hand_{side}", M_WHITE)

    # 4. RIGHT HAND: GLOWING DEATH BEAM SPHERE & LASER RAY!
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=12, radius=4.5, location=(-28.5, -4.5, 102.0))
    d_beam = bpy.context.active_object
    d_beam.name = "Frieza_DeathBeam_Core"
    link_and_parent(d_beam, "hand_r", M_DEATH_BEAM)

    # Piercing concentrated Death Beam Ray projecting forward
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.8, depth=55.0, location=(-28.5, -32.0, 102.0))
    ray = bpy.context.active_object
    ray.rotation_euler = (math.pi / 2.0, 0, 0)
    link_and_parent(ray, "hand_r", M_DEATH_BEAM)

    # 5. OVERHEAD FLOATING SUPERNOVA / DEATH BALL
    bpy.ops.mesh.primitive_uv_sphere_add(segments=20, ring_count=16, radius=11.5, location=(-28.5, -2.0, 168.0))
    supernova = bpy.context.active_object
    supernova.name = "Frieza_Supernova"
    link_and_parent(supernova, "hand_r", M_SUPERNOVA)

    # Supernova Corona Rings
    for cr_i in range(3):
        bpy.ops.mesh.primitive_torus_add(major_radius=14.5 + cr_i * 2.0, minor_radius=0.7, location=(-28.5, -2.0, 168.0))
        c_ring = bpy.context.active_object
        c_ring.rotation_euler = (cr_i * 0.9, cr_i * 1.3, cr_i * 0.4)
        link_and_parent(c_ring, "hand_r", M_SUPERNOVA)

    # 6. PELVIS & LONG PREHENSILE REPTILIAN WHIP TAIL!
    bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=8.0, depth=10.0, location=(0, 0, 108.0))
    pel = bpy.context.active_object
    link_and_parent(pel, "pelvis", M_WHITE)

    # Long Curving Tail (7 segments arching upward and back)
    tail_pts = [
        (0.0, 7.0, 106.0, 4.2),
        (0.0, 14.0, 104.0, 3.8),
        (0.0, 21.0, 99.0, 3.4),
        (0.0, 27.0, 92.0, 3.0),
        (0.0, 31.0, 83.0, 2.6),
        (0.0, 33.0, 72.0, 2.2),
        (0.0, 31.0, 60.0, 1.8),
        (0.0, 25.0, 50.0, 1.4)
    ]
    for ti in range(len(tail_pts) - 1):
        x1, y1, z1, r1 = tail_pts[ti]
        x2, y2, z2, r2 = tail_pts[ti + 1]
        mx, my, mz = (x1 + x2) * 0.5, (y1 + y2) * 0.5, (z1 + z2) * 0.5
        length = math.sqrt((x2 - x1)**2 + (y2 - y1)**2 + (z2 - z1)**2)
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=(r1 + r2) * 0.5, depth=length, location=(mx, my, mz))
        seg = bpy.context.active_object
        seg.name = f"Frieza_Tail_Seg_{ti}"
        ang_x = math.atan2(y2 - y1, z2 - z1)
        seg.rotation_euler = (ang_x, 0, 0)
        link_and_parent(seg, "pelvis", M_WHITE)

    # 7. LEGS WITH PURPLE SHIN PLATES
    for side, sx in [("l", 1.0), ("r", -1.0)]:
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=5.2, depth=26.0, location=(sx * 6.6, 0, 88.0))
        th = bpy.context.active_object
        link_and_parent(th, f"thigh_{side}", M_WHITE)

        # Calf
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=4.4, depth=24.0, location=(sx * 6.6, 0, 50.0))
        calf = bpy.context.active_object
        link_and_parent(calf, f"calf_{side}", M_WHITE)

        # Purple Shin Plate Shield
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sx * 6.6, -3.8, 50.0))
        shin = bpy.context.active_object
        shin.scale = (4.8, 2.0, 16.0)
        link_and_parent(shin, f"calf_{side}", M_PURPLE_GEM)

        # 2-Toed Bio Foot
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sx * 6.6, -4.0, 8.0))
        foot = bpy.context.active_object
        foot.scale = (5.5, 12.0, 3.8)
        link_and_parent(foot, f"foot_{side}", M_WHITE)

    # Save Blend & Export GLB
    blend_out = ART_DIR / "PFU_Frieza.blend"
    glb_out = MODELS_DIR / "frieza.glb"
    print(f"Saving Blender file: {blend_out}")
    bpy.ops.wm.save_as_mainfile(filepath=str(blend_out))

    print(f"Exporting GLB: {glb_out}")
    bpy.ops.export_scene.gltf(
        filepath=str(glb_out),
        export_format='GLB',
        use_selection=False,
        export_skins=True,
        export_animations=True
    )
    print(f"=== FRIEZA BUILD SUCCESSFUL ({glb_out.stat().st_size} bytes) ===")

if __name__ == "__main__":
    build_frieza()
