extends Page
## The band: each member's skills, mood, gear and tenure, plus genre.


func build() -> void:
	title("The Band", "%s · together %s · live rating %d" % [Game.band_name, U.duration(Game.band_age()), int(Game.band_score())], "users")
	var top := UI.hbox(12)
	top.add_child(UI.genre_chip(Game.genre, true))
	top.add_child(UI.label("Current genre", "Small"))
	top.add_child(UI.spacer())
	top.add_child(UI.button("TREAT THE BAND", "gift", "Gold", _band_treat_dialog))
	top.add_child(UI.button("CHANGE GENRE", "swap", "", _genre_dialog))
	add_child(top)
	var grid := GridContainer.new()
	grid.columns = 2 if get_viewport().get_visible_rect().size.x >= 1100 else 1
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 16)
	for role in Game.ROLES:
		grid.add_child(_member_card(role))
	add_child(grid)


func _member_card(role: String) -> Control:
	var m := Game.member(role)
	if m.is_empty():
		var c0: Array = UI.card(InstrumentData.ROLE_NAMES[role], Icons.role_icon(role), "Card", UITheme.BAD)
		c0[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
		c0[1].add_child(UI.label("Vacant! Gigs will suffer badly until you find someone.", "Body", null, true))
		c0[1].add_child(UI.button("FIND A %s" % InstrumentData.ROLE_NAMES[role].to_upper(), "search", "Gold", func():
			hq.open_page("talent")
			TalentPage.role = role
			hq.refresh()))
		return c0[0]
	var p := UI.panel("Card")
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var v := UI.vbox(12)
	p.add_child(v)
	var top := UI.hbox(16)
	top.add_child(Portrait.make(m.look, 104))
	var idv := UI.vbox(4)
	idv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var rr := UI.hbox(6)
	rr.add_child(Icons.make(Icons.role_icon(role), 16, UITheme.ACCENT))
	rr.add_child(UI.label(InstrumentData.ROLE_NAMES[role].to_upper(), "Caps", UITheme.ACCENT))
	if bool(m.original):
		rr.add_child(UI.chip("Original", UITheme.GOLD, false, "star"))
	var tb := MusicianView.tier_badge(m)
	if tb:
		rr.add_child(tb)
	rr.custom_minimum_size.y = 28
	idv.add_child(rr)
	idv.add_child(UI.label(m.name, "H3"))
	var tags := UI.hbox(8)
	tags.add_child(UI.label("Age %d" % int(m.age), "Small"))
	tags.add_child(UI.genre_pair(m))
	tags.add_child(UI.chip(Game.temperament_word(int(m.ease)), UITheme.MUTED))
	idv.add_child(tags)
	idv.add_child(UI.label("In the band %s%s" % [U.duration(Game.tenure(m)), " ★ founder" if bool(m.original) else ""], "Small"))
	top.add_child(idv)
	var val := UI.vbox(-4)
	val.add_child(UI.label("VALUE", "Caps"))
	val.add_child(UI.label(U.money(Game.value_of(m)), "Stat", UITheme.GOLD))
	top.add_child(val)
	v.add_child(top)
	var bars := UI.hbox(20)
	var sb := MusicianView.skill_block(m, 200)
	sb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bars.add_child(sb)
	var hb := MusicianView.happy_block(m, 200)
	hb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bars.add_child(hb)
	v.add_child(bars)
	var fb := MusicianView.fame_block(m, 200)
	fb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var frow := UI.hbox(20)
	frow.add_child(fb)
	var fame_note := UI.label(_fame_note(m), "Small", UITheme.MUTED, true)
	fame_note.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# Always two lines tall, so every card's gear box lines up.
	fame_note.max_lines_visible = 2
	fame_note.custom_minimum_size.y = fame_note.get_line_height() * 2 + 4
	frow.add_child(fame_note)
	v.add_child(frow)
	var bio := UI.label(m.bio, "BodyMuted", null, true)
	bio.add_theme_font_size_override("font_size", 15)
	bio.max_lines_visible = 2
	bio.custom_minimum_size.y = bio.get_line_height() * 2 + 4
	v.add_child(bio)
	var gear := UI.panel("CardFlat")
	var gh := UI.hbox(10)
	gh.add_child(Icons.make(Icons.role_icon(role), 22, UITheme.GOLD))
	var gv := UI.vbox(0)
	gv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var inst := Data.instrument(role, int(m.inst))
	gv.add_child(UI.label("GEAR · TIER %d OF 7 · +%d ON STAGE" % [int(m.inst), Game.inst_bonus(m)], "Caps"))
	gv.add_child(UI.label(inst.name, "Strong"))
	gh.add_child(gv)
	var exp := Data.expected_inst_tier(m.skill)
	if int(m.inst) < exp:
		gh.add_child(UI.chip("Wants better", Color("#ff9f43")))
	var up := UI.button("UPGRADE", "upgrade", "", _upgrade_dialog.bind(role))
	up.disabled = int(m.inst) >= 7
	gh.add_child(up)
	gear.add_child(gh)
	v.add_child(gear)
	var acts := UI.hbox(10)
	acts.add_child(UI.button("TREAT", "gift", "Gold", _treat_dialog.bind(m.id)))
	acts.add_child(UI.spacer())
	acts.add_child(UI.button("SACK", "userX", "Ghost", func():
		var extra := " As an original member, some fans won't like it." if bool(m.original) else ""
		main.confirm("Sack %s?" % m.name, "They'll leave immediately and won't come back. The rest of the band may be unsettled.%s" % extra, "SACK THEM", func(): Game.sack(role), "userX")))
	v.add_child(acts)
	return p


func _upgrade_dialog(role: String) -> void:
	var m := Game.member(role)
	var v := UI.vbox(12)
	v.add_child(UI.label("GEAR SHOP", "Caps", UITheme.ACCENT))
	v.add_child(UI.label("Upgrade %s's %s" % [m.name.get_slice(" ", 0), "kit" if role == "drums" else ("mic" if role == "vocals" else "instrument")], "H2"))
	v.add_child(UI.label("Better gear adds to their on-stage skill and makes them happier. Funds: %s" % U.money(Game.funds), "BodyMuted", null, true))
	var modal: Control
	var list: Array = InstrumentData.TIERS[role]
	for t in range(int(m.inst) + 1, list.size()):
		var it: Dictionary = list[t]
		var price := Game.gear_price(it.cost)
		var row := UI.panel("CardFlat")
		var h := UI.hbox(12)
		var tv := UI.vbox(0)
		tv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tv.add_child(UI.label("TIER %d · +%d ON STAGE" % [t, InstrumentData.BONUS[t]], "Caps", UITheme.GOLD))
		tv.add_child(UI.label(it.name, "Strong"))
		tv.add_child(UI.label(it.desc, "Small", null, true))
		h.add_child(tv)
		var b := UI.button(U.money(price), "funds", "Gold", func():
			if Game.upgrade_instrument(role, t):
				main.show_toast("%s: new %s!" % [m.name.get_slice(" ", 0), it.name], "good")
			main.close_modal(modal))
		b.disabled = price > Game.funds
		b.custom_minimum_size.x = 130
		h.add_child(b)
		row.add_child(h)
		v.add_child(row)
	v.add_child(UI.button("Close", "x", "Ghost", func(): main.close_modal(modal)))
	modal = main.open_modal(v, 640, true)


static func treat_options(main: Control, mid: String, on_pick: Callable) -> VBoxContainer:
	var m: Dictionary = Game.musicians[mid]
	var v := UI.vbox(10)
	v.add_child(UI.label("GIFTS", "Caps"))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	for i in InstrumentData.GIFTS.size():
		var g: Dictionary = InstrumentData.GIFTS[i]
		if float(g.cost) > Game.funds * 4.0 and i > 1:
			continue
		var b := UI.button("%s · %s" % [g.name, U.money(g.cost)], g.icon, "", on_pick.bind({"kind": "gift", "idx": i}))
		b.disabled = float(g.cost) > Game.funds
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.tooltip_text = "+%d contentment" % int(round(Game.gift_boost(m, g.boost)))
		grid.add_child(b)
	v.add_child(grid)
	v.add_child(UI.label("ONE-OFF BONUS", "Caps"))
	var row := UI.hbox(8)
	for opt in Game.bonus_options(m):
		var b2 := UI.button(U.money(opt[0]), "cash", "", on_pick.bind({"kind": "bonus", "amount": opt[0], "boost": opt[1]}))
		b2.disabled = float(opt[0]) > Game.funds
		b2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b2.tooltip_text = "+%d contentment" % int(round(Game.gift_boost(m, opt[1])))
		row.add_child(b2)
	v.add_child(row)
	if float(m.gift_fatigue) > 10.0:
		v.add_child(UI.icon_label("info", "%s is getting used to treats. They're less effective right now." % m.name.get_slice(" ", 0), UITheme.MUTED, "Small"))
	return v


## Treats for everyone at once: a cheap night out or a pricey spa weekend.
func _band_treat_dialog() -> void:
	var v := UI.vbox(14)
	v.add_child(UI.label("TREAT THE BAND", "Caps", UITheme.ACCENT))
	v.add_child(UI.label("Lift everyone's spirits at once", "H2"))
	v.add_child(UI.label("Treats work less well if you overdo them. Funds: %s" % U.money(Game.funds), "BodyMuted", null, true))
	var modal: Control
	for i in InstrumentData.BAND_TREATS.size():
		var t: Dictionary = InstrumentData.BAND_TREATS[i]
		var cost := Game.band_treat_cost(i)
		var row := UI.panel("CardFlat")
		var h := UI.hbox(14)
		h.add_child(Icons.make(t.icon, 30, UITheme.GOLD))
		var tv := UI.vbox(2)
		tv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tv.add_child(UI.label(t.name, "H3"))
		var eff := "+%d contentment each" % int(t.boost)
		eff += " · tiredness gone" if float(t.fatigue) < 0.0 else " · a bit hungover"
		tv.add_child(UI.label(eff, "Caps", UITheme.GOOD))
		tv.add_child(UI.label(t.desc, "Small", null, true))
		h.add_child(tv)
		var b := UI.button(U.money(cost), "funds", "Gold", func():
			var txt := Game.treat_band(i)
			main.close_modal(modal)
			if txt != "":
				main.show_toast(txt, "good", 6.0))
		b.disabled = cost > Game.funds
		b.custom_minimum_size.x = 130
		b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		h.add_child(b)
		row.add_child(h)
		v.add_child(row)
	v.add_child(UI.button("Close", "x", "Ghost", func(): main.close_modal(modal)))
	modal = main.open_modal(v, 680, true)


func _treat_dialog(mid: String) -> void:
	var m: Dictionary = Game.musicians[mid]
	var v := UI.vbox(14)
	var h := UI.hbox(14)
	h.add_child(Portrait.make(m.look, 80))
	var iv := UI.vbox(4)
	iv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	iv.add_child(UI.label("Treat %s" % m.name, "H3"))
	iv.add_child(MusicianView.happy_block(m, 260))
	h.add_child(iv)
	v.add_child(h)
	var modal: Control
	v.add_child(treat_options(main, mid, func(choice: Dictionary):
		var txt := ""
		if choice.kind == "gift":
			txt = Game.give_gift(mid, int(choice.idx))
		else:
			txt = Game.give_bonus(mid, float(choice.amount), float(choice.boost))
		if txt != "":
			main.show_toast(txt, "good", 5.0)
		main.close_modal(modal)))
	v.add_child(UI.button("Close", "x", "Ghost", func(): main.close_modal(modal)))
	modal = main.open_modal(v, 660, true)


func _genre_dialog() -> void:
	var v := UI.vbox(14)
	v.add_child(UI.label("NEW DIRECTION?", "Caps", UITheme.ACCENT))
	v.add_child(UI.label("Change Genre", "H2"))
	v.add_child(UI.label("Switching sound loses the people who don't like the new genre, though loyal fans may stick around. People who love the new sound will warm to you, and so will band members who love it. Estimates below.", "BodyMuted", null, true))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	var modal: Control
	for g in Data.genres:
		if g.id == Game.genre:
			continue
		var cost := Game.genre_change_cost(g.id)
		var fans_lost := float(cost.fans)
		var lis_lost := float(cost.listeners)
		var b := UI.button("%s  ·  −%s fans, −%s listeners" % [g.name, U.num(fans_lost), U.num(lis_lost)], "note", "", func():
			main.close_modal(modal)
			main.confirm("Go %s?" % g.name, "You'll lose about [b]%s fans[/b] and [b]%s listeners[/b]." % [U.num(fans_lost), U.num(lis_lost)], "CHANGE GENRE", func(): Game.change_genre(g.id), "swap"))
		b.add_theme_color_override("icon_normal_color", Color(g.color))
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(b)
	v.add_child(grid)
	v.add_child(UI.button("Keep it as it is", "x", "Ghost", func(): main.close_modal(modal)))
	modal = main.open_modal(v, 820, true)


static func _fame_note(m: Dictionary) -> String:
	var f := float(m.get("fame", 0.0))
	if f >= 55.0:
		return "Famous enough to cause trouble, or do some good."
	if m.role == "vocals":
		return "Singers catch the most spotlight."
	return "Rises with the band's fame."
