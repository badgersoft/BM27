class_name Meter
extends Control
## A slim rounded bar (0..1) with an optional marker (e.g. potential)
## or marker range (potential estimate).

var value := 0.5:
	set(v):
		value = clampf(v, 0.0, 1.0)
		queue_redraw()
var color := UITheme.ACCENT
var track := Color(1, 1, 1, 0.08)
var marker := -1.0
var marker_hi := -1.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	var rad := minf(size.y * 0.5, 6.0)
	draw_style_box(_rounded(track, rad), r)
	if marker >= 0.0 and marker_hi > marker:
		var a := Rect2(Vector2(size.x * marker, 0), Vector2(size.x * (marker_hi - marker), size.y))
		draw_style_box(_rounded(Color(color.r, color.g, color.b, 0.22), rad), a)
	if value > 0.0:
		draw_style_box(_rounded(color, rad), Rect2(Vector2.ZERO, Vector2(maxf(size.y, size.x * value), size.y)))
	if marker >= 0.0 and marker_hi <= marker:
		var x := size.x * marker
		draw_rect(Rect2(Vector2(x - 1.5, -2), Vector2(3, size.y + 4)), UITheme.TEXT)


func _rounded(c: Color, rad: float) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = c
	s.set_corner_radius_all(int(rad))
	s.anti_aliasing = true
	return s
