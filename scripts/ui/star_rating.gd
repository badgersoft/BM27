class_name StarRating
extends Control
## Five stars with half-star support, drawn as vector polygons.

var rating := 3.0:
	set(v):
		rating = v
		queue_redraw()
var star_size := 22.0:
	set(v):
		star_size = v
		custom_minimum_size = Vector2(v * 5.0 + 4.0 * 4.0, v)
var color := UITheme.GOLD


func _ready() -> void:
	custom_minimum_size = Vector2(star_size * 5.0 + 16.0, star_size)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _star(center: Vector2, r: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 10:
		var ang := -PI / 2.0 + i * PI / 5.0
		var rr := r if i % 2 == 0 else r * 0.45
		pts.append(center + Vector2(cos(ang), sin(ang)) * rr)
	return pts


func _draw() -> void:
	var r := star_size * 0.5
	for i in 5:
		var c := Vector2(r + i * (star_size + 4.0), size.y * 0.5 + r * 0.06)
		var pts := _star(c, r)
		draw_colored_polygon(pts, Color(1, 1, 1, 0.1))
		var fill := clampf(rating - i, 0.0, 1.0)
		if fill >= 0.99:
			draw_colored_polygon(pts, color)
		elif fill >= 0.49:
			# Left half: clip the star polygon at the centre line.
			var half := PackedVector2Array()
			for p in pts:
				half.append(Vector2(minf(p.x, c.x), p.y))
			draw_colored_polygon(half, color)
