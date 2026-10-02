extends "res://tests/test_base.gd"
## Saga "Der Riss zwischen den Welten": content integrity (cast, arenas, stage slots, step types),
## open act II, decisions and bonds, all three endings, and a full playthrough on the real main scene.

const StorySaga = preload("res://scripts/story_saga.gd")
const StoryMode = preload("res://scripts/story_mode.gd")

const STEP_TYPES := ["stage", "title", "narrate", "say", "cam", "move", "pose", "face", "fx", "vanish", "appear", "wait",
	"qte", "fight", "credits", "music", "set", "choice", "branch", "bonds"]

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	var story = app.story
	story.persist = false
	story.flags = {}
	story.done_ids = {}
	story.set_campaign("saga")
	test_data(app)
	test_unlocking(story)
	await test_playthrough(app, story)
	await test_endings(app, story)
	app.queue_free()
	await process_frame
	finish("saga")

## Every step of a chapter, including nested choice/branch/bonds/QTE steps.
func walk(steps: Array, out: Array) -> void:
	for s in steps:
		out.append(s)
		walk(s.get("success", []), out)
		walk(s.get("fail", []), out)
		walk(s.get("steps", []), out)
		walk(s.get("else", []), out)
		for o in s.get("options", []): walk(o.get("steps", []), out)

func test_data(app) -> void:
	var list: Array = StorySaga.chapters()
	check(list.size() >= 14, "the saga has a prologue, three acts and an epilogue (%d chapters)" % list.size())
	var ids := {}
	for ch in list: ids[ch.id] = true
	var ok := true
	var lines := 0
	var fights := 0
	var choices := 0
	for ch in list:
		if not app.ARENAS.has(ch.arena):
			print("  unknown arena ", ch.arena)
			ok = false
		for req in ch.requires:
			if not ids.has(req): ok = false
		var stage_size := 0
		var all: Array = []
		walk(ch.steps, all)
		for s in all:
			var t: String = str(s.get("t", ""))
			if not t in STEP_TYPES:
				print("  unknown step ", t, " in ", ch.id)
				ok = false
			if t == "stage": stage_size = s.cast.size()
			if t in ["say"]:
				lines += 1
				if not StorySaga.CAST.has(s.who):
					print("  unknown speaker ", s.who)
					ok = false
				if str(s.text).length() > 160: print("  long line (%d) in %s" % [str(s.text).length(), ch.id])
			if t == "narrate": lines += 1
			if t in ["move", "pose", "vanish", "appear"] and int(s.who) >= stage_size:
				print("  stage slot ", s.who, " out of range in ", ch.id)
				ok = false
			if t == "fight":
				fights += 1
				for id in s.cast: if not StorySaga.CAST.has(id): ok = false
			if t == "choice": choices += 1
	check(ok, "every chapter references existing arenas, chapters, speakers, stage slots and step types")
	check(lines >= 180, "the saga is fully written out (%d lines)" % lines)
	check(fights >= 13 and choices >= 5, "fights in every chapter and real decisions (%d fights, %d choices)" % [fights, choices])
	for id in StorySaga.CAST:
		var c: Dictionary = StorySaga.CAST[id]
		if c.has("boss") or str(c.prompt).is_empty(): continue
		check(Prompt.valid(StoryMode.cast_profile(id, 0)), "%s is a valid fighter" % id)
	check(StoryMode.voice_path("volt", "Hallo") == StoryMode.voice_path("volt", "Hallo") and StoryMode.voice_path("volt", "Hallo") != StoryMode.voice_path("nova", "Hallo"),
		"voice files are keyed by speaker and text")

func test_unlocking(story) -> void:
	var list: Array = story.chapters()
	var idx := {}
	for k in range(list.size()): idx[list[k].id] = k
	check(story.is_unlocked(idx.s0) and not story.is_unlocked(idx.s1), "only the prologue is open at the start")
	for id in ["s0", "s1", "s2"]: story.done_ids[id] = true
	var open_worlds := 0
	for id in ["s3", "s5", "s6", "s7", "s8", "s9"]: if story.is_unlocked(idx[id]): open_worlds += 1
	check(open_worlds == 6 and not story.is_unlocked(idx.s4), "after act I all worlds of act II are open at once, Zip's chapter waits for Glaciem's")
	check(not story.is_unlocked(idx.s10), "act III needs every world of act II")
	story.done_ids = {}

func test_playthrough(app, story) -> void:
	story.auto_advance = true
	story.auto_qte_success = true
	var list: Array = story.chapters()
	var total_fights := 0
	for k in range(list.size()):
		story.start_chapter(k)
		var frames := 0
		var fights := 0
		while story.running and frames < 4000:
			await process_frame
			frames += 1
			if story.in_fight:
				fights += 1
				story.on_fight_finished(0)
		total_fights += fights
		check(not story.running and story.is_done(k), "%s „%s“ plays through (%d fights)" % [list[k].id, list[k].title, fights])
	check(total_fights >= 13, "every chapter before the epilogue has its fight (%d)" % total_fights)
	check(story.bond_count() >= 8, "healing everyone wins them as allies (%d bonds)" % story.bond_count())
	check(story.flags.get("ending_true", false), "with (almost) everyone at your side the true ending plays")
	check(app.selection.visible and not app.cinematic, "after the credits the game returns to the selection screen")

func test_endings(app, story) -> void:
	var list: Array = story.chapters()
	var epilog: int = list.size() - 1
	for case in [["end_aria", "ending_aria"], ["end_worlds", "ending_worlds"]]:
		story.flags = {case[0]: true, "bond_bruno": true}
		story.start_chapter(epilog)
		var frames := 0
		while story.running and frames < 3000:
			await process_frame
			frames += 1
		check(story.flags.get(case[1], false) and not story.flags.get("ending_true", false),
			"with few allies the decision decides the ending (%s)" % case[1])
	story.flags = {}
	story.auto_advance = false
