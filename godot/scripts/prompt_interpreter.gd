extends RefCounted
## Pure local provider. Replace interpret() with a validated provider later, never execute prompt text.

const STAT_KEYS = ["vitality", "power", "defense", "speed", "technique"]
const ELEMENTS = {
	"electric": ["blitz", "elektr", "electric", "storm"],
	"fire": ["lava", "feuer", "fire", "brenn", "phoenix", "phönix", "flamme"],
	"ice": ["eis", "ice", "frost"],
	"wind": ["wind", "air"]
}

static func interpret(raw: Variant, slot: int = 0) -> Dictionary:
	var text := str(raw).strip_edges().left(512) if raw is String else ""
	if text.is_empty(): text = "Ausgeglichener Kämpfer"
	var lower := text.to_lower()
	var seed_value: int = 2166136261
	for character in lower:
		seed_value = ((seed_value ^ character.unicode_at(0)) * 16777619) & 0x7fffffff
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var goku := has_any(lower, ["goku", "son goku", "saiyajin", "saiyan", "kakarot", "ultra ego", "kamehameha", "ultra instinct", "ssj"])
	var luffy := not goku and has_any(lower, ["luffy", "ruffy", "straw hat", "strohhut", "gum gum", "gum-gum", "one piece", "mugiwara", "gum gum pistole"])
	var subzero := not goku and not luffy and has_any(lower, ["sub zero", "subzero", "sub-zero", "cryomancer", "ice ninja", "lin kuei", "kori", "mortal kombat"])
	var pain := not goku and not luffy and not subzero and has_any(lower, ["pain", "nagato", "rinnegan", "akatsuki", "tendo", "deva path", "shinra tensei"])
	var sonic := not goku and not luffy and not subzero and not pain and has_any(lower, ["sonic", "hedgehog", "blue blur", "spin dash", "sega", "chaos emerald", "supersonic"])
	var akaza := not goku and not luffy and not subzero and not pain and not sonic and has_any(lower, ["akaza", "akaze", "upper rank", "upper moon", "hakai satsu", "compass needle", "soryu", "demon slayer", "kimetsu", "destructivedeath"])
	var blue_eyes := not goku and not luffy and not subzero and not pain and not sonic and not akaza and has_any(lower, ["weiße drache", "weisse drache", "weisser drache", "weißer drache", "blue-eyes", "blue eyes", "white dragon", "burst stream", "white lightning", "yu-gi-oh", "yugioh", "kaiba", "eiskalten blick", "eiskalter blick"])
	var anubis := not goku and not luffy and not subzero and not pain and not sonic and not akaza and not blue_eyes and has_any(lower, ["anubis", "jackal", "khopesh", "ägyptisch", "egypt", "pharaoh", "pharao", "underworld", "unterwelt", "osiris", "jackal god"])
	var phoenix := not goku and not luffy and not subzero and not pain and not sonic and not akaza and not blue_eyes and not anubis and has_any(lower, ["phoenix", "phönix", "empress", "kaiserin", "glaive", "fire queen", "firebird", "feuervogel", "fenix"])
	var specter := not goku and not luffy and not subzero and not pain and not sonic and not akaza and not blue_eyes and not anubis and not phoenix and has_any(lower, ["specter", "spectre", "void lance", "phantom warrior", "kristall phantom", "wraith", "crystal"])
	var valkyrie := not goku and not luffy and not subzero and not pain and not sonic and not akaza and not blue_eyes and not anubis and not phoenix and not specter and has_any(lower, ["valkyrie", "walküre", "moe", "paladin", "angel", "engel", "lichtflügel", "waifu"])
	var dragon := not goku and not luffy and not subzero and not pain and not sonic and not akaza and not blue_eyes and not anubis and not phoenix and not specter and not valkyrie and (has_any(lower, ["drachenritter", "drake", "wyrm", "slayer", "drakon", "drache"]) or (lower.contains("dragon") and not lower.contains("dragon ball") and not lower.contains("dragonball")))
	var heavy := not goku and not luffy and not subzero and not pain and not sonic and not akaza and not blue_eyes and not anubis and not phoenix and not specter and not valkyrie and not dragon and has_any(lower, ["golem", "panzer", "lavagolem", "tank", "stein", "heavy", "titan"])

	var values: Array = [20, 26, 16, 20, 18] if goku else ([18, 28, 16, 26, 12] if luffy else ([18, 26, 16, 24, 16] if subzero else ([20, 27, 17, 19, 17] if pain else ([16, 22, 14, 34, 14] if sonic else ([22, 28, 16, 22, 12] if akaza else ([22, 30, 20, 18, 10] if blue_eyes else ([20, 28, 18, 18, 16] if anubis else ([19, 24, 15, 20, 22] if phoenix else ([16, 25, 17, 22, 20] if specter else ([17, 22, 16, 23, 22] if valkyrie else ([23, 26, 21, 15, 15] if dragon else ([27, 24, 27, 10, 12] if heavy else [18, 20, 14, 29, 19]))))))))))))
	for n in range(8):
		var a := rng.randi_range(0, 4)
		var b := rng.randi_range(0, 4)
		if a != b and values[a] > 8 and values[b] < 36:
			values[a] -= 1
			values[b] += 1
	var stats := {}
	for n in range(5): stats[STAT_KEYS[n]] = values[n]
	var element := "ki_purple" if goku else ("rubber" if luffy else ("ice" if subzero else ("gravity" if pain else ("wind" if sonic else ("blood_demon" if akaza else ("holy_light" if blue_eyes else ("shadow_gold" if anubis else ("fire" if phoenix else ("void" if specter else ("holy" if valkyrie else ("fire" if dragon else ("fire" if heavy else "shadow"))))))))))))
	for candidate in ELEMENTS:
		if has_any(lower, ELEMENTS[candidate]):
			element = candidate
			break
	var colors := {"electric": Color("43e5ff"), "fire": Color("ff733e"), "ice": Color("b4e5ff"), "wind": Color("9dffcd"), "shadow": Color("b19dff"), "holy": Color("ffe26a"), "shadow_gold": Color("c9a227"), "void": Color("9b30ff"), "ki_purple": Color("b347ff"), "gravity": Color("9900ee"), "rubber": Color("ff2b2b"), "blood_demon": Color("00e5ff"), "holy_light": Color("70d6ff")}
	var std_range: float = 2.15 if goku else (2.85 if luffy else (1.80 if subzero else (2.30 if pain else (1.65 if sonic else (2.10 if akaza else (2.20 if blue_eyes else (2.10 if anubis else (2.00 if phoenix else (2.20 if specter else (1.85 if valkyrie else (1.95 if dragon else (1.55 if heavy else 1.75))))))))))))
	var std_cooldown: float = 0.57 if goku else (0.52 if luffy else (0.54 if subzero else (0.56 if pain else (0.44 if sonic else (0.48 if akaza else (0.54 if blue_eyes else (0.62 if anubis else (0.55 if phoenix else (0.58 if specter else (0.52 if valkyrie else (0.72 if dragon else (0.9 if heavy else 0.60))))))))))))
	var std_windup: float = 0.12 if goku else (0.10 if luffy else (0.10 if subzero else (0.11 if pain else (0.08 if sonic else (0.09 if akaza else (0.11 if blue_eyes else (0.13 if anubis else (0.11 if phoenix else (0.11 if specter else (0.10 if valkyrie else (0.16 if dragon else (0.22 if heavy else 0.12))))))))))))
	var weight: float = 1.32 if heavy else (1.28 if blue_eyes else (1.20 if dragon else (1.08 if anubis else (1.05 if (goku or pain) else (1.02 if akaza else (0.88 if sonic else (0.98 if (specter or phoenix) else 0.92)))))))
	var std_angle: float = 28.0
	var spec_angle: float = 52.0 if heavy else (45.0 if pain else (42.0 if blue_eyes else (40.0 if akaza else (35.0 if (luffy or sonic) else 42.0))))
	var spec_ability_name: String = "Kamehameha" if goku else ("Gum-Gum Pistol" if luffy else ("Kori Ice Shard" if subzero else ("Shinra Tensei" if pain else ("Super Spin Dash" if sonic else ("Destructive Death: Compass Needle" if akaza else ("Burst Stream of Destruction" if blue_eyes else ("Anubis Wrath" if anubis else ("Phoenix Flare" if phoenix else ("Void Lance" if specter else ("Radiant Pierce" if valkyrie else ("Wyrm Flame" if dragon else ("Magma Quake" if heavy else "Raijin Dash"))))))))))))
	var spec_type: String = "beam" if goku else ("reach_strike" if luffy else ("ice_slow" if subzero else ("radial_blast" if pain else ("electric_dash" if sonic else ("radial_blast" if akaza else ("beam" if blue_eyes else ("curse_strike" if anubis else ("flame_wave" if phoenix else ("void_strike" if specter else ("holy_pierce" if valkyrie else ("fire_breath" if dragon else ("ground_quake" if heavy else "electric_dash"))))))))))))

	var standard := {
		"name": "White Dragon Claw" if blue_eyes else ("Destructive Fist" if akaza else "Standard Strike"),
		"damage": 6.0 + stats.power * 0.24, "range": std_range,
		"cooldown": std_cooldown, "windup": std_windup,
		"active": 0.08, "recovery": 0.14,
		"cost": 20, "push": 0.28 if luffy else (0.26 if blue_eyes else (0.24 if akaza else (0.22 if sonic else 0.20))),
		"angle": std_angle, "hitstun": 0.20
	}
	var spec_range: float = 2.65 if goku else (3.20 if luffy else (2.55 if subzero else (3.00 if pain else (3.35 if sonic else (2.80 if akaza else (3.40 if blue_eyes else (2.70 if anubis else (2.75 if phoenix else (2.90 if specter else (2.45 if valkyrie else (2.85 if dragon else (2.25 if heavy else 2.40))))))))))))
	var spec_cooldown: float = 3.4 if goku else (2.9 if luffy else (2.8 if subzero else (3.0 if pain else (2.6 if sonic else (2.7 if akaza else (3.2 if blue_eyes else (3.1 if anubis else (3.0 if phoenix else (2.9 if specter else (3.2 if valkyrie else (3.5 if dragon else (3.1 if heavy else 3.3))))))))))))
	var spec_windup: float = 0.36 if goku else (0.28 if luffy else (0.26 if subzero else (0.30 if pain else (0.16 if sonic else (0.22 if akaza else (0.30 if blue_eyes else (0.30 if anubis else (0.29 if phoenix else (0.28 if specter else (0.32 if valkyrie else (0.38 if dragon else (0.35 if heavy else 0.35))))))))))))
	var special := {
		"name": spec_ability_name,
		"type": spec_type,
		"damage": 16.0 + stats.power * 0.32, "range": spec_range,
		"cooldown": spec_cooldown, "windup": spec_windup,
		"active": 0.16, "recovery": 0.28,
		"cost": 40, "push": 0.75 if luffy else (0.72 if blue_eyes else (0.70 if akaza else (0.65 if sonic else 0.62))),
		"angle": spec_angle, "hitstun": 0.38
	}
	var family := "goku" if goku else ("luffy" if luffy else ("subzero" if subzero else ("pain" if pain else ("sonic" if sonic else ("akaza" if akaza else ("blue_eyes" if blue_eyes else ("anubis" if anubis else ("phoenix" if phoenix else ("specter" if specter else ("valkyrie" if valkyrie else ("dragon" if dragon else ("golem" if heavy else "ninja"))))))))))))
	var fname := "SON GOKU (ULTRA)" if goku else ("MONKEY D. RUFFY" if luffy else ("SUB-ZERO" if subzero else ("PAIN" if pain else ("SONIC THE HEDGEHOG" if sonic else ("AKAZA (UPPER RANK 3)" if akaza else ("BLUE-EYES WHITE DRAGON" if blue_eyes else ("CYBER ANUBIS" if anubis else ("PHOENIX EMPRESS" if phoenix else ("VOID SPECTER" if specter else ("VALKYRIE AURA" if valkyrie else ("IGNIS DRAKE" if dragon else ("CINDER BASTION" if heavy else "VOLT SHADOW"))))))))))))
	var modules := ["turtle_gi", "power_pole"] if goku else (["straw_hat", "gum_gum"] if luffy else (["cryo_armor", "kori_blade"] if subzero else (["rinnegan", "akatsuki"] if pain else (["power_sneakers", "spin_dash"] if sonic else (["soryu_style", "compass_needle"] if akaza else (["dragon_plate", "burst_stream"] if blue_eyes else (["anubis_armor", "khopesh"] if anubis else (["feather_armor", "phoenix_glaive"] if phoenix else (["crystal_armor", "void_lance"] if specter else (["radiant_armor", "light_rapier"] if valkyrie else (["dragon_plate", "greatsword"] if dragon else (["basalt", "gauntlets"] if heavy else ["shadow_armor", "twin_blades"]))))))))))))
	return {"prompt": text, "slot": slot, "seed": seed_value, "family": family,
		"name": fname, "element": element,
		"modules": modules,
		"color": colors.get(element, Color("9b30ff")), "stats": stats, "standard": standard, "special": special,
		"health": 90.0 + stats.vitality * 1.6, "speed": 2.3 + stats.speed * 0.065,
		"weight": clampf(weight, 0.85, 1.35)}

static func has_any(text: String, words: Array) -> bool:
	for word in words:
		if text.contains(word): return true
	return false

static func valid(p: Dictionary) -> bool:
	if p.get("is_remix", false):
		var st = p.get("stats", {})
		var t = st.get("vitality", 0) + st.get("power", 0) + st.get("defense", 0) + st.get("speed", 0) + st.get("technique", 0)
		return t == 100 and p.has("standard") and p.has("special")

	var total := 0
	for key in STAT_KEYS:
		var v: int = p.stats[key]
		if v < 8 or v > 36: return false
		total += v
	for key in ["standard", "special"]:
		var a: Dictionary = p[key]
		if a.damage < 3 or a.damage > 30 or a.cooldown < 0.3 or a.cooldown > 6: return false
		if a.range < 0.9 or a.range > 3.5: return false
	return total == 100 and p.standard.cost + p.special.cost <= 60 and (
		(p.family == "golem" and p.modules == ["basalt", "gauntlets"]) or
		(p.family == "ninja" and p.modules == ["shadow_armor", "twin_blades"]) or
		(p.family == "valkyrie" and p.modules == ["radiant_armor", "light_rapier"]) or
		(p.family == "dragon" and p.modules == ["dragon_plate", "greatsword"]) or
		(p.family == "anubis" and p.modules == ["anubis_armor", "khopesh"]) or
		(p.family == "specter" and p.modules == ["crystal_armor", "void_lance"]) or
		(p.family == "phoenix" and p.modules == ["feather_armor", "phoenix_glaive"]) or
		(p.family == "goku" and p.modules == ["turtle_gi", "power_pole"]) or
		(p.family == "subzero" and p.modules == ["cryo_armor", "kori_blade"]) or
		(p.family == "pain" and p.modules == ["rinnegan", "akatsuki"]) or
		(p.family == "sonic" and p.modules == ["power_sneakers", "spin_dash"]) or
		(p.family == "akaza" and p.modules == ["soryu_style", "compass_needle"]) or
		(p.family == "blue_eyes" and p.modules == ["dragon_plate", "burst_stream"]) or
		(p.family == "luffy" and p.modules == ["straw_hat", "gum_gum"]))
