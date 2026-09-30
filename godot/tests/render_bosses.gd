extends SceneTree
## Visual check of the angel bosses in their boss levels: intro, fight and a close-up.
## Usage: godot --path godot --script res://tests/render_bosses.gd -- --out=<dir> [--only=<boss>]

const Bosses = preload("res://scripts/bosses.gd")

var out_dir := "user://"
var only := ""
var quick := false

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): out_dir = arg.trim_prefix("--out=")
		if arg.begins_with("--only="): only = arg.trim_prefix("--only=")
		if arg == "--quick": quick = true
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
	for bid in Bosses.ORDER:
		if only != "" and bid != only: continue
		app.start_boss(bid, false)
		app.sim.mode = "autonomous"
		await frames(170 if quick else 40)
		if not quick:
			await shot("boss_%s_1_intro.png" % bid)
			await frames(300)
			await shot("boss_%s_2_fight.png" % bid)
			await frames(200)
			await shot("boss_%s_3_fight.png" % bid)
		# Close-up of the body.
		var f: Dictionary = app.sim.fighters[app.sim.fighters.size() - 1]
		app.cinematic = true
		app.camera.global_position = Vector3(f.x + 0.8, f.y + 2.0, 6.0)
		app.camera.look_at(Vector3(f.x, f.y + 1.8, 0))
		await frames(3)
		await shot("boss_%s_4_closeup.png" % bid)
		app.cinematic = false
		app.show_selection()
		await frames(5)
	quit()
