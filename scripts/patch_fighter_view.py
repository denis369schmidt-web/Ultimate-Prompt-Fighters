import pathlib

p = pathlib.Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate\godot\scripts\fighter_view.gd")
src = p.read_text(encoding="utf-8")

# 1) Preserve authentic face plates & UV-mapped textures
old_surface_start = '''\tfor mesh in model.find_children("*", "MeshInstance3D", true, false):
\t\tfor surface in range(mesh.mesh.get_surface_count()):
\t\t\tvar original = mesh.get_active_material(surface)
\t\t\tif original is StandardMaterial3D:
\t\t\t\tvar mat: StandardMaterial3D = original.duplicate()
\t\t\t\tmat.cull_mode = BaseMaterial3D.CULL_DISABLED
\t\t\t\tmat.uv1_scale = triplanar_scale
\t\t\t\tmat.uv1_triplanar = true'''

new_surface_start = '''\tfor mesh in model.find_children("*", "MeshInstance3D", true, false):
\t\tfor surface in range(mesh.mesh.get_surface_count()):
\t\t\tvar original = mesh.get_active_material(surface)
\t\t\tif original is StandardMaterial3D:
\t\t\t\tvar mat: StandardMaterial3D = original.duplicate()
\t\t\t\tmat.cull_mode = BaseMaterial3D.CULL_DISABLED

\t\t\t\t# PRESERVE AUTHENTIC FACE PLATES & UV-MAPPED FACIAL DETAILS
\t\t\t\tif "Face" in mesh.name or "FacePlate" in mesh.name or "Face" in mat.resource_name:
\t\t\t\t\tmat.uv1_triplanar = false
\t\t\t\t\tmat.rim_enabled = true
\t\t\t\t\tmat.rim = 0.50
\t\t\t\t\tmat.rim_tint = 0.40
\t\t\t\t\tmat.roughness = 0.48
\t\t\t\t\tmat.metallic = 0.0
\t\t\t\t\tmesh.set_surface_override_material(surface, mat)
\t\t\t\t\tcontinue

\t\t\t\tmat.uv1_scale = triplanar_scale
\t\t\t\tmat.uv1_triplanar = true'''

assert old_surface_start in src, "old_surface_start not found"
src = src.replace(old_surface_start, new_surface_start, 1)
print("1/2 Face plate preservation added to fighter_view.gd")

# 2) Add goku, phoenix, anubis, specter branches
old_ninja_branch = '''\t\t\t\telse: # Ninja
\t\t\t\t\tif "Eye" in mesh.name or "Visor" in mesh.name or "Conduit" in mesh.name or "PowerPort" in mesh.name or "GreaveGlow" in mesh.name or "BackNode" in mesh.name or "Center" in mesh.name:'''

new_all_branches = '''\t\t\t\telif p.family == "goku":
\t\t\t\t\tif "Hair" in mesh.name or "Spike" in mesh.name or "Bang" in mesh.name or "Crown" in mesh.name:
\t\t\t\t\t\t# Ultra Ego / Super Saiyan Ultra Radiant Purple Spiked Hair
\t\t\t\t\t\tmat.albedo_color = Color("9b30ff")
\t\t\t\t\t\tmat.roughness = 0.22
\t\t\t\t\t\tmat.metallic = 0.25
\t\t\t\t\t\tmat.rim_enabled = true
\t\t\t\t\t\tmat.rim = 1.0
\t\t\t\t\t\tmat.rim_tint = 0.85
\t\t\t\t\t\tmat.emission_enabled = true
\t\t\t\t\t\tmat.emission = Color("8a2be2")
\t\t\t\t\t\tmat.emission_energy_multiplier = 0.85
\t\t\t\t\telif "Gi" in mesh.name or "Pants" in mesh.name or "Torso" in mesh.name or "Chest" in mesh.name or "Tunic" in mesh.name:
\t\t\t\t\t\t# Authentic Turtle School Orange Martial Arts Gi
\t\t\t\t\t\tmat.albedo_color = Color("ff5722")
\t\t\t\t\t\tmat.roughness = 0.82
\t\t\t\t\t\tmat.metallic = 0.02
\t\t\t\t\telif "Undershirt" in mesh.name or "Belt" in mesh.name or "Sash" in mesh.name or "Wrist" in mesh.name or "Boot" in mesh.name or "Knot" in mesh.name:
\t\t\t\t\t\t# Navy Blue undershirt, sash belt & martial arts wristbands
\t\t\t\t\t\tmat.albedo_color = Color("1a237e")
\t\t\t\t\t\tmat.roughness = 0.75
\t\t\t\t\t\tmat.metallic = 0.05
\t\t\t\t\telif "Skin" in mat.resource_name or "Arm" in mesh.name or "Neck" in mesh.name or "Head" in mesh.name:
\t\t\t\t\t\t# Toned anime martial artist tan skin
\t\t\t\t\t\tmat.albedo_color = Color("f8d2b8")
\t\t\t\t\t\tmat.roughness = 0.52
\t\t\t\t\t\tmat.metallic = 0.0
\t\t\t\t\t\tmat.rim_enabled = true
\t\t\t\t\t\tmat.rim = 0.45
\t\t\t\t\telif "Pole" in mesh.name or "Staff" in mesh.name:
\t\t\t\t\t\t# Power Pole (Nyoi-bo) crimson red & gold
\t\t\t\t\t\tmat.albedo_color = Color("c62828")
\t\t\t\t\t\tmat.metallic = 0.85
\t\t\t\t\t\tmat.roughness = 0.15
\t\t\t\t\telif "Aura" in mesh.name or "Ki" in mesh.name or "Core" in mesh.name:
\t\t\t\t\t\tmat.albedo_color = Color(2.0, 1.0, 2.5)
\t\t\t\t\t\tmat.emission_enabled = true
\t\t\t\t\t\tmat.emission = Color("b347ff")
\t\t\t\t\t\tmat.emission_energy_multiplier = 5.5
\t\t\t\t\t\tglow_materials.append(mat)
\t\t\t\t\t\tbase_emissions.append(5.5)
\t\t\t\t\telse:
\t\t\t\t\t\tmat.albedo_color = Color("ff5722")
\t\t\t\t\t\tmat.roughness = 0.85
\t\t\t\telif p.family == "phoenix":
\t\t\t\t\tif "Feather" in mesh.name or "Wing" in mesh.name or "Paul" in mesh.name or "Chest" in mesh.name or "Crown" in mesh.name:
\t\t\t\t\t\tmat.albedo_color = Color("d83212")
\t\t\t\t\t\tmat.roughness = 0.22
\t\t\t\t\t\tmat.metallic = 0.35
\t\t\t\t\t\tmat.rim_enabled = true
\t\t\t\t\t\tmat.rim = 0.85
\t\t\t\t\telif "Gold" in mesh.name or "Trim" in mesh.name or "Claw" in mesh.name:
\t\t\t\t\t\tmat.albedo_color = Color("f5c227")
\t\t\t\t\t\tmat.metallic = 0.95
\t\t\t\t\t\tmat.roughness = 0.12
\t\t\t\t\telif "Fire" in mesh.name or "Gem" in mesh.name or "Lava" in mesh.name or "Core" in mesh.name or "Glaive" in mesh.name:
\t\t\t\t\t\tmat.albedo_color = Color(2.5, 1.5, 0.5)
\t\t\t\t\t\tmat.emission_enabled = true
\t\t\t\t\t\tmat.emission = Color("ff6d2b")
\t\t\t\t\t\tmat.emission_energy_multiplier = 5.0
\t\t\t\t\t\tglow_materials.append(mat)
\t\t\t\t\t\tbase_emissions.append(5.0)
\t\t\t\t\telse:
\t\t\t\t\t\tmat.albedo_color = Color("8c1206")
\t\t\t\t\t\tmat.roughness = 0.45
\t\t\t\telif p.family == "anubis":
\t\t\t\t\tif "Gold" in mesh.name or "Trim" in mesh.name or "EarInner" in mesh.name or "Fang" in mesh.name or "Uraeus" in mesh.name or "Khopesh" in mesh.name:
\t\t\t\t\t\tmat.albedo_color = Color("f0be24")
\t\t\t\t\t\tmat.metallic = 0.96
\t\t\t\t\t\tmat.roughness = 0.14
\t\t\t\t\telif "Lapis" in mesh.name or "Nemes" in mesh.name:
\t\t\t\t\t\tmat.albedo_color = Color("142864")
\t\t\t\t\t\tmat.roughness = 0.35
\t\t\t\t\t\tmat.metallic = 0.30
\t\t\t\t\telif "Emerald" in mesh.name or "Glow" in mesh.name:
\t\t\t\t\t\tmat.albedo_color = Color(0.8, 2.5, 1.5)
\t\t\t\t\t\tmat.emission_enabled = true
\t\t\t\t\t\tmat.emission = Color("2be58f")
\t\t\t\t\t\tmat.emission_energy_multiplier = 4.8
\t\t\t\t\t\tglow_materials.append(mat)
\t\t\t\t\t\tbase_emissions.append(4.8)
\t\t\t\t\telse:
\t\t\t\t\t\tmat.albedo_color = Color("1a1c22")
\t\t\t\t\t\tmat.metallic = 0.70
\t\t\t\t\t\tmat.roughness = 0.25
\t\t\t\telif p.family == "specter":
\t\t\t\t\tif "Crystal" in mesh.name or "Lance" in mesh.name or "Prism" in mesh.name or "Spike" in mesh.name:
\t\t\t\t\t\tmat.albedo_color = Color("c088ff")
\t\t\t\t\t\tmat.metallic = 0.80
\t\t\t\t\t\tmat.roughness = 0.08
\t\t\t\t\t\tmat.rim_enabled = true
\t\t\t\t\t\tmat.rim = 0.95
\t\t\t\t\telif "Void" in mesh.name or "Glow" in mesh.name or "Eye" in mesh.name or "Core" in mesh.name:
\t\t\t\t\t\tmat.albedo_color = Color(2.0, 1.2, 3.0)
\t\t\t\t\t\tmat.emission_enabled = true
\t\t\t\t\t\tmat.emission = Color("9b30ff")
\t\t\t\t\t\tmat.emission_energy_multiplier = 5.2
\t\t\t\t\t\tglow_materials.append(mat)
\t\t\t\t\t\tbase_emissions.append(5.2)
\t\t\t\t\telse:
\t\t\t\t\t\tmat.albedo_color = Color("181028")
\t\t\t\t\t\tmat.metallic = 0.65
\t\t\t\t\t\tmat.roughness = 0.22
\t\t\t\telse: # Ninja
\t\t\t\t\tif "Eye" in mesh.name or "Visor" in mesh.name or "Conduit" in mesh.name or "PowerPort" in mesh.name or "GreaveGlow" in mesh.name or "BackNode" in mesh.name or "Center" in mesh.name:'''

assert old_ninja_branch in src, "old_ninja_branch not found"
src = src.replace(old_ninja_branch, new_all_branches, 1)
print("2/2 All character branches added to fighter_view.gd")

p.write_text(src, encoding="utf-8")
print(f"FIGHTER_VIEW_PATCHED_OK (lines: {src.count(chr(10))})")
