extends SceneTree

func _initialize() -> void:
	var main_scene = load("res://main.tscn").instantiate()
	root.add_child(main_scene)
	
	# Wait for selection screen, 3D idle models and UI
	for i in range(25):
		await process_frame

	var img_select = root.get_viewport().get_texture().get_image()
	if img_select:
		img_select.save_png("res://screenshot_mk1_selection_screen.png")
		print("MK1_SELECTION_SCREENSHOT_SAVED")

	# Select new Mixamo fighters
	main_scene.apply_arena("imperial_colosseum")
	main_scene.prompts[0].text = "Stahlritter Paladin Steel Knight"
	main_scene.prompts[1].text = "Cyber Vanguard Soldat Blaster"
	main_scene.start_round("autonomous")

	# Wait for combat action
	for f in range(50):
		await process_frame

	var img_fight = root.get_viewport().get_texture().get_image()
	if img_fight:
		img_fight.save_png("res://screenshot_new_fighters_fight.png")
		print("NEW_FIGHTERS_FIGHT_SCREENSHOT_SAVED")
	
	quit()
