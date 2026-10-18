class_name TalentPage
extends Page
## Scout and sign musicians (replacing whoever holds the role).

static var role := "vocals"


func build() -> void:
	title("Talent Scouting", "Who's out there looking for a band. Stars only show up once you're famous and rich enough. Availability changes monthly.", "search")
	var tabs := UI.hbox(6)
	for r in Game.ROLES:
		var b := UI.button(InstrumentData.ROLE_NAMES[r].to_upper() + "S", Icons.role_icon(r), "SegOn" if r == role else "Seg", func():
			role = r
			hq.refresh())
		tabs.add_child(b)
	tabs.add_child(UI.spacer())
	tabs.add_child(UI.stat("funds", "Funds", U.money(Game.funds), UITheme.GOLD))
	add_child(tabs)
	var cur := Game.member(role)
	if not cur.is_empty():
		var c: Array = UI.card("Current %s" % InstrumentData.ROLE_NAMES[role].to_lower(), Icons.role_icon(role), "CardFlat")
		var h := UI.hbox(14)
		h.add_child(Portrait.make(cur.look, 56))
		var v := UI.vbox(2)
		v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		v.add_child(UI.label(cur.name, "Strong"))
		v.add_child(UI.label("Age %d · %s" % [int(cur.age), Game.happiness_word(cur.happy)], "Small"))
		h.add_child(v)
		h.add_child(MusicianView.skill_block(cur, 240))
		c[1].add_child(h)
		add_child(c[0])
	var list: Array = Game.market(role)
	if list.is_empty():
		add_child(UI.label("Nobody's available right now. Try again next month.", "BodyMuted"))
	for m in list:
		add_child(MusicianView.market_row(m, func(): MusicianView.open_offer(main, m, func(_ok): hq.refresh()), cur))
