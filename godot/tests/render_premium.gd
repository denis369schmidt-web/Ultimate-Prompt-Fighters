extends SceneTree
## Screenshot of the premium shop tab (test mode).
## Usage: godot --path godot --script res://tests/render_premium.gd -- --out=<dir>

var out_dir := "user://"

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): out_dir = arg.trim_prefix("--out=")
	call_deferred("run")

func run() -> void:
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	for k in range(10): await process_frame
	app.show_title("menu")
	app._close_title_panel()
	app.shop_tab = "premium"
	app._open_title_panel("shop")
	for k in range(10): await process_frame
	await RenderingServer.frame_post_draw
	root.get_viewport().get_texture().get_image().save_png(out_dir.path_join("premium_tab.png"))
	print("SHOT premium_tab.png")
	quit()
