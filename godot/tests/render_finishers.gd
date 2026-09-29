extends SceneTree
## Renders every finisher cinematic at two moments for visual review.
## Usage: godot --path godot --script res://tests/render_finishers.gd -- --out=<dir>

var out_dir := "user://"

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): out_dir = arg.trim_prefix("--out=")
	call_deferred("run")

func frames(n: int) -> void:
	for k in range(n): await process_frame

func shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_viewport().get_texture().get_image().save_png(out_dir.path_join(name))
	print("CAPTURED ", name)

func run() -> void:
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	await frames(5)
	var kinds := {"inferno": "EINÄSCHERN", "frost": "EISSARG", "storm": "HIMMELSZORN", "void": "LEERENSOG", "titan": "STERNENSCHUSS"}
	for kind in kinds:
		app.start_round("autonomous")
		await frames(10)
		app.sim.countdown = 0.0
		var w: Dictionary = app.sim.fighters[0]
		var l: Dictionary = app.sim.fighters[1]
		w.x = -1.2
		w.y = 0.0
		w.facing = 1
		l.x = 1.0
		l.y = 0.0
		l.state = "Dazed"
		l.pose = "Dazed"
		app.sim.result = 0
		await frames(30)
		await shot("fin_%s_0_dazed.png" % kind)
		app.play_finisher(0, 1, kind, kinds[kind])
		await frames(70)
		await shot("fin_%s_1.png" % kind)
		await frames(60)
		await shot("fin_%s_2.png" % kind)
		while app.finisher_running: await process_frame
		await frames(5)
		await shot("fin_%s_3_result.png" % kind)
	quit()
