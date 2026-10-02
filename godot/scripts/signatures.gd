extends RefCounted
## Signature specials: every fighter family gets its own special move built from a
## mechanic plus individual shape, color and numbers. The combat core (combat.gd)
## executes the mechanics, main.gd draws them.
##
## Mechanics:
##   projectile  – flying shot. Options: shape, speed, life, size, count (spread), gravity,
##                 pierce, homing, wave (sine), turn (returns), freeze, explode (radius),
##                 fuse (explodes after time), swap (swap places on hit), pull (drags target)
##   meteor      – projectile dropping from above onto the area in front
##   beam        – long instant hitbox in front (length, thick)
##   dash        – rushes forward hitting everything on the way (speed, multi = rehits)
##   teleport    – blinks behind the nearest opponent and strikes
##   eruption    – ground wave of pillars travelling forward (count, speed)
##   whirl       – spinning all-around multi-hit (radius, time, pull > 0 draws opponents in; push_mult scales the launch)
##   barrage     – rapid hits in front (hits)
##   power       – slow, huge single strike
##   counter     – guard stance; a hit during it is answered automatically
##   mine        – places a trap that explodes on contact (or after fuse)
##   turret      – places a turret that fires bolts for a few seconds
##   rage        – temporary power and speed boost
##   clone       – a shadow double runs forward and strikes
##   mark        – kunai that marks the opponent; special again = lightning strike at the mark
##   javelin     – throws the spear, it sticks in the floor; special again = recall, hits on the way back,
##                 catching it readies the next throw
##   magma       – lava blob that leaves a burning pool; at full heat gauge special = meltdown blast
##   board       – boarding hook: on hit the attacker is pulled over and kicks
##   bulwark     – shield wall: frontal hits are stopped, shots reflected, then a shield bash
##   iai         – iaido stance: the first opponent stepping into reach is cut in one flash
##   leap_slam   – leaps onto the opponent; landing quake hits every grounded opponent nearby
##   charge_beam – hold special to charge: longer, stronger beam (full charge crosses the stage)
##   volley      – six aimed ki shots in a row, the last one explodes
##   nova        – orb grows above the head, then is hurled; bigger = more damage and blast
##   shadow_clone – clone dashes forward, then stays and copies the owner's attacks
##   trail_dash  – dash that leaves a shocking spark trail on the ground
##   singularity – gravity core that drags opponents in, then explodes
##   one_punch   – slow punch that breaks shields; knockback grows with percent, sure KO past a threshold
##   tri_slash   – sword dash; special again within `window` dashes again, the third cut launches upward
##   sun_wheel   – flaming wheel: rolls forward in a rising arc, hitting all around
##   sling_fist  – hold special to wind up: the fist flies further and hits hardest with its tip
##   star_seal   – star mandala on the floor: shocks opponents inside, Raiga in it is enraged
##   ice_decoy   – leaves an ice statue and blinks back; whoever touches the statue freezes
##   eagle       – the double-headed eagle carries the fighter: free flight (jump/up rises, down sinks),
##                 faster in the air, the eagle dives at opponents in reach every `rehit` seconds
##   turbo       – turbo boots: faster running, full-speed body hits knock opponents away
##   flame_wall  – sword plunged into the floor: a fire wall that burns and stops enemy shots

const SIGS := {
	"ninja": {"mech": "mark", "shape": "kunai", "color": Color("49def4"), "speed": 20.0, "life": 0.5, "size": 0.35, "push": 0.1, "mark": true, "dmg": 0.45},
	"golem": {"mech": "magma", "shape": "lava_blob", "color": Color("ff6d2b"), "speed": 7.0, "rise": 4.0, "life": 2.0, "size": 0.5, "gravity": 14.0,
		"pool": {"life": 4.0, "size": 1.2, "rehit": 0.5, "dmg": 0.35}, "dmg": 0.7},
	"valkyrie": {"mech": "javelin", "shape": "lance", "color": Color("ffe26a"), "speed": 12.0, "rise": 2.0, "gravity": 14.0, "life": 2.0, "size": 0.55,
		"pierce": true, "javelin": true, "dmg": 0.85},
	"dragon": {"mech": "flame_wall", "shape": "flame_wall", "color": Color("ff5a1f"), "life": 3.0, "size": 0.55, "rehit": 0.45, "dmg": 0.4, "windup": 0.22},
	"kairo": {"mech": "charge_beam", "color": Color("7dd3fc"), "length": 5.0, "max_length": 14.0, "thick": 0.8, "charge": 1.4, "dmg": 0.8, "windup": 0.25},
	"varakh": {"mech": "volley", "shape": "orb", "color": Color("ffe838"), "count": 6, "interval": 0.1, "speed": 15.0, "life": 0.9, "size": 0.3, "final_explode": 2.0, "final_mult": 2.5, "dmg": 0.16},
	"xylar": {"mech": "nova", "shape": "orb", "color": Color("c084fc"), "hold": 1.0, "grow": 0.5, "size": 0.3, "max_size": 1.1, "speed": 8.0, "life": 3.0, "explode": 1.4, "dmg": 0.55, "windup": 0.12},
	"glaciem": {"mech": "ice_decoy", "shape": "ice_decoy", "color": Color("9be7ff"), "life": 3.5, "size": 0.55, "freeze": 1.3, "blink": 2.6, "dmg": 0.55, "windup": 0.05},
	"oryn": {"mech": "singularity", "color": Color("9900ee"), "gravity_pull": 9.0, "pull_radius": 4.0, "fuse": 1.6, "explode": 2.6, "dmg": 1.0},
	"tobi": {"mech": "sling_fist", "color": Color("ff2b2b"), "length": 3.0, "max_length": 7.5, "charge": 1.2, "tip": 1.5, "dmg": 1.1, "windup": 0.2},
	"jubei": {"mech": "tri_slash", "color": Color("3bfac8"), "speed": 11.0, "window": 0.9, "dmg": 0.75, "windup": 0.07},
	"ren": {"mech": "shadow_clone", "color": Color("ff9b3d"), "speed": 10.0, "dash_time": 0.45, "life": 5.0, "echo_mult": 0.5, "dmg": 0.8},
	"amethya": {"mech": "trail_dash", "color": Color("60d5ff"), "speed": 17.0, "multi": 1, "trail_life": 2.0, "trail_dmg": 0.18, "dmg": 1.0},
	"bruno": {"mech": "one_punch", "color": Color("ffd23f"), "ko_at": 120.0, "kb_scale": 70.0, "dmg": 1.5, "windup": 0.55},
	"hikaru": {"mech": "sun_wheel", "color": Color("ff6524"), "radius": 1.5, "time": 0.55, "speed": 7.5, "rise": 6.5, "dmg": 1.15},
	"arber": {"mech": "eagle", "color": Color("e41e20"), "time": 6.5, "rehit": 1.0, "reach": 3.4, "dmg": 0.55, "lift": 0.12, "boost": 1.3, "windup": 0.28},
	"zip": {"mech": "turbo", "color": Color("3b82f6"), "time": 4.0, "boost": 1.6, "min_speed": 4.5, "rehit": 0.6, "dmg": 0.45},
	"raiga": {"mech": "star_seal", "shape": "star_seal", "color": Color("00e5ff"), "life": 5.0, "size": 1.7, "rehit": 0.7, "dmg": 0.25},
	"albion": {"mech": "beam", "color": Color("e0f2fe"), "length": 8.0, "thick": 1.4, "dmg": 1.15, "windup": 0.45},
	"pyrax": {"mech": "projectile", "shape": "fireball", "color": Color("ff6610"), "speed": 9.0, "life": 1.4, "size": 0.6, "gravity": 9.0, "rise": 5.0, "explode": 2.0, "dmg": 1.0},
	"anubis": {"mech": "projectile", "shape": "hook", "color": Color("c9a227"), "speed": 16.0, "life": 0.5, "size": 0.5, "pull": true, "dmg": 0.6},
	"phoenix": {"mech": "projectile", "shape": "firebird", "color": Color("ff8a1f"), "speed": 11.0, "life": 1.2, "size": 0.7, "wave": 1.0, "pierce": true, "dmg": 0.9},
	"specter": {"mech": "teleport", "color": Color("9b30ff"), "dmg": 1.1},
	"brunhild": {"mech": "eruption", "color": Color("ffd24a"), "count": 4, "speed": 7.0, "dmg": 0.8},
	"lepora": {"mech": "projectile", "shape": "arrow", "color": Color("86efac"), "speed": 24.0, "life": 0.8, "size": 0.4, "gravity": 3.0, "pierce": true, "dmg": 0.8},
	"thorn_witch": {"mech": "mine", "color": Color("4ade80"), "shape": "thorns", "dmg": 1.0},
	"nyx": {"mech": "projectile", "shape": "scythe", "color": Color("a855f7"), "speed": 13.0, "life": 1.4, "size": 0.7, "turn": 0.5, "pierce": true, "dmg": 0.8},
	"shira": {"mech": "barrage", "color": Color("f472b6"), "hits": 5, "range": 1.9, "dmg": 1.0},
	"frostwyrm": {"mech": "beam", "color": Color("7dd3fc"), "length": 5.5, "thick": 1.1, "freeze": 0.8, "dmg": 0.9},
	"cyborg_mech": {"mech": "beam", "color": Color("22d3ee"), "length": 10.0, "thick": 0.3, "dmg": 0.8, "windup": 0.2},
	"reaper_hound": {"mech": "dash", "color": Color("d6d3d1"), "speed": 12.0, "multi": 2, "dmg": 1.0},
	"treant": {"mech": "eruption", "color": Color("65a30d"), "count": 3, "speed": 6.0, "dmg": 0.9},
	"celestial_fox": {"mech": "projectile", "shape": "foxfire", "color": Color("38bdf8"), "speed": 8.0, "life": 1.5, "size": 0.45, "count": 3, "homing": 6.0, "dmg": 0.45},
	"mossback": {"mech": "rage", "color": Color("84cc16"), "time": 6.0},
	"steel_knight": {"mech": "bulwark", "color": Color("e2e8f0"), "time": 0.75, "dmg": 1.2},
	"vanguard_soldier": {"mech": "projectile", "shape": "grenade", "color": Color("fbbf24"), "speed": 8.0, "life": 1.6, "size": 0.4, "gravity": 12.0, "rise": 6.0, "explode": 2.4, "dmg": 1.0},
	"sorceress_medea": {"mech": "projectile", "shape": "orb", "color": Color("c084fc"), "speed": 6.0, "life": 2.2, "size": 0.55, "homing": 9.0, "dmg": 0.9},
	"skeleton_reaper": {"mech": "whirl", "color": Color("a78bfa"), "radius": 2.6, "time": 0.55, "pull": 5.0, "dmg": 1.0},
	"mutant_titan": {"mech": "rage", "color": Color("84cc16"), "time": 7.0},
	"swat_specops": {"mech": "projectile", "shape": "bullet", "color": Color("fb923c"), "speed": 26.0, "life": 0.45, "size": 0.3, "count": 3, "spread": 0.12, "dmg": 0.35},
	"samurai_dreyar": {"mech": "iai", "color": Color("99f6e4"), "time": 0.9, "range": 3.8, "dmg": 1.5, "windup": 0.08},
	"pirate_captain": {"mech": "board", "shape": "hook", "color": Color("d6d3d1"), "speed": 18.0, "life": 0.45, "size": 0.5, "push": 0.05, "yank": true, "dmg": 0.5},
	"vampire_lord": {"mech": "projectile", "shape": "bat", "color": Color("dc2626"), "speed": 9.0, "life": 1.6, "size": 0.45, "count": 3, "homing": 7.0, "lifesteal": 0.5, "dmg": 0.4},
	"wizard_sorcerer": {"mech": "meteor", "color": Color("ff7a1a"), "size": 0.9, "explode": 2.2, "dmg": 1.2},
	"warrok_brute": {"mech": "leap_slam", "color": Color("f97316"), "rise": 11.5, "radius": 6.0, "dmg": 1.1, "windup": 0.18},
	# ── the five new fighters ──
	"nekra": {"mech": "eruption", "color": Color("e7e5e4"), "shape": "bone", "count": 5, "speed": 11.0, "dmg": 0.6},
	"grimbolt": {"mech": "mine", "color": Color("f59e0b"), "shape": "bomb", "fuse": 1.6, "explode": 3.0, "dmg": 1.3},
	"echo": {"mech": "projectile", "shape": "glitch", "color": Color("5eead4"), "speed": 15.0, "life": 0.7, "size": 0.6, "swap": true, "dmg": 0.6},
	"kettenwart": {"mech": "whirl", "color": Color("78716c"), "radius": 3.6, "time": 0.5, "pull": 18.0, "dmg": 0.7},
	"don_valente": {"mech": "turret", "color": Color("facc15"), "dmg": 0.35},
}

## Body pose shown while a special runs, per mechanic.
const MECH_POSE := {
	"projectile": "Cast", "meteor": "Summon", "beam": "Beam", "dash": "Dash", "teleport": "SpecialAttack",
	"eruption": "Slam", "whirl": "Spin", "barrage": "Barrage", "power": "HeavyPunch", "counter": "Counter",
	"mine": "Crouch", "turret": "Cast", "rage": "Roar", "clone": "SpecialAttack",
	"mark": "Cast", "mark_strike": "SpecialAttack", "javelin": "Cast", "recall": "Cast", "magma": "Cast", "meltdown": "Slam",
	"board": "Cast", "cannon": "Summon", "bulwark": "Block", "iai": "Charge", "leap_slam": "Rise",
	"charge_beam": "Beam", "volley": "Barrage", "nova": "Summon", "shadow_clone": "SpecialAttack", "trail_dash": "Dash",
	"singularity": "Cast", "one_punch": "HeavyPunch",
	"tri_slash": "Dash", "tri_slash_2": "Dash", "tri_slash_3": "Rise", "sun_wheel": "Spin", "sling_fist": "HeavyPunch",
	"star_seal": "Slam", "ice_decoy": "Dodge", "turbo": "Dash", "flame_wall": "Slam", "eagle": "Summon",
}

static func for_family(family: String) -> Dictionary:
	return SIGS.get(family, {})
