class_name MusicianView
extends RefCounted
## Reusable musician widgets: list rows, skill bars, and the signing dialog.


static func tier_badge(m: Dictionary) -> Control:
	match int(m.tier):
		2: return UI.chip("Superstar", UITheme.GOLD, true, "crown")
		1: return UI.chip("Star", UITheme.GOLD, false, "star")
	return null


## Skill bar with potential marker (exact) or band (estimate).
static func skill_block(m: Dictionary, width: float = 180.0) -> VBoxContainer:
	var v := UI.vbox(4)
	var pr := Game.potential_range(m)
	var top := UI.hbox(6)
	top.add_child(UI.label("SKILL", "Caps"))
	top.add_child(UI.label(str(int(m.skill)), "Strong"))
	top.add_child(UI.spacer())
	var pot_txt := str(pr.x) if pr.x == pr.y else "%d–%d" % [pr.x, pr.y]
	top.add_child(UI.label("POTENTIAL", "Caps"))
	top.add_child(UI.label(pot_txt, "Strong", UITheme.GOLD))
	v.add_child(top)
	var bar: Meter
	if pr.x == pr.y:
		bar = UI.meter(float(m.skill) / 100.0, UITheme.INFO, 8.0, float(m.pot) / 100.0)
	else:
		bar = UI.meter(float(m.skill) / 100.0, UITheme.INFO, 8.0, pr.x / 100.0, pr.y / 100.0)
	v.add_child(bar)
	v.custom_minimum_size.x = width
	return v


## Their own fame, with a word for it and a hint when it's getting risky.
static func fame_block(m: Dictionary, width: float = 150.0) -> VBoxContainer:
	var f := float(m.get("fame", 0.0))
	var v := UI.vbox(4)
	var top := UI.hbox(6)
	top.add_child(Icons.make("star", 16, UITheme.GOLD))
	top.add_child(UI.label("FAME · " + fame_word(f).to_upper(), "Caps", UITheme.GOLD))
	top.add_child(UI.spacer())
	top.add_child(UI.label(str(int(f)), "Strong", UITheme.GOLD))
	v.add_child(top)
	v.add_child(UI.meter(f / 100.0, UITheme.GOLD, 8.0))
	v.custom_minimum_size.x = width
	v.tooltip_text = "Personal fame. Above 55, members start doing unpredictable things: some good, some not. Happy members tend to use it for good."
	v.mouse_filter = Control.MOUSE_FILTER_PASS
	return v


static func fame_word(f: float) -> String:
	if f >= 90.0:
		return "Icon"
	if f >= 75.0:
		return "Celeb"
	if f >= 55.0:
		return "Famous"
	if f >= 25.0:
		return "Known"
	return "Unknown"


static func happy_block(m: Dictionary, width: float = 150.0) -> VBoxContainer:
	var h := float(m.happy)
	var col := UI.happiness_color(h)
	var v := UI.vbox(4)
	var top := UI.hbox(6)
	top.add_child(Icons.make(UI.happiness_icon(h), 16, col))
	top.add_child(UI.label(Game.happiness_word(h).to_upper(), "Caps", col))
	top.add_child(UI.spacer())
	top.add_child(UI.label(str(int(h)), "Strong", col))
	v.add_child(top)
	v.add_child(UI.meter(h / 100.0, col, 8.0))
	v.custom_minimum_size.x = width
	return v


## A compact market row: portrait, identity, skill, price, action button.
static func market_row(m: Dictionary, action: Callable, replacing: Dictionary = {}) -> PanelContainer:
	var value := Game.value_of(m)
	var affordable := value <= Game.funds
	var p := UI.panel("Card")
	if not affordable:
		p.modulate = Color(1, 1, 1, 0.55)
	var h := UI.hbox(16)
	h.add_child(Portrait.make(m.look, 72))
	var id := UI.vbox(4)
	id.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var nm := UI.hbox(8)
	nm.add_child(UI.label(m.name, "Title"))
	var tb := tier_badge(m)
	if tb:
		nm.add_child(tb)
	id.add_child(nm)
	var tags := UI.hbox(8)
	tags.add_child(UI.label("Age %d" % int(m.age), "Small"))
	tags.add_child(UI.genre_pair(m))
	tags.add_child(UI.chip(Game.temperament_word(int(m.ease)), UITheme.MUTED))
	id.add_child(tags)
	var bio := UI.label(m.bio, "BodyMuted", null, true)
	bio.add_theme_font_size_override("font_size", 15)
	id.add_child(bio)
	h.add_child(id)
	var mid := UI.vbox(8)
	mid.add_child(skill_block(m, 210))
	mid.add_child(UI.icon_label(Icons.role_icon(m.role), Data.instrument(m.role, int(m.inst)).name, UITheme.MUTED, "Small", 14))
	mid.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	h.add_child(mid)
	var right := UI.vbox(6)
	right.custom_minimum_size.x = 150
	right.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var price := UI.label("FREE" if value == 0 else U.money(value), "Stat", UITheme.GOOD if value == 0 else UITheme.GOLD)
	price.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	right.add_child(price)
	var btn: Button
	if not affordable:
		btn = UI.button("Can't afford", "lock", "", Callable())
		btn.disabled = true
	elif int(m.cooldown) > Game.week:
		btn = UI.button("Not talking", "x", "", Callable())
		btn.disabled = true
	else:
		btn = UI.button("SIGN" if value == 0 else "MAKE OFFER", "handshake", "Gold", action)
	right.add_child(btn)
	if not replacing.is_empty() and affordable:
		var r := UI.label("Replaces %s" % replacing.name.get_slice(" ", 0), "Small", UITheme.BAD)
		r.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		right.add_child(r)
	h.add_child(right)
	p.add_child(h)
	return p


## Opens the offer dialog. on_done(ok: bool) called after a successful signing.
static func open_offer(main: Control, m: Dictionary, on_done: Callable) -> void:
	var value := float(Game.value_of(m))
	if value <= 0.0:
		var cur := Game.member(m.role)
		var sign_free := func():
			Game.sign_musician(m.id, 0.0)
			main.show_toast("%s has joined the band!" % m.name, "good")
			on_done.call(true)
		if not cur.is_empty():
			main.confirm("Replace %s?" % cur.name, "[b]%s[/b] will join for free and [b]%s[/b] will leave the band." % [m.name, cur.name], "SIGN", sign_free, "swap", "Gold")
		else:
			sign_free.call()
		return
	var v := UI.vbox(16)
	var top := UI.hbox(16)
	top.add_child(Portrait.make(m.look, 110))
	var info := UI.vbox(4)
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_child(UI.label("NEGOTIATION", "Caps", UITheme.ACCENT))
	info.add_child(UI.label(m.name, "H2"))
	info.add_child(UI.label("%s · Age %d · Loves %s and %s" % [InstrumentData.ROLE_NAMES[m.role], int(m.age), Data.genre_name(m.genre), Data.genre_name(m.get("genre2", m.genre))], "BodyMuted"))
	info.add_child(skill_block(m, 300))
	top.add_child(info)
	v.add_child(top)
	var cont := float(m.happy)
	var mood := "They're very comfortable where they are and will want close to full price." if cont > 70.0 \
		else ("They're open to a deal if the number is right." if cont > 40.0 else "They're desperate for a band. A cheeky offer might just work.")
	var c: Array = UI.card("Their asking price", "funds", "CardFlat", UITheme.GOLD)
	c[1].add_child(UI.label(U.money_full(value), "StatBig", UITheme.GOLD))
	c[1].add_child(UI.label("Contentment %d. %s" % [int(cont), mood], "BodyMuted", null, true))
	var cur2 := Game.member(m.role)
	if not cur2.is_empty():
		c[1].add_child(UI.icon_label("swap", "Signing will replace %s, who will leave the band." % cur2.name, UITheme.BAD, "Small"))
	v.add_child(c[0])
	v.add_child(UI.label("MAKE AN OFFER", "Caps"))
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	var modal: Control
	for pct in [100, 90, 80, 70, 60, 50]:
		var amt := roundf(value * pct / 100.0 / 10.0) * 10.0
		var b := UI.button("%d%%  ·  %s" % [pct, U.money(amt)], "", "Gold" if pct == 100 else "", func():
			var res := Game.make_offer(m.id, amt)
			main.close_modal(modal)
			main.show_toast(res.text, "good" if res.ok else "bad")
			on_done.call(res.ok))
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.disabled = amt > Game.funds
		grid.add_child(b)
	v.add_child(grid)
	var row := UI.hbox(10)
	row.add_child(UI.label("Lowball offers risk them refusing to talk for a few weeks.", "Small", UITheme.DIM, true))
	row.get_child(0).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(UI.button("Walk away", "x", "Ghost", func(): main.close_modal(modal)))
	v.add_child(row)
	modal = main.open_modal(v, 680, true)
