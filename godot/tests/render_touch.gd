extends SceneTree
## Screenshot of a fight with the touch controls in the phone profile (menu, fight, pause).
## Usage: godot --path godot --script res://tests/render_touch.gd -- --out=<dir>

const Platform = preload("res://scripts/platform.gd")
var out_dir := "user://"

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): out_dir = arg.trim_prefix("--out=")
	call_deferred("run")

func shot(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_viewport().get_texture().get_image().save_png(out_dir.path_join(name))
	print("SHOT ", name)

func run() -> void:
	Platform.forced = "mobile"
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	for k in range(10): await process_frame
	app.hide_title()
	for k in range(5): await process_frame
	await shot("touch_menu.png")
	app.start_round("pve")
	for k in range(200): await process_frame
	# Show a held button and the stick in use.
	app.touch.stick_touch = 9
	app.touch.stick_base = Vector2(200, 540)
	app.touch._set_stick(Vector2(60, -20))
	app.touch.pressed_buttons["attack"] = true
	app.touch.queue_redraw()
	await shot("touch_fight.png")
	app.touch.release_all()
	app.paused = true
	for k in range(5): await process_frame
	await shot("touch_pause.png")
	quit()
