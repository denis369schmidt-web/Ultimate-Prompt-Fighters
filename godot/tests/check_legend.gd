extends "res://tests/test_base.gd"
## Checks one hand-written legend (scripts/legends/legend_<id>.gd) and plays it through.
## Usage: godot --headless --path godot -s tests/check_legend.gd -- --fam=arber
## Prints FAIL lines with the reason and PFU_TEST_SUMMARY suite=legend_<id>.

const StoryLegends = preload("res://scripts/story_legends.gd")
const STEP_TYPES := ["stage", "title", "narrate", "say", "cam", "move", "pose", "face", "fx", "vanish", "appear", "wait",
	"qte", "fight", "music", "set", "choice", "branch"]
const SHOTS := ["wide", "sky", "close", "low", "two"]
const FX := ["flash", "shake", "burst", "ink"]
const MOODS := ["calm", "sad", "hope", "tense", "fight", "boss", "boss_final"]
const POSES := ["Idle", "Victory", "HitReact", "Attack", "Kick", "HeavyPunch", "Charge", "Beam", "Summon", "Cast", "Slam", "Spin",
	"Dash", "Rise", "Block", "Counter", "Dodge", "Roar", "Crouch", "Barrage", "SpecialAttack", "Defeat", "Dazed"]

var fam := ""

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--fam="): fam = arg.trim_prefix("--fam=")
	call_deferred("run")

func walk(steps: Array, out: Array) -> void:
	for s in steps:
		out.append(s)
		walk(s.get("success", []), out)
		walk(s.get("fail", []), out)
		walk(s.get("steps", []), out)
		walk(s.get("else", []), out)
		for o in s.get("options", []): walk(o.get("steps", []), out)

func run() -> void:
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	app.progression.persist = false
	var ind = StoryLegends.individual(fam)
	check(ind != null, "scripts/legends/legend_%s.gd exists and parses" % fam)
	if ind == null:
		finish("legend_" + fam)
		return
	var ids: Array = app.mk_presets.map(func(p): return str(p.id))
	check(fam in ids, "%s is a roster fighter" % fam)
	for key in ["epithet", "summary", "relic", "relic_text"]:
		check(str(ind.INFO.get(key, "")).length() >= 3, "INFO has %s" % key)
	var cast: Dictionary = StoryLegends.cast(fam, app.mk_presets)
	check(cast.has("hero") and str(ind.CAST.hero.get("preset", "")) == fam, "the cast has \"hero\" with preset \"%s\"" % fam)
	var bosses = load("res://scripts/bosses.gd")
	for key in cast:
		var c: Dictionary = cast[key]
		if c.has("boss"):
			check(str(bosses.data(str(c.boss)).get("name", "")) != "", "cast %s: boss %s exists" % [key, c.boss])
		elif str(ind.CAST[key].get("preset", "")) != "":
			check(str(ind.CAST[key].preset) in ids and str(c.prompt) != "", "cast %s: preset %s is a roster fighter" % [key, ind.CAST[key].preset])
			check(app.Prompt.interpret(str(c.prompt), 0).family == str(ind.CAST[key].preset), "cast %s plays as %s" % [key, ind.CAST[key].preset])
		elif not c.get("narrator", false):
			check(false, "cast %s needs a preset, a boss or narrator: true" % key)
		check(str(c.get("name", "")) != "" or c.get("narrator", false), "cast %s has a name" % key)
	var chs: Array = ind.chapters()
	check(chs.size() == 4, "four chapters (%d)" % chs.size())
	var lines := 0
	var words := 0
	var fights_total := 0
	for k in range(chs.size()):
		var ch: Dictionary = chs[k]
		var pre := "%s chapter %d: " % [fam, k + 1]
		check(str(ch.get("id", "")) == "%s_%d" % [fam, k + 1], pre + "id is %s_%d" % [fam, k + 1])
		check(int(ch.get("stars", -1)) == StoryLegends.stars_needed(k), pre + "stars = %d" % StoryLegends.stars_needed(k))
		check(app.ARENAS.has(str(ch.get("arena", ""))), pre + "arena %s exists" % ch.get("arena", ""))
		check(str(ch.get("title", "")).length() >= 3, pre + "has a title")
		var all: Array = []
		walk(ch.steps, all)
		var stage := 0
		var fights := 0
		var ok := true
		for s in all:
			var t: String = str(s.get("t", ""))
			if not t in STEP_TYPES:
				check(false, pre + "unknown step type %s" % t)
				continue
			match t:
				"stage":
					stage = s.cast.size()
					for e in s.cast:
						if not cast.has(str(e.id)): check(false, pre + "stage: unknown cast %s" % e.id)
				"say":
					lines += 1
					words += str(s.text).split(" ").size()
					if not cast.has(str(s.who)): check(false, pre + "say: unknown speaker %s" % s.who)
					if str(s.text).length() > 220: check(false, pre + "line too long (%d chars): %s…" % [str(s.text).length(), str(s.text).left(40)])
				"narrate":
					lines += 1
					words += str(s.text).split(" ").size()
					if str(s.text).length() > 260: check(false, pre + "narration too long (%d chars)" % str(s.text).length())
				"cam":
					if not str(s.get("shot", "")) in SHOTS: check(false, pre + "cam shot %s unknown" % s.get("shot", ""))
					if int(s.get("who", 0)) >= stage or int(s.get("who2", 0)) >= maxi(stage, 1): check(false, pre + "cam slot out of range")
				"fx":
					if not str(s.get("kind", "")) in FX: check(false, pre + "fx %s unknown" % s.get("kind", ""))
				"music":
					if not str(s.get("mood", "")) in MOODS: check(false, pre + "music mood %s unknown" % s.get("mood", ""))
				"pose":
					if not str(s.get("pose", "")) in POSES: check(false, pre + "pose %s unknown" % s.get("pose", ""))
				"fight":
					fights += 1
					if str(s.cast[0]) != "hero": check(false, pre + "fight: \"hero\" must be first (the player)")
					for id in s.cast:
						if not cast.has(str(id)): check(false, pre + "fight: unknown cast %s" % id)
						elif cast[str(id)].get("narrator", false): check(false, pre + "fight: the narrator cannot fight")
					if s.has("lives") and s.lives.size() != s.cast.size(): check(false, pre + "fight: lives must match the cast")
					if s.has("teams") and s.teams.size() != s.cast.size(): check(false, pre + "fight: teams must match the cast")
					if str(s.get("goal", "")) == "": check(false, pre + "fight: needs a goal")
				"choice":
					if s.get("options", []).size() != 2: check(false, pre + "choice needs two options")
					for o in s.get("options", []):
						if not str(o.get("flag", "")).begins_with(fam + "_"): check(false, pre + "choice flags start with %s_" % fam)
				"set", "branch":
					if not str(s.get("flag", "")).begins_with(fam + "_"): check(false, pre + "%s flag must start with %s_" % [t, fam])
			if t in ["move", "pose", "vanish", "appear", "face"] and int(s.get("who", 0)) >= stage:
				check(false, pre + "%s: stage slot %d out of range (stage has %d)" % [t, int(s.get("who", 0)), stage])
		check(fights >= 1, pre + "has at least one fight")
		fights_total += fights
	check(lines >= 50, "the legend is fully written (%d lines, %d words; at least 50 lines)" % [lines, words])
	# Play everything.
	var story = app.story
	story.persist = false
	story.done_ids = {}
	story.flags = {}
	story.auto_advance = true
	story.auto_qte_success = true
	app.progression.fighter_xp[fam] = 99999
	app.progression.legend_relics = {}
	story.open_legend(fam)
	for k in range(4):
		story.start_chapter(k)
		var frames := 0
		while story.running and frames < 6000:
			await process_frame
			frames += 1
			if story.in_fight: story.on_fight_finished(0)
		check(not story.running and story.is_done(k), "%s chapter %d plays through" % [fam, k + 1])
	check(app.progression.legend_relics.has(fam), "finishing the legend gives the relic")
	app.queue_free()
	await process_frame
	finish("legend_" + fam)
