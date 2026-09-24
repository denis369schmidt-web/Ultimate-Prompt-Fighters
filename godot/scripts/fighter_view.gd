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

# --- SUBZERO TEXTURES ---
const SUBZERO_ARMOR_ALBEDO = preload("res://assets/textures/skins/subzero_armor_albedo.png")
const SUBZERO_ICE_EM = preload("res://assets/textures/skins/subzero_ice_emission.png")

# --- PAIN TEXTURES ---
const PAIN_CLOAK_ALBEDO = preload("res://assets/textures/skins/pain_cloak_albedo.png")
const PAIN_RINNEGAN_EM = preload("res://assets/textures/skins/pain_rinnegan_emission.png")

# --- GOKU TEXTURES ---
const GOKU_GI_ALBEDO = preload("res://assets/textures/skins/goku_gi_albedo.png")
const GOKU_UNDERSHIRT_ALBEDO = preload("res://assets/textures/skins/goku_undershirt_albedo.png")

# --- VFX PARTICLES ---
const LAVA_EMBER_TEX = preload("res://assets/textures/vfx/lava_ember.png")
const ELECTRIC_SPARK_TEX = preload("res://assets/textures/vfx/electric_spark.png")

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

func setup(p: Dictionary) -> void:
	profile = p
	model = load("res://assets/models/%s.glb" % p.family).instantiate()
	add_child(model)
	if p.family in ["subzero", "pain", "luffy"]:
		model.scale = Vector3.ONE * 1.05
	elif p.family == "goku":
		model.scale = Vector3.ONE * 0.01
		model.rotation.y = PI
	else:
		model.scale = Vector3.ONE * 0.01

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
		if clip_map.has("Idle"):
			animation.play(clip_map["Idle"])
			current_pose = "Idle"

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
	elif p.family == "subzero":
		triplanar_scale = Vector3(0.020, 0.020, 0.020)
		skin_glow_color = Color("4ad4ff")
		skin_metallic = 0.88
		skin_roughness = 0.22
	elif p.family == "pain":
		triplanar_scale = Vector3(0.018, 0.018, 0.018)
		skin_glow_color = Color("9900ee")
		skin_metallic = 0.15
		skin_roughness = 0.65
	elif p.family == "luffy":
		triplanar_scale = Vector3(0.018, 0.018, 0.018)
		skin_glow_color = Color("ff2b2b")
		skin_metallic = 0.05
		skin_roughness = 0.55
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
			elif p.family in ["subzero", "pain", "goku", "luffy"]:
				# GLB imported materials may be BaseMaterial3D or null – create fresh one
				mat = StandardMaterial3D.new()
			else:
				continue
			mat.cull_mode = BaseMaterial3D.CULL_DISABLED

			# PRESERVE AUTHENTIC FACE PLATES & UV-MAPPED FACIAL DETAILS
			if "Face" in mesh.name or "FacePlate" in mesh.name or "Face" in mat.resource_name:
				mat.uv1_triplanar = false
				mat.rim_enabled = true
				mat.rim = 0.50
				mat.rim_tint = 0.40
				mat.roughness = 0.48
				mat.metallic = 0.0
				mesh.set_surface_override_material(surface, mat)
				continue

			if p.family in ["subzero", "pain", "goku", "luffy"]:
				mat.uv1_triplanar = false
				mat.rim_enabled = true
				mat.rim = 0.35
				mat.rim_tint = 0.50
			else:
				mat.uv1_scale = triplanar_scale
				mat.uv1_triplanar = true
				mat.uv1_triplanar_sharpness = 8.0 if p.family == "ninja" else 3.0
				mat.rim_enabled = true
				mat.rim = 0.85
				mat.rim_tint = 0.70

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
					mat.emission = Color("ffe57f") if ("Gem" in mesh.name or "Edge" in mesh.name or "Tip" in mesh.name) else Color("8fe4ff")
					mat.emission_energy_multiplier = 4.6
					mat.roughness = 0.06
					glow_materials.append(mat)
					base_emissions.append(4.6)
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
					# Pearlescent white paladin plate armor
					mat.albedo_color = Color("f2f5fb")
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
					mat.albedo_texture = skin_rock_albedo
					mat.albedo_color = Color(0.24, 0.25, 0.28)
					mat.normal_enabled = true
					mat.normal_texture = skin_rock_norm
					mat.normal_scale = 2.2
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
			elif p.family == "goku":
				if "Hair" in mesh.name or "Spike" in mesh.name or "Bang" in mesh.name or "Crown" in mesh.name:
					# Ultra Ego / Super Saiyan Ultra Radiant Purple Spiked Hair
					mat.albedo_color = Color("9b30ff")
					mat.roughness = 0.22
					mat.metallic = 0.25
					mat.rim_enabled = true
					mat.rim = 1.0
					mat.rim_tint = 0.85
					mat.emission_enabled = true
					mat.emission = Color("8a2be2")
					mat.emission_energy_multiplier = 0.85
				elif "Gi" in mesh.name or "Pants" in mesh.name or "Tunic" in mesh.name:
					# Authentic Turtle School Orange Martial Arts Gi
					mat.albedo_texture = GOKU_GI_ALBEDO
					mat.albedo_color = Color("ffffff")
					mat.roughness = 0.82
					mat.metallic = 0.02
				elif "Undershirt" in mesh.name or "Belt" in mesh.name or "Sash" in mesh.name or "Wrist" in mesh.name or "Boot" in mesh.name or "Knot" in mesh.name:
					# Navy Blue undershirt, sash belt & martial arts wristbands
					mat.albedo_texture = GOKU_UNDERSHIRT_ALBEDO
					mat.albedo_color = Color("ffffff")
					mat.roughness = 0.75
					mat.metallic = 0.05
				elif "Skin" in mat.resource_name or "Arm" in mesh.name or "Neck" in mesh.name or "Head" in mesh.name or "GokuBody" in mesh.name:
					# Toned anime martial artist tan skin
					mat.albedo_color = Color("f5caaa")
					mat.roughness = 0.52
					mat.metallic = 0.0
					mat.rim_enabled = true
					mat.rim = 0.35
				elif "Pole" in mesh.name or "Staff" in mesh.name:
					# Power Pole (Nyoi-bo) crimson red & gold
					mat.albedo_color = Color("c62828")
					mat.metallic = 0.85
					mat.roughness = 0.15
				elif "Aura" in mesh.name or "Ki" in mesh.name or "Core" in mesh.name:
					mat.albedo_color = Color(2.0, 1.0, 2.5)
					mat.emission_enabled = true
					mat.emission = Color("b347ff")
					mat.emission_energy_multiplier = 5.5
					glow_materials.append(mat)
					base_emissions.append(5.5)
				else:
					mat.albedo_color = Color("ff5722")
					mat.roughness = 0.85
			elif p.family == "phoenix":
				if "Feather" in mesh.name or "Wing" in mesh.name or "Paul" in mesh.name or "Chest" in mesh.name or "Crown" in mesh.name:
					mat.albedo_color = Color("d83212")
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
					mat.emission = Color("2be58f")
					mat.emission_energy_multiplier = 4.8
					glow_materials.append(mat)
					base_emissions.append(4.8)
				else:
					mat.albedo_color = Color("1a1c22")
					mat.metallic = 0.70
					mat.roughness = 0.25
			elif p.family == "specter":
				if "Crystal" in mesh.name or "Lance" in mesh.name or "Prism" in mesh.name or "Spike" in mesh.name:
					mat.albedo_color = Color("c088ff")
					mat.metallic = 0.80
					mat.roughness = 0.08
					mat.rim_enabled = true
					mat.rim = 0.95
				elif "Void" in mesh.name or "Glow" in mesh.name or "Eye" in mesh.name or "Core" in mesh.name:
					mat.albedo_color = Color(2.0, 1.2, 3.0)
					mat.emission_enabled = true
					mat.emission = Color("9b30ff")
					mat.emission_energy_multiplier = 5.2
					glow_materials.append(mat)
					base_emissions.append(5.2)
				else:
					mat.albedo_color = Color("181028")
					mat.metallic = 0.65
					mat.roughness = 0.22
			elif p.family == "subzero":
				if "Eye" in mesh.name or "Ice" in mesh.name or "Kori" in mesh.name or "Spike" in mesh.name:
					mat.albedo_color = Color("8ae8ff")
					mat.metallic = 0.20
					mat.roughness = 0.06
					mat.emission_enabled = true
					mat.emission_texture = SUBZERO_ICE_EM
					mat.emission = Color("4ad4ff")
					mat.emission_energy_multiplier = 3.5
					glow_materials.append(mat)
					base_emissions.append(3.5)
				elif "Medallion" in mesh.name:
					mat.albedo_color = Color("e5b820")
					mat.metallic = 0.95
					mat.roughness = 0.16
				elif "Armor" in mesh.name or "Shin" in mesh.name or "Pauldron" in mesh.name or "Gauntlet" in mesh.name or "Guard" in mesh.name or "Kneecap" in mesh.name:
					mat.albedo_texture = SUBZERO_ARMOR_ALBEDO
					mat.albedo_color = Color("ffffff")
					mat.metallic = 0.85
					mat.roughness = 0.25
					mat.rim_enabled = true
					mat.rim = 0.85
					mat.rim_tint = 0.70
				elif "Mask" in mesh.name:
					mat.albedo_color = Color("0088ee")
					mat.metallic = 0.70
					mat.roughness = 0.28
					mat.rim_enabled = true
					mat.rim = 0.90
				elif "Tabard" in mesh.name or "Tasset" in mesh.name:
					mat.albedo_color = Color("0066ee")
					mat.roughness = 0.52
					mat.metallic = 0.10
					mat.rim_enabled = true
					mat.rim = 0.60
				elif "Cowl" in mesh.name or "Belt" in mesh.name or "Boot" in mesh.name:
					mat.albedo_color = Color("0c0e12")
					mat.roughness = 0.80
					mat.metallic = 0.05
				elif "Body" in mesh.name:
					mat.albedo_color = Color("14161c")
					mat.roughness = 0.85
					mat.metallic = 0.04
				else:
					mat.albedo_color = Color("0055bb")
					mat.roughness = 0.65
			elif p.family == "pain":
				if "Rinnegan" in mesh.name or "Eye" in mesh.name or "EyeRing" in mesh.name:
					mat.albedo_color = Color("7010bb")
					mat.metallic = 0.15
					mat.roughness = 0.08
					mat.emission_enabled = true
					mat.emission_texture = PAIN_RINNEGAN_EM
					mat.emission = Color("9900ee")
					mat.emission_energy_multiplier = 4.0
					glow_materials.append(mat)
					base_emissions.append(4.0)
				elif "Cloud" in mesh.name:
					mat.albedo_color = Color("d41208")
					mat.roughness = 0.68
					mat.metallic = 0.04
				elif "Cloak" in mesh.name:
					mat.albedo_texture = PAIN_CLOAK_ALBEDO
					mat.albedo_color = Color("ffffff")
					mat.roughness = 0.75
					mat.metallic = 0.02
				elif "Headband" in mesh.name:
					mat.albedo_color = Color("c2c8d2")
					mat.metallic = 0.92
					mat.roughness = 0.20
				elif "Pierce" in mesh.name or "EarRing" in mesh.name:
					mat.albedo_color = Color("2e323a")
					mat.metallic = 0.95
					mat.roughness = 0.12
				elif "Hair" in mesh.name:
					mat.albedo_color = Color("ff5500")
					mat.roughness = 0.38
					mat.metallic = 0.08
					mat.rim_enabled = true
					mat.rim = 0.95
				elif "Body" in mesh.name:
					mat.albedo_color = Color("f6d8c8")
					mat.roughness = 0.52
					mat.metallic = 0.0
					mat.rim_enabled = true
					mat.rim = 0.45
				elif "Body" in mesh.name or "Skin" in mesh.name or "GEO" in mesh.name or "geo" in mesh.name:
					mat.albedo_color = Color("f0d0b8")
					mat.roughness = 0.55
					mat.metallic = 0.0
					mat.rim_enabled = true
					mat.rim = 0.40
				else:
					mat.albedo_color = Color("222226")
					mat.roughness = 0.70
			elif p.family == "luffy":
				if "Vest" in mesh.name:
					mat.albedo_color = Color("dc1412")
					mat.roughness = 0.72
					mat.metallic = 0.0
				elif "Shorts" in mesh.name:
					mat.albedo_color = Color("153888")
					mat.roughness = 0.78
					mat.metallic = 0.0
				elif "Cuff" in mesh.name:
					mat.albedo_color = Color("eeeeee")
					mat.roughness = 0.85
				elif "StrawHat" in mesh.name or "Hat" in mesh.name:
					mat.albedo_color = Color("dfbf52")
					mat.roughness = 0.68
				elif "Ribbon" in mesh.name:
					mat.albedo_color = Color("cc1010")
					mat.roughness = 0.65
				elif "Button" in mesh.name:
					mat.albedo_color = Color("f0c020")
					mat.metallic = 0.90
					mat.roughness = 0.20
				elif "Sandal" in mesh.name:
					mat.albedo_color = Color("5a3818")
					mat.roughness = 0.80
				elif "Hair" in mesh.name:
					mat.albedo_color = Color("101014")
					mat.roughness = 0.35
				elif "Eye" in mesh.name or "Pupil" in mesh.name:
					mat.albedo_color = Color("ffffff") if "White" in mesh.name else Color("050505")
					mat.roughness = 0.15
				elif "Body" in mesh.name or "GEO" in mesh.name or "body_male" in mesh.name:
					mat.albedo_color = Color("f5caaa")
					mat.roughness = 0.52
					mat.metallic = 0.0
					mat.rim_enabled = true
					mat.rim = 0.35
				else:
					mat.albedo_color = Color("e01515")
					mat.roughness = 0.65
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

func _process(delta: float) -> void:
	pulse_time += delta
	var pulse: float = sin(pulse_time * 3.6) * 0.22 + 1.0
	for i in range(glow_materials.size()):
		var base_em: float = base_emissions[i] if i < base_emissions.size() else 2.0
		glow_materials[i].emission_energy_multiplier = base_em * pulse

func update_state(state: Dictionary, delta: float) -> void:
	position.x = state.x
	position.y = state.get("y", 0.0)
	var target_rot: float = (PI - state.facing * 0.65) if (profile and profile.get("family", "") == "goku") else (state.facing * 0.65)
	model.rotation.y = lerp_angle(model.rotation.y, target_rot, minf(1.0, delta * 14))

	var is_invuln: bool = state.get("invulnerable", 0.0) > 0.0
	model.visible = not is_invuln or (int(pulse_time * 24.0) % 2 == 0)

	var pose: String = state.pose
	if pose != current_pose and animation and clip_map.has(pose):
		animation.play(clip_map[pose], 0.09)
		current_pose = pose

	if shield:
		var is_blocking: bool = state.get("blocking", false)
		shield.visible = is_blocking
		if is_blocking:
			shield.position = Vector3(state.facing * 0.38, 1.15, 0.15)
			shield.rotation.y = state.facing * 0.65

func flash() -> void:
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

