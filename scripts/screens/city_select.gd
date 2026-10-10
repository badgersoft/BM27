extends Screen
## Step 2: choose a home city. Bigger cities hold more potential fans but
## rehearsal rooms and early gigs cost more.

var selected := -1
var detail: PanelContainer
var regions_box: GridContainer


func _ready() -> void:
	selected = Game.base_city
	var v := page_root(36)
	var top := UI.hbox(16)
	top.add_child(UI.button("BACK", "chevL", "Ghost", func(): go("managers")))
	top.add_child(UI.spacer())
	top.add_child(preload("res://scripts/screens/manager_select.gd")._steps(1))
	v.add_child(top)
	v.add_child(header("Where's Home?", "Your fanbase starts in your home city, spreads across the region, then the nation. Bigger cities mean more potential fans, but pricier rooms and gigs.", "Step 2 of 5 · Home city"))
	detail = UI.panel("CardHi")
	v.add_child(detail)
	regions_box = GridContainer.new()
	regions_box.columns = 3 if get_viewport_rect().size.x >= 1100 else 2
	regions_box.add_theme_constant_override("h_separation", 12)
	regions_box.add_theme_constant_override("v_separation", 12)
	v.add_child(UI.scroller(regions_box))
	_build()


func _build() -> void:
	var pub: Public = Game.public
	UI.clear(regions_box)
	for r in pub.regions.size():
		var reg: Dictionary = pub.regions[r]
		var c: Array = UI.card(reg.name, "home" if reg.id == "lon" else "venue", "Card", UITheme.GOLD)
		c[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
		for ci in reg.cities:
			c[1].add_child(_city_button(ci))
		regions_box.add_child(c[0])
	_build_detail()


func _city_button(ci: int) -> Button:
	var pub: Public = Game.public
	var city: Dictionary = pub.cities[ci]
	var on := ci == selected
	var b := Button.new()
	b.theme_type_variation = "SegOn" if on else "Seg"
	b.custom_minimum_size.y = 50
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.pressed.connect(func():
		selected = ci
		_build())
	var h := UI.hbox(10)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var col := Color("#140808") if on else UITheme.TEXT
	var n := UI.label(city.name, "Strong", col)
	n.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(n)
	h.add_child(UI.label("%s people" % U.num(city.count), "Small", col.darkened(0.2) if on else UITheme.MUTED))
	h.add_child(UI.label(_pounds(float(city.cost)), "Strong", Color("#7a4b00") if on else UITheme.GOLD))
	var m := UI.margin(h, 14, 0, 14, 0)
	m.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(UI.full_rect(m))
	return b


static func _pounds(cost: float) -> String:
	if cost >= 1.6:
		return "£££"
	if cost >= 1.08:
		return "££"
	return "£"


func _build_detail() -> void:
	UI.clear(detail)
	var pub: Public = Game.public
	if selected < 0:
		var h0 := UI.hbox(12)
		h0.add_child(Icons.make("target", 26, UITheme.GOLD))
		h0.add_child(UI.label("Pick a city below to see its music scene.", "Title"))
		detail.add_child(h0)
		return
	var city: Dictionary = pub.cities[selected]
	var mg: Dictionary = Game.manager()
	var h := UI.hbox(24)
	var iv := UI.vbox(4)
	iv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	iv.add_child(UI.label(pub.region_name(int(city.region)).to_upper(), "Caps", UITheme.ACCENT))
	var nm := UI.label(city.name, "H2")
	iv.add_child(nm)
	var scene := UI.hbox(8)
	scene.add_child(UI.label("THE SCENE", "Caps"))
	for g in city.top_genres:
		scene.add_child(UI.genre_chip(g))
	iv.add_child(scene)
	var share := float(city.genre_share.get(mg.genre, 0.0)) * 100.0
	iv.add_child(UI.label("%d%% of locals name %s as their favourite genre (%s's choice)." % [int(round(share)), Data.genre_name(mg.genre), mg.short], "BodyMuted", null, true))
	h.add_child(iv)
	h.add_child(UI.stat("users", "Music public", U.num(city.count)))
	h.add_child(UI.stat("funds", "Costs", "×%.2f" % float(city.cost), UITheme.GOLD))
	var b := UI.button("MAKE %s HOME" % str(city.name).to_upper(), "home", "Primary", _confirm)
	b.add_theme_font_size_override("font_size", 24)
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	h.add_child(b)
	detail.add_child(h)


func _confirm() -> void:
	Game.set_base_city(selected)
	go("practice_setup")


func on_back() -> void:
	go("managers")
