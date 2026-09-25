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
	var vegeta := has_any(lower, ["vegeta", "prinz vegeta", "final flash", "galick gun", "big bang attack", "saiyan prince", "saiyajin prinz"])
	var goku := not vegeta and has_any(lower, ["goku", "son goku", "saiyajin", "saiyan", "kakarot", "ultra ego", "kamehameha", "ultra instinct", "ssj"])
	var luffy := not goku and not vegeta and has_any(lower, ["luffy", "ruffy", "straw hat", "strohhut", "gum gum", "gum-gum", "one piece", "mugiwara", "gum gum pistole"])
	var zoro := not goku and not vegeta and not luffy and has_any(lower, ["zoro", "roronoa", "santoryu", "drei schwerter", "three sword", "katana", "enma", "wado ichimonji", "onigiri"])
	var naruto := not goku and not vegeta and not luffy and not zoro and has_any(lower, ["naruto", "uzumaki", "rasengan", "hokage", "kyuubi", "kurama", "sage mode", "schattendoppelgänger", "shadow clone"])
	var pain := not goku and not vegeta and not luffy and not zoro and not naruto and has_any(lower, ["pain", "nagato", "akatsuki", "tendo", "deva path", "shinra tensei"])
	var sasuke := not goku and not vegeta and not luffy and not zoro and not naruto and not pain and has_any(lower, ["sasuke", "uchiha", "chidori", "sharingan", "kusanagi", "amaterasu", "chidori blitz"])
	var saitama := not goku and not vegeta and not luffy and not zoro and not naruto and not pain and not sasuke and has_any(lower, ["saitama", "one punch", "serious punch", "caped baldy", "glatze", "hero for fun", "ernster schlag"])
	var tanjiro := not goku and not vegeta and not luffy and not zoro and not naruto and not pain and not sasuke and not saitama and has_any(lower, ["tanjiro", "kamado", "hinokami", "sonnenatmung", "wasseratmung", "nichirin", "hanafuda", "kagura"])
	var subzero := not goku and not vegeta and not luffy and not zoro and not naruto and not sasuke and not saitama and not tanjiro and has_any(lower, ["sub zero", "subzero", "sub-zero", "cryomancer", "ice ninja", "lin kuei", "kori", "mortal kombat"])
	var sonic := not goku and not vegeta and not luffy and not zoro and not naruto and not sasuke and not saitama and not tanjiro and not subzero and not pain and has_any(lower, ["sonic", "hedgehog", "blue blur", "spin dash", "sega", "chaos emerald", "supersonic"])
	var akaza := not goku and not vegeta and not luffy and not zoro and not naruto and not sasuke and not saitama and not tanjiro and not subzero and not pain and not sonic and has_any(lower, ["akaza", "akaze", "upper rank", "upper moon", "hakai satsu", "compass needle", "soryu", "demon slayer", "kimetsu", "destructivedeath"])
	var blue_eyes := not goku and not vegeta and not luffy and not zoro and not naruto and not sasuke and not saitama and not tanjiro and not subzero and not pain and not sonic and not akaza and has_any(lower, ["weiße drache", "weisse drache", "weisser drache", "weißer drache", "blue-eyes", "blue eyes", "white dragon", "burst stream", "white lightning", "yu-gi-oh", "yugioh", "kaiba", "eiskalten blick", "eiskalter blick"])
	var anubis := not goku and not vegeta and not luffy and not zoro and not naruto and not sasuke and not saitama and not tanjiro and not subzero and not pain and not sonic and not akaza and not blue_eyes and has_any(lower, ["anubis", "jackal", "khopesh", "ägyptisch", "egypt", "pharaoh", "pharao", "underworld", "unterwelt", "osiris", "jackal god"])
	var phoenix := not goku and not vegeta and not luffy and not zoro and not naruto and not sasuke and not saitama and not tanjiro and not subzero and not pain and not sonic and not akaza and not blue_eyes and not anubis and has_any(lower, ["phoenix", "phönix", "empress", "kaiserin", "glaive", "fire queen", "firebird", "feuervogel", "fenix"])
	var specter := not goku and not vegeta and not luffy and not zoro and not naruto and not sasuke and not saitama and not tanjiro and not subzero and not pain and not sonic and not akaza and not blue_eyes and not anubis and not phoenix and has_any(lower, ["specter", "spectre", "void lance", "phantom warrior", "kristall phantom", "wraith", "crystal"])
	var valkyrie := not goku and not vegeta and not luffy and not zoro and not naruto and not sasuke and not saitama and not tanjiro and not subzero and not pain and not sonic and not akaza and not blue_eyes and not anubis and not phoenix and not specter and has_any(lower, ["valkyrie", "walküre", "moe", "paladin", "angel", "engel", "lichtflügel", "waifu"])
	var dragon := not goku and not vegeta and not luffy and not zoro and not naruto and not sasuke and not saitama and not tanjiro and not subzero and not pain and not sonic and not akaza and not blue_eyes and not anubis and not phoenix and not specter and not valkyrie and (has_any(lower, ["drachenritter", "drake", "wyrm", "slayer", "drakon", "drache"]) or (lower.contains("dragon") and not lower.contains("dragon ball") and not lower.contains("dragonball")))
	var heavy := not goku and not vegeta and not luffy and not zoro and not naruto and not sasuke and not saitama and not tanjiro and not subzero and not pain and not sonic and not akaza and not blue_eyes and not anubis and not phoenix and not specter and not valkyrie and not dragon and has_any(lower, ["golem", "panzer", "lavagolem", "tank", "stein", "heavy", "titan"])

	var fam := "ninja"
	if goku: fam = "goku"
	elif vegeta: fam = "vegeta"
	elif luffy: fam = "luffy"
	elif zoro: fam = "zoro"
	elif naruto: fam = "naruto"
	elif sasuke: fam = "sasuke"
	elif saitama: fam = "saitama"
	elif tanjiro: fam = "tanjiro"
	elif subzero: fam = "subzero"
	elif pain: fam = "pain"
	elif sonic: fam = "sonic"
	elif akaza: fam = "akaza"
	elif blue_eyes: fam = "blue_eyes"
	elif anubis: fam = "anubis"
	elif phoenix: fam = "phoenix"
	elif specter: fam = "specter"
	elif valkyrie: fam = "valkyrie"
	elif dragon: fam = "dragon"
	elif heavy: fam = "golem"

	var fam_configs: Dictionary = {
		"goku": {
			"values": [20, 26, 16, 20, 18], "element": "ki_purple", "weight": 1.05,
			"std_name": "Standard Strike", "std_range": 2.15, "std_cd": 0.57, "std_windup": 0.12, "std_push": 0.20,
			"spec_name": "Kamehameha", "spec_type": "beam", "spec_range": 3.60, "spec_cd": 3.4, "spec_windup": 0.36, "spec_push": 0.72, "spec_angle": 42.0, "spec_dmg_bonus": 0.0,
			"fname": "SON GOKU (ULTRA)", "modules": ["turtle_gi", "power_pole"]
		},
		"vegeta": {
			"values": [18, 28, 16, 22, 16], "element": "ki_gold", "weight": 1.06,
			"std_name": "Saiyan Strike", "std_range": 2.10, "std_cd": 0.54, "std_windup": 0.11, "std_push": 0.26,
			"spec_name": "Final Flash", "spec_type": "beam", "spec_range": 3.60, "spec_cd": 3.5, "spec_windup": 0.38, "spec_push": 0.78, "spec_angle": 42.0, "spec_dmg_bonus": 2.0,
			"fname": "PRINZ VEGETA", "modules": ["saiyan_armor", "final_flash"]
		},
		"luffy": {
			"values": [18, 28, 16, 26, 12], "element": "rubber", "weight": 0.95,
			"std_name": "Standard Strike", "std_range": 2.85, "std_cd": 0.52, "std_windup": 0.10, "std_push": 0.28,
			"spec_name": "Gum-Gum Pistol", "spec_type": "reach_strike", "spec_range": 3.20, "spec_cd": 2.9, "spec_windup": 0.28, "spec_push": 0.75, "spec_angle": 35.0, "spec_dmg_bonus": 0.0,
			"fname": "MONKEY D. RUFFY", "modules": ["straw_hat", "gum_gum"]
		},
		"zoro": {
			"values": [22, 28, 18, 18, 14], "element": "wind_slash", "weight": 1.12,
			"std_name": "Santoryu Slash", "std_range": 2.40, "std_cd": 0.50, "std_windup": 0.10, "std_push": 0.28,
			"spec_name": "Santoryu: Onigiri", "spec_type": "dash_slash", "spec_range": 3.10, "spec_cd": 3.0, "spec_windup": 0.24, "spec_push": 0.75, "spec_angle": 38.0, "spec_dmg_bonus": 0.0,
			"fname": "RORONOA ZORO", "modules": ["santoryu_blades", "wado_ichimonji"]
		},
		"naruto": {
			"values": [22, 24, 16, 24, 14], "element": "wind_rasen", "weight": 0.98,
			"std_name": "Uzumaki Combo", "std_range": 2.05, "std_cd": 0.48, "std_windup": 0.09, "std_push": 0.22,
			"spec_name": "Rasengan", "spec_type": "vortex_strike", "spec_range": 3.00, "spec_cd": 2.8, "spec_windup": 0.20, "spec_push": 0.68, "spec_angle": 35.0, "spec_dmg_bonus": 0.0,
			"fname": "NARUTO UZUMAKI", "modules": ["orange_jacket", "rasengan_core"]
		},
		"sasuke": {
			"values": [16, 26, 14, 28, 16], "element": "electric_chidori", "weight": 0.98,
			"std_name": "Kusanagi Slash", "std_range": 2.20, "std_cd": 0.46, "std_windup": 0.08, "std_push": 0.22,
			"spec_name": "Chidori", "spec_type": "electric_dash", "spec_range": 3.15, "spec_cd": 2.7, "spec_windup": 0.18, "spec_push": 0.68, "spec_angle": 35.0, "spec_dmg_bonus": 0.0,
			"fname": "SASUKE UCHIHA", "modules": ["uchiha_vest", "chidori_lightning"]
		},
		"saitama": {
			"values": [24, 34, 18, 16, 8], "element": "serious_force", "weight": 1.05,
			"std_name": "Normal Punch", "std_range": 2.25, "std_cd": 0.42, "std_windup": 0.08, "std_push": 0.32,
			"spec_name": "Serious Punch", "spec_type": "serious_blow", "spec_range": 3.40, "spec_cd": 3.6, "spec_windup": 0.26, "spec_push": 0.85, "spec_angle": 40.0, "spec_dmg_bonus": 2.0,
			"fname": "SAITAMA (ONE PUNCH)", "modules": ["yellow_suit", "hero_cape"]
		},
		"tanjiro": {
			"values": [20, 26, 16, 22, 16], "element": "sun_flame", "weight": 1.02,
			"std_name": "Nichirin Slash", "std_range": 2.30, "std_cd": 0.50, "std_windup": 0.10, "std_push": 0.24,
			"spec_name": "Hinokami Kagura", "spec_type": "flame_slash", "spec_range": 3.05, "spec_cd": 3.0, "spec_windup": 0.22, "spec_push": 0.70, "spec_angle": 38.0, "spec_dmg_bonus": 0.0,
			"fname": "TANJIRO KAMADO", "modules": ["checkered_haori", "nichirin_sword"]
		},
		"subzero": {
			"values": [18, 26, 16, 24, 16], "element": "ice", "weight": 1.05,
			"std_name": "Standard Strike", "std_range": 1.80, "std_cd": 0.54, "std_windup": 0.10, "std_push": 0.20,
			"spec_name": "Kori Ice Shard", "spec_type": "ice_slow", "spec_range": 2.55, "spec_cd": 2.8, "spec_windup": 0.26, "spec_push": 0.62, "spec_angle": 42.0, "spec_dmg_bonus": 0.0,
			"fname": "SUB-ZERO", "modules": ["cryo_armor", "kori_blade"]
		},
		"pain": {
			"values": [20, 27, 17, 19, 17], "element": "gravity", "weight": 1.05,
			"std_name": "Standard Strike", "std_range": 2.30, "std_cd": 0.56, "std_windup": 0.11, "std_push": 0.20,
			"spec_name": "Shinra Tensei", "spec_type": "radial_blast", "spec_range": 3.00, "spec_cd": 3.0, "spec_windup": 0.30, "spec_push": 0.62, "spec_angle": 45.0, "spec_dmg_bonus": 0.0,
			"fname": "PAIN", "modules": ["rinnegan", "akatsuki"]
		},
		"sonic": {
			"values": [16, 22, 14, 34, 14], "element": "wind", "weight": 0.88,
			"std_name": "Standard Strike", "std_range": 1.65, "std_cd": 0.44, "std_windup": 0.08, "std_push": 0.22,
			"spec_name": "Super Spin Dash", "spec_type": "electric_dash", "spec_range": 3.35, "spec_cd": 2.6, "spec_windup": 0.16, "spec_push": 0.65, "spec_angle": 35.0, "spec_dmg_bonus": 0.0,
			"fname": "SONIC THE HEDGEHOG", "modules": ["power_sneakers", "spin_dash"]
		},
		"akaza": {
			"values": [22, 28, 16, 22, 12], "element": "blood_demon", "weight": 1.02,
			"std_name": "Destructive Fist", "std_range": 2.10, "std_cd": 0.48, "std_windup": 0.09, "std_push": 0.24,
			"spec_name": "Destructive Death: Compass Needle", "spec_type": "radial_blast", "spec_range": 2.80, "spec_cd": 2.7, "spec_windup": 0.22, "spec_push": 0.70, "spec_angle": 40.0, "spec_dmg_bonus": 0.0,
			"fname": "AKAZA (UPPER RANK 3)", "modules": ["soryu_style", "compass_needle"]
		},
		"blue_eyes": {
			"values": [22, 30, 20, 18, 10], "element": "holy_light", "weight": 1.28,
			"std_name": "White Dragon Claw", "std_range": 2.20, "std_cd": 0.54, "std_windup": 0.11, "std_push": 0.26,
			"spec_name": "Burst Stream of Destruction", "spec_type": "beam", "spec_range": 3.40, "spec_cd": 3.2, "spec_windup": 0.30, "spec_push": 0.72, "spec_angle": 42.0, "spec_dmg_bonus": 0.0,
			"fname": "BLUE-EYES WHITE DRAGON", "modules": ["dragon_plate", "burst_stream"]
		},
		"anubis": {
			"values": [20, 28, 18, 18, 16], "element": "shadow_gold", "weight": 1.08,
			"std_name": "Standard Strike", "std_range": 2.10, "std_cd": 0.62, "std_windup": 0.13, "std_push": 0.20,
			"spec_name": "Anubis Wrath", "spec_type": "curse_strike", "spec_range": 2.70, "spec_cd": 3.1, "spec_windup": 0.30, "spec_push": 0.62, "spec_angle": 42.0, "spec_dmg_bonus": 0.0,
			"fname": "CYBER ANUBIS", "modules": ["anubis_armor", "khopesh"]
		},
		"phoenix": {
			"values": [19, 24, 15, 20, 22], "element": "fire", "weight": 0.98,
			"std_name": "Standard Strike", "std_range": 2.00, "std_cd": 0.55, "std_windup": 0.11, "std_push": 0.20,
			"spec_name": "Phoenix Flare", "spec_type": "flame_wave", "spec_range": 2.75, "spec_cd": 3.0, "spec_windup": 0.29, "spec_push": 0.62, "spec_angle": 42.0, "spec_dmg_bonus": 0.0,
			"fname": "PHOENIX EMPRESS", "modules": ["feather_armor", "phoenix_glaive"]
		},
		"specter": {
			"values": [16, 25, 17, 22, 20], "element": "void", "weight": 0.98,
			"std_name": "Standard Strike", "std_range": 2.20, "std_cd": 0.58, "std_windup": 0.11, "std_push": 0.20,
			"spec_name": "Void Lance", "spec_type": "void_strike", "spec_range": 2.90, "spec_cd": 2.9, "spec_windup": 0.28, "spec_push": 0.62, "spec_angle": 42.0, "spec_dmg_bonus": 0.0,
			"fname": "VOID SPECTER", "modules": ["crystal_armor", "void_lance"]
		},
		"valkyrie": {
			"values": [17, 22, 16, 23, 22], "element": "holy", "weight": 1.05,
			"std_name": "Standard Strike", "std_range": 1.85, "std_cd": 0.52, "std_windup": 0.10, "std_push": 0.20,
			"spec_name": "Radiant Pierce", "spec_type": "holy_pierce", "spec_range": 2.45, "spec_cd": 3.2, "spec_windup": 0.32, "spec_push": 0.62, "spec_angle": 42.0, "spec_dmg_bonus": 0.0,
			"fname": "VALKYRIE AURA", "modules": ["radiant_armor", "light_rapier"]
		},
		"dragon": {
			"values": [23, 26, 21, 15, 15], "element": "fire", "weight": 1.20,
			"std_name": "Standard Strike", "std_range": 1.95, "std_cd": 0.72, "std_windup": 0.16, "std_push": 0.20,
			"spec_name": "Wyrm Flame", "spec_type": "fire_breath", "spec_range": 2.85, "spec_cd": 3.5, "spec_windup": 0.38, "spec_push": 0.62, "spec_angle": 42.0, "spec_dmg_bonus": 0.0,
			"fname": "IGNIS DRAKE", "modules": ["dragon_plate", "greatsword"]
		},
		"golem": {
			"values": [27, 24, 27, 10, 12], "element": "fire", "weight": 1.32,
			"std_name": "Standard Strike", "std_range": 1.55, "std_cd": 0.90, "std_windup": 0.22, "std_push": 0.20,
			"spec_name": "Magma Quake", "spec_type": "ground_quake", "spec_range": 2.25, "spec_cd": 3.1, "spec_windup": 0.35, "spec_push": 0.62, "spec_angle": 52.0, "spec_dmg_bonus": 0.0,
			"fname": "CINDER BASTION", "modules": ["basalt", "gauntlets"]
		},
		"ninja": {
			"values": [18, 20, 14, 29, 19], "element": "shadow", "weight": 0.92,
			"std_name": "Standard Strike", "std_range": 1.75, "std_cd": 0.60, "std_windup": 0.12, "std_push": 0.20,
			"spec_name": "Raijin Dash", "spec_type": "electric_dash", "spec_range": 2.40, "spec_cd": 3.3, "spec_windup": 0.35, "spec_push": 0.62, "spec_angle": 42.0, "spec_dmg_bonus": 0.0,
			"fname": "VOLT SHADOW", "modules": ["shadow_armor", "twin_blades"]
		}
	}

	var cfg: Dictionary = fam_configs[fam]
	var values: Array = cfg.values.duplicate()
	for n in range(8):
		var a := rng.randi_range(0, 4)
		var b := rng.randi_range(0, 4)
		if a != b and values[a] > 8 and values[b] < 36:
			values[a] -= 1
			values[b] += 1
	var stats := {}
	for n in range(5): stats[STAT_KEYS[n]] = values[n]

	var element: String = cfg.element
	for candidate in ELEMENTS:
		if has_any(lower, ELEMENTS[candidate]):
			element = candidate
			break

	var colors := {"electric": Color("43e5ff"), "fire": Color("ff733e"), "ice": Color("b4e5ff"), "wind": Color("9dffcd"), "shadow": Color("b19dff"), "holy": Color("ffe26a"), "shadow_gold": Color("c9a227"), "void": Color("9b30ff"), "ki_purple": Color("b347ff"), "ki_gold": Color("ffe838"), "gravity": Color("9900ee"), "rubber": Color("ff2b2b"), "wind_slash": Color("3bfac8"), "wind_rasen": Color("4ae0ff"), "electric_chidori": Color("60d5ff"), "serious_force": Color("ff4040"), "sun_flame": Color("ff6524"), "blood_demon": Color("00e5ff"), "holy_light": Color("70d6ff")}

	var standard := {
		"name": cfg.std_name,
		"damage": 6.0 + stats.power * 0.24, "range": cfg.std_range,
		"cooldown": cfg.std_cd, "windup": cfg.std_windup,
		"active": 0.08, "recovery": 0.14,
		"cost": 20, "push": cfg.std_push,
		"angle": 28.0, "hitstun": 0.20
	}
	var special := {
		"name": cfg.spec_name,
		"type": cfg.spec_type,
		"damage": 16.0 + stats.power * 0.32 + cfg.spec_dmg_bonus, "range": cfg.spec_range,
		"cooldown": cfg.spec_cd, "windup": cfg.spec_windup,
		"active": 0.16, "recovery": 0.28,
		"cost": 40, "push": cfg.spec_push,
		"angle": cfg.spec_angle, "hitstun": 0.38
	}

	return {
		"prompt": text, "slot": slot, "seed": seed_value, "family": fam,
		"name": cfg.fname, "element": element,
		"modules": cfg.modules,
		"color": colors.get(element, Color("9b30ff")), "stats": stats, "standard": standard, "special": special,
		"health": 90.0 + stats.vitality * 1.6, "speed": 2.3 + stats.speed * 0.065,
		"weight": clampf(cfg.weight, 0.85, 1.35)
	}

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
		if a.damage < 3 or a.damage > 35 or a.cooldown < 0.3 or a.cooldown > 6: return false
		if a.range < 0.9 or a.range > 3.8: return false
	return total == 100 and p.standard.cost + p.special.cost <= 60 and (
		(p.family == "golem" and p.modules == ["basalt", "gauntlets"]) or
		(p.family == "ninja" and p.modules == ["shadow_armor", "twin_blades"]) or
		(p.family == "valkyrie" and p.modules == ["radiant_armor", "light_rapier"]) or
		(p.family == "dragon" and p.modules == ["dragon_plate", "greatsword"]) or
		(p.family == "anubis" and p.modules == ["anubis_armor", "khopesh"]) or
		(p.family == "specter" and p.modules == ["crystal_armor", "void_lance"]) or
		(p.family == "phoenix" and p.modules == ["feather_armor", "phoenix_glaive"]) or
		(p.family == "goku" and p.modules == ["turtle_gi", "power_pole"]) or
		(p.family == "vegeta" and p.modules == ["saiyan_armor", "final_flash"]) or
		(p.family == "subzero" and p.modules == ["cryo_armor", "kori_blade"]) or
		(p.family == "pain" and p.modules == ["rinnegan", "akatsuki"]) or
		(p.family == "sonic" and p.modules == ["power_sneakers", "spin_dash"]) or
		(p.family == "akaza" and p.modules == ["soryu_style", "compass_needle"]) or
		(p.family == "blue_eyes" and p.modules == ["dragon_plate", "burst_stream"]) or
		(p.family == "zoro" and p.modules == ["santoryu_blades", "wado_ichimonji"]) or
		(p.family == "naruto" and p.modules == ["orange_jacket", "rasengan_core"]) or
		(p.family == "sasuke" and p.modules == ["uchiha_vest", "chidori_lightning"]) or
		(p.family == "saitama" and p.modules == ["yellow_suit", "hero_cape"]) or
		(p.family == "tanjiro" and p.modules == ["checkered_haori", "nichirin_sword"]) or
		(p.family == "luffy" and p.modules == ["straw_hat", "gum_gum"]))
