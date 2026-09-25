extends SceneTree

func _initialize():
	render_select()

func render_select() -> void:
	print("--- Rendering Mortal Kombat 14 Select Grid ---")
	var main_scene = load("res://main.tscn").instantiate()
	root.add_child(main_scene)
	
	# Wait for _ready to execute
	await process_frame
	await process_frame

	main_scene.show_selection()

	for f in range(25):
		await process_frame

	var img = root.get_viewport().get_texture().get_image()
	if img:
		img.save_png("res://screenshot_mortal_kombat_14_select.png")
		print("SAVED: screenshot_mortal_kombat_14_select.png")

	print("=== MORTAL KOMBAT 14 SELECT RENDERED! ===")
	quit(0)
