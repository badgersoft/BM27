class_name StageBackdrop
extends Control
## Static stage-lights-and-crowd backdrop for the menus. Drawn once with
## vector shapes; no per-frame cost (low processor mode keeps it idle).

var beam_colors: Array = [Color(1, 0.24, 0.18, 0.10), Color(1, 0.77, 0.24, 0.08), Color(0.3, 0.8, 0.95, 0.06)]
var crowd := true
var seed_val := 27


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _draw() -> void:
	var w := size.x
	var h := size.y
	draw_rect(Rect2(Vector2.ZERO, size), UITheme.BG)
	# Soft vertical vignette.
	for i in 8:
		var t := float(i) / 8.0
		draw_rect(Rect2(0, h * t, w, h / 8.0 + 1.0), Color(0.08, 0.06, 0.09, 0.35 * (1.0 - t)))
	# Light beams from rigs above.
	var rigs := [0.18, 0.5, 0.82]
	for i in rigs.size():
		var x: float = w * rigs[i]
		var c: Color = beam_colors[i % beam_colors.size()]
		var spread := w * 0.16
		var tilt := (float(i) - 1.0) * w * 0.12
		draw_colored_polygon(PackedVector2Array([Vector2(x - 10, -10), Vector2(x + 10, -10),
			Vector2(x + tilt + spread, h), Vector2(x + tilt - spread, h)]), c)
		draw_circle(Vector2(x, 6), 16, Color(c.r, c.g, c.b, 0.6))
	# Rig truss.
	draw_rect(Rect2(0, 0, w, 10), Color("#1c1c22"))
	for x in range(0, int(w), 28):
		draw_line(Vector2(x, 0), Vector2(x + 14, 10), Color("#2a2a33"), 2.0)
	if not crowd:
		return
	# Crowd silhouettes along the bottom.
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_val
	var base := h - 6.0
	for row in 3:
		var y := base - row * 22.0
		var shade := Color(0.03, 0.03, 0.04, 1.0).lerp(Color(0.09, 0.08, 0.11, 1.0), float(row) / 3.0)
		var x := -10.0 + rng.randf_range(0.0, 20.0)
		while x < w + 20.0:
			var r := rng.randf_range(11.0, 15.0)
			var hy := y - rng.randf_range(18.0, 34.0)
			draw_circle(Vector2(x, hy), r, shade)
			draw_rect(Rect2(x - r * 1.3, hy + r * 0.6, r * 2.6, h - hy), shade)
			if rng.randf() < 0.12:
				# Hands in the air.
				var arm := Vector2(x + rng.randf_range(-6, 6), hy - r - rng.randf_range(16, 30))
				draw_line(Vector2(x + r * 0.8, hy + r * 0.6), arm, shade, 6.0)
				draw_circle(arm, 4.5, shade)
			x += rng.randf_range(22.0, 34.0)
