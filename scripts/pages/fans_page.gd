extends Page
## Your public: the fan ladder, how far you've spread, your top fans and
## where everyone lives.

const TIER_COLORS := [Color("#6d6a76"), Color("#8fd3f4"), Color("#4cc9f0"), Color("#ff3d2e"), Color("#ffc53d")]
const TIER_ICONS := ["minus", "headphones", "radio", "heart", "crown"]
const TOP_FAN_MIN := 25


func build() -> void:
	var pub: Public = Game.public
	var sub := "%s people stand for the UK's %s music lovers. Your first 99 in any group are real individuals; bigger groups count each person as more." % [U.num(pub.size()), U.num(Public.TOTAL_REAL)]
	title("Your Public", sub, "heart")
	add_child(_ladder(pub))
	add_child(_journey(pub))
	var cols := columns(1.25)
	cols[0].add_child(_top_fans(pub))
	cols[0].add_child(_demographics(pub))
	cols[1].add_child(_cities(pub))
	cols[1].add_child(_counting())


# ------------------------------------------------------------- fan ladder

func _ladder(pub: Public) -> Control:
	var grid := GridContainer.new()
	grid.columns = 5 if get_viewport().get_visible_rect().size.x >= 1360 else 3
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	for t in 5:
		var col: Color = TIER_COLORS[t]
		var p := PanelContainer.new()
		p.add_theme_stylebox_override("panel", UITheme.box(UITheme.PANEL, 14, Color(col.r, col.g, col.b, 0.5), 1, 14, 12))
		p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var v := UI.vbox(4)
		var h := UI.hbox(8)
		h.add_child(Icons.make(TIER_ICONS[t], 20, col))
		h.add_child(UI.label(Public.TIER_NAMES[t].to_upper(), "Caps", col))
		v.add_child(h)
		var n := pub.count(t)
		var real := pub.real_tier(t)
		v.add_child(UI.label(U.num(real), "StatBig", UITheme.TEXT if t > 0 else UITheme.MUTED))
		v.add_child(UI.label("%s %s in the game" % [U.num(n), U.plural(n, "person", "people")], "Small", col))
		var d := UI.label(Public.TIER_DESC[t], "Small", UITheme.MUTED, true)
		d.add_theme_font_size_override("font_size", 14)
		v.add_child(d)
		p.add_child(v)
		grid.add_child(p)
	return grid


# ------------------------------------------------------------ reach steps

func _journey(pub: Public) -> Control:
	var c: Array = UI.card("Reach", "trendUp", "Card", UITheme.GOLD)
	var row := UI.hbox(10)
	var home_r := pub.region_of(Game.base_city)
	var steps := ["Local · %s" % Game.city_name(), "Regional · %s" % pub.regions[home_r].short, "National · All 9 regions"]
	for i in 3:
		var on := pub.stage >= i
		var chip := PanelContainer.new()
		var col := UITheme.GOLD if pub.stage == i else (UITheme.GOOD if on else UITheme.DIM)
		chip.add_theme_stylebox_override("panel", UITheme.box(Color(col.r, col.g, col.b, 0.14 if on else 0.05), 20, col, 1, 14, 6))
		var h := UI.hbox(6)
		h.add_child(Icons.make("check" if pub.stage > i else ("target" if pub.stage == i else "lock"), 16, col))
		h.add_child(UI.label(steps[i].to_upper(), "Caps", col))
		chip.add_child(h)
		row.add_child(chip)
		if i < 2:
			row.add_child(Icons.make("chevR", 16, UITheme.DIM))
	c[1].add_child(row)
	var hint := ""
	match pub.stage:
		0:
			var ct := pub.city_counts(Game.base_city)
			hint = "Win 25 real fans in %s (you have %d) and word will spread across %s." % [Game.city_name(), ct[Public.FAN] + ct[Public.SUPER], pub.regions[home_r].name]
		1:
			hint = "Build a strong following across the region, or land a national chart hit, to go national."
		2:
			hint = "You're known all over the country. Keep them listening."
	c[1].add_child(UI.label(hint, "BodyMuted", null, true))
	return c[0]


# -------------------------------------------------------------- top fans

func _top_fans(pub: Public) -> Control:
	var c: Array = UI.card("Top fans", "trophy", "Card", UITheme.GOLD)
	var grid := GridContainer.new()
	grid.columns = 6
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 8)
	for h in ["#", "NAME", "", "FAN FOR", "FROM", "LOVE"]:
		grid.add_child(UI.label(h, "Caps"))
	c[1].add_child(grid)
	var real := pub.real_fans()
	if real <= TOP_FAN_MIN:
		var empty := UI.vbox(4)
		empty.add_child(UI.icon_label("heart", "You don't have any real fans yet", UITheme.MUTED, "Title", 20))
		empty.add_child(UI.label("The table fills up once more than %d people count themselves as real fans (%d so far). Great gigs are the quickest way to win them." % [TOP_FAN_MIN, real], "BodyMuted", null, true))
		c[1].add_child(empty)
		return c[0]
	var fans := pub.top_fans(TOP_FAN_MIN)
	for i in fans.size():
		var f: Dictionary = fans[i]
		var t := int(f.tier)
		grid.add_child(UI.label(str(i + 1), "Strong", UITheme.GOLD if i < 3 else UITheme.MUTED))
		var nm := UI.label(f.name, "Strong")
		nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nm.tooltip_text = "Age %d · loves %s and %s · gig-goer %d · loyalty %d · variance %d" % [f.age, Data.genre_name(f.fav), Data.genre_name(f.second), f.gig, f.loyalty, f.variance]
		nm.mouse_filter = Control.MOUSE_FILTER_PASS
		grid.add_child(nm)
		grid.add_child(UI.chip(Public.TIER_NAMES[t], TIER_COLORS[t], t == Public.SUPER))
		grid.add_child(UI.label(_months(int(f.months)), "Body"))
		grid.add_child(UI.label(f.city, "Body", UITheme.MUTED))
		var love := UI.hbox(8)
		var m := UI.meter(float(f.fanatic) / 100.0, TIER_COLORS[t], 6.0)
		m.custom_minimum_size.x = 80
		m.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		love.add_child(m)
		love.add_child(UI.label(str(int(f.fanatic)), "Strong", TIER_COLORS[t]))
		grid.add_child(love)
	return c[0]


static func _months(m: int) -> String:
	if m < 1:
		return "New"
	if m < 12:
		return "%d %s" % [m, U.plural(m, "month")]
	var y := m / 12
	var r := m % 12
	return "%dy %dm" % [y, r] if r > 0 else "%d %s" % [y, U.plural(y, "year")]


# ------------------------------------------------------- how we count

func _counting() -> Control:
	var c: Array = UI.card("How we count", "info", "CardFlat", UITheme.MUTED)
	c[1].add_child(UI.label("Each person in the game stands for more real people as a group grows. Only the people inside each band get its weight, so numbers never jump.", "Small", UITheme.MUTED, true))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 24)
	var prev := 0
	for b in Public.BANDS:
		var top := int(b[0])
		var label := "%s+" % U.num(prev + 1) if top >= 1000000 else "%s – %s" % [U.num(prev + 1), U.num(top)]
		grid.add_child(UI.label(label + " people", "Small", UITheme.TEXT))
		grid.add_child(UI.label("× %d each" % int(b[1]), "Strong", UITheme.GOLD))
		prev = top
	c[1].add_child(grid)
	return c[0]


# ---------------------------------------------------------- demographics

func _demographics(pub: Public) -> Control:
	var c: Array = UI.card("Who are your fans?", "users", "Card", UITheme.GOLD)
	var d := pub.demographics(Public.REGULAR)
	if int(d.total) == 0:
		c[1].add_child(UI.label("Nobody's into you enough yet to draw a picture.", "BodyMuted"))
		return c[0]
	c[1].add_child(UI.label("Regular listeners and up · %d people · %d%% female, %d%% male" % [d.total, int(round(100.0 * d.female / d.total)), 100 - int(round(100.0 * d.female / d.total))], "Small"))
	var labels := ["Under 18", "18-24", "25-34", "35-49", "50-64", "65+"]
	var mx := 1
	for n in d.bands:
		mx = maxi(mx, int(n))
	for i in 6:
		var h := UI.hbox(10)
		var l := UI.label(labels[i], "Small", UITheme.TEXT)
		l.custom_minimum_size.x = 70
		h.add_child(l)
		var m := UI.meter(float(d.bands[i]) / mx, UITheme.INFO, 8.0)
		m.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		h.add_child(m)
		var n := UI.label(str(d.bands[i]), "Small")
		n.custom_minimum_size.x = 40
		h.add_child(n)
		c[1].add_child(h)
	return c[0]


# ---------------------------------------------------------------- cities

func _cities(pub: Public) -> Control:
	var c: Array = UI.card("Across the country", "venue", "Card", UITheme.GOLD)
	var home_r := pub.region_of(Game.base_city)
	var order: Array = range(pub.regions.size())
	order.sort_custom(func(a, b):
		if a == home_r:
			return true
		if b == home_r:
			return false
		return _region_engaged(pub, a) > _region_engaged(pub, b))
	var unreached: Array = []
	for r in order:
		if r != home_r and _region_engaged(pub, r) == 0:
			unreached.append(pub.regions[r].short)
			continue
		c[1].add_child(UI.label(str(pub.regions[r].name).to_upper(), "Caps", UITheme.ACCENT if r == home_r else UITheme.MUTED))
		for ci in pub.regions[r].cities:
			c[1].add_child(_city_row(pub, ci))
	if not unreached.is_empty():
		c[1].add_child(UI.sep())
		c[1].add_child(UI.icon_label("lock", "Not reached yet: " + ", ".join(unreached), UITheme.DIM, "Small"))
	return c[0]


static func _region_engaged(pub: Public, r: int) -> int:
	var n := 0
	for ci in pub.regions[r].cities:
		var ct: Array = pub.city_counts(ci)
		n += ct[1] + ct[2] + ct[3] + ct[4]
	return n


func _city_row(pub: Public, ci: int) -> Control:
	var v := UI.vbox(3)
	var h := UI.hbox(8)
	if ci == Game.base_city:
		h.add_child(Icons.make("home", 14, UITheme.GOLD))
	var n := UI.label(pub.city_name(ci), "Strong", UITheme.GOLD if ci == Game.base_city else UITheme.TEXT)
	n.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(n)
	var ct: Array = pub.city_counts(ci)
	for t in [1, 2, 3, 4]:
		var cell := UI.hbox(3)
		cell.add_child(Icons.make(TIER_ICONS[t], 12, TIER_COLORS[t]))
		var l := UI.label(str(ct[t]), "Small", UITheme.TEXT)
		l.custom_minimum_size.x = 30
		cell.add_child(l)
		cell.tooltip_text = Public.TIER_NAMES[t]
		h.add_child(cell)
	v.add_child(h)
	var m := UI.meter(pub.exposure[ci], UITheme.GOLD, 4.0)
	m.tooltip_text = "How much your music is circulating in %s" % pub.city_name(ci)
	v.add_child(m)
	return v
