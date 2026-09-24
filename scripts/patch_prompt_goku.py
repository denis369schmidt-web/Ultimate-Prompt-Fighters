import pathlib

p = pathlib.Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate\godot\scripts\prompt_interpreter.gd")
src = p.read_text(encoding="utf-8")

old_checks = '''    var phoenix := not dragon and not valkyrie and not heavy and not anubis and not specter and has_any(lower, ["phoenix", "phönix", "empress", "kaiserin", "feather", "feder", "glaive", "fire queen", "firebird", "feuervogel", "fenix"])
    # Stats: phoenix has balanced offensive + high technique
    var values: Array = [27, 24, 27, 10, 12] if heavy else ([23, 26, 21, 15, 15] if dragon else ([17, 22, 16, 23, 22] if valkyrie else ([20, 28, 18, 18, 16] if anubis else ([16, 25, 17, 22, 20] if specter else ([19, 24, 15, 20, 22] if phoenix else [18, 20, 14, 29, 19])))))'''

new_checks = '''    var phoenix := not dragon and not valkyrie and not heavy and not anubis and not specter and has_any(lower, ["phoenix", "phönix", "empress", "kaiserin", "feather", "feder", "glaive", "fire queen", "firebird", "feuervogel", "fenix"])
    var goku := not dragon and not valkyrie and not heavy and not anubis and not specter and not phoenix and has_any(lower, ["goku", "son goku", "saiyajin", "saiyan", "kakarot", "ultra ego", "dragonball", "dragon ball", "kamehameha", "ultra instinct", "ssj", "lila", "purple", "violet"])
    var values: Array = [27, 24, 27, 10, 12] if heavy else ([23, 26, 21, 15, 15] if dragon else ([17, 22, 16, 23, 22] if valkyrie else ([20, 28, 18, 18, 16] if anubis else ([16, 25, 17, 22, 20] if specter else ([19, 24, 15, 20, 22] if phoenix else ([22, 28, 16, 22, 22] if goku else [18, 20, 14, 29, 19]))))))'''

assert old_checks in src, "old_checks not found"
src = src.replace(old_checks, new_checks, 1)

old_element = '''    var element := "fire" if dragon else ("holy" if valkyrie else ("shadow_gold" if anubis else ("void" if specter else ("fire" if phoenix else "shadow"))))'''
new_element = '''    var element := "fire" if dragon else ("holy" if valkyrie else ("shadow_gold" if anubis else ("void" if specter else ("fire" if phoenix else ("ki_purple" if goku else "shadow")))))'''
assert old_element in src, "old_element not found"
src = src.replace(old_element, new_element, 1)

old_colors = '''    var colors := {"electric": Color("43e5ff"), "fire": Color("ff733e"), "ice": Color("b4e5ff"), "wind": Color("9dffcd"), "shadow": Color("b19dff"), "holy": Color("ffe26a"), "shadow_gold": Color("c9a227"), "void": Color("9b30ff")}'''
new_colors = '''    var colors := {"electric": Color("43e5ff"), "fire": Color("ff733e"), "ice": Color("b4e5ff"), "wind": Color("9dffcd"), "shadow": Color("b19dff"), "holy": Color("ffe26a"), "shadow_gold": Color("c9a227"), "void": Color("9b30ff"), "ki_purple": Color("b347ff")}'''
assert old_colors in src, "old_colors not found"
src = src.replace(old_colors, new_colors, 1)

old_std = '''    var std_range: float = 1.55 if heavy else (1.95 if dragon else (1.85 if valkyrie else (2.10 if anubis else (2.20 if specter else (2.00 if phoenix else 1.75)))))'''
new_std = '''    var std_range: float = 1.55 if heavy else (1.95 if dragon else (1.85 if valkyrie else (2.10 if anubis else (2.20 if specter else (2.00 if phoenix else (2.15 if goku else 1.75))))))'''
assert old_std in src, "old_std not found"
src = src.replace(old_std, new_std, 1)

old_family = '''    var family := "golem" if heavy else ("dragon" if dragon else ("valkyrie" if valkyrie else ("anubis" if anubis else ("specter" if specter else ("phoenix" if phoenix else "ninja")))))
    var fname := "CINDER BASTION" if heavy else ("IGNIS DRAKE" if dragon else ("VALKYRIE AURA" if valkyrie else ("CYBER ANUBIS" if anubis else ("VOID SPECTER" if specter else ("PHOENIX EMPRESS" if phoenix else "VOLT SHADOW")))))
    var modules := ["basalt", "gauntlets"] if heavy else (["dragon_plate", "greatsword"] if dragon else (["radiant_armor", "light_rapier"] if valkyrie else (["anubis_armor", "khopesh"] if anubis else (["crystal_armor", "void_lance"] if specter else (["feather_armor", "phoenix_glaive"] if phoenix else ["shadow_armor", "twin_blades"])))))'''

new_family = '''    var family := "golem" if heavy else ("dragon" if dragon else ("valkyrie" if valkyrie else ("anubis" if anubis else ("specter" if specter else ("phoenix" if phoenix else ("goku" if goku else "ninja"))))))
    var fname := "CINDER BASTION" if heavy else ("IGNIS DRAKE" if dragon else ("VALKYRIE AURA" if valkyrie else ("CYBER ANUBIS" if anubis else ("VOID SPECTER" if specter else ("PHOENIX EMPRESS" if phoenix else ("SON GOKU (ULTRA)" if goku else "VOLT SHADOW"))))))
    var modules := ["basalt", "gauntlets"] if heavy else (["dragon_plate", "greatsword"] if dragon else (["radiant_armor", "light_rapier"] if valkyrie else (["anubis_armor", "khopesh"] if anubis else (["crystal_armor", "void_lance"] if specter else (["feather_armor", "phoenix_glaive"] if phoenix else (["turtle_gi", "power_pole"] if goku else ["shadow_armor", "twin_blades"]))))))'''

assert old_family in src, "old_family not found"
src = src.replace(old_family, new_family, 1)

old_valid = '''        (p.family == "specter" and p.modules == ["crystal_armor", "void_lance"]) or
        (p.family == "phoenix" and p.modules == ["feather_armor", "phoenix_glaive"]))'''

new_valid = '''        (p.family == "specter" and p.modules == ["crystal_armor", "void_lance"]) or
        (p.family == "phoenix" and p.modules == ["feather_armor", "phoenix_glaive"]) or
        (p.family == "goku" and p.modules == ["turtle_gi", "power_pole"]))'''

assert old_valid in src, "old_valid not found"
src = src.replace(old_valid, new_valid, 1)

p.write_text(src, encoding="utf-8")
print("PROMPT_INTERPRETER_GOKU_OK")
