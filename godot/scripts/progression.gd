extends RefCounted
## Meta progression for the local player (P1): player level and rank, mastery per fighter,
## three daily challenges, a daily play streak and achievements. Saved to user://.
## Pure logic without nodes, so it is tested headless (tests/test_progression.gd).
##
## Flow: begin_match() when a fight starts, track(event) for every combat event,
## end_match(result) when it ends -> summary for the result screen.

const SAVE_PATH := "user://progress.cfg"

const RANKS := [[1, "REKRUT"], [5, "KÄMPFER"], [10, "VETERAN"], [15, "CHAMPION"], [20, "MEISTER"],
	[30, "GROSSMEISTER"], [40, "LEGENDE"], [50, "MYTHOS"]]
## Total fighter XP needed for 1 … 5 mastery stars.
const MASTERY := [150, 500, 1200, 2500, 5000]

## Daily challenge pool: stat counted during a match, goal, XP reward.
const CHALLENGES := {
	"wins": {"text": "Gewinne %d Kämpfe", "goal": 2, "xp": 120},
	"hits": {"text": "Lande %d Treffer", "goal": 60, "xp": 100},
	"combo": {"text": "Schaffe eine %der-Combo", "goal": 6, "xp": 110, "max": true},
	"finishers": {"text": "Führe %d Finisher aus", "goal": 1, "xp": 150},
	"signatures": {"text": "Setze %d Spezialangriffe ein", "goal": 6, "xp": 100},
	"kos": {"text": "Wirf %d Gegner aus der Arena", "goal": 4, "xp": 120},
	"weapons": {"text": "Hebe %d Waffen auf", "goal": 3, "xp": 90},
	"damage": {"text": "Verursache %d%% Schaden", "goal": 400, "xp": 110},
	"fighters": {"text": "Spiele mit %d verschiedenen Kämpfern", "goal": 3, "xp": 130},
	"perfect": {"text": "Gewinne %d Kampf ohne Stock-Verlust", "goal": 1, "xp": 160},
	"dashes": {"text": "Nutze %d Luft-Dashes", "goal": 10, "xp": 80},
}
const DAILY_COUNT := 3
const DAILY_BONUS := 200   # all three done

## Achievements: id -> [title, description, stat, threshold]. Stats are lifetime totals.
const ACHIEVEMENTS := {
	"first_blood": ["Erstes Blut", "Gewinne deinen ersten Kampf", "wins", 1],
	"ten_wins": ["Aufsteiger", "Gewinne 10 Kämpfe", "wins", 10],
	"fifty_wins": ["Arenaheld", "Gewinne 50 Kämpfe", "wins", 50],
	"hundred_wins": ["Unbesiegbar", "Gewinne 100 Kämpfe", "wins", 100],
	"first_finisher": ["Vollstrecker", "Führe deinen ersten Finisher aus", "finishers", 1],
	"ten_finishers": ["Henker", "Führe 10 Finisher aus", "finishers", 10],
	"combo8": ["Kettenreaktion", "Schaffe eine 8er-Combo", "best_combo", 8],
	"combo15": ["Combo-Gott", "Schaffe eine 15er-Combo", "best_combo", 15],
	"ko50": ["Rausschmeißer", "Wirf 50 Gegner aus der Arena", "kos", 50],
	"perfect1": ["Makellos", "Gewinne ohne einen Stock zu verlieren", "perfects", 1],
	"perfect10": ["Unberührbar", "10 makellose Siege", "perfects", 10],
	"weapons20": ["Waffennarr", "Hebe 20 Waffen auf", "weapons", 20],
	"sig100": ["Signatur-Künstler", "Setze 100 Spezialangriffe ein", "signatures", 100],
	"roster10": ["Vielseitig", "Spiele mit 10 verschiedenen Kämpfern", "fighters_played", 10],
	"roster30": ["Sammler", "Spiele mit 30 verschiedenen Kämpfern", "fighters_played", 30],
	"master1": ["Spezialist", "Bringe einen Kämpfer auf 5 Sterne", "max_mastery", 5],
	"streak3": ["Stammgast", "Spiele 3 Tage in Folge", "streak", 3],
	"streak7": ["Süchtig nach Siegen", "Spiele 7 Tage in Folge", "streak", 7],
	"daily10": ["Pflichtbewusst", "Schließe 10 Tagesaufgaben ab", "dailies", 10],
	"level10": ["Veteran", "Erreiche Level 10", "level", 10],
	"level25": ["Großmeister-Anwärter", "Erreiche Level 25", "level", 25],
	"matches100": ["Dauerbrenner", "Bestreite 100 Kämpfe", "matches", 100],
	"boss1": ["Götterdämmerung", "Besiege deinen ersten Boss", "bosses", 1],
	"boss10": ["Himmelsstürmer", "Besiege 10 Bosse", "bosses", 10],
	"league_gold": ["Goldliga", "Erreiche die Goldliga", "best_league", 2],
	"league_champ": ["Champion", "Erreiche die Champion-Liga", "best_league", 6],
	"grade_s": ["Stilikone", "Erreiche die Kampfnote S", "grade_s", 1],
	"streak5w": ["Unaufhaltsam", "Gewinne 5 Kämpfe in Folge", "best_win_streak", 5],
	"chapters10": ["Chronist", "Schließe 10 Story-Kapitel ab", "chapters", 10],
}

## Weekly challenges: bigger goals, coins instead of XP; all three add a free chest.
const WEEKLY := {
	"wins": {"text": "Gewinne %d Kämpfe", "goal": 12, "coins": 300},
	"hits": {"text": "Lande %d Treffer", "goal": 350, "coins": 250},
	"kos": {"text": "Wirf %d Gegner aus der Arena", "goal": 25, "coins": 250},
	"finishers": {"text": "Führe %d Finisher aus", "goal": 4, "coins": 300},
	"signatures": {"text": "Setze %d Spezialangriffe ein", "goal": 40, "coins": 200},
	"damage": {"text": "Verursache %d%% Schaden", "goal": 3000, "coins": 250},
	"perfect": {"text": "Gewinne %d Kämpfe ohne Stock-Verlust", "goal": 3, "coins": 350},
	"bosses": {"text": "Besiege %d Bosse", "goal": 3, "coins": 400},
}

var save_path := SAVE_PATH
var xp := 0
var granted := {}             # store product id -> true (contents given once)
var fighter_xp := {}          # family -> xp
var stats := {}               # lifetime totals
var achievements := {}        # id -> unix time unlocked
var daily := {}               # {"day": int, "list": [{id, goal, progress, done}], "bonus": bool}
var streak := {"last_day": -1, "days": 0}
## Shop: coins earned in fights and the story, bought start screen backgrounds (backgrounds.gd).
var coins := 0
var unlocked := {}            # background id -> true
var menu_bg := "neon_alley"   # selected start screen background
var persist := true           # false: never touches the save file (headless tests)
## Unlockables and reward loops (rewards.gd).
var skins_owned := {}
var skin := ""                # equipped skin for P1's fighter
var weapons_owned := {}
var start_weapon := ""        # weapon P1 holds at the start of versus / boss fights
var chests := 0               # free lucky chests
var login := {"last": -1, "step": 0}
var path_claimed := 0         # Hall of Fame tiers already rewarded
var win_streak := 0
var rank_points := 0          # league points (rewards.gd LEAGUES)
var best_league := 0
var boost_matches := 0        # fights left with double XP
var title := "rookie"
var weekly := {}              # {"week", "list", "bonus"}
var first_win_day := -1
var bounty_day := -1
var wheel_day := -1
var adventure := {}           # family -> {wave, score, runs, combo} (adventure mode records)
var adventure_best := {}      # best run overall {score, wave, family, day}
var legend_relics := {}       # family -> true: legend finished (story_legends.gd)
var challenge := {}           # daily challenge: done_day, streak, best_streak, total (fun_modes.gd)
var last_seen := -1           # last day the game was opened (comeback gift)
var event := {}               # the week's event (fun_modes.gd), set by main – not saved
var _day := 0

# Current match
var _active := false
var _family := ""
var _match := {}

# ─────────────────────────────────────────────────────────────── curve ──

## XP needed to go from level n to n+1: grows gently so early levels come fast.
static func xp_to_next(level: int) -> int:
	return 120 + (level - 1) * 45

static func level_for(total_xp: int) -> int:
	var lvl := 1
	var left := total_xp
	while left >= xp_to_next(lvl):
		left -= xp_to_next(lvl)
		lvl += 1
	return lvl

## XP already earned inside the current level and the size of that level.
static func level_progress(total_xp: int) -> Vector2i:
	var lvl := 1
	var left := total_xp
	while left >= xp_to_next(lvl):
		left -= xp_to_next(lvl)
		lvl += 1
	return Vector2i(left, xp_to_next(lvl))

static func rank_for(level: int) -> String:
	var title: String = RANKS[0][1]
	for r in RANKS:
		if level >= int(r[0]): title = r[1]
	return title

## Mastery stars of one fighter (0..5).
func stars_of(fam: String) -> int:
	return stars_for(int(fighter_xp.get(fam, 0)))

## A finished legend: the relic, coins and a chest – only once per fighter. Returns true the first time.
func grant_legend(fam: String, coins_gain: int) -> bool:
	if legend_relics.has(fam): return false
	legend_relics[fam] = true
	coins += coins_gain
	chests += 1
	save_progress()
	return true

static func stars_for(fxp: int) -> int:
	var s := 0
	for t in MASTERY:
		if fxp >= t: s += 1
	return s

func level() -> int:
	return level_for(xp)

func stars(family: String) -> int:
	return stars_for(int(fighter_xp.get(family, 0)))

# ────────────────────────────────────────────────────────── persistence ──

func load_progress() -> void:
	if not persist: return
	var cfg := ConfigFile.new()
	if cfg.load(save_path) != OK: return
	xp = int(cfg.get_value("player", "xp", 0))
	fighter_xp = cfg.get_value("player", "fighter_xp", {})
	stats = cfg.get_value("player", "stats", {})
	achievements = cfg.get_value("player", "achievements", {})
	daily = cfg.get_value("player", "daily", {})
	streak = cfg.get_value("player", "streak", {"last_day": -1, "days": 0})
	coins = int(cfg.get_value("shop", "coins", 0))
	unlocked = cfg.get_value("shop", "unlocked", {})
	menu_bg = str(cfg.get_value("shop", "menu_bg", "neon_alley"))
	skins_owned = cfg.get_value("shop", "skins_owned", {})
	granted = cfg.get_value("shop", "granted", {})
	skin = str(cfg.get_value("shop", "skin", ""))
	weapons_owned = cfg.get_value("shop", "weapons_owned", {})
	start_weapon = str(cfg.get_value("shop", "start_weapon", ""))
	chests = int(cfg.get_value("shop", "chests", 0))
	login = cfg.get_value("shop", "login", {"last": -1, "step": 0})
	path_claimed = int(cfg.get_value("shop", "path_claimed", 0))
	win_streak = int(cfg.get_value("player", "win_streak", 0))
	for key in ["rank_points", "best_league", "boost_matches", "title", "weekly", "first_win_day", "bounty_day", "wheel_day", "adventure", "adventure_best", "legend_relics", "challenge", "last_seen"]:
		set(key, cfg.get_value("extra", key, get(key)))
	_migrate_family_ids()

## Saves written before the roster rename keep their fighter progress under the new ids.
const RENAMED_IDS := {"goku": "kairo", "vegeta": "varakh", "frieza": "xylar", "subzero": "glaciem", "pain": "oryn",
	"luffy": "tobi", "zoro": "jubei", "naruto": "ren", "sasuke": "amethya", "saitama": "bruno", "tanjiro": "hikaru",
	"sonic": "zip", "akaza": "raiga", "blue_eyes": "albion", "charizard": "pyrax", "tripo_fran_statue": "lepora",
	"golden_golem": "brunhild", "tripo_fantasy_female": "thorn_witch", "tripo_nyx_harvester": "nyx", "tripo_cat_girl": "shira",
	"tripo_dragon_blue": "frostwyrm", "tripo_white_sci": "cyborg_mech", "tripo_skeleton_dog": "reaper_hound",
	"tripo_wooden_forest": "treant", "tripo_nine_tailed": "celestial_fox", "tripo_quadruped_tree": "mossback"}

func _migrate_family_ids() -> void:
	for old in RENAMED_IDS:
		var new_id: String = RENAMED_IDS[old]
		if fighter_xp.has(old):
			fighter_xp[new_id] = int(fighter_xp.get(new_id, 0)) + int(fighter_xp[old])
			fighter_xp.erase(old)
	var played: Array = stats.get("played", [])
	var migrated: Array = []
	for f in played:
		var id: String = RENAMED_IDS.get(str(f), str(f))
		if not id in migrated: migrated.append(id)
	if not played.is_empty():
		stats["played"] = migrated
		stats["fighters_played"] = migrated.size()

func save_progress() -> void:
	if not persist: return
	var cfg := ConfigFile.new()
	cfg.set_value("player", "xp", xp)
	cfg.set_value("player", "fighter_xp", fighter_xp)
	cfg.set_value("player", "stats", stats)
	cfg.set_value("player", "achievements", achievements)
	cfg.set_value("player", "daily", daily)
	cfg.set_value("player", "streak", streak)
	cfg.set_value("shop", "coins", coins)
	cfg.set_value("shop", "unlocked", unlocked)
	cfg.set_value("shop", "menu_bg", menu_bg)
	for key in ["skins_owned", "skin", "weapons_owned", "start_weapon", "chests", "login", "path_claimed", "granted"]:
		cfg.set_value("shop", key, get(key))
	cfg.set_value("player", "win_streak", win_streak)
	for key in ["rank_points", "best_league", "boost_matches", "title", "weekly", "first_win_day", "bounty_day", "wheel_day", "adventure", "adventure_best", "legend_relics", "challenge", "last_seen"]:
		cfg.set_value("extra", key, get(key))
	cfg.save(save_path)

# ────────────────────────────────────────────────────────────── daily ──

static func today() -> int:
	return int(Time.get_unix_time_from_system() / 86400.0)

## Rolls the day's challenges (same three for the whole day) when the day changed.
func refresh_daily(day: int = today()) -> void:
	if int(daily.get("day", -1)) == day: return
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("pfu-daily-%d" % day)
	var pool: Array = CHALLENGES.keys()
	var list: Array = []
	while list.size() < DAILY_COUNT and not pool.is_empty():
		var id: String = pool.pop_at(rng.randi_range(0, pool.size() - 1))
		list.append({"id": id, "goal": int(CHALLENGES[id].goal), "progress": 0, "done": false})
	daily = {"day": day, "list": list, "bonus": false, "fighters": []}

func refresh_weekly(day: int = today()) -> void:
	var week: int = day / 7
	if int(weekly.get("week", -1)) == week: return
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("pfu-weekly-%d" % week)
	var pool: Array = WEEKLY.keys()
	var list: Array = []
	while list.size() < 3:
		var id: String = pool.pop_at(rng.randi_range(0, pool.size() - 1))
		list.append({"id": id, "goal": int(WEEKLY[id].goal), "progress": 0, "done": false})
	weekly = {"week": week, "list": list, "bonus": false}

static func weekly_text(c: Dictionary) -> String:
	return str(WEEKLY[c.id].text) % int(c.goal)

## A finished story chapter: coins and the chapter statistic.
func story_chapter_done(coins_reward: int = 60) -> void:
	_add("chapters", 1)
	coins += coins_reward
	_check_achievements()
	save_progress()

static func challenge_text(c: Dictionary) -> String:
	return str(CHALLENGES[c.id].text) % int(c.goal)

## Streak multiplier: +10 % per extra day in a row, up to +50 %.
func streak_mult() -> float:
	return 1.0 + minf(4.0, maxf(0.0, float(streak.days) - 1.0)) * 0.1 + (0.1 if int(streak.days) >= 6 else 0.0)

func _touch_streak(day: int) -> void:
	var last: int = int(streak.last_day)
	if last == day: return
	streak.days = int(streak.days) + 1 if last == day - 1 else 1
	streak.last_day = day
	stats["streak"] = maxi(int(stats.get("streak", 0)), int(streak.days))

# ────────────────────────────────────────────────────────────── match ──

## mode: "pve", "manual" or "story" count; AI-vs-AI ("autonomous") does not.
func begin_match(family: String, mode: String, day: int = today()) -> void:
	_active = mode in ["pve", "manual", "story"]
	if not _active: return
	refresh_daily(day)
	refresh_weekly(day)
	_touch_streak(day)
	_day = day
	_family = family
	_match = {"hits": 0, "damage": 0.0, "combo": 0, "kos": 0, "finishers": 0, "signatures": 0,
		"weapons": 0, "dashes": 0, "stocks_lost": 0, "bosses": 0}

func is_tracking() -> bool:
	return _active

## Feeds one combat event; only P1 (slot 0) is the local player.
func track(ev: Dictionary) -> void:
	if not _active: return
	match str(ev.get("type", "")):
		"hit":
			if int(ev.get("actor", -1)) == 0 and int(ev.get("target", 0)) != 0:
				_match.hits += 1
				_match.damage += float(ev.get("damage", 0.0))
		"combo_end":
			if int(ev.get("actor", -1)) == 0: _match.combo = maxi(int(_match.combo), int(ev.get("count", 0)))
		"ring_out", "hp_ko":
			if int(ev.get("actor", -1)) == 0: _match.stocks_lost += 1
			else: _match.kos += 1
		"finisher":
			if int(ev.get("actor", -1)) == 0: _match.finishers += 1
		"signature":
			if int(ev.get("actor", -1)) == 0: _match.signatures += 1
		"weapon_pickup":
			if int(ev.get("actor", -1)) == 0: _match.weapons += 1
		"air_dash":
			if int(ev.get("actor", -1)) == 0: _match.dashes += 1
		"boss_defeated":
			if int(ev.get("by", -1)) == 0: _match.bosses += 1

## Coins outside of fights (story chapters …).
func add_coins(amount: int) -> void:
	coins += maxi(0, amount)
	save_progress()

## Ends the match (result = winner slot, -1 draw) and returns what was earned.
## bonus_coins: extra coins (e.g. for defeating a boss). A fight pays a quarter of its XP as coins.
func end_match(result: int, bonus_coins: int = 0, context: Dictionary = {}) -> Dictionary:
	if not _active: return {}
	_active = false
	var won: bool = result == 0
	var perfect: bool = won and int(_match.stocks_lost) == 0
	var level_before := level()
	var stars_before := stars(_family)

	# XP for this fight.
	var gains: Array = []
	gains.append(["Teilnahme", 40])
	if won: gains.append(["Sieg", 80])
	if perfect: gains.append(["Makellos", 50])
	if int(_match.kos) > 0: gains.append(["%d× K.O." % _match.kos, 25 * int(_match.kos)])
	if int(_match.combo) >= 3: gains.append(["%der-Combo" % _match.combo, 4 * int(_match.combo)])
	if int(_match.finishers) > 0: gains.append(["Finisher", 60 * int(_match.finishers)])
	var dmg_xp := int(float(_match.damage) / 10.0)
	if dmg_xp > 0: gains.append(["%d%% Schaden" % int(_match.damage), dmg_xp])

	# Lifetime stats.
	_add("matches", 1)
	if won: _add("wins", 1)
	if perfect: _add("perfects", 1)
	for k in ["hits", "kos", "finishers", "signatures", "weapons", "dashes"]: _add(k, int(_match[k]))
	_add("damage", int(_match.damage))
	stats["best_combo"] = maxi(int(stats.get("best_combo", 0)), int(_match.combo))
	var played: Array = stats.get("played", [])
	if not _family in played: played.append(_family)
	stats["played"] = played
	stats["fighters_played"] = played.size()

	# Daily challenges.
	var completed: Array = []
	var today_fighters: Array = daily.get("fighters", [])
	if not _family in today_fighters: today_fighters.append(_family)
	daily["fighters"] = today_fighters
	var add := {"wins": 1 if won else 0, "hits": _match.hits, "finishers": _match.finishers,
		"signatures": _match.signatures, "kos": _match.kos, "weapons": _match.weapons,
		"damage": int(_match.damage), "perfect": 1 if perfect else 0, "dashes": _match.dashes}
	for c in daily.get("list", []):
		if c.done: continue
		var id: String = c.id
		if id == "combo": c.progress = maxi(int(c.progress), int(_match.combo))
		elif id == "fighters": c.progress = today_fighters.size()
		else: c.progress = int(c.progress) + int(add.get(id, 0))
		if int(c.progress) >= int(c.goal):
			c.progress = c.goal
			c.done = true
			completed.append(challenge_text(c))
			gains.append(["Aufgabe: %s" % challenge_text(c), int(CHALLENGES[id].xp)])
			_add("dailies", 1)
	if not bool(daily.get("bonus", false)) and not daily.get("list", []).is_empty() \
			and daily.list.all(func(c): return c.done):
		daily.bonus = true
		gains.append(["Alle Tagesaufgaben!", DAILY_BONUS])

	var base := 0
	for g in gains: base += int(g[1])
	var mult := streak_mult()
	var boosted: bool = boost_matches > 0
	if boosted:
		mult *= 2.0
		boost_matches -= 1
	mult *= float(event.get("xp", 1.0))
	var total := int(round(base * mult))
	xp += total
	fighter_xp[_family] = int(fighter_xp.get(_family, 0)) + total
	stats["level"] = level()
	var best := 0
	for f in fighter_xp: best = maxi(best, stars_for(int(fighter_xp[f])))
	stats["max_mastery"] = best

	# Style grade from how the fight went.
	var R = load("res://scripts/rewards.gd")
	var score: float = float(_match.hits) + float(_match.combo) * 3.0 + float(_match.kos) * 15.0 + float(_match.finishers) * 25.0
	score += float(_match.damage) / 10.0 - float(_match.stocks_lost) * 20.0 + (40.0 if won else 0.0) + (30.0 if perfect else 0.0)
	var grade: Array = R.grade_for(score)
	if grade[0] == "S": _add("grade_s", 1)
	# Coins: a quarter of the XP, boosted by win streak and grade, plus bonuses.
	win_streak = win_streak + 1 if won else 0
	stats["best_win_streak"] = maxi(int(stats.get("best_win_streak", 0)), win_streak)
	var streak_bonus: float = 1.0 + 0.1 * float(mini(5, maxi(0, win_streak - 1)))
	var earned: int = int(total / 4.0 * streak_bonus * float(grade[2]) * float(event.get("coins", 1.0))) + maxi(0, bonus_coins)
	var extras: Array = []
	if won and first_win_day != _day:
		first_win_day = _day
		earned += 100
		extras.append("⭐ ERSTER SIEG DES TAGES +100 🪙")
	if won and str(context.get("bounty", "")) == _family and bounty_day != _day:
		bounty_day = _day
		earned += 150
		extras.append("💰 KOPFGELD KASSIERT +150 🪙")
	# League points.
	var lp_change: int = (25 + 5 * mini(4, maxi(0, win_streak - 1))) if won else -15
	rank_points = maxi(0, rank_points + lp_change)
	var league_now: int = R.league_for(rank_points)
	if league_now > best_league:
		for lg in range(best_league + 1, league_now + 1):
			var lr: Dictionary = R.LEAGUE_REWARDS[lg]
			earned += int(lr.get("coins", 0))
			chests += int(lr.get("chests", 0))
			extras.append("🏅 AUFSTIEG: %s-LIGA! +%d 🪙%s" % [R.LEAGUES[lg][0], int(lr.get("coins", 0)), "  + 🎁" if lr.has("chests") else ""])
		best_league = league_now
		stats["best_league"] = best_league
	# Mastery stars pay out.
	var stars_now: int = stars(_family)
	for st in range(stars_before + 1, stars_now + 1):
		earned += 100 * st
		extras.append("★ MEISTERSCHAFT %d STERNE +%d 🪙" % [st, 100 * st])
	# Weekly challenges.
	var wadd := {"wins": 1 if won else 0, "hits": _match.hits, "kos": _match.kos, "finishers": _match.finishers, "signatures": _match.signatures,
		"damage": int(_match.damage), "perfect": 1 if perfect else 0, "bosses": _match.bosses}
	_add("bosses", int(_match.bosses))
	for c in weekly.get("list", []):
		if c.done: continue
		c.progress = int(c.progress) + int(wadd.get(c.id, 0))
		if int(c.progress) >= int(c.goal):
			c.progress = c.goal
			c.done = true
			earned += int(WEEKLY[c.id].coins)
			extras.append("📅 WOCHENAUFGABE: %s +%d 🪙" % [weekly_text(c), int(WEEKLY[c.id].coins)])
	if not bool(weekly.get("bonus", false)) and not weekly.get("list", []).is_empty() and weekly.list.all(func(c): return c.done):
		weekly.bonus = true
		chests += 1
		extras.append("📅 ALLE WOCHENAUFGABEN! + 🎁 TRUHE")
	# Level ups pay coins, every fifth level a free lucky chest.
	var level_coins := 0
	for lv in range(level_before + 1, level() + 1):
		level_coins += 40 * lv
		if lv % 5 == 0: chests += 1
	earned += level_coins
	var new_achievements := _check_achievements()
	earned += 100 * new_achievements.size()   # every achievement pays 100 coins
	coins += earned
	save_progress()
	return {
		"won": won, "gains": gains, "base": base, "mult": mult, "total": total,
		"xp": xp, "level_before": level_before, "level": level(), "rank": rank_for(level()),
		"rank_up": rank_for(level()) != rank_for(level_before),
		"family": _family, "stars_before": stars_before, "stars": stars(_family),
		"challenges": completed, "achievements": new_achievements, "streak": int(streak.days),
		"coins": earned, "coins_total": coins, "win_streak": win_streak, "streak_bonus": streak_bonus,
		"level_coins": level_coins, "grade": grade[0], "grade_mult": grade[2], "extras": extras, "boosted": boosted,
		"league": R.league_name(rank_points), "lp_change": lp_change, "rank_points": rank_points,
	}

func _add(key: String, amount: int) -> void:
	stats[key] = int(stats.get(key, 0)) + amount

func _check_achievements() -> Array:
	var out: Array = []
	for id in ACHIEVEMENTS:
		if achievements.has(id): continue
		var a: Array = ACHIEVEMENTS[id]
		if int(stats.get(a[2], 0)) >= int(a[3]):
			achievements[id] = int(Time.get_unix_time_from_system())
			out.append({"id": id, "title": a[0], "text": a[1]})
	return out
