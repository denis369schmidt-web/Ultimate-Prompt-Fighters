extends "res://tests/test_base.gd"
## Legends: every fighter has a four-chapter story, chapters open with mastery stars, the last one
## pays the relic, and the relic helps in the adventure. Plays one whole legend on the main scene.

const StoryLegends = preload("res://scripts/story_legends.gd")
const Adventure = preload("res://scripts/adventure.gd")

const STEP_TYPES := ["stage", "title", "narrate", "say", "cam", "move", "pose", "face", "fx", "vanish", "appear", "wait", "fight", "music", "qte", "choice", "branch", "bonds", "set"]

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	app.progression.persist = false
	var story = app.story
	story.persist = false
	story.done_ids = {}
	test_data(app)
	test_unlocking(app, story)
	await test_playthrough(app, story)
	test_adventure_relic()
	app.queue_free()
	await process_frame
	finish("legends")

## Checks every step (also inside branch/choice/qte arms) and returns the possible fight counts
## over all paths through `steps`, sorted and without duplicates.
func _walk(steps: Array, cast: Dictionary, r: Dictionary, id: String) -> Array:
	var counts: Array = [0]
	for s in steps:
		var t: String = str(s.get("t", ""))
		if not t in STEP_TYPES: print("  unknown step ", t, " in ", id); r.ok = false
		if t == "stage": r.stage = s.cast.size()
		if t == "say" and not cast.has(s.who): print("  unknown speaker ", s.who, " in ", id); r.ok = false
		if t in ["move", "pose", "vanish", "appear"] and int(s.who) >= r.stage: print("  slot out of range in ", id); r.ok = false
		var arms: Array = []
		match t:
			"fight":
				arms = [[1]]
				for c in s.cast: if not cast.has(c): print("  unknown fighter ", c, " in ", id); r.ok = false
			"branch", "bonds": arms = [_walk(s.get("steps", []), cast, r, id), _walk(s.get("else", []), cast, r, id)]
			"choice": for o in s.options: arms.append(_walk(o.get("steps", []), cast, r, id))
			"qte": arms = [_walk(s.get("success", []), cast, r, id), _walk(s.get("fail", []), cast, r, id)]
		if arms.is_empty(): continue
		var next: Array = []
		for a in counts:
			for arm in arms:
				for b in arm:
					if not (a + b) in next: next.append(a + b)
		next.sort()
		counts = next
	return counts

func test_data(app) -> void:
	var missing: Array = []
	for p in app.mk_presets:
		if p.id != "fusionskammer" and not StoryLegends.has_legend(str(p.id)): missing.append(p.id)
	check(missing.is_empty(), "every fighter has a legend %s" % [missing])
	var generic: Array = []
	for p in app.mk_presets:
		if p.id != "fusionskammer" and StoryLegends.individual(str(p.id)) == null: generic.append(p.id)
	check(generic.is_empty(), "every fighter has a hand-written legend (scripts/legends) %s" % [generic])
	var ok := true
	var lines := 0
	var ids: Array = app.mk_presets.map(func(p): return str(p.id))
	for fam in StoryLegends.LEGENDS:
		var L: Array = StoryLegends.LEGENDS[fam]
		if not app.ARENAS.has(L[0]): print("  unknown arena ", L[0], " for ", fam); ok = false
		if not str(L[1]) in ids or str(L[1]) == fam: print("  bad rival ", L[1], " for ", fam); ok = false
		if str(load("res://scripts/bosses.gd").data(StoryLegends.boss_of(fam)).get("name", "")) == "": print("  unknown boss for ", fam); ok = false
		for k in range(4, 11):
			if str(L[k]).length() < (5 if k == 6 else 20): print("  short text ", k, " for ", fam); ok = false
			lines += 1
		var cast: Dictionary = StoryLegends.cast(fam, app.mk_presets)
		var chs: Array = StoryLegends.chapters(fam)
		if chs.size() != 4: ok = false
		for ch in chs:
			var r := {"ok": true, "stage": 0}
			var fights: Array = _walk(ch.steps, cast, r, ch.id)
			if not r.ok: ok = false
			if fights != [1]: print("  chapter without exactly one fight on every path: ", ch.id, " ", fights); ok = false
	check(ok, "all legends use real arenas, rivals, bosses, speakers and stage slots; one fight per path through each chapter")
	check(lines >= 49 * 7, "every legend is fully written (%d story lines)" % lines)
	var p: Dictionary = app.Prompt.interpret(StoryLegends.cast("arber", app.mk_presets).hero.prompt, 0)
	check(p.family == "arber", "the hero of a legend is the real fighter")

func test_unlocking(app, story) -> void:
	app.progression.fighter_xp = {}
	story.open_legend("arber")
	check(story.chapters().size() == 4 and story.is_unlocked(0) and not story.is_unlocked(1), "chapter I is open, the rest needs playing")
	story.done_ids["arber_1"] = true
	check(not story.is_unlocked(1), "chapter II needs one mastery star")
	app.progression.fighter_xp["arber"] = app.progression.MASTERY[0]
	check(story.is_unlocked(1) and not story.is_unlocked(2), "one star opens chapter II")
	app.progression.fighter_xp["arber"] = app.progression.MASTERY[2]
	check(not story.is_unlocked(2), "chapters stay in order")
	story.done_ids["arber_2"] = true
	story.done_ids["arber_3"] = true
	check(story.is_unlocked(3), "three stars and the earlier chapters open the legend's end")
	story.set_campaign("legend")
	story.open_menu()
	check(story.menu_list.get_child_count() >= 49, "the legend menu lists every fighter")
	story.close_menu()

func test_playthrough(app, story) -> void:
	story.auto_advance = true
	story.auto_qte_success = true
	story.done_ids = {}
	app.progression.fighter_xp["arber"] = app.progression.MASTERY[2]
	app.progression.legend_relics = {}
	var coins: int = app.progression.coins
	story.open_legend("arber")
	for k in range(4):
		story.start_chapter(k)
		var frames := 0
		var fights := 0
		while story.running and frames < 4000:
			await process_frame
			frames += 1
			if story.in_fight:
				fights += 1
				story.on_fight_finished(0)
		check(not story.running and story.is_done(k) and fights == 1, "Arbër chapter %d plays through with its fight" % (k + 1))
	check(app.progression.legend_relics.has("arber") and app.progression.coins >= coins + StoryLegends.RELIC_COINS, "the finished legend pays the relic and coins")
	check(not app.progression.grant_legend("arber", 400), "the relic is given only once")
	story.auto_advance = false

func test_adventure_relic() -> void:
	var a := Adventure.new()
	a.start({"id": "arber", "prompt": "Arbër"}, [{"id": "zip", "prompt": "Zip"}], 1)
	a.win_wave(50.0, 100.0, 0)
	var plain: float = a.damage
	var b := Adventure.new()
	b.start({"id": "arber", "prompt": "Arbër"}, [{"id": "zip", "prompt": "Zip"}], 1)
	b.relic = true
	b.win_wave(50.0, 100.0, 0)
	check(b.damage < plain, "with the relic more damage heals between waves (%.0f vs %.0f %%)" % [b.damage, plain])
	check(a.is_milestone(10) and not a.is_milestone(9), "every tenth wave is a milestone")
