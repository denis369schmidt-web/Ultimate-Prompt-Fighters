extends SceneTree

const Prompt = preload("res://scripts/prompt_interpreter.gd")
const FighterView = preload("res://scripts/fighter_view.gd")

func _initialize():
	render_all()

func render_all() -> void:
	var showcases = [
		{
			"file": "screenshot_dragon_showcase.png",
			"fighter": "Mächtiger Cyber Drachenritter mit flammendem Drachen-Großschwert",
			"slot": 0,
			"pos": Vector3(0, 0, 0),
			"facing": 0.55,
			"pose": "SpecialAttack",
			"blocking": false,
			"cam_pos": Vector3(0.35, 1.42, 2.35),
			"cam_look": Vector3(0, 1.25, 0),
			"sky": "res://assets/textures/arenas/sky_volcano_sanctum.png",
			"sun_col": Color("fff5eb"),
			"sun_rot": Vector3(-25, -15, 0)
		},
		{
			"file": "screenshot_dragon_vs_valkyrie.png",
			"fighter": "Strahlende Moe Valkyrie Paladin Kriegerin mit Lichtflügeln und Rapier",
			"slot": 0,
			"pos": Vector3(-0.85, 0, 0),
			"facing": 1.0,
			"pose": "Block",
			"blocking": true,
			"opponent": "Mächtiger Cyber Drachenritter mit flammendem Drachen-Großschwert",
			"opp_slot": 1,
			"opp_pos": Vector3(0.85, 0, 0),
			"opp_facing": -1.0,
			"opp_pose": "LightAttack",
			"cam_pos": Vector3(0, 1.40, 3.05),
			"cam_look": Vector3(0, 1.18, 0),
			"sky": "res://assets/textures/arenas/sky_volcano_sanctum.png",
			"sun_col": Color("fff5eb"),
			"sun_rot": Vector3(-25, -15, 0)
		},
		{
			"file": "screenshot_anubis_showcase.png",
			"fighter": "Jackal God Anubis wielding dual Khopesh",
			"slot": 0,
			"pos": Vector3(0, 0, 0),
			"facing": -0.30,
			"pose": "SpecialAttack",
			"blocking": false,
			"cam_pos": Vector3(0.3, 1.45, 2.8),
			"cam_look": Vector3(0, 1.20, 0),
			"sky": "res://assets/textures/arenas/sky_volcano_sanctum.png",
			"sun_col": Color("fff0dd"),
			"sun_rot": Vector3(-28, 25, 0)
		},
		{
			"file": "screenshot_specter_showcase.png",
			"fighter": "Void Specter crystal phantom warrior with void lance",
			"slot": 0,
			"pos": Vector3(0, 0, 0),
			"facing": -0.25,
			"pose": "SpecialAttack",
			"blocking": false,
			"cam_pos": Vector3(0.25, 1.50, 2.7),
			"cam_look": Vector3(0, 1.25, 0),
			"sky": "res://assets/textures/arenas/sky_blood_moon.png",
			"sun_col": Color("cce0ff"),
			"sun_rot": Vector3(-32, 18, 0)
		},
		{
			"file": "screenshot_subzero_showcase.png",
			"fighter": "Sub-Zero Lin Kuei Cryomancer ice ninja kori blade",
			"slot": 0,
			"pos": Vector3(0, 0, 0),
			"facing": -0.22,
			"pose": "SpecialAttack",
			"blocking": false,
			"cam_pos": Vector3(0.28, 1.35, 2.65),
			"cam_look": Vector3(0, 1.15, 0),
			"sky": "res://assets/textures/arenas/sky_blood_moon.png",
			"sun_col": Color("ccf0ff"),
			"sun_rot": Vector3(-28, 20, 0)
		},
		{
			"file": "screenshot_pain_showcase.png",
			"fighter": "Pain Nagato Rinnegan Akatsuki tendo deva path",
			"slot": 0,
			"pos": Vector3(0, 0, 0),
			"facing": 0.10,
			"pose": "SpecialAttack",
			"blocking": false,
			"cam_pos": Vector3(0.25, 1.35, 2.65),
			"cam_look": Vector3(0, 1.15, 0),
			"sky": "res://assets/textures/arenas/sky_blood_moon.png",
			"sun_col": Color("aa44ff"),
			"sun_rot": Vector3(-32, 15, 0)
		},
		{
			"file": "screenshot_goku_showcase.png",
			"fighter": "Son Goku Saiyan Kämpfer mit lila Haaren und Turtle School Gi",
			"slot": 0,
			"pos": Vector3(0, 0, 0),
			"facing": -0.20,
			"pose": "SpecialAttack",
			"blocking": false,
			"cam_pos": Vector3(0.25, 1.35, 2.65),
			"cam_look": Vector3(0, 1.15, 0),
			"sky": "res://assets/textures/arenas/sky_blood_moon.png",
			"sun_col": Color("ffe5ff"),
			"sun_rot": Vector3(-25, 15, 0)
		},
		{
			"file": "screenshot_luffy_showcase.png",
			"fighter": "Monkey D. Luffy Strohhut Gum-Gum One Piece Mugiwara",
			"slot": 0,
			"pos": Vector3(0, 0, 0),
			"facing": -0.18,
			"pose": "SpecialAttack",
			"blocking": false,
			"cam_pos": Vector3(0.28, 1.35, 2.65),
			"cam_look": Vector3(0, 1.15, 0),
			"sky": "res://assets/textures/arenas/sky_blood_moon.png",
			"sun_col": Color("ff8844"),
			"sun_rot": Vector3(-28, 20, 0)
		},
		{
			"file": "screenshot_subzero_vs_pain.png",
			"fighter": "Sub-Zero Lin Kuei Cryomancer ice ninja kori blade",
			"slot": 0,
			"pos": Vector3(-1.05, 0, 0),
			"facing": 1.0,
			"pose": "SpecialAttack",
			"blocking": false,
			"opponent": "Pain Nagato Rinnegan Akatsuki tendo deva path",
			"opp_slot": 1,
			"opp_pos": Vector3(1.05, 0, 0),
			"opp_facing": -1.0,
			"opp_pose": "SpecialAttack",
			"cam_pos": Vector3(0, 1.45, 3.85),
			"cam_look": Vector3(0, 1.15, 0),
			"sky": "res://assets/textures/arenas/sky_blood_moon.png",
			"sun_col": Color("ccf0ff"),
			"sun_rot": Vector3(-28, 20, 0)
		},
		{
			"file": "screenshot_all_four_showcase.png",
			"fighter": "Mächtiger Cyber Drachenritter mit flammendem Drachen-Großschwert",
			"slot": 0,
			"pos": Vector3(0.38, 0, 0.05),
			"facing": -0.32,
			"pose": "Idle",
			"blocking": false,
			"extra_1": "Strahlende Moe Valkyrie Paladin Kriegerin mit Lichtflügeln und Rapier",
			"extra_1_pos": Vector3(-0.38, 0, 0.05),
			"extra_1_facing": 0.32,
			"extra_2": "Blitzschneller Schattenninja mit elektrischen Klingen",
			"extra_2_pos": Vector3(-1.38, 0, -0.15),
			"extra_2_facing": 0.45,
			"extra_3": "Gepanzerter Lavagolem mit brennenden Fäusten",
			"extra_3_pos": Vector3(1.42, 0, -0.15),
			"extra_3_facing": -0.45,
			"cam_pos": Vector3(0, 1.48, 3.9),
			"cam_look": Vector3(0, 1.20, 0),
			"sky": "res://assets/textures/arenas/sky_blood_moon.png",
			"sun_col": Color("fff0e2"),
			"sun_rot": Vector3(-30, 20, 0)
		}
	]

	var floor_tex = load("res://assets/textures/arenas/floor_stone_albedo.png")
	var floor_norm = load("res://assets/textures/arenas/floor_stone_normal.png")

	for sc_info in showcases:
		print("Rendering showcase: ", sc_info.file)
		var scene = Node3D.new()
		root.add_child(scene)

		var cam = Camera3D.new()
		cam.position = sc_info.cam_pos
		scene.add_child(cam)
		cam.look_at_from_position(cam.position, sc_info.cam_look)
		cam.current = true

		var env = WorldEnvironment.new()
		env.environment = Environment.new()
		env.environment.background_mode = Environment.BG_SKY
		var sky = Sky.new()
		var sky_mat = PanoramaSkyMaterial.new()
		sky_mat.panorama = load(sc_info.sky)
		sky.sky_material = sky_mat
		env.environment.sky = sky
		env.environment.sky_rotation = Vector3(0, deg_to_rad(90), 0)
		env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
		env.environment.ambient_light_energy = 0.85
		env.environment.ambient_light_sky_contribution = 0.70
		env.environment.glow_enabled = true
		env.environment.glow_intensity = 0.85
		env.environment.glow_bloom = 0.20
		env.environment.glow_blend_mode = Environment.GLOW_BLEND_MODE_SOFTLIGHT
		env.environment.glow_hdr_threshold = 1.02
		env.environment.glow_hdr_scale = 1.8
		env.environment.volumetric_fog_enabled = true
		env.environment.volumetric_fog_density = 0.010
		env.environment.volumetric_fog_albedo = Color(0.2, 0.25, 0.35)
		env.environment.ssao_enabled = true
		env.environment.ssao_radius = 1.8
		env.environment.ssao_intensity = 2.6
		env.environment.ssr_enabled = true
		env.environment.ssr_max_steps = 64
		env.environment.adjustment_enabled = true
		env.environment.adjustment_contrast = 1.10
		env.environment.adjustment_saturation = 1.15
		env.environment.tonemap_mode = Environment.TONE_MAPPER_ACES
		scene.add_child(env)

		# Floor with SSR-friendly wet/polished sheen on Layer 1 only
		var floor_mesh = MeshInstance3D.new()
		floor_mesh.layers = 1
		var plane = PlaneMesh.new()
		plane.size = Vector2(24, 24)
		floor_mesh.mesh = plane
		var f_mat = StandardMaterial3D.new()
		f_mat.albedo_texture = floor_tex
		f_mat.normal_enabled = true
		f_mat.normal_texture = floor_norm
		f_mat.normal_scale = 2.2
		f_mat.uv1_scale = Vector3(4, 4, 4)
		f_mat.roughness = 0.42
		f_mat.metallic = 0.15
		f_mat.rim_enabled = true
		f_mat.rim = 0.35
		floor_mesh.material_override = f_mat
		scene.add_child(floor_mesh)

		# Direct Sun Key Light (illuminates both arena and fighters)
		var light = DirectionalLight3D.new()
		light.light_cull_mask = 1 | 2
		light.rotation_degrees = sc_info.sun_rot
		light.light_color = sc_info.sun_col
		light.light_energy = 2.0
		light.shadow_enabled = true
		light.shadow_bias = 0.015
		light.shadow_blur = 1.4
		scene.add_child(light)

		# Dedicated 3-Point Rim / Kicker Light (Isolated to Layer 2: Fighters only, zero floor sheen!)
		var rim = DirectionalLight3D.new()
		rim.light_cull_mask = 2
		rim.rotation_degrees = Vector3(145, 25, 0)
		rim.light_color = sc_info.sun_col.lerp(Color.WHITE, 0.5)
		rim.light_energy = 1.75
		rim.shadow_enabled = false
		scene.add_child(rim)

		# Soft Fill Light
		var fill = DirectionalLight3D.new()
		fill.rotation_degrees = Vector3(25, -140, 0)
		fill.light_color = Color("85a5cc")
		fill.light_energy = 0.75
		scene.add_child(fill)

		# Primary fighter
		var p1 = Prompt.interpret(sc_info.fighter, sc_info.slot)
		var v1 = FighterView.new()
		scene.add_child(v1)
		v1.setup(p1)
		v1.position = sc_info.pos

		# Opponent if any
		var v2: FighterView = null
		if sc_info.has("opponent"):
			var p2 = Prompt.interpret(sc_info.opponent, sc_info.opp_slot)
			v2 = FighterView.new()
			scene.add_child(v2)
			v2.setup(p2)
			v2.position = sc_info.opp_pos

		# Extra fighters
		var ve1: FighterView = null
		if sc_info.has("extra_1"):
			var pe1 = Prompt.interpret(sc_info.extra_1, 1)
			ve1 = FighterView.new()
			scene.add_child(ve1)
			ve1.setup(pe1)
			ve1.position = sc_info.extra_1_pos

		var ve2: FighterView = null
		if sc_info.has("extra_2"):
			var pe2 = Prompt.interpret(sc_info.extra_2, 1)
			ve2 = FighterView.new()
			scene.add_child(ve2)
			ve2.setup(pe2)
			ve2.position = sc_info.extra_2_pos

		var ve3: FighterView = null
		if sc_info.has("extra_3"):
			var pe3 = Prompt.interpret(sc_info.extra_3, 1)
			ve3 = FighterView.new()
			scene.add_child(ve3)
			ve3.setup(pe3)
			ve3.position = sc_info.extra_3_pos

		# Process frames with continuous state updating
		for f in range(35):
			v1.update_state({"x": sc_info.pos.x, "y": sc_info.pos.y, "facing": sc_info.facing, "pose": sc_info.pose, "blocking": sc_info.blocking}, 0.016)
			if v2:
				v2.update_state({"x": sc_info.opp_pos.x, "y": sc_info.opp_pos.y, "facing": sc_info.opp_facing, "pose": sc_info.opp_pose, "blocking": false}, 0.016)
			if ve1:
				ve1.update_state({"x": sc_info.extra_1_pos.x, "y": 0, "facing": sc_info.extra_1_facing, "pose": "Idle", "blocking": false}, 0.016)
			if ve2:
				ve2.update_state({"x": sc_info.extra_2_pos.x, "y": 0, "facing": sc_info.extra_2_facing, "pose": "Idle", "blocking": false}, 0.016)
			if ve3:
				ve3.update_state({"x": sc_info.extra_3_pos.x, "y": 0, "facing": sc_info.extra_3_facing, "pose": "Idle", "blocking": false}, 0.016)
			await process_frame

		var img = root.get_viewport().get_texture().get_image()
		if img:
			img.save_png("res://" + sc_info.file)
			print("SAVED: ", sc_info.file)

		scene.queue_free()
		await process_frame

	print("ALL_SHOWCASE_SCREENSHOTS_DONE")
	quit(0)
