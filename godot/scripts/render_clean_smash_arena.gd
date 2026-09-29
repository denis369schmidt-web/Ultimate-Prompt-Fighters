extends SceneTree

func _initialize():
	render_showcase()

func render_showcase() -> void:
	print("--- RENDERING CLEAN SMASH ARENA & SELECT SCREEN ---")
	var main_scene = load("res://main.tscn").instantiate()
	root.add_child(main_scene)

	for f in range(15):
		await process_frame

	main_scene.player_count = 4
	main_scene.apply_arena("blood_moon")

	# Select 4 fighters
	main_scene.on_mk_fighter_selected(0, 37) # Mutant Titan
	main_scene.on_mk_fighter_selected(1, 34) # Vanguard Soldier
	main_scene.on_mk_fighter_selected(2, 39) # Samurai Dreyar
	main_scene.on_mk_fighter_selected(3, 41) # Vampire Lord Vlad

	# Capture selection screen first
	for f in range(25):
		await process_frame

	var img_sel = root.get_viewport().get_texture().get_image()
	if img_sel:
		img_sel.save_png("res://screenshot_smash_selection_45.png")
		print("SAVED: screenshot_smash_selection_45.png")

	# Start round
	main_scene.start_round("pve")

	for f in range(25):
		await process_frame

	if main_scene.sim.fighters.size() >= 4:
		main_scene.sim.fighters[0].damage_percent = 24.0
		main_scene.sim.fighters[1].damage_percent = 132.0
		main_scene.sim.fighters[1].lives = 2
		main_scene.sim.fighters[2].damage_percent = 65.0
		main_scene.sim.fighters[3].damage_percent = 168.0
		main_scene.sim.fighters[3].lives = 1

	for f in range(40):
		await process_frame

	var img = root.get_viewport().get_texture().get_image()
	if img:
		img.save_png("res://screenshot_smash_clean_4player.png")
		print("SAVED: screenshot_smash_clean_4player.png")

	quit(0)
