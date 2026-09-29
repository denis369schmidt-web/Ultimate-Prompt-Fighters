extends SceneTree
## Renders all Mixamo bodies in the guard pose, 8 per image, to pick bodies for fighters.
## Usage: godot --path godot --script res://tests/render_bodies.gd -- --out=<dir>

const Prompt = preload("res://scripts/prompt_interpreter.gd")
const FighterView = preload("res://scripts/fighter_view.gd")
var out_dir := "user://"
var first_page := 0

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): out_dir = arg.trim_prefix("--out=")
		if arg.begins_with("--page="): first_page = int(arg.trim_prefix("--page="))
	call_deferred("run")

func run() -> void:
	var files: Array = []
	for f in DirAccess.get_files_at("res://assets/models/mixamo"):
		if f.ends_with(".glb"): files.append(f)
	files.sort()
	var world := Node3D.new()
	root.add_child(world)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("1b2230")
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color("8090a8")
	env.environment.tonemap_mode = Environment.TONE_MAPPER_AGX
	world.add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-35, -30, 0)
	sun.light_energy = 1.6
	world.add_child(sun)
	var cam := Camera3D.new()
	cam.position = Vector3(0, 1.1, 9.0)
	cam.fov = 45
	world.add_child(cam)
	cam.look_at(Vector3(0, 1.0, 0))
	cam.current = true
	var page := first_page
	while page * 8 < files.size():
		var views: Array = []
		var labels: Array = []
		for k in range(8):
			var idx := page * 8 + k
			if idx >= files.size(): break
			var p: Dictionary = Prompt.interpret("neutral fighter", 0)
			p.family = "body_" + files[idx].get_basename()
			p.model_path = "res://assets/models/mixamo/" + files[idx]
			var v = FighterView.new()
			world.add_child(v)
			v.setup(p)
			views.append(v)
			var l := Label3D.new()
			l.text = files[idx].get_basename()
			l.pixel_size = 0.004
			l.position = Vector3(-5.6 + k * 1.6, -0.25, 0.5)
			world.add_child(l)
			labels.append(l)
		for f in range(30):
			for k in range(views.size()):
				views[k].update_state({"x": -5.6 + k * 1.6, "y": 0.0, "facing": 1, "pose": "Idle", "blocking": false}, 1.0 / 60.0)
				views[k].model.rotation.y = 0.2
			await process_frame
		await RenderingServer.frame_post_draw
		root.get_viewport().get_texture().get_image().save_png(out_dir.path_join("bodies_%d.png" % page))
		print("PAGE ", page)
		for v in views: v.queue_free()
		for l in labels: l.queue_free()
		page += 1
	quit()
