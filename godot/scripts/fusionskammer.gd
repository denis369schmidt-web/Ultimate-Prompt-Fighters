class_name Fusionskammer
extends RefCounted

# ==============================================================================
# FUSIONSKAMMER (CHARACTER FUSION & DYNAMIC PROCEDURAL GENERATOR)
# Generates fully playable, balanced fighters with modular 3D equipment,
# dynamic appearance fusion, and stat adjustments based on prompts or custom pieces.
# ==============================================================================

const TOTAL_STAT_BUDGET := 100.0

# Available Archetype Bodies (Mixamo, Tripo AI, and Classics)
const BODY_MODULES := {
	"ninja": {
		"id": "body_ninja", "family": "ninja_master", "name": "Shinobi Schattenmeister",
		"weight": 0.95, "base_hp": 100.0, "stats": {"vit": 16, "pwr": 20, "def": 14, "spd": 28, "tech": 22},
		"anim_family": "ninja", "scale": 1.0, "model_file": "res://assets/models/mixamo/ninja_master.glb"
	},
	"paladin": {
		"id": "body_paladin", "family": "paladin_armed", "name": "Heiliger Aether-Paladin",
		"weight": 1.08, "base_hp": 115.0, "stats": {"vit": 22, "pwr": 22, "def": 24, "spd": 16, "tech": 16},
		"anim_family": "valkyrie", "scale": 1.0, "model_file": "res://assets/models/mixamo/paladin_armed.glb"
	},
	"golem": {
		"id": "body_golem", "family": "warrok_brute", "name": "Magma Warrok Koloss",
		"weight": 1.40, "base_hp": 135.0, "stats": {"vit": 30, "pwr": 28, "def": 26, "spd": 8, "tech": 8},
		"anim_family": "golem", "scale": 1.08, "model_file": "res://assets/models/mixamo/warrok_brute.glb"
	},
	"samurai": {
		"id": "body_samurai", "family": "samurai_dreyar", "name": "Meister-Samurai Dreyar",
		"weight": 1.02, "base_hp": 112.0, "stats": {"vit": 18, "pwr": 26, "def": 16, "spd": 22, "tech": 18},
		"anim_family": "zoro", "scale": 1.0, "model_file": "res://assets/models/mixamo/samurai_dreyar.glb"
	},
	"pirate": {
		"id": "body_pirate", "family": "pirate_captain", "name": "Piratenkapitän Freibeuter",
		"weight": 1.00, "base_hp": 110.0, "stats": {"vit": 20, "pwr": 24, "def": 16, "spd": 22, "tech": 18},
		"anim_family": "luffy", "scale": 1.0, "model_file": "res://assets/models/mixamo/pirate_captain.glb"
	},
	"brawler": {
		"id": "body_brawler", "family": "martial_yaku", "name": "Street Martial Artist Yaku",
		"weight": 0.98, "base_hp": 112.0, "stats": {"vit": 20, "pwr": 28, "def": 16, "spd": 24, "tech": 12},
		"anim_family": "saitama", "scale": 1.0, "model_file": "res://assets/models/mixamo/martial_yaku.glb"
	},
	"grandmaster": {
		"id": "body_grandmaster", "family": "monk_ganfaul", "name": "Shaolin Großmeister Ganfaul",
		"weight": 1.00, "base_hp": 114.0, "stats": {"vit": 20, "pwr": 24, "def": 18, "spd": 20, "tech": 18},
		"anim_family": "tanjiro", "scale": 1.0, "model_file": "res://assets/models/mixamo/monk_ganfaul.glb"
	},
	"vampire": {
		"id": "body_vampire", "family": "vampire_lord", "name": "Gothic Vampirfürst",
		"weight": 1.00, "base_hp": 108.0, "stats": {"vit": 16, "pwr": 25, "def": 16, "spd": 22, "tech": 21},
		"anim_family": "specter", "scale": 1.0, "model_file": "res://assets/models/mixamo/vampire_lord.glb"
	},
	"vanguard": {
		"id": "body_vanguard", "family": "vanguard_soldier", "name": "Schwerer Vanguard-Soldat",
		"weight": 1.10, "base_hp": 120.0, "stats": {"vit": 24, "pwr": 24, "def": 22, "spd": 16, "tech": 14},
		"anim_family": "ninja", "scale": 1.0, "model_file": "res://assets/models/mixamo/vanguard_soldier.glb"
	},
	"knight": {
		"id": "body_knight", "family": "steel_knight", "name": "Ritter in Vollplatte",
		"weight": 1.15, "base_hp": 122.0, "stats": {"vit": 24, "pwr": 24, "def": 26, "spd": 12, "tech": 14},
		"anim_family": "valkyrie", "scale": 1.0, "model_file": "res://assets/models/mixamo/steel_knight.glb"
	},
	"reaper": {
		"id": "body_reaper", "family": "skeleton_reaper", "name": "Untoter Skelett-Schnitter",
		"weight": 0.90, "base_hp": 105.0, "stats": {"vit": 16, "pwr": 24, "def": 14, "spd": 24, "tech": 22},
		"anim_family": "specter", "scale": 1.0, "model_file": "res://assets/models/mixamo/skeleton_reaper.glb"
	},
	"sorceress": {
		"id": "body_sorceress", "family": "sorceress_medea", "name": "Erzmagierin Medea",
		"weight": 0.90, "base_hp": 98.0, "stats": {"vit": 14, "pwr": 28, "def": 12, "spd": 20, "tech": 26},
		"anim_family": "valkyrie", "scale": 1.0, "model_file": "res://assets/models/mixamo/sorceress_medea.glb"
	},
	"wizard": {
		"id": "body_wizard", "family": "wizard_sorcerer", "name": "Arkaner Elementar-Zauberer",
		"weight": 0.92, "base_hp": 100.0, "stats": {"vit": 14, "pwr": 28, "def": 12, "spd": 18, "tech": 28},
		"anim_family": "specter", "scale": 1.0, "model_file": "res://assets/models/mixamo/wizard_sorcerer.glb"
	},
	"swat": {
		"id": "body_swat", "family": "swat_specops", "name": "Taktischer SWAT-Agent",
		"weight": 1.04, "base_hp": 115.0, "stats": {"vit": 20, "pwr": 22, "def": 20, "spd": 20, "tech": 18},
		"anim_family": "ninja", "scale": 1.0, "model_file": "res://assets/models/mixamo/swat_specops.glb"
	},
	"mutant": {
		"id": "body_mutant", "family": "mutant_titan", "name": "Mutierter Koloss-Titan",
		"weight": 1.35, "base_hp": 130.0, "stats": {"vit": 28, "pwr": 28, "def": 24, "spd": 10, "tech": 10},
		"anim_family": "golem", "scale": 1.08, "model_file": "res://assets/models/mixamo/mutant_titan.glb"
	},
	# Tripo AI Titans
	"golden_golem": {
		"id": "body_golden_golem", "family": "golden_golem", "name": "Goldener Titan Golem",
		"weight": 1.40, "base_hp": 135.0, "stats": {"vit": 28, "pwr": 28, "def": 26, "spd": 10, "tech": 8},
		"anim_family": "golem", "scale": 2.15, "model_file": "res://assets/models/golden_golem.glb"
	},
	"kitsune": {
		"id": "body_kitsune", "family": "tripo_cat_girl", "name": "Kitsune Klingentänzerin",
		"weight": 0.95, "base_hp": 105.0, "stats": {"vit": 16, "pwr": 24, "def": 14, "spd": 26, "tech": 20},
		"anim_family": "ninja", "scale": 1.95, "model_file": "res://assets/models/tripo_cat_girl.glb"
	},
	"blue_wyrm": {
		"id": "body_blue_wyrm", "family": "tripo_dragon_blue", "name": "Blauer Frost-Wyrm",
		"weight": 1.30, "base_hp": 125.0, "stats": {"vit": 24, "pwr": 28, "def": 22, "spd": 16, "tech": 10},
		"anim_family": "dragon", "scale": 2.25, "model_file": "res://assets/models/tripo_dragon_blue.glb"
	},
	"nyx_reaper": {
		"id": "body_nyx", "family": "tripo_nyx_harvester", "name": "Nyx Seelenernter",
		"weight": 1.05, "base_hp": 115.0, "stats": {"vit": 18, "pwr": 26, "def": 18, "spd": 20, "tech": 18},
		"anim_family": "specter", "scale": 1.95, "model_file": "res://assets/models/tripo_nyx_harvester.glb"
	},
	# Classics & Anime
	"subzero": {
		"id": "body_subzero", "family": "subzero", "name": "Lin Kuei Cryomancer",
		"weight": 1.05, "base_hp": 115.0, "stats": {"vit": 20, "pwr": 24, "def": 20, "spd": 20, "tech": 16},
		"anim_family": "subzero", "scale": 1.05, "model_file": "res://assets/models/subzero.glb"
	},
	"goku": {
		"id": "body_goku", "family": "goku", "name": "Sturmmönch Kairo",
		"weight": 1.00, "base_hp": 118.0, "stats": {"vit": 20, "pwr": 28, "def": 18, "spd": 22, "tech": 12},
		"anim_family": "goku", "scale": 0.01, "model_file": "res://assets/models/goku.glb"
	},
	"pain": {
		"id": "body_pain", "family": "pain", "name": "Schwerkraftprophet Oryn",
		"weight": 1.00, "base_hp": 112.0, "stats": {"vit": 18, "pwr": 26, "def": 18, "spd": 18, "tech": 20},
		"anim_family": "pain", "scale": 1.05, "model_file": "res://assets/models/pain.glb"
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
	},
	"plasma": {
		"name": "Cyber Plasma", "color": Color("00ffcc"),
		"bonus_stat": "tech", "bonus_val": 5, "debuff_stat": "def", "debuff_val": 2,
		"sfx_hit": "electric", "vfx": "plasma_rings"
	},
	"blood": {
		"name": "Crimson Blood", "color": Color("e0113a"),
		"bonus_stat": "pwr", "bonus_val": 5, "debuff_stat": "vit", "debuff_val": 2,
		"sfx_hit": "hit", "vfx": "crimson_burst"
	}
}

# Equipment Modules
const EQUIPMENT_MODULES := {
	# --- MAIN HAND WEAPONS (weapon_r) ---
	"flame_katana": {
		"id": "eq_flame_katana", "name": "Flammen-Katana", "slot": "weapon_r",
		"mesh_type": "katana", "color": Color("ff3b19"), "emission": Color("ff6600"), "glow": 3.8,
		"stat_mods": {"pwr": 8, "tech": 4, "def": -2}, "weight_mod": 0.02,
		"std_mods": {"damage": 4.0, "push": 0.08, "name": "Flammen-Schnitt"}
	},
	"ice_rapier": {
		"id": "eq_ice_rapier", "name": "Frost-Rapier", "slot": "weapon_r",
		"mesh_type": "rapier", "color": Color("80f0ff"), "emission": Color("20d0ff"), "glow": 3.2,
		"stat_mods": {"spd": 6, "tech": 6, "pwr": -2}, "weight_mod": 0.01,
		"std_mods": {"windup": -0.02, "range": 0.25, "name": "Eisstich"}
	},
	"war_hammer": {
		"id": "eq_war_hammer", "name": "Titanen-Kriegshammer", "slot": "weapon_r",
		"mesh_type": "hammer", "color": Color("504845"), "emission": Color("ff8800"), "glow": 2.2,
		"stat_mods": {"pwr": 12, "vit": 4, "spd": -6}, "weight_mod": 0.08,
		"std_mods": {"push": 0.26, "damage": 7.0, "windup": 0.03, "name": "Schwerer Schmetterhieb"}
	},
	"plasma_blaster": {
		"id": "eq_plasma_blaster", "name": "Plasma-Buster", "slot": "weapon_r",
		"mesh_type": "blaster", "color": Color("222b35"), "emission": Color("00ffcc"), "glow": 4.2,
		"stat_mods": {"tech": 10, "pwr": 6, "vit": -4}, "weight_mod": 0.04,
		"std_mods": {"range": 0.40, "name": "Plasmastrahl"}
	},
	"energy_scythe": {
		"id": "eq_energy_scythe", "name": "Seelen-Sense", "slot": "weapon_r",
		"mesh_type": "scythe", "color": Color("2b1838"), "emission": Color("aa33ff"), "glow": 3.8,
		"stat_mods": {"pwr": 9, "tech": 7, "def": -4}, "weight_mod": 0.03,
		"std_mods": {"range": 0.35, "push": 0.12, "name": "Seelen-Schwung"}
	},
	"paladin_greatsword": {
		"id": "eq_paladin_greatsword", "name": "Heiliges Paladin-Großschwert", "slot": "weapon_r",
		"mesh_type": "sword", "color": Color("d4af37"), "emission": Color("fff0a0"), "glow": 3.5,
		"stat_mods": {"pwr": 10, "def": 4, "spd": -4}, "weight_mod": 0.05,
		"std_mods": {"damage": 6.0, "push": 0.20, "name": "Aether-Hieb"}
	},

	# --- OFF-HAND WEAPONS & SHIELDS (weapon_l) ---
	"aegis_shield": {
		"id": "eq_aegis_shield", "name": "Aegis-Bollwerkschild", "slot": "weapon_l",
		"mesh_type": "shield", "color": Color("303848"), "emission": Color("44aaff"), "glow": 2.5,
		"stat_mods": {"def": 12, "vit": 6, "spd": -6}, "weight_mod": 0.10, "shield_boost": 0.30
	},
	"energy_buckler": {
		"id": "eq_energy_buckler", "name": "Plasma-Buckler", "slot": "weapon_l",
		"mesh_type": "buckler", "color": Color("1a2030"), "emission": Color("ff33aa"), "glow": 3.5,
		"stat_mods": {"def": 6, "tech": 6, "spd": -2}, "weight_mod": 0.03, "shield_boost": 0.15
	},

	# --- HEADGEAR (head) ---
	"cyber_visor": {
		"id": "eq_cyber_visor", "name": "Cyber-Holo-Visier", "slot": "head",
		"mesh_type": "visor", "color": Color("111620"), "emission": Color("00e5ff"), "glow": 4.0,
		"stat_mods": {"tech": 8, "spd": 2}, "weight_mod": 0.0
	},
	"dragon_horns": {
		"id": "eq_dragon_horns", "name": "Drachenhörner", "slot": "head",
		"mesh_type": "horns", "color": Color("802010"), "emission": Color("ff4000"), "glow": 2.5,
		"stat_mods": {"pwr": 6, "vit": 4}, "weight_mod": 0.01
	},
	"shinobi_cowl": {
		"id": "eq_shinobi_cowl", "name": "Schatten-Kapuze", "slot": "head",
		"mesh_type": "cowl", "color": Color("15151e"), "emission": Color("303045"), "glow": 0.5,
		"stat_mods": {"spd": 6, "def": 2}, "weight_mod": 0.0
	},

	# --- BACK ATTACHMENTS (back) ---
	"angel_wings": {
		"id": "eq_angel_wings", "name": "Aether-Lichtflügel", "slot": "back",
		"mesh_type": "wings_feather", "color": Color("ffffff"), "emission": Color("e0f4ff"), "glow": 3.0,
		"stat_mods": {"spd": 8, "vit": 4, "def": -2}, "weight_mod": -0.05
	},
	"dragon_wings": {
		"id": "eq_dragon_wings", "name": "Lavadrachen-Schwingen", "slot": "back",
		"mesh_type": "wings_bat", "color": Color("4a1208"), "emission": Color("ff4400"), "glow": 3.5,
		"stat_mods": {"pwr": 6, "spd": 4}, "weight_mod": 0.02
	},

	# --- SHOULDER PAULDRONS (shoulders) ---
	"spiked_pauldrons": {
		"id": "eq_spiked_pauldrons", "name": "Obsidian-Stachelschultern", "slot": "shoulders",
		"mesh_type": "pauldrons_spiked", "color": Color("1c1d24"), "emission": Color("ff2200"), "glow": 2.0,
		"stat_mods": {"def": 8, "pwr": 4, "spd": -2}, "weight_mod": 0.04
	}
}

const ABILITY_MODULES := {
	"beam": {
		"name": "Photonenstrahl", "type": "beam", "range": 4.5, "cooldown": 3.0, "windup": 0.18,
		"push": 0.70, "angle": 30.0, "damage_bonus": 2.0, "element": "plasma"
	},
	"blast": {
		"name": "Elementar-Explosion", "type": "shockwave", "range": 3.2, "cooldown": 2.8, "windup": 0.22,
		"push": 0.85, "angle": 45.0, "damage_bonus": 1.5, "element": "fire"
	},
	"dash": {
		"name": "Kometen-Sturm", "type": "dash", "range": 4.0, "cooldown": 2.5, "windup": 0.10,
		"push": 0.60, "angle": 25.0, "damage_bonus": 1.0, "element": "lightning"
	},
	"slow": {
		"name": "Eis-Nova", "type": "slow", "range": 3.5, "cooldown": 3.2, "windup": 0.20,
		"push": 0.40, "angle": 35.0, "damage_bonus": 0.8, "element": "ice"
	}
}

# ------------------------------------------------------------------------------
# CORE GENERATION & FUSION ENGINE
# ------------------------------------------------------------------------------
static func generate_fusion(prompt_text: String, slot_index: int = 0) -> Dictionary:
	return remix_character(prompt_text, slot_index)

static func remix_character(prompt_text: String, slot_index: int = 0) -> Dictionary:
	var lower := prompt_text.to_lower().strip_edges()

	# 1. Determine Base Body Archetype
	var body_key := "ninja"
	if has_any(lower, ["paladin", "ritter", "knight", "schild", "shield", "panzer", "holy"]):
		body_key = "paladin"
	elif has_any(lower, ["golem", "warrok", "stein", "rock", "koloss", "lava", "cinder", "brute", "titan"]):
		body_key = "golem"
	elif has_any(lower, ["samurai", "katana", "zoro", "dreyar", "schwert"]):
		body_key = "samurai"
	elif has_any(lower, ["pirat", "pirate", "seemann", "luffy", "kapitän"]):
		body_key = "pirate"
	elif has_any(lower, ["brawler", "boxer", "faust", "fist", "martial", "yaku", "saitama"]):
		body_key = "brawler"
	elif has_any(lower, ["monk", "mönch", "shaolin", "meister", "ganfaul", "tanjiro"]):
		body_key = "grandmaster"
	elif has_any(lower, ["vampir", "vampire", "blut", "gothic", "lord"]):
		body_key = "vampire"
	elif has_any(lower, ["vanguard", "soldat", "cyber", "mech", "xbot", "krieger"]):
		body_key = "vanguard"
	elif has_any(lower, ["reaper", "skelett", "skeleton", "tod", "undead", "sense"]):
		body_key = "reaper"
	elif has_any(lower, ["magier", "hexe", "sorceress", "wizard", "zauber", "arcane"]):
		body_key = "sorceress"
	elif has_any(lower, ["mutant", "monster", "abomination"]):
		body_key = "mutant"
	elif has_any(lower, ["gold", "golden golem", "midas"]):
		body_key = "golden_golem"
	elif has_any(lower, ["kitsune", "katze", "cat", "fuchs"]):
		body_key = "kitsune"
	elif has_any(lower, ["wyrm", "drache", "dragon"]):
		body_key = "blue_wyrm"
	elif has_any(lower, ["subzero", "sub-zero", "kori", "eis"]):
		body_key = "subzero"
	elif has_any(lower, ["kairo", "sturmmönch", "goku", "saiyajin", "dbz"]):
		body_key = "goku"
	elif has_any(lower, ["oryn", "schwerkraft", "pain", "nagato", "akatsuki"]):
		body_key = "pain"

	var body_data: Dictionary = BODY_MODULES[body_key]

	# 2. Determine Element & Material
	var elem_key := "shadow"
	if has_any(lower, ["feuer", "flamm", "fire", "lava", "burn", "inferno"]):
		elem_key = "fire"
	elif has_any(lower, ["eis", "frost", "ice", "kalt", "cold", "schnee"]):
		elem_key = "ice"
	elif has_any(lower, ["blitz", "volt", "electric", "donner", "storm"]):
		elem_key = "lightning"
	elif has_any(lower, ["licht", "heilig", "holy", "radiant", "gött", "angel"]):
		elem_key = "holy"
	elif has_any(lower, ["plasma", "cyber", "laser", "tech"]):
		elem_key = "plasma"
	elif has_any(lower, ["blut", "blood", "rot", "crimson", "vampir"]):
		elem_key = "blood"
	var elem_data: Dictionary = ELEMENT_VARIANTS[elem_key]

	# 3. Dynamic Equipment Extraction
	var equipped: Array = extract_equipment(lower, elem_key, body_key)

	# 4. Determine Ability
	var ability_key := "blast"
	if has_any(lower, ["beam", "strahl", "laser", "burst", "blaster"]):
		ability_key = "beam"
	elif has_any(lower, ["dash", "sprint", "speed", "blitz", "flügel", "wings"]):
		ability_key = "dash"
	elif has_any(lower, ["freeze", "slow", "cryo", "frost", "eis"]):
		ability_key = "slow"
	var ability_data: Dictionary = ABILITY_MODULES[ability_key].duplicate()
	ability_data.element = elem_key

	# 5. Balance Attributes
	var base_stats: Dictionary = body_data.stats.duplicate()
	var balanced_stats: Dictionary = balance_stats(base_stats, elem_data, equipped)

	# 6. Standard Attack Setup
	var std_name: String = "Schlag"
	var std_range := 2.0
	var std_push := 0.20
	var std_damage := 14.0
	var std_windup := 0.08
	var std_cooldown := 0.40

	for eq in equipped:
		if eq.has("std_mods"):
			var sm: Dictionary = eq.std_mods
			if sm.has("name"): std_name = sm.name
			if sm.has("range"): std_range += sm.range
			if sm.has("push"): std_push += sm.push
			if sm.has("damage"): std_damage += sm.damage
			if sm.has("windup"): std_windup = maxf(0.04, std_windup + sm.windup)

	# 7. Total Weight & Health Calculation
	var final_weight: float = body_data.weight
	for eq in equipped:
		if eq.has("weight_mod"): final_weight += eq.weight_mod
	var final_hp: float = body_data.base_hp + (balanced_stats.vit - 20) * 2.5

	var final_name := generate_name(prompt_text, body_key, elem_key, equipped)

	return {
		"is_remix": true,
		"name": final_name,
		"prompt": prompt_text,
		"slot": slot_index,
		"family": body_data.family,
		"model_file": body_data.get("model_file", ""),
		"element": elem_key,
		"color": elem_data.color,
		"health": final_hp,
		"weight": clampf(final_weight, 0.70, 1.80),
		"speed": 6.0 * (1.0 + (balanced_stats.spd - 20) * 0.02),
		"scale": body_data.get("scale", 1.0),
		"stats": {
			"vitality": balanced_stats.vit,
			"power": balanced_stats.pwr,
			"defense": balanced_stats.def,
			"speed": balanced_stats.spd,
			"technique": balanced_stats.tech
		},
		"standard": {
			"name": std_name,
			"damage": std_damage * (1.0 + (balanced_stats.pwr - 20) * 0.015),
			"push": std_push,
			"range": std_range,
			"windup": std_windup,
			"cooldown": std_cooldown
		},
		"special": {
			"name": ability_data.name,
			"type": ability_data.type,
			"element": elem_key,
			"damage": (18.0 + ability_data.damage_bonus) * (1.0 + (balanced_stats.tech - 20) * 0.02),
			"push": ability_data.push,
			"range": ability_data.range,
			"windup": ability_data.windup,
			"cooldown": maxf(1.5, ability_data.cooldown - (balanced_stats.tech - 20) * 0.04),
			"angle": ability_data.angle
		},
		"equipment": equipped
	}

# ------------------------------------------------------------------------------
# DYNAMIC EQUIPMENT EXTRACTION
# ------------------------------------------------------------------------------
static func extract_equipment(lower: String, elem_key: String, body_key: String) -> Array:
	var equipped: Array = []
	var occupied_slots: Dictionary = {}

	# Weapon extraction
	if has_any(lower, ["katana", "schwert", "blade", "klinge"]):
		if elem_key == "ice":
			equipped.append(EQUIPMENT_MODULES["ice_rapier"])
		elif body_key == "paladin":
			equipped.append(EQUIPMENT_MODULES["paladin_greatsword"])
		else:
			equipped.append(EQUIPMENT_MODULES["flame_katana"])
		occupied_slots["weapon_r"] = true
	elif has_any(lower, ["hammer", "keule", "koloss", "mace"]):
		equipped.append(EQUIPMENT_MODULES["war_hammer"])
		occupied_slots["weapon_r"] = true
	elif has_any(lower, ["blaster", "plasma", "pistole", "kanone", "gun"]):
		equipped.append(EQUIPMENT_MODULES["plasma_blaster"])
		occupied_slots["weapon_r"] = true
	elif has_any(lower, ["sense", "scythe", "reaper", "ernter"]):
		equipped.append(EQUIPMENT_MODULES["energy_scythe"])
		occupied_slots["weapon_r"] = true

	# Off-hand extraction
	if has_any(lower, ["schild", "shield", "aegis", "bollwerk"]):
		equipped.append(EQUIPMENT_MODULES["aegis_shield"])
		occupied_slots["weapon_l"] = true
	elif has_any(lower, ["buckler", "puffer"]):
		equipped.append(EQUIPMENT_MODULES["energy_buckler"])
		occupied_slots["weapon_l"] = true

	# Wings extraction
	if has_any(lower, ["flügel", "wings", "engel", "angel"]):
		equipped.append(EQUIPMENT_MODULES["angel_wings"])
		occupied_slots["back"] = true
	elif has_any(lower, ["drachenflügel", "schwingen"]):
		equipped.append(EQUIPMENT_MODULES["dragon_wings"])
		occupied_slots["back"] = true

	# Headgear extraction
	if has_any(lower, ["visier", "visor", "helm", "cyber", "holo"]):
		equipped.append(EQUIPMENT_MODULES["cyber_visor"])
		occupied_slots["head"] = true
	elif has_any(lower, ["hörner", "horns", "dämon", "oni"]):
		equipped.append(EQUIPMENT_MODULES["dragon_horns"])
		occupied_slots["head"] = true
	elif has_any(lower, ["maske", "kapuze", "cowl", "ninja"]):
		equipped.append(EQUIPMENT_MODULES["shinobi_cowl"])
		occupied_slots["head"] = true

	# Shoulder extraction
	if has_any(lower, ["stacheln", "schultern", "pauldrons", "stachelschultern"]):
		equipped.append(EQUIPMENT_MODULES["spiked_pauldrons"])
		occupied_slots["shoulders"] = true

	return equipped

# ------------------------------------------------------------------------------
# ATTRIBUTE BUDGET BALANCER
# ------------------------------------------------------------------------------
static func balance_stats(base: Dictionary, elem: Dictionary, equipped: Array) -> Dictionary:
	var stats := {
		"vit": float(base.vit),
		"pwr": float(base.pwr),
		"def": float(base.def),
		"spd": float(base.spd),
		"tech": float(base.tech)
	}

	# Apply elemental bias
	stats[elem.bonus_stat] = float(stats[elem.bonus_stat]) + float(elem.bonus_val)
	stats[elem.debuff_stat] = maxf(6.0, float(stats[elem.debuff_stat]) - float(elem.debuff_val))

	# Apply equipment modifiers
	for eq in equipped:
		if eq.has("stat_mods"):
			for s in eq.stat_mods:
				stats[s] = maxf(6.0, float(stats[s]) + float(eq.stat_mods[s]))

	# Normalize exactly to 100 points
	var current_sum: float = float(stats.vit) + float(stats.pwr) + float(stats.def) + float(stats.spd) + float(stats.tech)
	var factor: float = float(TOTAL_STAT_BUDGET) / current_sum

	var final_vit: int = int(round(float(stats.vit) * factor))
	var final_pwr: int = int(round(float(stats.pwr) * factor))
	var final_def: int = int(round(float(stats.def) * factor))
	var final_spd: int = int(round(float(stats.spd) * factor))
	var final_tech: int = int(TOTAL_STAT_BUDGET) - (final_vit + final_pwr + final_def + final_spd)

	return {
		"vit": final_vit,
		"pwr": final_pwr,
		"def": final_def,
		"spd": final_spd,
		"tech": final_tech
	}

# ------------------------------------------------------------------------------
# TITLE & NAME GENERATOR
# ------------------------------------------------------------------------------
static func generate_name(prompt_raw: String, body: String, elem: String, equipped: Array) -> String:
	var words := prompt_raw.strip_edges().split(" ")
	if words.size() > 0 and words[0].length() > 2:
		var candidate: String = words[0].to_upper()
		if not candidate in ["EIN", "EINE", "DER", "DIE", "DAS", "MIT"]:
			return prompt_raw.left(24).to_upper()

	var prefix := elem.to_upper()
	var base_title := "KÄMPFER"
	if body == "golem": base_title = "KOLOSS"
	elif body == "ninja": base_title = "SHINOBI"
	elif body == "paladin": base_title = "PALADIN"
	elif body == "samurai": base_title = "SAMURAI"
	elif body == "pirate": base_title = "FREIBEUTER"
	elif body == "vampire": base_title = "VAMPIRFÜRST"
	elif body == "reaper": base_title = "SCHNITTER"
	elif body == "sorceress": base_title = "ERZMAGIER"
	elif body == "mutant": base_title = "TITAN"

	return "%s %s" % [prefix, base_title]

static func has_any(s: String, list: Array) -> bool:
	for word in list:
		if word in s: return true
	return false

static func validate(char_def: Dictionary) -> Dictionary:
	var errors: Array = []
	if not char_def.has("name") or char_def.name.is_empty():
		errors.append("Charaktername fehlt")
	if not char_def.has("stats"):
		errors.append("Fehlende Attribute")
	return {
		"valid": errors.is_empty(),
		"errors": errors
	}
