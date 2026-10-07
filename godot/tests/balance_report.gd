extends SceneTree
## Balance check: every fighter plays AI against AI against every other fighter (both sides),
## without items, and the win rates are written as a ranked table.
## Usage: godot --headless --path godot -s tests/balance_report.gd -- [--games=1] [--lives=2] [--level=7]
##        [--only=a,b] [--out=<file.md>]

const Prompt = preload("res://scripts/prompt_interpreter.gd")
const Combat = preload("res://scripts/combat.gd")
const Kits = preload("res://tests/test_kits.gd")

var games := 1
var lives := 2
var level := 7
var only: Array = []
var out_path := ""

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--games="): games = int(arg.trim_prefix("--games="))
		if arg.begins_with("--lives="): lives = int(arg.trim_prefix("--lives="))
		if arg.begins_with("--level="): level = int(arg.trim_prefix("--level="))
		if arg.begins_with("--only="): only = arg.trim_prefix("--only=").split(",")
		if arg.begins_with("--out="): out_path = arg.trim_prefix("--out=")
	run()
	quit()

## One AI duel without items. Returns 0 or 1 for the winner, -1 for a draw.
func duel(a: String, b: String, seed: int) -> Dictionary:
	var m = Combat.new()
	m.start([Prompt.interpret(Kits.PROMPTS[a], 0), Prompt.interpret(Kits.PROMPTS[b], 1)], null, "autonomous", lives)
	m.ai_level = level
	m.rng.seed = seed
	m.ai_rng.seed = seed ^ 0x5bd1e995
	m.items.clear()
	var ticks := 0
	var limit := int((Combat.MATCH_TIME + 30.0) / Combat.STEP)
	while m.result == -2 and ticks < limit:
		m.item_spawn_timer = 999.0
		m.tick(m.agent_commands())
		ticks += 1
	return {"winner": m.result if m.result in [0, 1] else -1, "time": ticks * Combat.STEP}

func run() -> void:
	var fams: Array = Kits.PROMPTS.keys()
	var stats := {}
	for f in fams: stats[f] = {"w": 0, "l": 0, "d": 0, "time": 0.0, "n": 0}
	var started := Time.get_ticks_msec()
	var seed := 1
	for a in fams:
		for b in fams:
			if a == b: continue
			if not only.is_empty() and not (a in only or b in only): continue
			for g in range(games):
				seed += 1
				var r: Dictionary = duel(a, b, seed * 7919)
				for side in [[a, 0], [b, 1]]:
					var s: Dictionary = stats[side[0]]
					s.n += 1
					s.time += float(r.time)
					if r.winner == -1: s.d += 1
					elif r.winner == side[1]: s.w += 1
					else: s.l += 1
		print("BALANCE_PROGRESS ", a, " ", (Time.get_ticks_msec() - started) / 1000, " s")
	var rows: Array = []
	for f in fams:
		var s: Dictionary = stats[f]
		if s.n == 0: continue
		rows.append({"fam": f, "rate": (s.w + 0.5 * s.d) / float(s.n), "w": s.w, "l": s.l, "d": s.d, "avg": s.time / s.n})
	rows.sort_custom(func(x, y): return x.rate > y.rate)
	var md := "| # | Kämpfer | Siegquote | S | N | U | Ø Kampfdauer |\n|---|---|---|---|---|---|---|\n"
	for k in range(rows.size()):
		var r: Dictionary = rows[k]
		md += "| %d | %s | %.0f %% | %d | %d | %d | %.0f s |\n" % [k + 1, r.fam, r.rate * 100.0, r.w, r.l, r.d, r.avg]
		print("BALANCE_ROW %-18s %5.1f%%  W%3d L%3d D%3d  avg %4.0fs" % [r.fam, r.rate * 100.0, r.w, r.l, r.d, r.avg])
	print("BALANCE_DONE ", (Time.get_ticks_msec() - started) / 1000, " s")
	if out_path != "":
		var file := FileAccess.open(out_path, FileAccess.WRITE)
		file.store_string(md)
