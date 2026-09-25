class_name CharacterRemixer
extends RefCounted

# ==============================================================================
# CHARACTER REMIXER DATA MODEL & MODULAR PIPELINE
# Generates fully playable, balanced fighters from modular components based on prompts.
# ==============================================================================

const TOTAL_STAT_BUDGET := 100.0

# Available Archetype Bodies
const BODY_MODULES := {
	"ninja": {
		"id": "body_ninja", "family": "ninja", "name": "Shinobi Exosuit",
		"weight": 0.95, "base_hp": 100.0, "stats": {"vit": 16, "pwr": 20, "def": 14, "spd": 28, "tech": 22},
		"anim_family": "ninja", "scale": 0.01
	},
	"golem": {
		"id": "body_golem", "family": "golem", "name": "Magma Core Colossus",
		"weight": 1.35, "base_hp": 130.0, "stats": {"vit": 28, "pwr": 26, "def": 26, "spd": 10, "tech": 10},
		"anim_family": "golem", "scale": 0.01
	},
	"valkyrie": {
		"id": "body_valkyrie", "family": "valkyrie", "name": "Aether Paladin Plate",
		"weight": 1.05, "base_hp": 110.0, "stats": {"vit": 20, "pwr": 22, "def": 22, "spd": 18, "tech": 18},
		"anim_family": "valkyrie", "scale": 0.01
	},
	"dragon": {
		"id": "body_dragon", "family": "dragon", "name": "Draconic Scale Carapace",
		"weight": 1.20, "base_hp": 120.0, "stats": {"vit": 24, "pwr": 25, "def": 22, "spd": 16, "tech": 13},
		"anim_family": "dragon", "scale": 0.01
	},
	"goku": {
		"id": "body_goku", "family": "goku", "name": "Martial Arts Gi",
		"weight": 1.00, "base_hp": 115.0, "stats": {"vit": 20, "pwr": 26, "def": 18, "spd": 22, "tech": 14},
		"anim_family": "goku", "scale": 0.01
	},
	"subzero": {
		"id": "body_subzero", "family": "subzero", "name": "Lin Kuei Cryo Tunic",
		"weight": 1.05, "base_hp": 112.0, "stats": {"vit": 19, "pwr": 23, "def": 20, "spd": 20, "tech": 18},
		"anim_family": "subzero", "scale": 1.05
	},
	"pain": {
		"id": "body_pain", "family": "pain", "name": "Akatsuki Shroud",
		"weight": 1.00, "base_hp": 110.0, "stats": {"vit": 18, "pwr": 25, "def": 18, "spd": 19, "tech": 20},
		"anim_family": "pain", "scale": 1.05
	},
	"luffy": {
		"id": "body_luffy", "family": "luffy", "name": "Straw Hat Brawler",
		"weight": 0.95, "base_hp": 115.0, "stats": {"vit": 22, "pwr": 24, "def": 16, "spd": 24, "tech": 14},
		"anim_family": "luffy", "scale": 1.05
	},
	"sonic": {
		"id": "body_sonic", "family": "sonic", "name": "Blue Blur Quills",
		"weight": 0.85, "base_hp": 95.0, "stats": {"vit": 14, "pwr": 18, "def": 14, "spd": 34, "tech": 20},
		"anim_family": "sonic", "scale": 1.05
	},
	"akaza": {
		"id": "body_akaza", "family": "akaza", "name": "Soryu Demon Physique",
		"weight": 1.02, "base_hp": 118.0, "stats": {"vit": 22, "pwr": 26, "def": 18, "spd": 22, "tech": 12},
		"anim_family": "akaza", "scale": 0.01
	},
	"blue_eyes": {
		"id": "body_blue_eyes", "family": "blue_eyes", "name": "Platinum Dragon Wings",
		"weight": 1.30, "base_hp": 125.0, "stats": {"vit": 24, "pwr": 28, "def": 22, "spd": 16, "tech": 10},
		"anim_family": "blue_eyes", "scale": 0.0115
	}
}

# Elements and Material Variants
const ELEMENT_VARIANTS := {
	"fire": {
		"name": "Infernal Flame", "color": Color("ff5522"),
		"bonus_stat": "pwr", "bonus_val": 4, "debuff_stat": "spd", "debuff_val": 2,
		"sfx_hit": "lava", "vfx": "fire_sparks"
	},
	"ice": {
		"name": "Glacial Frost", "color": Color("4ae0ff"),
		"bonus_stat": "def", "bonus_val": 4, "debuff_stat": "pwr", "debuff_val": 2,
		"sfx_hit": "block", "vfx": "ice_shards"
	},
	"lightning": {
		"name": "Volt Storm", "color": Color("ffe838"),
		"bonus_stat": "spd", "bonus_val": 4, "debuff_stat": "vit", "debuff_val": 2,
		"sfx_hit": "electric", "vfx": "electric_sparks"
	},
	"shadow": {
		"name": "Void Shadow", "color": Color("9944ee"),
		"bonus_stat": "tech", "bonus_val": 4, "debuff_stat": "def", "debuff_val": 2,
		"sfx_hit": "hit", "vfx": "void_smoke"
	},
	"holy": {
		"name": "Radiant Light", "color": Color("ffffff"),
		"bonus_stat": "vit", "bonus_val": 4, "debuff_stat": "spd", "debuff_val": 2,
		"sfx_hit": "hit", "vfx": "holy_glimmer"
	}
}

# Signature Special Abilities Library
const ABILITY_MODULES := {
	"beam": {
		"id": "ability_beam", "name": "Energy Beam", "type": "beam",
		"damage": 22.0, "push": 0.40, "windup": 0.28, "active": 0.35, "recovery": 0.22,
		"cooldown": 4.5, "range": 3.4, "hitstun": 0.45, "angle": 30.0, "cost": 40
	},
	"dash": {
		"id": "ability_dash", "name": "Supersonic Dash", "type": "electric_dash",
		"damage": 18.0, "push": 0.48, "windup": 0.15, "active": 0.25, "recovery": 0.18,
		"cooldown": 3.8, "range": 3.2, "hitstun": 0.38, "angle": 38.0, "cost": 40
	},
	"blast": {
		"id": "ability_blast", "name": "Gravity Blast", "type": "gravity_wave",
		"damage": 20.0, "push": 0.65, "windup": 0.22, "active": 0.30, "recovery": 0.25,
		"cooldown": 4.2, "range": 3.4, "hitstun": 0.50, "angle": 42.0, "cost": 40
	},
	"slow": {
		"id": "ability_slow", "name": "Cryo Freeze Surge", "type": "ice_slow",
		"damage": 16.0, "push": 0.32, "windup": 0.18, "active": 0.28, "recovery": 0.20,
		"cooldown": 4.0, "range": 3.3, "hitstun": 0.55, "angle": 25.0, "cost": 40
	},
	"barrage": {
		"id": "ability_barrage", "name": "Rapid Martial Barrage", "type": "compass_needle",
		"damage": 24.0, "push": 0.38, "windup": 0.20, "active": 0.40, "recovery": 0.25,
		"cooldown": 4.6, "range": 3.0, "hitstun": 0.48, "angle": 32.0, "cost": 40
	},
	"elastic": {
		"id": "ability_elastic", "name": "Elastic Cannon", "type": "gum_gum_pistol",
		"damage": 21.0, "push": 0.52, "windup": 0.24, "active": 0.32, "recovery": 0.20,
		"cooldown": 4.2, "range": 3.4, "hitstun": 0.42, "angle": 35.0, "cost": 40
	}
}

# ------------------------------------------------------------------------------
# PROMPT ANALYZER & REMIX ENGINE
# ------------------------------------------------------------------------------
static func remix_character(prompt: String, player_slot: int = 0, seed_val: int = 0) -> Dictionary:
	var lower: String = prompt.to_lower()
	var rng = RandomNumberGenerator.new()
	if seed_val != 0:
		rng.seed = seed_val
	else:
		rng.seed = hash(prompt) + player_slot * 31

	# 1. Determine Archetype Body
	var body_key := "ninja"
	if has_any(lower, ["drache", "dragon", "wyrm", "blue-eyes", "burst stream"]):
		body_key = "blue_eyes" if has_any(lower, ["blue-eyes", "weiß", "white", "yugioh", "yu-gi-oh"]) else "dragon"
	elif has_any(lower, ["golem", "stein", "rock", "koloss", "lava", "cinder"]):
		body_key = "golem"
	elif has_any(lower, ["valkyrie", "engel", "paladin", "licht", "moe", "rapier"]):
		body_key = "valkyrie"
	elif has_any(lower, ["goku", "saiyajin", "saiyan", "kamehameha", "dbz"]):
		body_key = "goku"
	elif has_any(lower, ["subzero", "sub-zero", "cryo", "lin kuei", "kori"]):
		body_key = "subzero"
	elif has_any(lower, ["pain", "nagato", "akatsuki", "rinnegan", "shinra"]):
		body_key = "pain"
	elif has_any(lower, ["luffy", "ruffy", "gum", "mugiwara", "one piece"]):
		body_key = "luffy"
	elif has_any(lower, ["sonic", "igel", "hedgehog", "spin dash", "sega"]):
		body_key = "sonic"
	elif has_any(lower, ["akaza", "oberer rang", "hakai satsu", "kimetsu"]):
		body_key = "akaza"

	var body_data: Dictionary = BODY_MODULES[body_key]

	# 2. Determine Element & Material
	var elem_key := "shadow"
	if has_any(lower, ["feuer", "flamm", "fire", "lava", "burn"]):
		elem_key = "fire"
	elif has_any(lower, ["eis", "frost", "ice", "kalt", "cold", "schnee"]):
		elem_key = "ice"
	elif has_any(lower, ["blitz", "volt", "electric", "donner", "storm"]):
		elem_key = "lightning"
	elif has_any(lower, ["licht", "heilig", "holy", "radiant", "gött"]):
		elem_key = "holy"
	var elem_data: Dictionary = ELEMENT_VARIANTS[elem_key]

	# 3. Determine Ability
	var ability_key := "blast"
	if has_any(lower, ["beam", "strahl", "kamehameha", "laser", "burst"]):
		ability_key = "beam"
	elif has_any(lower, ["dash", "sprint", "speed", "blitz", "sonic"]):
		ability_key = "dash"
	elif has_any(lower, ["freeze", "slow", "cryo", "frost"]):
		ability_key = "slow"
	elif has_any(lower, ["barrage", "kompass", "akaza", "faust", "fist"]):
		ability_key = "barrage"
	elif has_any(lower, ["gum", "pistol", "elastic", "luffy"]):
		ability_key = "elastic"
	var ability_data: Dictionary = ABILITY_MODULES[ability_key].duplicate()
	ability_data.element = elem_key

	# 4. Standard Attack Assembly
	var std_range: float = 1.35 if body_key in ["dragon", "blue_eyes", "valkyrie"] else (1.10 if body_key in ["ninja", "sonic"] else 1.25)
	var std_windup: float = 0.08 if body_key in ["ninja", "sonic"] else (0.14 if body_key == "golem" else 0.10)
	var std_attack := {
		"name": "Strike",
		"damage": 10.0 + (float(body_data.stats.pwr) * 0.20),
		"push": 0.22,
		"windup": std_windup,
		"active": 0.12,
		"recovery": 0.16,
		"cooldown": 0.35,
		"range": std_range,
		"hitstun": 0.22,
		"angle": 30.0,
		"cost": 20
	}

	# 5. Balanced Stat Allocation
	var stats: Dictionary = body_data.stats.duplicate()
	# Apply element affinity bonus & debuff
	stats[elem_data.bonus_stat] = stats.get(elem_data.bonus_stat, 20) + elem_data.bonus_val
	stats[elem_data.debuff_stat] = maxi(8, stats.get(elem_data.debuff_stat, 20) - elem_data.debuff_val)

	# Normalize to exact budget
	var current_total: float = stats.vit + stats.pwr + stats.def + stats.spd + stats.tech
	var norm_factor: float = TOTAL_STAT_BUDGET / current_total
	stats.vitality = int(round(stats.vit * norm_factor))
	stats.power = int(round(stats.pwr * norm_factor))
	stats.defense = int(round(stats.def * norm_factor))
	stats.speed = int(round(stats.spd * norm_factor))
	stats.technique = int(round(stats.tech * norm_factor))
	# Ensure exact 100 sum
	var diff := int(TOTAL_STAT_BUDGET - (stats.vitality + stats.power + stats.defense + stats.speed + stats.technique))
	stats.vitality += diff

	# 6. Assemble Profile Dictionary
	var char_name := generate_name(body_key, elem_key, prompt)
	var health_val := float(stats.vitality) * 5.0 + 10.0

	return {
		"name": char_name,
		"family": body_key,
		"element": elem_key,
		"color": elem_data.color,
		"weight": body_data.weight,
		"health": health_val,
		"speed": float(stats.speed) * 0.12 + 1.2,
		"stats": stats,
		"standard": std_attack,
		"special": ability_data,
		"modules": [body_data.id, "mat_" + elem_key, ability_data.id],
		"prompt": prompt,
		"slot": player_slot,
		"is_remix": true
	}

static func generate_name(body: String, elem: String, prompt: String) -> String:
	var prefix := elem.to_upper()
	var core := body.to_upper()
	if body == "blue_eyes": core = "BLUE-EYES"
	elif body == "subzero": core = "SUB-ZERO"
	elif body == "luffy": core = "RUFFY"
	return "%s %s" % [prefix, core]

static func has_any(s: String, list: Array) -> bool:
	for word in list:
		if word in s: return true
	return false

# ------------------------------------------------------------------------------
# VALIDATION ENGINE
# ------------------------------------------------------------------------------
static func validate(char_def: Dictionary) -> Dictionary:
	var errors: Array = []
	if not char_def.has("name") or char_def.name.is_empty():
		errors.append("Charaktername fehlt")
	if not char_def.has("family") or not BODY_MODULES.has(char_def.family):
		errors.append("Ungültige Skelettfamilie")
	if not char_def.has("stats"):
		errors.append("Fehlende Attribute")
	else:
		var st = char_def.stats
		var sum = st.get("vitality", 0) + st.get("power", 0) + st.get("defense", 0) + st.get("speed", 0) + st.get("technique", 0)
		if sum != int(TOTAL_STAT_BUDGET):
			errors.append("Attributbudget unbalanciert (Summe: %d, erwartet: 100)" % sum)
	if not char_def.has("standard") or not char_def.has("special"):
		errors.append("Angriffsdefinitionen unvollständig")
	
	return {
		"valid": errors.is_empty(),
		"errors": errors
	}
