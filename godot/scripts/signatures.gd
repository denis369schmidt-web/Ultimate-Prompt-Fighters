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
##   breath      – fire breath: a long cone in front that hits many times; in the air Pyrax hovers while breathing
##   rebirth     – burst of phoenix fire all around; heals damage (more the more hurt), long cooldown
##   soul_weigh  – jackal hook that drags the opponent in; damage grows with the opponent's percent
##   war_horn    – horn blast: a wide wave in front that throws opponents far, then armor for a few seconds
##   fox_orbit   – three foxfires circle the fighter and burn whoever touches them;
##                 special again hurls them at the nearest opponent (homing)
##   missile_salvo – rockets launch upward, then home in on the nearest opponent and explode
##   blizzard    – snow cloud above the opponent that follows them, hail hits and freezes briefly
##   arrow_rain  – arrows rain down in a row over the opponent's position, one after another
##   reap        – wide scythe sweep that drags opponents in and heals by part of the damage
##   bramble     – a hedge of thorn bushes grows along the floor ahead, they burn whoever stands in them
##   root_snare  – roots break out under the opponent after a short warning and hold them fast
##   stampede    – long armored charge that keeps its speed and tramples everything in the way
##   hex         – slow homing curse orb: a cursed opponent takes more damage for a few seconds
##   bone_prison – a bone cage closes around the opponent, holds them inside and bursts
##   toxic_cloud – poison cloud that follows its owner and eats at everyone close by
##   flashbang   – thrown stun grenade: bursts on landing or after its fuse, everyone in the blast is stunned
##   orbital_strike – marks the opponent's spot; after a warning a beam from orbit hits the whole column
##   bat_form    – turns into a bat swarm: flies forward untouchable, the bats bite all around and heal
##   revenant    – raises a skeleton servant that walks to the nearest opponent and strikes again and again
##   time_bomb   – sticky bomb: clings to whoever it hits (or lies ticking on the floor) and blows up
##   phase_swap  – glitch shot: on hit Echo and the target swap places, Echo glitches out of reach for a moment
##   chain_leash – soul chain: drags the opponent in and keeps them on a short chain for a few seconds

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
	"pyrax": {"mech": "breath", "color": Color("ff6610"), "length": 3.4, "time": 0.9, "rehit": 0.12, "hover": 2.5, "dmg": 0.24, "windup": 0.12},
	"anubis": {"mech": "soul_weigh", "shape": "hook", "color": Color("c9a227"), "speed": 16.0, "life": 0.5, "size": 0.5, "pull": true, "weigh": 120.0, "dmg": 0.7},
	"phoenix": {"mech": "rebirth", "color": Color("ff8a1f"), "radius": 2.4, "heal": 12.0, "heal_share": 0.15, "cooldown": 10.0, "dmg": 1.1, "windup": 0.3},
	"specter": {"mech": "teleport", "color": Color("9b30ff"), "dmg": 1.1},
	"brunhild": {"mech": "war_horn", "color": Color("ffd24a"), "length": 4.2, "armor": 3.0, "dmg": 0.5, "windup": 0.35},
	"lepora": {"mech": "arrow_rain", "shape": "arrow", "color": Color("86efac"), "count": 7, "width": 2.1, "height": 7.0, "speed": 16.0, "size": 0.4, "push": 0.25, "angle": 70.0, "dmg": 0.3, "windup": 0.22},
	"thorn_witch": {"mech": "bramble", "shape": "thorns", "color": Color("4ade80"), "count": 3, "gap": 1.0, "life": 4.0, "size": 0.45, "rehit": 0.6, "push": 0.35, "angle": 75.0, "dmg": 0.35, "windup": 0.2},
	"nyx": {"mech": "reap", "color": Color("a855f7"), "length": 3.2, "pull": 7.0, "lifesteal": 0.5, "dmg": 1.0, "windup": 0.25},
	"shira": {"mech": "barrage", "color": Color("f472b6"), "hits": 5, "range": 1.9, "dmg": 1.0},
	"frostwyrm": {"mech": "blizzard", "shape": "cloud", "color": Color("bae6fd"), "life": 3.2, "size": 1.1, "height": 3.2, "follow": 2.2, "rehit": 0.5, "freeze": 0.25, "push": 0.1, "angle": 80.0, "dmg": 0.3, "windup": 0.3},
	"cyborg_mech": {"mech": "missile_salvo", "shape": "missile", "color": Color("22d3ee"), "count": 4, "speed": 11.0, "life": 2.2, "size": 0.3, "home_delay": 0.35, "homing": 5.0, "explode": 1.1, "dmg": 0.4, "windup": 0.2},
	"reaper_hound": {"mech": "dash", "color": Color("d6d3d1"), "speed": 12.0, "multi": 2, "dmg": 1.0},
	"treant": {"mech": "root_snare", "shape": "roots", "color": Color("65a30d"), "delay": 0.5, "life": 0.85, "size": 0.7, "freeze": 0.9, "push": 0.2, "angle": 85.0, "dmg": 0.6, "windup": 0.3},
	"celestial_fox": {"mech": "fox_orbit", "shape": "foxfire", "color": Color("38bdf8"), "count": 3, "radius": 1.3, "spin": 4.0, "life": 5.0, "size": 0.35, "rehit": 0.5, "speed": 12.0, "homing": 6.0, "dmg": 0.45},
	"mossback": {"mech": "stampede", "color": Color("84cc16"), "speed": 8.5, "time": 0.9, "dmg": 1.0, "windup": 0.25},
	"steel_knight": {"mech": "bulwark", "color": Color("e2e8f0"), "time": 0.75, "dmg": 1.2},
	"vanguard_soldier": {"mech": "orbital_strike", "shape": "strike_marker", "color": Color("fbbf24"), "delay": 1.0, "life": 1.3, "size": 0.9, "height": 9.0, "push": 1.0, "angle": 82.0, "dmg": 1.4, "windup": 0.25},
	"sorceress_medea": {"mech": "hex", "shape": "orb", "color": Color("c084fc"), "speed": 6.0, "life": 2.4, "size": 0.5, "homing": 7.0, "hex": 5.0, "hex_mult": 1.3, "dmg": 0.6, "windup": 0.25},
	"skeleton_reaper": {"mech": "bone_prison", "shape": "bone_cage", "color": Color("a78bfa"), "life": 1.8, "size": 0.9, "explode": 1.5, "push": 0.9, "angle": 70.0, "dmg": 1.2, "windup": 0.3},
	"mutant_titan": {"mech": "toxic_cloud", "shape": "cloud", "color": Color("84cc16"), "life": 4.0, "size": 1.7, "rehit": 0.5, "push": 0.1, "angle": 60.0, "dmg": 0.22, "windup": 0.2},
	"swat_specops": {"mech": "flashbang", "shape": "grenade", "color": Color("fb923c"), "speed": 6.0, "rise": 5.0, "gravity": 14.0, "life": 1.6, "size": 0.35, "fuse": 0.01, "explode": 2.6, "freeze": 1.0, "flash": true, "push": 0.4, "angle": 60.0, "dmg": 0.5, "windup": 0.18},
	"samurai_dreyar": {"mech": "iai", "color": Color("99f6e4"), "time": 0.9, "range": 3.8, "dmg": 1.5, "windup": 0.08},
	"pirate_captain": {"mech": "board", "shape": "hook", "color": Color("d6d3d1"), "speed": 18.0, "life": 0.45, "size": 0.5, "push": 0.05, "yank": true, "dmg": 0.5},
	"vampire_lord": {"mech": "bat_form", "color": Color("dc2626"), "time": 1.0, "speed": 7.5, "radius": 1.3, "lifesteal": 0.4, "dmg": 1.0, "windup": 0.15},
	"wizard_sorcerer": {"mech": "meteor", "color": Color("ff7a1a"), "size": 0.9, "explode": 2.2, "dmg": 1.2},
	"warrok_brute": {"mech": "leap_slam", "color": Color("f97316"), "rise": 11.5, "radius": 6.0, "dmg": 1.1, "windup": 0.18},
	# ── the five new fighters ──
	"nekra": {"mech": "revenant", "shape": "skeleton", "color": Color("e7e5e4"), "life": 5.0, "size": 0.55, "walk": 3.0, "rehit": 0.8, "push": 0.45, "angle": 45.0, "dmg": 0.35, "windup": 0.3},
	"grimbolt": {"mech": "time_bomb", "shape": "bomb", "color": Color("f59e0b"), "speed": 8.0, "rise": 5.0, "gravity": 14.0, "life": 2.6, "size": 0.4, "sticky": true, "stick_fuse": 1.4, "fuse": 0.01, "explode": 2.4, "push": 0.95, "angle": 65.0, "dmg": 1.3, "windup": 0.2},
	"echo": {"mech": "phase_swap", "shape": "glitch", "color": Color("5eead4"), "speed": 15.0, "life": 0.7, "size": 0.6, "swap": true, "dmg": 0.6},
	"kettenwart": {"mech": "chain_leash", "shape": "hook", "color": Color("78716c"), "speed": 17.0, "life": 0.55, "size": 0.5, "pull": true, "leash": 3.0, "leash_len": 2.5, "dmg": 0.6},
	"don_valente": {"mech": "turret", "color": Color("facc15"), "dmg": 0.35},
	# ── Paket 9: Concept-Art-Trio ──
	"kalyx": {"mech": "crown_shift", "color": Color("7dd3fc"), "glut_color": Color("ff5a1f"), "radius": 1.8, "glut_mult": 1.2, "frost_freeze": 0.18, "dmg": 0.7, "windup": 0.1},
	"vorruk": {"mech": "pack_hound", "shape": "alien_hound", "color": Color("c084fc"), "life": 3.4, "size": 0.55, "walk": 7.5, "rehit": 0.45,
		"push": 0.3, "angle": 50.0, "dmg": 0.35, "windup": 0.3},
	"neris": {"mech": "anchor_chain", "shape": "anchor", "color": Color("a78bfa"), "speed": 18.0, "life": 0.36, "size": 0.45, "pull": true, "anchor": true,
		"zip": 15.0, "dmg": 0.6},
	# ── Paket 8: Nationen ──
	"konrad": {"mech": "anvil", "shape": "anvil", "color": Color("ffce00"), "life": 2.2, "gravity": 24.0, "size": 0.6, "height": 7.0,
		"explode": 1.8, "freeze": 0.45, "push": 0.85, "angle": 70.0, "dmg": 1.15, "windup": 0.28},
	"bogdan": {"mech": "frost_roar", "color": Color("bfdbfe"), "length": 3.6, "freeze": 0.8, "dmg": 0.8, "windup": 0.3},
	"kaan": {"mech": "crescent", "shape": "moon_crescent", "color": Color("ffffff"), "speed": 13.0, "life": 1.6, "size": 0.55, "turn": 0.42,
		"pierce": true, "push": 0.45, "angle": 40.0, "dmg": 0.6},
	"amra": {"mech": "bridge_dive", "color": Color("38bdf8"), "rise": 13.0, "dive": 24.0, "radius": 3.2, "dmg": 1.0, "windup": 0.15},
	"dusty": {"mech": "lasso", "shape": "lasso", "color": Color("d6b37a"), "speed": 17.0, "life": 0.5, "size": 0.5, "lasso": true, "push": 0.2, "dmg": 0.55},
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
	"star_seal": "Slam", "ice_decoy": "Dodge", "turbo": "Dash", "flame_wall": "Slam", "eagle": "Summon", "breath": "Beam", "rebirth": "Rise",
	"soul_weigh": "Cast", "war_horn": "Roar", "fox_orbit": "Summon", "fox_release": "Cast", "missile_salvo": "Cast",
	"blizzard": "Summon", "arrow_rain": "Cast", "reap": "Spin",
	"bramble": "Slam", "root_snare": "Slam", "stampede": "Dash", "hex": "Cast", "bone_prison": "Summon", "toxic_cloud": "Roar",
	"flashbang": "Cast", "orbital_strike": "Summon", "bat_form": "Dash", "revenant": "Summon", "time_bomb": "Cast", "phase_swap": "Cast", "chain_leash": "Cast",
}

static func for_family(family: String) -> Dictionary:
	return SIGS.get(family, {})
