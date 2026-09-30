extends SceneTree
## Visual check of shop tabs, extras panels and skins on fighters.
## Usage: godot --path godot --script res://tests/render_rewards.gd -- --out=<dir>

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
	await frames(8)
	app.progression.coins = 4321
	app.progression.xp = 2600
	app.progression.chests = 2
	app.show_title("menu")
	for tab in ["weapons", "skins", "chest"]:
		app.shop_tab = tab
		app._open_title_panel("shop")
		await frames(3)
		await shot("r_shop_%s.png" % tab)
	for panel in ["extras", "daily", "path"]:
		app._open_title_panel(panel)
		await frames(3)
		await shot("r_%s.png" % panel)
	app._close_title_panel()
	app.hide_title()
	for look in ["gold", "obsidian", "galaxy", "crystal", "neon", "celestial"]:
		app.progression.skins_owned[look] = true
		app.progression.skin = look
		app.start_round("autonomous")
		await frames(60)
		var f: Dictionary = app.sim.fighters[0]
		app.cinematic = true
		app.camera.global_position = Vector3(f.x + 0.6, f.y + 1.3, 3.4)
		app.camera.look_at(Vector3(f.x, f.y + 1.0, 0))
		await frames(2)
		await shot("r_skin_%s.png" % look)
		app.cinematic = false
		app.show_selection()
	quit()
