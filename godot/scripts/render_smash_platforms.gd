extends SceneTree

const Prompt = preload("res://scripts/prompt_interpreter.gd")
const Combat = preload("res://scripts/combat.gd")
const FighterView = preload("res://scripts/fighter_view.gd")

func _initialize():
	var scene = Node3D.new()
	root.add_child(scene)

	# Camera
	var cam = Camera3D.new()
	cam.position = Vector3(0, 2.1, 6.2)
	cam.fov = 55
	scene.add_child(cam)
	cam.look_at_from_position(cam.position, Vector3(0, 1.45, 0))
	cam.current = true

	# Environment
	var env = WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_SKY
	var sky = Sky.new()
	var sky_mat = PanoramaSkyMaterial.new()
	sky_mat.panorama = load("res://assets/textures/arenas/sky_blood_moon.png")
	sky.sky_material = sky_mat
	env.environment.sky = sky
	env.environment.sky_rotation = Vector3(0, deg_to_rad(90), 0)
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color("2a384c")
	env.environment.ambient_light_energy = 0.90
	env.environment.glow_enabled = true
	env.environment.glow_bloom = 0.4
	env.environment.glow_intensity = 1.0
	env.environment.tonemap_mode = Environment.TONE_MAPPER_ACES
	scene.add_child(env)

	# Sun
	var sun = DirectionalLight3D.new()
	sun.light_color = Color("fff0e2")
	sun.light_energy = 2.0
	sun.rotation_degrees = Vector3(-35, -25, 0)
	scene.add_child(sun)

	# Main Stage Floor
	var stage_slab = MeshInstance3D.new()
	var stage_box = BoxMesh.new()
	stage_box.size = Vector3(9.5, 0.4, 3.2)
	stage_slab.mesh = stage_box
	stage_slab.position = Vector3(0, -0.2, 0)
	var stage_mat = StandardMaterial3D.new()
	stage_mat.albedo_texture = preload("res://assets/textures/arenas/floor_lava_albedo.png")
	stage_mat.emission_enabled = true
	stage_mat.emission_texture = preload("res://assets/textures/arenas/floor_lava_emission.png")
	stage_mat.emission = Color("ff6d2b")
	stage_mat.emission_energy_multiplier = 1.2
	stage_slab.material_override = stage_mat
	scene.add_child(stage_slab)

	# Floating Platforms
	var stone_tex: Texture2D = preload("res://assets/textures/characters/golem_rock_albedo.png")
	var stone_norm: Texture2D = preload("res://assets/textures/characters/golem_rock_normal.png")
	var plats = [
		{"pos": Vector3(-2.3, 1.45, 0.0), "size": Vector3(2.2, 0.14, 1.1)},
		{"pos": Vector3( 2.3, 1.45, 0.0), "size": Vector3(2.2, 0.14, 1.1)},
		{"pos": Vector3( 0.0, 2.65, 0.0), "size": Vector3(2.2, 0.14, 1.1)},
	]
	for p in plats:
		var root_plat = Node3D.new()
		root_plat.position = p.pos
		scene.add_child(root_plat)

		var slab = MeshInstance3D.new()
		var box = BoxMesh.new()
		box.size = p.size
		slab.mesh = box
		var mat = StandardMaterial3D.new()
		mat.albedo_texture = stone_tex
		mat.normal_enabled = true
		mat.normal_texture = stone_norm
		mat.normal_scale = 1.8
		mat.roughness = 0.55
		mat.metallic = 0.25
		slab.material_override = mat
		root_plat.add_child(slab)

		var trim = MeshInstance3D.new()
		var trim_mesh = BoxMesh.new()
		trim_mesh.size = Vector3(p.size.x + 0.08, 0.035, p.size.z + 0.08)
		trim.mesh = trim_mesh
		trim.position.y = p.size.y * 0.5 - 0.015
		var trim_mat = StandardMaterial3D.new()
		trim_mat.albedo_color = Color("1a2030")
		trim_mat.emission_enabled = true
		trim_mat.emission = Color("49def4")
		trim_mat.emission_energy_multiplier = 3.5
		trim.material_override = trim_mat
		root_plat.add_child(trim)

		var crystal = MeshInstance3D.new()
		var prism = PrismMesh.new()
		prism.size = Vector3(0.42, 0.38, 0.42)
		crystal.mesh = prism
		crystal.rotation_degrees = Vector3(180, 0, 0)
		crystal.position.y = -p.size.y * 0.5 - 0.16
		var c_mat = StandardMaterial3D.new()
		c_mat.albedo_color = Color(1.5, 1.5, 2.0)
		c_mat.emission_enabled = true
		c_mat.emission = Color("ff6d2b")
		c_mat.emission_energy_multiplier = 4.5
		crystal.material_override = c_mat
		root_plat.add_child(crystal)

	# Place fighters on different platforms:
	# 1. Luffy on top platform
	var p_luffy = Prompt.interpret("Monkey D. Luffy Strohhut Gum-Gum One Piece Mugiwara", 0)
	var v_luffy = FighterView.new()
	scene.add_child(v_luffy)
	v_luffy.setup(p_luffy)
	v_luffy.update_state({"x": 0.0, "y": 2.65, "facing": 1.0, "pose": "Idle", "blocking": false}, 0.016)

	# 2. Goku on left platform
	var p_goku = Prompt.interpret("Son Goku Super Saiyan Kamehameha Dragon Ball Z", 1)
	var v_goku = FighterView.new()
	scene.add_child(v_goku)
	v_goku.setup(p_goku)
	v_goku.update_state({"x": -2.3, "y": 1.45, "facing": 1.0, "pose": "Idle", "blocking": false}, 0.016)

	# 3. Sub-Zero on right platform
	var p_subzero = Prompt.interpret("Sub-Zero Lin Kuei Cryomancer ice ninja kori blade", 0)
	var v_subzero = FighterView.new()
	scene.add_child(v_subzero)
	v_subzero.setup(p_subzero)
	v_subzero.update_state({"x": 2.3, "y": 1.45, "facing": -1.0, "pose": "SpecialAttack", "blocking": false}, 0.016)

	# 4. Golem & Ninja on main stage floor
	var p_golem = Prompt.interpret("Gepanzerter Lavagolem mit brennenden Fäusten", 0)
	var v_golem = FighterView.new()
	scene.add_child(v_golem)
	v_golem.setup(p_golem)
	v_golem.update_state({"x": -2.2, "y": 0.0, "facing": 1.0, "pose": "Idle", "blocking": false}, 0.016)

	var p_ninja = Prompt.interpret("Blitzschneller Schattenninja mit elektrischen Klingen", 1)
	var v_ninja = FighterView.new()
	scene.add_child(v_ninja)
	v_ninja.setup(p_ninja)
	v_ninja.update_state({"x": 2.2, "y": 0.0, "facing": -1.0, "pose": "LightAttack", "blocking": false}, 0.016)

	# Render frames
	for frame in range(4):
		root.render()

	var img = root.get_texture().get_image()
	img.save_png("res://screenshot_smash_platforms.png")
	print("SAVED: screenshot_smash_platforms.png")
	quit(0)
