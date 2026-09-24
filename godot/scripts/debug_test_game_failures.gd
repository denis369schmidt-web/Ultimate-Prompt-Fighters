extends SceneTree

const Prompt = preload("res://scripts/prompt_interpreter.gd")
const Combat = preload("res://scripts/combat.gd")

func match_ready(a: String = "electric ninja", b: String = "lava golem"):
	var m = Combat.new()
	m.start(Prompt.interpret(a, 0), Prompt.interpret(b, 1), "manual")
	m.countdown = 0
	m.fighters[0].x = -0.5
	m.fighters[1].x = 0.5
	return m

func _init() -> void:
	print("--- Debugging Test 1: P2 special attack and victory ---")
	var m = match_ready()
	m.fighters[0].hp = 0.1
	var idle := [{}, {}]
	var ok = m.queue_attack(1, true)
	print("queue_attack ok: ", ok)
	print("P2 pending before ticks: ", m.fighters[1].pending)
	for n in range(30):
		m.tick(idle)
		if n % 5 == 0:
			print("Tick ", n, ": P1 HP=", m.fighters[0].hp, " P2 pending_remaining=", m.fighters[1].pending.get("remaining", -1), " result=", m.result)
	print("Final result: ", m.result, " | P1 HP: ", m.fighters[0].hp, " | P1 lives: ", m.fighters[0].lives)

	print("\n--- Debugging Test 2: Arena boundaries ---")
	m = match_ready()
	for n in range(300):
		m.tick([{"move": -1}, {"move": 1}])
	print("P0 x: ", m.fighters[0].x, " | P1 x: ", m.fighters[1].x)
	print("P0 >= -5.2: ", (m.fighters[0].x >= -5.2), " | P1 <= 5.2: ", (m.fighters[1].x <= 5.2))
	quit()
