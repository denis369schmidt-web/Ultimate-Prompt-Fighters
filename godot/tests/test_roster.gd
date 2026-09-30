extends "res://tests/test_base.gd"
## Roster integrity: every selection card yields the fighter it shows, and no player-visible
## text (card name, prompt, fighter name, move names) contains third-party protected terms.

## Lower-case fragments of third-party names and signature moves that must never be shown.
const HeroGear = preload("res://scripts/hero_gear.gd")
const FighterView = preload("res://scripts/fighter_view.gd")

const PROTECTED_TERMS := [
	"goku", "vegeta", "frieza", "freezer", "naruto", "sasuke", "nagato", "luffy", "ruffy", "zoro",
	"tanjiro", "akaza", "saitama", "sonic", "glurak", "charizard", "blue-eyes", "sub-zero",
	"kamehameha", "rasengan", "chidori", "gum-gum", "final flash", "shinra", "hinokami",
	"serious punch", "compass needle", "burst stream", "death beam", "onigiri", "santoryu",
	"smash", "mortal kombat", "pokemon", "pokémon", "yu-gi-oh", "dragon ball", "one piece",
	"kimetsu", "sega", "saiyan", "saiyajin", "akatsuki", "rinnegan", "sharingan", "uchiha", "uzumaki",
	"viera", "final fantasy", "lin kuei", "kaiba", "hokage",
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

	# Third-party names no longer act as shortcuts to the house heroes.
	for foreign in ["Son Goku Super Saiyan Kamehameha Dragon Ball Z", "Naruto Uzumaki Rasengan", "Sonic the Hedgehog Spin Dash",
			"Monkey D. Luffy Gum-Gum", "Fran Viera Final Fantasy", "Glurak Pokemon", "Sub-Zero Lin Kuei"]:
		var fp: Dictionary = Prompt.interpret(foreign, 0)
		check(not HeroGear.has_hero(str(fp.family)), "'%s' does not select a house hero (got %s)" % [foreign, fp.family])
		check(find_protected(str(fp.family)).is_empty(), "'%s' maps to no protected family id" % foreign)

	# Every house hero wears its own generated outfit and gear.
	for fam in HeroGear.HEROES:
		check(find_protected(fam).is_empty(), "hero id %s is not a protected term" % fam)
	for preset in app.mk_presets:
		if not HeroGear.has_hero(str(preset.id)): continue
		var hp: Dictionary = Prompt.interpret(preset.prompt, 0)
		hp.slot = 0
		var v = FighterView.new()
		root.add_child(v)
		v.setup(hp)
		var gear = v.hero_gear
		check(gear != null and gear.body_mats.size() > 0, "%s wears the recolored outfit" % preset.id)
		var parts := 0
		if gear != null:
			for n in v.find_children("*", "MeshInstance3D", true, false):
				if n.has_meta("gear"): parts += 1
		check(parts >= 3, "%s has its own gear (%d parts)" % [preset.id, parts])
		v.update_state({"x": 0.0, "y": 0.0, "facing": 1, "pose": "Charge", "state": "Attack", "blocking": false}, 0.016)
		v.flash()
		v.queue_free()

	app.queue_free()
	await process_frame
	finish("roster")
