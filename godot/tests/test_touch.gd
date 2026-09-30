extends "res://tests/test_base.gd"
## Touch controls (touch_controls.gd) and platform profiles (platform.gd): the on-screen stick
## and buttons drive player 1 like a gamepad, swipes are smash attacks, pause / back work
## without keys, and the build profile is detected.

const Platform = preload("res://scripts/platform.gd")

## Headless runs have no window to route input events, so events go straight to the controls.
var t = null

func _initialize() -> void:
	call_deferred("run")

func touch_event(idx: int, pos: Vector2, pressed: bool) -> void:
	var ev := InputEventScreenTouch.new()
	ev.index = idx
	ev.position = pos
	ev.pressed = pressed
	t._input(ev)

func drag_event(idx: int, pos: Vector2, rel: Vector2) -> void:
	var ev := InputEventScreenDrag.new()
	ev.index = idx
	ev.position = pos
	ev.relative = rel
	t._input(ev)

func frames(n: int = 2) -> void:
	for k in range(n): await process_frame

func run() -> void:
	# ── Platform profile ──
	check(Platform.build() == "desktop", "a plain run is the desktop build (%s)" % Platform.build())
	check(not Platform.is_mobile(), "desktop is not mobile")
	check(not Platform.low_graphics(), "desktop keeps full graphics")

	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	await frames()
	check(app.touch == null, "no touch controls on desktop by default")
	app.setup_touch(true)
	t = app.touch
	check(t != null, "touch controls can be switched on")
	await frames()
	check(t.mode == "menu", "menus show only the back button (%s)" % t.mode)

	# ── Fight ──
	app.start_round("pve")
	await frames(3)
	check(t.mode == "fight", "a running fight shows the full controls (%s)" % t.mode)

	# Attack button
	var atk: Vector2 = t.button_center(t.BUTTONS[0])
	touch_event(0, atk, true)
	await frames()
	check(Input.is_action_pressed("p1_standard"), "tapping ANGRIFF presses the attack action")
	touch_event(0, atk, false)
	await frames()
	check(not Input.is_action_pressed("p1_standard"), "lifting the thumb releases it")

	# Every button reaches its action.
	var all_ok := true
	for b in t.BUTTONS:
		var c: Vector2 = t.button_center(b)
		touch_event(1, c, true)
		await frames()
		all_ok = all_ok and Input.is_action_pressed(str(b[1]))
		touch_event(1, c, false)
		await frames()
	check(all_ok, "all five buttons (attack, special, jump, shield, grab) work")

	# Floating stick
	var a: Vector2 = t._area()
	var start := Vector2(a.x * 0.2, a.y * 0.7)
	touch_event(2, start, true)
	drag_event(2, start + Vector2(90, 0), Vector2(90, 0))
	await frames()
	check(Input.is_action_pressed("p1_right") and not Input.is_action_pressed("p1_left"), "stick right presses right")
	var cmd: Dictionary = app.manual_commands()[0]
	check(float(cmd.move) > 0.6, "player 1 walks right from the stick (move %.2f)" % float(cmd.move))
	drag_event(2, start + Vector2(0, -90), Vector2(-90, -90))
	await frames()
	check(Input.is_action_pressed("p1_up"), "stick up aims up (up tilts, up special)")
	touch_event(2, start + Vector2(0, -90), false)
	await frames()
	check(not Input.is_action_pressed("p1_right") and not Input.is_action_pressed("p1_up"), "releasing the stick centers it")

	# Swipe = smash
	var sw := Vector2(a.x * 0.62, a.y * 0.35)
	touch_event(3, sw, true)
	# The running game reads swipes every physics tick, so the command is sampled right away.
	drag_event(3, sw + Vector2(0, -80), Vector2(0, -80))
	cmd = app.manual_commands()[0]
	touch_event(3, sw + Vector2(0, -80), false)
	check(cmd.get("smash", false) and cmd.up and cmd.standard, "an upward swipe is an up smash")
	touch_event(3, sw, true)
	drag_event(3, sw + Vector2(-90, 5), Vector2(-90, 5))
	cmd = app.manual_commands()[0]
	touch_event(3, sw + Vector2(-90, 5), false)
	check(cmd.get("smash", false) and float(cmd.move) < 0.0, "a left swipe is a left smash")
	cmd = app.manual_commands()[0]
	check(not cmd.get("smash", false), "one swipe gives exactly one smash")

	# Pause without keys
	touch_event(4, t.pause_center(), true)
	await frames()
	touch_event(4, t.pause_center(), false)
	await frames()
	check(app.paused and t.mode == "pause", "the pause button pauses the fight")
	var resume: Vector2 = t.pause_buttons()[0][1]
	touch_event(4, resume, true)
	await frames()
	touch_event(4, resume, false)
	await frames()
	check(not app.paused and t.mode == "fight", "WEITER resumes")

	# Held inputs never get stuck when the controls change mode.
	touch_event(5, t.button_center(t.BUTTONS[1]), true)
	await frames()
	app.paused = true
	await frames()
	check(not Input.is_action_pressed("p1_special"), "pausing releases held touch buttons")
	touch_event(5, t.button_center(t.BUTTONS[1]), false)
	app.paused = false
	await frames()

	# Android back button
	app.go_back()
	check(app.paused, "back during a fight pauses")
	app.go_back()
	check(not app.paused, "back again resumes")
	var quit: Vector2 = t.pause_buttons()[1][1]
	app.paused = true
	await frames()
	touch_event(6, quit, true)
	await frames()
	touch_event(6, quit, false)
	await frames(3)
	check(not app.active and app.selection.visible, "AUSWAHL leaves the fight to the fighter selection")
	app._notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	await frames()
	check(app.title_screen != null and app.title_screen.visible, "back in the selection goes to the main menu")

	# Settings
	t.apply_settings(9.0, 0.0)
	check(t.scale_factor <= 1.5 and t.opacity >= 0.2, "size and opacity stay in a usable range")
	t.apply_settings(1.0, 0.6)

	app.queue_free()
	await frames()

	# ── Phone build ──
	Platform.forced = "mobile"
	check(Platform.is_mobile() and Platform.touch_enabled() and Platform.low_graphics(), "the mobile build uses touch and the light graphics profile")
	var phone = load("res://main.tscn").instantiate()
	root.add_child(phone)
	await frames()
	check(phone.touch != null, "on phones the touch controls are there from the start")
	check(phone.sunlight.directional_shadow_mode == DirectionalLight3D.SHADOW_ORTHOGONAL and is_equal_approx(phone.get_viewport().scaling_3d_scale, 0.75),
		"phones render with one shadow split at 75 % resolution")
	phone.queue_free()
	await frames()
	root.get_viewport().scaling_3d_scale = 1.0
	Engine.max_fps = 0
	Platform.forced = "play"
	check(Platform.is_mobile() and Platform.build() == "play", "the Play Store build counts as mobile")
	Platform.forced = "steam"
	check(not Platform.is_mobile() and not Platform.touch_enabled(), "the Steam build is keyboard / gamepad first")
	Platform.forced = ""
	finish("touch")
