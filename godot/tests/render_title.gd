extends SceneTree
## Screenshots of the start screen (splash and main menu) with the live arena behind it.
## Usage: godot --path godot --script res://tests/render_title.gd -- --out=<dir> [--bg=neon_alley]

var out_dir := "user://"
var bg_id := ""

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): out_dir = arg.trim_prefix("--out=")
		if arg.begins_with("--bg="): bg_id = arg.trim_prefix("--bg=")
	call_deferred("run")

func shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_viewport().get_texture().get_image().save_png(out_dir.path_join("title_%s.png" % name))
	print("CAPTURED ", name)

func run() -> void:
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	for n in range(5): await process_frame
	if bg_id != "":
		app.progression.unlocked[bg_id] = true
		app.progression.menu_bg = bg_id
	app.show_title("splash")
	for n in range(60): await process_frame
	await shot("splash")
	app._enter_main_menu()
	await process_frame
	await process_frame
	if app.title_panel != null:
		app._close_title_panel()
	for n in range(60): await process_frame
	await shot("menu")
	quit()
