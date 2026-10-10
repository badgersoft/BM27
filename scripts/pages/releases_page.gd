extends Page
## The archive: every single and album you've released, for posterity.


func build() -> void:
	var total := 0.0
	var sales := 0
	for r in Game.releases:
		total += float(r.revenue)
		sales += int(r.total_sales)
	title("Release Archive", "%d %s · %s copies sold · %s earned" % [Game.releases.size(), U.plural(Game.releases.size(), "release"), U.num(sales), U.money(total)], "disc")
	if Game.releases.is_empty():
		var c: Array = UI.card("", "", "CardFlat")
		c[1].add_child(UI.icon_label("vinyl", "Nothing released yet. Once you're getting noticed, record producers will come calling.", UITheme.MUTED, "Body", 22))
		add_child(c[0])
		return
	for r in Game.releases:
		add_child(_release_card(r))


func _release_card(r: Dictionary) -> Control:
	var album: bool = r.kind == "album"
	var p := UI.panel("Card")
	var h := UI.hbox(18)
	h.add_child(_sleeve(r))
	var v := UI.vbox(4)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var tr := UI.hbox(8)
	tr.add_child(UI.chip("Album" if album else "Single", UITheme.GOLD if album else UITheme.INFO, album))
	if r.status == "charting":
		tr.add_child(UI.chip("In the charts", UITheme.GOOD))
	tr.add_child(UI.genre_chip(r.get("genre", Game.genre)))
	v.add_child(tr)
	v.add_child(UI.label(r.title, "H3", null, true))
	v.add_child(UI.label("Released %s · %s %s" % [U.date_label(int(r.week)), "on" if album else "produced by", r.producer], "Small", null, true))
	var it := UI.hbox(8)
	it.add_child(Icons.make("bolt", 16, UITheme.GOLD))
	it.add_child(UI.label("THE IT FACTOR", "Caps"))
	it.add_child(UI.stars(clampf((float(r.it) - 0.5) / 1.2 * 5.0, 0.5, 5.0), 14))
	v.add_child(it)
	h.add_child(v)
	var grid := GridContainer.new()
	grid.columns = 2 if album else 3
	grid.add_theme_constant_override("h_separation", 22)
	grid.add_theme_constant_override("v_separation", 6)
	grid.add_child(UI.stat("trophy", "Peak (national)", "#%d" % int(r.peak_nat) if int(r.peak_nat) > 0 else "—", UITheme.GOLD))
	if not album:
		grid.add_child(UI.stat("home", "Peak (local)", "#%d" % int(r.peak_local) if int(r.peak_local) > 0 else "—"))
	grid.add_child(UI.stat("calendar", "Weeks charted", str(int(r.weeks_on))))
	grid.add_child(UI.stat("vinyl", "Copies sold", U.num(int(r.total_sales))))
	grid.add_child(UI.stat("funds", "Earned", U.money(float(r.revenue)), UITheme.GOLD))
	h.add_child(grid)
	p.add_child(h)
	return p


## A little record sleeve drawn from the title's hash.
func _sleeve(r: Dictionary) -> Control:
	var hsh := absi(hash(r.title))
	var base := Data.genre_color(r.get("genre", Game.genre))
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", UITheme.box(base.darkened(0.45 + (hsh % 30) / 100.0), 8, Color(0, 0, 0, 0), 0, 10, 10))
	p.custom_minimum_size = Vector2(88, 88)
	var ic := Icons.make("disc" if r.kind == "album" else "vinyl", 56, base.lightened(0.2))
	p.add_child(ic)
	p.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return p
