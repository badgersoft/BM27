extends Screen
## Best careers so far.


func _ready() -> void:
	add_child(UI.full_rect(StageBackdrop.new()))
	var v := page_root(48)
	var top := UI.hbox(16)
	top.add_child(UI.button("BACK", "chevL", "Ghost", func(): go("menu")))
	v.add_child(top)
	v.add_child(header("Hall of Fame", "The greatest bands you've ever managed (and the ones that imploded spectacularly).", "Legends"))
	var list := UI.vbox(10)
	var data: Array = Game.load_hall_of_fame()
	if data.is_empty():
		var c: Array = UI.card("", "", "CardFlat")
		c[1].add_child(UI.icon_label("trophy", "No legends yet. Go and make some history.", UITheme.MUTED, "Body", 22))
		list.add_child(c[0])
	for i in data.size():
		var e: Dictionary = data[i]
		var p := UI.panel("CardHi" if i == 0 else "Card")
		var h := UI.hbox(18)
		var rank := UI.label("#%d" % (i + 1), "StatBig", UITheme.GOLD if i == 0 else UITheme.MUTED)
		rank.custom_minimum_size.x = 70
		h.add_child(rank)
		var info := UI.vbox(2)
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info.add_child(UI.label(str(e.band), "H3"))
		var ending := "Retired legends" if e.ending == "retired" else "Split up"
		info.add_child(UI.label("%s · managed by %s · %s together · %s" % [e.genre, e.manager, U.duration(int(e.weeks)), ending], "BodyMuted", null, true))
		h.add_child(info)
		h.add_child(_mini("star", "Peak fame", str(int(e.peak_fame))))
		h.add_child(_mini("chart", "Best single", "#%d" % int(e.best_nat) if int(e.best_nat) > 0 else "-"))
		h.add_child(_mini("funds", "Earned", U.money(float(e.earned))))
		h.add_child(_mini("trophy", "Legacy", U.num(float(e.score))))
		p.add_child(h)
		list.add_child(p)
	v.add_child(UI.scroller(list))


func _mini(icon: String, cap: String, val: String) -> Control:
	var s := UI.stat(icon, cap, val, UITheme.TEXT)
	s.custom_minimum_size.x = 130
	return s


func on_back() -> void:
	go("menu")
