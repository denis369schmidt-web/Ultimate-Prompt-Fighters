extends SceneTree
## Renders one in-fight screenshot per arena (agents fighting) for visual review.
## Usage: godot --path godot --script res://tests/render_arenas.gd -- --out=<dir> [--only=a,b]

var out_dir := "user://"
var only: Array = []

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): out_dir = arg.trim_prefix("--out=")
		if arg.begins_with("--only="): only = Array(arg.trim_prefix("--only=").split(","))
	call_deferred("run")

func run() -> void:
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	for n in range(5): await process_frame
	for arena in app.ARENAS:
		if not only.is_empty() and not arena in only: continue
		app.apply_arena(arena)
		app.start_round("autonomous")
		for n in range(170): await process_frame
		await RenderingServer.frame_post_draw
		root.get_viewport().get_texture().get_image().save_png(out_dir.path_join("arena_%s.png" % arena))
		print("CAPTURED ", arena)
	quit()
