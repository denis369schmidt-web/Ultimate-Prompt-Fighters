extends Control
## On-screen touch controls for player 1 (phones, tablets, touch laptops).
##   left thumb  – floating stick: appears where the thumb lands, moves and aims (tilts, up/down specials)
##   right thumb – ANGRIFF, SPEZIAL, SPRUNG, SCHILD, GRIFF; a swipe on free space = smash attack
##   top         – pause (in fights), back (in menus); paused: WEITER / AUSWAHL
## The controls drive the normal input actions (p1_left, p1_standard …), so the simulation
## cannot tell them apart from a gamepad. main.gd reads take_smash() for swipes and sets
## `mode` ("fight", "pause", "menu" or "off") every frame.

signal pause_pressed
signal back_pressed
signal quit_pressed

const STICK_RADIUS := 92.0
const DEADZONE := 0.18
const SWIPE_MIN := 60.0
const SWIPE_TIME := 0.3

## name, action, label, color, anchor offset from the bottom-right corner, radius
const BUTTONS := [
	["attack", "p1_standard", "ANGRIFF", Color("f97316"), Vector2(-150, -135), 64.0],
	["special", "p1_special", "SPEZIAL", Color("a855f7"), Vector2(-282, -92), 52.0],
	["jump", "p1_jump", "SPRUNG", Color("22c55e"), Vector2(-108, -270), 52.0],
	["block", "p1_block", "SCHILD", Color("38bdf8"), Vector2(-262, -222), 44.0],
	["grab", "p1_grab", "GRIFF", Color("facc15"), Vector2(-392, -64), 38.0],
]

var mode := "off":
	set(v):
		if v == mode: return
		mode = v
		release_all()
		queue_redraw()
var scale_factor := 1.0
var opacity := 0.6

var stick_touch := -1
var stick_base := Vector2.ZERO
var stick_vec := Vector2.ZERO
var button_touch := {}       # touch index -> button name
var swipes := {}             # touch index -> [start position, start time]
var pressed_buttons := {}    # button name -> true
var pending_smash := Vector2.ZERO
var _time := 0.0

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var P = load("res://scripts/platform.gd")
	scale_factor = clampf(float(P.setting("touch_scale", 1.0)), 0.7, 1.5)
	opacity = clampf(float(P.setting("touch_opacity", 0.6)), 0.2, 1.0)

func _process(delta: float) -> void:
	_time += delta

# ─────────────────────────────────────────────────────────── layout ──

func _area() -> Vector2:
	return size if size.x > 10.0 else get_viewport_rect().size

func stick_home() -> Vector2:
	return Vector2(190, _area().y - 180)

func button_center(b: Array) -> Vector2:
	var a := _area()
	return Vector2(a.x, a.y) + (b[4] as Vector2) * scale_factor

func button_radius(b: Array) -> float:
	return float(b[5]) * scale_factor

## Below the round timer, clear of both players' HUD cards.
func pause_center() -> Vector2:
	return Vector2(_area().x * 0.5, 158)

func back_center() -> Vector2:
	return Vector2(56, 56)

func button_at(pos: Vector2) -> String:
	for b in BUTTONS:
		if pos.distance_to(button_center(b)) <= button_radius(b) * 1.15: return str(b[0])
	return ""

func _button(name: String) -> Array:
	for b in BUTTONS:
		if b[0] == name: return b
	return []

# ──────────────────────────────────────────────────────────── input ──

func _input(event: InputEvent) -> void:
	if mode == "off" or not visible: return
	if event is InputEventScreenTouch:
		if event.pressed: _touch_down(event.index, event.position)
		else: _touch_up(event.index, event.position)
	elif event is InputEventScreenDrag:
		_touch_move(event.index, event.position)

func pause_buttons() -> Array:
	var a := _area()
	return [["resume", a * 0.5 + Vector2(-150, 90), "▶ WEITER"], ["quit", a * 0.5 + Vector2(150, 90), "☰ AUSWAHL"]]

func _touch_down(idx: int, pos: Vector2) -> void:
	if mode == "pause":
		for pb in pause_buttons():
			if Rect2(pb[1] - Vector2(120, 34), Vector2(240, 68)).has_point(pos):
				if pb[0] == "resume": pause_pressed.emit()
				else: quit_pressed.emit()
				get_viewport().set_input_as_handled()
		return
	if mode == "menu":
		if pos.distance_to(back_center()) < 40.0:
			back_pressed.emit()
			get_viewport().set_input_as_handled()
		return
	if pos.distance_to(pause_center()) < 40.0:
		pause_pressed.emit()
		get_viewport().set_input_as_handled()
		return
	var b := button_at(pos)
	if b != "":
		button_touch[idx] = b
		_press(b, true)
		get_viewport().set_input_as_handled()
		return
	var a := _area()
	if pos.x < a.x * 0.45 and stick_touch == -1:
		stick_touch = idx
		# Floating stick: the base jumps to the thumb, but stays fully on screen.
		var r := STICK_RADIUS * scale_factor
		stick_base = Vector2(clampf(pos.x, r + 10, a.x * 0.45 - r), clampf(pos.y, a.y * 0.3, a.y - r - 10))
		_set_stick(pos - stick_base)
		get_viewport().set_input_as_handled()
		return
	if pos.x >= a.x * 0.45:
		swipes[idx] = [pos, _time]
		get_viewport().set_input_as_handled()

func _touch_move(idx: int, pos: Vector2) -> void:
	if idx == stick_touch:
		_set_stick(pos - stick_base)
		get_viewport().set_input_as_handled()
	elif swipes.has(idx):
		var start: Vector2 = swipes[idx][0]
		var d := pos - start
		if d.length() >= SWIPE_MIN * scale_factor and _time - float(swipes[idx][1]) <= SWIPE_TIME:
			pending_smash = d.normalized()
			swipes.erase(idx)
		get_viewport().set_input_as_handled()
	elif button_touch.has(idx):
		# Sliding a thumb from one button to another (e.g. attack -> jump) works like a pad.
		var b := button_at(pos)
		if b != "" and b != button_touch[idx]:
			_press(button_touch[idx], false)
			button_touch[idx] = b
			_press(b, true)
		get_viewport().set_input_as_handled()

func _touch_up(idx: int, _pos: Vector2) -> void:
	if idx == stick_touch:
		stick_touch = -1
		_set_stick(Vector2.ZERO)
	if button_touch.has(idx):
		_press(button_touch[idx], false)
		button_touch.erase(idx)
	swipes.erase(idx)
	queue_redraw()

func _set_stick(offset: Vector2) -> void:
	var r := STICK_RADIUS * scale_factor
	var v := offset.limit_length(r) / r
	stick_vec = v if v.length() > DEADZONE else Vector2.ZERO
	_apply_axis("p1_left", maxf(0.0, -stick_vec.x))
	_apply_axis("p1_right", maxf(0.0, stick_vec.x))
	_apply_axis("p1_up", 1.0 if stick_vec.y < -0.5 else 0.0)
	_apply_axis("p1_down", 1.0 if stick_vec.y > 0.55 else 0.0)
	queue_redraw()

func _apply_axis(action: String, strength: float) -> void:
	if not InputMap.has_action(action): return
	if strength > 0.0: Input.action_press(action, strength)
	else: Input.action_release(action)

func _press(name: String, down: bool) -> void:
	var b := _button(name)
	if b.is_empty(): return
	var action: String = b[1]
	if down:
		pressed_buttons[name] = true
		if InputMap.has_action(action): Input.action_press(action)
	else:
		pressed_buttons.erase(name)
		if InputMap.has_action(action): Input.action_release(action)
	queue_redraw()

## A swipe on free space since the last call: the smash direction (screen space, y down) or zero.
func take_smash() -> Vector2:
	var s := pending_smash
	pending_smash = Vector2.ZERO
	return s

func release_all() -> void:
	for b in BUTTONS:
		if InputMap.has_action(str(b[1])): Input.action_release(str(b[1]))
	for a in ["p1_left", "p1_right", "p1_up", "p1_down"]:
		if InputMap.has_action(a): Input.action_release(a)
	stick_touch = -1
	stick_vec = Vector2.ZERO
	button_touch.clear()
	swipes.clear()
	pressed_buttons.clear()
	pending_smash = Vector2.ZERO

func apply_settings(new_scale: float, new_opacity: float) -> void:
	scale_factor = clampf(new_scale, 0.7, 1.5)
	opacity = clampf(new_opacity, 0.2, 1.0)
	var P = load("res://scripts/platform.gd")
	P.set_setting("touch_scale", scale_factor)
	P.set_setting("touch_opacity", opacity)
	queue_redraw()

# ─────────────────────────────────────────────────────────── drawing ──

func _draw() -> void:
	if mode == "off": return
	var font := ThemeDB.fallback_font
	if mode == "pause":
		for pb in pause_buttons():
			var r2 := Rect2(pb[1] - Vector2(120, 34), Vector2(240, 68))
			draw_rect(r2, Color(0.05, 0.07, 0.12, 0.85))
			draw_rect(r2, Color("fde68a"), false, 3.0)
			_glyph(font, pb[1], str(pb[2]), 24, Color.WHITE)
		return
	if mode == "menu":
		_disc(back_center(), 30.0, Color("94a3b8"), false)
		_glyph(font, back_center(), "◀", 22, Color.WHITE)
		return
	# Stick
	var base := stick_base if stick_touch != -1 else stick_home()
	var r := STICK_RADIUS * scale_factor
	draw_circle(base, r, Color(0, 0, 0, 0.28 * opacity))
	draw_arc(base, r, 0, TAU, 64, Color(1, 1, 1, 0.45 * opacity), 3.0, true)
	for k in range(4):
		var a := TAU * k / 4.0
		var tip := base + Vector2(cos(a), sin(a)) * (r - 14)
		draw_circle(tip, 4.0, Color(1, 1, 1, 0.35 * opacity))
	var knob := base + stick_vec * r
	draw_circle(knob, r * 0.42, Color(1, 1, 1, (0.55 if stick_touch != -1 else 0.3) * opacity))
	draw_arc(knob, r * 0.42, 0, TAU, 48, Color(1, 1, 1, 0.8 * opacity), 2.0, true)
	# Buttons
	for b in BUTTONS:
		var c: Vector2 = button_center(b)
		var rad := button_radius(b)
		var on: bool = pressed_buttons.has(b[0])
		_disc(c, rad, b[3], on)
		_glyph(font, c, str(b[2]), int(clampf(rad * 0.3, 11, 20)), Color.WHITE)
	# Swipe hint and pause
	var a2 := _area()
	draw_string(font, Vector2(a2.x * 0.5 + 40, a2.y - 24), "WISCHEN = SMASH", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(1, 1, 1, 0.35 * opacity))
	_disc(pause_center(), 30.0, Color("94a3b8"), false)
	_glyph(font, pause_center(), "II", 20, Color.WHITE)

func _disc(c: Vector2, r: float, col: Color, on: bool) -> void:
	draw_circle(c, r, Color(col.r, col.g, col.b, (0.75 if on else 0.28) * opacity))
	draw_arc(c, r, 0, TAU, 64, Color(col.r, col.g, col.b, 0.95 * opacity), 3.0, true)
	if on: draw_arc(c, r + 5, 0, TAU, 64, Color(1, 1, 1, 0.6 * opacity), 2.0, true)

func _glyph(font: Font, c: Vector2, text: String, fs: int, col: Color) -> void:
	var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	draw_string_outline(font, c + Vector2(-w * 0.5, fs * 0.35), text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 4, Color(0, 0, 0, 0.6 * maxf(0.6, opacity)))
	draw_string(font, c + Vector2(-w * 0.5, fs * 0.35), text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(col.r, col.g, col.b, maxf(0.75, opacity)))
