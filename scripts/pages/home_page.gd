extends Page
## HQ home: this week's focus, the month's gig, the weekly report, the band
## at a glance and your chart positions.


func build() -> void:
	var cols := columns(1.55)
	var left: VBoxContainer = cols[0]
	var right: VBoxContainer = cols[1]
	left.add_child(_focus_card())
	left.add_child(_gig_card())
	left.add_child(_report_card())
	right.add_child(_roster_card())
	right.add_child(_charts_card())
	right.add_child(_tour_card())
	right.add_child(_band_stats_card())


func _focus_card() -> Control:
	var c: Array = UI.card("This week's focus", "target", "Card", UITheme.GOLD)
	var grid := GridContainer.new()
	grid.columns = 5 if get_viewport().get_visible_rect().size.x >= 1100 else 3
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	for key in WeekSim.FOCUS_ORDER:
		var f: Dictionary = WeekSim.FOCUS[key]
		var on: bool = Game.focus == key
		var b := Button.new()
		b.theme_type_variation = "SegOn" if on else "Seg"
		b.custom_minimum_size = Vector2(110, 86)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		b.tooltip_text = f.desc
		b.pressed.connect(Game.set_focus.bind(key))
		var v := UI.vbox(4)
		v.alignment = BoxContainer.ALIGNMENT_CENTER
		v.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var ic := Icons.make(f.icon, 30, Color("#140808") if on else UITheme.TEXT)
		ic.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		v.add_child(ic)
		var l := UI.label(f.name.to_upper(), "Caps", Color("#140808") if on else UITheme.TEXT)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(l)
		b.add_child(UI.full_rect(v))
		grid.add_child(b)
	c[1].add_child(grid)
	var f2: Dictionary = WeekSim.FOCUS[Game.focus]
	var hint: String = f2.desc
	match Game.focus:
		"promote": hint += "  This week: %s." % U.money(Game.promote_cost())
		"rehearse": hint += "  Training at %s (×%.2f)." % [Data.practice_venue(Game.practice_idx).name, float(Data.practice_venue(Game.practice_idx).train)]
		"write": hint += "  Song bank: %d / 100." % int(Game.songcraft)
	c[1].add_child(UI.label(hint, "BodyMuted", null, true))
	var fat := float(Game.flags.get("fatigue", 0.0))
	if fat >= 6.0:
		c[1].add_child(UI.icon_label("alert", "The band are getting worn out. A Chill Out week would do them good.", Color("#ff9f43"), "Small"))
	return c[0]


func _gig_card() -> Control:
	var d := U.date(Game.week)
	var weeks_left: int = 4 - d.week_of_month
	var c: Array = UI.card("Gig this month", "ticket", "Card", UITheme.GOLD)
	var v: VBoxContainer = c[1]
	if Game.gig_booked >= 0:
		var g := Data.gig_venue(Game.gig_booked)
		var h := UI.hbox(14)
		var bar := ColorRect.new()
		bar.color = Color(g.colour)
		bar.custom_minimum_size = Vector2(6, 56)
		h.add_child(bar)
		var iv := UI.vbox(2)
		iv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		iv.add_child(UI.label(g.name, "H3"))
		iv.add_child(UI.label("Capacity %s · Booked · Gig night %s" % [U.num(g.cap), "at the end of this week" if weeks_left == 0 else "in %d %s" % [weeks_left + 0, U.plural(weeks_left, "week")]], "BodyMuted", null, true))
		h.add_child(iv)
		var est := Game.estimate_attendance(Game.gig_booked)
		h.add_child(UI.stat("users", "Expected", "%s–%s" % [U.num(est.x), U.num(est.y)]))
		v.add_child(h)
	elif Game.gig_skipped:
		v.add_child(UI.icon_label("x", "You're sitting this month out. Fans will notice.", UITheme.MUTED, "Body", 20))
	elif Game.gig_offers.is_empty():
		v.add_child(UI.icon_label("info", "No venues are willing to book you this month. Try again next month.", UITheme.MUTED, "Body", 20))
	else:
		var h2 := UI.hbox(14)
		var t := UI.label("%d %s offering you a slot. Book before the end of week 4." % [Game.gig_offers.size(), "venue is" if Game.gig_offers.size() == 1 else "venues are"], "Body", null, true)
		t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h2.add_child(t)
		h2.add_child(UI.button("VIEW OFFERS", "ticket", "Gold", hq.open_page.bind("gigs")))
		v.add_child(h2)
		var names := UI.hbox(8)
		for idx in Game.gig_offers:
			names.add_child(UI.chip(Data.gig_venue(idx).name, Color(Data.gig_venue(idx).colour)))
		v.add_child(names)
	if not Game.gig_history.is_empty():
		var last: Dictionary = Game.gig_history[0]
		var lh := UI.hbox(10)
		lh.add_child(UI.label("LAST GIG", "Caps"))
		lh.add_child(UI.label("%s · %s people" % [last.venue_name, U.num(last.attendance)], "Small"))
		lh.add_child(UI.stars(float(last.crowd), 15))
		v.add_child(lh)
	return c[0]


func _report_card() -> Control:
	var c: Array = UI.card("Weekly update", "mail", "Card", UITheme.GOLD)
	var r: Dictionary = Game.report
	if r.is_empty():
		c[1].add_child(UI.label("Your first weekly update will land here after you press NEXT WEEK.", "BodyMuted", null, true))
		return c[0]
	var deltas := UI.hbox(24)
	deltas.add_child(_delta("funds", "Funds", float(r.funds1) - float(r.funds0), true))
	deltas.add_child(_delta("heart", "True fans", float(r.fans1) - float(r.fans0)))
	deltas.add_child(_delta("headphones", "Listeners", float(r.listeners1) - float(r.listeners0)))
	deltas.add_child(_delta("star", "Fame", float(r.fame1) - float(r.fame0)))
	c[1].add_child(deltas)
	c[1].add_child(UI.sep())
	var lines: Array = r.get("lines", [])
	if lines.is_empty():
		c[1].add_child(UI.label("A quiet week.", "BodyMuted"))
	for ln in lines:
		var h := UI.hbox(10)
		var dot := Icons.make("dot", 10, UI.kind_color(ln.kind))
		dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		h.add_child(dot)
		var l := UI.label(ln.text, "Body", null, true)
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(l)
		c[1].add_child(h)
	var gains: Dictionary = r.get("skill_gains", {})
	var best := ""
	var best_g := 0.0
	for id in gains:
		if float(gains[id]) > best_g and Game.musicians.has(id):
			best_g = float(gains[id])
			best = Game.musicians[id].name
	if best != "" and best_g >= 0.05:
		c[1].add_child(UI.icon_label("trendUp", "Most improved: %s (+%.1f skill)" % [best, best_g], UITheme.GOOD, "Small"))
	return c[0]


func _delta(icon: String, cap: String, d: float, money: bool = false) -> Control:
	var col := UITheme.GOOD if d > 0.5 else (UITheme.BAD if d < -0.5 else UITheme.MUTED)
	var txt: String
	if money:
		txt = U.signed_money(d)
	elif cap == "Fame":
		txt = ("+%.1f" % d) if d >= 0.05 else ("%.1f" % d if d <= -0.05 else "±0")
	else:
		txt = U.signed_num(d)
	return UI.stat(icon, cap, txt, col)


func _roster_card() -> Control:
	var c: Array = UI.card("The band", "users", "Card", UITheme.GOLD)
	for role in Game.ROLES:
		var m := Game.member(role)
		var h := UI.hbox(12)
		if m.is_empty():
			var ph := PanelContainer.new()
			ph.add_theme_stylebox_override("panel", UITheme.box(UITheme.BG_2, 10, UITheme.BAD, 1, 8, 8))
			ph.add_child(Icons.make(Icons.role_icon(role), 28, UITheme.BAD))
			h.add_child(ph)
			var v := UI.vbox(0)
			v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			v.add_child(UI.label("NO %s!" % InstrumentData.ROLE_NAMES[role].to_upper(), "Caps", UITheme.BAD))
			v.add_child(UI.label("Hire one on the Talent page", "Small"))
			h.add_child(v)
			h.add_child(UI.button("HIRE", "search", "Gold", hq.open_page.bind("talent")))
		else:
			h.add_child(Portrait.make(m.look, 52))
			var v2 := UI.vbox(2)
			v2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var nr := UI.hbox(6)
			nr.add_child(Icons.make(Icons.role_icon(role), 14, UITheme.MUTED))
			var nm := UI.label(m.name + (" ★" if bool(m.original) else ""), "Strong")
			nm.clip_text = true
			nm.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			nr.add_child(nm)
			v2.add_child(nr)
			v2.add_child(MusicianView.happy_block(m, 160))
			h.add_child(v2)
			var sk := UI.vbox(-4)
			sk.add_child(UI.label("SKILL", "Caps"))
			sk.add_child(UI.label(str(int(m.skill)), "Stat", UITheme.INFO))
			h.add_child(sk)
		c[1].add_child(h)
	var b := UI.button("MANAGE BAND", "users", "", hq.open_page.bind("band"))
	c[1].add_child(b)
	return c[0]


func _charts_card() -> Control:
	var c: Array = UI.card("Charts", "chart", "Card", UITheme.GOLD)
	var shown := 0
	for rel in Game.releases:
		var visible: bool = rel.status == "charting" or (rel.status == "out" and Game.week - int(rel.out_week) <= 1)
		if not visible:
			continue
		shown += 1
		var h := UI.hbox(10)
		h.add_child(Icons.make("disc" if rel.kind == "album" else "vinyl", 22, UITheme.GOLD))
		var v := UI.vbox(0)
		v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		v.add_child(UI.label("'%s'" % rel.title, "Strong", null, true))
		var sub := "Album chart" if rel.kind == "album" else "Single"
		if int(rel.local_pos) > 0 and int(rel.nat_pos) > 0:
			sub += " · Local #%d" % int(rel.local_pos)
		elif int(rel.local_pos) > 0:
			sub += " · Local chart only"
		if rel.status == "out":
			sub += " · Dropped out"
		v.add_child(UI.label(sub, "Small"))
		h.add_child(v)
		var local_only := int(rel.nat_pos) == 0 and int(rel.local_pos) > 0
		var cur := int(rel.local_pos) if local_only else int(rel.nat_pos)
		var last := int(rel.last_local) if local_only else int(rel.last_nat)
		h.add_child(movement(cur, last))
		var pos_txt := "—"
		if local_only:
			pos_txt = "L#%d" % cur
		elif cur > 0:
			pos_txt = "#%d" % cur
		var pos := UI.label(pos_txt, "Stat", UITheme.TEXT if cur > 0 else UITheme.DIM)
		pos.custom_minimum_size.x = 56
		pos.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		h.add_child(pos)
		c[1].add_child(h)
	if shown == 0:
		c[1].add_child(UI.label("Nothing of yours in the charts. Get famous enough and a producer will call.", "BodyMuted", null, true))
	var locals := Charts.local_rival_entries(3)
	if not locals.is_empty():
		c[1].add_child(UI.sep())
		c[1].add_child(UI.label("LOCAL COMPETITION", "Caps"))
		for e in locals:
			var h2 := UI.hbox(10)
			var pl := UI.label("#%d" % int(e.pos), "Strong", UITheme.MUTED)
			pl.custom_minimum_size.x = 36
			h2.add_child(pl)
			var t := UI.label("%s  ·  %s" % [e.title, e.artist], "Small", UITheme.TEXT, true)
			t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			h2.add_child(t)
			h2.add_child(movement(int(e.pos), int(e.last)))
			c[1].add_child(h2)
	return c[0]


func _tour_card() -> Control:
	if Game.is_final_tour():
		var c: Array = UI.card("The Final Tour", "flag", "CardHi", UITheme.GOLD)
		c[1].add_child(UI.label("%d weeks to go" % Game.final_tour_weeks_left(), "H3", UITheme.GOLD))
		c[1].add_child(UI.label("Every casual fan wants one last look. Book the biggest venues you can.", "BodyMuted", null, true))
		c[1].add_child(UI.meter(1.0 - Game.final_tour_weeks_left() / float(Game.FINAL_TOUR_LENGTH), UITheme.GOLD, 8.0))
		return c[0]
	if not Game.can_start_final_tour():
		var spacer := Control.new()
		spacer.visible = false
		return spacer
	var c2: Array = UI.card("The Final Tour", "flag", "Card", UITheme.GOLD)
	c2[1].add_child(UI.label("You've been together long enough to go out on a high. Announce a six-month farewell tour: huge crowds, huge merch, then retirement.", "Body", null, true))
	c2[1].add_child(UI.button("ANNOUNCE FINAL TOUR", "flag", "Gold", func():
		main.confirm("Announce the Final Tour?", "Six months of farewell gigs with bigger crowds and merch sales, then the band retires and your career ends. There's no going back.", "ANNOUNCE IT", Game.start_final_tour, "flag")))
	return c2[0]


func _band_stats_card() -> Control:
	var c: Array = UI.card("Band stats", "amp", "Card", UITheme.GOLD)
	var score := Game.band_score()
	c[1].add_child(_bar_row("Live rating", score, 130.0, UITheme.ACCENT, str(int(score))))
	c[1].add_child(_bar_row("Song bank", Game.songcraft, 100.0, UITheme.INFO, str(int(Game.songcraft))))
	var fat := float(Game.flags.get("fatigue", 0.0))
	c[1].add_child(_bar_row("Fatigue", fat, 10.0, Color("#ff9f43"), "%d/10" % int(fat)))
	c[1].add_child(_bar_row("Scene trend", Game.trend(), 1.3, UITheme.GOOD, "×%.2f" % Game.trend()))
	return c[0]


func _bar_row(cap: String, val: float, mx: float, col: Color, txt: String) -> Control:
	var v := UI.vbox(4)
	var h := UI.hbox(6)
	h.add_child(UI.label(cap.to_upper(), "Caps"))
	h.add_child(UI.spacer())
	h.add_child(UI.label(txt, "Strong", col))
	v.add_child(h)
	v.add_child(UI.meter(val / mx, col, 6.0))
	return v
