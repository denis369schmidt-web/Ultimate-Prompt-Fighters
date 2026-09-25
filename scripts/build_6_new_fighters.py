"""Master 3D Model Builder for 6 New Ultimate Prompt Fighters:
1. Naruto Uzumaki (Rasengan, Konoha Forehead Protector, Orange Tracksuit, Whiskers)
2. Vegeta (Saiyan Royal Armor, Flame Hair, Final Flash Energy Orbs)
3. Roronoa Zoro (Santoryu 3-Katana Style, Wado in Mouth, Green Harama/Robe)
4. Saitama (Caped Baldy, Serious Punch Shockwave, Golden Suit, Red Gloves)
5. Tanjiro Kamado (Checkered Haori, Nichirin Blade, Hinokami Flame Dragon Aura, Hanafuda)
6. Sasuke Uchiha (Chidori Lightning, Kusanagi Blade, Shimenawa Rope Belt, Sharingan)

Imports the standard 18-bone combat rig with 7 animations from ninja.glb,
builds high-polygon stylized anime anatomy and signature accessories,
and exports standalone GLBs to godot/assets/models/{char}.glb.
"""
import bpy, bmesh, math, sys, os
from pathlib import Path
from mathutils import Vector, Euler

ROOT = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate")
NINJA_GLB = ROOT / "godot/assets/models/ninja.glb"
MODELS_DIR = ROOT / "godot/assets/models"
ART_DIR = ROOT / "art/characters"

MODELS_DIR.mkdir(parents=True, exist_ok=True)

def make_mat(name, col, rough=0.45, metal=0.0, emit=None, emit_str=0.0):
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

def load_base_rig():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    sc = bpy.context.scene
    bpy.ops.import_scene.gltf(filepath=str(NINJA_GLB))
    armature = None
    for obj in bpy.data.objects:
        if obj.type == "ARMATURE":
            armature = obj
            break
    assert armature is not None, "18-bone Armature must be present in ninja.glb"
    for m in [o for o in bpy.data.objects if o.type == "MESH"]:
        bpy.data.objects.remove(m, do_unlink=True)
    return armature, sc

def link_and_parent(obj, bone_name, armature, sc, mat=None):
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

def export_character(char_name, armature):
    glb_out = MODELS_DIR / f"{char_name}.glb"
    blend_dir = ART_DIR / char_name
    blend_dir.mkdir(parents=True, exist_ok=True)
    blend_out = blend_dir / f"PFU_{char_name.capitalize()}.blend"
    
    print(f"Saving {char_name} blend: {blend_out}")
    bpy.ops.wm.save_as_mainfile(filepath=str(blend_out))
    
    print(f"Exporting {char_name} GLB: {glb_out}")
    bpy.ops.export_scene.gltf(
        filepath=str(glb_out),
        export_format='GLB',
        use_selection=False,
        export_skins=True,
        export_animations=True
    )
    print(f"SUCCESS: {char_name} exported ({glb_out.stat().st_size} bytes)")

# ==============================================================================
# 1. NARUTO UZUMAKI BUILDER
# ==============================================================================
def build_naruto():
    print("\n>>> BUILDING NARUTO UZUMAKI <<<")
    armature, sc = load_base_rig()
    
    M_SKIN = make_mat("Naruto_Skin", (0.95, 0.78, 0.65), rough=0.55)
    M_HAIR = make_mat("Naruto_Hair", (1.0, 0.85, 0.08), rough=0.35, emit=(1.0, 0.85, 0.1), emit_str=0.8)
    M_ORANGE = make_mat("Naruto_Orange", (0.96, 0.42, 0.05), rough=0.6)
    M_BLACK = make_mat("Naruto_Black", (0.10, 0.11, 0.14), rough=0.7)
    M_BAND = make_mat("Naruto_Headband", (0.08, 0.18, 0.55), rough=0.45)
    M_PLATE = make_mat("Naruto_Plate", (0.85, 0.88, 0.92), rough=0.25, metal=0.85)
    M_RASENGAN = make_mat("Naruto_Rasengan", (0.30, 0.85, 1.0), rough=0.1, emit=(0.35, 0.90, 1.0), emit_str=6.0)
    M_WHISKERS = make_mat("Naruto_Whiskers", (0.45, 0.25, 0.20), rough=0.5)

    # Head
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=12, radius=8.2, location=(0, 0, 148.0))
    head = bpy.context.active_object
    head.scale = (1.0, 1.08, 1.18)
    link_and_parent(head, "head", armature, sc, M_SKIN)

    # 3D Anime Spiky Hair Clusters (24 Hair spikes)
    for i in range(24):
        ang = (i / 24.0) * math.pi * 2.0
        r = 5.5 + (i % 3) * 2.0
        hx = math.cos(ang) * r
        hy = math.sin(ang) * r * 0.85 + 1.0
        hz = 153.0 + (i % 4) * 2.5
        bpy.ops.mesh.primitive_cone_add(vertices=5, radius1=3.2, radius2=0.0, depth=9.5, location=(hx, hy, hz))
        cone = bpy.context.active_object
        cone.rotation_euler = (math.cos(ang) * 0.45, math.sin(ang) * 0.45, ang)
        link_and_parent(cone, "head", armature, sc, M_HAIR)

    # Konoha Forehead Protector (Cloth band & Metal plate)
    bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=8.6, depth=3.6, location=(0, 0, 151.0))
    band = bpy.context.active_object
    band.scale = (1.02, 1.08, 1.0)
    link_and_parent(band, "head", armature, sc, M_BAND)

    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -8.7, 151.0))
    plate = bpy.context.active_object
    plate.scale = (7.8, 1.2, 3.2)
    link_and_parent(plate, "head", armature, sc, M_PLATE)

    # Whiskers on cheeks
    for side in [-1, 1]:
        for wy in [-1.5, 0.0, 1.5]:
            bpy.ops.mesh.primitive_cylinder_add(vertices=4, radius=0.35, depth=4.2, location=(side * 5.4, -6.8, 144.5 + wy))
            w = bpy.context.active_object
            w.rotation_euler = (0, 0, side * 0.4)
            link_and_parent(w, "head", armature, sc, M_WHISKERS)

    # Torso (Orange Shinobi Jacket with White/Black Collar & Uzumaki spiral)
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=8.8, depth=24.0, location=(0, 0, 126.0))
    torso = bpy.context.active_object
    torso.scale = (1.1, 0.85, 1.0)
    link_and_parent(torso, "spine_01", armature, sc, M_ORANGE)

    # Black Shoulders / Chest panel
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=9.1, depth=8.0, location=(0, 0, 134.0))
    chest = bpy.context.active_object
    chest.scale = (1.12, 0.88, 1.0)
    link_and_parent(chest, "spine_02", armature, sc, M_BLACK)

    # White high collar
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=6.8, depth=5.5, location=(0, -0.5, 140.0))
    col = bpy.context.active_object
    col.scale = (1.05, 0.95, 1.0)
    link_and_parent(col, "neck", armature, sc, make_mat("Naruto_Collar", (0.95, 0.95, 0.95), rough=0.6))

    # Arms
    for side, sx in [("l", 1.0), ("r", -1.0)]:
        # Upper Arm
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=3.8, depth=17.0, location=(sx * 13.5, 0, 125.0))
        ua = bpy.context.active_object
        link_and_parent(ua, f"upperarm_{side}", armature, sc, M_ORANGE)

        # Forearm
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=3.3, depth=16.0, location=(sx * 22.0, 0, 112.0))
        fa = bpy.context.active_object
        link_and_parent(fa, f"lowerarm_{side}", armature, sc, M_ORANGE)

        # Hand
        bpy.ops.mesh.primitive_uv_sphere_add(segments=8, ring_count=6, radius=3.2, location=(sx * 28.0, 0, 102.0))
        hand = bpy.context.active_object
        link_and_parent(hand, f"hand_{side}", armature, sc, M_SKIN)

    # Right Hand: Glowing Rotating RASENGAN Sphere & Energy Aura Rings
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=12, radius=4.8, location=(-28.0, -2.5, 102.0))
    ras = bpy.context.active_object
    ras.name = "Naruto_Rasengan_Core"
    link_and_parent(ras, "hand_r", armature, sc, M_RASENGAN)

    for ring_i in range(3):
        bpy.ops.mesh.primitive_torus_add(major_radius=6.2 + ring_i * 1.5, minor_radius=0.5, location=(-28.0, -2.5, 102.0))
        ring = bpy.context.active_object
        ring.rotation_euler = (ring_i * 0.8, ring_i * 1.2, ring_i * 0.5)
        link_and_parent(ring, "hand_r", armature, sc, M_RASENGAN)

    # Pelvis & Legs
    bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=7.8, depth=10.0, location=(0, 0, 108.0))
    pel = bpy.context.active_object
    link_and_parent(pel, "pelvis", armature, sc, M_ORANGE)

    for side, sx in [("l", 1.0), ("r", -1.0)]:
        # Thigh
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=5.2, depth=26.0, location=(sx * 6.5, 0, 88.0))
        th = bpy.context.active_object
        link_and_parent(th, f"thigh_{side}", armature, sc, M_ORANGE)

        # Holster on right thigh
        if sx < 0:
            bpy.ops.mesh.primitive_cube_add(size=1.0, location=(-11.5, 0, 88.0))
            holster = bpy.context.active_object
            holster.scale = (2.2, 4.2, 6.5)
            link_and_parent(holster, f"thigh_{side}", armature, sc, M_BLACK)

        # Shin / Calf (with white bandages)
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=4.2, depth=24.0, location=(sx * 6.5, 0, 50.0))
        calf = bpy.context.active_object
        link_and_parent(calf, f"calf_{side}", armature, sc, M_ORANGE)

        # Shinobi Sandal
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sx * 6.5, -3.5, 8.0))
        foot = bpy.context.active_object
        foot.scale = (5.5, 12.0, 3.8)
        link_and_parent(foot, f"foot_{side}", armature, sc, M_BAND)

    export_character("naruto", armature)

# ==============================================================================
# 2. VEGETA BUILDER (Saiyan Royal Prince)
# ==============================================================================
def build_vegeta():
    print("\n>>> BUILDING VEGETA (SAIYAN PRINCE) <<<")
    armature, sc = load_base_rig()

    M_SKIN = make_mat("Vegeta_Skin", (0.96, 0.79, 0.66), rough=0.5)
    M_HAIR = make_mat("Vegeta_Hair", (0.05, 0.05, 0.07), rough=0.25, metal=0.2)
    M_SUIT = make_mat("Vegeta_Suit", (0.06, 0.12, 0.42), rough=0.55)
    M_ARMOR_WHITE = make_mat("Vegeta_ArmorWhite", (0.92, 0.92, 0.95), rough=0.35, metal=0.1)
    M_ARMOR_GOLD = make_mat("Vegeta_ArmorGold", (0.95, 0.72, 0.12), rough=0.25, metal=0.6)
    M_GLOVE = make_mat("Vegeta_Glove", (0.95, 0.95, 0.96), rough=0.4)
    M_FINAL_FLASH = make_mat("Vegeta_FinalFlash", (1.0, 0.95, 0.25), rough=0.08, emit=(1.0, 0.92, 0.20), emit_str=7.5)

    # Head
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=12, radius=8.0, location=(0, 0, 146.0))
    head = bpy.context.active_object
    head.scale = (0.98, 1.05, 1.15)
    link_and_parent(head, "head", armature, sc, M_SKIN)

    # Iconic Upward-Flaming Saiyan Hair (26 towering black spikes with widow's peak)
    for i in range(26):
        ang = (i / 26.0) * math.pi * 2.0
        dist = 3.5 + (i % 4) * 1.5
        hx = math.cos(ang) * dist
        hy = math.sin(ang) * dist * 0.85
        hz = 154.0 + (i % 5) * 5.5
        bpy.ops.mesh.primitive_cone_add(vertices=5, radius1=3.5, radius2=0.0, depth=18.0, location=(hx, hy, hz))
        spike = bpy.context.active_object
        spike.rotation_euler = (math.cos(ang) * 0.25, math.sin(ang) * 0.25, ang + math.pi / 2.0)
        link_and_parent(spike, "head", armature, sc, M_HAIR)

    # Saiyan Royal Battle Armor (Torso Chestplate & Gold segmented ribs)
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=9.6, depth=22.0, location=(0, 0, 126.0))
    chest = bpy.context.active_object
    chest.scale = (1.18, 0.92, 1.0)
    link_and_parent(chest, "spine_01", armature, sc, M_ARMOR_WHITE)

    # Golden Abdominal Rib Striations
    for gy in [-5.0, 0.0, 5.0]:
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -7.5, 123.0 + gy))
        rib = bpy.context.active_object
        rib.scale = (12.0, 2.0, 2.5)
        link_and_parent(rib, "spine_01", armature, sc, M_ARMOR_GOLD)

    # Shoulder Armor Straps
    for side, sx in [("L", 1.0), ("R", -1.0)]:
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sx * 8.5, 0, 137.5))
        strap = bpy.context.active_object
        strap.scale = (5.0, 10.0, 3.0)
        link_and_parent(strap, "spine_02", armature, sc, M_ARMOR_GOLD)

    # Blue Under-Spandex Arms
    for side, sx in [("l", 1.0), ("r", -1.0)]:
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=4.2, depth=17.0, location=(sx * 14.0, 0, 126.0))
        ua = bpy.context.active_object
        link_and_parent(ua, f"upperarm_{side}", armature, sc, M_SUIT)

        # White Saiyan Gloves
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=4.5, depth=16.0, location=(sx * 22.5, 0, 112.0))
        fa = bpy.context.active_object
        link_and_parent(fa, f"lowerarm_{side}", armature, sc, M_GLOVE)

        bpy.ops.mesh.primitive_uv_sphere_add(segments=8, ring_count=6, radius=3.4, location=(sx * 28.5, 0, 102.0))
        hand = bpy.context.active_object
        link_and_parent(hand, f"hand_{side}", armature, sc, M_GLOVE)

        # FINAL FLASH Energy Orbs in both hands!
        bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=8, radius=4.6, location=(sx * 28.5, -4.0, 102.0))
        orb = bpy.context.active_object
        orb.name = f"Vegeta_FinalFlash_{side}"
        link_and_parent(orb, f"hand_{side}", armature, sc, M_FINAL_FLASH)

    # Pelvis & Legs
    bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=8.2, depth=10.0, location=(0, 0, 108.0))
    pel = bpy.context.active_object
    link_and_parent(pel, "pelvis", armature, sc, M_SUIT)

    for side, sx in [("l", 1.0), ("r", -1.0)]:
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=5.4, depth=26.0, location=(sx * 6.6, 0, 88.0))
        th = bpy.context.active_object
        link_and_parent(th, f"thigh_{side}", armature, sc, M_SUIT)

        # White Saiyan Combat Boots with Gold/Yellow Tips
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=4.8, depth=24.0, location=(sx * 6.6, 0, 50.0))
        boot = bpy.context.active_object
        link_and_parent(boot, f"calf_{side}", armature, sc, M_ARMOR_WHITE)

        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sx * 6.6, -4.0, 8.0))
        toe = bpy.context.active_object
        toe.scale = (5.6, 12.5, 4.0)
        link_and_parent(toe, f"foot_{side}", armature, sc, M_ARMOR_GOLD)

    export_character("vegeta", armature)

# ==============================================================================
# 3. RORONOA ZORO BUILDER (Santoryu 3-Sword Master)
# ==============================================================================
def build_zoro():
    print("\n>>> BUILDING RORONOA ZORO (SANTORYU MASTER) <<<")
    armature, sc = load_base_rig()

    M_SKIN = make_mat("Zoro_Skin", (0.95, 0.77, 0.64), rough=0.5)
    M_HAIR = make_mat("Zoro_Hair", (0.28, 0.72, 0.32), rough=0.45)
    M_ROBE = make_mat("Zoro_Robe", (0.12, 0.36, 0.22), rough=0.65)
    M_HARAMAKI = make_mat("Zoro_Haramaki", (0.22, 0.58, 0.32), rough=0.6)
    M_GOLD = make_mat("Zoro_Gold", (0.96, 0.78, 0.15), rough=0.25, metal=0.75)
    M_STEEL = make_mat("Zoro_Steel", (0.92, 0.94, 0.97), rough=0.15, metal=0.92)
    M_BLADE_WADO = make_mat("Zoro_Wado", (0.96, 0.96, 0.98), rough=0.15, metal=0.9)
    M_WIND_SLASH = make_mat("Zoro_WindSlash", (0.20, 0.95, 0.45), rough=0.1, emit=(0.25, 0.98, 0.50), emit_str=6.0)

    # Head
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=12, radius=8.1, location=(0, 0, 147.0))
    head = bpy.context.active_object
    head.scale = (0.98, 1.05, 1.15)
    link_and_parent(head, "head", armature, sc, M_SKIN)

    # Moss Green Cropped Hair with Bandana
    for i in range(18):
        ang = (i / 18.0) * math.pi * 2.0
        r = 6.2 + (i % 2) * 1.5
        hx = math.cos(ang) * r
        hy = math.sin(ang) * r * 0.9
        hz = 152.0 + (i % 3) * 2.0
        bpy.ops.mesh.primitive_cone_add(vertices=5, radius1=2.8, radius2=0.0, depth=6.5, location=(hx, hy, hz))
        sp = bpy.context.active_object
        link_and_parent(sp, "head", armature, sc, M_HAIR)

    # 3 Golden Hoop Earrings on Left Ear
    for ei in range(3):
        bpy.ops.mesh.primitive_torus_add(major_radius=1.2, minor_radius=0.25, location=(7.8, -0.5, 146.0 - ei * 1.4))
        earring = bpy.context.active_object
        link_and_parent(earring, "head", armature, sc, M_GOLD)

    # ── SWORD 1: Wado Ichimonji HELD IN MOUTH! ──────────────────────────────
    # White Tsuka handle clamped in teeth
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.9, depth=14.0, location=(0, -8.5, 143.0))
    wado_tsuka = bpy.context.active_object
    wado_tsuka.rotation_euler = (0, math.pi / 2.0, 0)
    link_and_parent(wado_tsuka, "head", armature, sc, M_BLADE_WADO)

    # Long razor-sharp Katana Blade projecting outward horizontally
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(28.0, -8.5, 143.0))
    wado_blade = bpy.context.active_object
    wado_blade.scale = (48.0, 0.4, 2.2)
    link_and_parent(wado_blade, "head", armature, sc, M_STEEL)

    # Muscular anime chest with slash scar & green open Harakiri robe
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=9.5, depth=24.0, location=(0, 0, 126.0))
    chest = bpy.context.active_object
    chest.scale = (1.15, 0.88, 1.0)
    link_and_parent(chest, "spine_01", armature, sc, M_SKIN)

    # Green Robe Sides
    for side, sx in [("L", 1.0), ("R", -1.0)]:
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sx * 7.5, 0, 126.0))
        robe = bpy.context.active_object
        robe.scale = (5.0, 9.5, 23.0)
        link_and_parent(robe, "spine_01", armature, sc, M_ROBE)

    # Green Haramaki (ribbed waist band)
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=8.8, depth=12.0, location=(0, 0, 114.0))
    har = bpy.context.active_object
    har.scale = (1.08, 0.92, 1.0)
    link_and_parent(har, "pelvis", armature, sc, M_HARAMAKI)

    # ── SWORDS 2 & 3: In Hands or at Hip with Green Flying Slash Effects ───
    for side, sx in [("l", 1.0), ("r", -1.0)]:
        # Arms
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=4.2, depth=17.0, location=(sx * 14.0, 0, 126.0))
        ua = bpy.context.active_object
        link_and_parent(ua, f"upperarm_{side}", armature, sc, M_SKIN)

        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=3.6, depth=16.0, location=(sx * 22.5, 0, 112.0))
        fa = bpy.context.active_object
        link_and_parent(fa, f"lowerarm_{side}", armature, sc, M_SKIN)

        # Hand holding Katana
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.9, depth=14.0, location=(sx * 28.5, 0, 102.0))
        tsuka = bpy.context.active_object
        tsuka.rotation_euler = (math.pi / 2.0, 0, 0)
        link_and_parent(tsuka, f"hand_{side}", armature, sc, M_GOLD)

        # Blade projecting forward
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sx * 28.5, -24.0, 102.0))
        blade = bpy.context.active_object
        blade.scale = (0.5, 42.0, 2.4)
        link_and_parent(blade, f"hand_{side}", armature, sc, M_STEEL)

        # Green Flying Slash Arc VFX
        bpy.ops.mesh.primitive_torus_add(major_radius=18.0, minor_radius=0.75, location=(sx * 28.5, -28.0, 102.0))
        arc = bpy.context.active_object
        arc.name = f"Zoro_Slash_Arc_{side}"
        arc.rotation_euler = (0, math.pi / 2.0, 0)
        link_and_parent(arc, f"hand_{side}", armature, sc, M_WIND_SLASH)

    # Legs & Boots
    for side, sx in [("l", 1.0), ("r", -1.0)]:
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=5.2, depth=26.0, location=(sx * 6.8, 0, 88.0))
        th = bpy.context.active_object
        link_and_parent(th, f"thigh_{side}", armature, sc, M_ROBE)

        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=4.5, depth=24.0, location=(sx * 6.8, 0, 50.0))
        calf = bpy.context.active_object
        link_and_parent(calf, f"calf_{side}", armature, sc, make_mat(f"Zoro_Boot_{side}", (0.12, 0.12, 0.15), rough=0.6))

        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sx * 6.8, -4.0, 8.0))
        foot = bpy.context.active_object
        foot.scale = (5.5, 12.0, 3.8)
        link_and_parent(foot, f"foot_{side}", armature, sc, make_mat(f"Zoro_Sole_{side}", (0.08, 0.08, 0.1), rough=0.6))

    export_character("zoro", armature)

# ==============================================================================
# 4. SAITAMA BUILDER (One Punch Man)
# ==============================================================================
def build_saitama():
    print("\n>>> BUILDING SAITAMA (ONE PUNCH MAN) <<<")
    armature, sc = load_base_rig()

    M_SKIN = make_mat("Saitama_Skin", (0.96, 0.80, 0.68), rough=0.35)
    M_SUIT = make_mat("Saitama_Suit", (0.98, 0.85, 0.10), rough=0.5)
    M_GLOVE = make_mat("Saitama_Glove", (0.88, 0.12, 0.12), rough=0.25, metal=0.1)
    M_CAPE = make_mat("Saitama_Cape", (0.95, 0.95, 0.97), rough=0.6)
    M_BUTTON = make_mat("Saitama_Button", (0.1, 0.1, 0.12), rough=0.3, metal=0.5)
    M_BELT = make_mat("Saitama_Belt", (0.12, 0.12, 0.14), rough=0.4)
    M_BUCKLE = make_mat("Saitama_Buckle", (0.95, 0.8, 0.15), rough=0.2, metal=0.85)
    M_SHOCKWAVE = make_mat("Saitama_Shockwave", (1.0, 0.98, 0.85), rough=0.05, emit=(1.0, 0.98, 0.9), emit_str=8.0)

    # Iconic Smooth Bald Head with Heroic Silhouette
    bpy.ops.mesh.primitive_uv_sphere_add(segments=20, ring_count=16, radius=8.2, location=(0, 0, 147.0))
    head = bpy.context.active_object
    head.scale = (0.96, 1.04, 1.16)
    link_and_parent(head, "head", armature, sc, M_SKIN)

    # Flowing White Superhero Cape behind shoulders
    bpy.ops.mesh.primitive_plane_add(size=1.0, location=(0, 8.5, 120.0))
    cape = bpy.context.active_object
    cape.scale = (24.0, 1.0, 36.0)
    cape.rotation_euler = (0.18, 0, 0)
    link_and_parent(cape, "spine_02", armature, sc, M_CAPE)

    # Black Cape Shoulder Fastener Buttons
    for side, sx in [("L", 1.0), ("R", -1.0)]:
        bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=2.2, depth=1.2, location=(sx * 7.5, -4.5, 137.0))
        btn = bpy.context.active_object
        link_and_parent(btn, "spine_02", armature, sc, M_BUTTON)

    # Yellow Superhero Suit Torso with center zipper
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=9.0, depth=24.0, location=(0, 0, 126.0))
    torso = bpy.context.active_object
    torso.scale = (1.12, 0.88, 1.0)
    link_and_parent(torso, "spine_01", armature, sc, M_SUIT)

    # White Zipper Line
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -8.0, 128.0))
    zip_line = bpy.context.active_object
    zip_line.scale = (0.8, 0.5, 18.0)
    link_and_parent(zip_line, "spine_01", armature, sc, M_CAPE)

    # Black Belt with Gold Buckle
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=8.5, depth=4.2, location=(0, 0, 114.0))
    belt = bpy.context.active_object
    belt.scale = (1.05, 0.9, 1.0)
    link_and_parent(belt, "pelvis", armature, sc, M_BELT)

    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -8.0, 114.0))
    buckle = bpy.context.active_object
    buckle.scale = (4.8, 1.5, 4.0)
    link_and_parent(buckle, "pelvis", armature, sc, M_BUCKLE)

    # Arms with Red Hero Gloves
    for side, sx in [("l", 1.0), ("r", -1.0)]:
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=4.2, depth=17.0, location=(sx * 13.8, 0, 126.0))
        ua = bpy.context.active_object
        link_and_parent(ua, f"upperarm_{side}", armature, sc, M_SUIT)

        # Red Glove Gauntlet
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=4.5, depth=16.0, location=(sx * 22.5, 0, 112.0))
        fa = bpy.context.active_object
        link_and_parent(fa, f"lowerarm_{side}", armature, sc, M_GLOVE)

        # Fist
        bpy.ops.mesh.primitive_uv_sphere_add(segments=8, ring_count=8, radius=3.8, location=(sx * 28.5, 0, 102.0))
        fist = bpy.context.active_object
        link_and_parent(fist, f"hand_{side}", armature, sc, M_GLOVE)

    # SERIOUS PUNCH Shockwave Blast Ring around right fist
    bpy.ops.mesh.primitive_torus_add(major_radius=12.0, minor_radius=1.8, location=(-28.5, -4.0, 102.0))
    shock = bpy.context.active_object
    shock.name = "Saitama_SeriousPunch_Shockwave"
    link_and_parent(shock, "hand_r", armature, sc, M_SHOCKWAVE)

    # Yellow Suit Legs & Red Boots
    for side, sx in [("l", 1.0), ("r", -1.0)]:
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=5.2, depth=26.0, location=(sx * 6.5, 0, 88.0))
        th = bpy.context.active_object
        link_and_parent(th, f"thigh_{side}", armature, sc, M_SUIT)

        # Red Calf Boot
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=4.6, depth=24.0, location=(sx * 6.5, 0, 50.0))
        boot = bpy.context.active_object
        link_and_parent(boot, f"calf_{side}", armature, sc, M_GLOVE)

        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sx * 6.5, -4.0, 8.0))
        foot = bpy.context.active_object
        foot.scale = (5.6, 12.5, 4.0)
        link_and_parent(foot, f"foot_{side}", armature, sc, M_GLOVE)

    export_character("saitama", armature)

# ==============================================================================
# 5. TANJIRO KAMADO BUILDER (Demon Slayer - Hinokami Kagura)
# ==============================================================================
def build_tanjiro():
    print("\n>>> BUILDING TANJIRO KAMADO (DEMON SLAYER) <<<")
    armature, sc = load_base_rig()

    M_SKIN = make_mat("Tanjiro_Skin", (0.95, 0.78, 0.65), rough=0.5)
    M_HAIR = make_mat("Tanjiro_Hair", (0.45, 0.12, 0.15), rough=0.35)
    M_SCAR = make_mat("Tanjiro_Scar", (0.65, 0.15, 0.12), rough=0.6)
    M_UNIFORM = make_mat("Tanjiro_Uniform", (0.14, 0.14, 0.16), rough=0.7)
    M_CHECKER = make_mat("Tanjiro_Checker", (0.15, 0.65, 0.38), rough=0.55) # Green / Black checkered
    M_SWORD = make_mat("Tanjiro_Nichirin", (0.12, 0.12, 0.14), rough=0.15, metal=0.9)
    M_FLAME_DRAGON = make_mat("Tanjiro_Hinokami", (1.0, 0.35, 0.05), rough=0.08, emit=(1.0, 0.38, 0.05), emit_str=7.2)
    M_HANAFUDA = make_mat("Tanjiro_Hanafuda", (0.95, 0.95, 0.95), rough=0.3)

    # Head
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=12, radius=8.0, location=(0, 0, 147.0))
    head = bpy.context.active_object
    head.scale = (0.98, 1.05, 1.15)
    link_and_parent(head, "head", armature, sc, M_SKIN)

    # Swept-Back Burgundy Anime Spikes (20 spikes)
    for i in range(20):
        ang = (i / 20.0) * math.pi * 2.0
        dist = 5.0 + (i % 3) * 1.8
        hx = math.cos(ang) * dist
        hy = math.sin(ang) * dist * 0.85 + 2.0
        hz = 153.0 + (i % 4) * 2.0
        bpy.ops.mesh.primitive_cone_add(vertices=5, radius1=3.0, radius2=0.0, depth=8.5, location=(hx, hy, hz))
        sp = bpy.context.active_object
        sp.rotation_euler = (0.45, 0, ang)
        link_and_parent(sp, "head", armature, sc, M_HAIR)

    # Demon Slayer Scar on upper forehead
    bpy.ops.mesh.primitive_plane_add(size=1.0, location=(-3.5, -7.8, 151.5))
    scar = bpy.context.active_object
    scar.scale = (3.2, 1.0, 3.2)
    scar.rotation_euler = (0.2, 0.3, 0)
    link_and_parent(scar, "head", armature, sc, M_SCAR)

    # Hanafuda Earrings dangling from ears
    for side, sx in [("L", 1.0), ("R", -1.0)]:
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sx * 7.8, -0.5, 142.0))
        earring = bpy.context.active_object
        earring.scale = (0.25, 2.4, 4.5)
        link_and_parent(earring, "head", armature, sc, M_HANAFUDA)

    # Black Demon Slayer Corps Uniform & Voluminous Checkered Haori
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=9.2, depth=24.0, location=(0, 0, 126.0))
    torso = bpy.context.active_object
    torso.scale = (1.15, 0.88, 1.0)
    link_and_parent(torso, "spine_01", armature, sc, M_CHECKER)

    # Arms with wide Haori sleeves
    for side, sx in [("l", 1.0), ("r", -1.0)]:
        bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=5.8, depth=18.0, location=(sx * 14.5, 0, 125.0))
        sleeve = bpy.context.active_object
        link_and_parent(sleeve, f"upperarm_{side}", armature, sc, M_CHECKER)

        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=3.4, depth=16.0, location=(sx * 22.5, 0, 112.0))
        fa = bpy.context.active_object
        link_and_parent(fa, f"lowerarm_{side}", armature, sc, M_UNIFORM)

        bpy.ops.mesh.primitive_uv_sphere_add(segments=8, ring_count=6, radius=3.2, location=(sx * 28.5, 0, 102.0))
        hand = bpy.context.active_object
        link_and_parent(hand, f"hand_{side}", armature, sc, M_SKIN)

    # Black Nichirin Katana in right hand with HINOKAMI KAGURA Flame Dragon Arc!
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.9, depth=14.0, location=(-28.5, 0, 102.0))
    tsuka = bpy.context.active_object
    tsuka.rotation_euler = (math.pi / 2.0, 0, 0)
    link_and_parent(tsuka, "hand_r", armature, sc, M_UNIFORM)

    # Pitch-Black Blade
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(-28.5, -24.0, 102.0))
    blade = bpy.context.active_object
    blade.scale = (0.5, 42.0, 2.2)
    link_and_parent(blade, "hand_r", armature, sc, M_SWORD)

    # Radiant Hinokami Kagura Sun Flame Dragon wrapping around the blade
    for flame_i in range(8):
        fy = -10.0 - flame_i * 4.5
        bpy.ops.mesh.primitive_torus_add(major_radius=4.5 + (flame_i % 3) * 1.5, minor_radius=1.2, location=(-28.5, fy, 102.0))
        flame = bpy.context.active_object
        flame.rotation_euler = (flame_i * 0.7, 0, flame_i * 0.9)
        link_and_parent(flame, "hand_r", armature, sc, M_FLAME_DRAGON)

    # Pleated Hakama Pants & Kyahan leg wraps
    for side, sx in [("l", 1.0), ("r", -1.0)]:
        bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=6.5, depth=26.0, location=(sx * 6.8, 0, 88.0))
        th = bpy.context.active_object
        link_and_parent(th, f"thigh_{side}", armature, sc, M_UNIFORM)

        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=4.5, depth=24.0, location=(sx * 6.8, 0, 50.0))
        calf = bpy.context.active_object
        link_and_parent(calf, f"calf_{side}", armature, sc, make_mat(f"Tanjiro_Kyahan_{side}", (0.9, 0.9, 0.92), rough=0.6))

        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sx * 6.8, -4.0, 8.0))
        foot = bpy.context.active_object
        foot.scale = (5.5, 12.0, 3.8)
        link_and_parent(foot, f"foot_{side}", armature, sc, make_mat(f"Tanjiro_Zori_{side}", (0.75, 0.2, 0.2), rough=0.6))

    export_character("tanjiro", armature)

# ==============================================================================
# 6. SASUKE UCHIHA BUILDER (Chidori Lightning & Kusanagi Blade)
# ==============================================================================
def build_sasuke():
    print("\n>>> BUILDING SASUKE UCHIHA <<<")
    armature, sc = load_base_rig()

    M_SKIN = make_mat("Sasuke_Skin", (0.95, 0.79, 0.67), rough=0.45)
    M_HAIR = make_mat("Sasuke_Hair", (0.06, 0.08, 0.14), rough=0.25, metal=0.1)
    M_SHIRT = make_mat("Sasuke_Shirt", (0.92, 0.92, 0.95), rough=0.6)
    M_PANTS = make_mat("Sasuke_Pants", (0.10, 0.12, 0.20), rough=0.65)
    M_ROPE = make_mat("Sasuke_Shimenawa", (0.55, 0.25, 0.75), rough=0.5) # Purple rope belt
    M_SWORD = make_mat("Sasuke_Kusanagi", (0.92, 0.94, 0.98), rough=0.12, metal=0.95)
    M_CHIDORI = make_mat("Sasuke_Chidori", (0.40, 0.85, 1.0), rough=0.05, emit=(0.45, 0.90, 1.0), emit_str=8.5)
    M_SHARINGAN = make_mat("Sasuke_Eye", (0.95, 0.08, 0.08), rough=0.1, emit=(1.0, 0.1, 0.1), emit_str=4.5)

    # Head
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=12, radius=8.0, location=(0, 0, 147.0))
    head = bpy.context.active_object
    head.scale = (0.96, 1.05, 1.15)
    link_and_parent(head, "head", armature, sc, M_SKIN)

    # Spiky Raven Black Anime Hair with bangs framing face
    for i in range(22):
        ang = (i / 22.0) * math.pi * 2.0
        r = 5.5 + (i % 3) * 2.0
        hx = math.cos(ang) * r
        hy = math.sin(ang) * r * 0.9 + (2.0 if i < 11 else -1.0)
        hz = 153.0 + (i % 4) * 2.2
        bpy.ops.mesh.primitive_cone_add(vertices=5, radius1=3.2, radius2=0.0, depth=10.0, location=(hx, hy, hz))
        sp = bpy.context.active_object
        sp.rotation_euler = (0.35, 0, ang)
        link_and_parent(sp, "head", armature, sc, M_HAIR)

    # Sharingan Eye Glow
    bpy.ops.mesh.primitive_uv_sphere_add(segments=8, ring_count=6, radius=1.3, location=(2.8, -7.8, 148.0))
    eye = bpy.context.active_object
    link_and_parent(eye, "head", armature, sc, M_SHARINGAN)

    # High-Collar Open Zipper Shirt with Uchiha Fan Crest on back
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=9.0, depth=24.0, location=(0, 0, 126.0))
    shirt = bpy.context.active_object
    shirt.scale = (1.12, 0.88, 1.0)
    link_and_parent(shirt, "spine_01", armature, sc, M_SHIRT)

    # High Collar
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=6.8, depth=7.0, location=(0, -0.2, 141.0))
    col = bpy.context.active_object
    col.scale = (1.05, 0.95, 1.0)
    link_and_parent(col, "neck", armature, sc, M_SHIRT)

    # Thick Purple Braided Shimenawa Rope Belt
    bpy.ops.mesh.primitive_torus_add(major_radius=9.2, minor_radius=2.5, location=(0, 0, 114.0))
    rope = bpy.context.active_object
    rope.scale = (1.05, 0.88, 1.0)
    link_and_parent(rope, "pelvis", armature, sc, M_ROPE)

    # Kusanagi Chokuto Sword at Hip
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(11.5, 2.0, 108.0))
    kusanagi = bpy.context.active_object
    kusanagi.scale = (1.2, 44.0, 2.2)
    kusanagi.rotation_euler = (0.25, 0.1, -0.4)
    link_and_parent(kusanagi, "pelvis", armature, sc, M_SWORD)

    # Arms
    for side, sx in [("l", 1.0), ("r", -1.0)]:
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=4.0, depth=17.0, location=(sx * 13.8, 0, 126.0))
        ua = bpy.context.active_object
        link_and_parent(ua, f"upperarm_{side}", armature, sc, M_SHIRT)

        # Arm bandage wraps
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=3.5, depth=16.0, location=(sx * 22.5, 0, 112.0))
        fa = bpy.context.active_object
        link_and_parent(fa, f"lowerarm_{side}", armature, sc, make_mat(f"Sasuke_Wrap_{side}", (0.22, 0.22, 0.28), rough=0.6))

        bpy.ops.mesh.primitive_uv_sphere_add(segments=8, ring_count=6, radius=3.2, location=(sx * 28.5, 0, 102.0))
        hand = bpy.context.active_object
        link_and_parent(hand, f"hand_{side}", armature, sc, M_SKIN)

    # LEFT HAND: CRACKLING CHIDORI (1000 BIRDS) LIGHTNING SPHERE & SPARKS!
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=12, radius=5.2, location=(28.5, -2.5, 102.0))
    chidori = bpy.context.active_object
    chidori.name = "Sasuke_Chidori_Core"
    link_and_parent(chidori, "hand_l", armature, sc, M_CHIDORI)

    # Electric Lightning Sparks radiating from hand
    for spark_i in range(8):
        ang = (spark_i / 8.0) * math.pi * 2.0
        bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=1.8, radius2=0.0, depth=12.0, location=(28.5 + math.cos(ang) * 4.0, -2.5 + math.sin(ang) * 4.0, 102.0))
        spark = bpy.context.active_object
        spark.rotation_euler = (math.cos(ang) * 0.8, math.sin(ang) * 0.8, ang)
        link_and_parent(spark, "hand_l", armature, sc, M_CHIDORI)

    # Dark Blue Pants & Shinobi Sandals
    for side, sx in [("l", 1.0), ("r", -1.0)]:
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=5.4, depth=26.0, location=(sx * 6.6, 0, 88.0))
        th = bpy.context.active_object
        link_and_parent(th, f"thigh_{side}", armature, sc, M_PANTS)

        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=4.5, depth=24.0, location=(sx * 6.6, 0, 50.0))
        calf = bpy.context.active_object
        link_and_parent(calf, f"calf_{side}", armature, sc, M_PANTS)

        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sx * 6.6, -4.0, 8.0))
        foot = bpy.context.active_object
        foot.scale = (5.5, 12.0, 3.8)
        link_and_parent(foot, f"foot_{side}", armature, sc, make_mat(f"Sasuke_Sandal_{side}", (0.1, 0.1, 0.14), rough=0.6))

    export_character("sasuke", armature)

# ==============================================================================
# MAIN EXECUTION
# ==============================================================================
if __name__ == "__main__":
    print("==================================================")
    print("STARTING BUILD FOR 6 PRO ANIME FIGHTERS")
    print("==================================================")
    build_naruto()
    build_vegeta()
    build_zoro()
    build_saitama()
    build_tanjiro()
    build_sasuke()
    print("==================================================")
    print("ALL 6 FIGHTERS BUILT & EXPORTED TO GLB!")
    print("==================================================")
