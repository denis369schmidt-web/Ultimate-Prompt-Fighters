extends SceneTree
## Screenshot of the fighter selection screen.
## Usage: godot --path godot --script res://tests/render_selection.gd -- --out=<file.png>
var out_file := "user://selection.png"
func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): out_file = arg.trim_prefix("--out=")
	call_deferred("run")
func run() -> void:
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	for n in range(40): await process_frame
	await RenderingServer.frame_post_draw
	root.get_viewport().get_texture().get_image().save_png(out_file)
	quit()
