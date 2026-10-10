extends Page
## Where the band rehearses.


func build() -> void:
	var cur := Data.practice_venue(Game.practice_idx)
	title("Rehearsal Space", "Currently at %s for %s a week. Better rooms mean faster improvement and happier musicians." % [cur.name, U.money(Game.rent_of(Game.practice_idx))], "venue")
	for idx in VenueView.practice_choices():
		add_child(VenueView.practice_row(idx, Game.practice_idx, _move))


func _move(idx: int) -> void:
	var v := Data.practice_venue(idx)
	main.confirm("Move to %s?" % v.name, "Rent will be [b]%s per week[/b], paid every week." % U.money(Game.rent_of(idx)), "MOVE IN", func():
		if Game.set_practice(idx):
			main.show_toast("Moved into %s." % v.name, "good"), "venue", "Gold")
