extends Control
## Renders the gig stage art for each venue style (hall, pub, theatre,
## arena, festival, stadium) in a grid.
func _ready() -> void:
	var bg := ColorRect.new(); bg.color = UITheme.BG; bg.set_anchors_preset(Control.PRESET_FULL_RECT); add_child(bg)
	# [venue index, attendance, fill, rating]
	var specs := [[0, 13, 0.52, 3.5], [3, 120, 0.8, 4.0], [7, 950, 0.79, 5.0], [10, 9000, 0.9, 4.5], [13, 60000, 0.92, 5.0], [14, 90000, 0.9, 5.0]]
	for i in specs.size():
		var sp: Array = specs[i]
		var art := StageArt.new()
		art.style = StageArt.style_for(sp[0])
		art.tex = StageArt.build(VenueData.GIGS[sp[0]].colour, sp[2], sp[3], 7 + i, sp[1], sp[0])
		art.neon = Color(VenueData.GIGS[sp[0]].colour).lightened(0.45)
		art.band = "The Wet Biscuits"
		art.position = Vector2((i % 2) * 640, (i / 2) * 250)
		art.size = Vector2(630, 630 * StageArt.H / StageArt.W)
		add_child(art)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tests/shots"))
	get_viewport().get_texture().get_image().save_png("res://tests/shots/stage_sheet.png")
	get_tree().quit()
