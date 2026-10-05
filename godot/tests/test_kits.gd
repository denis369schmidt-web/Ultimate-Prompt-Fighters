extends "res://tests/test_base.gd"
## Fighter kits (fighter_kits.gd): own physics, movesets, signatures and finishers for
## packages 1-3 – all on the real combat code.

const FighterKits = preload("res://scripts/fighter_kits.gd")
const Signatures = preload("res://scripts/signatures.gd")

const PROMPTS := {
	"arber": "Arbër der Bohrmeister mit zwei Bohrmaschinen und dem Doppeladler",
	"ninja": "Blitzschneller Schattenninja mit elektrischen Klingen",
	"valkyrie": "Strahlende Moe Valkyrie Paladin Kriegerin mit Lichtflügeln und Rapier",
	"golem": "Gepanzerter Lavagolem mit brennenden Fäusten",
	"pirate_captain": "Korsar Corsair Piratenkapitän mit Entermesser und Donnerbüchse",
	"steel_knight": "Steel Knight Ritter in Vollplatte mit eisernem Schild",
	"samurai_dreyar": "Samurai Dreyar Meister mit Wind-Klingen und Sturm-Schritten",
	"warrok_brute": "Warrok Koloss Urzeitlicher Berserker mit Knochenkeule und Erdbeben",
	"kairo": "Kairo der Sturmmönch mit Solar-Kanone",
	"varakh": "Varakh der Sternenprinz mit Nova-Strahl",
	"xylar": "Xylar der Leerenkaiser mit Nadelstrahl",
	"ren": "Ren der Wirbelfuchs mit Spiralkern",
	"amethya": "Kage der Donnerklinge mit Tausend Funken",
	"oryn": "Oryn der Schwerkraftprophet mit Abstoßungswelle",
	"bruno": "Bruno der Einschlag-Held mit Ernstfall-Schlag",
	"jubei": "Jubei der Windklingen-Wanderer mit Sturmschnitt",
	"hikaru": "Hikaru der Glutklingen-Wanderer mit Morgenrotschnitt",
	"tobi": "Tobi der Federfaust-Raufbold mit Schleuderfaust",
	"raiga": "Raiga die Donnerfaust mit Sternschlag",
	"glaciem": "Glaciem die Frostassassine mit Eissplitter",
	"zip": "Zip der Blitzkurier mit Turbo-Sprint",
	"dragon": "Mächtiger Cyber Drachenritter mit flammendem Drachen-Großschwert",
	"pyrax": "Pyrax die Glutwyvern mit Glutsturm",
	"phoenix": "Phoenix Empress with feather armor and phoenix glaive",
	"wizard_sorcerer": "Erzmagier Pyrus Feuerzauberer mit Meteorschlag und Flammenstab",
	"don_valente": "Don Valente der Unterweltpate mit Leibwächter-Geschütz",
	"specter": "Void Specter crystal phantom warrior with void lance",
	"shira": "Cat Girl Kitsune Warrior blade",
	"reaper_hound": "Reaper Skeleton Hound nether beast",
	"anubis": "Jackal God Anubis wielding dual Khopesh",
	"brunhild": "Brunhild golden axe valkyrie giantess",
	"celestial_fox": "Celestial Nine Tailed Fox Kyuubi spirit",
	"cyborg_mech": "White Cyborg Android Mech warrior",
	"frostwyrm": "Blue Wyrm Frost Dragon beast",
	"lepora": "Lepora die Mondjägerin mit Mondbogen",
	"nyx": "Nyx Harvester of Souls demon scythe reaper",
}
const DUMMY := "Albion der Silberwyrm mit Sturmstrahl"
const KIT_MOVES := ["jab", "ftilt", "utilt", "dtilt", "fsmash", "usmash", "dsmash", "dash_attack",
	"nair", "fair", "bair", "uair", "dair", "uspecial", "dspecial"]

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	test_profiles_and_physics()
	test_movesets()
	test_unique_signatures_and_finishers()
	test_finisher_codes()
	test_mark()
	test_javelin()
	test_magma_and_heat()
	test_board_pistol_cannon()
	test_bulwark()
	test_iai()
	test_leap_slam_and_armor()
	test_down_specials()
	test_charge_beam()
	test_volley()
	test_nova()
	test_shadow_clone()
	test_trail_dash()
	test_singularity_and_repel()
	test_one_punch()
	test_tri_slash()
	test_sun_wheel()
	test_sling_fist()
	test_star_seal()
	test_ice_decoy()
	test_turbo()
	test_eagle()
	test_flame_wall()
	test_breath()
	test_rebirth()
	test_soul_weigh()
	test_war_horn()
	test_fox_orbit()
	test_missile_salvo()
	test_blizzard()
	test_arrow_rain()
	test_reap()
	test_ai_plays_every_kit()
	finish("kits")

func duel(fam: String, other: String = DUMMY, gap: float = 3.0):
	var m = Combat.new()
	m.start([Prompt.interpret(PROMPTS.get(fam, fam), 0), Prompt.interpret(other, 1)], null, "manual", 3)
	m.countdown = 0.0
	place(m.fighters[0], -gap * 0.5, 1)
	place(m.fighters[1], gap * 0.5, -1)
	return m

func place(f: Dictionary, x: float, facing: int, y: float = 0.0) -> void:
	f.x = x
	f.y = y
	f.vx = 0.0
	f.vy = 0.0
	f.is_grounded = absf(y) < 0.01
	f.state = "Ready"
	f.pending = {}
	f.stun = 0.0
	f.hitstop = 0
	f.facing = facing
	f.cooldowns = [0.0, 0.0]
	f._prev_in = {}

func ticks(m, n: int, events: Array = []) -> void:
	for k in range(n):
		m.tick(idle_commands(m.fighters.size()))
		events.append_array(m.events)

func has_event(events: Array, type: String) -> bool:
	for ev in events:
		if ev.type == type: return true
	return false

func test_profiles_and_physics() -> void:
	for fam in PROMPTS:
		var p: Dictionary = Prompt.interpret(PROMPTS[fam], 0)
		check(p.family == fam and p.has("archetype") and Prompt.valid(p), "%s has a kit profile (%s)" % [fam, p.get("archetype", "?")])
	var ninja: Dictionary = FighterKits.physics(Prompt.interpret(PROMPTS.ninja, 0))
	var golem: Dictionary = FighterKits.physics(Prompt.interpret(PROMPTS.golem, 0))
	var valk: Dictionary = FighterKits.physics(Prompt.interpret(PROMPTS.valkyrie, 0))
	var plain: Dictionary = FighterKits.physics(Prompt.interpret(DUMMY, 0))
	check(plain == FighterKits.DEFAULT_PHYS, "fighters without a kit keep the default physics")
	check(ninja.jump > golem.jump and ninja.gravity < golem.gravity + 1.0 and ninja.air > golem.air, "the ninja is more agile than the golem")
	check(valk.air_jumps == 3 and golem.air_jumps == 1, "wings give Boltar a third air jump, the golem has one")
	# Jump height in the simulation follows the kit.
	var heights := {}
	for fam in ["ninja", "warrok_brute"]:
		var m = duel(fam)
		m.tick([cmd({"jump": true, "jump_held": true}), cmd()])
		var top := 0.0
		for n in range(80):
			m.tick([cmd({"jump_held": true}), cmd()])
			top = maxf(top, m.fighters[0].y)
		heights[fam] = top
	check(heights.ninja > heights.warrok_brute + 0.2, "Volt Ninja jumps higher than Warrok (%.2f vs %.2f m)" % [heights.ninja, heights.warrok_brute])
	var w: Dictionary = Prompt.interpret(PROMPTS.warrok_brute, 0)
	var n2: Dictionary = Prompt.interpret(PROMPTS.ninja, 0)
	check(w.weight > n2.weight and n2.speed > w.speed, "weight and run speed come from the kit")

func test_movesets() -> void:
	var names := {}
	for fam in PROMPTS:
		var p: Dictionary = Prompt.interpret(PROMPTS[fam], 0)
		var mv: Dictionary = Combat.build_moveset(p)
		var kit: Dictionary = FighterKits.for_family(fam).moves
		var complete := true
		for key in KIT_MOVES:
			if not kit.has(key) or mv[key].name != kit[key][0]: complete = false
			if float(mv[key].windup) <= 0.0 or float(mv[key].recovery) <= 0.0: complete = false
		check(complete, "%s has its own jab, tilts, smashes, aerials and specials with frame data" % fam)
		names[mv.jab.name] = true
		check(mv.nspecial.has("name") and mv.uspecial.special and mv.dspecial.special, "%s: three specials" % fam)
	check(names.size() == PROMPTS.size(), "every package-1 fighter has a different jab (%d)" % names.size())
	var plain: Dictionary = Combat.build_moveset(Prompt.interpret(DUMMY, 0))
	check(plain.dtilt.name == "Fußfeger", "fighters without a kit keep the generated moveset")
	var golem: Dictionary = Combat.build_moveset(Prompt.interpret(PROMPTS.golem, 0))
	var ninja: Dictionary = Combat.build_moveset(Prompt.interpret(PROMPTS.ninja, 0))
	check(golem.fsmash.windup > ninja.fsmash.windup and golem.fsmash.damage > ninja.fsmash.damage, "heavy smashes are slower and stronger")
	check(float(golem.fsmash.get("armor", 0.0)) > 0.0 and not ninja.fsmash.has("armor"), "the golem's smashes have armor")

func test_unique_signatures_and_finishers() -> void:
	var mechs := {}
	var fin_names := {}
	var codes := {}
	for fam in PROMPTS:
		var mech: String = Signatures.for_family(fam).mech
		mechs[mech] = true
		for other in Signatures.SIGS:
			if other != fam and not PROMPTS.has(other) and Signatures.SIGS[other].mech == mech:
				check(false, "%s shares its signature mechanic %s with %s" % [fam, mech, other])
		var fin: Dictionary = Combat.finisher_for(Prompt.interpret(PROMPTS[fam], 0))
		fin_names[fin.name] = true
		codes[str(fin.code)] = true
		check(fin.get("variant", "") != "", "%s has its own finisher %s (%s)" % [fam, fin.name, Combat.code_text(fin.code)])
	check(mechs.size() == PROMPTS.size(), "packages 1-5 have %d different, exclusive signature mechanics" % mechs.size())
	check(fin_names.size() == PROMPTS.size() and codes.size() == PROMPTS.size(), "finisher names and codes are all different")

func test_finisher_codes() -> void:
	for fam in PROMPTS:
		var m = duel(fam, DUMMY, 2.0)
		m.initial_lives = 1
		m.finishers_enabled = true
		var w: Dictionary = m.fighters[0]
		var l: Dictionary = m.fighters[1]
		l.lives = 1
		l.x = Combat.BLAST_ZONE_RIGHT + 1.0
		l.is_grounded = false
		m.tick(idle_commands())
		var fin: Dictionary = Combat.finisher_for(w.profile)
		var toward: float = 1.0 if l.x > w.x else -1.0
		var variant := ""
		for token in fin.code:
			var c := {}
			match token:
				"U": c = {"jump": true}
				"D": c = {"down": true}
				"S": c = {"special": true}
				"A": c = {"standard": true}
				"F": c = {"move": toward}
				"B": c = {"move": -toward}
			m.tick([cmd(c), cmd()])
			for ev in m.events:
				if ev.type == "finisher": variant = ev.variant
			m.tick(idle_commands())
			for ev in m.events:
				if ev.type == "finisher": variant = ev.variant
		check(variant == fin.variant, "%s: entering %s plays the finisher variant '%s'" % [fam, Combat.code_text(fin.code), variant])

func test_mark() -> void:
	var m = duel("ninja", DUMMY, 4.0)
	var ev: Array = []
	m.queue_attack(0, true)
	ticks(m, 50, ev)
	var b: Dictionary = m.fighters[1]
	check(has_event(ev, "marked") and b.marked_by == 0, "the kunai marks the opponent")
	place(m.fighters[0], -4.0, 1)
	b.stun = 0.0
	place(b, 3.0, -1)
	b.marked_by = 0
	b.mark_timer = 2.0
	var before: float = b.damage_percent
	m.queue_attack(0, true)
	var ev2: Array = []
	ticks(m, 30, ev2)
	check(has_event(ev2, "teleport") and b.damage_percent > before + 5.0, "special again: lightning strike at the marked opponent (%.1f%%)" % (b.damage_percent - before))
	check(b.marked_by == -1, "the mark is used up")

func test_javelin() -> void:
	var m = duel("valkyrie", DUMMY, 12.0)
	m.fighters[1].x = 8.0
	var ev: Array = []
	m.queue_attack(0, true)
	ticks(m, 90, ev)
	var stuck := false
	for pr in m.projectiles:
		if pr.owner == 0 and pr.get("stuck", false): stuck = true
	check(stuck and has_event(ev, "stuck"), "the thrown spear sticks in the floor")
	# Opponent between Boltar and the spear gets hit by the recall.
	var spear_x := 0.0
	for pr in m.projectiles: if pr.get("stuck", false): spear_x = pr.x
	place(m.fighters[1], (m.fighters[0].x + spear_x) * 0.5, -1)
	var before: float = m.fighters[1].damage_percent
	m.fighters[0].cooldowns = [0.0, 3.0]
	ev.clear()
	m.queue_attack(0, true)
	ticks(m, 90, ev)
	check(has_event(ev, "recall") and m.fighters[1].damage_percent > before, "special again recalls the spear, it hits on the way back")
	check(has_event(ev, "catch") and m.fighters[0].cooldowns[1] <= 0.0, "catching the spear readies the next throw")

func test_magma_and_heat() -> void:
	var m = duel("golem", DUMMY, 5.0)
	var ev: Array = []
	m.fighters[1].x = 6.0
	m.queue_attack(0, true)
	ticks(m, 70, ev)
	var pool_x := INF
	for pr in m.projectiles: if pr.get("pooled", false): pool_x = pr.x
	check(has_event(ev, "pool") and pool_x < INF, "the lava blob leaves a burning pool")
	place(m.fighters[1], pool_x, -1)
	var before: float = m.fighters[1].damage_percent
	var hits := 0
	for n in range(120):
		m.tick(idle_commands())
		m.fighters[1].x = pool_x
		for e in m.events: if e.type == "hit" and e.target == 1: hits += 1
	check(hits >= 2 and m.fighters[1].damage_percent > before, "standing in the pool burns repeatedly (%d hits)" % hits)
	# Heat: getting hit heats Magmor up; full heat turns the special into a meltdown.
	var g: Dictionary = m.fighters[0]
	g.heat = Combat.HEAT_MAX - 1.0
	place(g, 0.0, 1)
	place(m.fighters[1], 1.2, -1)
	m.queue_attack(1, false)
	ev.clear()
	ticks(m, 40, ev)
	check(g.heat >= Combat.HEAT_MAX and has_event(ev, "heat_full"), "hits fill the heat gauge")
	place(g, 0.0, 1)
	place(m.fighters[1], -2.0, 1)  # behind: meltdown hits all around
	var hp_before: float = m.fighters[1].damage_percent
	m.queue_attack(0, true)
	ticks(m, 50)
	check(g.heat == 0.0 and m.fighters[1].damage_percent > hp_before + 10.0, "meltdown blasts all around and empties the gauge")

func test_board_pistol_cannon() -> void:
	var m = duel("pirate_captain", DUMMY, 4.0)
	var ev: Array = []
	var start_x: float = m.fighters[0].x
	m.queue_attack(0, true)
	ticks(m, 40, ev)
	check(has_event(ev, "yank") and m.fighters[0].x > start_x + 2.0, "the boarding hook pulls Seraphine to the opponent")
	var kicked := false
	for e in ev: if e.type == "hit" and e.actor == 0 and e.damage > 8.0: kicked = true
	check(kicked, "…and she follows up with a boarding kick")
	m = duel("pirate_captain", DUMMY, 6.0)
	m.start_move(0, "ftilt")
	ev.clear()
	ticks(m, 40, ev)
	check(has_event(ev, "projectile") and m.fighters[1].damage_percent > 0.0, "forward tilt fires her pistol")
	m = duel("pirate_captain", DUMMY, 6.0)
	m.start_move(0, "dspecial")
	ev.clear()
	ticks(m, 90, ev)
	check(has_event(ev, "blast") and m.fighters[1].damage_percent > 0.0, "down special calls a cannon shot")

func test_bulwark() -> void:
	var m = duel("steel_knight", DUMMY, 1.2)
	m.queue_attack(0, true)
	ticks(m, 5)
	check(m.fighters[0].bulwark > 0.0, "shield wall is up")
	m.queue_attack(1, false)
	var ev: Array = []
	ticks(m, 20, ev)
	check(has_event(ev, "bulwark_block") and m.fighters[0].damage_percent == 0.0, "frontal hits are stopped completely")
	# Shots are reflected.
	m = duel("steel_knight", "Varakh der Sternenprinz mit Nova-Strahl", 6.0)
	m.queue_attack(1, true)
	ticks(m, 30)
	m.queue_attack(0, true)
	ev.clear()
	ticks(m, 80, ev)
	check(has_event(ev, "reflect") and m.fighters[1].damage_percent > 0.0, "shots are reflected back at the shooter")
	# From behind the wall does not help.
	m = duel("steel_knight", DUMMY, 1.2)
	place(m.fighters[1], m.fighters[0].x - 1.0, 1)
	m.queue_attack(0, true)
	ticks(m, 5)
	m.queue_attack(1, false)
	ticks(m, 20)
	check(m.fighters[0].damage_percent > 0.0, "hits from behind get through")

func test_iai() -> void:
	var m = duel("samurai_dreyar", DUMMY, 6.0)
	m.queue_attack(0, true)
	ticks(m, 8)
	var ev: Array = []
	for n in range(50):
		m.tick([cmd(), cmd({"move": -1.0})])  # the opponent walks into the stance
		ev.append_array(m.events)
		if has_event(ev, "iai_cut"): break
	var s: Dictionary = m.fighters[0]
	var o: Dictionary = m.fighters[1]
	ticks(m, 10, ev)
	check(has_event(ev, "iai_cut") and o.damage_percent > 15.0, "iaido cuts the opponent who steps into reach (%.1f%%)" % o.damage_percent)
	check(has_event(ev, "iai_cut") and (s.x - o.x) * -float(s.facing) < 0.0 or s.x > -2.0, "the samurai flashes through to the other side")
	# Nobody in reach: the stance ends harmlessly.
	m = duel("samurai_dreyar", DUMMY, 9.0)
	m.queue_attack(0, true)
	ev.clear()
	ticks(m, 90, ev)
	check(not has_event(ev, "iai_cut") and m.fighters[0].state == "Ready", "the stance ends without a target")

func test_leap_slam_and_armor() -> void:
	var m = duel("warrok_brute", DUMMY, 6.0)
	m.queue_attack(0, true)
	var ev: Array = []
	ticks(m, 120, ev)
	check(has_event(ev, "slam") and absf(m.fighters[0].x - 3.0) < 2.0, "Warrok leaps onto the opponent")
	check(m.fighters[1].damage_percent > 5.0, "the landing quake hits the grounded opponent")
	# Airborne opponents are not hit by the quake.
	m = duel("warrok_brute", DUMMY, 6.0)
	m.queue_attack(0, true)
	for n in range(120):
		m.fighters[1].y = 4.0
		m.fighters[1].vy = 0.0
		m.fighters[1].is_grounded = false
		m.tick(idle_commands())
	check(m.fighters[1].damage_percent == 0.0, "the quake misses airborne opponents")
	# Armor: a jab does not stop Warrok's forward smash.
	m = duel("warrok_brute", DUMMY, 1.3)
	m.start_move(0, "fsmash")
	ticks(m, 3)
	m.queue_attack(1, false)
	ev.clear()
	ticks(m, 40, ev)
	check(has_event(ev, "armor") and m.fighters[1].damage_percent > 10.0, "armored smash goes through a jab and lands")

func test_down_specials() -> void:
	var m = duel("ninja", DUMMY, 3.0)
	var x0: float = m.fighters[0].x
	m.start_move(0, "dspecial")
	ticks(m, 8)
	check(m.fighters[0].x < x0 - 2.0 and m.fighters[0].intangible > 0.0, "Volt Ninja's smoke swap blinks back and is intangible")
	m = duel("warrok_brute")
	m.start_move(0, "dspecial")
	ticks(m, 20)
	check(m.fighters[0].rage_timer > 0.0 and m.fighters[0].armor_timer >= 0.0, "Warrok's war cry enrages him")
	m = duel("golem")
	m.start_move(0, "dspecial")
	ticks(m, 12)
	check(m.fighters[0].armor_timer > 1.0, "Magmor's magma armor lasts")
	m = duel("steel_knight", DUMMY, 1.2)
	m.start_move(0, "dspecial")
	ticks(m, 4)
	m.queue_attack(1, false)
	var ev: Array = []
	ticks(m, 30, ev)
	check(has_event(ev, "counter"), "Cardinal's down special counters")

func beam_length(m) -> float:
	for n in range(200):
		var f: Dictionary = m.fighters[0]
		if not f.pending.is_empty() and f.pending.stage == "active": return float(f.pending.ability.range)
		m.tick([cmd({"special_held": true}) if n < m.get_meta("hold", 0) else cmd(), cmd()])
	return 0.0

func test_charge_beam() -> void:
	var m = duel("kairo", DUMMY, 3.0)
	m.set_meta("hold", 0)
	m.queue_attack(0, true)
	var short_len: float = beam_length(m)
	var m2 = duel("kairo", DUMMY, 3.0)
	m2.set_meta("hold", 120)
	m2.queue_attack(0, true)
	var long_len: float = beam_length(m2)
	check(short_len > 3.0 and long_len > short_len + 6.0, "holding special charges a longer beam (%.1f → %.1f m)" % [short_len, long_len])
	ticks(m2, 30)
	check(m2.fighters[1].damage_percent > 10.0, "the charged beam hits hard (%.1f%%)" % m2.fighters[1].damage_percent)

func test_volley() -> void:
	var m = duel("varakh", DUMMY, 5.0)
	m.queue_attack(0, true)
	var shots := 0
	var blast := false
	for n in range(120):
		m.tick(idle_commands())
		for e in m.events:
			if e.type == "projectile" and e.actor == 0: shots += 1
			if e.type == "blast": blast = true
	check(shots == 6 and blast, "ki volley: six shots, the last explodes (%d)" % shots)
	check(m.fighters[1].damage_percent > 8.0, "the volley hits (%.1f%%)" % m.fighters[1].damage_percent)
	# Shots are aimed: an opponent above still gets hit.
	m = duel("varakh", DUMMY, 4.0)
	place(m.fighters[1], 2.0, -1, 2.5)
	m.queue_attack(0, true)
	for n in range(40):
		m.fighters[1].y = 2.5
		m.fighters[1].vy = 0.0
		m.fighters[1].is_grounded = false
		m.tick(idle_commands())
	check(m.fighters[1].damage_percent > 0.0, "volley shots aim at an airborne opponent")

func test_nova() -> void:
	var m = duel("xylar", DUMMY, 5.0)
	m.queue_attack(0, true)
	ticks(m, 30)
	var orb: Dictionary = {}
	for pr in m.projectiles: if pr.owner == 0: orb = pr
	check(not orb.is_empty() and orb.y > m.fighters[0].y + 2.0, "the nova orb floats above Xylar's head")
	var small: float = float(orb.get("size_now", 0.0))
	ticks(m, 25)
	check(float(orb.get("size_now", 0.0)) > small + 0.1, "it grows (%.2f → %.2f)" % [small, float(orb.get("size_now", 0.0))])
	var ev: Array = []
	ticks(m, 120, ev)
	check(has_event(ev, "nova_launch") and has_event(ev, "blast") and m.fighters[1].damage_percent > 8.0, "then it is hurled and explodes (%.1f%%)" % m.fighters[1].damage_percent)

func test_shadow_clone() -> void:
	var m = duel("ren", DUMMY, 8.0)
	m.queue_attack(0, true)
	var ev: Array = []
	ticks(m, 40, ev)
	var clone: Dictionary = {}
	for pr in m.projectiles: if pr.owner == 0 and pr.get("echoing", false): clone = pr
	check(has_event(ev, "clone_ready") and not clone.is_empty(), "the shadow clone dashes out and stays")
	# Ren attacks far away; the clone next to the opponent copies the attack.
	place(m.fighters[1], clone.x + 0.9, -1)
	place(m.fighters[0], -8.0, 1)
	var before: float = m.fighters[1].damage_percent
	m.start_move(0, "ftilt")
	ev.clear()
	ticks(m, 30, ev)
	check(has_event(ev, "echo_strike") and m.fighters[1].damage_percent > before, "the clone copies Ren's attack where it stands")
	var cx: float = clone.x
	place(m.fighters[0], -8.0, 1)
	m.start_move(0, "dspecial")
	ev.clear()
	ticks(m, 10, ev)
	check(has_event(ev, "clone_swap") and absf(m.fighters[0].x - cx) < 0.5, "down special swaps places with the clone")

func test_trail_dash() -> void:
	var m = duel("amethya", DUMMY, 9.0)
	m.queue_attack(0, true)
	ticks(m, 40)
	var sparks := 0
	var sx := 0.0
	for pr in m.projectiles:
		if pr.owner == 0 and str(pr.kind) == "trail":
			sparks += 1
			sx = pr.x
	check(sparks >= 3, "the thunder dash leaves a spark trail (%d)" % sparks)
	place(m.fighters[1], sx, -1)
	var before: float = m.fighters[1].damage_percent
	for n in range(40):
		m.fighters[1].x = sx
		m.tick(idle_commands())
	check(m.fighters[1].damage_percent > before, "standing in the trail shocks")

func test_singularity_and_repel() -> void:
	var m = duel("oryn", DUMMY, 6.0)
	var start_gap: float = absf(m.fighters[1].x - m.fighters[0].x)
	m.queue_attack(0, true)
	var min_gap := start_gap
	var ev: Array = []
	for n in range(150):
		m.tick(idle_commands())
		ev.append_array(m.events)
		min_gap = minf(min_gap, absf(m.fighters[1].x - m.fighters[0].x))
	check(min_gap < start_gap - 1.0, "the singularity drags the opponent in (%.1f → %.1f)" % [start_gap, min_gap])
	check(has_event(ev, "blast") and m.fighters[1].damage_percent > 5.0, "…and explodes")
	m = duel("oryn", "Varakh der Sternenprinz mit Nova-Strahl", 6.0)
	m.queue_attack(1, true)
	ticks(m, 30)
	m.start_move(0, "dspecial")
	ev.clear()
	ticks(m, 80, ev)
	check(has_event(ev, "reflect"), "Oryn's repulsion sends shots back")

func test_one_punch() -> void:
	var m = duel("bruno", DUMMY, 1.4)
	m.fighters[1].damage_percent = 40.0
	for n in range(4): m.tick([cmd(), cmd({"block": true})])
	m.queue_attack(0, true)
	var ev: Array = []
	for n in range(60):
		m.tick([cmd(), cmd({"block": true})])
		ev.append_array(m.events)
	check(has_event(ev, "shield_pierce") and m.fighters[1].damage_percent > 50.0, "the serious punch breaks through the shield")
	m = duel("bruno", DUMMY, 1.4)
	m.fighters[1].damage_percent = 130.0
	m.queue_attack(0, true)
	ev.clear()
	ticks(m, 200, ev)
	check(has_event(ev, "one_punch_ko") and m.fighters[1].lives == 2, "past 120 % it is a sure KO")

## Ticks until fighter 0 can act again (max n ticks).
func until_ready(m, n: int, events: Array = []) -> void:
	for k in range(n):
		if m.fighters[0].pending.is_empty() and m.fighters[0].state == "Ready": return
		m.tick(idle_commands())
		events.append_array(m.events)

func test_tri_slash() -> void:
	var m = duel("jubei", DUMMY, 2.5)
	var ev: Array = []
	for k in range(3):
		m.queue_attack(0, true)
		m.tick(idle_commands())
		ev.append_array(m.events)
		until_ready(m, 60, ev)
	var stages := {}
	var hits := 0
	for e in ev:
		if e.type == "signature" and str(e.mech).begins_with("tri_slash"): stages[e.mech] = true
		if e.type == "hit" and e.actor == 0: hits += 1
	check(stages.size() == 3, "special three times: three different cuts (%s)" % str(stages.keys()))
	check(hits >= 3 and m.fighters[1].damage_percent > 15.0, "all three cuts land (%d hits, %.1f%%)" % [hits, m.fighters[1].damage_percent])
	# Waiting too long breaks the chain: the next special starts over.
	m = duel("jubei", DUMMY, 2.5)
	m.queue_attack(0, true)
	ticks(m, 150)
	check(m.fighters[0].chain_stage == 0, "the chain ends after the window")

func test_sun_wheel() -> void:
	var m = duel("hikaru", DUMMY, 2.4)
	m.queue_attack(0, true)
	var top := 0.0
	var hits := 0
	for n in range(70):
		m.tick(idle_commands())
		top = maxf(top, m.fighters[0].y)
		for e in m.events: if e.type == "hit" and e.actor == 0: hits += 1
	check(top > 0.8, "the sun wheel rolls up in an arc (%.2f m)" % top)
	check(hits >= 2, "and hits several times (%d)" % hits)

func test_sling_fist() -> void:
	var m = duel("tobi", DUMMY, 3.0)
	m.set_meta("hold", 0)
	m.queue_attack(0, true)
	var short_len: float = beam_length(m)
	var m2 = duel("tobi", DUMMY, 7.0)
	m2.set_meta("hold", 120)
	m2.queue_attack(0, true)
	var long_len: float = beam_length(m2)
	check(long_len > short_len + 3.5, "holding special stretches the fist further (%.1f → %.1f m)" % [short_len, long_len])
	ticks(m2, 30)
	check(m2.fighters[1].damage_percent > 10.0, "the fully stretched fist hits far away (%.1f%%)" % m2.fighters[1].damage_percent)
	var m3 = duel("tobi", DUMMY, 1.2)
	m3.set_meta("hold", 120)
	m3.queue_attack(0, true)
	beam_length(m3)
	ticks(m3, 30)
	check(m3.fighters[1].damage_percent == 0.0, "only the fist hits: an opponent right in front is passed over")

func test_star_seal() -> void:
	var m = duel("raiga", DUMMY, 6.0)
	m.queue_attack(0, true)
	ticks(m, 20)
	var seal: Dictionary = {}
	for pr in m.projectiles: if pr.owner == 0 and pr.spec.get("seal", false): seal = pr
	check(not seal.is_empty(), "the star seal lies on the floor")
	check(m.fighters[0].rage_timer > 0.0, "Raiga in the seal is enraged")
	place(m.fighters[1], seal.x + 0.8, -1)
	var before: float = m.fighters[1].damage_percent
	for n in range(90):
		m.fighters[1].x = seal.x + 0.8
		m.tick(idle_commands())
	check(m.fighters[1].damage_percent > before + 2.0, "opponents in the seal are shocked repeatedly (%.1f%%)" % (m.fighters[1].damage_percent - before))
	place(m.fighters[0], seal.x - 6.0, 1)
	ticks(m, 30)
	check(m.fighters[0].rage_timer == 0.0, "outside the seal the rage fades")

func test_ice_decoy() -> void:
	var m = duel("glaciem", DUMMY, 3.0)
	var x0: float = m.fighters[0].x
	m.queue_attack(0, true)
	ticks(m, 12)
	var decoy: Dictionary = {}
	for pr in m.projectiles: if pr.owner == 0 and str(pr.spec.get("shape", "")) == "ice_decoy": decoy = pr
	check(not decoy.is_empty() and absf(decoy.x - x0) < 0.2, "an ice statue stays where Glaciem stood")
	check(m.fighters[0].x < x0 - 2.0, "Glaciem blinks back (%.1f m)" % (x0 - m.fighters[0].x))
	var frozen := false
	for n in range(80):
		m.tick([cmd(), cmd({"move": -1.0})])
		if m.fighters[1].freeze_timer > 0.0: frozen = true
		if frozen: break
	check(frozen, "the opponent touching the statue freezes")

func test_turbo() -> void:
	var dist := {}
	for turbo in [false, true]:
		var m = duel("zip", DUMMY, 12.0)
		m.fighters[1].x = 8.0
		if turbo:
			m.queue_attack(0, true)
			until_ready(m, 40)
		var x0: float = m.fighters[0].x
		for n in range(40): m.tick([cmd({"move": 1.0}), cmd()])
		dist[turbo] = m.fighters[0].x - x0
	check(dist[true] > dist[false] * 1.3, "turbo boots: faster running (%.1f vs %.1f m)" % [dist[true], dist[false]])
	var m2 = duel("zip", DUMMY, 6.0)
	m2.queue_attack(0, true)
	until_ready(m2, 40)
	var ev: Array = []
	for n in range(90):
		m2.tick([cmd({"move": 1.0}), cmd()])
		ev.append_array(m2.events)
	check(has_event(ev, "turbo_ram") and m2.fighters[1].damage_percent > 0.0, "running into the opponent at full speed knocks it away")

func test_flame_wall() -> void:
	var m = duel("dragon", "Varakh der Sternenprinz mit Nova-Strahl", 6.0)
	m.queue_attack(0, true)
	ticks(m, 25)
	var wall: Dictionary = {}
	for pr in m.projectiles: if pr.owner == 0 and pr.spec.get("wall", false): wall = pr
	check(not wall.is_empty() and wall.x > m.fighters[0].x, "the fire wall stands in front of the Templar")
	m.queue_attack(1, true)
	var ev: Array = []
	ticks(m, 80, ev)
	check(has_event(ev, "wall_block") and m.fighters[0].damage_percent == 0.0, "the wall stops enemy shots")
	m = duel("dragon", DUMMY, 6.0)
	m.queue_attack(0, true)
	ticks(m, 25)
	for pr in m.projectiles: if pr.owner == 0 and pr.spec.get("wall", false): wall = pr
	var hits := 0
	for n in range(100):
		place(m.fighters[1], wall.x, -1)
		m.tick(idle_commands())
		for e in m.events: if e.type == "hit" and e.actor == 0: hits += 1
	check(hits >= 2, "standing in the wall burns repeatedly (%d)" % hits)

func test_breath() -> void:
	var m = duel("pyrax", DUMMY, 2.4)
	m.queue_attack(0, true)
	var hits := 0
	for n in range(90):
		place(m.fighters[1], m.fighters[0].x + 2.4, -1)
		m.tick(idle_commands())
		for e in m.events: if e.type == "hit" and e.actor == 0: hits += 1
	check(hits >= 3, "Pyrax's fire breath burns several times over its length (%d hits at 2.4 m)" % hits)
	var fall := {}
	for breathe in [true, false]:
		m = duel("pyrax", DUMMY, 4.0)
		place(m.fighters[0], -5.0, 1) # over open floor, no platform below
		m.fighters[0].y = 4.5
		m.fighters[0].is_grounded = false
		m.fighters[0].vy = -2.0
		if breathe: m.queue_attack(0, true)
		ticks(m, 40)
		fall[breathe] = 4.5 - float(m.fighters[0].y)
	check(fall[true] < fall[false] - 0.8, "breathing in the air makes Pyrax hover (fell %.2f m vs %.2f m)" % [fall[true], fall[false]])

func test_rebirth() -> void:
	var m = duel("phoenix", DUMMY, 1.6)
	m.fighters[0].damage_percent = 100.0
	m.queue_attack(0, true)
	var ev: Array = []
	ticks(m, 40, ev)
	check(has_event(ev, "rebirth_heal") and m.fighters[0].damage_percent < 80.0, "rebirth heals Scarlet (%.0f %% left of 100)" % m.fighters[0].damage_percent)
	check(m.fighters[1].damage_percent > 0.0, "the burst of the rebirth hits whoever stands next to her")
	check(m.fighters[0].cooldowns[1] > 5.0, "rebirth has a long cooldown (%.1f s)" % m.fighters[0].cooldowns[1])
	var m2 = duel("phoenix", DUMMY, 1.6)
	m2.fighters[0].damage_percent = 5.0
	m2.queue_attack(0, true)
	ticks(m2, 40)
	check(m2.fighters[0].damage_percent >= 0.0, "rebirth never heals below 0 %")

func test_soul_weigh() -> void:
	var gain := {}
	for pct in [0.0, 120.0]:
		var m = duel("anubis", DUMMY, 3.0)
		m.fighters[1].damage_percent = pct
		m.queue_attack(0, true)
		var ev: Array = []
		ticks(m, 40, ev)
		gain[pct] = float(m.fighters[1].damage_percent) - pct
		if pct > 0.0: check(has_event(ev, "soul_weigh"), "the hook weighs the opponent's heart")
	check(gain[0.0] > 0.0 and gain[120.0] > gain[0.0] * 1.6, "the weighing hits harder the more damage the opponent has (%.1f vs %.1f)" % [gain[0.0], gain[120.0]])

func test_war_horn() -> void:
	var m = duel("brunhild", DUMMY, 2.6)
	var x0: float = m.fighters[1].x
	m.queue_attack(0, true)
	var ev: Array = []
	ticks(m, 30, ev)
	check(has_event(ev, "war_horn") and m.fighters[1].damage_percent > 0.0, "the horn blast hits at 2.6 m")
	check(float(m.fighters[0].armor_timer) > 1.5, "after the horn Brunhild has armor (%.1f s)" % m.fighters[0].armor_timer)
	ticks(m, 20)
	check(m.fighters[1].x > x0 + 1.0, "the horn throws the opponent far away (%.1f m)" % (m.fighters[1].x - x0))

func test_fox_orbit() -> void:
	var m = duel("celestial_fox", DUMMY, 1.3)
	m.queue_attack(0, true)
	ticks(m, 20)
	var orbs := 0
	for pr in m.projectiles:
		if pr.owner == 0 and bool(pr.spec.get("orbit", false)): orbs += 1
	check(orbs == 3, "three foxfires circle the fox (%d)" % orbs)
	var hits := 0
	for n in range(120):
		place(m.fighters[1], m.fighters[0].x + 1.3, -1)
		m.tick(idle_commands())
		for e in m.events: if e.type == "hit" and e.actor == 0: hits += 1
	check(hits >= 2, "the circling foxfire burns whoever stands close (%d hits)" % hits)
	var m2 = duel("celestial_fox", DUMMY, 6.0)
	m2.queue_attack(0, true)
	ticks(m2, 40)
	var ok: bool = m2.queue_attack(0, true)
	var ev: Array = []
	ticks(m2, 90, ev)
	var released := false
	for e in ev: if e.type == "signature" and e.mech == "fox_release": released = true
	check(ok and released and m2.fighters[1].damage_percent > 0.0, "special again hurls the foxfires at the opponent 6 m away (%.0f %%)" % m2.fighters[1].damage_percent)

func test_missile_salvo() -> void:
	var m = duel("cyborg_mech", DUMMY, 5.0)
	m.queue_attack(0, true)
	var ev: Array = []
	for n in range(150):
		place(m.fighters[1], m.fighters[0].x + 5.0, -1)
		m.tick(idle_commands())
		ev.append_array(m.events)
	var blasts := 0
	for e in ev: if e.type == "blast" and e.actor == 0: blasts += 1
	check(blasts >= 2 and m.fighters[1].damage_percent > 0.0, "the rockets home in and explode on the opponent (%d blasts)" % blasts)

func test_blizzard() -> void:
	var m = duel("frostwyrm", DUMMY, 4.0)
	m.queue_attack(0, true)
	var hits := 0
	var frozen := false
	for n in range(200):
		place(m.fighters[1], 3.0 if n < 100 else 4.5, -1)
		m.tick(idle_commands())
		for e in m.events:
			if e.type == "hit" and e.actor == 0: hits += 1
			if e.type == "freeze_hit" and e.actor == 0: frozen = true
	check(hits >= 3 and frozen, "the snow storm follows the opponent and hails on them (%d hits, freeze %s)" % [hits, frozen])

func test_arrow_rain() -> void:
	var m = duel("lepora", DUMMY, 5.0)
	m.queue_attack(0, true)
	var arrows := 0
	var hits := 0
	for n in range(90):
		place(m.fighters[1], m.fighters[0].x + 5.0, -1)
		m.tick(idle_commands())
		for e in m.events:
			if e.type == "projectile" and e.actor == 0: arrows += 1
			if e.type == "hit" and e.actor == 0: hits += 1
	check(arrows == 7 and hits >= 2, "seven arrows rain on the opponent 5 m away (%d arrows, %d hits)" % [arrows, hits])

func test_reap() -> void:
	var m = duel("nyx", DUMMY, 2.8)
	m.fighters[0].damage_percent = 60.0
	m.queue_attack(0, true)
	ticks(m, 40)
	check(m.fighters[1].damage_percent > 0.0, "the scythe sweep reaches 2.8 m")
	check(m.fighters[0].damage_percent < 60.0, "the harvest heals Nyx (%.1f %% left of 60)" % m.fighters[0].damage_percent)

func test_ai_plays_every_kit() -> void:
	for fam in PROMPTS:
		var m = duel(fam, DUMMY, 4.0)
		m.ai_level = 7
		var hits := 0
		for n in range(1500):
			m.tick(m.agent_commands())
			for e in m.events: if e.type == "hit" and e.actor == 0: hits += 1
			if m.result != -2: break
		check(hits > 0, "the AI lands hits with %s (%d)" % [fam, hits])

func test_eagle() -> void:
	var p: Dictionary = Prompt.interpret(PROMPTS.arber, 0)
	check(p.family == "arber" and Prompt.interpret("Albaner mit zwei Bohrmaschinen", 0).family == "arber", "Arbër is found by name and by his drills")
	var m = duel("arber", DUMMY, 2.0)
	var ev: Array = []
	m.queue_attack(0, true)
	ticks(m, 30, ev)
	check(has_event(ev, "eagle_summon") and m.fighters[0].eagle > 0.0, "the special calls the double-headed eagle")
	# Gliding: with the eagle he stays in the air far longer than a normal jump.
	ticks(m, 90, ev)
	check(not m.fighters[0].is_grounded and m.fighters[0].y > 0.8, "the eagle carries him through the air (y %.1f after 2 s)" % m.fighters[0].y)
	var y0: float = m.fighters[0].y
	for n in range(30): m.tick([cmd({"jump_held": true, "up": true}), cmd()])
	check(m.fighters[0].y > y0 + 0.5, "jump makes the eagle climb (%.1f → %.1f)" % [y0, m.fighters[0].y])
	check(has_event(ev, "eagle_strike") and m.fighters[1].damage_percent > 0.0, "the eagle dives at the opponent in reach (%.0f %%)" % m.fighters[1].damage_percent)
	ticks(m, 360, ev)
	check(has_event(ev, "eagle_leave") and m.fighters[0].eagle == 0.0, "the eagle leaves when the time is up")
	# Drills: the jab is a multi-hit.
	var m2 = duel("arber", DUMMY, 1.2)
	var hits := 0
	m2.start_move(0, "jab")
	for n in range(40):
		m2.tick(idle_commands(2))
		for e in m2.events: if e.type == "hit" and e.get("actor", -1) == 0: hits += 1
	check(hits >= 3, "the twin drills hit several times in a row (%d hits)" % hits)
