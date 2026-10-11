extends Page
## This month's gig offers and the gig history.


func build() -> void:
	var d := U.date(Game.week)
	title("Gigs", "One gig a month, played at the end of week 4. It's %s, week %d." % [d.month, d.week_of_month], "ticket")
	if Game.gig_booked >= 0:
		add_child(_offer_card(Game.gig_booked, true))
	elif Game.gig_skipped:
		var c: Array = UI.card("Sitting this one out", "x", "Card")
		c[1].add_child(UI.label("You've chosen to skip this month. Some fans will drift away.", "Body", null, true))
		add_child(c[0])
	elif Game.gig_offers.is_empty():
		var c2: Array = UI.card("No offers", "info", "Card")
		c2[1].add_child(UI.label("No venues will book you this month. It happens. New offers arrive at the start of next month.", "Body", null, true))
		add_child(c2[0])
	else:
		var grid := GridContainer.new()
		grid.columns = mini(Game.gig_offers.size(), 3) if get_viewport().get_visible_rect().size.x >= 1100 else 1
		grid.add_theme_constant_override("h_separation", 16)
		grid.add_theme_constant_override("v_separation", 16)
		for idx in Game.gig_offers:
			grid.add_child(_offer_card(idx, false))
		add_child(grid)
		var sk := UI.hbox(10)
		sk.add_child(UI.label("Not feeling it? Skipping costs a few fans.", "Small"))
		sk.add_child(UI.button("SKIP THIS MONTH", "x", "Ghost", func():
			main.confirm("Skip this month's gig?", "Fans like to see you play. Skipping a month loses a few of them.", "SKIP", Game.skip_gig_month, "ticket")))
		add_child(sk)
	add_child(_history())


func _offer_card(idx: int, booked: bool) -> Control:
	var v: Dictionary = Data.gig_venue(idx)
	var p := UI.panel("CardHi" if booked else "Card")
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var col := UI.vbox(10)
	p.add_child(col)
	var head := UI.hbox(10)
	var bar := ColorRect.new()
	bar.color = Color(v.colour)
	bar.custom_minimum_size = Vector2(6, 52)
	head.add_child(bar)
	var hv := UI.vbox(0)
	hv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var vc := Game.gig_city_of(idx)
	hv.add_child(UI.label("%s VENUE · %s" % [v.tier.to_upper(), Game.city_name(vc).to_upper()], "Caps", Color(v.colour).lightened(0.2)))
	hv.add_child(UI.label(v.name, "H3", null, true))
	head.add_child(hv)
	col.add_child(head)
	col.add_child(UI.label(v.desc, "BodyMuted", null, true))
	if vc != Game.base_city:
		col.add_child(UI.icon_label("bus", "Away gig: fans from %s will travel if they're keen enough." % Game.city_name(), UITheme.INFO, "Small"))
	var est := Game.estimate_attendance(idx)
	var per := Game.gig_income_per_head(idx)
	var hire := Game.venue_hire(idx)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 18)
	grid.add_theme_constant_override("v_separation", 8)
	grid.add_child(UI.stat("users", "Capacity", U.num(v.cap)))
	grid.add_child(UI.stat("funds", "Hire cost", U.money(hire), UITheme.GOLD))
	grid.add_child(UI.stat("target", "Expected crowd", "%s–%s" % [U.num(est.x), U.num(est.y)]))
	grid.add_child(UI.stat("cash", "Per head", "£%.2f" % per))
	col.add_child(grid)
	var lo := est.x * per - hire
	var hi := est.y * per - hire
	var prof := UI.hbox(8)
	prof.add_child(UI.label("ESTIMATED PROFIT", "Caps"))
	prof.add_child(UI.spacer())
	prof.add_child(UI.label("%s to %s" % [U.signed_money(lo), U.signed_money(hi)], "Strong", UITheme.GOOD if lo >= 0 else (UITheme.GOLD if hi >= 0 else UITheme.BAD)))
	col.add_child(prof)
	var bd := "Ticket £%.2f a head%s" % [float(v.ticket), (" · merch about £%.2f a head" % float(v.merch)) if float(v.merch) > 0 else ""]
	col.add_child(UI.label(bd, "Small", null, true))
	var bar_txt := "You'll also get half the bar takings from the night, usually around £%.2f a head (thirsty crowds spend more)." % (float(v.bar) * 0.5)
	col.add_child(UI.icon_label("cash", bar_txt, UITheme.MUTED, "Small", 16, true))
	if booked:
		col.add_child(UI.icon_label("check", "BOOKED · plays at the end of week 4", UITheme.GOLD, "Caps", 18))
	else:
		var b := UI.button("BOOK IT · %s" % U.money(hire), "ticket", "Gold", func():
			if Game.book_gig(idx):
				main.show_toast("Booked %s!" % v.name, "good"))
		b.disabled = hire > Game.funds
		if b.disabled:
			b.text = "CAN'T AFFORD · %s" % U.money(hire)
		col.add_child(b)
	return p


func _history() -> Control:
	var c: Array = UI.card("Gig history", "calendar", "Card")
	if Game.gig_history.is_empty():
		c[1].add_child(UI.label("No gigs played yet.", "BodyMuted"))
		return c[0]
	var grid := GridContainer.new()
	grid.columns = 6
	grid.add_theme_constant_override("h_separation", 18)
	grid.add_theme_constant_override("v_separation", 8)
	for h in ["DATE", "VENUE", "CROWD", "RATING", "CRITIC", "PROFIT"]:
		grid.add_child(UI.label(h, "Caps"))
	for g in Game.gig_history.slice(0, 12):
		grid.add_child(UI.label(U.date_label(int(g.week)), "Small"))
		var vn := UI.label(g.venue_name, "Body")
		vn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(vn)
		grid.add_child(UI.label("%s / %s" % [U.num(g.attendance), U.num(g.cap)], "Body"))
		grid.add_child(UI.stars(float(g.crowd), 14))
		grid.add_child(UI.stars(float(g.critic), 14, UITheme.INFO))
		grid.add_child(UI.label(U.signed_money(float(g.profit)), "Strong", UITheme.GOOD if float(g.profit) >= 0 else UITheme.BAD))
	c[1].add_child(grid)
	return c[0]
