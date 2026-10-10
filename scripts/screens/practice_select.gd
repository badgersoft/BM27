extends Screen
## Step 2: pick a rehearsal space.


func _ready() -> void:
	var v := page_root(36)
	var top := UI.hbox(16)
	top.add_child(UI.button("BACK", "chevL", "Ghost", func(): go("managers")))
	top.add_child(UI.spacer())
	top.add_child(preload("res://scripts/screens/manager_select.gd")._steps(1))
	v.add_child(top)
	var hr := UI.hbox(20)
	var hd := header("Somewhere To Rehearse", "Rent is paid weekly. Better rooms train the band faster and keep them happier. You can move any time.", "Step 2 of 4 · Rehearsal space")
	hd.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hr.add_child(hd)
	hr.add_child(funds_pill())
	v.add_child(hr)
	var list := UI.vbox(10)
	for idx in VenueView.practice_choices():
		list.add_child(VenueView.practice_row(idx, -1, _pick))
	v.add_child(UI.scroller(list))


func _pick(idx: int) -> void:
	Game.practice_idx = idx
	go("recruit")


func on_back() -> void:
	go("managers")
