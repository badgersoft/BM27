extends Control
## Renders every manager portrait plus a sample of musicians to a PNG.
func _ready() -> void:
	var bg := ColorRect.new(); bg.color = UITheme.BG; bg.set_anchors_preset(Control.PRESET_FULL_RECT); add_child(bg)
	var grid := GridContainer.new(); grid.columns = 8; grid.position = Vector2(16, 16)
	grid.add_theme_constant_override("h_separation", 12); grid.add_theme_constant_override("v_separation", 12)
	add_child(grid)
	for m in Data.managers:
		grid.add_child(Portrait.make(m.look, 140))
	var db := Data.build_musicians()
	for i in range(0, 200, 17):
		grid.add_child(Portrait.make(db[i].look, 140))
	var row := HBoxContainer.new(); row.position = Vector2(16, 650); add_child(row)
	for n in Icons.P.keys().slice(0, 40):
		row.add_child(Icons.make(n, 26))
	await get_tree().process_frame
	await get_tree().process_frame
	get_viewport().get_texture().get_image().save_png("res://tests/out_portraits.png")
	get_tree().quit()
