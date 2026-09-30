extends Node3D

# --- GOLEM HIGH-RES REFERENCE TEXTURES ---
const GOLEM_LAVA_ROCK_ALBEDO = preload("res://assets/textures/skins/golem_lava_rock_albedo.png")
const GOLEM_LAVA_ROCK_NORMAL = preload("res://assets/textures/skins/golem_lava_rock_normal.png")
const GOLEM_LAVA_CORE_ALBEDO = preload("res://assets/textures/skins/golem_lava_core_albedo.png")
const GOLEM_LAVA_CORE_EMISSION = preload("res://assets/textures/skins/golem_lava_core_emission.png")

const GOLEM_FROST_ROCK_ALBEDO = preload("res://assets/textures/skins/golem_frost_rock_albedo.png")
const GOLEM_FROST_ROCK_NORMAL = preload("res://assets/textures/skins/golem_frost_rock_normal.png")
const GOLEM_FROST_CORE_ALBEDO = preload("res://assets/textures/skins/golem_frost_core_albedo.png")
const GOLEM_FROST_CORE_EMISSION = preload("res://assets/textures/skins/golem_frost_core_emission.png")

const GOLEM_TOXIC_ROCK_ALBEDO = preload("res://assets/textures/skins/golem_toxic_rock_albedo.png")
const GOLEM_TOXIC_ROCK_NORMAL = preload("res://assets/textures/skins/golem_toxic_rock_normal.png")
const GOLEM_TOXIC_CORE_ALBEDO = preload("res://assets/textures/skins/golem_toxic_core_albedo.png")
const GOLEM_TOXIC_CORE_EMISSION = preload("res://assets/textures/skins/golem_toxic_core_emission.png")

const GOLEM_STORM_ROCK_ALBEDO = preload("res://assets/textures/skins/golem_storm_rock_albedo.png")
const GOLEM_STORM_ROCK_NORMAL = preload("res://assets/textures/skins/golem_storm_rock_normal.png")
const GOLEM_STORM_CORE_ALBEDO = preload("res://assets/textures/skins/golem_storm_core_albedo.png")
const GOLEM_STORM_CORE_EMISSION = preload("res://assets/textures/skins/golem_storm_core_emission.png")

# --- NINJA HIGH-RES REFERENCE TEXTURES ---
const NINJA_SHADOW_ARMOR_ALBEDO = preload("res://assets/textures/skins/ninja_shadow_armor_albedo.png")
const NINJA_SHADOW_ARMOR_NORMAL = preload("res://assets/textures/skins/ninja_shadow_armor_normal.png")
const NINJA_SHADOW_CLOTH_ALBEDO = preload("res://assets/textures/skins/ninja_shadow_cloth_albedo.png")
const NINJA_SHADOW_BLADE_ALBEDO = preload("res://assets/textures/skins/ninja_shadow_blade_albedo.png")
const NINJA_SHADOW_BLADE_EMISSION = preload("res://assets/textures/skins/ninja_shadow_blade_emission.png")

const NINJA_FIRE_ARMOR_ALBEDO = preload("res://assets/textures/skins/ninja_fire_armor_albedo.png")
const NINJA_FIRE_ARMOR_NORMAL = preload("res://assets/textures/skins/ninja_fire_armor_normal.png")
const NINJA_FIRE_BLADE_ALBEDO = preload("res://assets/textures/skins/ninja_fire_blade_albedo.png")
const NINJA_FIRE_BLADE_EMISSION = preload("res://assets/textures/skins/ninja_fire_blade_emission.png")

const NINJA_ARCTIC_ARMOR_ALBEDO = preload("res://assets/textures/skins/ninja_arctic_armor_albedo.png")
const NINJA_ARCTIC_ARMOR_NORMAL = preload("res://assets/textures/skins/ninja_arctic_armor_normal.png")
const NINJA_ARCTIC_BLADE_ALBEDO = preload("res://assets/textures/skins/ninja_arctic_blade_albedo.png")
const NINJA_ARCTIC_BLADE_EMISSION = preload("res://assets/textures/skins/ninja_arctic_blade_emission.png")

const NINJA_CRIMSON_ARMOR_ALBEDO = preload("res://assets/textures/skins/ninja_crimson_armor_albedo.png")
const NINJA_CRIMSON_ARMOR_NORMAL = preload("res://assets/textures/skins/ninja_crimson_armor_normal.png")
const NINJA_CRIMSON_BLADE_ALBEDO = preload("res://assets/textures/skins/ninja_crimson_blade_albedo.png")
const NINJA_CRIMSON_BLADE_EMISSION = preload("res://assets/textures/skins/ninja_crimson_blade_emission.png")

# --- NINJA GLOWING VISORS ---
const NINJA_VOLT_VISOR_ALBEDO = preload("res://assets/textures/skins/ninja_volt_visor_albedo.png")
const NINJA_VOLT_VISOR_EM = preload("res://assets/textures/skins/ninja_volt_visor_emission.png")
const NINJA_FIRE_VISOR_ALBEDO = preload("res://assets/textures/skins/ninja_fire_visor_albedo.png")
const NINJA_FIRE_VISOR_EM = preload("res://assets/textures/skins/ninja_fire_visor_emission.png")
const NINJA_ARCTIC_VISOR_ALBEDO = preload("res://assets/textures/skins/ninja_arctic_visor_albedo.png")
const NINJA_ARCTIC_VISOR_EM = preload("res://assets/textures/skins/ninja_arctic_visor_emission.png")
const NINJA_CRIMSON_VISOR_ALBEDO = preload("res://assets/textures/skins/ninja_crimson_visor_albedo.png")
const NINJA_CRIMSON_VISOR_EM = preload("res://assets/textures/skins/ninja_crimson_visor_emission.png")

# --- VALKYRIE TEXTURES ---
const VALKYRIE_PLATE_ALBEDO = preload("res://assets/textures/skins/valkyrie_plate_albedo.png")
const VALKYRIE_PLATE_NORMAL = preload("res://assets/textures/skins/valkyrie_plate_normal.png")
const VALKYRIE_WINGS_EMISSION = preload("res://assets/textures/skins/valkyrie_wings_emission.png")

# --- DRAGON TEXTURES ---
const DRAGON_SCALE_ALBEDO = preload("res://assets/textures/skins/dragon_scale_albedo.png")
const DRAGON_SCALE_NORMAL = preload("res://assets/textures/skins/dragon_scale_normal.png")
const DRAGON_SCALE_EMISSION = preload("res://assets/textures/skins/dragon_scale_emission.png")

# --- ANUBIS TEXTURES ---
const ANUBIS_OBSIDIAN_ALBEDO = preload("res://assets/textures/skins/anubis_obsidian_albedo.png")
const ANUBIS_OBSIDIAN_NORMAL = preload("res://assets/textures/skins/anubis_obsidian_normal.png")
const ANUBIS_OBSIDIAN_EMISSION = preload("res://assets/textures/skins/anubis_obsidian_emission.png")

# --- SPECTER TEXTURES ---
const SPECTER_CRYSTAL_ALBEDO = preload("res://assets/textures/skins/specter_crystal_albedo.png")
const SPECTER_CRYSTAL_NORMAL = preload("res://assets/textures/skins/specter_crystal_normal.png")
const SPECTER_CRYSTAL_EMISSION = preload("res://assets/textures/skins/specter_crystal_emission.png")

# --- PHOENIX TEXTURES ---
const PHOENIX_FEATHER_ALBEDO = preload("res://assets/textures/skins/phoenix_feather_albedo.png")
const PHOENIX_FEATHER_NORMAL = preload("res://assets/textures/skins/phoenix_feather_normal.png")
const PHOENIX_FEATHER_EMISSION = preload("res://assets/textures/skins/phoenix_feather_emission.png")

# --- VFX PARTICLES & ATTACK SPRITES ---
const LAVA_EMBER_TEX = preload("res://assets/textures/vfx/lava_ember.png")
const ELECTRIC_SPARK_TEX = preload("res://assets/textures/vfx/electric_spark.png")
const VFX_SLASH_KATANA = preload("res://assets/textures/vfx/slash_katana.png")
const VFX_SLASH_ICE = preload("res://assets/textures/vfx/slash_ice.png")
const VFX_SLASH_FIRE = preload("res://assets/textures/vfx/slash_fire.png")
const VFX_SLASH_WIND = preload("res://assets/textures/vfx/slash_wind.png")
const VFX_SLASH_BLOOD = preload("res://assets/textures/vfx/slash_blood.png")
const VFX_BLAST_BEAM_WIDE = preload("res://assets/textures/vfx/blast_beam_wide.png")
const VFX_BLAST_BEAM_NEEDLE = preload("res://assets/textures/vfx/blast_beam_needle.png")
const VFX_BLAST_SHOCKWAVE = preload("res://assets/textures/vfx/blast_shockwave.png")
const VFX_BLAST_SPIRAL = preload("res://assets/textures/vfx/blast_spiral.png")
const VFX_IMPACT_HEAVY_PUNCH = preload("res://assets/textures/vfx/impact_heavy_punch.png")
const VFX_IMPACT_LIGHTNING = preload("res://assets/textures/vfx/impact_lightning_strike.png")
const VFX_IMPACT_ICE_SPIKES = preload("res://assets/textures/vfx/impact_ice_spikes.png")

var animation: AnimationPlayer
var model: Node3D
var profile: Dictionary
var current_pose := ""
var clip_map := {}
var glow_materials: Array = []
var base_emissions: Array = []
var aura_particles: CPUParticles3D
var pulse_time := 0.0

var shield: MeshInstance3D
var custom_attack_node: Node3D = null
var custom_special_node: Node3D = null
var attack_sprite_inst: MeshInstance3D = null
var special_sprite_inst: MeshInstance3D = null
var skin_glow_color := Color("4ae5ff")
var equipped_items_nodes: Array = []
var base_model_scale := Vector3.ONE
var skeleton: Skeleton3D = null
var bone_map: Dictionary = {}
var freeze_block: MeshInstance3D = null
var scale_base := Vector3.ZERO
var squash := 0.0
var lean := 0.0
var was_grounded := true
## Own gear and outfit of the house heroes (hero_gear.gd), null for everyone else.
var hero_gear: Node3D = null
const HeroGear = preload("res://scripts/hero_gear.gd")

## Recently used model scenes stay loaded, so switching back to a fighter does not
## re-read large GLB files from disk. Least recently used entries are evicted.
const MODEL_CACHE_SIZE := 8
static var _model_cache: Dictionary = {}
static var _model_cache_order: Array = []

## Rigged, textured bodies for fighters whose original models were blocky primitives
## (and for fighters that shared a body with another card). Each body is unique.
const MIXAMO_BODIES := {
	"kairo": "gladiator_heraklios", "varakh": "exo_red", "xylar": "demon_warlord",
	"ren": "kachujin_dragon", "amethya": "assassin_night", "oryn": "paladin_nord",
	"glaciem": "exo_gray", "zip": "crypto_cyber", "raiga": "maw_alien",
	"albion": "maria_prop", "pyrax": "parasite_beast", "anubis": "cyber_xbot",
	"phoenix": "eve_warrior", "specter": "arissa_fighter", "dragon": "castle_guard",
	"golem": "pumpkin_abomination", "tobi": "brute_titan", "jubei": "elven_archer",
	"nekra": "zombie_girl", "grimbolt": "goblin_warrior", "echo": "cyber_ybot",
	"kettenwart": "war_zombie", "don_valente": "boss_enforcer", "lepora": "eve_warrior", "bruno": "samurai_dreyar",
}

static func load_model_scene(path: String) -> PackedScene:
	if _model_cache.has(path):
		_model_cache_order.erase(path)
		_model_cache_order.append(path)
		return _model_cache[path]
	var scene: PackedScene = load(path)
	_model_cache[path] = scene
	_model_cache_order.append(path)
	while _model_cache_order.size() > MODEL_CACHE_SIZE:
		_model_cache.erase(_model_cache_order.pop_front())
	return scene

func setup(p: Dictionary) -> void:
	profile = p
	var boss_body := ""
	if p.has("boss"):
		boss_body = str(load("res://scripts/bosses.gd").data(str(p.boss)).get("body", ""))
		if boss_body == "" or not ResourceLoader.exists(boss_body):
			# Abstract bosses (seraph, wheels, cherub, fly): procedural body, no skeleton, animates itself.
			boss_body = ""
			model = load("res://scripts/boss_models.gd").build(str(p.boss))
			set_meta("model_path", "boss:" + str(p.boss))
			add_child(model)
			return
	var m_path := "res://assets/models/%s.glb" % p.family
	if p.has("model_path") and ResourceLoader.exists(p.model_path):
		m_path = p.model_path
	elif ResourceLoader.exists("res://assets/models/mixamo/%s.glb" % p.family):
		m_path = "res://assets/models/mixamo/%s.glb" % p.family
	elif MIXAMO_BODIES.has(p.family) and ResourceLoader.exists("res://assets/models/mixamo/%s.glb" % MIXAMO_BODIES[p.family]):
		m_path = "res://assets/models/mixamo/%s.glb" % MIXAMO_BODIES[p.family]
	elif p.family == "ninja" and ResourceLoader.exists("res://assets/models/mixamo/ninja_master.glb"):
		m_path = "res://assets/models/mixamo/ninja_master.glb"
	elif p.family == "valkyrie" and ResourceLoader.exists("res://assets/models/mixamo/paladin_armed.glb"):
		m_path = "res://assets/models/mixamo/paladin_armed.glb"
	elif p.family == "golem" and ResourceLoader.exists("res://assets/models/mixamo/warrok_brute.glb"):
		m_path = "res://assets/models/mixamo/warrok_brute.glb"
	elif p.family == "dragon" and ResourceLoader.exists("res://assets/models/mixamo/samurai_dreyar.glb"):
		m_path = "res://assets/models/mixamo/samurai_dreyar.glb"
	elif p.family == "specter" and ResourceLoader.exists("res://assets/models/mixamo/vampire_lord.glb"):
		m_path = "res://assets/models/mixamo/vampire_lord.glb"
	elif p.family == "jubei" and ResourceLoader.exists("res://assets/models/mixamo/samurai_dreyar.glb"):
		m_path = "res://assets/models/mixamo/samurai_dreyar.glb"
	elif p.family == "tobi" and ResourceLoader.exists("res://assets/models/mixamo/pirate_captain.glb"):
		m_path = "res://assets/models/mixamo/pirate_captain.glb"
	elif p.family == "bruno" and ResourceLoader.exists("res://assets/models/mixamo/martial_yaku.glb"):
		m_path = "res://assets/models/mixamo/martial_yaku.glb"
	elif p.family == "hikaru" and ResourceLoader.exists("res://assets/models/mixamo/monk_ganfaul.glb"):
		m_path = "res://assets/models/mixamo/monk_ganfaul.glb"
	elif p.family == "steel_knight" and ResourceLoader.exists("res://assets/models/mixamo/steel_knight.glb"):
		m_path = "res://assets/models/mixamo/steel_knight.glb"
	elif p.family == "vanguard_soldier" and ResourceLoader.exists("res://assets/models/mixamo/vanguard_soldier.glb"):
		m_path = "res://assets/models/mixamo/vanguard_soldier.glb"
	elif p.family == "sorceress_medea" and ResourceLoader.exists("res://assets/models/mixamo/sorceress_medea.glb"):
		m_path = "res://assets/models/mixamo/sorceress_medea.glb"
	elif p.family == "skeleton_reaper" and ResourceLoader.exists("res://assets/models/mixamo/skeleton_reaper.glb"):
		m_path = "res://assets/models/mixamo/skeleton_reaper.glb"
	elif p.family == "mutant_titan" and ResourceLoader.exists("res://assets/models/mixamo/mutant_titan.glb"):
		m_path = "res://assets/models/mixamo/mutant_titan.glb"
	elif p.family == "swat_specops" and ResourceLoader.exists("res://assets/models/mixamo/swat_specops.glb"):
		m_path = "res://assets/models/mixamo/swat_specops.glb"

	if boss_body != "":
		m_path = boss_body
		set_meta("boss_body", true)
	model = load_model_scene(m_path).instantiate()
	set_meta("model_path", m_path)
	add_child(model)

	# Robust universal height normalization
	var max_mesh_height := 0.0
	for m in model.find_children("*", "MeshInstance3D", true, false):
		if m.mesh:
			max_mesh_height = maxf(max_mesh_height, m.mesh.get_aabb().size.y)

	var target_h: float = 2.15 if p.family in ["warrok_brute", "mutant_titan", "golem", "golden_golem", "pumpkin_abomination", "kettenwart"] else 1.80
	if p.has("boss"): target_h = float(load("res://scripts/bosses.gd").data(str(p.boss)).get("height", 3.3))
	elif p.family == "grimbolt": target_h = 1.3   # small goblin
	elif p.family == "don_valente": target_h = 1.9
	if max_mesh_height > 0.05:
		model.scale = Vector3.ONE * (target_h / max_mesh_height)
	else:
		model.scale = Vector3.ONE * 1.0

	base_model_scale = model.scale

	for child in model.find_children("*", "AnimationPlayer", true, false):
		animation = child
	if animation:
		for clip in animation.get_animation_list():
			if "GumGum" in str(clip) or "Pistol" in str(clip):
				clip_map["SpecialAttack"] = clip
				clip_map["LightAttack"] = clip
			for pose in ["Idle", "Move", "LightAttack", "SpecialAttack", "HitReact", "Defeat", "Victory"]:
				if str(clip).ends_with(pose):
					clip_map[pose] = clip
					if pose in ["Idle", "Move"]:
						animation.get_animation(clip).loop_mode = Animation.LOOP_LINEAR
		if clip_map.has("LightAttack"):
			clip_map["Attack"] = clip_map["LightAttack"]
			clip_map["Throw"] = clip_map["LightAttack"]
			clip_map["Grab"] = clip_map["LightAttack"]
		if clip_map.has("Idle"):
			clip_map["Carrying"] = clip_map["Idle"]
		if clip_map.has("HitReact"):
			clip_map["Grabbed"] = clip_map["HitReact"]
		if clip_map.has("Idle"):
			animation.play(clip_map["Idle"])
			current_pose = "Idle"

	var skels = model.find_children("*", "Skeleton3D", true, false)
	if skels.size() > 0:
		skeleton = skels[0]
		bone_map.clear()
		var search_patterns = {
			"hips": ["mixamorig_Hips", "Hips", "Pelvis", "hips", "pelvis", "Root"],
			"spine": ["mixamorig_Spine", "mixamorig_Spine1", "Spine", "Spine1", "spine"],
			"head": ["mixamorig_Head", "Head", "head"],
			"left_arm": ["mixamorig_LeftArm", "LeftArm", "LeftUpperArm", "left_arm", "UpperArm.L", "arm.L"],
			"left_forearm": ["mixamorig_LeftForeArm", "LeftForeArm", "LeftLowerArm", "left_forearm", "ForeArm.L"],
			"right_arm": ["mixamorig_RightArm", "RightArm", "RightUpperArm", "right_arm", "UpperArm.R", "arm.R"],
			"right_forearm": ["mixamorig_RightForeArm", "RightForeArm", "RightLowerArm", "right_forearm", "ForeArm.R"],
			"left_leg": ["mixamorig_LeftUpLeg", "LeftUpLeg", "LeftThigh", "left_upleg", "Thigh.L"],
			"left_shin": ["mixamorig_LeftLeg", "LeftLeg", "LeftShin", "left_leg", "Shin.L"],
			"right_leg": ["mixamorig_RightUpLeg", "RightUpLeg", "RightThigh", "right_upleg", "Thigh.R"],
			"right_shin": ["mixamorig_RightLeg", "RightLeg", "RightShin", "right_leg", "Shin.R"]
		}
		for b_key in search_patterns:
			for candidate in search_patterns[b_key]:
				var idx = skeleton.find_bone(candidate)
				if idx != -1:
					bone_map[b_key] = idx
					break
			if not bone_map.has(b_key):
				for b_idx in range(skeleton.get_bone_count()):
					var bn := skeleton.get_bone_name(b_idx).to_lower()
					if b_key == "hips" and ("hips" in bn or "pelvis" in bn): bone_map[b_key] = b_idx; break
					elif b_key == "spine" and ("spine" in bn): bone_map[b_key] = b_idx; break
					elif b_key == "head" and ("head" in bn): bone_map[b_key] = b_idx; break
					elif b_key == "left_arm" and ("leftarm" in bn or "left_arm" in bn or "leftupperarm" in bn) and not "shoulder" in bn: bone_map[b_key] = b_idx; break
					elif b_key == "right_arm" and ("rightarm" in bn or "right_arm" in bn or "rightupperarm" in bn) and not "shoulder" in bn: bone_map[b_key] = b_idx; break
					elif b_key == "left_forearm" and ("leftforearm" in bn or "left_forearm" in bn or "leftlowerarm" in bn): bone_map[b_key] = b_idx; break
					elif b_key == "right_forearm" and ("rightforearm" in bn or "right_forearm" in bn or "rightlowerarm" in bn): bone_map[b_key] = b_idx; break
					elif b_key == "left_leg" and ("leftupleg" in bn or "leftthigh" in bn): bone_map[b_key] = b_idx; break
					elif b_key == "right_leg" and ("rightupleg" in bn or "rightthigh" in bn): bone_map[b_key] = b_idx; break
					elif b_key == "left_shin" and ("leftleg" in bn or "leftshin" in bn) and not "up" in bn: bone_map[b_key] = b_idx; break
					elif b_key == "right_shin" and ("rightleg" in bn or "rightshin" in bn) and not "up" in bn: bone_map[b_key] = b_idx; break

	if _is_scanned_model(p.family):
		_fit_scanned_model(p.family, target_h)
	else:
		_normalize_by_head(target_h)
	setup_freeze_block()

	var p_text: String = str(p.get("prompt", "")).to_lower()
	var element: String = str(p.get("element", "shadow")).to_lower()

	# -------------------------------------------------------------------------
	# SELECT SKIN ASSETS MATCHING PROMPT & ELEMENT
	# -------------------------------------------------------------------------
	var skin_rock_albedo: Texture2D
	var skin_rock_norm: Texture2D
	var skin_core_albedo: Texture2D
	var skin_core_em: Texture2D
	var skin_cloth_albedo: Texture2D
	var skin_visor_albedo: Texture2D
	var skin_visor_em: Texture2D
	var skin_glow_color: Color = p.get("color", Color("49def4"))
	var skin_roughness := 0.65
	var skin_metallic := 0.0
	var triplanar_scale: Vector3

	if p.family == "golem":
		triplanar_scale = Vector3(0.012, 0.012, 0.012)
		if "frost" in p_text or "eis" in p_text or "ice" in p_text or element == "ice":
			skin_rock_albedo = GOLEM_FROST_ROCK_ALBEDO
			skin_rock_norm = GOLEM_FROST_ROCK_NORMAL
			skin_core_albedo = GOLEM_FROST_CORE_ALBEDO
			skin_core_em = GOLEM_FROST_CORE_EMISSION
			skin_glow_color = Color("5ee7ff")
			skin_roughness = 0.45
		elif "toxic" in p_text or "gift" in p_text or "spore" in p_text or "green" in p_text:
			skin_rock_albedo = GOLEM_TOXIC_ROCK_ALBEDO
			skin_rock_norm = GOLEM_TOXIC_ROCK_NORMAL
			skin_core_albedo = GOLEM_TOXIC_CORE_ALBEDO
			skin_core_em = GOLEM_TOXIC_CORE_EMISSION
			skin_glow_color = Color("76ff43")
			skin_roughness = 0.70
		elif "storm" in p_text or "blitz" in p_text or "donner" in p_text or element == "electric":
			skin_rock_albedo = GOLEM_STORM_ROCK_ALBEDO
			skin_rock_norm = GOLEM_STORM_ROCK_NORMAL
			skin_core_albedo = GOLEM_STORM_CORE_ALBEDO
			skin_core_em = GOLEM_STORM_CORE_EMISSION
			skin_glow_color = Color("ffd24a")
			skin_roughness = 0.55
		else: # Default Lava Bastion
			skin_rock_albedo = GOLEM_LAVA_ROCK_ALBEDO
			skin_rock_norm = GOLEM_LAVA_ROCK_NORMAL
			skin_core_albedo = GOLEM_LAVA_CORE_ALBEDO
			skin_core_em = GOLEM_LAVA_CORE_EMISSION
			skin_glow_color = Color("ff6d2b")
			skin_roughness = 0.72
	elif p.family == "valkyrie":
		triplanar_scale = Vector3(0.018, 0.018, 0.018)
		skin_rock_albedo = NINJA_ARCTIC_ARMOR_ALBEDO
		skin_rock_norm = NINJA_ARCTIC_ARMOR_NORMAL
		skin_cloth_albedo = NINJA_SHADOW_CLOTH_ALBEDO
		skin_core_albedo = NINJA_ARCTIC_BLADE_ALBEDO
		skin_core_em = NINJA_ARCTIC_BLADE_EMISSION
		skin_glow_color = p.get("color", Color("ffe26a"))
		skin_metallic = 0.65
		skin_roughness = 0.22
	elif p.family == "dragon":
		triplanar_scale = Vector3(0.015, 0.015, 0.015)
		skin_rock_albedo = GOLEM_LAVA_ROCK_ALBEDO
		skin_rock_norm = GOLEM_LAVA_ROCK_NORMAL
		skin_core_albedo = NINJA_FIRE_BLADE_ALBEDO
		skin_core_em = NINJA_FIRE_BLADE_EMISSION
		if "frost" in p_text or "ice" in p_text or "eis" in p_text or "blau" in p_text or "blue" in p_text or element == "ice":
			skin_glow_color = Color("3ae8ff")
		elif "shadow" in p_text or "schatten" in p_text or "void" in p_text or "dark" in p_text:
			skin_glow_color = Color("bf42ff")
		elif "toxic" in p_text or "gift" in p_text or "acid" in p_text:
			skin_glow_color = Color("68ff3b")
		else:
			skin_glow_color = p.get("color", Color("ff5511"))
		skin_metallic = 0.85
		skin_roughness = 0.24
	elif p.family == "glaciem":
		triplanar_scale = Vector3(0.020, 0.020, 0.020)
		skin_glow_color = Color("4ad4ff")
		skin_metallic = 0.88
		skin_roughness = 0.22
	elif p.family == "oryn":
		triplanar_scale = Vector3(0.018, 0.018, 0.018)
		skin_glow_color = Color("9900ee")
		skin_metallic = 0.15
		skin_roughness = 0.65
	elif p.family == "tobi":
		triplanar_scale = Vector3(0.018, 0.018, 0.018)
		skin_glow_color = Color("ff2b2b")
		skin_metallic = 0.05
		skin_roughness = 0.55
	elif p.family == "zip":
		triplanar_scale = Vector3(0.018, 0.018, 0.018)
		skin_glow_color = Color("00a2ff")
		skin_metallic = 0.08
		skin_roughness = 0.35
	elif p.family == "raiga":
		triplanar_scale = Vector3(0.018, 0.018, 0.018)
		skin_glow_color = Color("00e5ff")
		skin_metallic = 0.05
		skin_roughness = 0.45
	elif p.family == "albion":
		triplanar_scale = Vector3(0.018, 0.018, 0.018)
		skin_glow_color = Color("70d6ff")
		skin_metallic = 0.35
		skin_roughness = 0.28
	elif p.family == "ren":
		triplanar_scale = Vector3(0.018, 0.018, 0.018)
		skin_glow_color = Color("4ae0ff")
		skin_metallic = 0.10
		skin_roughness = 0.50
	elif p.family == "varakh":
		triplanar_scale = Vector3(0.018, 0.018, 0.018)
		skin_glow_color = Color("ffe838") # Final Flash Gold
		skin_metallic = 0.30
		skin_roughness = 0.35
	elif p.family == "jubei":
		triplanar_scale = Vector3(0.018, 0.018, 0.018)
		skin_glow_color = Color("3bfac8") # Wind Slash Emerald
		skin_metallic = 0.25
		skin_roughness = 0.40
	elif p.family == "bruno":
		triplanar_scale = Vector3(0.018, 0.018, 0.018)
		skin_glow_color = Color("ff3322") # Serious Force Crimson
		skin_metallic = 0.15
		skin_roughness = 0.35
	elif p.family == "hikaru":
		triplanar_scale = Vector3(0.018, 0.018, 0.018)
		skin_glow_color = Color("ff6524") # Hinokami Fire Orange
		skin_metallic = 0.18
		skin_roughness = 0.45
	elif p.family == "amethya":
		triplanar_scale = Vector3(0.018, 0.018, 0.018)
		skin_glow_color = Color("60d5ff")
		skin_metallic = 0.20
		skin_roughness = 0.38
	elif p.family == "xylar":
		triplanar_scale = Vector3(0.018, 0.018, 0.018)
		skin_glow_color = Color("b438ff") # Imperial Purple
		skin_metallic = 0.25
		skin_roughness = 0.25
	elif p.family == "pyrax":
		triplanar_scale = Vector3(0.018, 0.018, 0.018)
		skin_glow_color = Color("ff6610") # Fire Dragon Flame
		skin_metallic = 0.05
		skin_roughness = 0.38
	else: # Ninja
		triplanar_scale = Vector3(0.016, 0.016, 0.016)
		if "fire" in p_text or "feuer" in p_text or "flam" in p_text or "lava" in p_text or element == "fire":
			skin_rock_albedo = NINJA_FIRE_ARMOR_ALBEDO
			skin_rock_norm = NINJA_FIRE_ARMOR_NORMAL
			skin_cloth_albedo = NINJA_FIRE_ARMOR_ALBEDO
			skin_core_albedo = NINJA_FIRE_BLADE_ALBEDO
			skin_core_em = NINJA_FIRE_BLADE_EMISSION
			skin_visor_albedo = NINJA_FIRE_VISOR_ALBEDO
			skin_visor_em = NINJA_FIRE_VISOR_EM
			skin_glow_color = Color("ff7733")
			skin_metallic = 0.58
			skin_roughness = 0.26
		elif "frost" in p_text or "arctic" in p_text or "ice" in p_text or "weiss" in p_text or "white" in p_text or element == "ice":
			skin_rock_albedo = NINJA_ARCTIC_ARMOR_ALBEDO
			skin_rock_norm = NINJA_ARCTIC_ARMOR_NORMAL
			skin_cloth_albedo = NINJA_SHADOW_CLOTH_ALBEDO
			skin_core_albedo = NINJA_ARCTIC_BLADE_ALBEDO
			skin_core_em = NINJA_ARCTIC_BLADE_EMISSION
			skin_visor_albedo = NINJA_ARCTIC_VISOR_ALBEDO
			skin_visor_em = NINJA_ARCTIC_VISOR_EM
			skin_glow_color = Color("6ee9ff")
			skin_metallic = 0.65
			skin_roughness = 0.22
		elif "crimson" in p_text or "rot" in p_text or "red" in p_text or "blood" in p_text:
			skin_rock_albedo = NINJA_CRIMSON_ARMOR_ALBEDO
			skin_rock_norm = NINJA_CRIMSON_ARMOR_NORMAL
			skin_cloth_albedo = NINJA_SHADOW_CLOTH_ALBEDO
			skin_core_albedo = NINJA_CRIMSON_BLADE_ALBEDO
			skin_core_em = NINJA_CRIMSON_BLADE_EMISSION
			skin_visor_albedo = NINJA_CRIMSON_VISOR_ALBEDO
			skin_visor_em = NINJA_CRIMSON_VISOR_EM
			skin_glow_color = Color("ff2b4a")
			skin_metallic = 0.58
			skin_roughness = 0.26
		else: # Default Cyber Shadow / Volt
			skin_rock_albedo = NINJA_SHADOW_ARMOR_ALBEDO
			skin_rock_norm = NINJA_SHADOW_ARMOR_NORMAL
			skin_cloth_albedo = NINJA_SHADOW_CLOTH_ALBEDO
			skin_core_albedo = NINJA_SHADOW_BLADE_ALBEDO
			skin_core_em = NINJA_SHADOW_BLADE_EMISSION
			skin_visor_albedo = NINJA_VOLT_VISOR_ALBEDO
			skin_visor_em = NINJA_VOLT_VISOR_EM
			skin_glow_color = Color("3ae8ff")
			skin_metallic = 0.60
			skin_roughness = 0.25

	# -------------------------------------------------------------------------
	# APPLY DETAILED SHADING ACCORDING TO MESH IDENTITY & ARCHETYPE
	# -------------------------------------------------------------------------
	for mesh in model.find_children("*", "MeshInstance3D", true, false):
		for surface in range(mesh.mesh.get_surface_count()):
			var original = mesh.get_active_material(surface)
			var mat: StandardMaterial3D
			if original is StandardMaterial3D:
				mat = original.duplicate()
			elif true:
				# GLB imported materials may be BaseMaterial3D or null – create fresh one
				mat = StandardMaterial3D.new()
			else:
				continue
			mat.cull_mode = BaseMaterial3D.CULL_DISABLED
			mat.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
			mat.specular_mode = BaseMaterial3D.SPECULAR_TOON

			# Assign fighter meshes to Visual Layers 1 & 2 for isolated 3-point rim lighting
			mesh.layers = 1 | 2
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON

			# PRESERVE AUTHENTIC FACE PLATES & UV-MAPPED FACIAL DETAILS
			if "Face" in mesh.name or "FacePlate" in mesh.name or "Face" in mat.resource_name:
				mat.uv1_triplanar = false
				mat.rim_enabled = true
				mat.rim = 0.65
				mat.rim_tint = 0.40
				mat.roughness = 0.48
				mat.metallic = 0.0
				if original is StandardMaterial3D and original.albedo_texture != null:
					mat.albedo_texture = original.albedo_texture
					mat.albedo_color = original.albedo_color
				else:
					mat.albedo_color = Color("f6d8c8")
				var face_outline := StandardMaterial3D.new()
				face_outline.cull_mode = BaseMaterial3D.CULL_FRONT
				face_outline.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
				face_outline.grow = true
				face_outline.grow_amount = 0.012
				face_outline.albedo_color = Color(0.04, 0.04, 0.06, 1.0)
				mat.next_pass = face_outline
				mesh.set_surface_override_material(surface, mat)
				continue

			if not p.family in ["ninja_legacy", "golem_legacy"]:
				mat.uv1_triplanar = false
				# Crisp grazing rim contour (cel look)
				mat.rim_enabled = true
				mat.rim = 0.78
				mat.rim_tint = 0.45
			else:
				mat.uv1_scale = triplanar_scale
				mat.uv1_triplanar = true
				mat.uv1_triplanar_sharpness = 8.0 if p.family == "ninja" else 3.0
				mat.rim_enabled = true
				mat.rim = 0.90
				mat.rim_tint = 0.65

			# Luxury Clearcoat on metallic plates and jewel/gem carapaces
			if mat.metallic > 0.35:
				mat.clearcoat_enabled = true
				mat.clearcoat = 0.85
				mat.clearcoat_roughness = 0.18

			# Subsurface wrap-around approximation for living skin meshes
			if ("Skin" in mesh.name or "Body" in mesh.name or "GEO" in mesh.name or "Arm" in mesh.name or "Leg" in mesh.name) and mat.metallic < 0.1:
				mat.subsurf_scatter_enabled = true
				mat.subsurf_scatter_strength = 0.22

			# Textured models keep their own textures. The four original families only use the
			# hand-made skins on their legacy meshes; on Mixamo bodies those skins rendered black.
			if p.family == "echo":
				# Hologram: translucent glowing cyan with a bright rim.
				mat.albedo_texture = null
				mat.albedo_color = Color(0.35, 1.0, 0.95, 0.5)
				mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				mat.emission_enabled = true
				mat.emission = Color("2dd4bf")
				mat.emission_energy_multiplier = 1.6
				mat.rim_enabled = true
				mat.rim = 1.0
				mat.rim_tint = 0.1
				mat.metallic = 0.0
				mat.roughness = 0.2
				glow_materials.append(mat)
				base_emissions.append(1.6)
				mesh.set_surface_override_material(surface, mat)
				continue
			var legacy_skin: bool = p.family in ["golem", "ninja", "valkyrie", "dragon"] and not "/mixamo/" in m_path
			var mixamo_body: bool = "/mixamo/" in m_path
			# BaseMaterial3D also covers ORM materials, which some bodies import with.
			if original is BaseMaterial3D and not legacy_skin and (original.albedo_texture != null or mixamo_body):
				mat.albedo_texture = original.albedo_texture
				# Light tint in the fighter's element color keeps shared bodies distinguishable.
				var base_col: Color = Color(1.0, 1.0, 1.0) if original.albedo_texture != null else original.albedo_color
				mat.albedo_color = base_col.lerp(skin_glow_color, 0.18) if p.family in ["golem", "ninja", "valkyrie", "dragon"] else base_col
				if original.albedo_texture == null:
					# Untextured body (robot mannequins): stylized metal in the fighter's element color.
					var body_col: Color = p.get("color", skin_glow_color)
					mat.albedo_color = body_col.darkened(0.3 if original.albedo_color.v > 0.25 else 0.55)
					original = null # skip the texture-derived roughness/metallic below
				mat.roughness = clampf(original.roughness, 0.20, 0.85) if original != null else 0.28
				mat.metallic = original.metallic if original != null else 0.75
				if original != null and original.normal_texture != null:
					mat.normal_enabled = true
					mat.normal_texture = original.normal_texture
				mat.rim_enabled = true
				mat.rim = 0.65
				mat.rim_tint = 0.35
				var outline := StandardMaterial3D.new()
				outline.cull_mode = BaseMaterial3D.CULL_FRONT
				outline.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
				outline.grow = true
				outline.grow_amount = 0.003
				outline.albedo_color = Color(0.04, 0.04, 0.06, 1.0)
				mat.next_pass = outline
				mesh.set_surface_override_material(surface, mat)
				continue

			if p.family == "golem":
				if "Crown" in mesh.name or "Core" in mesh.name or "Eye" in mesh.name or "KnuckleGlow" in mesh.name or "Fissure" in mesh.name or "SpineMagma" in mesh.name or "Lava" in mat.resource_name:
					mat.albedo_texture = skin_core_albedo
					mat.albedo_color = Color(1.5, 1.3, 1.0)
					mat.emission_enabled = true
					mat.emission_texture = skin_core_em
					mat.emission = skin_glow_color
					mat.emission_energy_multiplier = 4.2
					mat.roughness = 0.20
					glow_materials.append(mat)
					base_emissions.append(4.2)
				elif "Armor" in mat.resource_name or "Pectoral" in mesh.name or "Shoulder" in mesh.name or "KneePlate" in mesh.name or "Brow" in mesh.name or "Jaw" in mesh.name or "Fist" in mesh.name or "Trapezius" in mesh.name or "Carapace" in mesh.name:
					mat.albedo_texture = skin_rock_albedo
					mat.albedo_color = Color(0.95, 0.95, 0.95)
					mat.normal_enabled = true
					mat.normal_texture = skin_rock_norm
					mat.normal_scale = 3.2
					mat.roughness = skin_roughness
					mat.metallic = 0.15
				else:
					mat.albedo_texture = skin_rock_albedo
					mat.normal_enabled = true
					mat.normal_texture = skin_rock_norm
					mat.normal_scale = 2.4
					mat.roughness = skin_roughness
					mat.metallic = 0.08
			elif p.family == "valkyrie":
				if "Feather" in mesh.name or "WingArch" in mesh.name or "Gem" in mesh.name or "Edge" in mesh.name or "Tip" in mesh.name or "Eye" in mesh.name:
					# Radiant ethereal light wings, jewels and holy rapier edge
					mat.albedo_color = Color(1.8, 1.8, 1.8)
					mat.emission_enabled = true
					mat.emission_texture = VALKYRIE_WINGS_EMISSION
					mat.emission = Color("ffe57f") if ("Gem" in mesh.name or "Edge" in mesh.name or "Tip" in mesh.name) else Color("8fe4ff")
					mat.emission_energy_multiplier = 2.4
					mat.roughness = 0.12
					glow_materials.append(mat)
					base_emissions.append(2.4)
				elif "Hair" in mesh.name or "TwinTail" in mesh.name or "Bang" in mesh.name or "Brow" in mesh.name:
					# Radiant anime golden-blonde hair
					mat.albedo_color = Color("f8df65")
					mat.roughness = 0.28
					mat.metallic = 0.12
					mat.rim_enabled = true
					mat.rim = 0.85
				elif "Head" in mesh.name or "Skin" in mat.resource_name or "Neck" in mesh.name or "UpperArm" in mesh.name:
					# Porcelain anime skin tone
					mat.albedo_color = Color("f5ded3")
					mat.roughness = 0.52
					mat.metallic = 0.0
					mat.rim_enabled = true
					mat.rim = 0.45
				elif "Gold" in mat.resource_name or "Tiara" in mesh.name or "Ribbon" in mesh.name or "Trim" in mesh.name or "Guard" in mesh.name or "Crossguard" in mesh.name or "Pommel" in mesh.name or "Armlet" in mesh.name or "Sole" in mesh.name or "TassetGold" in mesh.name or "HeelWing" in mesh.name or "ShoulderWing" in mesh.name or "CorsetBoning" in mesh.name:
					# Polished royal gold armor filigree
					mat.albedo_color = Color("f5c842")
					mat.metallic = 0.94
					mat.roughness = 0.16
				elif "Cloth" in mat.resource_name or "Bow" in mesh.name or "Waist" in mesh.name or "Tabard" in mesh.name:
					# Deep royal azure blue fabric
					mat.albedo_color = Color("1a3264")
					mat.roughness = 0.78
					mat.metallic = 0.04
				elif "Spine" in mesh.name or "Steel" in mat.resource_name:
					# Polished rapier steel
					mat.albedo_color = Color("dbe4f0")
					mat.metallic = 0.96
					mat.roughness = 0.10
				else:
					# Pearlescent white paladin plate armor with high-res PBR normal relief
					mat.albedo_texture = VALKYRIE_PLATE_ALBEDO
					mat.albedo_color = Color("f2f5fb")
					mat.normal_enabled = true
					mat.normal_texture = VALKYRIE_PLATE_NORMAL
					mat.normal_scale = 1.6
					mat.roughness = 0.22
					mat.metallic = 0.65
					mat.rim_enabled = true
					mat.rim = 0.65
			elif p.family == "dragon":
				if "Flame" in mesh.name or "Glow" in mesh.name or "RuneChannel" in mesh.name or "Edge" in mesh.name or "BladeTip" in mesh.name or "Eye" in mesh.name or "PommelSpike" in mesh.name or "GuardCore" in mesh.name or "TailBlade" in mesh.name:
					# Radiant dragonfire & plasma blade edges
					var mult: float = 8.0 if "Eye" in mesh.name else (7.2 if ("Edge" in mesh.name or "BladeTip" in mesh.name or "RuneChannel" in mesh.name) else 6.0)
					mat.albedo_color = Color(2.5, 1.8, 1.4)
					mat.emission_enabled = true
					mat.emission_texture = DRAGON_SCALE_EMISSION
					mat.emission = skin_glow_color
					mat.emission_energy_multiplier = mult
					mat.roughness = 0.04
					mat.metallic = 0.85
					glow_materials.append(mat)
					base_emissions.append(mult)
				elif "Gold" in mat.resource_name or "Crest" in mesh.name or "Ring" in mesh.name or "JawGuard" in mesh.name or "SpineFin" in mesh.name or "TailFin" in mesh.name or "TailSpear" in mesh.name or "Claw" in mesh.name or "PauldronBlade" in mesh.name or "Spike" in mesh.name or "Crossguard" in mesh.name or "Pommel" in mesh.name or "KneeGuard" in mesh.name or "Belt" in mesh.name:
					# Rich polished draconic gold
					mat.albedo_color = Color("f5be38")
					mat.metallic = 0.96
					mat.roughness = 0.16
					mat.rim_enabled = true
					mat.rim = 0.75
				elif "Mane" in mesh.name:
					# Crimson dragon mane
					mat.albedo_color = Color("8c1d28")
					mat.roughness = 0.38
					mat.metallic = 0.12
					mat.rim_enabled = true
					mat.rim = 0.85
					mat.rim_tint = 0.65
				elif "Scale" in mesh.name or "Horn" in mesh.name or "TailSeg" in mesh.name or "Pauldron" in mesh.name or "Vambrace" in mesh.name or "ThighPlate" in mesh.name or "Foot" in mesh.name or "Carapace" in mesh.name:
					# Obsidian dragon scales with micro-normal relief
					mat.albedo_texture = DRAGON_SCALE_ALBEDO
					mat.albedo_color = Color(0.24, 0.25, 0.28)
					mat.normal_enabled = true
					mat.normal_texture = DRAGON_SCALE_NORMAL
					mat.normal_scale = 2.4
					mat.metallic = 0.55
					mat.roughness = 0.28
					mat.rim_enabled = true
					mat.rim = 0.80
					mat.rim_tint = 0.50
				else:
					# Dark brushed titanium alloy skeleton
					mat.albedo_color = Color(0.32, 0.35, 0.40)
					mat.metallic = 0.88
					mat.roughness = 0.22
					mat.rim_enabled = true
					mat.rim = 0.65
			elif p.family == "phoenix":
				if "Feather" in mesh.name or "Wing" in mesh.name or "Paul" in mesh.name or "Chest" in mesh.name or "Crown" in mesh.name:
					mat.albedo_texture = PHOENIX_FEATHER_ALBEDO
					mat.albedo_color = Color("d83212")
					mat.normal_enabled = true
					mat.normal_texture = PHOENIX_FEATHER_NORMAL
					mat.normal_scale = 1.8
					mat.roughness = 0.22
					mat.metallic = 0.35
					mat.rim_enabled = true
					mat.rim = 0.85
				elif "Gold" in mesh.name or "Trim" in mesh.name or "Claw" in mesh.name:
					mat.albedo_color = Color("f5c227")
					mat.metallic = 0.95
					mat.roughness = 0.12
				elif "Fire" in mesh.name or "Gem" in mesh.name or "Lava" in mesh.name or "Core" in mesh.name or "Glaive" in mesh.name:
					mat.albedo_color = Color(2.5, 1.5, 0.5)
					mat.emission_enabled = true
					mat.emission_texture = PHOENIX_FEATHER_EMISSION
					mat.emission = Color("ff6d2b")
					mat.emission_energy_multiplier = 5.0
					glow_materials.append(mat)
					base_emissions.append(5.0)
				else:
					mat.albedo_color = Color("8c1206")
					mat.roughness = 0.45
			elif p.family == "anubis":
				if "Gold" in mesh.name or "Trim" in mesh.name or "EarInner" in mesh.name or "Fang" in mesh.name or "Uraeus" in mesh.name or "Khopesh" in mesh.name:
					mat.albedo_color = Color("f0be24")
					mat.metallic = 0.96
					mat.roughness = 0.14
				elif "Lapis" in mesh.name or "Nemes" in mesh.name:
					mat.albedo_color = Color("142864")
					mat.roughness = 0.35
					mat.metallic = 0.30
				elif "Emerald" in mesh.name or "Glow" in mesh.name:
					mat.albedo_color = Color(0.8, 2.5, 1.5)
					mat.emission_enabled = true
					mat.emission_texture = ANUBIS_OBSIDIAN_EMISSION
					mat.emission = Color("2be58f")
					mat.emission_energy_multiplier = 4.8
					glow_materials.append(mat)
					base_emissions.append(4.8)
				else:
					mat.albedo_texture = ANUBIS_OBSIDIAN_ALBEDO
					mat.normal_enabled = true
					mat.normal_texture = ANUBIS_OBSIDIAN_NORMAL
					mat.normal_scale = 2.0
					mat.albedo_color = Color("1a1c22")
					mat.metallic = 0.70
					mat.roughness = 0.25
			elif p.family == "specter":
				if "Crystal" in mesh.name or "Lance" in mesh.name or "Prism" in mesh.name or "Spike" in mesh.name:
					mat.albedo_texture = SPECTER_CRYSTAL_ALBEDO
					mat.normal_enabled = true
					mat.normal_texture = SPECTER_CRYSTAL_NORMAL
					mat.normal_scale = 1.8
					mat.albedo_color = Color("c088ff")
					mat.metallic = 0.80
					mat.roughness = 0.08
					mat.rim_enabled = true
					mat.rim = 0.95
				elif "Void" in mesh.name or "Glow" in mesh.name or "Eye" in mesh.name or "Core" in mesh.name:
					mat.albedo_color = Color(2.0, 1.2, 3.0)
					mat.emission_enabled = true
					mat.emission_texture = SPECTER_CRYSTAL_EMISSION
					mat.emission = Color("9b30ff")
					mat.emission_energy_multiplier = 5.2
					glow_materials.append(mat)
					base_emissions.append(5.2)
				else:
					mat.albedo_color = Color("181028")
					mat.metallic = 0.65
					mat.roughness = 0.22
			elif p.family in ["golden_golem", "tripo_fantasy_female", "tripo_nyx_harvester", "tripo_cat_girl", "tripo_dragon_blue", "tripo_white_sci", "tripo_skeleton_dog", "tripo_wooden_forest", "tripo_nine_tailed", "tripo_quadruped_tree"] or p.family.begins_with("tripo_"):
				mat.uv1_triplanar = false
				mat.rim_enabled = true
				mat.rim = 0.78
				mat.rim_tint = 0.40
				if original != null and "albedo_texture" in original and original.albedo_texture != null:
					mat.albedo_texture = original.albedo_texture
				if original != null and "normal_texture" in original and original.normal_texture != null:
					mat.normal_enabled = true
					mat.normal_texture = original.normal_texture
				if p.family == "golden_golem":
					mat.metallic = 0.90
					mat.roughness = 0.20
					mat.clearcoat_enabled = true
					mat.clearcoat = 0.85
					if original != null and "albedo_texture" in original and original.albedo_texture != null:
						mat.albedo_texture = original.albedo_texture
						mat.albedo_color = Color(1.2, 1.1, 0.9)
					else:
						mat.albedo_color = Color("e5b820")
				elif p.family == "tripo_white_sci":
					mat.metallic = 0.72
					mat.roughness = 0.28
					mat.clearcoat_enabled = true
					mat.clearcoat = 0.70
				elif p.family == "tripo_nyx_harvester":
					mat.metallic = 0.38
					mat.roughness = 0.42
					mat.rim = 0.88
				elif p.family == "tripo_dragon_blue":
					mat.metallic = 0.25
					mat.roughness = 0.32
				elif p.family == "tripo_nine_tailed":
					mat.metallic = 0.12
					mat.roughness = 0.48
					mat.rim = 0.92
					mat.rim_tint = 0.65
				elif p.family in ["tripo_wooden_forest", "tripo_quadruped_tree"]:
					mat.metallic = 0.04
					mat.roughness = 0.82
					if mat.albedo_texture == null:
						# The Sylvan Beast scan ships untextured: mossy bark from the rock scan.
						mat.albedo_texture = load("res://assets/polyhaven/textures/mossy_rock/mossy_rock_diff_2k.jpg")
						mat.normal_enabled = true
						mat.normal_texture = load("res://assets/polyhaven/textures/mossy_rock/mossy_rock_nor_gl_2k.jpg")
						mat.uv1_triplanar = true
						mat.uv1_scale = Vector3.ONE * 1.6
						mat.albedo_color = Color(0.95, 1.0, 0.85)
						mat.rim = 0.35
			else: # Ninja
				if "Eye" in mesh.name or "Visor" in mesh.name or "Conduit" in mesh.name or "PowerPort" in mesh.name or "GreaveGlow" in mesh.name or "BackNode" in mesh.name or "Center" in mesh.name:
					# Sharp glowing cyber-shinobi energy nodes & assassin eye slits
					mat.albedo_color = Color(1.8, 1.8, 1.8)
					mat.emission_enabled = true
					mat.emission = skin_glow_color
					mat.emission_energy_multiplier = 5.2
					mat.roughness = 0.08
					glow_materials.append(mat)
					base_emissions.append(5.2)
				elif "Hair" in mesh.name or "Ponytail" in mesh.name or "Bang" in mesh.name:
					# Stylized dark shinobi hair with smooth sheen
					mat.albedo_color = Color(0.04, 0.05, 0.07)
					mat.roughness = 0.32
					mat.metallic = 0.08
					mat.rim_enabled = true
					mat.rim = 0.75
				elif "Skin" in mat.resource_name or "UpperArm" in mesh.name:
					# Warm anime martial artist skin tone on bare upper arms
					mat.albedo_color = Color("cfa286")
					mat.roughness = 0.58
					mat.metallic = 0.0
					mat.rim_enabled = true
					mat.rim = 0.45
				elif "Mask" in mesh.name:
					# Dark cloth face mask covering chin and mouth
					mat.albedo_texture = skin_cloth_albedo
					mat.albedo_color = Color(0.22, 0.25, 0.30)
					mat.roughness = 0.85
					mat.metallic = 0.0
				elif "Electric" in mat.resource_name or ("Katana" in mesh.name and surface == 1):
					# Plasma cutting edge on dual tech-ninjato
					mat.albedo_texture = skin_core_albedo
					mat.albedo_color = Color(1.5, 1.5, 1.5)
					mat.emission_enabled = true
					mat.emission_texture = skin_core_em
					mat.emission = skin_glow_color
					mat.emission_energy_multiplier = 4.8
					mat.roughness = 0.05
					mat.metallic = 0.95
					glow_materials.append(mat)
					base_emissions.append(4.8)
				elif "Katana" in mesh.name and surface == 0:
					# Sleek dark steel blade spine
					mat.albedo_color = Color(0.22, 0.25, 0.32)
					mat.metallic = 0.88
					mat.roughness = 0.18
				elif "Gold" in mat.resource_name or "Plate" in mesh.name or "Tsuba" in mesh.name or "Pommel" in mesh.name or "Buckle" in mesh.name or "PortRim" in mesh.name:
					# Gold clan emblem, buckle and sword fittings
					mat.albedo_color = Color("f0b429")
					mat.metallic = 0.95
					mat.roughness = 0.18
				elif "Bandana" in mesh.name or "Sash" in mesh.name or "Ribbon" in mesh.name or "Tail" in mesh.name or "Runner" in mesh.name:
					mat.albedo_color = Color("781528") if "crimson" in p_text else (Color("1a2f4c") if "arctic" in p_text else Color("1b2a48"))
					mat.roughness = 0.75
					mat.metallic = 0.05
				elif "Armor" in mat.resource_name or "Chest" in mesh.name or "Bracer" in mesh.name or "Greave" in mesh.name or "Shoulder" in mesh.name or "Pouch" in mesh.name or "Sole" in mesh.name:
					mat.albedo_texture = skin_rock_albedo
					mat.albedo_color = Color(0.22, 0.26, 0.32)
					mat.normal_enabled = true
					mat.normal_texture = skin_rock_norm
					mat.normal_scale = 2.2
					mat.metallic = skin_metallic
					mat.roughness = skin_roughness
				else:
					mat.albedo_texture = skin_cloth_albedo
					mat.albedo_color = Color(0.12, 0.14, 0.18)
					mat.roughness = 0.82
					mat.metallic = 0.04

			# ─────────────────────────────────────────────────────────────────
			# INVERTED HULL BLACK OUTLINE PASS (cel look)
			# ─────────────────────────────────────────────────────────────────
			var is_vfx_or_slit := "Eye" in mesh.name or "Rune" in mesh.name or "Spark" in mesh.name or "Fire" in mesh.name or "Beam" in mesh.name or "Conduit" in mesh.name or "PowerPort" in mesh.name
			if not is_vfx_or_slit:
				var outline := StandardMaterial3D.new()
				outline.cull_mode = BaseMaterial3D.CULL_FRONT
				outline.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
				outline.grow = true
				outline.grow_amount = 0.016
				outline.albedo_color = Color(0.04, 0.04, 0.06, 1.0)
				mat.next_pass = outline

			mesh.set_surface_override_material(surface, mat)

	# -------------------------------------------------------------------------
	# DEFENSE ENERGY BLOCK SHIELD (HOLOGRAPHIC HEXAGONAL FORCEFIELD)
	# -------------------------------------------------------------------------
	shield = MeshInstance3D.new()
	var shield_mesh := CylinderMesh.new()
	shield_mesh.top_radius = 0.62
	shield_mesh.bottom_radius = 0.62
	shield_mesh.height = 0.012
	shield_mesh.radial_segments = 6 # Hexagonal energy barrier
	shield.mesh = shield_mesh
	shield.rotation_degrees = Vector3(90, 0, 0)
	var shield_mat := StandardMaterial3D.new()
	shield_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	shield_mat.albedo_color = Color(skin_glow_color.r, skin_glow_color.g, skin_glow_color.b, 0.22)
	shield_mat.emission_enabled = true
	shield_mat.emission = skin_glow_color
	shield_mat.emission_energy_multiplier = 1.15
	shield_mat.rim_enabled = true
	shield_mat.rim = 1.0
	shield_mat.rim_tint = 0.9
	shield_mat.roughness = 0.15
	shield_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	shield.material_override = shield_mat

	# Outer glowing hexagonal contour rim
	var rim_instance := MeshInstance3D.new()
	var rim_mesh := TorusMesh.new()
	rim_mesh.inner_radius = 0.58
	rim_mesh.outer_radius = 0.625
	rim_mesh.rings = 6
	rim_mesh.ring_segments = 6
	rim_instance.mesh = rim_mesh
	rim_instance.rotation_degrees = Vector3.ZERO
	var rim_mat := StandardMaterial3D.new()
	rim_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	rim_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	rim_mat.albedo_color = Color(skin_glow_color.r * 1.5, skin_glow_color.g * 1.5, skin_glow_color.b * 1.5, 0.95)
	rim_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	rim_instance.material_override = rim_mat
	shield.add_child(rim_instance)

	# Inner concentric holographic hex reticle
	var inner_reticle := MeshInstance3D.new()
	var reticle_mesh := TorusMesh.new()
	reticle_mesh.inner_radius = 0.32
	reticle_mesh.outer_radius = 0.345
	reticle_mesh.rings = 6
	reticle_mesh.ring_segments = 6
	inner_reticle.mesh = reticle_mesh
	inner_reticle.rotation_degrees = Vector3.ZERO
	var reticle_mat := StandardMaterial3D.new()
	reticle_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	reticle_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	reticle_mat.albedo_color = Color(skin_glow_color.r, skin_glow_color.g, skin_glow_color.b, 0.8)
	reticle_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	inner_reticle.material_override = reticle_mat
	shield.add_child(inner_reticle)

	shield.visible = false
	add_child(shield)

	# -------------------------------------------------------------------------
	# CHARACTER AURA PARTICLES
	# -------------------------------------------------------------------------
	aura_particles = CPUParticles3D.new()
	aura_particles.amount = 26
	aura_particles.lifetime = 1.4
	aura_particles.preprocess = 0.8
	aura_particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	aura_particles.emission_box_extents = Vector3(0.5, 0.8, 0.35)
	aura_particles.position.y = 1.0
	aura_particles.direction = Vector3(0, 1, 0)
	aura_particles.spread = 30.0
	aura_particles.gravity = Vector3(0, 0.15, 0)
	aura_particles.initial_velocity_min = 0.35
	aura_particles.initial_velocity_max = 0.85
	aura_particles.color = skin_glow_color

	var aura_mat := StandardMaterial3D.new()
	aura_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	aura_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	aura_mat.vertex_color_use_as_albedo = true
	aura_mat.albedo_texture = LAVA_EMBER_TEX if (p.family == "golem" or p.family == "dragon") else ELECTRIC_SPARK_TEX
	aura_mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES

	var aura_quad := QuadMesh.new()
	aura_quad.size = Vector2(0.14, 0.14)
	aura_quad.material = aura_mat
	aura_particles.mesh = aura_quad
	add_child(aura_particles)

	# Ground marker ring
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 0.40
	torus.outer_radius = 0.45
	torus.rings = 24
	torus.ring_segments = 8
	ring.mesh = torus
	ring.position.y = 0.025
	var ring_mat := StandardMaterial3D.new()
	ring_mat.albedo_color = Color("4ce5ff") if p.slot == 0 else Color("ff884b")
	ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring.material_override = ring_mat
	add_child(ring)
	setup_equipment(p)
	setup_freeze_block()
	setup_character_vfx(p)
	if has_meta("boss_body"):
		load("res://scripts/boss_models.gd").decorate(self, str(p.boss))
	elif not p.has("boss"):
		hero_gear = HeroGear.equip(self, str(p.get("family", "")))

func setup_character_vfx(p: Dictionary) -> void:
	var fam: String = p.get("family", "")
	var elem: String = p.get("element", "").to_lower()

	# 1. ATTACK VFX (Normal attacks, slashes, punches, kicks)
	custom_attack_node = Node3D.new()
	custom_attack_node.name = "CustomAttackVFX"

	var atk_tex: Texture2D = VFX_IMPACT_HEAVY_PUNCH
	var atk_size := Vector2(1.5, 1.5)
	var atk_col := Color("ffffff")

	if fam in ["jubei", "samurai_dreyar", "steel_knight", "pirate_captain"]:
		atk_tex = VFX_SLASH_KATANA
		atk_col = Color("67e8f9")
		atk_size = Vector2(1.8, 1.8)
	elif fam in ["hikaru", "zip", "sylvan"] or elem == "wind":
		atk_tex = VFX_SLASH_WIND
		atk_col = Color("86efac")
		atk_size = Vector2(1.8, 1.8)
	elif fam in ["glaciem", "frost", "sorceress_medea"] or elem == "ice":
		atk_tex = VFX_SLASH_ICE
		atk_col = Color("7dd3fc")
		atk_size = Vector2(1.7, 1.7)
	elif fam in ["pyrax", "phoenix", "golem"] or elem == "fire":
		atk_tex = VFX_SLASH_FIRE
		atk_col = Color("fed7aa")
		atk_size = Vector2(1.8, 1.8)
	elif fam in ["vampire_lord", "skeleton_reaper", "specter", "anubis"] or elem in ["shadow", "dark", "blood"]:
		atk_tex = VFX_SLASH_BLOOD
		atk_col = Color("fda4af")
		atk_size = Vector2(1.9, 1.9)
	elif fam in ["volt_ninja", "cyber", "cyber_xbot", "crypto_cyber"] or elem == "electric":
		atk_tex = VFX_IMPACT_LIGHTNING
		atk_col = Color("e0f2fe")
		atk_size = Vector2(1.7, 1.7)
	elif fam in ["bruno", "mutant_titan", "warrok_brute", "martial_yaku", "monk_ganfaul"]:
		atk_tex = VFX_IMPACT_HEAVY_PUNCH
		atk_col = Color("fef08a")
		atk_size = Vector2(2.1, 2.1)

	var atk_quad := QuadMesh.new()
	atk_quad.size = atk_size
	attack_sprite_inst = MeshInstance3D.new()
	attack_sprite_inst.mesh = atk_quad
	var atk_mat := StandardMaterial3D.new()
	atk_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	atk_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	atk_mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	atk_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	atk_mat.albedo_texture = atk_tex
	atk_mat.albedo_color = atk_col
	attack_sprite_inst.material_override = atk_mat
	custom_attack_node.add_child(attack_sprite_inst)

	custom_attack_node.position = Vector3(0.75, 1.15, 0.05)
	custom_attack_node.visible = false
	add_child(custom_attack_node)

	# 2. SPECIAL ATTACK VFX (signature beams, shockwaves, spirals …)
	custom_special_node = Node3D.new()
	custom_special_node.name = "CustomSpecialVFX"

	var spec_tex: Texture2D = VFX_BLAST_BEAM_WIDE
	var spec_size := Vector2(2.6, 2.6)
	var spec_col := Color("ffffff")

	if fam == "kairo" or fam == "varakh":
		spec_tex = VFX_BLAST_BEAM_WIDE
		spec_size = Vector2(4.5, 1.8)
		spec_col = Color("38bdf8")
	elif fam == "xylar":
		spec_tex = VFX_BLAST_BEAM_NEEDLE
		spec_size = Vector2(4.5, 1.2)
		spec_col = Color("d946ef")
	elif fam == "oryn":
		spec_tex = VFX_BLAST_SHOCKWAVE
		spec_size = Vector2(3.2, 3.2)
		spec_col = Color("c084fc")
	elif fam == "ren":
		spec_tex = VFX_BLAST_SPIRAL
		spec_size = Vector2(2.4, 2.4)
		spec_col = Color("60a5fa")
	elif fam in ["glaciem", "frost", "sorceress_medea"]:
		spec_tex = VFX_IMPACT_ICE_SPIKES
		spec_size = Vector2(2.8, 2.8)
		spec_col = Color("93c5fd")
	elif fam in ["jubei", "samurai_dreyar"]:
		spec_tex = VFX_SLASH_WIND
		spec_size = Vector2(3.0, 3.0)
		spec_col = Color("4ade80")
	elif fam in ["vampire_lord", "skeleton_reaper", "specter"]:
		spec_tex = VFX_SLASH_BLOOD
		spec_size = Vector2(3.2, 3.2)
		spec_col = Color("f43f5e")
	elif fam in ["bruno", "mutant_titan", "warrok_brute"]:
		spec_tex = VFX_IMPACT_HEAVY_PUNCH
		spec_size = Vector2(3.5, 3.5)
		spec_col = Color("fbbf24")
	elif fam in ["pyrax", "phoenix", "golem"]:
		spec_tex = VFX_SLASH_FIRE
		spec_size = Vector2(3.0, 3.0)
		spec_col = Color("fb923c")
	elif fam in ["volt_ninja", "cyber"]:
		spec_tex = VFX_IMPACT_LIGHTNING
		spec_size = Vector2(3.2, 3.2)
		spec_col = Color("7dd3fc")

	var spec_quad := QuadMesh.new()
	spec_quad.size = spec_size
	special_sprite_inst = MeshInstance3D.new()
	special_sprite_inst.mesh = spec_quad
	var spec_mat := StandardMaterial3D.new()
	spec_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	spec_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	spec_mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	spec_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	spec_mat.albedo_texture = spec_tex
	spec_mat.albedo_color = spec_col
	special_sprite_inst.material_override = spec_mat
	custom_special_node.add_child(special_sprite_inst)

	custom_special_node.position = Vector3(1.2, 1.15, 0.05)
	custom_special_node.visible = false
	add_child(custom_special_node)

func setup_freeze_block() -> void:
	freeze_block = MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(1.15, 2.1, 1.15)
	freeze_block.mesh = box
	freeze_block.position.y = 1.05
	var f_mat := StandardMaterial3D.new()
	f_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	f_mat.albedo_color = Color(0.25, 0.80, 1.0, 0.60)
	f_mat.roughness = 0.05
	f_mat.metallic = 0.15
	f_mat.emission_enabled = true
	f_mat.emission = Color("4ae5ff")
	f_mat.emission_energy_multiplier = 1.6
	freeze_block.material_override = f_mat
	freeze_block.visible = false
	add_child(freeze_block)

## ── Rig-independent procedural animation ────────────────────────────────────────
## Poses are limb DIRECTIONS in character space (x = character's right, y = up,
## z = forward). Each frame every limb bone is rotated so that it points along its
## target direction. Because the targets do not depend on a rig's local bone axes,
## the same pose looks the same on every humanoid skeleton (Mixamo, custom rigs).

## Limb chain: bone key -> key of the bone that defines its direction.
const LIMB_CHAIN := [
	["spine", "head"],
	["left_arm", "left_forearm"], ["left_forearm", "left_hand"],
	["right_arm", "right_forearm"], ["right_forearm", "right_hand"],
	["left_leg", "left_shin"], ["left_shin", "left_foot"],
	["right_leg", "right_shin"], ["right_shin", "right_foot"],
]
var rig_ready := false
var rig_right := Vector3(-1, 0, 0)   # character axes in skeleton space
var rig_up := Vector3(0, 1, 0)
var rig_forward := Vector3(0, 0, 1)
var rig_child: Dictionary = {}       # bone key -> bone index that gives its direction
var proc_pose := ""
var proc_pose_age := 0.0
## Windup of the running move (from the simulation) – strikes land exactly when it ends.
var anim_windup := 0.1
var spin_angle := 0.0
var flip_angle := 0.0
var tumble_angle := 0.0

## Finds hands, feet and the character axes from the rest pose (once per model).
func _prepare_rig() -> void:
	rig_ready = true
	if skeleton == null: return
	for key in bone_map: rig_child[key] = bone_map[key]
	var ends := {"left_forearm": "left_hand", "right_forearm": "right_hand", "left_shin": "left_foot", "right_shin": "right_foot"}
	for key in ends:
		if not bone_map.has(key): continue
		var best := -1
		var best_len := -1.0
		for c in skeleton.get_bone_children(bone_map[key]):
			var l: float = skeleton.get_bone_rest(c).origin.length()
			if l > best_len and not "twist" in skeleton.get_bone_name(c).to_lower():
				best_len = l
				best = c
		if best >= 0: rig_child[ends[key]] = best
	if bone_map.has("left_arm") and bone_map.has("right_arm") and bone_map.has("hips") and bone_map.has("head"):
		var l_pos: Vector3 = skeleton.get_bone_global_rest(bone_map["left_arm"]).origin
		var r_pos: Vector3 = skeleton.get_bone_global_rest(bone_map["right_arm"]).origin
		var hip: Vector3 = skeleton.get_bone_global_rest(bone_map["hips"]).origin
		var head: Vector3 = skeleton.get_bone_global_rest(bone_map["head"]).origin
		if (head - hip).length() > 0.0001 and (r_pos - l_pos).length() > 0.0001:
			rig_up = (head - hip).normalized()
			rig_right = (r_pos - l_pos).normalized()
			rig_right = (rig_right - rig_up * rig_right.dot(rig_up)).normalized()
			rig_forward = rig_up.cross(rig_right).normalized()

## Some bodies carry extra scale inside their node tree, so mesh bounds give the wrong
## height. With a rig the head bone is reliable: rescale so it sits at ~87% of the height.
func _normalize_by_head(target_h: float) -> void:
	if skeleton == null or not bone_map.has("head") or not is_inside_tree(): return
	var head_y: float = (skeleton.global_transform * skeleton.get_bone_global_rest(bone_map["head"])).origin.y - global_position.y
	if head_y <= 0.05: return
	var ratio: float = (target_h * 0.87) / head_y
	if ratio < 0.8 or ratio > 1.25:
		model.scale *= ratio
		base_model_scale = model.scale

## Tripo scans (and the gold golem) come centred on their origin and, when rigged, as
## quadrupeds whose "head" bone is not near the top, so neither mesh height nor head
## height fits them. They are fitted by their real bounds instead.
static func _is_scanned_model(family: String) -> bool:
	return family.begins_with("tripo_") or family == "golden_golem"

## Scan creatures are bigger than humanoids but must not fill the stage.
const SCAN_HEIGHT := {"tripo_dragon_blue": 2.3, "tripo_skeleton_dog": 1.9, "tripo_nine_tailed": 2.2, "tripo_quadruped_tree": 2.3}
const SCAN_MAX_WIDTH := 3.2
## Scans face +X; Mixamo bodies (and the facing logic in update_state) face +Z.
const SCAN_YAW := -90.0
const SCAN_YAW_OVERRIDE := {"tripo_skeleton_dog": 180.0}

## Bounds of all meshes in this view's space (skinned meshes in their bind pose).
func _model_bounds() -> AABB:
	var inv: Transform3D = global_transform.affine_inverse()
	var box := AABB()
	var first := true
	for m in model.find_children("*", "MeshInstance3D", true, false):
		if m.mesh == null: continue
		var b: AABB = inv * m.global_transform * m.mesh.get_aabb()
		box = b if first else box.merge(b)
		first = false
	return box

## Statue scans stand on a display base; this share of their height is cut away.
const PEDESTAL_CUT := {"tripo_nyx_harvester": 0.12, "tripo_fantasy_female": 0.05, "tripo_wooden_forest": 0.03, "tripo_nine_tailed": 0.14}
static var _cut_meshes := {}
## Lowest kept point per family, as a share of the uncut height (the vertex arrays and so
## the mesh bounds still include the removed base).
static var _cut_floor := {}
## Cutting a million-vertex scan takes seconds, so the result is baked here once.
const CUT_DIR := "res://assets/models/cut"

## Drops every triangle that lies completely below the cut height (view space), and flat
## ones a little above it: the top face of a base sits where the feet stand.
func _cut_pedestal(family: String) -> void:
	var box: AABB = _model_bounds()
	var cut_y: float = box.position.y + box.size.y * float(PEDESTAL_CUT[family])
	var flat_y: float = box.position.y + box.size.y * float(PEDESTAL_CUT[family]) * 1.3
	var inv: Transform3D = global_transform.affine_inverse()
	var lowest := INF
	var k := 0
	for m in model.find_children("*", "MeshInstance3D", true, false):
		if m.mesh == null: continue
		var key := "%s/%d" % [family, k]
		var baked := "%s/%s_%d.res" % [CUT_DIR, family, k]
		k += 1
		if not _cut_meshes.has(key) and ResourceLoader.exists(baked):
			_cut_meshes[key] = load(baked)
		if not _cut_meshes.has(key):
			var xf: Transform3D = inv * m.global_transform
			var out := ArrayMesh.new()
			for s in range(m.mesh.get_surface_count()):
				var arrays: Array = m.mesh.surface_get_arrays(s)
				var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
				var idx: PackedInt32Array = arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX] != null else PackedInt32Array(range(verts.size()))
				var pos := PackedVector3Array()
				pos.resize(verts.size())
				for v in range(verts.size()):
					pos[v] = xf * verts[v]
				var kept := PackedInt32Array()
				for t in range(0, idx.size() - 2, 3):
					var a: Vector3 = pos[idx[t]]
					var b: Vector3 = pos[idx[t + 1]]
					var c: Vector3 = pos[idx[t + 2]]
					var top: float = maxf(a.y, maxf(b.y, c.y))
					if top < cut_y: continue
					if top < flat_y:
						var n: Vector3 = (b - a).cross(c - a)
						if n.length_squared() > 0.0 and absf(n.normalized().y) > 0.85: continue
					kept.append(idx[t]); kept.append(idx[t + 1]); kept.append(idx[t + 2])
					lowest = minf(lowest, minf(a.y, minf(b.y, c.y)))
				if kept.is_empty(): continue
				arrays[Mesh.ARRAY_INDEX] = kept
				out.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays, [], {}, m.mesh.surface_get_format(s) & Mesh.ARRAY_FLAG_USE_8_BONE_WEIGHTS)
				out.surface_set_material(out.get_surface_count() - 1, m.mesh.surface_get_material(s))
			if lowest < INF: out.set_meta("floor", (lowest - box.position.y) / box.size.y)
			DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CUT_DIR))
			ResourceSaver.save(out, baked, ResourceSaver.FLAG_COMPRESS)
			_cut_meshes[key] = out
		m.mesh = _cut_meshes[key]
		if m.mesh.has_meta("floor"): lowest = minf(lowest, box.position.y + box.size.y * float(m.mesh.get_meta("floor")))
	if lowest < INF: _cut_floor[family] = (lowest - box.position.y) / box.size.y

## Scales a scan to its target height (capped in width) and stands it on the floor.
func _fit_scanned_model(family: String, target_h: float) -> void:
	if not is_inside_tree(): return
	var turn := Basis(Vector3.UP, deg_to_rad(float(SCAN_YAW_OVERRIDE.get(family, SCAN_YAW))))
	for c in model.get_children():
		if c is Node3D: c.transform = Transform3D(turn, Vector3.ZERO) * c.transform
	if PEDESTAL_CUT.has(family): _cut_pedestal(family)
	var box: AABB = _model_bounds()
	if box.size.y <= 0.01: return
	var ratio: float = float(SCAN_HEIGHT.get(family, target_h)) / box.size.y
	var wide: float = maxf(box.size.x, box.size.z) * ratio
	if wide > SCAN_MAX_WIDTH: ratio *= SCAN_MAX_WIDTH / wide
	model.scale *= ratio
	base_model_scale = model.scale
	# Lift the children: model.position.y itself is animated every frame.
	var fitted: AABB = _model_bounds()
	var floor_y: float = fitted.position.y + fitted.size.y * float(_cut_floor.get(family, 0.0))
	var lift: float = -floor_y / maxf(0.001, model.scale.y)
	for c in model.get_children():
		if c is Node3D: c.position.y += lift

func _char_dir(v: Vector3) -> Vector3:
	return (rig_right * v.x + rig_up * v.y + rig_forward * v.z).normalized()

## Rotates one bone so that its direction bone points along the character-space direction.
func _aim_bone(key: String, child_key: String, dir: Vector3, blend: float) -> void:
	if not bone_map.has(key) or not rig_child.has(child_key): return
	var b: int = bone_map[key]
	var c: int = rig_child[child_key]
	if c == b: return
	var parent: int = skeleton.get_bone_parent(b)
	var parent_basis := Basis.IDENTITY
	if parent >= 0: parent_basis = skeleton.get_bone_global_pose(parent).basis.orthonormalized()
	var rest_basis: Basis = skeleton.get_bone_rest(b).basis.orthonormalized()
	var base_global: Basis = parent_basis * rest_basis
	var child_offset: Vector3 = skeleton.get_bone_rest(c).origin
	if skeleton.get_bone_parent(c) != b:
		# The direction bone sits further down the chain (spine -> head): use rest positions.
		var rest_b: Transform3D = skeleton.get_bone_global_rest(b)
		child_offset = rest_b.basis.orthonormalized().inverse() * (skeleton.get_bone_global_rest(c).origin - rest_b.origin)
	if child_offset.length() < 0.00001: return
	var current_dir: Vector3 = (base_global * child_offset).normalized()
	var target_dir: Vector3 = _char_dir(dir)
	var wanted_global: Basis = base_global
	if current_dir.dot(target_dir) < 0.99999:
		wanted_global = Basis(Quaternion(current_dir, target_dir)) * base_global
	var wanted_local: Quaternion = (parent_basis.inverse() * wanted_global).get_rotation_quaternion()
	var now: Quaternion = skeleton.get_bone_pose_rotation(b)
	skeleton.set_bone_pose_rotation(b, now.slerp(wanted_local, blend))

## Leg: thigh swing angle a (radians, + = forward) and knee bend k (radians).
static func _leg(side: float, a: float, k: float, spread: float = 0.12) -> Array:
	var thigh := Vector3(side * spread, -cos(a), sin(a))
	var shin := Vector3(side * spread * 0.5, -cos(a - k), sin(a - k))
	return [thigh, shin]

## Arm: upper arm and forearm directions, x mirrored by side (-1 left, +1 right).
static func _arm(side: float, upper: Vector3, fore: Vector3) -> Array:
	return [Vector3(upper.x * side, upper.y, upper.z), Vector3(fore.x * side, fore.y, fore.z)]

## Strike progress: 0 while winding up, rising to 1 exactly when the move becomes active.
func _strike(t: float) -> float:
	var w: float = maxf(0.05, anim_windup)
	return smoothstep(w * 0.55, w + 0.03, t)

## Target limb directions for a pose; t = seconds in the pose, p = running clock.
func _pose_targets(pose: String, t: float, p: float) -> Dictionary:
	var breath := sin(p * 2.6) * 0.04
	# Default: fighting guard – fists up in front of the chest, knees soft.
	var la := _arm(-1.0, Vector3(0.28, -0.85 + breath, 0.35), Vector3(0.15, 0.55, 0.8))
	var ra := _arm(1.0, Vector3(0.28, -0.85 + breath, 0.35), Vector3(0.1, 0.5, 0.85))
	var ll := _leg(-1.0, 0.18, 0.3, 0.16)
	var rl := _leg(1.0, -0.12, 0.22, 0.16)
	var spine := Vector3(0, 1, 0.1 + breath)
	match pose:
		"Move":
			var s := sin(p * 11.0)
			ll = _leg(-1.0, s * 0.62, 0.35 + maxf(0.0, -s) * 0.9)
			rl = _leg(1.0, -s * 0.62, 0.35 + maxf(0.0, s) * 0.9)
			la = _arm(-1.0, Vector3(0.18, -cos(s * 0.7), -sin(s * 0.7)), Vector3(0.1, 0.35, 0.95))
			ra = _arm(1.0, Vector3(0.18, -cos(-s * 0.7), -sin(-s * 0.7)), Vector3(0.1, 0.35, 0.95))
			spine = Vector3(0, 1, 0.28)
		"Jump":
			ll = _leg(-1.0, 1.05, 1.6)
			rl = _leg(1.0, 0.55, 1.1)
			la = _arm(-1.0, Vector3(0.75, 0.35, 0.15), Vector3(0.6, 0.75, 0.2))
			ra = _arm(1.0, Vector3(0.75, 0.35, 0.15), Vector3(0.6, 0.75, 0.2))
			spine = Vector3(0, 1, 0.15)
		"Fall":
			var flap := sin(p * 6.0) * 0.12
			ll = _leg(-1.0, 0.35, 0.5)
			rl = _leg(1.0, -0.15, 0.35)
			la = _arm(-1.0, Vector3(0.9, 0.2 + flap, 0.0), Vector3(0.8, 0.45, 0.1))
			ra = _arm(1.0, Vector3(0.9, 0.2 - flap, 0.0), Vector3(0.8, 0.45, 0.1))
			spine = Vector3(0, 1, -0.05)
		"Attack", "LightAttack", "Throw", "Grab":
			# Short wind-up, then a full straight punch with the right arm.
			var strike := clampf((t - 0.05) / 0.08, 0.0, 1.0)
			ra = _arm(1.0, Vector3(0.3, -0.3, -0.5).lerp(Vector3(-0.05, 0.12, 1.0), strike),
				Vector3(0.2, 0.6, 0.4).lerp(Vector3(-0.05, 0.12, 1.0), strike))
			la = _arm(-1.0, Vector3(0.3, -0.6, 0.55), Vector3(-0.2, 0.7, 0.6))
			ll = _leg(-1.0, 0.45, 0.35, 0.2)
			rl = _leg(1.0, -0.4, 0.2, 0.2)
			spine = Vector3(0, 1, 0.3 * strike)
		"SpecialAttack":
			# Charge with both hands back, then a two-handed push forward.
			var release := clampf((t - 0.12) / 0.1, 0.0, 1.0)
			var back_u := Vector3(0.5, -0.4, -0.6)
			var fwd_u := Vector3(0.15, 0.1, 1.0)
			la = _arm(-1.0, back_u.lerp(fwd_u, release), Vector3(0.3, 0.2, -0.4).lerp(Vector3(0.05, 0.15, 1.0), release))
			ra = _arm(1.0, back_u.lerp(fwd_u, release), Vector3(0.3, 0.2, -0.4).lerp(Vector3(0.05, 0.15, 1.0), release))
			ll = _leg(-1.0, 0.55, 0.5, 0.26)
			rl = _leg(1.0, -0.45, 0.3, 0.26)
			spine = Vector3(0, 1, -0.15).lerp(Vector3(0, 1, 0.35), release)
		"Block":
			la = _arm(-1.0, Vector3(0.35, -0.3, 0.85), Vector3(-0.75, 0.6, 0.3))
			ra = _arm(1.0, Vector3(0.35, -0.25, 0.85), Vector3(-0.7, 0.65, 0.3))
			ll = _leg(-1.0, 0.3, 0.6, 0.22)
			rl = _leg(1.0, -0.2, 0.5, 0.22)
			spine = Vector3(0, 1, 0.25)
		"HitReact", "Grabbed":
			var jolt := maxf(0.0, 1.0 - t * 4.0)
			la = _arm(-1.0, Vector3(0.6, -0.3, -0.7), Vector3(0.6, 0.1, -0.5))
			ra = _arm(1.0, Vector3(0.6, -0.4, -0.6), Vector3(0.6, 0.2, -0.5))
			ll = _leg(-1.0, 0.4, 0.5)
			rl = _leg(1.0, -0.1, 0.3)
			spine = Vector3(0, 1, -0.45 - jolt * 0.3)
		"Victory":
			var pump := absf(sin(p * 4.0)) * 0.15
			ra = _arm(1.0, Vector3(0.15, 1.0, 0.05), Vector3(0.05, 1.0, 0.1 + pump))
			la = _arm(-1.0, Vector3(0.5, -0.85, -0.1), Vector3(-0.6, 0.1, 0.35))
			ll = _leg(-1.0, 0.1, 0.05, 0.22)
			rl = _leg(1.0, -0.1, 0.05, 0.22)
			spine = Vector3(0, 1, -0.12)
		"Defeat":
			la = _arm(-1.0, Vector3(0.15, -1.0, 0.25), Vector3(0.1, -1.0, 0.35))
			ra = _arm(1.0, Vector3(0.15, -1.0, 0.25), Vector3(0.1, -1.0, 0.35))
			ll = _leg(-1.0, 1.3, 2.4, 0.2)
			rl = _leg(1.0, 0.2, 1.4, 0.2)
			spine = Vector3(0, 0.8, 0.7)
		"Crouch":
			ll = _leg(-1.0, 1.0, 1.9, 0.2)
			rl = _leg(1.0, 0.6, 1.5, 0.2)
			spine = Vector3(0, 1, 0.45)
		"Charge":
			var shake := sin(p * 70.0) * 0.04
			ra = _arm(1.0, Vector3(0.45, -0.2 + shake, -0.85), Vector3(0.3, 0.7, -0.3))
			la = _arm(-1.0, Vector3(0.3, -0.5, 0.7), Vector3(-0.1, 0.6, 0.7))
			ll = _leg(-1.0, 0.7, 1.1, 0.25)
			rl = _leg(1.0, -0.5, 0.6, 0.25)
			spine = Vector3(shake, 1, -0.25)
		"Dodge":
			ll = _leg(-1.0, 1.25, 2.1)
			rl = _leg(1.0, 1.1, 2.0)
			la = _arm(-1.0, Vector3(0.3, -0.2, 0.9), Vector3(-0.4, 0.6, 0.6))
			ra = _arm(1.0, Vector3(0.3, -0.2, 0.9), Vector3(-0.4, 0.6, 0.6))
			spine = Vector3(0, 0.8, 0.7)
		"Ledge":
			var swing := sin(p * 2.2) * 0.15
			la = _arm(-1.0, Vector3(0.25, 1.0, 0.25), Vector3(0.15, 1.0, 0.35))
			ra = _arm(1.0, Vector3(0.25, 1.0, 0.25), Vector3(0.15, 1.0, 0.35))
			ll = _leg(-1.0, 0.15 + swing, 0.25)
			rl = _leg(1.0, -0.05 - swing, 0.2)
			spine = Vector3(0, 1, 0.2)
		"Dazed", "ShieldBreak":
			var sway := sin(p * 3.0) * 0.3
			la = _arm(-1.0, Vector3(0.2, -1.0, 0.1), Vector3(0.15, -1.0, 0.2))
			ra = _arm(1.0, Vector3(0.2, -1.0, 0.1), Vector3(0.15, -1.0, 0.2))
			ll = _leg(-1.0, 0.25, 0.5, 0.22)
			rl = _leg(1.0, 0.1, 0.45, 0.22)
			spine = Vector3(sway, 0.9, 0.35)
		"Kick":
			var k := _strike(t)
			ll = _leg(-1.0, 0.1, 0.25, 0.14)
			rl = _leg(1.0, lerpf(1.1, 1.45, k), lerpf(1.7, 0.05, k), 0.1)
			la = _arm(-1.0, Vector3(0.35, -0.5, 0.5), Vector3(-0.1, 0.7, 0.6))
			ra = _arm(1.0, Vector3(0.5, -0.6, -0.4), Vector3(0.3, 0.3, 0.5))
			spine = Vector3(0, 1, -0.25 * k)
		"BackKick":
			var k := _strike(t)
			ll = _leg(-1.0, 0.25, 0.4, 0.14)
			rl = _leg(1.0, lerpf(0.6, -1.35, k), lerpf(1.5, -0.1, k), 0.1)
			la = _arm(-1.0, Vector3(0.3, -0.3, 0.9), Vector3(0.1, 0.4, 0.9))
			ra = _arm(1.0, Vector3(0.3, -0.3, 0.9), Vector3(0.1, 0.4, 0.9))
			spine = Vector3(0, 1, 0.6 * k)
		"Uppercut":
			var k := _strike(t)
			ra = _arm(1.0, Vector3(0.35, -0.8, -0.2).lerp(Vector3(0.05, 1.0, 0.35), k), Vector3(0.2, 0.3, 0.6).lerp(Vector3(0.0, 1.0, 0.1), k))
			la = _arm(-1.0, Vector3(0.3, -0.6, 0.5), Vector3(-0.2, 0.7, 0.6))
			ll = _leg(-1.0, lerpf(0.6, 0.15, k), lerpf(1.1, 0.1, k), 0.2)
			rl = _leg(1.0, lerpf(-0.3, -0.1, k), lerpf(0.8, 0.1, k), 0.2)
			spine = Vector3(0, 1, lerpf(0.4, -0.2, k))
		"Sweep":
			var k := _strike(t)
			ll = _leg(-1.0, 1.3, 2.3, 0.25)
			rl = _leg(1.0, lerpf(0.4, 1.35, k), lerpf(1.0, 0.0, k), lerpf(0.6, 0.15, k))
			la = _arm(-1.0, Vector3(0.6, -0.8, 0.0), Vector3(0.5, -0.8, 0.2))
			ra = _arm(1.0, Vector3(0.5, -0.5, 0.6), Vector3(0.2, 0.3, 0.8))
			spine = Vector3(0, 1, 0.55)
		"HeavyPunch":
			var k := _strike(t)
			ra = _arm(1.0, Vector3(0.45, -0.05, -0.9).lerp(Vector3(-0.05, 0.1, 1.0), k), Vector3(0.3, 0.6, -0.3).lerp(Vector3(-0.05, 0.1, 1.0), k))
			la = _arm(-1.0, Vector3(0.2, -0.3, 0.8).lerp(Vector3(0.5, -0.4, -0.6), k), Vector3(0.0, 0.6, 0.7))
			ll = _leg(-1.0, lerpf(0.2, 0.75, k), lerpf(0.4, 0.8, k), 0.22)
			rl = _leg(1.0, lerpf(-0.2, -0.65, k), 0.15, 0.22)
			spine = Vector3(0, 1, lerpf(-0.2, 0.5, k))
		"Spin", "SlashSpin":
			la = _arm(-1.0, Vector3(0.95, 0.1, 0.1), Vector3(0.9, 0.2, 0.2))
			ra = _arm(1.0, Vector3(0.95, 0.1, 0.1), Vector3(0.9, 0.2, 0.3))
			ll = _leg(-1.0, 0.5, 0.9, 0.3)
			rl = _leg(1.0, -0.3, 0.6, 0.3)
			spine = Vector3(0, 1, 0.15)
		"Stomp", "SlashDown":
			var k := _strike(t)
			ll = _leg(-1.0, lerpf(1.2, 0.6, k), lerpf(1.8, 1.2, k))
			rl = _leg(1.0, lerpf(1.1, 0.0, k), lerpf(1.7, 0.0, k))
			if pose == "SlashDown":
				ra = _arm(1.0, Vector3(0.1, 1.0, 0.1).lerp(Vector3(0.05, -0.9, 0.4), k), Vector3(0.0, 1.0, 0.2).lerp(Vector3(0.0, -0.8, 0.6), k))
			else:
				ra = _arm(1.0, Vector3(0.7, 0.6, 0.0), Vector3(0.5, 0.8, 0.1))
			la = _arm(-1.0, Vector3(0.7, 0.6, 0.0), Vector3(0.5, 0.8, 0.1))
			spine = Vector3(0, 1, 0.3)
		"Rise":
			la = _arm(-1.0, Vector3(0.2, 1.0, 0.2), Vector3(0.1, 1.0, 0.3))
			ra = _arm(1.0, Vector3(0.2, 1.0, 0.2), Vector3(0.1, 1.0, 0.3))
			ll = _leg(-1.0, 1.1, 1.9)
			rl = _leg(1.0, 0.9, 1.7)
			spine = Vector3(0, 1, 0.1)
		"Slam":
			var k := _strike(t)
			var up := Vector3(0.25, 1.0, -0.2)
			var down := Vector3(0.15, -0.55, 0.85)
			la = _arm(-1.0, up.lerp(down, k), up.lerp(down, k))
			ra = _arm(1.0, up.lerp(down, k), up.lerp(down, k))
			ll = _leg(-1.0, lerpf(0.2, 0.8, k), lerpf(0.3, 1.4, k), 0.28)
			rl = _leg(1.0, lerpf(-0.1, 0.3, k), lerpf(0.2, 1.0, k), 0.28)
			spine = Vector3(0, 1, lerpf(-0.3, 0.75, k))
		"Cast":
			var k := _strike(t)
			ra = _arm(1.0, Vector3(0.5, -0.2, -0.6).lerp(Vector3(0.0, 0.15, 1.0), k), Vector3(0.3, 0.7, 0.0).lerp(Vector3(0.0, 0.2, 1.0), k))
			la = _arm(-1.0, Vector3(0.5, -0.5, -0.4), Vector3(0.3, 0.2, 0.5))
			ll = _leg(-1.0, 0.45, 0.4, 0.2)
			rl = _leg(1.0, -0.35, 0.2, 0.2)
			spine = Vector3(0, 1, lerpf(-0.15, 0.3, k))
		"Summon":
			var k := _strike(t)
			var up := Vector3(0.4, 1.0, 0.05)
			la = _arm(-1.0, up, up.lerp(Vector3(0.1, 0.5, 0.9), k))
			ra = _arm(1.0, up, up.lerp(Vector3(0.1, 0.5, 0.9), k))
			spine = Vector3(0, 1, -0.2)
		"Beam":
			var k := _strike(t)
			var charge_u := Vector3(0.45, -0.6, -0.35)
			var fire_u := Vector3(0.05, 0.15, 1.0)
			la = _arm(-1.0, charge_u.lerp(fire_u, k), Vector3(-0.4, 0.3, 0.5).lerp(fire_u, k))
			ra = _arm(1.0, charge_u.lerp(fire_u, k), Vector3(-0.4, 0.3, 0.5).lerp(fire_u, k))
			ll = _leg(-1.0, 0.55, 0.6, 0.3)
			rl = _leg(1.0, -0.5, 0.35, 0.3)
			spine = Vector3(0, 1, lerpf(-0.1, 0.35, k))
		"Dash":
			la = _arm(-1.0, Vector3(0.3, -0.3, -1.0), Vector3(0.2, -0.2, -1.0))
			ra = _arm(1.0, Vector3(0.1, 0.1, 1.0), Vector3(0.0, 0.1, 1.0))
			ll = _leg(-1.0, 0.9, 1.0)
			rl = _leg(1.0, -0.8, 0.6)
			spine = Vector3(0, 1, 0.85)
		"Barrage":
			var alt := sin(t * 45.0)
			ra = _arm(1.0, Vector3(0.1, 0.1, 1.0).lerp(Vector3(0.3, -0.4, 0.4), maxf(0.0, alt)), Vector3(0.0, 0.15, 1.0).lerp(Vector3(-0.2, 0.7, 0.6), maxf(0.0, alt)))
			la = _arm(-1.0, Vector3(0.1, 0.1, 1.0).lerp(Vector3(0.3, -0.4, 0.4), maxf(0.0, -alt)), Vector3(0.0, 0.15, 1.0).lerp(Vector3(-0.2, 0.7, 0.6), maxf(0.0, -alt)))
			ll = _leg(-1.0, 0.5, 0.5, 0.22)
			rl = _leg(1.0, -0.4, 0.3, 0.22)
			spine = Vector3(0, 1, 0.35)
		"Counter":
			la = _arm(-1.0, Vector3(-0.1, 0.3, 0.9), Vector3(0.7, 0.5, 0.3))
			ra = _arm(1.0, Vector3(0.4, -0.5, 0.3), Vector3(0.1, 0.5, 0.8))
			ll = _leg(-1.0, 0.6, 1.0, 0.3)
			rl = _leg(1.0, -0.4, 0.7, 0.3)
			spine = Vector3(0, 1, 0.2)
		"Roar":
			var shake := sin(p * 50.0) * 0.05
			la = _arm(-1.0, Vector3(0.85, -0.3 + shake, -0.2), Vector3(0.8, 0.3, 0.1))
			ra = _arm(1.0, Vector3(0.85, -0.3 - shake, -0.2), Vector3(0.8, 0.3, 0.1))
			ll = _leg(-1.0, 0.25, 0.4, 0.3)
			rl = _leg(1.0, -0.2, 0.35, 0.3)
			spine = Vector3(shake, 1, -0.35)
		"Slash", "SlashBack":
			var k := _strike(t)
			var from_u := Vector3(0.85, 0.55, -0.35)
			var to_u := Vector3(-0.45, 0.05, 0.9) if pose == "Slash" else Vector3(0.5, 0.0, -1.0)
			ra = _arm(1.0, from_u.lerp(to_u, k), Vector3(0.6, 0.8, -0.1).lerp(to_u, k))
			la = _arm(-1.0, Vector3(0.4, -0.6, 0.4), Vector3(0.0, 0.5, 0.7))
			ll = _leg(-1.0, lerpf(0.2, 0.6, k), lerpf(0.3, 0.6, k), 0.24)
			rl = _leg(1.0, lerpf(-0.1, -0.5, k), 0.2, 0.24)
			spine = Vector3(0, 1, lerpf(-0.1, 0.35, k))
		"Thrust":
			var k := _strike(t)
			ra = _arm(1.0, Vector3(0.35, -0.2, -0.8).lerp(Vector3(0.0, 0.08, 1.0), k), Vector3(0.1, 0.5, -0.3).lerp(Vector3(0.0, 0.08, 1.0), k))
			la = _arm(-1.0, Vector3(0.6, 0.2, -0.6), Vector3(0.5, 0.6, -0.2))
			ll = _leg(-1.0, lerpf(0.2, 0.9, k), lerpf(0.4, 1.0, k), 0.2)
			rl = _leg(1.0, lerpf(-0.2, -0.7, k), 0.1, 0.2)
			spine = Vector3(0, 1, lerpf(-0.1, 0.55, k))
		"SlashUp":
			var k := _strike(t)
			ra = _arm(1.0, Vector3(0.35, -0.9, 0.35).lerp(Vector3(0.05, 1.0, 0.25), k), Vector3(0.2, -0.6, 0.8).lerp(Vector3(0.0, 1.0, 0.3), k))
			la = _arm(-1.0, Vector3(0.4, -0.5, 0.4), Vector3(0.0, 0.5, 0.7))
			ll = _leg(-1.0, lerpf(0.6, 0.1, k), lerpf(1.1, 0.1, k), 0.2)
			rl = _leg(1.0, lerpf(-0.2, -0.1, k), lerpf(0.7, 0.1, k), 0.2)
			spine = Vector3(0, 1, lerpf(0.4, -0.25, k))
		"SlashLow":
			var k := _strike(t)
			ra = _arm(1.0, Vector3(0.8, -0.3, -0.4).lerp(Vector3(0.0, -0.6, 0.85), k), Vector3(0.6, -0.2, 0.3).lerp(Vector3(0.0, -0.4, 0.9), k))
			la = _arm(-1.0, Vector3(0.5, -0.6, 0.2), Vector3(0.1, 0.3, 0.7))
			ll = _leg(-1.0, 1.1, 1.9, 0.26)
			rl = _leg(1.0, -0.3, 0.9, 0.26)
			spine = Vector3(0, 1, 0.6)
		"HeavySlash":
			var k := _strike(t)
			var up := Vector3(0.15, 1.0, -0.35)
			var down := Vector3(0.05, -0.45, 1.0)
			ra = _arm(1.0, up.lerp(down, k), up.lerp(down, k))
			la = _arm(-1.0, up.lerp(down, k) * Vector3(-1, 1, 1), up.lerp(down, k) * Vector3(-1, 1, 1))
			ll = _leg(-1.0, lerpf(0.2, 0.8, k), lerpf(0.3, 0.9, k), 0.24)
			rl = _leg(1.0, lerpf(-0.1, -0.5, k), 0.2, 0.24)
			spine = Vector3(0, 1, lerpf(-0.35, 0.65, k))
		"Tumble":
			la = _arm(-1.0, Vector3(0.8, 0.4, -0.2), Vector3(0.6, 0.6, 0.0))
			ra = _arm(1.0, Vector3(0.8, 0.4, -0.2), Vector3(0.6, 0.6, 0.0))
			ll = _leg(-1.0, 0.9, 1.4)
			rl = _leg(1.0, 0.5, 0.9)
			spine = Vector3(0, 1, 0.3)
		"Carrying":
			la = _arm(-1.0, Vector3(0.3, 0.95, 0.2), Vector3(0.1, 0.9, 0.3))
			ra = _arm(1.0, Vector3(0.3, 0.95, 0.2), Vector3(0.1, 0.9, 0.3))
			spine = Vector3(0, 1, -0.08)
	return {
		"spine": spine,
		"left_arm": la[0], "left_forearm": la[1], "right_arm": ra[0], "right_forearm": ra[1],
		"left_leg": ll[0], "left_shin": ll[1], "right_leg": rl[0], "right_shin": rl[1],
	}

func update_procedural_skeleton(pose: String, delta: float, facing: float, is_frozen: bool) -> void:
	if skeleton == null or is_frozen: return
	if animation != null and animation.is_playing() and clip_map.has(pose): return
	# Humanoid poses only: on quadruped rigs (no arm bones) they would stand the spine upright.
	if not (bone_map.has("left_arm") and bone_map.has("right_arm")): return
	if not rig_ready: _prepare_rig()
	if pose != proc_pose:
		proc_pose = pose
		proc_pose_age = 0.0
	proc_pose_age += delta
	var fast: bool = not (pose in ["Idle", "Move", "Fall", "Victory", "Defeat", "Ledge", "Dazed", "Carrying"])
	var blend: float = minf(1.0, delta * (26.0 if fast else 12.0))
	var targets: Dictionary = _pose_targets(pose, proc_pose_age, pulse_time)
	for link in LIMB_CHAIN:
		if targets.has(link[0]):
			_aim_bone(link[0], link[1], targets[link[0]], blend)

func _process(delta: float) -> void:
	pulse_time += delta
	var pulse: float = sin(pulse_time * 3.6) * 0.22 + 1.0
	for i in range(glow_materials.size()):
		var base_em: float = base_emissions[i] if i < base_emissions.size() else 2.0
		glow_materials[i].emission_energy_multiplier = base_em * pulse

func update_state(state: Dictionary, delta: float) -> void:
	if profile.has("boss") and not has_meta("boss_body"):
		position.x = state.x
		position.y = state.get("y", 0.0)
		var cam := get_viewport().get_camera_3d() if is_inside_tree() else null
		model.apply_state(state, cam.global_position if cam else Vector3(0, 1.5, 8))
		visible = state.get("state", "") != "Defeated" or visible
		return
	position.x = state.x
	position.y = state.get("y", 0.0)
	var target_rot: float = state.facing * 0.65
	model.rotation.y = lerp_angle(model.rotation.y, target_rot, minf(1.0, delta * 14))

	var is_titan: bool = state.get("titan_timer", 0.0) > 0.0
	var target_scale: Vector3 = base_model_scale * (2.0 if is_titan else 1.0)
	if scale_base == Vector3.ZERO: scale_base = model.scale
	scale_base = scale_base.lerp(target_scale, minf(1.0, delta * 9.0))
	# Squash on landing, stretch on take-off: short, springy, readable.
	var grounded: bool = state.get("is_grounded", true)
	if grounded and not was_grounded: squash = 0.75
	elif not grounded and was_grounded and float(state.get("vy", 0.0)) > 2.0: squash = -0.6
	was_grounded = grounded
	squash = move_toward(squash, 0.0, delta * 5.0)
	var sq: float = squash * 0.16
	model.scale = scale_base * Vector3(1.0 + sq * 0.5, 1.0 - sq, 1.0 + sq * 0.5)

	var is_frozen: bool = state.get("freeze_timer", 0.0) > 0.0
	if freeze_block:
		freeze_block.visible = is_frozen
		if is_titan:
			freeze_block.scale = Vector3.ONE * 2.0
			freeze_block.position.y = 2.1
		else:
			freeze_block.scale = Vector3.ONE
			freeze_block.position.y = 1.05

	var is_invuln: bool = state.get("invulnerable", 0.0) > 0.0
	if is_invuln:
		aura_particles.color = Color(1.6, 1.2, 0.2, 1.0)
		aura_particles.amount = 45
		model.visible = (int(pulse_time * 30.0) % 2 == 0)
	else:
		aura_particles.color = skin_glow_color
		aura_particles.amount = 26
		model.visible = true

	var pose: String = state.pose

	if custom_attack_node:
		var is_atk: bool = (pose in ["Attack", "LightAttack"])
		custom_attack_node.visible = is_atk
		if is_atk:
			custom_attack_node.position.x = state.facing * 0.85
			custom_attack_node.position.y = 1.15
			custom_attack_node.scale = Vector3.ONE * (1.8 if is_titan else 1.25)
			custom_attack_node.rotation.z += delta * 24.0 * state.facing

	if custom_special_node:
		var is_spec: bool = (pose == "SpecialAttack")
		custom_special_node.visible = is_spec
		if is_spec:
			custom_special_node.scale = Vector3.ONE * (2.2 if is_titan else 1.55)
			custom_special_node.position.x = state.facing * 1.25
			custom_special_node.position.y = 1.15
			custom_special_node.rotation.z += delta * 12.0 * state.facing

	if pose != current_pose and animation and clip_map.has(pose):
		animation.play(clip_map[pose], 0.09)
		current_pose = pose
	elif not (animation and clip_map.has(pose)):
		# No clip for this pose (jump, fall, block …): hand the skeleton to the procedural poses.
		if animation and animation.is_playing() and skeleton != null: animation.stop(true)
		current_pose = pose
		if pose == "Idle":
			model.position.y = sin(pulse_time * 2.8) * 0.035
			model.rotation.z = sin(pulse_time * 1.4) * 0.015
		elif pose == "Move":
			model.position.y = abs(sin(pulse_time * 8.0)) * 0.05
			model.rotation.z = sin(pulse_time * 8.0) * 0.05 * state.facing
		elif pose in ["Attack", "LightAttack"]:
			model.position.x = state.facing * 0.20
			model.rotation.y = lerp_angle(model.rotation.y, target_rot + state.facing * 0.35, minf(1.0, delta * 15.0))
		elif pose == "SpecialAttack":
			model.position.y = 0.10 + sin(pulse_time * 10.0) * 0.03
			model.rotation.y = lerp_angle(model.rotation.y, target_rot - state.facing * 0.25, minf(1.0, delta * 15.0))
		elif pose == "HitReact":
			model.position.x = -state.facing * 0.15
			model.rotation.z = -state.facing * 0.10
		else:
			model.position = Vector3.ZERO

	if skeleton != null:
		update_procedural_skeleton(pose, delta, state.facing, is_frozen)
	# Lean into the running direction, lean back when launched.
	var speed_x: float = float(state.get("walk_v", 0.0)) + float(state.get("vx", 0.0)) * 0.4
	lean = lerpf(lean, clampf(-speed_x * 0.025, -0.18, 0.18), minf(1.0, delta * 8.0))
	model.rotation.z = lean
	anim_windup = float(state.get("anim_windup", 0.1))
	# Whole-body motion: spins, flips, dropped hips for low moves, tumbling when launched.
	if pose in ["Spin", "SlashSpin"]:
		spin_angle += delta * 22.0
		model.rotation.y = target_rot + spin_angle
	else:
		spin_angle = 0.0
	if pose == "Rise":
		flip_angle += delta * 13.0
	else:
		flip_angle = lerp_angle(flip_angle, 0.0, minf(1.0, delta * 12.0))
	model.rotation.x = flip_angle
	var launch_speed: float = Vector2(float(state.get("vx", 0.0)), float(state.get("vy", 0.0))).length()
	if state.get("state", "") == "HitStun" and launch_speed > 9.0 and not state.get("is_grounded", true):
		tumble_angle += delta * launch_speed * 1.4 * -signf(float(state.get("vx", 1.0)))
		model.rotation.z = tumble_angle
	else:
		tumble_angle = 0.0
	var hip_drop: float = {"Sweep": -0.4, "SlashLow": -0.32, "Crouch": -0.28, "Counter": -0.18, "Slam": -0.22, "Dodge": -0.3, "Beam": -0.1}.get(pose, 0.0)
	model.position.y += hip_drop * (1.0 if pose == current_pose else 0.0)

	if hero_gear != null: hero_gear.apply_state(state)
	if shield:
		var is_blocking: bool = state.get("blocking", false)
		shield.visible = is_blocking
		if is_blocking:
			shield.position = Vector3(state.facing * 0.38, 1.15, 0.15)
			shield.rotation.y = state.facing * 0.65

func flash() -> void:
	if profile.has("boss") and not has_meta("boss_body"):
		model.flash()
		return
	if hero_gear != null: hero_gear.flash()
	for i in range(glow_materials.size()):
		var mat: StandardMaterial3D = glow_materials[i]
		mat.emission_energy_multiplier = 4.0
		var base_em: float = base_emissions[i] if i < base_emissions.size() else 2.0
		create_tween().tween_property(mat, "emission_energy_multiplier", base_em, 0.2)

func shield_flash() -> void:
	if shield and shield.material_override is StandardMaterial3D:
		var smat: StandardMaterial3D = shield.material_override
		smat.emission_energy_multiplier = 3.2
		create_tween().tween_property(smat, "emission_energy_multiplier", 1.15, 0.22)

func setup_equipment(p: Dictionary) -> void:
	if not p.has("equipment") or not (p.equipment is Array):
		return
	var skel: Skeleton3D = null
	for child in model.find_children("*", "Skeleton3D", true, false):
		skel = child
		break

	for eq in p.equipment:
		var slot: String = eq.get("slot", "")
		var mtype: String = eq.get("mesh_type", "")
		var col: Color = eq.get("color", Color.WHITE)
		var em_col: Color = eq.get("emission", Color.BLACK)
		var glow_val: float = eq.get("glow", 0.0)

		var gear_node := Node3D.new()
		gear_node.name = "Gear_" + eq.get("id", "item")

		var g_mat = StandardMaterial3D.new()
		g_mat.albedo_color = col
		g_mat.metallic = 0.65 if mtype in ["katana", "rapier", "hammer", "blaster", "shield", "helm", "pauldrons"] else 0.15
		g_mat.roughness = 0.28
		if glow_val > 0.0:
			g_mat.emission_enabled = true
			g_mat.emission = em_col
			g_mat.emission_energy_multiplier = glow_val
			glow_materials.append(g_mat)
			base_emissions.append(glow_val)

		match mtype:
			"katana":
				var blade = MeshInstance3D.new()
				var b_box = BoxMesh.new()
				b_box.size = Vector3(0.04, 0.95, 0.012)
				blade.mesh = b_box
				blade.material_override = g_mat
				blade.position = Vector3(0, 0.45, 0)
				gear_node.add_child(blade)
				var edge = MeshInstance3D.new()
				var e_box = BoxMesh.new()
				e_box.size = Vector3(0.015, 0.92, 0.006)
				edge.mesh = e_box
				var e_mat = StandardMaterial3D.new()
				e_mat.albedo_color = em_col
				e_mat.emission_enabled = true
				e_mat.emission = em_col
				e_mat.emission_energy_multiplier = glow_val * 1.5
				edge.material_override = e_mat
				edge.position = Vector3(0.022, 0.45, 0)
				gear_node.add_child(edge)
				var guard = MeshInstance3D.new()
				var g_cyl = CylinderMesh.new()
				g_cyl.top_radius = 0.07; g_cyl.bottom_radius = 0.07; g_cyl.height = 0.015
				guard.mesh = g_cyl
				guard.material_override = g_mat
				gear_node.add_child(guard)
				var grip = MeshInstance3D.new()
				var grip_cyl = CylinderMesh.new()
				grip_cyl.top_radius = 0.025; grip_cyl.bottom_radius = 0.025; grip_cyl.height = 0.24
				grip.mesh = grip_cyl
				grip.position = Vector3(0, -0.12, 0)
				gear_node.add_child(grip)

			"rapier":
				var rblade = MeshInstance3D.new()
				var r_cyl = CylinderMesh.new()
				r_cyl.top_radius = 0.005; r_cyl.bottom_radius = 0.022; r_cyl.height = 1.05
				rblade.mesh = r_cyl
				rblade.material_override = g_mat
				rblade.position = Vector3(0, 0.52, 0)
				gear_node.add_child(rblade)
				var rguard = MeshInstance3D.new()
				var r_sph = SphereMesh.new()
				r_sph.radius = 0.08; r_sph.height = 0.09
				rguard.mesh = r_sph
				rguard.material_override = g_mat
				gear_node.add_child(rguard)

			"hammer":
				var hhead = MeshInstance3D.new()
				var h_box = BoxMesh.new()
				h_box.size = Vector3(0.24, 0.28, 0.42)
				hhead.mesh = h_box
				hhead.material_override = g_mat
				hhead.position = Vector3(0, 0.72, 0)
				gear_node.add_child(hhead)
				var hshaft = MeshInstance3D.new()
				var hs_cyl = CylinderMesh.new()
				hs_cyl.top_radius = 0.035; hs_cyl.bottom_radius = 0.035; hs_cyl.height = 0.95
				hshaft.mesh = hs_cyl
				hshaft.material_override = g_mat
				hshaft.position = Vector3(0, 0.35, 0)
				gear_node.add_child(hshaft)

			"blaster":
				var bbarrel = MeshInstance3D.new()
				var bb_cyl = CylinderMesh.new()
				bb_cyl.top_radius = 0.065; bb_cyl.bottom_radius = 0.085; bb_cyl.height = 0.55
				bbarrel.mesh = bb_cyl
				bbarrel.rotation.x = PI / 2.0
				bbarrel.material_override = g_mat
				gear_node.add_child(bbarrel)
				var bmuzzle = MeshInstance3D.new()
				var bm_sph = SphereMesh.new()
				bm_sph.radius = 0.055; bm_sph.height = 0.06
				bmuzzle.mesh = bm_sph
				var bm_mat = StandardMaterial3D.new()
				bm_mat.albedo_color = em_col; bm_mat.emission_enabled = true; bm_mat.emission = em_col; bm_mat.emission_energy_multiplier = glow_val * 2.0
				bmuzzle.material_override = bm_mat
				bmuzzle.position = Vector3(0, 0, 0.30)
				gear_node.add_child(bmuzzle)

			"shield":
				var splate = MeshInstance3D.new()
				var sp_box = BoxMesh.new()
				sp_box.size = Vector3(0.55, 0.75, 0.04)
				splate.mesh = sp_box
				splate.material_override = g_mat
				gear_node.add_child(splate)
				var sboss = MeshInstance3D.new()
				var sb_sph = SphereMesh.new()
				sb_sph.radius = 0.12; sb_sph.height = 0.10
				sboss.mesh = sb_sph
				var sb_mat = StandardMaterial3D.new()
				sb_mat.albedo_color = em_col; sb_mat.emission_enabled = true; sb_mat.emission = em_col; sb_mat.emission_energy_multiplier = glow_val * 1.5
				sboss.material_override = sb_mat
				sboss.position = Vector3(0, 0, 0.03)
				gear_node.add_child(sboss)

			"visor":
				var visor_m = MeshInstance3D.new()
				var v_box = BoxMesh.new()
				v_box.size = Vector3(0.24, 0.06, 0.12)
				visor_m.mesh = v_box
				var v_mat = StandardMaterial3D.new()
				v_mat.albedo_color = em_col; v_mat.emission_enabled = true; v_mat.emission = em_col; v_mat.emission_energy_multiplier = glow_val
				visor_m.material_override = v_mat
				visor_m.position = Vector3(0, 0.04, 0.12)
				gear_node.add_child(visor_m)

			"halo":
				var halo_m = MeshInstance3D.new()
				var h_tor = TorusMesh.new()
				h_tor.inner_radius = 0.18; h_tor.outer_radius = 0.24
				halo_m.mesh = h_tor
				var h_mat = StandardMaterial3D.new()
				h_mat.albedo_color = em_col; h_mat.emission_enabled = true; h_mat.emission = em_col; h_mat.emission_energy_multiplier = glow_val
				halo_m.material_override = h_mat
				halo_m.position = Vector3(0, 0.28, 0)
				gear_node.add_child(halo_m)

			"wings", "dragon_wings", "angel_wings":
				for sx in [-1.0, 1.0]:
					var wing_m = MeshInstance3D.new()
					var w_box = BoxMesh.new()
					w_box.size = Vector3(0.85, 0.55, 0.02)
					wing_m.mesh = w_box
					wing_m.position = Vector3(sx * 0.55, 0.15, -0.22)
					wing_m.rotation = Vector3(0.1, sx * 0.45, sx * 0.35)
					wing_m.material_override = g_mat
					gear_node.add_child(wing_m)

			"jetpack":
				for sx in [-1.0, 1.0]:
					var tube = MeshInstance3D.new()
					var t_cyl = CylinderMesh.new()
					t_cyl.top_radius = 0.07; t_cyl.bottom_radius = 0.07; t_cyl.height = 0.42
					tube.mesh = t_cyl
					tube.material_override = g_mat
					tube.position = Vector3(sx * 0.18, 0.05, -0.16)
					gear_node.add_child(tube)
					var tflame = MeshInstance3D.new()
					var tf_cone = CylinderMesh.new()
					tf_cone.top_radius = 0.0; tf_cone.bottom_radius = 0.06; tf_cone.height = 0.22
					tflame.mesh = tf_cone
					var tf_mat = StandardMaterial3D.new()
					tf_mat.albedo_color = em_col; tf_mat.emission_enabled = true; tf_mat.emission = em_col; tf_mat.emission_energy_multiplier = glow_val * 1.5
					tflame.material_override = tf_mat
					tflame.position = Vector3(sx * 0.18, -0.25, -0.16)
					tflame.rotation.x = PI
					gear_node.add_child(tflame)

			_:
				var generic_m = MeshInstance3D.new()
				var g_box = BoxMesh.new()
				g_box.size = Vector3(0.15, 0.15, 0.15)
				generic_m.mesh = g_box
				generic_m.material_override = g_mat
				gear_node.add_child(generic_m)

		var attached := false
		if skel:
			var target_bone_name := ""
			match slot:
				"weapon_r":
					for bn in ["hand_r", "Hand_R", "RightHand", "hand.R"]:
						if skel.find_bone(bn) != -1: target_bone_name = bn; break
				"weapon_l":
					for bn in ["hand_l", "Hand_L", "LeftHand", "hand.L"]:
						if skel.find_bone(bn) != -1: target_bone_name = bn; break
				"head":
					for bn in ["head", "Head"]:
						if skel.find_bone(bn) != -1: target_bone_name = bn; break
				"back", "shoulders":
					for bn in ["spine_02", "Spine2", "Chest", "spine_01", "Spine1"]:
						if skel.find_bone(bn) != -1: target_bone_name = bn; break

			if not target_bone_name.is_empty():
				var att = BoneAttachment3D.new()
				att.bone_name = target_bone_name
				att.add_child(gear_node)
				skel.add_child(att)
				equipped_items_nodes.append(gear_node)
				attached = true

		if not attached:
			match slot:
				"weapon_r": gear_node.position = Vector3(-0.35, 0.95, 0.15)
				"weapon_l": gear_node.position = Vector3(0.35, 0.95, 0.15)
				"head": gear_node.position = Vector3(0, 1.75, 0)
				"back": gear_node.position = Vector3(0, 1.25, -0.20)
				"shoulders": gear_node.position = Vector3(0, 1.35, 0)
			add_child(gear_node)
			equipped_items_nodes.append(gear_node)

# ── Finisher helpers ──────────────────────────────────────────────────────────────
## Bones collapsed by a finisher and body colors before charring, restored for rematches.
var gore_hidden: Array = []
var gore_colors: Dictionary = {}

func has_bone(key: String) -> bool:
	return skeleton != null and bone_map.has(key)

## World position of a mapped bone (head, left_arm, ...); falls back to the body centre.
func bone_world(key: String) -> Vector3:
	if has_bone(key):
		return (skeleton.global_transform * skeleton.get_bone_global_pose(bone_map[key])).origin
	return global_position + Vector3(0, 1.1, 0)

## Collapses a bone and everything attached to it to zero size.
func gore_hide_bone(key: String) -> bool:
	if not has_bone(key): return false
	var idx: int = bone_map[key]
	skeleton.set_bone_pose_scale(idx, Vector3.ONE * 0.001)
	gore_hidden.append(idx)
	return true

## Darkens the body: 0 = normal, 1 = charred black.
func char_body(amount: float) -> void:
	for m in model.find_children("*", "MeshInstance3D", true, false):
		if m.mesh == null: continue
		for sfc in range(m.mesh.get_surface_count()):
			var mat = m.get_surface_override_material(sfc)
			if not (mat is BaseMaterial3D): continue
			var key := "%s/%d" % [m.get_instance_id(), sfc]
			if not gore_colors.has(key): gore_colors[key] = [mat, mat.albedo_color]
			mat.albedo_color = (gore_colors[key][1] as Color).lerp(Color(0.05, 0.03, 0.02), amount)

func reset_gore() -> void:
	if skeleton != null:
		for idx in gore_hidden: skeleton.set_bone_pose_scale(idx, Vector3.ONE)
	gore_hidden.clear()
	for key in gore_colors:
		var entry: Array = gore_colors[key]
		if is_instance_valid(entry[0]): entry[0].albedo_color = entry[1]
	gore_colors.clear()
	visible = true

## Where a held weapon sits: at the right hand, blade continuing the forearm direction.
## Rigs without hands get a fixed spot in front of the body.
func weapon_grip(facing: float) -> Transform3D:
	if skeleton != null and rig_ready and bone_map.has("right_forearm") and rig_child.has("right_hand"):
		var hand: Vector3 = (skeleton.global_transform * skeleton.get_bone_global_pose(rig_child["right_hand"])).origin
		var fore: Vector3 = bone_world("right_forearm")
		var dir: Vector3 = (hand - fore).normalized()
		if dir.length() > 0.1:
			var side: Vector3 = dir.cross(Vector3.BACK)
			if side.length() < 0.05: side = dir.cross(Vector3.UP)
			side = side.normalized()
			return Transform3D(Basis(side, dir, side.cross(dir)).orthonormalized(), hand + dir * 0.05)
	var pos: Vector3 = global_position + Vector3(facing * 0.45, 1.0, 0.35)
	return Transform3D(Basis(Vector3.BACK, deg_to_rad(-60.0 * facing)), pos)
