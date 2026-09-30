extends "res://tests/test_base.gd"
## Story campaign "Die göttliche Prüfung": content integrity (cast, arenas, bosses, QTE keys),
## realm unlocking, every boss body builds, and a full playthrough of all chapters on the main scene.

const StoryDivina = preload("res://scripts/story_divina.gd")
const StoryMode = preload("res://scripts/story_mode.gd")
const Bosses = preload("res://scripts/bosses.gd")
const BossModels = preload("res://scripts/boss_models.gd")
const FighterView = preload("res://scripts/fighter_view.gd")
const QTE_KEYS := ["jump", "standard", "special", "grab", "block"]

func _initialize() -> void:
	call_deferred("run")

func walk(steps: Array, out: Array) -> void:
	for s in steps:
		out.append(s)
		walk(s.get("success", []), out)
		walk(s.get("fail", []), out)

func run() -> void:
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	var story = app.story
	story.persist = false
	story.done_ids = {}
	test_bosses_and_models()
	test_data(app)
	test_unlocking(story)
	await test_playthrough(app, story)
	app.queue_free()
	await process_frame
	finish("divina")

func test_bosses_and_models() -> void:
	check(Bosses.HEAVEN.size() == 9 and Bosses.HELL.size() == 10, "nine choirs of heaven and ten princes of hell")
	var ok := true
	for bid in Bosses.ORDER:
		var b: Dictionary = Bosses.data(bid)
		for phase in b.patterns:
			for pat in phase: if Bosses.pattern(pat).is_empty():
				ok = false
				print("  missing pattern ", pat, " for ", bid)
		var view = FighterView.new()
		root.add_child(view)
		view.setup(Bosses.profile(bid, 2))
		var meshes: int = view.find_children("*", "MeshInstance3D", true, false).size()
		var sculpted: bool = view.has_meta("boss_body")
		check(meshes > (3 if sculpted else 25) and (sculpted == b.has("body")), "%s has its body (%s, %d parts)" % [bid, "sculpted" if sculpted else "procedural", meshes])
		view.free()
	check(ok, "every boss pattern exists in the pattern table")

func test_data(app) -> void:
	var list: Array = StoryDivina.all()
	check(list.size() == 21, "the journey has 21 chapters (prolog, 10 hell, 10 heaven)")
	var realms := {}
	for ch in list: realms[ch.realm] = realms.get(ch.realm, 0) + 1
	check(realms.get("earth", 0) == 1 and realms.get("hell", 0) == 10 and realms.get("heaven", 0) == 10, "realms: earth 1, hell 10, heaven 10 (%s)" % [realms])
	var bosses_met := {}
	var ok := true
	for ch in list:
		ok = ok and app.ARENAS.has(ch.arena)
		var all: Array = []
		walk(ch.steps, all)
		var stage_size := 0
		for s in all:
			match s.t:
				"stage":
					stage_size = s.cast.size()
					for c in s.cast: ok = ok and StoryDivina.CAST.has(c.id)
				"say": ok = ok and StoryDivina.CAST.has(s.who)
				"cam", "move", "pose", "vanish", "appear": if s.has("who"): ok = ok and int(s.who) < stage_size
				"qte": for k in s.keys: ok = ok and k in QTE_KEYS
				"fight":
					for id in s.cast:
						ok = ok and StoryDivina.CAST.has(id)
						if StoryDivina.CAST[id].has("boss"): bosses_met[StoryDivina.CAST[id].boss] = true
		if not ok:
			print("  invalid chapter ", ch.id)
			break
	check(ok, "every chapter references existing arenas, cast members, stage slots and QTE keys")
	check(bosses_met.size() == Bosses.ORDER.size(), "every one of the 19 bosses is fought in the story (%d)" % bosses_met.size())
	for id in ["dante", "vergil", "beatrice"]:
		check(Prompt.valid(StoryMode.cast_profile(id, 0)), "%s is a valid fighter" % id)
	check(StoryMode.cast_profile("lucifer", 2, 2).get("boss", "") == "lucifer", "boss cast members become bosses")

func test_unlocking(story) -> void:
	story.set_campaign("divina")
	var list: Array = story.chapters()
	var hell_first: int = story._realm_target("hell")
	var heaven_first: int = story._realm_target("heaven")
	check(story.is_unlocked(0) and story.is_unlocked(hell_first) and story.is_unlocked(heaven_first), "prolog, hell and heaven can be started right away")
	check(not story.is_unlocked(hell_first + 1) and not story.is_unlocked(heaven_first + 1), "later chapters are locked")
	story.done_ids[list[hell_first].id] = true
	check(story.is_unlocked(hell_first + 1) and story._realm_target("hell") == hell_first + 1, "finishing a chapter opens the next one of its realm")
	story.done_ids = {}

func test_playthrough(app, story) -> void:
	story.set_campaign("divina")
	story.auto_advance = true
	story.auto_qte_success = true
	var list: Array = story.chapters()
	var boss_fights := 0
	for k in range(list.size()):
		story.start_chapter(k)
		var frames := 0
		var fights := 0
		while story.running and frames < 4000:
			await process_frame
			frames += 1
			if story.in_fight:
				fights += 1
				for f in app.sim.fighters: if f.is_boss: boss_fights += 1
				story.on_fight_finished(0)
		check(not story.running and story.is_done(k), "%s plays through (%d fights)" % [list[k].id, fights])
	check(boss_fights >= 19, "all boss fights ran (%d)" % boss_fights)
	check(story.continue_index() == list.size() - 1 and app.selection.visible, "after the epilogue the game returns to the selection screen")
	story.set_campaign("zeile")
