extends Node
## Story mode player: chapter menu, in-engine cutscenes (camera shots, dialogue, poses,
## effects), quick-time events and story fights on the real combat simulation.
## Content lives in story_data.gd; this script only plays it.

const StoryData = preload("res://scripts/story_data.gd")
const StoryDivina = preload("res://scripts/story_divina.gd")
const StorySaga = preload("res://scripts/story_saga.gd")
const VOICE_DIR := "res://assets/audio/voice/story/"
## Music mood per step "music" (audio_director.gd TRACKS).
const MOODS := {"calm": "story_calm", "sad": "story_sad", "hope": "story_hope", "tense": "story_tense",
	"fight": "fight", "boss": "boss", "boss_final": "boss_final"}
const Bosses = preload("res://scripts/bosses.gd")
const StoryLegends = preload("res://scripts/story_legends.gd")
const Prompt = preload("res://scripts/prompt_interpreter.gd")

const SAVE_PATH := "user://story.cfg"
const TYPE_SPEED := 48.0          # characters per second in dialogue
const LETTERBOX_HEIGHT := 64.0
## QTE keys use the gameplay actions of player 1 (player 2's keys are accepted too).
const QTE_ACTIONS := ["jump", "standard", "special", "grab", "block"]
## Starting percent applied by a quick-time event before a fight.
const QTE_BONUS_PERCENT := 25.0
const QTE_PENALTY_PERCENT := 20.0

signal advanced
signal qte_finished(success: bool)
signal fight_done(win: bool)

var main: Node
var running := false
var in_fight := false
## Headless/testing: dialogue does not wait for input, QTEs resolve to auto_qte_success.
var auto_advance := false
var auto_qte_success := true
var persist := true

var chapter_index := -1
var completed := 0                # number of finished chapters (unlocks the next one)
## Campaign: "zeile" (Die letzte Zeile, linear) or "divina" (Die göttliche Prüfung: earth, hell,
## heaven – every realm's first chapter is open, the rest unlock one by one).
var campaign := "saga"
## Legends: the fighter whose legend is open ("" = the list of all fighters).
var legend_family := ""
var _legend_cache := {}
var _saga_cache: Array = []
var choice_panel: PanelContainer
var choice_label: Label
var choice_buttons: Array = []
var choice_index := 0
var choice_result := -1
var done_ids := {}                # finished chapter ids of the divina campaign
var menu_title: Label
var menu_sub: Label
var menu_realm_row: HBoxContainer
var flags := {}                   # QTE results: flag -> bool
var session := 0                  # bumped on abort; running coroutines stop
var skipping := false             # ESC: fast-forward to the next fight
var current_fight: Dictionary = {}
var stage_ids: Array = []         # cast id per stage slot

# Cinematic camera, tweened by shots and applied every frame.
var cam_pos := Vector3(0, 2.4, 10.5)
var cam_look := Vector3(0, 1.3, 0)
var cam_shake := 0.0

# QTE state
var qte_active := false
var qte: Dictionary = {}

# UI
var layer: CanvasLayer
var letterbox_top: ColorRect
var letterbox_bottom: ColorRect
var fade_rect: ColorRect
var flash_rect: ColorRect
var title_box: VBoxContainer
var title_label: Label
var subtitle_label: Label
var narrate_label: Label
var dialog_panel: PanelContainer
var dialog_portrait: TextureRect
var dialog_name: Label
var dialog_title: Label
var dialog_text: RichTextLabel
var dialog_hint: Label
var qte_ring: QteRing
var qte_label: Label
var qte_count_label: Label
var banner: Label
var result_box: VBoxContainer
var result_title: Label
var result_hint: Label
var menu_panel: PanelContainer
var menu_list: VBoxContainer
var pause_hint: Label
var credits_label: Label
var typing := false


## Circular QTE timer with the key glyph in the middle.
class QteRing extends Control:
	var fraction := 1.0
	var glyph := "F"
	var color := Color("f7c844")
	var pulse := 0.0

	func _draw() -> void:
		var c := size * 0.5
		var r := minf(size.x, size.y) * 0.42
		draw_circle(c, r + 10.0, Color(0, 0, 0, 0.55))
		draw_arc(c, r, 0.0, TAU, 64, Color(1, 1, 1, 0.15), 10.0, true)
		draw_arc(c, r, -PI * 0.5, -PI * 0.5 + TAU * fraction, 64, color, 10.0, true)
		var font := get_theme_default_font()
		var fs := int(r * 0.9 * (1.0 + pulse * 0.12))
		var ts := font.get_string_size(glyph, HORIZONTAL_ALIGNMENT_CENTER, -1, fs)
		draw_string(font, c + Vector2(-ts.x * 0.5, ts.y * 0.32), glyph, HORIZONTAL_ALIGNMENT_CENTER, -1, fs, Color.WHITE)


func setup(main_node: Node) -> void:
	main = main_node
	_build_ui()
	load_progress()

# ─────────────────────────────────────────────────────────────── UI construction ──

func _lbl(text: String, size: int, color: Color = Color("eef4ff")) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	l.add_theme_constant_override("outline_size", 8)
	return l

func _style(bg: Color, border: Color, radius: int = 10) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(2)
	s.set_corner_radius_all(radius)
	s.content_margin_left = 18
	s.content_margin_right = 18
	s.content_margin_top = 12
	s.content_margin_bottom = 12
	return s

func _build_ui() -> void:
	layer = CanvasLayer.new()
	layer.layer = 10
	add_child(layer)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)

	letterbox_top = ColorRect.new()
	letterbox_top.color = Color.BLACK
	letterbox_top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	letterbox_top.offset_bottom = 0
	letterbox_top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(letterbox_top)
	letterbox_bottom = ColorRect.new()
	letterbox_bottom.color = Color.BLACK
	letterbox_bottom.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	letterbox_bottom.offset_top = 0
	letterbox_bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(letterbox_bottom)

	title_box = VBoxContainer.new()
	title_box.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	title_box.custom_minimum_size = Vector2(900, 160)
	title_box.position = Vector2(190, 250)
	title_box.alignment = BoxContainer.ALIGNMENT_CENTER
	title_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(title_box)
	title_label = _lbl("", 64, Color("f7c844"))
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_box.add_child(title_label)
	subtitle_label = _lbl("", 30)
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_box.add_child(subtitle_label)
	title_box.modulate.a = 0.0

	narrate_label = _lbl("", 26, Color("f3ead8"))
	narrate_label.position = Vector2(140, 250)
	narrate_label.custom_minimum_size = Vector2(1000, 200)
	narrate_label.size = Vector2(1000, 200)
	narrate_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	narrate_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	narrate_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	narrate_label.modulate.a = 0.0
	root.add_child(narrate_label)

	dialog_panel = PanelContainer.new()
	dialog_panel.position = Vector2(110, 470)
	dialog_panel.custom_minimum_size = Vector2(1060, 170)
	dialog_panel.add_theme_stylebox_override("panel", _style(Color(0.02, 0.03, 0.06, 0.92), Color("49def4")))
	root.add_child(dialog_panel)
	var drow := HBoxContainer.new()
	drow.add_theme_constant_override("separation", 18)
	dialog_panel.add_child(drow)
	var pframe := PanelContainer.new()
	pframe.custom_minimum_size = Vector2(132, 132)
	pframe.add_theme_stylebox_override("panel", _style(Color("0b111c"), Color("34445b"), 8))
	drow.add_child(pframe)
	dialog_portrait = TextureRect.new()
	dialog_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	dialog_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	dialog_portrait.custom_minimum_size = Vector2(110, 110)
	pframe.add_child(dialog_portrait)
	var dcol := VBoxContainer.new()
	dcol.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	drow.add_child(dcol)
	var nrow := HBoxContainer.new()
	nrow.add_theme_constant_override("separation", 12)
	dcol.add_child(nrow)
	dialog_name = _lbl("", 24, Color("49def4"))
	nrow.add_child(dialog_name)
	dialog_title = _lbl("", 14, Color("9bb5cf"))
	dialog_title.size_flags_vertical = Control.SIZE_SHRINK_END
	nrow.add_child(dialog_title)
	dialog_text = RichTextLabel.new()
	dialog_text.bbcode_enabled = false
	dialog_text.fit_content = true
	dialog_text.scroll_active = false
	dialog_text.custom_minimum_size = Vector2(840, 80)
	dialog_text.add_theme_font_size_override("normal_font_size", 21)
	dialog_text.add_theme_color_override("default_color", Color("eef4ff"))
	dcol.add_child(dialog_text)
	dialog_hint = _lbl("▶ ENTER / LEERTASTE  ·  ESC ÜBERSPRINGEN", 11, Color("7f93ad"))
	dialog_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	dcol.add_child(dialog_hint)
	dialog_panel.hide()

	qte_label = _lbl("", 30, Color("ffffff"))
	qte_label.position = Vector2(140, 150)
	qte_label.size = Vector2(1000, 60)
	qte_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	qte_label.hide()
	root.add_child(qte_label)
	qte_ring = QteRing.new()
	qte_ring.position = Vector2(560, 230)
	qte_ring.size = Vector2(160, 160)
	qte_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	qte_ring.hide()
	root.add_child(qte_ring)
	qte_count_label = _lbl("", 22, Color("f7c844"))
	qte_count_label.position = Vector2(140, 400)
	qte_count_label.size = Vector2(1000, 40)
	qte_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	qte_count_label.hide()
	root.add_child(qte_count_label)

	banner = _lbl("", 30, Color("f7c844"))
	banner.position = Vector2(140, 200)
	banner.size = Vector2(1000, 60)
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.modulate.a = 0.0
	root.add_child(banner)

	result_box = VBoxContainer.new()
	result_box.position = Vector2(240, 250)
	result_box.custom_minimum_size = Vector2(800, 180)
	result_box.alignment = BoxContainer.ALIGNMENT_CENTER
	result_box.hide()
	root.add_child(result_box)
	result_title = _lbl("", 72, Color("f7c844"))
	result_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_box.add_child(result_title)
	result_hint = _lbl("", 20)
	result_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_box.add_child(result_hint)

	pause_hint = _lbl("STORY: [Q] Kapitel verlassen", 16, Color("f472b6"))
	pause_hint.position = Vector2(500, 200)
	pause_hint.hide()
	root.add_child(pause_hint)

	credits_label = _lbl("", 26, Color("f3ead8"))
	credits_label.position = Vector2(140, 720)
	credits_label.size = Vector2(1000, 1200)
	credits_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	credits_label.hide()
	root.add_child(credits_label)

	flash_rect = ColorRect.new()
	flash_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash_rect.color = Color(1, 1, 1, 0)
	flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(flash_rect)
	fade_rect = ColorRect.new()
	fade_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(fade_rect)

	_build_menu(root)

func _build_menu(root: Control) -> void:
	menu_panel = PanelContainer.new()
	menu_panel.position = Vector2(290, 60)
	menu_panel.custom_minimum_size = Vector2(700, 600)
	menu_panel.add_theme_stylebox_override("panel", _style(Color(0.02, 0.025, 0.05, 0.97), Color("f472b6"), 14))
	menu_panel.hide()
	root.add_child(menu_panel)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	menu_panel.add_child(v)
	var head := _lbl("📖 STORYMODUS", 16, Color("f472b6"))
	v.add_child(head)
	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 8)
	v.add_child(tabs)
	tabs.add_child(_menu_button("🌌 DER RISS ZWISCHEN DEN WELTEN", Color("c084fc"), func(): set_campaign("saga")))
	tabs.add_child(_menu_button("📖 DIE LETZTE ZEILE", Color("f7c844"), func(): set_campaign("zeile")))
	tabs.add_child(_menu_button("🔥✨ DIE GÖTTLICHE PRÜFUNG", Color("ff5a1f"), func(): set_campaign("divina")))
	tabs.add_child(_menu_button("📜 LEGENDEN", Color("fbbf24"), func(): set_campaign("legend")))
	menu_title = _lbl("", 28, Color("f7c844"))
	v.add_child(menu_title)
	menu_sub = _lbl("", 13, Color("bfcee1"))
	menu_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	menu_sub.custom_minimum_size.x = 660
	v.add_child(menu_sub)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(660, 330)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	v.add_child(scroll)
	menu_list = VBoxContainer.new()
	menu_list.add_theme_constant_override("separation", 5)
	menu_list.custom_minimum_size.x = 640
	scroll.add_child(menu_list)
	menu_realm_row = HBoxContainer.new()
	menu_realm_row.add_theme_constant_override("separation", 10)
	v.add_child(menu_realm_row)
	menu_realm_row.add_child(_menu_button("🔥 HÖLLENREICH", Color("ef4444"), func(): start_chapter(_realm_target("hell"))))
	menu_realm_row.add_child(_menu_button("✨ HIMMELREICH", Color("ffe08a"), func(): start_chapter(_realm_target("heaven"))))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	v.add_child(row)
	var cont := _menu_button("▶ WEITERSPIELEN", Color("4ade80"), func(): start_chapter(continue_index()))
	row.add_child(cont)
	var back := _menu_button("ZURÜCK", Color("ef4444"), close_menu)
	row.add_child(back)
	_build_choice(root)

## Decision panel for "choice" steps: two options, keyboard (←/→, 1/2, Enter), pad (D-pad, A) or mouse.
func _build_choice(root: Control) -> void:
	choice_panel = PanelContainer.new()
	choice_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	choice_panel.position = Vector2(240, 470)
	choice_panel.custom_minimum_size = Vector2(800, 150)
	choice_panel.add_theme_stylebox_override("panel", _style(Color(0.03, 0.02, 0.07, 0.95), Color("c084fc"), 14))
	choice_panel.hide()
	root.add_child(choice_panel)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	choice_panel.add_child(v)
	choice_label = _lbl("", 20, Color("f5e9ff"))
	choice_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	choice_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(choice_label)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 24)
	v.add_child(row)
	for k in range(2):
		var idx := k
		var b := _menu_button("", Color("c084fc"), func(): _choose(idx))
		b.custom_minimum_size = Vector2(360, 54)
		b.add_theme_font_size_override("font_size", 18)
		row.add_child(b)
		choice_buttons.append(b)
	v.add_child(_lbl("← → wählen  ·  ENTER / A bestätigen", 12, Color("94a3b8")))

func _choose(idx: int) -> void:
	if choice_panel.visible: choice_result = idx

func _highlight_choice() -> void:
	for k in range(choice_buttons.size()):
		var b: Button = choice_buttons[k]
		b.add_theme_stylebox_override("normal", _style(Color("2c1f47") if k == choice_index else Color("14202e"), Color("f0abfc") if k == choice_index else Color("6b4c8a"), 8))

func _menu_button(text: String, color: Color, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 40)
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", 16)
	b.add_theme_stylebox_override("normal", _style(Color("14202e"), color.darkened(0.3), 8))
	b.add_theme_stylebox_override("hover", _style(Color("22364a"), color, 8))
	b.add_theme_stylebox_override("pressed", _style(Color("2c4760"), color, 8))
	b.add_theme_stylebox_override("disabled", _style(Color("0c1118"), Color("222a35"), 8))
	b.pressed.connect(cb)
	return b

func _refresh_menu() -> void:
	for c in menu_list.get_children(): c.queue_free()
	var divina: bool = campaign == "divina"
	var saga: bool = campaign == "saga"
	menu_title.text = "PROMPT FIGHTER – " + (StoryDivina.TITLE if divina else (StorySaga.TITLE if saga else StoryData.TITLE))
	menu_sub.text = StoryDivina.SUBTITLE if divina else (StorySaga.SUBTITLE if saga else "Eine Welt aus Worten wird gelöscht. Nur der letzte Promptgeborene kann die letzte Zeile schützen.")
	menu_realm_row.visible = divina
	if campaign == "legend":
		_refresh_legend_menu()
		return
	if saga:
		_refresh_saga_menu()
		return
	var realm_names := {"earth": "🌲 PROLOG · ERDE", "hell": "🔥 INFERNO · DAS HÖLLENREICH", "heaven": "✨ PARADISO · DAS HIMMELREICH"}
	var last_realm := ""
	var list: Array = chapters()
	for k in range(list.size()):
		var ch: Dictionary = list[k]
		if divina and str(ch.realm) != last_realm:
			last_realm = str(ch.realm)
			menu_list.add_child(_lbl(realm_names.get(last_realm, last_realm), 14, Color("ff8a4a") if last_realm == "hell" else Color("ffe08a")))
		var unlocked: bool = is_unlocked(k)
		var done: bool = is_done(k)
		var mark := "✓" if done else ("▶" if unlocked else "🔒")
		if unlocked and not done and needs_full_game(k): mark = "💎"
		var idx := k
		var label_text: String = "%s  KAPITEL %d  ·  %s" % [mark, k + 1, ch.title.to_upper() if unlocked else "???"]
		if divina: label_text = "%s  %s" % [mark, ch.title.to_upper() if unlocked else "???"]
		var b := _menu_button(label_text, (Color("ef4444") if str(ch.get("realm", "")) == "hell" else Color("f7c844")) if unlocked else Color("334155"),
			func(): start_chapter(idx))
		b.disabled = not unlocked
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		menu_list.add_child(b)

## Legends: first every fighter with progress, then the four chapters of the chosen one.
func _refresh_legend_menu() -> void:
	menu_title.text = "📜 LEGENDEN"
	if legend_family == "":
		menu_sub.text = "Jeder Kämpfer hat seine eigene Geschichte. Kapitel öffnen sich mit seinen Meisterschafts-Sternen – spiel ihn, um mehr zu erfahren. Am Ende wartet sein Relikt."
		for preset in main.mk_presets:
			var fam: String = str(preset.id)
			if not StoryLegends.has_legend(fam): continue
			var done := 0
			for k in range(4):
				if done_ids.has("%s_%d" % [fam, k + 1]): done += 1
			var stars: int = main.progression.stars_of(fam) if main.get("progression") != null else 0
			var relic: bool = main.get("progression") != null and main.progression.legend_relics.has(fam)
			var b := _menu_button("%s  %s  ·  %d/4 Kapitel  ·  %s" % ["👑" if relic else ("▶" if done < 4 else "✓"), str(preset.name), done, "★".repeat(stars) + "☆".repeat(maxi(0, 3 - stars))],
				Color("fbbf24") if relic else Color("f7c844"), func(): open_legend(fam))
			b.alignment = HORIZONTAL_ALIGNMENT_LEFT
			menu_list.add_child(b)
		return
	var inf: Dictionary = StoryLegends.info(legend_family)
	menu_title.text = "📜 " + StoryLegends.cast_name(legend_family) + " – " + str(inf.epithet).to_upper()
	menu_sub.text = "%s   ·   Sterne: %s   ·   Relikt: %s" % [str(inf.summary), "★".repeat(legend_stars()), str(inf.get("relic", ""))]
	var list: Array = chapters()
	for k in range(list.size()):
		var ch: Dictionary = list[k]
		var unlocked: bool = is_unlocked(k)
		var mark := "✓" if is_done(k) else ("▶" if unlocked else "🔒")
		var need: int = int(ch.get("stars", 0))
		var lock_txt := "" if unlocked else ("  ·  braucht ★%d (%s spielen)" % [need, StoryLegends.cast_name(legend_family)] if legend_stars() < need else "  ·  erst Kapitel %d" % k)
		var idx := k
		var b := _menu_button("%s  KAPITEL %s  ·  %s%s" % [mark, ["I", "II", "III", "IV"][k], str(ch.title).to_upper(), lock_txt], Color("fbbf24") if unlocked else Color("334155"),
			func(): start_chapter(idx))
		b.disabled = not unlocked
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		menu_list.add_child(b)
	menu_list.add_child(_menu_button("◀ ALLE LEGENDEN", Color("94a3b8"), func():
		legend_family = ""
		_refresh_menu()))

## Saga menu: grouped by act; act II lists every world, open in any order.
func _refresh_saga_menu() -> void:
	var act_names := {"prolog": "PROLOG", "act1": "AKT I · DIE SPUR DER SPLITTER", "act2": "AKT II · DIE VERLORENEN WELTEN (freie Reihenfolge)",
		"act3": "AKT III · DIE LETZTE FEDER", "epilog": "EPILOG"}
	var last_act := ""
	var list: Array = chapters()
	var bonds := 0
	for b in StorySaga.BONDS: if flags.get(b, false): bonds += 1
	menu_sub.text = StorySaga.SUBTITLE + "   ·   Verbündete: %d / %d" % [bonds, StorySaga.BONDS.size()]
	for k in range(list.size()):
		var ch: Dictionary = list[k]
		if str(ch.act) != last_act:
			last_act = str(ch.act)
			menu_list.add_child(_lbl(act_names.get(last_act, last_act), 14, Color("c084fc")))
		var unlocked: bool = is_unlocked(k)
		var mark := "✓" if is_done(k) else ("▶" if unlocked else "🔒")
		var idx := k
		var b := _menu_button("%s  %s" % [mark, str(ch.title).to_upper() if unlocked else "???"], Color("c084fc") if unlocked else Color("334155"),
			func(): start_chapter(idx))
		b.disabled = not unlocked
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		menu_list.add_child(b)

## Chapters and cast of the current campaign.
func chapters() -> Array:
	if campaign == "legend":
		if legend_family == "": return []
		if not _legend_cache.has(legend_family): _legend_cache[legend_family] = StoryLegends.chapters(legend_family)
		return _legend_cache[legend_family]
	if campaign == "saga":
		if _saga_cache.is_empty(): _saga_cache = StorySaga.chapters()
		return _saga_cache
	return StoryDivina.all() if campaign == "divina" else StoryData.CHAPTERS

func cast_table() -> Dictionary:
	if campaign == "legend" and legend_family != "": return StoryLegends.cast(legend_family, main.mk_presets)
	if campaign == "saga": return StorySaga.CAST
	return StoryDivina.CAST if campaign == "divina" else StoryData.CAST

## Profile of a cast member of the current campaign (its own cast first).
func _profile(id: String, slot: int, heroes: int = 1) -> Dictionary:
	var c: Dictionary = cast_table().get(id, {})
	if c.is_empty(): return cast_profile(id, slot, heroes)
	if c.has("boss"): return Bosses.profile(str(c.boss), heroes)
	var p: Dictionary = Prompt.interpret(c.prompt, slot)
	p.name = c.name
	return p

## Mastery stars of the open legend's fighter.
func legend_stars() -> int:
	if main.get("progression") == null: return 0
	return main.progression.stars_of(legend_family)

func open_legend(fam: String) -> void:
	campaign = "legend"
	legend_family = fam
	if menu_panel != null and menu_panel.visible: _refresh_menu()

func set_campaign(id: String) -> void:
	if id == "legend": legend_family = ""
	campaign = id
	if menu_panel != null and menu_panel.visible: _refresh_menu()

func is_done(k: int) -> bool:
	if campaign == "divina" or campaign == "saga" or campaign == "legend": return done_ids.has(str(chapters()[k].id))
	return k < completed

func is_unlocked(k: int) -> bool:
	if campaign == "legend":
		var need: int = int(chapters()[k].get("stars", 0))
		return legend_stars() >= need and (k == 0 or is_done(k - 1))
	if campaign == "saga":
		var ch: Dictionary = chapters()[k]
		for req in ch.get("requires", []):
			if not done_ids.has(str(req)): return false
		return true
	if campaign != "divina": return k <= completed
	var list: Array = chapters()
	return bool(list[k].get("start", false)) or is_done(k) or (k > 0 and is_done(k - 1))

## First unlocked, unfinished chapter (the whole journey in order).
func continue_index() -> int:
	var list: Array = chapters()
	for k in range(list.size()):
		if is_unlocked(k) and not is_done(k): return k
	return list.size() - 1

## First unfinished chapter of a realm (hell or heaven).
func _realm_target(realm: String) -> int:
	var list: Array = chapters()
	var first := -1
	for k in range(list.size()):
		if str(list[k].realm) != realm: continue
		if first < 0: first = k
		if is_unlocked(k) and not is_done(k): return k
	return first

func open_menu() -> void:
	_refresh_menu()
	menu_panel.show()
	main.sound("jump")

func close_menu() -> void:
	menu_panel.hide()

# ─────────────────────────────────────────────────────────────── progress ──

func load_progress() -> void:
	if not persist: return
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		completed = clampi(int(cfg.get_value("story", "completed", 0)), 0, StoryData.chapter_count())
		flags = cfg.get_value("story", "flags", {})
		done_ids = cfg.get_value("divina", "done", {})

func save_progress() -> void:
	if not persist or DisplayServer.get_name() == "headless": return
	var cfg := ConfigFile.new()
	cfg.set_value("story", "completed", completed)
	cfg.set_value("story", "flags", flags)
	cfg.set_value("divina", "done", done_ids)
	cfg.save(SAVE_PATH)

# ─────────────────────────────────────────────────────────────── chapter flow ──

## Chapters playable without the Vollversion (Google Play free tier).
const FREE_CHAPTERS := ["d0", "h1", "p1"]

func needs_full_game(k: int) -> bool:
	if campaign != "divina" or not main.has_method("full_game_locked") or not main.full_game_locked(): return false
	return not str(chapters()[k].get("id", "")) in FREE_CHAPTERS

func start_chapter(index: int) -> void:
	if index < 0 or index >= chapters().size(): return
	if needs_full_game(index):
		close_menu()
		main.show_full_game_offer()
		return
	close_menu()
	session += 1
	running = true
	in_fight = false
	skipping = false
	chapter_index = index
	main.sound("start")
	_run_chapter(index, session)

func _alive(my_session: int) -> bool:
	return running and my_session == session

func _run_chapter(index: int, my_session: int) -> void:
	var steps: Array = chapters()[index].steps
	main.music({"saga": "story_calm", "divina": "story_tense"}.get(campaign, "story_calm"))
	await fade(1.0, 0.25)
	_set_letterbox(true, 0.01)
	for step in steps:
		if not _alive(my_session): return
		await run_step(step, my_session)
	if not _alive(my_session): return
	if campaign == "divina" or campaign == "saga" or campaign == "legend": done_ids[str(chapters()[index].id)] = true
	if campaign == "legend" and str(chapters()[index].id).ends_with("_4") and main.get("progression") != null:
		main.progression.grant_legend(legend_family, StoryLegends.RELIC_COINS)
	else: completed = maxi(completed, index + 1)
	if main.get("progression") != null: main.progression.story_chapter_done(60) # a finished chapter pays coins
	save_progress()
	await fade(1.0, 0.6)
	_end_story_session()
	if index + 1 < chapters().size():
		open_menu()

## Leaves the story and returns to fighter selection.
func abort() -> void:
	session += 1
	_end_story_session()

func _end_story_session() -> void:
	running = false
	in_fight = false
	qte_active = false
	skipping = false
	get_tree().paused = false
	_hide_overlays()
	_set_letterbox(false, 0.2)
	fade(0.0, 0.4)
	main.show_selection()

func _hide_overlays() -> void:
	dialog_panel.hide()
	if choice_panel != null: choice_panel.hide()
	qte_ring.hide()
	qte_label.hide()
	qte_count_label.hide()
	result_box.hide()
	credits_label.hide()
	pause_hint.hide()
	title_box.modulate.a = 0.0
	narrate_label.modulate.a = 0.0
	banner.modulate.a = 0.0

func run_step(step: Dictionary, my_session: int) -> void:
	match str(step.get("t", "")):
		"stage": _stage(step)
		"title": await _title(step, my_session)
		"narrate": await _narrate(step.text, my_session)
		"say": await _say(step, my_session)
		"cam": await _cam(step, my_session)
		"move": await _move(step, my_session)
		"pose": await _pose(step, my_session)
		"face": _fighter(int(step.who)).facing = int(step.facing)
		"fx": _fx(step)
		"vanish": _set_visible(int(step.who), false)
		"appear": _set_visible(int(step.who), true)
		"wait": await wait(float(step.get("time", 0.5)), my_session)
		"qte": await _qte_step(step, my_session)
		"fight": await _fight(step, my_session)
		"credits": await _credits(my_session)
		"music": main.music(MOODS.get(str(step.get("mood", "calm")), "story_calm"))
		"set": flags[str(step.flag)] = true
		"choice": await _choice(step, my_session)
		"branch":
			for sub_step in (step.get("steps", []) if flags.get(str(step.flag), false) else step.get("else", [])):
				if not _alive(my_session): return
				await run_step(sub_step, my_session)
		"bonds":
			for sub_step in (step.get("steps", []) if bond_count() >= int(step.get("min", 1)) else step.get("else", [])):
				if not _alive(my_session): return
				await run_step(sub_step, my_session)
		_: push_warning("Unknown story step: %s" % str(step))

## Healed fighters who joined Volt in the saga.
func bond_count() -> int:
	var n := 0
	for b in StorySaga.BONDS: if flags.get(b, false): n += 1
	return n

## Decision: shows two options, remembers the chosen flag and plays that option's steps.
func _choice(step: Dictionary, my_session: int) -> void:
	var options: Array = step.options
	var pick := 0
	if not auto_advance and not skipping:
		choice_label.text = str(step.get("text", ""))
		for k in range(choice_buttons.size()):
			(choice_buttons[k] as Button).text = str(options[k].label) if k < options.size() else ""
		choice_index = 0
		choice_result = -1
		_highlight_choice()
		choice_panel.show()
		while choice_result < 0 and _alive(my_session):
			await get_tree().process_frame
		choice_panel.hide()
		pick = clampi(choice_result, 0, options.size() - 1)
		main.sound("start")
	var opt: Dictionary = options[pick]
	flags[str(opt.flag)] = true
	for sub_step in opt.get("steps", []):
		if not _alive(my_session): return
		await run_step(sub_step, my_session)

## Voiced line for a speaker and text (generated by tools/voice_lines.py), "" when missing.
static func voice_path(who: String, text: String) -> String:
	return VOICE_DIR + ("%s|%s" % [who, text]).md5_text().left(16) + ".ogg"

func _speak(who: String, text: String) -> void:
	if main.get("audio_director") == null or main.audio_director == null: return
	var path := voice_path(who, text)
	if ResourceLoader.exists(path): main.audio_director.speak(path)

# ─────────────────────────────────────────────────────────────── helpers ──

func chapter_title() -> String:
	if chapter_index < 0: return ""
	if campaign == "divina": return str(chapters()[chapter_index].title).to_upper()
	return "KAPITEL %d: %s" % [chapter_index + 1, str(chapters()[chapter_index].title).to_upper()]

static func cast_profile(id: String, slot: int, heroes: int = 1) -> Dictionary:
	var c: Dictionary = StoryData.CAST.get(id, StoryDivina.CAST.get(id, StorySaga.CAST.get(id, {})))
	if c.has("boss"): return Bosses.profile(str(c.boss), heroes)
	var p: Dictionary = Prompt.interpret(c.prompt, slot)
	p.name = c.name
	return p

func _fighter(i: int) -> Dictionary:
	return main.sim.fighters[i] if i >= 0 and i < main.sim.fighters.size() else {}

func _set_visible(i: int, v: bool) -> void:
	if i < main.views.size() and is_instance_valid(main.views[i]):
		main.views[i].visible = v

## Waits real time; returns early when skipping or aborted.
func wait(seconds: float, my_session: int) -> void:
	var t := 0.0
	while t < seconds and _alive(my_session) and not skipping and not auto_advance:
		await get_tree().process_frame
		t += get_process_delta_time()

func fade(to_alpha: float, time: float) -> void:
	var tw := create_tween()
	tw.tween_property(fade_rect, "color:a", to_alpha, time)
	await tw.finished

func _set_letterbox(on: bool, time: float) -> void:
	var tw := create_tween().set_parallel(true)
	tw.tween_property(letterbox_top, "offset_bottom", LETTERBOX_HEIGHT if on else 0.0, time)
	tw.tween_property(letterbox_bottom, "offset_top", -LETTERBOX_HEIGHT if on else 0.0, time)

func _wait_advance(my_session: int) -> void:
	if auto_advance or skipping: return
	await advanced

# ─────────────────────────────────────────────────────────────── step types ──

func _stage(step: Dictionary) -> void:
	stage_ids.clear()
	var p_list: Array = []
	for k in range(step.cast.size()):
		var entry: Dictionary = step.cast[k]
		stage_ids.append(entry.id)
		p_list.append(_profile(entry.id, k))
	main.prepare_cutscene_stage(p_list, chapters()[chapter_index].arena)
	for k in range(step.cast.size()):
		var f: Dictionary = _fighter(k)
		f.x = float(step.cast[k].x)
		if not f.is_boss: f.y = 0.0
		f.facing = int(step.cast[k].get("facing", 1))
		f.pose = "Idle"
		if k < main.views.size():
			main.views[k].update_state(f, 1.0)
			main.views[k].reset_physics_interpolation()
	fade(0.0, 0.35)
	_set_letterbox(true, 0.3)

func _title(step: Dictionary, my_session: int) -> void:
	title_label.text = step.text
	subtitle_label.text = step.get("sub", "")
	var tw := create_tween()
	tw.tween_property(title_box, "modulate:a", 1.0, 0.5)
	main.sound("start")
	await wait(2.2, my_session)
	var tw2 := create_tween()
	tw2.tween_property(title_box, "modulate:a", 0.0, 0.4)

func _narrate(text: String, my_session: int) -> void:
	narrate_label.text = text
	_speak("erzaehler", text)
	var tw := create_tween()
	tw.tween_property(narrate_label, "modulate:a", 1.0, 0.4)
	await _wait_advance(my_session)
	var tw2 := create_tween()
	tw2.tween_property(narrate_label, "modulate:a", 0.0, 0.25)
	if not auto_advance and not skipping: await tw2.finished

func _say(step: Dictionary, my_session: int) -> void:
	var c: Dictionary = cast_table().get(step.who, {})
	var col := Color(str(c.get("color", "49def4")))
	dialog_name.text = str(c.get("name", step.who))
	dialog_name.add_theme_color_override("font_color", col)
	dialog_title.text = str(c.get("title", ""))
	dialog_panel.add_theme_stylebox_override("panel", _style(Color(0.02, 0.03, 0.06, 0.92), col))
	var prompt: String = str(c.get("prompt", ""))
	if prompt.is_empty():
		dialog_portrait.texture = null
	else:
		dialog_portrait.texture = main.portrait_for_family(Prompt.interpret(prompt, 0).family)
	dialog_text.text = step.text
	dialog_text.visible_characters = 0
	dialog_panel.show()
	_speak(str(step.who), str(step.text))
	if not auto_advance and not skipping:
		typing = true
		var total: int = step.text.length()
		var shown := 0.0
		while typing and shown < total and _alive(my_session):
			await get_tree().process_frame
			shown += get_process_delta_time() * TYPE_SPEED
			dialog_text.visible_characters = int(shown)
		typing = false
	dialog_text.visible_characters = -1
	await _wait_advance(my_session)
	if main.get("audio_director") != null and main.audio_director != null: main.audio_director.stop_voice()
	dialog_panel.hide()

## Camera shots are computed from the current stage positions.
func _cam(step: Dictionary, my_session: int) -> void:
	var shot: String = str(step.get("shot", "wide"))
	var who: int = int(step.get("who", 0))
	var f: Dictionary = _fighter(who)
	var x: float = float(f.get("x", 0.0))
	var target_pos := Vector3(0, 2.4, 10.5)
	var target_look := Vector3(0, 1.3, 0)
	match shot:
		"wide":
			target_pos = Vector3(0, 2.6, 11.5)
			target_look = Vector3(0, 1.3, 0)
		"sky":
			target_pos = Vector3(0, 7.5, 15.0)
			target_look = Vector3(0, 2.4, 0)
		"close":
			var side: float = float(f.get("facing", 1))
			target_pos = Vector3(x + side * 1.1, 1.75, 3.4)
			target_look = Vector3(x, 1.45, 0)
			if f.get("is_boss", false):
				# Bosses are huge: step back and look up at the body.
				target_pos = Vector3(x + side * 1.6, float(f.y) + 2.2, 7.2)
				target_look = Vector3(x, float(f.y) + 1.9, 0)
		"low":
			target_pos = Vector3(x - float(f.get("facing", 1)) * 0.6, 0.45, 3.6)
			target_look = Vector3(x, 1.8, 0)
		"two":
			var x2: float = float(_fighter(int(step.get("who2", 1))).get("x", 0.0))
			var mid: float = (x + x2) * 0.5
			var span: float = absf(x2 - x)
			target_pos = Vector3(mid, 1.9, 4.2 + span * 0.9)
			target_look = Vector3(mid, 1.3, 0)
	var time: float = float(step.get("time", 1.0))
	if time <= 0.02 or auto_advance or skipping:
		cam_pos = target_pos
		cam_look = target_look
		return
	var tw := create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(self, "cam_pos", target_pos, time)
	tw.tween_property(self, "cam_look", target_look, time)
	await wait(time * 0.6, my_session)

func _move(step: Dictionary, my_session: int) -> void:
	var i: int = int(step.who)
	var f: Dictionary = _fighter(i)
	if f.is_empty(): return
	var from_x: float = f.x
	var to_x: float = float(step.x)
	var time: float = maxf(0.05, float(step.get("time", 1.0)))
	f.facing = 1 if to_x > from_x else -1
	f.pose = "Move"
	var t := 0.0
	while t < time and _alive(my_session) and not skipping and not auto_advance:
		await get_tree().physics_frame
		t += get_physics_process_delta_time()
		f.x = lerpf(from_x, to_x, clampf(t / time, 0.0, 1.0))
	f.x = to_x
	f.pose = "Idle"

func _pose(step: Dictionary, my_session: int) -> void:
	var f: Dictionary = _fighter(int(step.who))
	if f.is_empty(): return
	f.pose = str(step.pose)
	await wait(float(step.get("time", 0.8)), my_session)
	if not str(step.pose) in ["Defeat", "Victory"]:
		f.pose = "Idle"

func _fx(step: Dictionary) -> void:
	var kind: String = str(step.kind)
	var who: int = int(step.get("who", 0))
	match kind:
		"flash":
			flash_rect.color.a = 0.9
			create_tween().tween_property(flash_rect, "color:a", 0.0, 0.6)
			main.sound("electric")
		"shake":
			cam_shake = 0.6
			main.sound("lava")
		"burst":
			if who < main.sim.fighters.size():
				main.hit_effect(who, true, true)
				main.super_effect(who)
			cam_shake = 0.4
			main.sound("hit")
		"ink":
			_ink_burst(who)
			cam_shake = 0.3
			main.sound("lava")

## Black-violet ink particles bursting from a corrupted fighter.
func _ink_burst(who: int) -> void:
	var f: Dictionary = _fighter(who)
	if f.is_empty(): return
	var p := CPUParticles3D.new()
	p.one_shot = true
	p.emitting = false
	p.amount = 60
	p.lifetime = 1.4
	p.explosiveness = 0.85
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = 0.5
	p.direction = Vector3(0, 1, 0)
	p.spread = 70.0
	p.initial_velocity_min = 1.5
	p.initial_velocity_max = 4.0
	p.gravity = Vector3(0, -2.5, 0)
	p.scale_amount_min = 0.6
	p.scale_amount_max = 1.6
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	mat.vertex_color_use_as_albedo = true
	var quad := QuadMesh.new()
	quad.size = Vector2(0.16, 0.16)
	quad.material = mat
	p.mesh = quad
	var grad := Gradient.new()
	grad.set_color(0, Color(0.35, 0.05, 0.6, 1.0))
	grad.set_color(1, Color(0.02, 0.0, 0.05, 0.0))
	p.color_ramp = grad
	main.add_child(p)
	p.position = Vector3(f.x, f.y + 1.1, 0.2)
	p.emitting = true
	get_tree().create_timer(2.0).timeout.connect(p.queue_free)

# ─────────────────────────────────────────────────────────────── quick-time events ──

## Display name of the key bound to a gameplay action for player 1.
static func key_name(action: String) -> String:
	var a := "p1_" + action
	if InputMap.has_action(a):
		for ev in InputMap.action_get_events(a):
			if ev is InputEventKey:
				var code: int = ev.physical_keycode if ev.physical_keycode != 0 else ev.keycode
				return OS.get_keycode_string(code)
	return action.to_upper()

## Starts a QTE. Kinds: press (one key in time), mash (count presses in time),
## sequence (each key in order, each with its own time window).
func begin_qte(step: Dictionary) -> void:
	qte = {
		"kind": str(step.get("kind", "press")),
		"keys": step.get("keys", ["standard"]),
		"index": 0,
		"count": 0,
		"need": int(step.get("count", 1)),
		"window": float(step.get("time", 1.2)),
		"left": float(step.get("time", 1.2)),
	}
	qte_active = true
	_qte_refresh()

func _qte_refresh() -> void:
	var key: String = qte.keys[mini(qte.index, qte.keys.size() - 1)]
	qte_ring.glyph = key_name(key)
	qte_ring.fraction = clampf(qte.left / qte.window, 0.0, 1.0)
	qte_ring.queue_redraw()
	if qte.kind == "mash":
		qte_count_label.text = "%d / %d" % [qte.count, qte.need]
	elif qte.kind == "sequence":
		qte_count_label.text = "%d / %d" % [qte.index, qte.keys.size()]
	else:
		qte_count_label.text = ""

## Feeds one pressed action into the running QTE.
func qte_press(action: String) -> void:
	if not qte_active: return
	var expected: String = qte.keys[mini(qte.index, qte.keys.size() - 1)]
	qte_ring.pulse = 1.0
	if action != expected:
		if qte.kind != "mash": _qte_end(false)
		return
	match qte.kind:
		"press":
			_qte_end(true)
		"mash":
			qte.count += 1
			main.sound("block")
			if qte.count >= qte.need: _qte_end(true)
		"sequence":
			qte.index += 1
			main.sound("block")
			if qte.index >= qte.keys.size():
				_qte_end(true)
			else:
				qte.left = qte.window
	if qte_active: _qte_refresh()

func qte_tick(dt: float) -> void:
	if not qte_active: return
	qte.left -= dt
	qte_ring.pulse = maxf(0.0, qte_ring.pulse - dt * 6.0)
	if qte.left <= 0.0:
		_qte_end(false)
	else:
		_qte_refresh()

func _qte_end(success: bool) -> void:
	if not qte_active: return
	qte_active = false
	qte_ring.color = Color("4ade80") if success else Color("ef4444")
	qte_ring.fraction = 1.0
	qte_ring.queue_redraw()
	main.sound("victory" if success else "hit")
	qte_finished.emit(success)

func _qte_step(step: Dictionary, my_session: int) -> void:
	var success: bool = auto_qte_success
	if not auto_advance and not skipping:
		qte_label.text = step.get("text", "")
		qte_ring.color = Color("f7c844")
		qte_label.show()
		qte_ring.show()
		qte_count_label.show()
		begin_qte(step)
		success = await qte_finished
		await wait(0.5, my_session)
		qte_label.hide()
		qte_ring.hide()
		qte_count_label.hide()
	elif skipping:
		return # skipped QTEs count neither as success nor as failure
	if step.has("flag"): flags[step.flag] = success
	var branch: Array = step.get("success" if success else "fail", [])
	for sub in branch:
		if not _alive(my_session): return
		await run_step(sub, my_session)

# ─────────────────────────────────────────────────────────────── fights ──

func _fight(step: Dictionary, my_session: int) -> void:
	skipping = false
	current_fight = step
	while _alive(my_session):
		_start_fight(step)
		var win: bool = await fight_done
		if not _alive(my_session): return
		if win:
			await _show_result("SIEG!", "", 1.6, my_session)
			result_box.hide()
			return
		result_title.text = "NIEDERLAGE"
		result_title.add_theme_color_override("font_color", Color("ef4444"))
		result_hint.text = "[ENTER] NOCHMAL VERSUCHEN   ·   [ESC] ZUM KAPITELMENÜ"
		result_box.show()
		if auto_advance: return
		var retry: bool = await _await_retry_choice()
		result_box.hide()
		if not retry:
			abort()
			open_menu()
			return

var _retry_choice := -1

func _await_retry_choice() -> bool:
	_retry_choice = -1
	while _retry_choice < 0 and running:
		await get_tree().process_frame
	return _retry_choice == 1

func _start_fight(step: Dictionary) -> void:
	var p_list: Array = []
	var heroes: int = 0
	for id in step.cast:
		if not cast_table().get(id, {}).has("boss"): heroes += 1
	for k in range(step.cast.size()):
		p_list.append(_profile(step.cast[k], k, heroes))
	_hide_overlays()
	_set_letterbox(false, 0.25)
	fade(0.0, 0.2)
	main.begin_match(p_list, "pve", 3)
	var sim = main.sim
	var lives: Array = step.get("lives", [])
	for k in range(mini(lives.size(), sim.fighters.size())):
		sim.fighters[k].lives = int(lives[k])
	if step.has("teams"): sim.set_teams(step.teams)
	for f in sim.fighters:
		if f.is_boss: sim.time_left = 300.0 # boss fights get more time
	var mods: Dictionary = step.get("mods", {})
	for key in mods:
		var k: int = int(key)
		if k < sim.fighters.size():
			sim.fighters[k].power_mult = float(mods[key].get("power", 1.0))
			sim.fighters[k].kb_taken_mult = float(mods[key].get("kb", 1.0))
	# Extra fight options (legends): time limit, starting damage per slot, AI level for this fight.
	if step.has("time"): sim.time_left = float(step.time)
	var dmg_start: Dictionary = step.get("damage", {})
	for key in dmg_start:
		if int(key) < sim.fighters.size(): sim.fighters[int(key)].damage_percent = float(dmg_start[key])
	if step.has("ai"): sim.ai_level = int(step.ai)
	# A won QTE softens the enemies up, a lost one costs the player some percent.
	var flag: String = str(step.get("qte", ""))
	if flags.has(flag):
		if flags[flag]:
			for f in sim.fighters:
				if f.team != 0: f.damage_percent = QTE_BONUS_PERCENT
		else:
			sim.fighters[0].damage_percent = QTE_PENALTY_PERCENT
	in_fight = true
	main.show_status(str(step.get("goal", "")), 4.0)
	show_banner(str(step.get("goal", "KAMPF!")))

func show_banner(text: String) -> void:
	banner.text = text
	var tw := create_tween()
	tw.tween_property(banner, "modulate:a", 1.0, 0.3)
	tw.tween_interval(1.8)
	tw.tween_property(banner, "modulate:a", 0.0, 0.5)

## Called by main when the story fight's simulation reports a result.
func on_fight_finished(result: int) -> void:
	if not in_fight: return
	in_fight = false
	var win: bool = result >= 0 and main.sim.fighters[result].team == 0
	fight_done.emit(win)

func retry_fight() -> void:
	if in_fight and not current_fight.is_empty():
		_start_fight(current_fight)

func _show_result(title: String, hint: String, time: float, my_session: int) -> void:
	result_title.text = title
	result_title.add_theme_color_override("font_color", Color("f7c844"))
	result_hint.text = hint
	result_box.show()
	await wait(time, my_session)

func _credits(my_session: int) -> void:
	_hide_overlays()
	await fade(1.0, 1.0)
	if campaign == "saga":
		credits_label.text = "\n".join(StorySaga.CREDITS)
	elif campaign == "divina":
		credits_label.text = "\n".join(StoryDivina.CREDITS)
	else: credits_label.text = "\n".join([
		"PROMPT FIGHTER", StoryData.TITLE, "", "",
		"VOLT – der letzte Promptgeborene", "AURA – Hüterin des Lichthains", "KORSAR – Kapitän der Salzkrähe",
		"SIR KALDEN · CINDER BASTION · DREYAR · WARROK", "SCHATTEN-VOLT", "NOVA, die einst NULLA hieß", "",
		"und ARIA, die Schreiberin", "", "", "Danke fürs Spielen.", "", "Jeder Prompt ist eine neue Seite."])
	credits_label.position.y = 720
	credits_label.show()
	if auto_advance: return
	var tw := create_tween()
	tw.tween_property(credits_label, "position:y", -900.0, 22.0)
	await wait(22.5, my_session)
	credits_label.hide()

# ─────────────────────────────────────────────────────────────── frame & input ──

func _process(delta: float) -> void:
	if running and main.cinematic and main.camera:
		var shake := Vector3.ZERO
		if cam_shake > 0.0:
			cam_shake = maxf(0.0, cam_shake - delta * 1.6)
			shake = Vector3(randf_range(-1, 1), randf_range(-1, 1), 0) * cam_shake * 0.25
		main.camera.position = cam_pos + shake
		main.camera.look_at(cam_look + shake * 0.5)
	if qte_active: qte_tick(delta)
	pause_hint.visible = running and in_fight and main.paused

func _input(event: InputEvent) -> void:
	if menu_panel.visible and event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			close_menu()
		elif event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
			start_chapter(continue_index())
		get_viewport().set_input_as_handled() # the selection screen below must not react
		return
	if not running: return
	if choice_panel != null and choice_panel.visible:
		var dir := 0
		if event.is_action_pressed("ui_left") or (event is InputEventKey and event.pressed and event.keycode == KEY_1): dir = -1
		elif event.is_action_pressed("ui_right") or (event is InputEventKey and event.pressed and event.keycode == KEY_2): dir = 1
		if dir != 0:
			choice_index = 0 if dir < 0 else 1
			_highlight_choice()
			if event is InputEventKey and event.keycode in [KEY_1, KEY_2]: choice_result = choice_index
		elif event.is_action_pressed("ui_accept") or (event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_A):
			choice_result = choice_index
		get_viewport().set_input_as_handled()
		return
	if event is InputEventJoypadButton and event.pressed:
		# Controller: A continues / retries, B or Menu skips / gives up, View leaves a paused fight.
		var jb: int = event.button_index
		if result_box.visible and _retry_choice == -1:
			if jb == JOY_BUTTON_A: _retry_choice = 1
			elif jb == JOY_BUTTON_B or jb == JOY_BUTTON_BACK: _retry_choice = 0
			get_viewport().set_input_as_handled()
			return
		if in_fight:
			if main.paused and jb == JOY_BUTTON_BACK:
				abort()
				open_menu()
				get_viewport().set_input_as_handled()
			return
		if not qte_active:
			if jb == JOY_BUTTON_A or jb == JOY_BUTTON_X:
				if typing: typing = false
				else: advanced.emit()
				get_viewport().set_input_as_handled()
				return
			if jb == JOY_BUTTON_B or jb == JOY_BUTTON_START:
				skipping = true
				typing = false
				advanced.emit()
				get_viewport().set_input_as_handled()
				return
	# Retry / give up after a lost fight.
	if result_box.visible and _retry_choice == -1 and event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE]:
			_retry_choice = 1
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE:
			_retry_choice = 0
			get_viewport().set_input_as_handled()
		return
	if in_fight:
		if main.paused and event is InputEventKey and event.pressed and event.keycode == KEY_Q:
			abort()
			open_menu()
			get_viewport().set_input_as_handled()
		return
	if qte_active:
		for action in QTE_ACTIONS:
			for pl in ["p1_", "p2_"]:
				if InputMap.has_action(pl + action) and event.is_action_pressed(pl + action, false, true):
					qte_press(action)
					get_viewport().set_input_as_handled()
					return
		return
	var pressed_advance := false
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			skipping = true
			typing = false
			advanced.emit()
			get_viewport().set_input_as_handled()
			return
		pressed_advance = event.keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_F, KEY_K]
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pressed_advance = not menu_panel.visible
	if pressed_advance:
		if typing:
			typing = false
		else:
			advanced.emit()
		get_viewport().set_input_as_handled()
