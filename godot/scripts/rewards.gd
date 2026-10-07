extends RefCounted
## Unlockables and reward loops: weapons and skins bought with coins, the lucky chest,
## the 7-day login calendar, the Hall of Fame path (Ruhmespfad), level-up rewards and win
## streaks. Pure rules – the state lives in progression.gd, the UI in main.gd.

const RARITY := {"S": ["SELTEN", Color("60a5fa")], "E": ["EPISCH", Color("c084fc")], "L": ["LEGENDÄR", Color("fbbf24")], "P": ["PFAD-EXKLUSIV", Color("f87171")]}

## Shop weapons (definitions in combat.gd WEAPONS). Bought weapons spawn in every arena and one
## can be the start weapon that P1 holds at the beginning of each versus / boss fight.
const WEAPONS := [
	{"id": "shadow_katana", "name": "SCHATTENKATANA", "price": 350, "rarity": "S", "info": "Blitzschnell, Plasmaklinge als Spezial"},
	{"id": "frost_axe", "name": "FROSTAXT", "price": 450, "rarity": "S", "info": "Friert bei jedem Treffer ein"},
	{"id": "flame_whip", "name": "FEUERPEITSCHE", "price": 500, "rarity": "E", "info": "Riesige Reichweite, Flammensichel"},
	{"id": "crystal_bow", "name": "KRISTALLBOGEN", "price": 600, "rarity": "E", "info": "Durchschlagende Kristallpfeile"},
	{"id": "dragon_lance", "name": "DRACHENLANZE", "price": 700, "rarity": "E", "info": "Längste Stichwaffe, Lichtstrahl"},
	{"id": "soul_scythe", "name": "SEELENSENSE", "price": 800, "rarity": "L", "info": "Weite Sensenhiebe, Mondsichel"},
	{"id": "thunder_hammer", "name": "DONNERHAMMER", "price": 900, "rarity": "L", "info": "Brutaler Knockback, Erdbeben"},
	{"id": "plasma_cannon", "name": "PLASMAKANONE", "price": 1200, "rarity": "L", "info": "Explodierende Plasmakugeln"},
]

## Fighter skins: a surface look for P1's fighter (boss_models.gd apply_skin).
const SKINS := [
	{"id": "gold", "name": "GOLDRAUSCH", "look": "gold", "price": 300, "rarity": "S"},
	{"id": "chrome", "name": "CHROM", "look": "silver", "price": 300, "rarity": "S"},
	{"id": "marble", "name": "MARMORSTATUE", "look": "marble", "price": 400, "rarity": "S"},
	{"id": "emerald", "name": "SMARAGD", "look": "emerald", "price": 550, "rarity": "E"},
	{"id": "frost", "name": "FROSTHAUCH", "look": "frost", "price": 600, "rarity": "E"},
	{"id": "obsidian", "name": "OBSIDIANGLUT", "look": "obsidian", "price": 700, "rarity": "E"},
	{"id": "neon", "name": "NEONPULS", "look": "neon", "price": 800, "rarity": "E"},
	{"id": "shadow", "name": "SCHATTENFORM", "look": "shadow", "price": 900, "rarity": "L"},
	{"id": "lava", "name": "LAVAHERZ", "look": "lava", "price": 1000, "rarity": "L"},
	{"id": "crystal", "name": "KRISTALL", "look": "crystal", "price": 1100, "rarity": "L"},
	{"id": "ghost", "name": "GEIST", "look": "ghost", "price": 1200, "rarity": "L"},
	{"id": "galaxy", "name": "GALAXIE", "look": "galaxy", "price": 1500, "rarity": "L"},
	{"id": "celestial", "name": "HIMMELSGLANZ", "look": "celestial", "price": 0, "rarity": "P", "path": 15},
	{"id": "infernal", "name": "HÖLLENFÜRST", "look": "infernal", "price": 0, "rarity": "P", "path": 30},
]

## 7-day login calendar (day 7 also gives a free chest); a missed day starts over.
const LOGIN := [50, 75, 100, 125, 150, 200, 300]

## Hall of Fame path: a tier every PATH_XP total XP; rewards per tier.
const PATH_XP := 400
const PATH_TIERS := 30
const CHEST_PRICE := 150

static func skin(id: String) -> Dictionary:
	for s in SKINS: if s.id == id: return s
	return {}

static func weapon(id: String) -> Dictionary:
	for w in WEAPONS: if w.id == id: return w
	return {}

## Reward of a Hall of Fame tier.
static func path_reward(tier: int) -> Dictionary:
	if tier == 15: return {"kind": "skin", "id": "celestial"}
	if tier == 30: return {"kind": "skin", "id": "infernal"}
	if tier == 10: return {"kind": "weapon", "id": "shadow_katana"}
	if tier == 20: return {"kind": "weapon", "id": "dragon_lance"}
	if tier % 5 == 0: return {"kind": "chest", "amount": 1}
	return {"kind": "coins", "amount": 80 + tier * 10}

static func reward_text(r: Dictionary) -> String:
	match str(r.get("kind", "")):
		"coins": return "%d 🪙" % int(r.amount)
		"chest": return "🎁 GLÜCKSTRUHE"
		"skin": return "SKIN %s" % skin(r.id).get("name", r.id)
		"weapon": return "WAFFE %s" % weapon(r.id).get("name", r.id)
		"background": return ("ARENA %s" % r.name) if r.has("name") else ("HINTERGRUND %s" % str(r.id).to_upper())
	return "?"

static func path_tier(prog) -> int:
	return mini(PATH_TIERS, int(prog.xp) / PATH_XP)

# ── owning, buying, equipping ──

static func owns_skin(prog, id: String) -> bool:
	return prog.skins_owned.has(id)

static func owns_weapon(prog, id: String) -> bool:
	return prog.weapons_owned.has(id)

static func buy_skin(prog, id: String) -> bool:
	var s: Dictionary = skin(id)
	if s.is_empty() or s.has("path") or owns_skin(prog, id) or int(prog.coins) < int(s.price): return false
	prog.coins -= int(s.price)
	prog.skins_owned[id] = true
	prog.save_progress()
	return true

static func buy_weapon(prog, id: String) -> bool:
	var w: Dictionary = weapon(id)
	if w.is_empty() or owns_weapon(prog, id) or int(prog.coins) < int(w.price): return false
	prog.coins -= int(w.price)
	prog.weapons_owned[id] = true
	prog.save_progress()
	return true

static func equip_skin(prog, id: String) -> bool:
	if id != "" and not owns_skin(prog, id): return false
	prog.skin = id
	prog.save_progress()
	return true

static func equip_weapon(prog, id: String) -> bool:
	if id != "" and not owns_weapon(prog, id): return false
	prog.start_weapon = id
	prog.save_progress()
	return true

## Weapons that can spawn in arenas: the eight classics plus every bought one.
static func weapon_pool(prog, base: Array) -> Array:
	var pool: Array = base.duplicate()
	for w in WEAPONS:
		if owns_weapon(prog, w.id): pool.append(w.id)
	return pool

static func grant(prog, r: Dictionary) -> Dictionary:
	# Gives a reward; an item that is already owned turns into coins.
	match str(r.get("kind", "")):
		"coins": prog.coins += int(r.amount)
		"chest": prog.chests += int(r.get("amount", 1))
		"skin":
			if owns_skin(prog, r.id): return grant(prog, {"kind": "coins", "amount": 200})
			prog.skins_owned[r.id] = true
		"weapon":
			if owns_weapon(prog, r.id): return grant(prog, {"kind": "coins", "amount": 200})
			prog.weapons_owned[r.id] = true
		"background":
			if prog.unlocked.has(r.id): return grant(prog, {"kind": "coins", "amount": 250})
			prog.unlocked[r.id] = true
	return r

# ── lucky chest ──

## Opens a chest: a free one if available, else for CHEST_PRICE coins. {} if neither.
## Odds: 50 % coins, 25 % skin, 17 % weapon, 8 % background; owned items become coins.
static func open_chest(prog, rng: RandomNumberGenerator, backgrounds: Array) -> Dictionary:
	if int(prog.chests) > 0: prog.chests -= 1
	elif int(prog.coins) >= CHEST_PRICE: prog.coins -= CHEST_PRICE
	else: return {}
	var roll: float = rng.randf()
	var r := {}
	if roll < 0.5:
		r = {"kind": "coins", "amount": [60, 90, 120, 150, 250, 400][rng.randi_range(0, 5)]}
	elif roll < 0.75:
		var pool: Array = SKINS.filter(func(s): return not s.has("path") and not owns_skin(prog, s.id))
		r = {"kind": "skin", "id": pool[rng.randi_range(0, pool.size() - 1)].id} if not pool.is_empty() else {"kind": "coins", "amount": 300}
	elif roll < 0.92:
		var wp: Array = WEAPONS.filter(func(w): return not owns_weapon(prog, w.id))
		r = {"kind": "weapon", "id": wp[rng.randi_range(0, wp.size() - 1)].id} if not wp.is_empty() else {"kind": "coins", "amount": 300}
	else:
		var bp: Array = backgrounds.filter(func(b): return int(b.price) > 0 and not prog.unlocked.has(b.id))
		r = {"kind": "background", "id": bp[rng.randi_range(0, bp.size() - 1)].id} if not bp.is_empty() else {"kind": "coins", "amount": 400}
	var got: Dictionary = grant(prog, r)
	prog.save_progress()
	return got

## Legend chest: free, once per finished legend (story_mode.gd). Unlike the lucky chest it always
## holds something you do not own yet – a skin, a weapon or an arena; only a full collection pays coins.
const LEGEND_CHEST_COINS := 500
static func open_legend_chest(prog, rng: RandomNumberGenerator, backgrounds: Array) -> Dictionary:
	var pool: Array = []
	for s in SKINS:
		if not s.has("path") and not owns_skin(prog, s.id): pool.append({"kind": "skin", "id": s.id})
	for w in WEAPONS:
		if not owns_weapon(prog, w.id): pool.append({"kind": "weapon", "id": w.id})
	for b in backgrounds:
		if int(b.price) > 0 and not prog.unlocked.has(b.id): pool.append({"kind": "background", "id": b.id, "name": b.name})
	var r: Dictionary = {"kind": "coins", "amount": LEGEND_CHEST_COINS} if pool.is_empty() else pool[rng.randi_range(0, pool.size() - 1)]
	var got: Dictionary = grant(prog, r)
	prog.save_progress()
	return got

# ── daily login ──

static func login_ready(prog, day: int) -> bool:
	return int(prog.login.get("last", -1)) != day

## Claims today's login reward. Consecutive days climb the calendar, a gap starts at day 1.
static func claim_login(prog, day: int) -> Dictionary:
	if not login_ready(prog, day): return {}
	var last: int = int(prog.login.get("last", -1))
	var step: int = (int(prog.login.get("step", 0)) % LOGIN.size()) if last == day - 1 else 0
	var coins: int = LOGIN[step]
	prog.coins += coins
	if step == LOGIN.size() - 1: prog.chests += 1
	prog.login = {"last": day, "step": step + 1}
	prog.save_progress()
	return {"day": step + 1, "coins": coins, "chest": step == LOGIN.size() - 1}

# ── Hall of Fame ──

## Claims every reached, unclaimed tier. Returns the rewards given.
static func claim_path(prog) -> Array:
	var out: Array = []
	var reached: int = path_tier(prog)
	while int(prog.path_claimed) < reached:
		prog.path_claimed += 1
		out.append(grant(prog, path_reward(int(prog.path_claimed))))
	if not out.is_empty(): prog.save_progress()
	return out

## Share of everything collectable that the player owns (0..1).
static func collection(prog, backgrounds: Array) -> float:
	var total: int = backgrounds.size() + WEAPONS.size() + SKINS.size()
	var have: int = prog.skins_owned.size() + prog.weapons_owned.size()
	for b in backgrounds: if int(b.price) == 0 or prog.unlocked.has(b.id): have += 1
	return float(have) / float(total)

# ── League (ranked points from every counted fight) ──

const LEAGUES := [["BRONZE", 0, Color("cd7f32")], ["SILBER", 100, Color("cbd5e1")], ["GOLD", 250, Color("fbbf24")], ["PLATIN", 450, Color("67e8f9")],
	["DIAMANT", 700, Color("a78bfa")], ["MEISTER", 1000, Color("f87171")], ["CHAMPION", 1400, Color("fde047")]]
## Reward for reaching a league for the first time (index = league).
const LEAGUE_REWARDS := [{}, {"coins": 200}, {"coins": 300, "chests": 1}, {"coins": 500, "chests": 1}, {"coins": 800, "chests": 1},
	{"coins": 1200, "chests": 2}, {"coins": 2000, "chests": 3}]

static func league_for(points: int) -> int:
	var idx := 0
	for k in range(LEAGUES.size()):
		if points >= int(LEAGUES[k][1]): idx = k
	return idx

static func league_name(points: int) -> String:
	return str(LEAGUES[league_for(points)][0])

# ── Style grade ──

const GRADES := [["S", 150, 1.5, Color("fde047")], ["A", 100, 1.25, Color("4ade80")], ["B", 60, 1.1, Color("38bdf8")], ["C", 30, 1.0, Color("cbd5e1")], ["D", -9999, 0.9, Color("94a3b8")]]

static func grade_for(score: float) -> Array:
	for g in GRADES:
		if score >= float(g[1]): return g
	return GRADES[GRADES.size() - 1]

# ── Lucky wheel (one free spin per day, more for coins) ──

const WHEEL := [{"kind": "coins", "amount": 50}, {"kind": "coins", "amount": 100}, {"kind": "coins", "amount": 150}, {"kind": "boost", "amount": 3},
	{"kind": "coins", "amount": 250}, {"kind": "chest", "amount": 1}, {"kind": "coins", "amount": 500}, {"kind": "coins", "amount": 1000}]
const WHEEL_WEIGHTS := [22, 20, 16, 12, 12, 9, 6, 3]
const WHEEL_PRICE := 100
const BOOST_PRICE := 250

static func wheel_text(seg: Dictionary) -> String:
	match str(seg.kind):
		"boost": return "2× XP (%d)" % int(seg.amount)
		"chest": return "🎁 TRUHE"
	return ("JACKPOT %d 🪙" if int(seg.amount) >= 1000 else "%d 🪙") % int(seg.amount)

static func wheel_free(prog, day: int) -> bool:
	return int(prog.wheel_day) != day

## Spins the wheel: free once a day, else WHEEL_PRICE coins. Returns {index, reward} or {}.
static func spin_wheel(prog, rng: RandomNumberGenerator, day: int) -> Dictionary:
	if wheel_free(prog, day): prog.wheel_day = day
	elif int(prog.coins) >= WHEEL_PRICE: prog.coins -= WHEEL_PRICE
	else: return {}
	var total := 0
	for w in WHEEL_WEIGHTS: total += w
	var roll: int = rng.randi_range(0, total - 1)
	var idx := 0
	while roll >= WHEEL_WEIGHTS[idx]:
		roll -= WHEEL_WEIGHTS[idx]
		idx += 1
	var seg: Dictionary = WHEEL[idx]
	if seg.kind == "boost": prog.boost_matches += int(seg.amount)
	else: grant(prog, seg)
	prog.save_progress()
	return {"index": idx, "reward": seg}

static func buy_boost(prog) -> bool:
	if int(prog.coins) < BOOST_PRICE: return false
	prog.coins -= BOOST_PRICE
	prog.boost_matches += 3
	prog.save_progress()
	return true

## Fighter of the day with a bounty: win with it for bonus coins.
static func bounty_family(day: int, families: Array) -> String:
	if families.is_empty(): return ""
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("pfu-bounty-%d" % day)
	return str(families[rng.randi_range(0, families.size() - 1)])

# ── Titles ──

const TITLES := [
	{"id": "supporter", "name": "Gönner der Arenen", "stat": "supporter", "need": 1},
	{"id": "rookie", "name": "Frischling", "stat": "matches", "need": 0},
	{"id": "brawler", "name": "Raufbold", "stat": "wins", "need": 10},
	{"id": "hero", "name": "Arenaheld", "stat": "wins", "need": 50},
	{"id": "stylish", "name": "Stilikone", "stat": "grade_s", "need": 1},
	{"id": "unstoppable", "name": "Unaufhaltsam", "stat": "best_win_streak", "need": 5},
	{"id": "godslayer", "name": "Götterdämmerung", "stat": "bosses", "need": 1},
	{"id": "stormer", "name": "Himmelsstürmer", "stat": "bosses", "need": 10},
	{"id": "chronicler", "name": "Chronist", "stat": "chapters", "need": 10},
	{"id": "blademaster", "name": "Klingenmeister", "stat": "max_mastery", "need": 5},
	{"id": "gold_league", "name": "Goldkämpfer", "stat": "best_league", "need": 2},
	{"id": "champion", "name": "Champion der Arenen", "stat": "best_league", "need": 6},
	{"id": "legend", "name": "Lebende Legende", "stat": "level", "need": 25},
]

static func title_unlocked(prog, t: Dictionary) -> bool:
	return int(prog.stats.get(t.stat, 0)) >= int(t.need)

static func title_name(prog) -> String:
	for t in TITLES:
		if t.id == prog.title and title_unlocked(prog, t): return str(t.name)
	return "Frischling"

static func equip_title(prog, id: String) -> bool:
	for t in TITLES:
		if t.id == id and title_unlocked(prog, t):
			prog.title = id
			prog.save_progress()
			return true
	return false
