extends SceneTree
## Renders story mode screenshots (title, dialogue, QTE, story fight) for visual review.
## Usage: godot --path godot --script res://tests/render_story.gd -- --out=<dir> [--chapter=N]

var out_dir := "user://"
var chapter := 0

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): out_dir = arg.trim_prefix("--out=")
		if arg.begins_with("--chapter="): chapter = int(arg.trim_prefix("--chapter="))
	call_deferred("run")

func shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_viewport().get_texture().get_image().save_png(out_dir.path_join(name))
	print("CAPTURED ", name)

func frames(n: int) -> void:
	for k in range(n): await process_frame

func run() -> void:
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	await frames(10)
	var story = app.story
	story.persist = false
	story.open_menu()
	await frames(10)
	await shot("story_menu.png")
	story.start_chapter(chapter)
	await frames(95)
	await shot("story_title.png")
	var dialogs := 0
	var qte_done := false
	var guard := 0
	while story.running and not story.in_fight and guard < 4000:
		guard += 1
		await process_frame
		if story.qte_active and not qte_done:
			await frames(25)
			await shot("story_qte.png")
			story.qte_press(story.qte.keys[story.qte.index])
			while story.qte_active: story.qte_press(story.qte.keys[mini(story.qte.index, story.qte.keys.size() - 1)])
			qte_done = true
		elif story.dialog_panel.visible and not story.typing:
			dialogs += 1
			if dialogs in [2, 4]: await shot("story_dialog_%d.png" % dialogs)
			story.advanced.emit()
		elif story.narrate_label.modulate.a > 0.95:
			if dialogs == 0: await shot("story_narrate.png")
			story.advanced.emit()
	await frames(150)
	await shot("story_fight.png")
	quit()
