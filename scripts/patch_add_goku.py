import pathlib

p = pathlib.Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate\scripts\blender_generate_fighters.py")
src = p.read_text(encoding="utf-8")

goku_func = '''def build_goku():
    """
    SON GOKU (Ultra Ego / Super Saiyan Ultra with Purple Hair).
    Authentic Toriyama Dragon Ball aesthetic:
    - Iconic Goku spiked hair (massive curved spikes + 3 front bangs) in radiant purple (#9b30ff)
    - Authentic UV-mapped anime face plate with Toriyama eyes, furrowed brow & smirk
    - Orange Turtle School Gi with V-neck cutout revealing navy blue undershirt
    - Toned muscular bare anime arms
    - Navy blue sash belt with tied knot & hanging tails
    - Baggy orange martial arts pants with fabric folds
    - Navy blue wristbands & martial arts boots with red laces
    - Red Power Pole (Nyoi-bo) with gold caps
    """
    reset_scene()
    ensure_output_dirs()

    hair_purple = _advanced_material("M_GokuHair",
        base_color=(0.58, 0.14, 0.95), metallic=0.25, roughness=0.22,
        anisotropic=0.75, clearcoat=0.85, clearcoat_roughness=0.08,
        emission=(0.55, 0.12, 0.90), emission_strength=1.5)
    gi_orange = _advanced_material("M_GokuGi",
        base_color=(0.95, 0.32, 0.10), metallic=0.02, roughness=0.80,
        subsurface=0.10, ior=1.45)
    navy_blue = _advanced_material("M_GokuNavy",
        base_color=(0.08, 0.12, 0.42), metallic=0.04, roughness=0.75)
    skin_toned = _advanced_material("M_GokuSkin",
        base_color=(0.85, 0.62, 0.48), metallic=0.0, roughness=0.52,
        subsurface=0.45, subsurface_radius=(1.1, 0.45, 0.15),
        clearcoat=0.25, clearcoat_roughness=0.10, ior=1.42)
    staff_red = _advanced_material("M_GokuStaff",
        base_color=(0.75, 0.12, 0.12), metallic=0.85, roughness=0.15,
        clearcoat=0.8)
    gold_trim = _advanced_material("M_GokuGold",
        base_color=(0.95, 0.78, 0.20), metallic=0.96, roughness=0.15)
    ki_glow = _advanced_material("M_GokuKi",
        base_color=(0.1, 0.0, 0.2), metallic=0.0, roughness=0.0,
        emission=(0.75, 0.25, 1.0), emission_strength=16.0)

    armature = create_armature("SK_Goku", fighter_bones(scale=1.04, wide=1.04))

    def part(obj, bone_name):
        skin_rigid(obj, armature, bone_name)

    # ── HEAD: AUTHENTIC GOKU FACE & PURPLE SPIKED HAIR ──────────────────
    face = create_face_plate("Goku_FacePlate", (0, -2.5, 168), (8.5, 5.5, 10.0), "face_goku.png")
    part(face, "head")

    skull = uv_part("Goku_Skull", (0, 2.5, 169), (8.6, 8.0, 10.0), skin_toned)
    part(skull, "head")

    # Iconic 3 Front Forehead Bangs (hanging between the eyes)
    bang_center = beveled_part("Goku_Bang_Center", (0, -7.8, 172.5), (2.2, 3.8, 7.2), hair_purple, bevel=0.4,
                              rotation=(math.radians(22), 0, 0))
    part(bang_center, "head")
    bang_left = beveled_part("Goku_Bang_L", (-4.5, -7.2, 173.5), (2.0, 3.2, 6.5), hair_purple, bevel=0.4,
                             rotation=(math.radians(18), math.radians(-14), math.radians(10)))
    part(bang_left, "head")
    bang_right = beveled_part("Goku_Bang_R", (4.5, -7.2, 173.5), (2.0, 3.2, 6.5), hair_purple, bevel=0.4,
                              rotation=(math.radians(18), math.radians(14), math.radians(-10)))
    part(bang_right, "head")

    # Iconic Massive Sweeping Goku Spikes (Left & Right Fanning Tufts)
    spike_l1 = beveled_part("Goku_Spike_L1", (-14.0, 1.0, 184.0), (4.5, 4.2, 12.0), hair_purple, bevel=0.8, subsurf=True,
                            rotation=(math.radians(-10), math.radians(-38), math.radians(25)))
    part(spike_l1, "head")
    spike_l2 = beveled_part("Goku_Spike_L2", (-18.0, 3.0, 173.0), (4.0, 4.5, 13.5), hair_purple, bevel=0.8, subsurf=True,
                            rotation=(math.radians(-15), math.radians(-52), math.radians(12)))
    part(spike_l2, "head")
    spike_l3 = beveled_part("Goku_Spike_L3", (-15.0, 5.0, 162.0), (3.6, 4.0, 11.5), hair_purple, bevel=0.7, subsurf=True,
                            rotation=(math.radians(-22), math.radians(-44), math.radians(-15)))
    part(spike_l3, "head")

    spike_r1 = beveled_part("Goku_Spike_R1", (14.0, 1.0, 185.0), (4.5, 4.2, 12.0), hair_purple, bevel=0.8, subsurf=True,
                            rotation=(math.radians(-10), math.radians(38), math.radians(-25)))
    part(spike_r1, "head")
    spike_r2 = beveled_part("Goku_Spike_R2", (18.0, 3.0, 174.0), (4.0, 4.5, 13.5), hair_purple, bevel=0.8, subsurf=True,
                            rotation=(math.radians(-15), math.radians(52), math.radians(-12)))
    part(spike_r2, "head")

    spike_top = beveled_part("Goku_Spike_Top", (0, 3.5, 194.0), (4.8, 4.5, 14.0), hair_purple, bevel=0.8, subsurf=True,
                             rotation=(math.radians(-12), 0, 0))
    part(spike_top, "head")
    spike_top_l = beveled_part("Goku_Spike_TopL", (-6.5, 4.0, 190.0), (4.2, 4.0, 12.5), hair_purple, bevel=0.7, subsurf=True,
                               rotation=(math.radians(-15), math.radians(-18), math.radians(12)))
    part(spike_top_l, "head")
    spike_top_r = beveled_part("Goku_Spike_TopR", (6.5, 4.0, 190.0), (4.2, 4.0, 12.5), hair_purple, bevel=0.7, subsurf=True,
                               rotation=(math.radians(-15), math.radians(18), math.radians(-12)))
    part(spike_top_r, "head")

    # ── NECK & GI COLLAR ────────────────────────────────────────────────
    neck = cylinder_between("Goku_Neck", (0, 0, 153), (0, 0, 165), 5.5, skin_toned)
    smart_uv(neck); part(neck, "neck")

    # ── TORSO: TURTLE GI WITH V-NECK & NAVY UNDERSHIRT ──────────────────
    undershirt = beveled_part("Goku_Undershirt", (0, 0, 135), (14.0, 9.5, 15.0), navy_blue, bevel=1.8, subsurf=True)
    part(undershirt, "spine_02")

    gi_chest = beveled_part("Goku_Gi_Chest", (0, 0.5, 134), (18.5, 11.5, 20.0), gi_orange, bevel=2.4, subsurf=True)
    part(gi_chest, "spine_02")

    lapel_l = beveled_part("Goku_Lapel_L", (-5.5, -11.0, 140.0), (4.5, 1.8, 14.0), gi_orange, bevel=0.4,
                           rotation=(math.radians(12), math.radians(-18), math.radians(15)))
    part(lapel_l, "spine_02")
    lapel_r = beveled_part("Goku_Lapel_R", (5.5, -11.0, 140.0), (4.5, 1.8, 14.0), gi_orange, bevel=0.4,
                           rotation=(math.radians(12), math.radians(18), math.radians(-15)))
    part(lapel_r, "spine_02")

    kanji_badge = beveled_part("Goku_Kanji_Badge", (-7.5, -11.8, 141.0), (2.8, 0.6, 2.8), gold_trim, bevel=0.2)
    part(kanji_badge, "spine_02")

    gi_ab = beveled_part("Goku_Gi_Ab", (0, 0, 112), (15.5, 9.5, 14.0), gi_orange, bevel=2.0, subsurf=True)
    part(gi_ab, "spine_01")

    belt = beveled_part("Goku_Belt_Main", (0, 0, 96), (16.8, 10.2, 5.5), navy_blue, bevel=1.2, subsurf=True)
    part(belt, "pelvis")
    belt_knot = beveled_part("Goku_Belt_Knot", (-14.0, -4.5, 95.0), (3.5, 3.2, 4.0), navy_blue, bevel=0.6)
    part(belt_knot, "pelvis")
    sash_tail1 = beveled_part("Goku_Sash_Tail1", (-14.5, -5.0, 83.0), (2.2, 1.5, 12.0), navy_blue, bevel=0.3,
                              rotation=(math.radians(8), 0, math.radians(-10)))
    part(sash_tail1, "pelvis")
    sash_tail2 = beveled_part("Goku_Sash_Tail2", (-13.0, -4.5, 80.0), (2.0, 1.4, 14.0), navy_blue, bevel=0.3,
                              rotation=(math.radians(12), 0, math.radians(8)))
    part(sash_tail2, "pelvis")

    # ── ARMS: TONED MUSCULAR ANIME ARMS & NAVY WRISTBANDS ───────────────
    for side, sfx, ubone, lbone, hbone in (
            (1, "L", "upperarm_l", "lowerarm_l", "hand_l"),
            (-1, "R", "upperarm_r", "lowerarm_r", "hand_r")):
        sw = side
        ux, lx, hx = sw * 48, sw * 74, sw * 88

        cuff = beveled_part(f"Goku_Gi_Cuff_{sfx}", (sw * 34, 0, 143), (6.5, 9.0, 6.0), gi_orange, bevel=1.0, subsurf=True)
        part(cuff, ubone)

        bicep = cylinder_between(f"Goku_UpperArm_{sfx}", (sw * 34, 0, 142), (ux, 0, 128), 7.5, skin_toned)
        smart_uv(bicep); part(bicep, ubone)

        elbow = beveled_part(f"Goku_Elbow_{sfx}", (ux, 0, 128), (7.0, 7.0, 6.0), skin_toned, bevel=1.2, subsurf=True)
        part(elbow, ubone)

        forearm = cylinder_between(f"Goku_LowerArm_{sfx}", (ux, 0, 126), (lx, 0, 110), 6.8, skin_toned)
        smart_uv(forearm); part(forearm, lbone)

        wristband = beveled_part(f"Goku_Wristband_{sfx}", (sw * 64, 0, 114), (6.2, 6.2, 10.5), navy_blue, bevel=0.8, subsurf=True)
        part(wristband, lbone)
        wrist_trim = beveled_part(f"Goku_WristTrim_{sfx}", (sw * 64, 0, 119), (6.5, 6.5, 1.4), gold_trim, bevel=0.2)
        part(wrist_trim, lbone)

        hand = beveled_part(f"Goku_Hand_{sfx}", (hx, 0, 102), (7.2, 6.0, 9.5), skin_toned, bevel=1.4, subsurf=True)
        part(hand, hbone)

    # ── POWER POLE (NYOI-BŌ) ON RIGHT HAND ──────────────────────────────
    pole_shaft = cylinder_between("Goku_Pole_Shaft", (-88, 0, 30), (-88, 0, 170), 2.2, staff_red, vertices=12)
    smart_uv(pole_shaft); part(pole_shaft, "hand_r")
    pole_cap_top = beveled_part("Goku_Pole_CapTop", (-88, 0, 172), (2.8, 2.8, 3.0), gold_trim, bevel=0.5)
    part(pole_cap_top, "hand_r")
    pole_cap_bot = beveled_part("Goku_Pole_CapBot", (-88, 0, 28), (2.8, 2.8, 3.0), gold_trim, bevel=0.5)
    part(pole_cap_bot, "hand_r")
    ki_ball = beveled_part("Goku_Ki_Aura", (-88, 0, 176), (2.2, 2.2, 2.2), ki_glow, bevel=0.4)
    part(ki_ball, "hand_r")

    # ── LEGS: BAGGY MARTIAL ARTS PANTS & MARTIAL ARTS BOOTS ─────────────
    for side, sfx, thbone, cfbone, ftbone in (
            (1, "L", "thigh_l", "calf_l", "foot_l"),
            (-1, "R", "thigh_r", "calf_r", "foot_r")):
        sw = side

        thigh = cylinder_between(f"Goku_Pants_Thigh_{sfx}", (sw * 21, 0, 88), (sw * 23, 0, 54), 10.5, gi_orange)
        smart_uv(thigh); part(thigh, thbone)
        thigh_fold = beveled_part(f"Goku_PantsFold_{sfx}", (sw * 22, -2.5, 70), (10.0, 9.5, 12.0), gi_orange, bevel=2.0, subsurf=True)
        part(thigh_fold, thbone)

        knee = beveled_part(f"Goku_Knee_{sfx}", (sw * 23, -2.0, 54), (9.0, 8.5, 7.5), gi_orange, bevel=1.5, subsurf=True)
        part(knee, cfbone)

        calf = cylinder_between(f"Goku_Pants_Calf_{sfx}", (sw * 23, 0, 52), (sw * 21, 0, 22), 9.2, gi_orange)
        smart_uv(calf); part(calf, cfbone)

        boot_shaft = cylinder_between(f"Goku_Boot_Shaft_{sfx}", (sw * 21, 0, 24), (sw * 21, 0, 10), 8.0, navy_blue)
        smart_uv(boot_shaft); part(boot_shaft, cfbone)
        boot_lace = beveled_part(f"Goku_Boot_Lace_{sfx}", (sw * 21, -7.5, 18), (2.2, 1.2, 9.0), staff_red, bevel=0.2)
        part(boot_lace, cfbone)

        foot = beveled_part(f"Goku_Foot_{sfx}", (sw * 20, -6, 7), (8.5, 17.5, 6.0), navy_blue, bevel=1.8, subsurf=True)
        part(foot, ftbone)
        sole = beveled_part(f"Goku_Sole_{sfx}", (sw * 20, -6, 1.8), (9.0, 18.0, 1.8), hair_purple, bevel=0.3)
        part(sole, ftbone)

    add_combat_actions(armature, "Goku", heavy=False)
    setup_hero_camera(120, 280, lens=48)
    add_preview_lights(120, energy=5500)
    render_preview("goku_model_preview.png")
    save_and_export(armature, "PFU_SonGoku.blend", "PFU_SonGoku.fbx")
    print("GOKU_GEN_OK")

'''

# Insert before if __name__ == "__main__":
main_anchor = 'if __name__ == "__main__":'
assert main_anchor in src, "main_anchor not found"
src = src.replace(main_anchor, goku_func + "\n" + main_anchor, 1)

# Update __main__ to support --only-goku
old_main = '''if __name__ == "__main__":
    import sys
    if "--only-ninja" in sys.argv:
        build_ninja()
    elif "--only-golem" in sys.argv:
        build_golem()
    elif "--only-valkyrie" in sys.argv:
        build_valkyrie()
    elif "--only-dragon" in sys.argv:
        build_dragon()
    elif "--only-anubis" in sys.argv:
        build_anubis()
    elif "--only-specter" in sys.argv:
        build_specter()
    elif "--only-phoenix" in sys.argv:
        build_phoenix()
    else:
        build_ninja()
        build_golem()
        build_valkyrie()
        build_dragon()
        build_anubis()
        build_specter()
        build_phoenix()
    print("ALL_PFU_FIGHTERS_READY")'''

new_main = '''if __name__ == "__main__":
    import sys
    if "--only-ninja" in sys.argv:
        build_ninja()
    elif "--only-golem" in sys.argv:
        build_golem()
    elif "--only-valkyrie" in sys.argv:
        build_valkyrie()
    elif "--only-dragon" in sys.argv:
        build_dragon()
    elif "--only-anubis" in sys.argv:
        build_anubis()
    elif "--only-specter" in sys.argv:
        build_specter()
    elif "--only-phoenix" in sys.argv:
        build_phoenix()
    elif "--only-goku" in sys.argv:
        build_goku()
    else:
        build_ninja()
        build_golem()
        build_valkyrie()
        build_dragon()
        build_anubis()
        build_specter()
        build_phoenix()
        build_goku()
    print("ALL_PFU_FIGHTERS_READY")'''

assert old_main in src, "old_main not found"
src = src.replace(old_main, new_main, 1)

p.write_text(src, encoding="utf-8")
print(f"GOKU_ADDED_TO_BUILDER_OK (lines: {src.count(chr(10))})")
