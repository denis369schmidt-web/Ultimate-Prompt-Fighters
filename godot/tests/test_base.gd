extends SceneTree
## Shared helpers for headless test scripts.
## Uses check() instead of assert(): a failing assert() pauses headless Godot in
## the debugger forever, a failing check() is recorded and the run continues.

const Prompt = preload("res://scripts/prompt_interpreter.gd")
const Combat = preload("res://scripts/combat.gd")

## Command that presses nothing; tests build variations with cmd().
const IDLE := {"move": 0.0, "standard": false, "special": false, "jump": false, "block": false, "grab": false}

var passed: int = 0
var failed: int = 0
var results: Array = []

func check(value: bool, message: String) -> void:
	if value:
		passed += 1
	else:
		failed += 1
	results.append({"pass": value, "test": message})
	print(("PASS " if value else "FAIL ") + message)

func cmd(overrides: Dictionary = {}) -> Dictionary:
	var c: Dictionary = IDLE.duplicate()
	c.merge(overrides, true)
	return c

func idle_commands(count: int = 2) -> Array:
	var out: Array = []
	for n in range(count):
		out.append(cmd())
	return out

## Fresh 1v1 match with the countdown skipped and fighters close together.
func match_ready(a: String = "electric ninja", b: String = "lava golem", lives: int = 3):
	var m = Combat.new()
	m.start([Prompt.interpret(a, 0), Prompt.interpret(b, 1)], null, "manual", lives)
	m.countdown = 0.0
	m.fighters[0].x = -0.5
	m.fighters[1].x = 0.5
	return m

func run_ticks(m, frames: int, commands: Array = []) -> void:
	var c: Array = commands if not commands.is_empty() else idle_commands(m.fighters.size())
	for n in range(frames):
		m.tick(c)

## Prints the machine-readable summary line and exits with a failing code if needed.
func finish(suite: String) -> void:
	print("PFU_TEST_SUMMARY suite=%s passed=%d failed=%d" % [suite, passed, failed])
	quit(1 if failed > 0 else 0)
