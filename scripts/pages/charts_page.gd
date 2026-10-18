extends Page
## The three charts, plus the record books for weeks at No.1.

static var tab := "nat"


func build() -> void:
	title("The Charts", "Ranked on this week's sales. Your releases are highlighted in gold, local bands are tagged.", "chart")
	var tabs := UI.hbox(6)
	for t in [["nat", "NATIONAL TOP %d" % Charts.NAT_SIZE, "chart"], ["local", "LOCAL TOP %d" % Charts.LOCAL_SIZE, "home"],
			["album", "ALBUM TOP %d" % Charts.ALBUM_SIZE, "disc"], ["records", "RECORDS", "trophy"]]:
		tabs.add_child(UI.button(t[1], t[2], "SegOn" if tab == t[0] else "Seg", func():
			tab = t[0]
			hq.refresh()))
	add_child(tabs)
	if tab == "records":
		_records()
		return
	var chart: Array
	var size := Charts.NAT_SIZE
	match tab:
		"local":
			chart = Game.chart_local
			size = Charts.LOCAL_SIZE
		"album":
			chart = Game.chart_album
			size = Charts.ALBUM_SIZE
		_:
			chart = Game.chart_nat
	var c: Array = UI.card("", "", "Card")
	var list: VBoxContainer = c[1]
	list.add_theme_constant_override("separation", 2)
	for e in chart.slice(0, size):
		list.add_child(_row(e))
	add_child(c[0])


func _row(e: Dictionary) -> Control:
	var mine := bool(e.player)
	var p := PanelContainer.new()
	var bg := Color(1, 0.77, 0.24, 0.12) if mine else Color(0, 0, 0, 0)
	p.add_theme_stylebox_override("panel", UITheme.box(bg, 8, Color(0, 0, 0, 0), 0, 10, 6))
	var h := UI.hbox(14)
	var pos := UI.label(str(int(e.pos)), "Stat", UITheme.GOLD if mine else UITheme.TEXT)
	pos.custom_minimum_size.x = 44
	pos.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	h.add_child(pos)
	var mv := movement(int(e.pos), int(e.last) if int(e.age) > 0 else 0)
	mv.custom_minimum_size.x = 44
	h.add_child(mv)
	var t := UI.label(e.title, "Strong", UITheme.GOLD if mine else UITheme.TEXT)
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	t.clip_text = true
	t.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	h.add_child(t)
	var a := UI.label(e.artist, "Body", UITheme.GOLD if mine else UITheme.MUTED)
	a.custom_minimum_size.x = 260
	a.clip_text = true
	a.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	h.add_child(a)
	if bool(e.local) and not mine and tab != "local":
		h.add_child(UI.chip("Local", UITheme.INFO))
	if tab != "local":
		# A fixed slot, so the artist column lines up whether or not there's a badge.
		var slot := UI.hbox(0)
		slot.custom_minimum_size.x = 150
		slot.alignment = BoxContainer.ALIGNMENT_END
		if int(e.get("wk1", 0)) > 0:
			var n1 := UI.chip("%dw at No.1" % int(e.wk1), UITheme.GOLD, false, "crown")
			n1.tooltip_text = "Weeks at number one"
			slot.add_child(n1)
		h.add_child(slot)
	# This week's sales: the chart is ranked on them.
	var sold := float(Charts.weekly_sales(int(e.pos), tab == "album", tab == "local"))
	if mine:
		for r in Game.releases:
			if r.id == e.rel:
				sold = float(r.sales)
	var sl := UI.label(U.num(sold), "Small", UITheme.GOLD if mine else UITheme.MUTED)
	sl.custom_minimum_size.x = 64
	sl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	sl.tooltip_text = "Copies sold this week"
	h.add_child(sl)
	var wk := UI.label("%dw" % (int(e.age) + 1), "Small")
	wk.custom_minimum_size.x = 36
	h.add_child(wk)
	p.add_child(h)
	return p


# ---------------------------------------------------------------- records

func _records() -> void:
	var cols := columns(1.0)
	cols[0].add_child(_record_card("Singles: most weeks at No.1", "chart", Charts.records("single")))
	cols[1].add_child(_record_card("Albums: most weeks at No.1", "disc", Charts.records("album")))


func _record_card(heading: String, icon: String, recs: Array) -> Control:
	var c: Array = UI.card(heading, icon, "Card", UITheme.GOLD)
	if recs.is_empty():
		c[1].add_child(UI.label("No number ones yet. Give it a week.", "BodyMuted"))
		return c[0]
	for i in recs.size():
		var r: Dictionary = recs[i]
		var mine := bool(r.get("player", false))
		var h := UI.hbox(12)
		var n := UI.label(str(i + 1), "Strong", UITheme.GOLD if i < 3 else UITheme.MUTED)
		n.custom_minimum_size.x = 26
		h.add_child(n)
		var v := UI.vbox(0)
		v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var t := UI.label(r.title, "Strong", UITheme.GOLD if mine else UITheme.TEXT)
		t.clip_text = true
		t.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		v.add_child(t)
		v.add_child(UI.label("%s · %s" % [r.artist, U.date_label(int(r.first))], "Small", UITheme.GOLD if mine else UITheme.MUTED))
		h.add_child(v)
		h.add_child(UI.label("%d %s" % [int(r.weeks), U.plural(int(r.weeks), "week")], "Strong", UITheme.GOLD))
		c[1].add_child(h)
	return c[0]
