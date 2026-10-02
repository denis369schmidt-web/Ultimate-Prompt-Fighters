extends SceneTree
## Screenshots of real fights in several arenas (quality check) plus the main menu.
## Usage: godot --path godot --script res://tests/render_fight.gd -- --out=<dir> [--prefix=after]

var out_dir := "user://"
var prefix := "fight"
const SETUPS := [["kairo", "albion", "blood_moon"], ["pyrax", "glaciem", "volcano_sanctum"], ["raiga", "ren", "imperial_colosseum"], ["zip", "oryn", "frozen_summit"]]

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): out_dir = arg.trim_prefix("--out=")
		if arg.begins_with("--prefix="): prefix = arg.trim_prefix("--prefix=")
	call_deferred("run")

func shot(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_viewport().get_texture().get_image().save_png(out_dir.path_join("%s_%s.png" % [prefix, name]))
	print("SHOT ", name)

func preset_index(app, id: String) -> int:
	for k in range(app.mk_presets.size()):
		if app.mk_presets[k].id == id: return k
	return 0

func run() -> void:
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	for k in range(10): await process_frame
	app.show_title("menu")
	app._close_title_panel()
	for k in range(10): await process_frame
	await shot("menu")
	app.hide_title()
	for s in SETUPS:
		app.on_mk_fighter_selected(0, preset_index(app, s[0]))
		app.on_mk_fighter_selected(1, preset_index(app, s[1]))
		if app.ARENAS.has(s[2]): app.apply_arena(s[2])
		app.start_round("autonomous")
		for k in range(240): await process_frame
		await shot("%s_%s" % [s[0], app.current_arena])
		app.show_selection()
		for k in range(5): await process_frame
	quit()
