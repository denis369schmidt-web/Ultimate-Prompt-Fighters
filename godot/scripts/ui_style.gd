extends RefCounted
## Prompt Fighters design system: color tokens, type scale, framed style boxes,
## button states, the shared Theme and small motion helpers for menus.
## Look: "forged arena" - dark gunmetal plates with cut corners, a double edge with an
## inner light seam, gold for focus and primary actions, cyan for P1 and amber for P2.

const FrameBox = preload("res://scripts/ui_frame_box.gd")
const TEKO = preload("res://assets/fonts/Teko.ttf")

# ---- Color tokens --------------------------------------------------------------------
const PLATE := Color("0d1524")        # panel fill
const PLATE_DEEP := Color("070b14")   # sunken areas, list wells
const RIM := Color("34445e")          # neutral edge
const SEAM := Color("8ea4c6")         # inner light seam tint
const GOLD := Color("f4b740")         # focus, primary, rewards
const EMBER := Color("ff6a2b")        # fight / danger actions
const P1 := Color("49def4")           # player 1
const P2 := Color("ffa04d")           # player 2 (amber)
const TEXT := Color("edf2f9")
const MUTED := Color("8d9bb4")

# ---- Spacing and type scale ----------------------------------------------------------
const PAD := 14
const GAP := 8
const SIZE_SMALL := 11
const SIZE_BODY := 14
const SIZE_BUTTON := 15
const SIZE_TITLE := 26
const SIZE_HERO := 40
const TOUCH_MIN := 42.0

# ---- Motion --------------------------------------------------------------------------
const T_FAST := 0.12
const T_MED := 0.22

static var _fonts: Dictionary = {}

## Teko at a given weight (variable font); cached so every caller shares one resource.
static func display_font(weight: int = 600, spacing: int = 1) -> FontVariation:
	var key := "%d_%d" % [weight, spacing]
	if _fonts.has(key): return _fonts[key]
	var fv := FontVariation.new()
	fv.base_font = TEKO
	fv.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): weight}
	fv.spacing_glyph = spacing
	_fonts[key] = fv
	return fv

## A framed plate. radius maps to the size of the cut corners.
static func frame(fill: Color, edge: Color = RIM, width: int = 1, radius: int = 12) -> FrameBox:
	var s := FrameBox.new()
	s.bg_color = fill
	s.border_color = edge
	s.set_border_width_all(width)
	s.cut = clampf(float(radius) * 0.9, 3.0, 18.0)
	s.content_margin_left = 18
	s.content_margin_right = 18
	s.content_margin_top = 12
	s.content_margin_bottom = 12
	if fill.a > 0.05 and width > 0:
		s.shadow_color = Color(0, 0, 0, 0.5)
		s.shadow_size = 8 if radius >= 10 else 4
		s.shadow_offset = Vector2(0, 3)
	else:
		s.shadow_size = 0
	s.seam = 0.30 if fill.a > 0.05 else 0.0
	return s

## Large windows: stronger shadow and corner brackets.
static func window(fill: Color, edge: Color, width: int = 2) -> FrameBox:
	var s := frame(fill, edge, width, 16)
	s.ornaments = true
	s.shadow_size = 18
	s.shadow_offset = Vector2(0, 8)
	s.shadow_color = Color(0, 0, 0, 0.62)
	s.content_margin_left = 24
	s.content_margin_right = 24
	s.content_margin_top = 18
	s.content_margin_bottom = 18
	return s

## Button style boxes for every state. accent tints the edge; fill is the resting plate.
static func button_boxes(accent: Color, fill: Color = Color(0.055, 0.085, 0.14, 0.94), radius: int = 8, slant: float = 0.0) -> Dictionary:
	var normal := frame(fill, accent.darkened(0.42), 1, radius)
	normal.content_margin_left = 14
	normal.content_margin_right = 14
	normal.content_margin_top = 6
	normal.content_margin_bottom = 6
	normal.shadow_size = 4
	normal.shadow_offset = Vector2(0, 2)
	normal.seam = 0.18
	normal.slant = slant
	var hover: FrameBox = normal.duplicate()
	hover.bg_color = fill.lerp(accent, 0.16).lightened(0.05)
	hover.border_color = accent.lightened(0.12)
	hover.seam = 0.45
	hover.shadow_color = Color(accent.r, accent.g, accent.b, 0.28)
	hover.shadow_size = 8
	hover.underglow = Color(accent.r, accent.g, accent.b, 0.20)
	var pressed: FrameBox = normal.duplicate()
	pressed.bg_color = fill.lerp(accent, 0.28)
	pressed.border_color = accent.lightened(0.3)
	pressed.set_border_width_all(2)
	pressed.shadow_size = 1
	pressed.shadow_offset = Vector2(0, 0)
	pressed.sheen = -0.04
	pressed.seam = 0.2
	var focus: FrameBox = hover.duplicate()
	focus.draw_center = false
	focus.border_color = GOLD
	focus.set_border_width_all(2)
	focus.shadow_size = 0
	focus.underglow = Color(0, 0, 0, 0)
	var disabled: FrameBox = normal.duplicate()
	disabled.bg_color = Color(fill.r, fill.g, fill.b, fill.a * 0.6).darkened(0.2)
	disabled.border_color = Color(RIM.r, RIM.g, RIM.b, 0.45)
	disabled.seam = 0.0
	disabled.shadow_size = 0
	return {"normal": normal, "hover": hover, "pressed": pressed, "focus": focus, "disabled": disabled, "hover_pressed": pressed}

## Applies the full state set, display font and hover/press motion to a button.
static func style_button(b: Button, accent: Color, fill: Color = Color(0.055, 0.085, 0.14, 0.94), radius: int = 8, slant: float = 0.0) -> void:
	var boxes := button_boxes(accent, fill, radius, slant)
	for k in boxes: b.add_theme_stylebox_override(k, boxes[k])
	b.add_theme_color_override("font_color", TEXT)
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	b.add_theme_color_override("font_pressed_color", accent.lightened(0.55))
	b.add_theme_color_override("font_focus_color", Color.WHITE)
	b.add_theme_color_override("font_disabled_color", Color(MUTED.r, MUTED.g, MUTED.b, 0.6))
	add_motion(b)

## Hover lifts the button slightly, pressing squeezes it. Safe inside containers (scale only).
static func add_motion(c: Control, hover_scale: float = 1.03) -> void:
	if c.has_meta("ui_motion"): return
	c.set_meta("ui_motion", true)
	var center := func(): c.pivot_offset = c.size * 0.5
	c.resized.connect(center)
	center.call()
	c.mouse_entered.connect(func(): _scale_to(c, hover_scale, T_FAST))
	c.mouse_exited.connect(func(): _scale_to(c, 1.0, T_MED))
	if c is BaseButton:
		(c as BaseButton).button_down.connect(func(): _scale_to(c, 0.965, 0.06))
		(c as BaseButton).button_up.connect(func(): _scale_to(c, hover_scale if c.get_global_rect().has_point(c.get_global_mouse_position()) else 1.0, T_FAST))

static func _scale_to(c: Control, s: float, t: float) -> void:
	if not c.is_inside_tree(): return
	if c.has_meta("ui_tw"):
		var old: Tween = c.get_meta("ui_tw")
		if old != null and old.is_valid(): old.kill()
	var tw := c.create_tween()
	tw.tween_property(c, "scale", Vector2.ONE * s, t).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	c.set_meta("ui_tw", tw)

static func animations_on() -> bool:
	return DisplayServer.get_name() != "headless"

## Fades a control in and lets it rise a few pixels (windows, overlays, result panels).
static func reveal(c: Control, rise: float = 14.0, t: float = T_MED) -> void:
	if not animations_on() or not c.is_inside_tree(): return
	var target := c.position
	c.modulate.a = 0.0
	c.position = target + Vector2(0, rise)
	var tw := c.create_tween().set_parallel()
	tw.tween_property(c, "modulate:a", 1.0, t).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(c, "position", target, t).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

## Fade only (full-screen layers whose position is driven by anchors).
static func fade_in(c: CanvasItem, t: float = T_MED) -> void:
	if not animations_on() or not c.is_inside_tree(): return
	c.modulate.a = 0.0
	c.create_tween().tween_property(c, "modulate:a", 1.0, t).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

## Scales a dialog up from 94 % while fading it in.
static func pop_in(c: Control, t: float = T_MED) -> void:
	if not animations_on() or not c.is_inside_tree(): return
	c.pivot_offset = c.size * 0.5
	c.modulate.a = 0.0
	c.scale = Vector2.ONE * 0.94
	var tw := c.create_tween().set_parallel()
	tw.tween_property(c, "modulate:a", 1.0, t).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(c, "scale", Vector2.ONE, t).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

## Fades a node out, then frees it. It stops taking input right away.
static func fade_free(c: Control, t: float = T_FAST) -> void:
	if not animations_on() or not c.is_inside_tree():
		c.queue_free()
		return
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for b in c.find_children("*", "Control", true, false):
		(b as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tw := c.create_tween()
	tw.tween_property(c, "modulate:a", 0.0, t).set_ease(Tween.EASE_IN)
	tw.tween_callback(c.queue_free)

## Theme for the UI root: defaults for controls that are not styled by hand
## (scroll bars, sliders, check boxes, line edits, tooltips, progress bars, plain buttons).
static func build_theme() -> Theme:
	var th := Theme.new()
	var bb := button_boxes(GOLD)
	for k in ["normal", "hover", "pressed", "focus", "disabled"]:
		th.set_stylebox(k, "Button", bb[k])
	th.set_font("font", "Button", display_font(500, 1))
	th.set_font_size("font_size", "Button", SIZE_BUTTON + 2)
	th.set_color("font_color", "Button", TEXT)
	th.set_color("font_hover_color", "Button", Color.WHITE)
	th.set_color("font_pressed_color", "Button", GOLD.lightened(0.4))
	th.set_color("font_focus_color", "Button", Color.WHITE)
	th.set_constant("outline_size", "Button", 0)
	var panel := frame(Color(PLATE.r, PLATE.g, PLATE.b, 0.95), RIM, 1, 12)
	th.set_stylebox("panel", "PanelContainer", panel)
	th.set_stylebox("panel", "Panel", panel)
	# Tooltips
	var tip := frame(Color(0.03, 0.05, 0.09, 0.97), GOLD.darkened(0.25), 1, 6)
	tip.content_margin_left = 10
	tip.content_margin_right = 10
	tip.content_margin_top = 6
	tip.content_margin_bottom = 6
	th.set_stylebox("panel", "TooltipPanel", tip)
	th.set_color("font_color", "TooltipLabel", TEXT)
	# Scroll bars: slim rail with a gold-edged grabber.
	for sb_type in ["VScrollBar", "HScrollBar"]:
		var rail := StyleBoxFlat.new()
		rail.bg_color = Color(0.02, 0.035, 0.06, 0.85)
		rail.set_corner_radius_all(3)
		rail.content_margin_left = 3
		rail.content_margin_right = 3
		rail.content_margin_top = 3
		rail.content_margin_bottom = 3
		var grab := StyleBoxFlat.new()
		grab.bg_color = Color("2a3a55")
		grab.border_color = GOLD.darkened(0.35)
		grab.set_border_width_all(1)
		grab.set_corner_radius_all(3)
		var grab_hi: StyleBoxFlat = grab.duplicate()
		grab_hi.bg_color = Color("3a5070")
		grab_hi.border_color = GOLD
		th.set_stylebox("scroll", sb_type, rail)
		th.set_stylebox("grabber", sb_type, grab)
		th.set_stylebox("grabber_highlight", sb_type, grab_hi)
		th.set_stylebox("grabber_pressed", sb_type, grab_hi)
	# Sliders
	var slider := StyleBoxFlat.new()
	slider.bg_color = Color(0.02, 0.035, 0.06, 0.9)
	slider.border_color = RIM
	slider.set_border_width_all(1)
	slider.set_corner_radius_all(2)
	slider.content_margin_top = 3
	slider.content_margin_bottom = 3
	var fill := StyleBoxFlat.new()
	fill.bg_color = GOLD.darkened(0.15)
	fill.set_corner_radius_all(2)
	fill.content_margin_top = 3
	fill.content_margin_bottom = 3
	th.set_stylebox("slider", "HSlider", slider)
	th.set_stylebox("grabber_area", "HSlider", fill)
	th.set_stylebox("grabber_area_highlight", "HSlider", fill)
	# Progress bars
	var pb_bg := StyleBoxFlat.new()
	pb_bg.bg_color = Color(0.02, 0.035, 0.06, 0.9)
	pb_bg.set_corner_radius_all(2)
	var pb_fill := StyleBoxFlat.new()
	pb_fill.bg_color = GOLD
	pb_fill.set_corner_radius_all(2)
	th.set_stylebox("background", "ProgressBar", pb_bg)
	th.set_stylebox("fill", "ProgressBar", pb_fill)
	# Line edits
	var le := frame(Color(0.02, 0.035, 0.06, 0.95), RIM, 1, 6)
	le.content_margin_top = 6
	le.content_margin_bottom = 6
	le.content_margin_left = 10
	le.content_margin_right = 10
	le.shadow_size = 0
	var le_focus: FrameBox = le.duplicate()
	le_focus.border_color = GOLD
	th.set_stylebox("normal", "LineEdit", le)
	th.set_stylebox("focus", "LineEdit", le_focus)
	th.set_stylebox("normal", "TextEdit", le)
	th.set_stylebox("focus", "TextEdit", le_focus)
	# Separators
	var sep := StyleBoxLine.new()
	sep.color = Color(RIM.r, RIM.g, RIM.b, 0.8)
	sep.thickness = 1
	th.set_stylebox("separator", "HSeparator", sep)
	th.set_constant("separation", "HSeparator", 10)
	return th
