import pathlib

p = pathlib.Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate\scripts\blender_generate_fighters.py")
src = p.read_text(encoding="utf-8")

old_goku_bangs = '''    # Iconic 3 Front Forehead Bangs (hanging between the eyes)
    bang_center = beveled_part("Goku_Bang_Center", (0, -7.8, 172.5), (2.2, 3.8, 7.2), hair_purple, bevel=0.4,
                              rotation=(math.radians(22), 0, 0))
    part(bang_center, "head")
    bang_left = beveled_part("Goku_Bang_L", (-4.5, -7.2, 173.5), (2.0, 3.2, 6.5), hair_purple, bevel=0.4,
                             rotation=(math.radians(18), math.radians(-14), math.radians(10)))
    part(bang_left, "head")
    bang_right = beveled_part("Goku_Bang_R", (4.5, -7.2, 173.5), (2.0, 3.2, 6.5), hair_purple, bevel=0.4,
                              rotation=(math.radians(18), math.radians(14), math.radians(-10)))
    part(bang_right, "head")'''

new_goku_bangs = '''    # Iconic 3 Front Forehead Bangs (framing forehead above the eyes so face is clearly visible)
    bang_center = beveled_part("Goku_Bang_Center", (0, -7.5, 175.5), (2.0, 2.5, 3.8), hair_purple, bevel=0.4,
                              rotation=(math.radians(18), 0, 0))
    part(bang_center, "head")
    bang_left = beveled_part("Goku_Bang_L", (-5.2, -6.8, 175.0), (1.8, 2.2, 3.6), hair_purple, bevel=0.4,
                             rotation=(math.radians(16), math.radians(-18), math.radians(12)))
    part(bang_left, "head")
    bang_right = beveled_part("Goku_Bang_R", (5.2, -6.8, 175.0), (1.8, 2.2, 3.6), hair_purple, bevel=0.4,
                              rotation=(math.radians(16), math.radians(18), math.radians(-12)))
    part(bang_right, "head")'''

assert old_goku_bangs in src, "old_goku_bangs not found"
src = src.replace(old_goku_bangs, new_goku_bangs, 1)

old_goku_hair_mat = '''    hair_purple = _advanced_material("M_GokuHair",
        base_color=(0.58, 0.14, 0.95), metallic=0.25, roughness=0.22,
        anisotropic=0.75, clearcoat=0.85, clearcoat_roughness=0.08,
        emission=(0.55, 0.12, 0.90), emission_strength=1.5)'''

new_goku_hair_mat = '''    hair_purple = _advanced_material("M_GokuHair",
        base_color=(0.42, 0.08, 0.75), metallic=0.35, roughness=0.18,
        anisotropic=0.85, clearcoat=1.0, clearcoat_roughness=0.04,
        emission=(0.32, 0.05, 0.60), emission_strength=0.6)'''

assert old_goku_hair_mat in src, "old_goku_hair_mat not found"
src = src.replace(old_goku_hair_mat, new_goku_hair_mat, 1)

p.write_text(src, encoding="utf-8")
print("GOKU_BANGS_FIXED_OK")
