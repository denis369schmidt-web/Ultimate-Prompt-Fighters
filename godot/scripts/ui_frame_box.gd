@tool
extends StyleBox
## Framed plate for every menu window, card and button (see ui_style.gd).
## Cut corners (large top-left / bottom-right, small elsewhere), a vertical gradient fill,
## a double edge (outer rim plus an inner light seam), a soft gradient drop shadow and
## optional corner brackets. Drawn with a handful of RenderingServer calls, no shader.
## Property names mirror StyleBoxFlat so existing code (border_width_left = 4, shadow_size ...)
## keeps working.

@export var bg_color := Color(0.05, 0.08, 0.13, 0.94):
	set(v): bg_color = v; emit_changed()
@export var border_color := Color("33425c"):
	set(v): border_color = v; emit_changed()
@export var border_width_left := 1:
	set(v): border_width_left = v; emit_changed()
@export var border_width_top := 1:
	set(v): border_width_top = v; emit_changed()
@export var border_width_right := 1:
	set(v): border_width_right = v; emit_changed()
@export var border_width_bottom := 1:
	set(v): border_width_bottom = v; emit_changed()
## Size of the large cut corners (top-left, bottom-right); the small ones use cut_ratio of it.
@export var cut := 10.0:
	set(v): cut = v; emit_changed()
@export var cut_ratio := 0.4:
	set(v): cut_ratio = v; emit_changed()
@export var shadow_color := Color(0, 0, 0, 0.45):
	set(v): shadow_color = v; emit_changed()
@export var shadow_size := 6:
	set(v): shadow_size = v; emit_changed()
@export var shadow_offset := Vector2(0, 3):
	set(v): shadow_offset = v; emit_changed()
## Horizontal slant in pixels (top edge moves right, bottom edge left).
@export var slant := 0.0:
	set(v): slant = v; emit_changed()
## Brightness added at the top of the fill, removed at the bottom.
@export var sheen := 0.07:
	set(v): sheen = v; emit_changed()
## Alpha of the inner light seam (0 = off).
@export var seam := 0.32:
	set(v): seam = v; emit_changed()
## Corner brackets in the border color (top-right and bottom-left).
@export var ornaments := false:
	set(v): ornaments = v; emit_changed()
## Optional glow band inside the bottom edge (selected cards, primary buttons).
@export var underglow := Color(0, 0, 0, 0):
	set(v): underglow = v; emit_changed()
@export var draw_center := true:
	set(v): draw_center = v; emit_changed()
## Kept for StyleBoxFlat compatibility; corners are always cut.
@export var corner_detail := 1

func set_border_width_all(w: int) -> void:
	border_width_left = w
	border_width_top = w
	border_width_right = w
	border_width_bottom = w

func set_corner_radius_all(r: int) -> void:
	cut = float(r)

## Outline with the four cut corners, clockwise from the top-left cut.
static func shape(r: Rect2, big: float, small: float, sl: float) -> PackedVector2Array:
	var lim: float = maxf(1.0, minf(r.size.x, r.size.y) * 0.45)
	big = clampf(big, 1.0, lim)
	small = clampf(small, 1.0, lim)
	var x0 := r.position.x
	var y0 := r.position.y
	var x1 := r.end.x
	var y1 := r.end.y
	var pts := PackedVector2Array([
		Vector2(x0 + big, y0), Vector2(x1 - small, y0), Vector2(x1, y0 + small), Vector2(x1, y1 - big),
		Vector2(x1 - big, y1), Vector2(x0 + small, y1), Vector2(x0, y1 - small), Vector2(x0, y0 + big)])
	if sl != 0.0 and r.size.y > 0.0:
		for i in range(pts.size()):
			pts[i].x += sl * (0.5 - (pts[i].y - y0) / r.size.y)
	return pts

func _ring(item: RID, outer: PackedVector2Array, inner: PackedVector2Array, c_out: PackedColorArray, c_in: PackedColorArray) -> void:
	var n := outer.size()
	var pts := PackedVector2Array(outer)
	pts.append_array(inner)
	var cols := PackedColorArray(c_out)
	cols.append_array(c_in)
	var idx := PackedInt32Array()
	for i in range(n):
		var j := (i + 1) % n
		idx.append_array([i, j, n + j, i, n + j, n + i])
	RenderingServer.canvas_item_add_triangle_array(item, idx, pts, cols)

func _grad(pts: PackedVector2Array, r: Rect2, top: Color, bottom: Color) -> PackedColorArray:
	var cols := PackedColorArray()
	for p in pts:
		cols.append(top.lerp(bottom, clampf((p.y - r.position.y) / maxf(1.0, r.size.y), 0.0, 1.0)))
	return cols

func _get_draw_rect(rect: Rect2) -> Rect2:
	var g: float = float(shadow_size) + absf(slant) * 0.5 + 6.0
	return rect.grow(g + maxf(absf(shadow_offset.x), absf(shadow_offset.y)))

func _draw(item: RID, rect: Rect2) -> void:
	if rect.size.x < 2.0 or rect.size.y < 2.0: return
	var small: float = cut * cut_ratio
	var outer := shape(rect, cut, small, slant)
	var n := outer.size()
	# Soft drop shadow: a gradient ring from the offset outline to a grown, transparent one.
	if shadow_size > 0 and shadow_color.a > 0.01:
		var s := float(shadow_size)
		var srect := Rect2(rect.position + shadow_offset, rect.size)
		var s_in := shape(srect, cut, small, slant)
		var s_out := shape(srect.grow(s), cut + s * 0.6, small + s * 0.6, slant)
		var clear := Color(shadow_color.r, shadow_color.g, shadow_color.b, 0.0)
		var c_in := PackedColorArray()
		var c_out := PackedColorArray()
		c_in.resize(n)
		c_out.resize(n)
		c_in.fill(shadow_color)
		c_out.fill(clear)
		_ring(item, s_out, s_in, c_out, c_in)
	var inner_rect := rect.grow_individual(-border_width_left, -border_width_top, -border_width_right, -border_width_bottom)
	var shrink: float = 0.6 * float(border_width_left + border_width_top + border_width_right + border_width_bottom) * 0.25
	var inner := shape(inner_rect, cut - shrink, small - shrink * 0.5, slant * inner_rect.size.y / maxf(1.0, rect.size.y))
	# Fill: lighter at the top, deeper at the bottom.
	if draw_center and bg_color.a > 0.0:
		var top := bg_color.lightened(sheen)
		var bottom := bg_color.darkened(sheen * 2.2)
		RenderingServer.canvas_item_add_polygon(item, inner, _grad(inner, rect, top, bottom))
	# Glow band along the bottom edge.
	if underglow.a > 0.01:
		var gh: float = minf(rect.size.y * 0.55, 26.0)
		var gr := Rect2(inner_rect.position.x, inner_rect.end.y - gh, inner_rect.size.x, gh)
		var gpts := shape(gr, 1.0, 1.0, 0.0)
		var g0 := Color(underglow.r, underglow.g, underglow.b, 0.0)
		RenderingServer.canvas_item_add_polygon(item, gpts, _grad(gpts, gr, g0, underglow))
	# Outer rim (per-side widths) with an anti-aliased contour.
	var bw: int = border_width_left + border_width_top + border_width_right + border_width_bottom
	if bw > 0 and border_color.a > 0.0:
		var rim_top := border_color.lightened(0.12)
		var rim_bottom := border_color.darkened(0.25)
		_ring(item, outer, inner, _grad(outer, rect, rim_top, rim_bottom), _grad(inner, rect, rim_top, rim_bottom))
		var contour := PackedVector2Array(outer)
		contour.append(outer[0])
		RenderingServer.canvas_item_add_polyline(item, contour, _grad(contour, rect, rim_top, rim_bottom), 1.0, true)
	elif draw_center and bg_color.a > 0.0:
		var edge := PackedVector2Array(inner)
		edge.append(inner[0])
		RenderingServer.canvas_item_add_polyline(item, edge, PackedColorArray([bg_color]), 1.0, true)
	# Inner light seam: a thin bright line two pixels inside the rim, strongest at the top.
	if seam > 0.01 and rect.size.y >= 18.0:
		var seam_rect := inner_rect.grow(-2.0)
		var spts := shape(seam_rect, cut - shrink - 1.2, small - shrink * 0.5 - 0.6, slant * seam_rect.size.y / maxf(1.0, rect.size.y))
		spts.append(spts[0])
		var base := border_color.lightened(0.55)
		var c_top := Color(base.r, base.g, base.b, seam)
		var c_bot := Color(base.r, base.g, base.b, seam * 0.18)
		RenderingServer.canvas_item_add_polyline(item, spts, _grad(spts, seam_rect, c_top, c_bot), 1.0, true)
	# Corner brackets just outside the small corners.
	if ornaments and rect.size.x >= 90.0 and rect.size.y >= 48.0:
		var oc := border_color.lightened(0.3)
		oc.a = minf(1.0, border_color.a + 0.15)
		var L: float = clampf(minf(rect.size.x, rect.size.y) * 0.12, 8.0, 18.0)
		var o := 3.0
		var tr := outer[1] + Vector2(0, -o)
		var tr2 := outer[2] + Vector2(o, 0)
		RenderingServer.canvas_item_add_polyline(item, PackedVector2Array([tr + Vector2(-L, 0), tr, tr2, tr2 + Vector2(0, L)]), PackedColorArray([oc]), 2.0, true)
		var bl := outer[5] + Vector2(0, o)
		var bl2 := outer[6] + Vector2(-o, 0)
		RenderingServer.canvas_item_add_polyline(item, PackedVector2Array([bl + Vector2(L, 0), bl, bl2, bl2 + Vector2(0, -L)]), PackedColorArray([oc]), 2.0, true)
		# A short accent stroke parallel to the big top-left cut.
		var a0 := outer[7] + Vector2(-0.0, 0)
		var a1 := outer[0]
		var mid := (a0 + a1) * 0.5
		var dir := (a1 - a0).normalized()
		var nrm := Vector2(dir.y, -dir.x) * 4.0
		var half: float = (a1 - a0).length() * 0.32
		RenderingServer.canvas_item_add_line(item, mid - dir * half + nrm, mid + dir * half + nrm, oc, 2.0, true)

func _test_mask(point: Vector2, rect: Rect2) -> bool:
	return Geometry2D.is_point_in_polygon(point, shape(rect, cut, cut * cut_ratio, slant))
