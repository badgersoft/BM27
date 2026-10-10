extends Screen
## Step 1: choose who you'll be. The player IS the manager, picked from
## four drawn from the roster.

var _cards: Array = []   # per card: Array of section Controls, aligned across cards
var _grid: GridContainer
var _aligning := false


func _ready() -> void:
	var v := page_root(36)
	var top := UI.hbox(16)
	top.add_child(UI.button("MENU", "chevL", "Ghost", func(): go("menu")))
	top.add_child(UI.spacer())
	top.add_child(_steps(0))
	v.add_child(top)
	v.add_child(header("Who Are You?", "This is your story. Pick the band manager you'll play as: your own savings, your own taste in music and one trick up your sleeve.", "Step 1 of 5 · Choose who you'll be"))
	var grid := GridContainer.new()
	_grid = grid
	var w := get_viewport_rect().size.x
	grid.columns = 4 if w >= 1200 else 2
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 16)
	for id in Game.manager_choices:
		grid.add_child(_card(Data.manager(id)))
	v.add_child(UI.scroller(grid))
	grid.resized.connect(func(): if not _aligning: _align.call_deferred())
	_align.call_deferred()


## Lines up each section (album, bio, perk...) across the cards in a row, so
## the boxes sit at the same height whatever the text wraps to.
func _align() -> void:
	if _aligning or not is_inside_tree():
		return
	_aligning = true
	for secs in _cards:
		for s in secs:
			s.custom_minimum_size.y = 0
	await get_tree().process_frame
	if not is_inside_tree():
		return
	var cols := maxi(1, _grid.columns)
	for row_start in range(0, _cards.size(), cols):
		var row := _cards.slice(row_start, row_start + cols)
		for si in row[0].size():
			var h := 0.0
			for secs in row:
				h = maxf(h, secs[si].get_combined_minimum_size().y)
			for secs in row:
				secs[si].custom_minimum_size.y = h
	await get_tree().process_frame
	_aligning = false


static func _steps(active: int) -> HBoxContainer:
	var h := UI.hbox(6)
	var names := ["You", "Home", "Rehearsal", "Recruit", "Name"]
	for i in names.size():
		var col := UITheme.ACCENT if i == active else (UITheme.TEXT if i < active else UITheme.DIM)
		var dot := UI.label("%d %s" % [i + 1, names[i].to_upper()], "Caps", col)
		h.add_child(dot)
		if i < names.size() - 1:
			h.add_child(UI.label("—", "Caps", UITheme.DIM))
	return h


func _card(mg: Dictionary) -> PanelContainer:
	var p := UI.panel("Card")
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var v := UI.vbox(10)
	p.add_child(v)
	var secs: Array = []
	var top := UI.hbox(14)
	top.add_child(Portrait.make(mg.look, 112))
	var idv := UI.vbox(4)
	idv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var nm := UI.label(mg.name, "Title", null, true)
	idv.add_child(nm)
	idv.add_child(UI.label("Age %d" % int(mg.age), "Small"))
	idv.add_child(UI.genre_chip(mg.genre, true))
	top.add_child(idv)
	v.add_child(top)
	secs.append(top)
	# Favourite album, styled like a record sleeve tag.
	var alb := UI.panel("CardFlat")
	var ah := UI.hbox(10)
	ah.add_child(Icons.make("vinyl", 26, Data.genre_color(mg.genre)))
	var av := UI.vbox(0)
	av.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	av.add_child(UI.label("FAVOURITE ALBUM", "Caps"))
	av.add_child(UI.label("'%s'" % mg.album, "Strong", null, true))
	av.add_child(UI.label("by %s" % mg.album_artist, "Small"))
	ah.add_child(av)
	alb.add_child(ah)
	v.add_child(alb)
	secs.append(alb)
	var bio := UI.label(mg.bio, "Body", null, true)
	bio.add_theme_font_size_override("font_size", 16)
	v.add_child(bio)
	secs.append(bio)
	var tastes := UI.label("Tastes: " + mg.tastes, "BodyMuted", null, true)
	tastes.add_theme_font_size_override("font_size", 15)
	v.add_child(tastes)
	secs.append(tastes)
	var perk: Array = UI.card(mg.perk_name, "bolt", "CardFlat", UITheme.GOLD)
	var pd := UI.label(mg.perk_desc, "Small", UITheme.TEXT, true)
	perk[1].add_child(pd)
	v.add_child(perk[0])
	secs.append(perk[0])
	_cards.append(secs)
	v.add_child(UI.spacer(false, true))
	var fr := UI.hbox(8)
	fr.add_child(UI.stat("funds", "Starting funds", U.money(mg.funds), UITheme.GOLD, true))
	v.add_child(fr)
	var b := UI.button("BE %s" % mg.short.to_upper(), "handshake", "Gold", func():
		Game.choose_manager(mg.id)
		go("city"))
	v.add_child(b)
	return p


func on_back() -> void:
	go("menu")
