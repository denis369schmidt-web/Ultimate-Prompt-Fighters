extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	print("RECORDING_START")
	for i in range(120):
		await process_frame
	print("RECORDING_DONE")
	quit(0)
