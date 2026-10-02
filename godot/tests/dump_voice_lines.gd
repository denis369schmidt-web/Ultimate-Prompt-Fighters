extends SceneTree
## Writes every spoken line of the saga (speaker, text, voice, target file) as JSON for
## tools/voice_lines.py. Usage: godot --headless --path godot -s tests/dump_voice_lines.gd -- --out=<file.json>

const StorySaga = preload("res://scripts/story_saga.gd")
const StoryMode = preload("res://scripts/story_mode.gd")

var lines: Array = []
var seen := {}

func _initialize() -> void:
	var out := "user://voice_lines.json"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): out = arg.trim_prefix("--out=")
	for ch in StorySaga.chapters(): _walk(ch.steps)
	var f := FileAccess.open(out, FileAccess.WRITE)
	f.store_string(JSON.stringify(lines, "  "))
	f.close()
	print("PFU_VOICE_LINES ", lines.size(), " -> ", out)
	quit()

func _add(who: String, text: String) -> void:
	var path: String = StoryMode.voice_path(who, text)
	if seen.has(path): return
	seen[path] = true
	var c: Dictionary = StorySaga.CAST.get(who, StorySaga.CAST.erzaehler)
	lines.append({"who": who, "text": text, "voice": c.get("voice", {}), "file": path.get_file()})

func _walk(steps: Array) -> void:
	for s in steps:
		match str(s.get("t", "")):
			"say": _add(str(s.who), str(s.text))
			"narrate": _add("erzaehler", str(s.text))
		_walk(s.get("success", []))
		_walk(s.get("fail", []))
		_walk(s.get("steps", []))
		_walk(s.get("else", []))
		for o in s.get("options", []): _walk(o.get("steps", []))
