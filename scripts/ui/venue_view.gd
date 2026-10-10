class_name VenueView
extends RefCounted
## Rows for rehearsal spaces and gig venues.


## Which rehearsal spaces to show: everything you can afford a month of,
## plus the next two as something to aim for.
static func practice_choices() -> Array:
	var out: Array = []
	var locked := 0
	for i in Data.practice.size():
		var month := Game.rent_of(i) * 4.0
		if month <= Game.funds or i <= Game.practice_idx or Game.rent_of(i) == 0.0:
			out.append(i)
		elif locked < 2:
			out.append(i)
			locked += 1
	return out


static func practice_row(idx: int, current: int, on_pick: Callable) -> PanelContainer:
	var v: Dictionary = Data.practice_venue(idx)
	var rent := Game.rent_of(idx)
	var affordable := rent * 4.0 <= Game.funds or idx <= current or rent == 0.0
	var is_cur := idx == current
	var p := UI.panel("CardHi" if is_cur else "Card")
	if not affordable:
		p.modulate = Color(1, 1, 1, 0.5)
	var h := UI.hbox(18)
	var ic := PanelContainer.new()
	ic.add_theme_stylebox_override("panel", UITheme.box(UITheme.PANEL_2, 12, Color(0, 0, 0, 0), 0, 12, 12))
	ic.add_child(Icons.make("venue" if idx >= 5 else "home", 30, UITheme.GOLD if is_cur else UITheme.TEXT))
	ic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	h.add_child(ic)
	var info := UI.vbox(4)
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_child(UI.label(v.name, "Title", null, true))
	info.add_child(UI.label(v.desc, "BodyMuted", null, true))
	h.add_child(info)
	var stats := UI.vbox(6)
	stats.custom_minimum_size.x = 220
	stats.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var tr := UI.hbox(6)
	tr.add_child(UI.label("TRAINING", "Caps"))
	tr.add_child(UI.spacer())
	tr.add_child(UI.label("×%.2f" % float(v.train), "Strong", UITheme.INFO))
	stats.add_child(tr)
	stats.add_child(UI.meter(float(v.train) / 2.6, UITheme.INFO, 6.0))
	var hp := UI.hbox(6)
	hp.add_child(UI.label("COMFORT", "Caps"))
	hp.add_child(UI.spacer())
	var happy := int(v.happy)
	hp.add_child(UI.label(("+%d" % happy) if happy > 0 else str(happy), "Strong", UITheme.GOOD if happy >= 0 else UITheme.BAD))
	stats.add_child(hp)
	h.add_child(stats)
	var right := UI.vbox(6)
	right.custom_minimum_size.x = 150
	right.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var price := UI.label("FREE" if rent == 0.0 else U.money(rent), "Stat", UITheme.GOOD if rent == 0.0 else UITheme.GOLD)
	price.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	right.add_child(price)
	var per := UI.label("per week", "Small")
	per.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	right.add_child(per)
	var b: Button
	if is_cur:
		b = UI.button("CURRENT", "check", "", Callable())
		b.disabled = true
	elif not affordable:
		b = UI.button("Too pricey", "lock", "", Callable())
		b.disabled = true
	else:
		b = UI.button("MOVE IN", "chevR", "Gold", on_pick.bind(idx))
	right.add_child(b)
	h.add_child(right)
	p.add_child(h)
	return p
