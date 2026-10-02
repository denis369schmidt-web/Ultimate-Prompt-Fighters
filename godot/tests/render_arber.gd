extends SceneTree
## Arbër close-ups: on foot with the drills, and riding the double-headed eagle.
## Usage: godot --path godot --script res://tests/render_arber.gd -- --out=<dir>

const Prompt = preload("res://scripts/prompt_interpreter.gd")
const FighterView = preload("res://scripts/fighter_view.gd")
var out_dir := "user://"

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): out_dir = arg.trim_prefix("--out=")
	call_deferred("run")

func run() -> void:
	var world := Node3D.new()
	root.add_child(world)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("1a2233")
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color("9aa6bd")
	env.environment.ambient_light_energy = 0.7
	env.environment.tonemap_mode = Environment.TONE_MAPPER_AGX
	env.environment.glow_enabled = true
	world.add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-35, 30, 0)
	sun.light_energy = 1.6
	sun.shadow_enabled = true
	world.add_child(sun)
	var rim := DirectionalLight3D.new()
	rim.rotation_degrees = Vector3(-10, 170, 0)
	rim.light_energy = 2.0
	rim.light_color = Color("ffd0c0")
	world.add_child(rim)
	var cam := Camera3D.new()
	cam.fov = 35
	world.add_child(cam)
	var shots := [["foot", 0.0, "Idle", Vector3(0.9, 1.3, 3.2), Vector3(0, 1.0, 0)], ["drill", 0.0, "Attack", Vector3(1.4, 1.5, 2.2), Vector3(0, 1.2, 0)],
		["eagle", 5.0, "Idle", Vector3(1.8, 2.6, 5.2), Vector3(0, 0.6, 0)], ["eagle_side", 5.0, "Idle", Vector3(0.0, 1.4, 5.5), Vector3(0, 0.6, 0)]]
	for s in shots:
		var v = FighterView.new()
		world.add_child(v)
		v.setup(Prompt.interpret("Arbër der Bohrmeister mit zwei Bohrmaschinen und dem Doppeladler", 0))
		cam.position = s[3]
		cam.look_at(s[4])
		for n in range(70):
			v.update_state({"x": 0.0, "y": 0.0, "facing": 1, "pose": s[2], "state": "Attack" if s[2] == "Attack" else "Ready", "blocking": false, "eagle": s[1]}, 1.0 / 60.0)
			await process_frame
		await RenderingServer.frame_post_draw
		root.get_viewport().get_texture().get_image().save_png(out_dir.path_join("arber_%s.png" % s[0]))
		print("CAPTURED ", s[0])
		v.queue_free()
		await process_frame
	quit()
