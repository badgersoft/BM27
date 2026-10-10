extends Screen
## Step 3: sign a singer, guitarist, bassist and drummer.

var role := "vocals"
var slots_box: HBoxContainer
var tabs_box: HBoxContainer
var list: VBoxContainer
var funds_box: Control
var next_btn: Button
var scroll: ScrollContainer


func _ready() -> void:
	var v := page_root(36)
	var top := UI.hbox(16)
	top.add_child(UI.button("BACK", "chevL", "Ghost", func(): go("practice_setup")))
	top.add_child(UI.spacer())
	top.add_child(preload("res://scripts/screens/manager_select.gd")._steps(2))
	v.add_child(top)
	var hr := UI.hbox(20)
	var hd := header("Find Your Four", "Freelancers are free. Better players cost money. Young players have the most potential to grow.", "Step 3 of 4 · Recruit")
	hd.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hr.add_child(hd)
	funds_box = UI.vbox(0)
	hr.add_child(funds_box)
	v.add_child(hr)
	slots_box = UI.hbox(12)
	v.add_child(slots_box)
	var tr := UI.hbox(12)
	tabs_box = UI.hbox(6)
	tr.add_child(tabs_box)
	tr.add_child(UI.spacer())
	next_btn = UI.button("NAME THE BAND", "chevR", "Primary", func(): go("naming"))
	next_btn.add_theme_font_size_override("font_size", 24)
	tr.add_child(next_btn)
	v.add_child(tr)
	list = UI.vbox(10)
	scroll = UI.scroller(list)
	v.add_child(scroll)
	_refresh()


func _refresh() -> void:
	UI.clear(funds_box)
	funds_box.add_child(funds_pill())
	UI.clear(slots_box)
	for r in Game.ROLES:
		slots_box.add_child(_slot(r))
	UI.clear(tabs_box)
	for r in Game.ROLES:
		var b := UI.button(InstrumentData.ROLE_NAMES[r].to_upper() + "S", Icons.role_icon(r), "SegOn" if r == role else "Seg", _set_role.bind(r))
		tabs_box.add_child(b)
	UI.clear(list)
	var cur := Game.member(role)
	for m in Game.market(role):
		list.add_child(MusicianView.market_row(m, _offer.bind(m), cur))
	next_btn.disabled = not Game.band_complete()
	scroll.scroll_vertical = 0


func _slot(r: String) -> PanelContainer:
	var m := Game.member(r)
	var p := UI.panel("CardHi" if r == role else "CardFlat")
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var h := UI.hbox(12)
	if m.is_empty():
		var ph := PanelContainer.new()
		ph.add_theme_stylebox_override("panel", UITheme.box(UITheme.BG_2, 12, UITheme.LINE, 2, 12, 12))
		ph.add_child(Icons.make(Icons.role_icon(r), 30, UITheme.DIM))
		h.add_child(ph)
		var v := UI.vbox(0)
		v.add_child(UI.label(InstrumentData.ROLE_NAMES[r].to_upper(), "Caps"))
		v.add_child(UI.label("Vacant", "Title", UITheme.DIM))
		h.add_child(v)
	else:
		h.add_child(Portrait.make(m.look, 56))
		var v2 := UI.vbox(0)
		v2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		v2.add_child(UI.label(InstrumentData.ROLE_NAMES[r].to_upper(), "Caps", UITheme.GOOD))
		v2.add_child(UI.label(m.name, "Strong", null, true))
		v2.add_child(UI.label("Skill %d" % int(m.skill), "Small"))
		h.add_child(v2)
	p.add_child(h)
	p.mouse_filter = Control.MOUSE_FILTER_STOP
	p.gui_input.connect(func(e):
		if (e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT) or (e is InputEventScreenTouch and e.pressed):
			_set_role(r))
	return p


func _set_role(r: String) -> void:
	role = r
	_refresh()


func _offer(m: Dictionary) -> void:
	MusicianView.open_offer(main, m, func(ok):
		if ok:
			# Hop to the next empty slot.
			for r in Game.ROLES:
				if Game.member(r).is_empty():
					role = r
					break
		_refresh())


func on_back() -> void:
	go("practice_setup")
