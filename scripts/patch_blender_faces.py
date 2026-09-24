import pathlib

p = pathlib.Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate\scripts\blender_generate_fighters.py")
src = p.read_text(encoding="utf-8")

# 1) Add create_face_plate helper
face_plate_def = '''def create_face_plate(name, center, size, texture_name):
    """
    Creates a curved 3D face plate mesh with chin taper and nose curve,
    with exact UV mapping for the authentic face texture.
    """
    cx, cy, cz = center
    sx, sy, sz = size

    cols = 9
    rows = 11
    verts = []
    uvs = []

    for r in range(rows):
        v = r / (rows - 1)
        z = cz - sz + v * (2.0 * sz)
        taper_x = 0.65 + 0.35 * math.sin(v * math.pi * 0.5)
        cheek = 1.0 + 0.08 * math.sin(v * math.pi)

        for c in range(cols):
            u = c / (cols - 1)
            angle = (u - 0.5) * math.radians(130.0)
            rx = sx * taper_x * cheek
            x = cx + rx * math.sin(angle)
            depth_curve = sy * math.cos(angle)
            nose_bump = 0.0
            if abs(c - 4) <= 1 and abs(v - 0.38) < 0.12:
                nose_bump = 1.8 * (1.0 - abs(c - 4)) * (1.0 - abs(v - 0.38) / 0.12)

            y = cy - depth_curve - nose_bump
            verts.append((x, y, z))
            tex_u = 0.15 + u * 0.70
            tex_v = 0.12 + v * 0.76
            uvs.append((tex_u, tex_v))

    faces = []
    for r in range(rows - 1):
        for c in range(cols - 1):
            i0 = r * cols + c
            i1 = r * cols + (c + 1)
            i2 = (r + 1) * cols + (c + 1)
            i3 = (r + 1) * cols + c
            faces.append((i0, i1, i2, i3))

    mesh = bpy.data.meshes.new(f"{name}_Mesh")
    mesh.from_pydata(verts, [], faces)
    mesh.update()

    uv_layer = mesh.uv_layers.new(name="UVMap")
    for poly in mesh.polygons:
        for loop_idx in poly.loop_indices:
            vert_idx = mesh.loops[loop_idx].vertex_index
            uv_layer.data[loop_idx].uv = uvs[vert_idx]

    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    smooth(obj)

    tex_path = SCRIPT_DIR.parent / "godot" / "assets" / "textures" / "characters" / texture_name
    mat = bpy.data.materials.new(f"M_{name}")
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    links = mat.node_tree.links
    nodes.clear()

    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (600, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (200, 0)
    links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])

    tex_node = nodes.new("ShaderNodeTexImage"); tex_node.location = (-200, 0)
    if tex_path.exists():
        tex_node.image = bpy.data.images.load(str(tex_path))
    links.new(tex_node.outputs["Color"], bsdf.inputs["Base Color"])

    bsdf.inputs["Roughness"].default_value = 0.45
    bsdf.inputs["Metallic"].default_value = 0.0
    for sskey in ("Subsurface Weight", "Subsurface"):
        if sskey in bsdf.inputs:
            bsdf.inputs[sskey].default_value = 0.25
            break

    assign_material(obj, mat)
    return obj

'''

target_anchor = "def fighter_bones(scale=1.0, wide=1.0):"
assert target_anchor in src, "fighter_bones anchor not found"
if "def create_face_plate(" not in src:
    src = src.replace(target_anchor, face_plate_def + "\n" + target_anchor, 1)
    print("1/6 Added create_face_plate")

# 2) Valkyrie Head upgrade
old_valk_head = '''    # --- ANIME HEAD, BIG EYES, WINGED TIARA & TWIN-TAILS ---
    head = uv_part("Valkyrie_Head", (0, 0, 168), (9.2, 10.0, 11.0), skin_mat)
    part(head, "head")

    # Big expressive anime eyes
    for side in (-1, 1):
        eye = beveled_part(f"Valkyrie_Eye_{side}", (side * 3.8, -9.2, 169.5), (2.4, 0.6, 1.6), eye_mat, bevel=0.3, rotation=(0, math.radians(-side * 8), math.radians(side * 6)))
        part(eye, "head")
        eyebrow = beveled_part(f"Valkyrie_Brow_{side}", (side * 3.8, -9.5, 172.0), (2.6, 0.4, 0.4), hair_mat, bevel=0.1)
        part(eyebrow, "head")'''

new_valk_head = '''    # --- AUTHENTIC ANIME FACE, HEAD & TWIN-TAILS ---
    face = create_face_plate("Valkyrie_FacePlate", (0, -2.5, 168), (8.2, 5.5, 9.8), "face_valkyrie.png")
    part(face, "head")

    head = uv_part("Valkyrie_Head", (0, 2.5, 169), (8.6, 8.0, 10.0), skin_mat)
    part(head, "head")'''

assert old_valk_head in src, "old_valk_head not found"
src = src.replace(old_valk_head, new_valk_head, 1)
print("2/6 Valkyrie head upgraded")

# 3) Ninja Head upgrade
old_ninja_head = '''    # --- HEAD, ANIME HAIR & MASK ---
    head = uv_part("Ninja_Head", (0, 0, 171), (11, 11, 13), skin_mat)
    part(head, "head")

    # Lower face mask & neck wrap
    mask = beveled_part("Ninja_FaceMask", (0, -7.2, 168), (8.5, 4.2, 5.5), cloth, bevel=1.8, subsurf=True)
    part(mask, "head")
    cowl_neck = beveled_part("Ninja_CowlNeck", (0, 0.5, 160), (12.0, 11.5, 7.5), cloth, bevel=2.5, subsurf=True)
    part(cowl_neck, "head")

    # Sharp glowing assassin eye slits
    for side in (-1, 1):
        eye = beveled_part(f"Ninja_Eye_{side}", (side * 4.2, -9.6, 172.8), (2.8, 0.6, 0.9), visor_mat, bevel=0.2, rotation=(0, math.radians(-side * 10), math.radians(side * 15)))
        part(eye, "head")'''

new_ninja_head = '''    # --- AUTHENTIC CYBER-SHINOBI FACE & HOOD ---
    face = create_face_plate("Ninja_FacePlate", (0, -2.5, 171), (8.6, 5.6, 10.2), "face_ninja.png")
    part(face, "head")

    head = uv_part("Ninja_Head", (0, 2.5, 172), (8.8, 8.2, 10.5), cloth)
    part(head, "head")

    cowl_neck = beveled_part("Ninja_CowlNeck", (0, 0.5, 160), (12.0, 11.5, 7.5), cloth, bevel=2.5, subsurf=True)
    part(cowl_neck, "head")'''

assert old_ninja_head in src, "old_ninja_head not found"
src = src.replace(old_ninja_head, new_ninja_head, 1)
print("3/6 Ninja head upgraded")

# 4) Phoenix Head upgrade
old_phx_head = '''    # ── HEAD: ornate helmet with crest feathers ──────────────────────────
    skull = beveled_part("Phx_Skull", (0,0,178), (10.8,10.2,11.8), feather_red, bevel=2.2, subsurf=True)
    part(skull, "head")
    skull_inner = beveled_part("Phx_SkullInner", (0,0,178), (8.5,8.0,10.0), lava_vein, bevel=1.2)
    part(skull_inner, "head")
    visor = beveled_part("Phx_Visor", (0,-9.5,176), (9.0,1.5,5.0), obsidian, bevel=0.5, subsurf=True)
    part(visor, "head")
    for side,sx in ((1,4.8),(-1,-4.8)):
        sfx = "L" if side>0 else "R"
        eye = beveled_part(f"Phx_Eye_{sfx}", (sx,-9.0,178), (2.5,1.0,2.5), eye_fire, bevel=0.3)
        part(eye, "head")
        cheek = beveled_part(f"Phx_Cheek_{sfx}", (sx*1.4,-5.0,173), (3.2,2.8,4.5), molten_gold, bevel=0.6, subsurf=True)
        part(cheek, "head")
        horn = beveled_part(f"Phx_Horn_{sfx}", (sx*6,0,188), (1.5,1.5,10.0), molten_gold, bevel=0.3, subsurf=True,
                            rotation=(0, math.radians(side*-20), 0))
        part(horn, "head")'''

new_phx_head = '''    # ── HEAD: authentic empress face & crest feathers ────────────────────
    face = create_face_plate("Phoenix_FacePlate", (0, -2.2, 178), (8.8, 5.5, 10.5), "face_phoenix.png")
    part(face, "head")

    skull = uv_part("Phx_Skull", (0, 2.5, 179), (8.8, 8.2, 10.2), feather_deep)
    part(skull, "head")
    for side,sx in ((1,4.8),(-1,-4.8)):
        sfx = "L" if side>0 else "R"
        horn = beveled_part(f"Phx_Horn_{sfx}", (sx*6,0,188), (1.5,1.5,10.0), molten_gold, bevel=0.3, subsurf=True,
                            rotation=(0, math.radians(side*-20), 0))
        part(horn, "head")'''

assert old_phx_head in src, "old_phx_head not found"
src = src.replace(old_phx_head, new_phx_head, 1)
print("4/6 Phoenix head upgraded")

# 5) Dragon Head upgrade
old_dragon_head = '''    # --- DRAGON SLAYER HELM, OBSIDIAN HORNS & VISOR ---
    head = uv_part("Dragon_HeadBase", (0, 0, 172), (10.5, 11.5, 12.5), titanium_dark)
    part(head, "head")

    faceplate = beveled_part("Dragon_Faceplate", (0, -8.5, 171), (9.0, 4.5, 9.5), titanium_dark, bevel=1.8, subsurf=True)
    part(faceplate, "head")
    jaw_guard = beveled_part("Dragon_JawGuard", (0, -7.5, 163), (8.0, 5.0, 4.5), gold_trim, bevel=1.0, subsurf=True)
    part(jaw_guard, "head")

    for side in (-1, 1):
        eye = beveled_part(f"Dragon_Eye_{side}", (side * 4.2, -10.5, 173.5), (3.0, 0.8, 1.2), visor_glow, bevel=0.2, rotation=(0, math.radians(-side * 14), math.radians(side * 18)))
        part(eye, "head")'''

new_dragon_head = '''    # --- AUTHENTIC DRAGON WARRIOR FACE & HELM ---
    face = create_face_plate("Dragon_FacePlate", (0, -2.5, 172), (8.8, 5.8, 10.5), "face_dragon.png")
    part(face, "head")

    head = uv_part("Dragon_HeadBase", (0, 2.5, 173), (9.0, 8.5, 10.5), titanium_dark)
    part(head, "head")

    jaw_guard = beveled_part("Dragon_JawGuard", (0, -6.8, 163), (8.0, 4.2, 3.5), gold_trim, bevel=0.8, subsurf=True)
    part(jaw_guard, "head")'''

assert old_dragon_head in src, "old_dragon_head not found"
src = src.replace(old_dragon_head, new_dragon_head, 1)
print("5/6 Dragon head upgraded")

# 6) Anubis Head upgrade
old_anubis_head = '''    # --- ANUBIS JACKAL HELM, TALL EARS, SNOUT & NEMES ---
    head = uv_part("Anubis_HeadBase", (0, 0, 172), (10.0, 11.0, 12.0), obsidian_black)
    part(head, "head")

    muzzle = beveled_part("Anubis_Muzzle", (0, -11.0, 169.5), (5.5, 9.5, 4.8), obsidian_black, bevel=1.0, subsurf=True, rotation=(math.radians(8), 0, 0))
    part(muzzle, "head")
    nose = beveled_part("Anubis_Nose", (0, -19.5, 170.8), (3.0, 2.5, 2.2), gold_royal, bevel=0.4)
    part(nose, "head")

    fang_l = beveled_part("Anubis_Fang_L", (2.2, -18.5, 167.5), (0.8, 1.2, 2.2), gold_royal, bevel=0.2)
    part(fang_l, "head")
    fang_r = beveled_part("Anubis_Fang_R", (-2.2, -18.5, 167.5), (0.8, 1.2, 2.2), gold_royal, bevel=0.2)
    part(fang_r, "head")

    for side in (-1, 1):
        eye = beveled_part(f"Anubis_Eye_{side}", (side * 4.0, -10.0, 173.5), (3.2, 0.9, 1.2), emerald_glow, bevel=0.2, rotation=(0, math.radians(-side * 18), math.radians(side * 22)))
        part(eye, "head")'''

new_anubis_head = '''    # --- AUTHENTIC ANUBIS JACKAL VISAGE & NEMES ---
    face = create_face_plate("Anubis_FacePlate", (0, -2.5, 172), (8.5, 5.5, 10.2), "face_anubis.png")
    part(face, "head")

    head = uv_part("Anubis_HeadBase", (0, 2.5, 173), (8.8, 8.5, 10.5), obsidian_black)
    part(head, "head")

    muzzle = beveled_part("Anubis_Muzzle", (0, -9.5, 169.0), (4.5, 7.5, 4.2), obsidian_black, bevel=0.8, subsurf=True, rotation=(math.radians(8), 0, 0))
    part(muzzle, "head")
    nose = beveled_part("Anubis_Nose", (0, -16.5, 170.2), (2.4, 2.0, 1.8), gold_royal, bevel=0.3)
    part(nose, "head")

    fang_l = beveled_part("Anubis_Fang_L", (1.8, -15.5, 167.5), (0.6, 1.0, 1.8), gold_royal, bevel=0.2)
    part(fang_l, "head")
    fang_r = beveled_part("Anubis_Fang_R", (-1.8, -15.5, 167.5), (0.6, 1.0, 1.8), gold_royal, bevel=0.2)
    part(fang_r, "head")'''

assert old_anubis_head in src, "old_anubis_head not found"
src = src.replace(old_anubis_head, new_anubis_head, 1)
print("6/6 Anubis head upgraded")

p.write_text(src, encoding="utf-8")
print(f"ALL_FACES_PATCHED_OK (lines: {src.count(chr(10))})")
