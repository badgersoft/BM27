extends Control
## Renders the gig stage art at several crowd sizes.
func _ready() -> void:
	var bg := ColorRect.new(); bg.color = UITheme.BG; bg.set_anchors_preset(Control.PRESET_FULL_RECT); add_child(bg)
	var y := 0.0
	for spec in [[6, 0.24, 5.0, "#6c757d"], [70, 0.78, 3.5, "#8d5524"], [24600, 0.98, 5.0, "#ffbe0b"]]:
		var r := TextureRect.new()
		r.texture = StageArt.build(spec[3], spec[1], spec[2], 7, spec[0])
		r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		r.stretch_mode = TextureRect.STRETCH_SCALE
		r.position = Vector2(0, y); r.size = Vector2(620, 236)
		add_child(r)
		y += 240
	await get_tree().process_frame
	await get_tree().process_frame
	get_viewport().get_texture().get_image().save_png("res://tests/shots/stage_sheet.png")
	get_tree().quit()
