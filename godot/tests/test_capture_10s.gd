extends SceneTree
## 10-second test recording script for Phase 0 verification.
## 600 frames @ 60 FPS = exactly 10.0 seconds with audio and video.

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	print("TEST_CAPTURE_INIT: Starting 10-second test recording...")
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	
	# Start match with music and sound
	var Prompt = load("res://scripts/prompt_interpreter.gd")
	var f1 = Prompt.interpret("Cyber Lightning Ninja", 0)
	var f2 = Prompt.interpret("Magma Golem", 1)
	app.begin_match([f1, f2], "autonomous", 3)
	if app.ARENAS.has("astral_nexus"):
		app.apply_arena("astral_nexus")
	app.sim.countdown = 0.0
	
	for i in range(600):
		if i % 40 == 0:
			app.sim.queue_attack(i % 2, (i % 80 == 0))
		await process_frame
		
	print("TEST_CAPTURE_DONE: 600 frames rendered!")
	quit(0)
