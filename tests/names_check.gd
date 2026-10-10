extends Node
## Prints a batch of generated band names per genre (sanity check).
func _ready() -> void:
	for g in Data.genres:
		print(g.name, ": ", Data.band_name_options(g.id), " | ", Data.song_title_options(g.id, []))
	get_tree().quit()
