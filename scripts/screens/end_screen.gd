extends Screen
## Retirement or break-up: the legacy screen.


func _ready() -> void:
	var bd := StageBackdrop.new()
	if Game.end_reason != "retired":
		bd.beam_colors = [Color(0.4, 0.4, 0.5, 0.06), Color(0.3, 0.3, 0.4, 0.05), Color(0.5, 0.2, 0.2, 0.05)]
	add_child(UI.full_rect(bd))
	var v := page_root(56)
	var retired := Game.end_reason == "retired"
	v.add_child(header(Game.band_name, ("Retired legends after %s together. Take a bow." if retired else "Split up after %s together. It was fun while it lasted.") % U.duration(Game.band_age()), "The end · " + ("Final Tour complete" if retired else "Band split"), 72))
	var body := UI.vbox(18)
	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 16)
	var best_venue := int(Game.stats.best_venue)
	var items := [
		["trophy", "Legacy score", U.num(Game.legacy_score()), UITheme.GOLD],
		["star", "Peak fame", "%d · %s" % [int(Game.stats.peak_fame), Game.fame_label(float(Game.stats.peak_fame))], UITheme.GOLD],
		["funds", "Total earned", U.money(float(Game.stats.earned)), UITheme.GOLD],
		["hourglass", "Together", U.duration(Game.band_age()), UITheme.TEXT],
		["ticket", "Gigs played", str(int(Game.stats.gigs)), UITheme.TEXT],
		["users", "Total crowds", U.num(int(Game.stats.total_attendance)), UITheme.TEXT],
		["venue", "Biggest venue", Data.gig_venue(best_venue).name if best_venue >= 0 else "—", UITheme.TEXT],
		["chart", "Best single", "#%d" % int(Game.stats.best_nat) if int(Game.stats.best_nat) > 0 else "—", UITheme.TEXT],
		["disc", "Albums", str(int(Game.flags.albums)), UITheme.TEXT],
		["heart", "Fans", U.num(Game.true_fans), UITheme.ACCENT],
		["headphones", "Listeners", U.num(Game.listeners), UITheme.INFO],
		["mic", "Interviews", str(int(Game.stats.interviews)), UITheme.TEXT],
	]
	for it in items:
		var p := UI.panel("Card")
		p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		p.add_child(UI.stat(it[0], it[1], it[2], it[3]))
		grid.add_child(p)
	body.add_child(grid)
	var lc: Array = UI.card("The final line-up", "users", "Card", UITheme.GOLD)
	var row := UI.hbox(20)
	for m in Game.members():
		var mv := UI.vbox(6)
		mv.add_child(Portrait.make(m.look, 96))
		mv.add_child(UI.label(m.name + (" ★" if bool(m.original) else ""), "Strong", null, true))
		mv.add_child(UI.label(InstrumentData.ROLE_NAMES[m.role], "Small"))
		mv.custom_minimum_size.x = 150
		row.add_child(mv)
	lc[1].add_child(row)
	body.add_child(lc[0])
	var btns := UI.hbox(12)
	btns.add_child(UI.button("HALL OF FAME", "trophy", "Gold", func(): go("hall")))
	btns.add_child(UI.button("MAIN MENU", "home", "", func():
		Game.active = false
		go("menu")))
	body.add_child(btns)
	v.add_child(UI.scroller(body))


func on_back() -> void:
	Game.active = false
	go("menu")
