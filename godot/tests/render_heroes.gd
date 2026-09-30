extends SceneTree
## Renders the house heroes (hero_gear.gd) full body, four per image, idle and charging.
## Usage: godot --path godot --script res://tests/render_heroes.gd -- --out=<dir> [--pose=Charge] [--only=kairo,zip]

const Prompt = preload("res://scripts/prompt_interpreter.gd")
const FighterView = preload("res://scripts/fighter_view.gd")
const HeroGear = preload("res://scripts/hero_gear.gd")

var out_dir := "user://"
var pose := "Idle"
var only: Array = []
var yaw := 0.45

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): out_dir = arg.trim_prefix("--out=")
		if arg.begins_with("--pose="): pose = arg.trim_prefix("--pose=")
		if arg.begins_with("--only="): only = Array(arg.trim_prefix("--only=").split(","))
		if arg.begins_with("--yaw="): yaw = float(arg.trim_prefix("--yaw="))
	call_deferred("run")

func run() -> void:
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	var presets: Array = []
	for p in app.mk_presets:
		if HeroGear.has_hero(str(p.id)) and (only.is_empty() or str(p.id) in only): presets.append(p.duplicate())
	app.queue_free()
	await process_frame

	var world := Node3D.new()
	root.add_child(world)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("141a26")
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color("8894aa")
	env.environment.ambient_light_energy = 0.6
	env.environment.tonemap_mode = Environment.TONE_MAPPER_AGX
	env.environment.glow_enabled = true
	env.environment.glow_intensity = 0.5
	world.add_child(env)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-30, 30, 0)
	key.light_energy = 1.6
	key.shadow_enabled = true
	world.add_child(key)
	var rim := DirectionalLight3D.new()
	rim.rotation_degrees = Vector3(-10, 170, 0)
	rim.light_energy = 2.2
	rim.light_color = Color("a8c8ff")
	world.add_child(rim)
	var floor_m := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(40, 10)
	floor_m.mesh = pm
	var fm := StandardMaterial3D.new()
	fm.albedo_color = Color("1f2937")
	floor_m.material_override = fm
	world.add_child(floor_m)
	var cam := Camera3D.new()
	cam.fov = 30
	world.add_child(cam)
	cam.current = true

	var page := 0
	var i := 0
	while i < presets.size():
		var views: Array = []
		var labels: Array = []
		for k in range(4):
			if i + k >= presets.size(): break
			var profile: Dictionary = Prompt.interpret(presets[i + k].prompt, 0)
			profile.slot = 0
			var v = FighterView.new()
			world.add_child(v)
			v.setup(profile)
			v.position = Vector3((k - 1.5) * 2.2, 0, 0)
			views.append(v)
			var l := Label3D.new()
			l.text = "%s  (%s)" % [presets[i + k].name, profile.family]
			l.position = Vector3((k - 1.5) * 2.2, -0.25, 0.6)
			l.font_size = 40
			l.pixel_size = 0.004
			world.add_child(l)
			labels.append(l)
		for n in range(40):
			for k in range(views.size()):
				views[k].update_state({"x": (k - 1.5) * 2.2, "y": 0.0, "facing": 1, "pose": pose, "state": "Attack" if pose != "Idle" else "Idle", "blocking": false}, 1.0 / 60.0)
				views[k].model.rotation.y = yaw
			await process_frame
		cam.position = Vector3(0, 1.25, 10.5)
		cam.look_at(Vector3(0, 1.0, 0))
		await process_frame
		await RenderingServer.frame_post_draw
		var img: Image = root.get_viewport().get_texture().get_image()
		img.save_png(out_dir.path_join("heroes_%s_%d.png" % [pose.to_lower(), page]))
		print("PAGE ", page)
		for v in views: v.queue_free()
		for l in labels: l.queue_free()
		await process_frame
		page += 1
		i += 4
	quit()
