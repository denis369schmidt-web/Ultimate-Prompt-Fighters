extends SceneTree
## Screenshots of every menu screen for UI reviews: title, selection, shop tabs, options,
## extras, boss menu, story menu, fight HUD, pause, result and the controller focus frame.
## Usage: godot --path godot --resolution 1600x900 --script res://tests/render_ui.gd -- --out=<dir> --capture-selection [--only=title,shop]

var out_dir := "user://"
var only: Array = []

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): out_dir = arg.trim_prefix("--out=")
		if arg.begins_with("--only="): only = arg.trim_prefix("--only=").split(",")
	call_deferred("run")

func frames(n: int) -> void:
	for k in range(n): await process_frame

func want(name: String) -> bool:
	return only.is_empty() or only.has(name)

func shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_viewport().get_texture().get_image().save_png(out_dir.path_join(name + ".png"))
	print("CAPTURED ", name)

func run() -> void:
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	await frames(10)
	app.progression.coins = 4321
	if want("selection"):
		await frames(20)
		await shot("selection")
		app.on_mk_fighter_selected(1, 7)
		await frames(10)
		await shot("selection_p2")
	if want("boss"):
		app.open_boss_menu()
		await frames(6)
		await shot("boss_menu")
		app.close_boss_menu()
	if want("title"):
		app.show_title("splash")
		await frames(30)
		await shot("title_splash")
		app._enter_main_menu()
		await frames(30)
		await shot("title_menu")
		app.title_index = 3
		app._layout_title()
		await frames(12)
		await shot("title_menu_extras")
	if want("shop"):
		app.show_title("menu")
		await frames(10)
		for tab in ["backgrounds", "weapons", "skins"]:
			app.shop_tab = tab
			app._open_title_panel("shop")
			await frames(16)
			if tab == "backgrounds":
				app._nav_pad(JOY_BUTTON_DPAD_DOWN, app.title_panel)
				app._nav_pad(JOY_BUTTON_DPAD_RIGHT, app.title_panel)
				await frames(16)
			await shot("shop_" + tab)
		for kind in ["options", "extras", "adventure", "daily", "path", "credits"]:
			app._open_title_panel(kind)
			await frames(16)
			await shot("panel_" + kind)
		app._close_title_panel()
		await frames(10)
	if want("story"):
		app.show_title("menu")
		await frames(4)
		app.hide_title()
		app.story.open_menu()
		await frames(16)
		await shot("story_menu")
		app.story.menu_panel.hide()
		app.show_selection()
		await frames(4)
	if want("fight"):
		app.hide_title()
		app.start_round("autonomous")
		await frames(160)
		await shot("fight_hud")
		app.paused = true
		await frames(6)
		await shot("fight_pause")
		app.paused = false
		app.result_label.text = app.winner_text() if app.sim.result >= 0 else "SPIELER 1 GEWINNT!"
		app.result_panel.show()
		await frames(16)
		await shot("result")
	quit()
