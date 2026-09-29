extends SceneTree

func _initialize() -> void:
	var main_scene = load("res://main.tscn").instantiate()
	root.add_child(main_scene)
	
	# Wait for ready and world initialization
	for i in range(10):
		await process_frame

	# Set fighters and arena
	main_scene.apply_arena("blood_moon")
	main_scene.prompts[0].text = "Goku Super Saiyan Kamehameha Dragon Ball"
	main_scene.prompts[1].text = "Vegeta Prinz der Saiyajins Final Flash Galick Gun"
	main_scene.start_round("autonomous")

	# Simulate active fight frames to let particles, auras, lighting and shaders settle
	for f in range(60):
		await process_frame

	var img = root.get_viewport().get_texture().get_image()
	if img:
		img.save_png("res://screenshot_aaa_ingame.png")
		print("INGAME_AAA_SCREENSHOT_SAVED")
	
	quit()
