extends "res://tests/test_base.gd"
## Roster integrity: every selection card yields the fighter it shows, and no player-visible
## text (card name, prompt, fighter name, move names) contains third-party protected terms.

## Lower-case fragments of third-party names and signature moves that must never be shown.
const PROTECTED_TERMS := [
	"goku", "vegeta", "frieza", "freezer", "naruto", "sasuke", "nagato", "luffy", "ruffy", "zoro",
	"tanjiro", "akaza", "saitama", "sonic", "glurak", "charizard", "blue-eyes", "sub-zero",
	"kamehameha", "rasengan", "chidori", "gum-gum", "final flash", "shinra", "hinokami",
	"serious punch", "compass needle", "burst stream", "death beam", "onigiri", "santoryu",
	"smash", "mortal kombat", "pokemon", "pokémon", "yu-gi-oh", "dragon ball", "one piece",
	"kimetsu", "sega", "saiyan", "saiyajin", "akatsuki", "rinnegan", "sharingan", "uchiha", "uzumaki",
]

func _initialize() -> void:
	call_deferred("run")

func find_protected(text: String) -> String:
	var lower := text.to_lower()
	for term in PROTECTED_TERMS:
		if lower.contains(term): return term
	return ""

func run() -> void:
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	await process_frame

	var families_seen := {}
	for preset in app.mk_presets:
		if preset.id == "fusionskammer": continue
		var p: Dictionary = Prompt.interpret(preset.prompt, 0)
		check(p.family == preset.id, "card %s selects its own fighter (got %s)" % [preset.name, p.family])
		check(not families_seen.has(p.family), "card %s is not a duplicate of another card" % preset.name)
		families_seen[p.family] = true
		var visible_text: String = " | ".join([preset.name, preset.prompt, p.name, p.standard.name, p.special.name])
		var term := find_protected(visible_text)
		check(term.is_empty(), "card %s shows no protected term%s" % [preset.name, "" if term.is_empty() else " (found '%s')" % term])

	# Saved prompts from older versions (legacy aliases) still resolve, but display the new names.
	var legacy: Dictionary = Prompt.interpret("Son Goku Super Saiyan Kamehameha Dragon Ball Z", 0)
	check(legacy.family == "goku" and find_protected(legacy.name + legacy.special.name).is_empty(),
		"legacy prompt resolves to the renamed fighter (%s)" % legacy.name)

	app.queue_free()
	await process_frame
	finish("roster")
