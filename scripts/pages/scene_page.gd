extends Page
## The music scene: genre trends, your direct competition, the megastars.


func build() -> void:
	title("The Scene", "What's hot, who you're up against, and the giants you're chasing.", "flame")
	var cols := columns(1.0)
	cols[0].add_child(_rivals_card())
	cols[0].add_child(_megastars_card())
	cols[1].add_child(_trends_card())


func _rivals_card() -> Control:
	var f := Game.fame()
	var c: Array = UI.card("Your competition · %s" % Data.genre_name(Game.genre), "target", "Card", UITheme.GOLD)
	c[1].add_child(UI.label("Bands in your genre at a similar level. They compete for the same crowds and can clash with your gigs.", "BodyMuted", null, true))
	var list: Array = Game.rivals.filter(func(r): return r.genre == Game.genre and absf(float(r.fame) - f) <= 15.0)
	list.sort_custom(func(a, b): return float(a.fame) > float(b.fame))
	var you := {"name": Game.band_name + " (you)", "fame": f, "local": f < 40.0, "you": true}
	list.append(you)
	list.sort_custom(func(a, b): return float(a.fame) > float(b.fame))
	if list.size() == 1:
		c[1].add_child(UI.label("Nobody in your genre is at your level right now.", "Body"))
	for r in list.slice(0, 10):
		c[1].add_child(_band_row(r))
	return c[0]


func _megastars_card() -> Control:
	var c: Array = UI.card("The big leagues", "crown", "Card", UITheme.GOLD)
	var megas: Array = Game.rivals.filter(func(r): return not bool(r.local))
	megas.sort_custom(func(a, b): return float(a.fame) > float(b.fame))
	for r in megas.slice(0, 8):
		c[1].add_child(_band_row(r))
	return c[0]


func _band_row(r: Dictionary) -> Control:
	var h := UI.hbox(12)
	var you: bool = r.get("you", false)
	var n := UI.label(r.name, "Strong", UITheme.GOLD if you else UITheme.TEXT)
	n.custom_minimum_size.x = 230
	n.clip_text = true
	n.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	h.add_child(n)
	if r.has("genre") and not you:
		h.add_child(UI.genre_chip(r.genre))
	if bool(r.get("local", false)) and not you:
		h.add_child(UI.chip("Local", UITheme.INFO))
	var m := UI.meter(float(r.fame) / 100.0, UITheme.GOLD if you else UITheme.MUTED, 6.0)
	m.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	h.add_child(m)
	var fl := UI.label(str(int(r.fame)), "Strong", UITheme.GOLD if you else UITheme.MUTED)
	fl.custom_minimum_size.x = 32
	h.add_child(fl)
	return h


func _trends_card() -> Control:
	var c: Array = UI.card("Scene trends", "trendUp", "Card", UITheme.GOLD)
	c[1].add_child(UI.label("Which genres are hot this month. Hot genres pull in more walk-ins and new listeners.", "BodyMuted", null, true))
	var ids: Array = Game.trends.keys()
	ids.sort_custom(func(a, b): return float(Game.trends[a]) > float(Game.trends[b]))
	for gid in ids:
		var t := float(Game.trends[gid])
		var h := UI.hbox(10)
		var n := UI.label(Data.genre_name(gid), "Strong", UITheme.GOLD if gid == Game.genre else UITheme.TEXT)
		n.custom_minimum_size.x = 120
		h.add_child(n)
		var col := UITheme.GOOD if t >= 1.05 else (UITheme.BAD if t <= 0.95 else UITheme.MUTED)
		var m := UI.meter((t - 0.7) / 0.6, Data.genre_color(gid), 8.0)
		m.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		h.add_child(m)
		h.add_child(Icons.make("trendUp" if t >= 1.05 else ("trendDown" if t <= 0.95 else "minus"), 18, col))
		var l := UI.label("×%.2f" % t, "Small", col)
		l.custom_minimum_size.x = 46
		h.add_child(l)
		c[1].add_child(h)
	return c[0]
