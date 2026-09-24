extends SceneTree
const Prompt = preload("res://scripts/prompt_interpreter.gd")
const Combat = preload("res://scripts/combat.gd")
var passed := 0
var failed := 0
var results: Array = []

func check(value: bool, message: String) -> void:
    if value: passed += 1
    else: failed += 1
    results.append({"pass": value, "test": message})
    print(("PASS " if value else "FAIL ") + message)

func match_ready(a: String = "electric ninja", b: String = "lava golem"):
    var m = Combat.new()
    m.start(Prompt.interpret(a, 0), Prompt.interpret(b, 1), "manual")
    m.countdown = 0
    m.fighters[0].x = -0.5
    m.fighters[1].x = 0.5
    return m

func _initialize() -> void:
    call_deferred("run")

func run() -> void:
    var p1: Dictionary = Prompt.interpret("electric ninja", 0)
    var p2: Dictionary = Prompt.interpret("armored lava golem", 1)
    check(p1.family == "ninja" and p2.family == "golem" and p1.prompt != p2.prompt, "independent prompts and skeleton families")
    check(p1 == Prompt.interpret("electric ninja", 0), "deterministic profile")
    check(p1.seed == Prompt.interpret("electric ninja", 1).seed, "same prompt reproducible across player slots")
    var valid := true
    for n in range(1000):
        var prompt: Variant = [null, "", "unbesiegbar unendlich Schaden", "lava golem", "electric ninja", "frost armor", "x".repeat(800)][n % 7]
        var profile := Prompt.interpret(prompt, n % 2)
        valid = valid and Prompt.valid(profile) and profile.prompt.length() <= 512
    check(valid, "1000 profiles: budget, bounds, invalid inputs and module compatibility")
    var idle := [{}, {}]
    var m = match_ready()
    var before: float = m.fighters[1].hp
    check(m.queue_attack(0, false), "standard attack accepted")
    check(not m.queue_attack(0, false), "duplicate attack blocked by pending/cooldown")
    for n in range(40): m.tick(idle)
    var damage: float = before - m.fighters[1].hp
    check(damage > 0 and damage < 30, "single standard hit applied within damage budget")
    for n in range(20): m.tick(idle)
    check(is_equal_approx(m.fighters[1].hp, before - damage), "no repeated damage after completed hit")
    m = match_ready()
    m.fighters[1].x = 5
    before = m.fighters[1].hp
    m.queue_attack(0, true)
    for n in range(30): m.tick(idle)
    check(m.fighters[1].hp == before, "special misses outside range")
    m = match_ready()
    m.fighters[1].hp = 0.1
    m.queue_attack(0, false)
    for n in range(30): m.tick(idle)
    check(m.result == 0, "player 1 win and player 2 defeat")
    m.restart()
    check(m.result == -2 and m.time_left == 90 and m.fighters[1].hp == m.fighters[1].profile.health and m.fighters[0].pending.is_empty(), "restart resets all combat state")
    m = match_ready()
    m.fighters[0].hp = 0.1
    m.queue_attack(1, true)
    for n in range(30): m.tick(idle)
    check(m.result == 1, "player 2 special attack and victory")
    m = match_ready("ninja", "ninja")
    m.fighters[0].hp = 0.1
    m.fighters[1].hp = 0.1
    m.queue_attack(0, false)
    m.queue_attack(1, false)
    for n in range(30): m.tick(idle)
    check(m.result == -1, "simultaneous double KO is a draw")
    m = match_ready()
    m.time_left = Combat.STEP
    m.tick(idle)
    check(m.result == -1, "timeout compares normalized health")
    m = match_ready()
    m.time_left = Combat.STEP
    m.fighters[1].hp *= 0.5
    m.tick(idle)
    check(m.result == 0, "timeout winner")
    var manual = match_ready()
    var agents = match_ready()
    agents.mode = "autonomous"
    for n in range(600):
        var commands: Array = agents.agent_commands()
        manual.tick(commands)
        agents.tick(commands)
    check(manual.fighters == agents.fighters and manual.result == agents.result, "identical commands yield identical rules in both modes")
    var wins := [0, 0, 0]
    var total_hits := 0
    for n in range(30):
        m = match_ready("electric ninja %d" % n, "lava golem %d" % n)
        m.fighters[0].x = -2.4
        m.fighters[1].x = 2.4
        for frame in range(5500):
            m.tick(m.agent_commands())
            for event in m.events:
                if event.type == "hit": total_hits += 1
            if m.result != -2: break
        if m.result >= 0: wins[m.result] += 1
        elif m.result == -1: wins[2] += 1
    check(wins[0] + wins[1] + wins[2] == 30 and total_hits > 0, "30 autonomous matches terminate with real hits")
    print("BALANCE_SAMPLE ", wins, " hits=", total_hits)
    m = match_ready()
    for n in range(300): m.tick([{"move": -1}, {"move": 1}])
    check(m.fighters[0].x >= -5.2 and m.fighters[1].x <= 5.2, "arena boundaries")
    m = match_ready()
    for n in range(120): m.tick([{"move": 1}, {"move": -1}])
    check(m.fighters[1].x - m.fighters[0].x >= 0.849, "fighters do not cross through each other")
    for family in ["ninja", "golem", "valkyrie", "dragon"]:
        var scene = load("res://assets/models/%s.glb" % family).instantiate()
        root.add_child(scene)
        var rigs: Array = scene.find_children("*", "Skeleton3D", true, false)
        var players: Array = scene.find_children("*", "AnimationPlayer", true, false)
        check(rigs.size() == 1 and rigs[0].get_bone_count() == 18, family + " imported 18-bone skeleton")
        var clips: Array = []
        if not players.is_empty(): clips.assign(players[0].get_animation_list())
        check(clips.size() >= 7, family + " imported animation clips " + str(clips))
        scene.queue_free()
    var app = load("res://main.tscn").instantiate()
    root.add_child(app)
    await process_frame
    app.start_round("manual")
    app.sim.countdown = 0
    Input.action_press("p1_right")
    var cmd: Array = app.manual_commands()
    check(cmd[0].move == 1 and cmd[1].move == 0, "P1 movement input is isolated")
    Input.action_release("p1_right")
    Input.action_press("p2_left")
    cmd = app.manual_commands()
    check(cmd[0].move == 0 and cmd[1].move == -1, "P2 movement input is isolated")
    Input.action_release("p2_left")
    for spec in [[KEY_F, 0, "standard"], [KEY_G, 0, "special"], [KEY_K, 1, "standard"], [KEY_L, 1, "special"]]:
        var key := InputEventKey.new()
        key.physical_keycode = spec[0]
        key.keycode = spec[0]
        key.pressed = true
        app._unhandled_key_input(key)
        cmd = app.manual_commands()
        check(cmd[spec[1]][spec[2]] and not cmd[1-spec[1]][spec[2]], "attack key isolated: " + OS.get_keycode_string(spec[0]))
    app.show_selection()
    check(not app.active and app.selection.visible, "return to prompt selection")
    app.start_round("autonomous")
    check(app.active and not app.selection.visible and app.sim.mode == "autonomous", "agent start button route")
    app.restart_round()
    check(app.sim.elapsed == 0 and app.sim.countdown > 0, "UI restart route")
    app.queue_free()
    await process_frame
    print("PFU_GODOT_TESTS passed=", passed, " failed=", failed)
    var report := {"engine": Engine.get_version_info().string, "passed": passed, "failed": failed,
        "balance_sample": wins, "sample_hits": total_hits, "tests": results}
    for arg in OS.get_cmdline_user_args():
        if arg.begins_with("--report="):
            var file := FileAccess.open(arg.trim_prefix("--report="), FileAccess.WRITE)
            if file: file.store_string(JSON.stringify(report, "  "))
    quit(1 if failed > 0 else 0)
