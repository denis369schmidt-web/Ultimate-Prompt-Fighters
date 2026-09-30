extends SceneTree
## Visual check of the start screen, the shop and every shop arena.
## Usage: godot --path godot --script res://tests/render_shop.gd -- --out=<dir>

const Backgrounds = preload("res://scripts/backgrounds.gd")

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
	app.show_title("splash")
	await frames(6)
	await shot("title_0_splash.png")
	for id in ["neon_alley", "colosseum_dusk", "dojo", "storm_roof"]:
		app.progression.unlocked[id] = true
		app.progression.menu_bg = id
		app.show_title("menu")
		app.title_index = 1
		await frames(4)
		app._layout_title()
		await frames(2)
		await shot("title_%s.png" % id)
	app.progression.coins = 1234
	app._open_title_panel("shop")
	await frames(2)
	app._nav_pad(JOY_BUTTON_DPAD_DOWN, app.title_panel)
	app._nav_pad(JOY_BUTTON_DPAD_RIGHT, app.title_panel)
	await frames(3)
	await shot("shop.png")
	app._close_title_panel()
	app.hide_title()
	for bg in Backgrounds.LIST.filter(func(b): return b.id in ["neon_alley", "holo_city", "orbital_ring", "rain_rooftop", "night_market", "graffiti_alley"]):
		app.apply_arena(Backgrounds.arena_id(bg))
		app.start_round("autonomous")
		await frames(200)
		await shot("arena_%02d_%s.png" % [Backgrounds.LIST.find(bg) + 1, bg.id])
		app.show_selection()
		await frames(3)
	quit()
