extends "res://tests/test_base.gd"
## Player level, fighter mastery, daily challenges, streak and achievements.

const Progression = preload("res://scripts/progression.gd")
const TEST_SAVE := "user://progress_test.cfg"

func _initialize() -> void:
	test_curve()
	test_match_rewards()
	test_ai_matches_do_not_count()
	test_daily_challenges()
	test_streak()
	test_achievements_and_save()
	test_new_achievements()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	finish("progression")

func fresh():
	var p = Progression.new()
	p.save_path = TEST_SAVE
	return p

func play(p, family: String, result: int, events: Array, day: int = 20000) -> Dictionary:
	p.begin_match(family, "pve", day)
	for ev in events: p.track(ev)
	return p.end_match(result)

## Achievements of packages 8/9 and the mutators.
func test_new_achievements() -> void:
	var p = fresh()
	p.persist = false
	for fam in Progression.NATIONS: play(p, fam, 0, [])
	check(p.achievements.has("nations5"), "winning with all five national fighters unlocks Weltreise")
	for fam in Progression.TRIO: play(p, fam, 1, [])
	check(p.achievements.has("trio3"), "playing Kalyx, Vorruk and Neris unlocks Neue Gesichter")
	var shifts: Array = []
	for k in range(50): shifts.append({"type": "crown_shift", "actor": 0})
	play(p, "kalyx", 1, shifts)
	check(p.achievements.has("crown50"), "50 crown shifts unlock Zwiegespalten")
	var pets: Array = []
	for k in range(20): pets.append({"type": "signature", "actor": 0, "mech": "pack_hound"})
	play(p, "vorruk", 1, pets)
	check(p.achievements.has("pets20"), "20 summoned pets unlock Rudelführer")
	for k in range(10):
		p.begin_match("ninja", "pve", 20000)
		p.note_mutators(["turbo", "bomb_rain"])
		p.end_match(0)
	check(p.achievements.has("mutator_win10") and not p.achievements.has("mutators_all"), "10 wins with mutators unlock Chaos-Liebhaber")
	p.begin_match("ninja", "pve", 20000)
	p.note_mutators(load("res://scripts/fun_modes.gd").MUTATORS.keys())
	p.end_match(1)
	check(p.achievements.has("mutators_all"), "fighting with every mutator unlocks Regelbrecher")

func test_curve() -> void:
	check(Progression.level_for(0) == 1, "a new player is level 1")
	check(Progression.level_for(Progression.xp_to_next(1)) == 2, "one level's XP reaches level 2")
	check(Progression.xp_to_next(10) > Progression.xp_to_next(1), "later levels need more XP")
	check(Progression.rank_for(1) == "REKRUT" and Progression.rank_for(20) == "MEISTER", "ranks follow the level")
	check(Progression.stars_for(0) == 0 and Progression.stars_for(5000) == 5, "mastery goes from 0 to 5 stars")
	var prog: Vector2i = Progression.level_progress(Progression.xp_to_next(1) + 10)
	check(prog.x == 10 and prog.y == Progression.xp_to_next(2), "level progress is XP inside the current level")

func test_match_rewards() -> void:
	var p = fresh()
	var hits: Array = []
	for n in range(10): hits.append({"type": "hit", "actor": 0, "target": 1, "damage": 12.0})
	hits.append({"type": "combo_end", "actor": 0, "count": 7})
	hits.append({"type": "ring_out", "actor": 1, "lives": 2})
	hits.append({"type": "hit", "actor": 1, "target": 0, "damage": 50.0}) # opponent's hit: not ours
	var won: Dictionary = play(p, "ninja", 0, hits)
	check(won.won and won.total > 0, "a win earns XP (%d)" % won.get("total", 0))
	check(p.stats.hits == 10 and p.stats.damage == 120, "only P1's hits count (%d hits, %d damage)" % [p.stats.hits, p.stats.damage])
	check(p.stats.best_combo == 7 and p.stats.kos == 1, "best combo and KOs are recorded")
	check(p.fighter_xp.ninja == won.total, "the fighter gets the same XP as the player")
	var q = fresh()
	var lost: Dictionary = play(q, "ninja", 1, [{"type": "ring_out", "actor": 0, "lives": 0}])
	check(lost.total > 0 and lost.total < won.total, "a loss still earns something, less than a win")
	var perfect_gain := false
	for g in won.gains: if g[0] == "Makellos": perfect_gain = true
	check(perfect_gain, "a win without losing a stock is a perfect win")

func test_ai_matches_do_not_count() -> void:
	var p = fresh()
	p.begin_match("ninja", "autonomous", 20000)
	p.track({"type": "hit", "actor": 0, "target": 1, "damage": 10.0})
	check(p.end_match(0).is_empty() and p.xp == 0, "AI-vs-AI fights give no progress")

func test_daily_challenges() -> void:
	var a = fresh()
	a.refresh_daily(20000)
	var b = fresh()
	b.refresh_daily(20000)
	var ids_a: Array = a.daily.list.map(func(c): return c.id)
	var ids_b: Array = b.daily.list.map(func(c): return c.id)
	check(ids_a.size() == 3 and ids_a == ids_b, "the same three challenges all day %s" % [ids_a])
	var unique := {}
	for id in ids_a: unique[id] = true
	check(unique.size() == 3, "three different challenges")
	var other_day := false
	for d in range(20001, 20008):
		b.refresh_daily(d)
		if b.daily.list.map(func(c): return c.id) != ids_a: other_day = true
	check(other_day, "challenges change from day to day")
	# Force a known set and complete it.
	var p = fresh()
	p.refresh_daily(20000)
	p.daily.list = [{"id": "hits", "goal": 5, "progress": 0, "done": false},
		{"id": "combo", "goal": 4, "progress": 0, "done": false},
		{"id": "wins", "goal": 2, "progress": 0, "done": false}]
	var evs: Array = []
	for n in range(5): evs.append({"type": "hit", "actor": 0, "target": 1, "damage": 5.0})
	evs.append({"type": "combo_end", "actor": 0, "count": 4})
	var r1: Dictionary = play(p, "golem", 0, evs)
	check(r1.challenges.size() == 2 and p.daily.list[2].progress == 1, "progress counts towards the goals (%s)" % [r1.challenges])
	var r2: Dictionary = play(p, "golem", 0, [])
	var bonus := false
	for g in r2.gains: if g[0] == "Alle Tagesaufgaben!": bonus = true
	check(r2.challenges.size() == 1 and bonus, "finishing all three pays the daily bonus")
	var r3: Dictionary = play(p, "golem", 0, [])
	var again := false
	for g in r3.gains: if g[0] == "Alle Tagesaufgaben!": again = true
	check(not again and r3.challenges.is_empty(), "the bonus is paid once per day")

func test_streak() -> void:
	var p = fresh()
	play(p, "ninja", 1, [], 30000)
	check(p.streak.days == 1 and is_equal_approx(p.streak_mult(), 1.0), "first day: streak 1, no bonus")
	play(p, "ninja", 1, [], 30000)
	check(p.streak.days == 1, "more fights on the same day keep the streak")
	play(p, "ninja", 1, [], 30001)
	play(p, "ninja", 1, [], 30002)
	check(p.streak.days == 3 and p.streak_mult() > 1.15, "three days in a row raise the XP multiplier (%.2f)" % p.streak_mult())
	play(p, "ninja", 1, [], 30005)
	check(p.streak.days == 1, "a missed day resets the streak")

func test_achievements_and_save() -> void:
	var p = fresh()
	var r: Dictionary = play(p, "ninja", 0, [{"type": "finisher", "actor": 0, "target": 1}])
	var ids: Array = r.achievements.map(func(a): return a.id)
	check("first_blood" in ids and "first_finisher" in ids, "first win and first finisher unlock achievements %s" % [ids])
	var r2: Dictionary = play(p, "ninja", 0, [])
	check(not "first_blood" in r2.achievements.map(func(a): return a.id), "an achievement unlocks only once")
	var q = fresh()
	q.load_progress()
	check(q.xp == p.xp and q.achievements.has("first_blood") and q.stars("ninja") == p.stars("ninja"), "progress survives a restart")
