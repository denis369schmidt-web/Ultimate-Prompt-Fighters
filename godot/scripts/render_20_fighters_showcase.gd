extends SceneTree

func _initialize():
	render_showcases()

func render_showcases() -> void:
	print("--- RENDERING 20-FIGHTER ROSTER & COMBAT SHOWCASES ---")
	var main_scene = load("res://main.tscn").instantiate()
	root.add_child(main_scene)
	
	# Wait for ready
	for f in range(10): await process_frame

	# 1. MORTAL KOMBAT 20 ROSTER SELECT SCREEN
	main_scene.show_selection()
	for f in range(25): await process_frame
	
	var img = root.get_viewport().get_texture().get_image()
	if img:
		img.save_png("res://screenshot_mortal_kombat_20_select.png")
		print("SAVED: screenshot_mortal_kombat_20_select.png")

	# 2. COMBAT SHOWCASE: NARUTO VS SASUKE
	print("--- Starting Naruto vs Sasuke Match ---")
	main_scene.prompts[0].text = "Naruto Uzumaki Rasengan Konoha Stirnband Kyuubi Sage Mode"
	main_scene.prompts[1].text = "Sasuke Uchiha Chidori Sharingan Kusanagi Shimenawa Blitz"
	main_scene.start_round("autonomous")
	
	for f in range(80):
		await process_frame
		
	var img2 = root.get_viewport().get_texture().get_image()
	if img2:
		img2.save_png("res://screenshot_naruto_vs_sasuke.png")
		print("SAVED: screenshot_naruto_vs_sasuke.png")

	# 3. COMBAT SHOWCASE: SAITAMA VS VEGETA
	print("--- Starting Saitama vs Vegeta Match ---")
	main_scene.prompts[0].text = "Saitama One Punch Man Serious Punch Caped Baldy Hero"
	main_scene.prompts[1].text = "Prinz Vegeta Saiyajin Royal Armor Final Flash Galick Gun"
	main_scene.start_round("autonomous")

	for f in range(80):
		await process_frame

	var img3 = root.get_viewport().get_texture().get_image()
	if img3:
		img3.save_png("res://screenshot_saitama_vs_vegeta.png")
		print("SAVED: screenshot_saitama_vs_vegeta.png")

	print("=== ALL 20-FIGHTER SHOWCASES RENDERED SUCCESSFULLY! ===")
	quit(0)
