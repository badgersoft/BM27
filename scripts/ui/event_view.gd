class_name EventView
extends RefCounted
## Presents queued game events as modals and feeds choices back to Game.

const BandPage := preload("res://scripts/pages/band_page.gd")


static func present(main: Control, ev: Dictionary, done: Callable) -> void:
	match ev.type:
		"gig": _gig(main, ev, done)
		"news": _news(main, ev, done)
		"report": _report(main, done)
		"interview": _interview(main, ev, done)
		"complaint": _complaint(main, ev, done)
		"left": _left(main, ev, done)
		"producer": _producer(main, ev, done)
		"name_release": _name_release(main, ev, done)
		"label": _label(main, ev, done)
		"star": _star(main, ev, done)
		"random", "fame": _random(main, ev, done)
		"doc", "film": _media_deal(main, ev, done)
		"breakup": _breakup(main, ev, done)
		"end": _end(main, ev, done)
		_: done.call_deferred()


# ---------------------------------------------------------------- helpers

static func _frame(kicker: String, title: String, icon: String, color: Color = UITheme.GOLD) -> VBoxContainer:
	var v := UI.vbox(16)
	var h := UI.hbox(14)
	var circ := PanelContainer.new()
	circ.add_theme_stylebox_override("panel", UITheme.box(Color(color.r, color.g, color.b, 0.16), 28, Color(0, 0, 0, 0), 0, 12, 12))
	circ.add_child(Icons.make(icon, 30, color))
	circ.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	h.add_child(circ)
	var tv := UI.vbox(0)
	tv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tv.add_child(UI.label(kicker.to_upper(), "Caps", color))
	tv.add_child(UI.label(title, "H2", null, true))
	h.add_child(tv)
	v.add_child(h)
	return v


## Resolve the event with a choice, then show the result (if any).
static func _choose(main: Control, modal: Control, ev: Dictionary, choice: Variant, done: Callable) -> void:
	main.close_modal(modal)
	var res: Dictionary = Game.resolve_event(ev, choice)
	_result(main, res, done)


static func _result(main: Control, res: Dictionary, done: Callable) -> void:
	if res.is_empty():
		done.call_deferred()
		return
	var col := UI.kind_color(res.get("kind", "info"))
	var v := _frame("Outcome", res.title, res.get("icon", "info"), col)
	v.add_child(UI.label(res.text, "Body", null, true))
	var m: Control
	v.add_child(UI.button("CONTINUE", "chevR", "Gold", func():
		main.close_modal(m)
		done.call_deferred()))
	m = main.open_modal(v, 600)


static func _choice_button(text: String, icon: String, variation: String, cb: Callable, disabled: bool = false) -> Button:
	var b := UI.button(text, icon, variation, cb)
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.disabled = disabled
	b.custom_minimum_size.y = 50
	return b


# --------------------------------------------------------------- gig night

static func _gig(main: Control, ev: Dictionary, done: Callable) -> void:
	var g: Dictionary = ev.gig
	var v := UI.vbox(16)
	var art := StageArt.new()
	art.tex = StageArt.build(g.colour, float(g.fill), float(g.crowd), int(g.week) * 31 + int(g.venue), int(g.attendance))
	art.band = Game.band_name
	art.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_child(art)
	var head := UI.hbox(16)
	var hv := UI.vbox(0)
	hv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hv.add_child(UI.label(("FINAL TOUR · " if bool(g.final_tour) else "") + "GIG NIGHT · " + str(g.get("city", "")).to_upper() + " · " + U.date_label(int(g.week)), "Caps", UITheme.ACCENT))
	var vn := UI.label(g.venue_name, "H1", null, true)
	vn.add_theme_font_size_override("font_size", 52)
	hv.add_child(vn)
	head.add_child(hv)
	var att := UI.vbox(-6)
	att.add_child(UI.label("ATTENDANCE", "Caps"))
	att.add_child(UI.label("%s / %s" % [U.num(g.attendance), U.num(g.cap)], "StatBig", UITheme.GOLD))
	att.add_child(UI.label("%d%% full" % int(round(float(g.fill) * 100.0)), "Small"))
	head.add_child(att)
	v.add_child(head)
	# Who turned up.
	v.add_child(_crowd_bar(g))
	if str(g.clash) != "":
		v.add_child(UI.icon_label("alert", "%s played across town the same night and pinched some of your crowd." % g.clash, Color("#ff9f43"), "Small"))
	var cols := UI.hbox(16)
	var rc: Array = UI.card("The crowd", "users", "CardFlat", UITheme.GOLD)
	rc[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rc[1].add_child(UI.stars(float(g.crowd), 30))
	rc[1].add_child(UI.label(g.crowd_quote, "Body", null, true))
	cols.add_child(rc[0])
	var cc: Array = UI.card("The critic", "pen", "CardFlat", UITheme.INFO)
	cc[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cc[1].add_child(UI.stars(float(g.critic), 30, UITheme.INFO))
	cc[1].add_child(UI.label("“%s”" % g.critic_quote, "Body", null, true))
	if str(g.get("critic_advice", "")) != "":
		cc[1].add_child(UI.icon_label("info", "Advice: " + str(g.critic_advice), UITheme.MUTED, "Small", 16, true))
	if str(g.get("review_note", "")) != "":
		cc[1].add_child(UI.label(str(g.review_note), "Small", UITheme.INFO, true))
	cols.add_child(cc[0])
	v.add_child(cols)
	var money: Array = UI.card("The money", "funds", "CardFlat", UITheme.GOLD)
	var grid := GridContainer.new()
	grid.columns = 5
	grid.add_theme_constant_override("h_separation", 22)
	grid.add_child(UI.stat("ticket", "Tickets", U.money(g.tickets)))
	grid.add_child(UI.stat("cash", "Bar (half)", U.money(g.bar)))
	grid.add_child(UI.stat("shirt", "Merch", U.money(g.merch)))
	grid.add_child(UI.stat("venue", "Venue hire", "−" + U.money(g.hire), UITheme.MUTED))
	grid.add_child(UI.stat("funds", "Profit", U.signed_money(float(g.profit)), UITheme.GOOD if float(g.profit) >= 0 else UITheme.BAD, true))
	money[1].add_child(grid)
	v.add_child(money[0])
	var conv := UI.hbox(24)
	conv.add_child(UI.stat("headphones", "New listeners", U.signed_num(float(g.new_listeners)), UITheme.INFO))
	conv.add_child(UI.stat("heart", "New fans", U.signed_num(float(g.new_fans)), UITheme.ACCENT))
	conv.add_child(UI.spacer())
	var m: Control
	var b := UI.button("CONTINUE", "chevR", "Primary", func():
		main.close_modal(m)
		done.call_deferred())
	conv.add_child(b)
	v.add_child(conv)
	m = main.open_modal(v, 1080)


static func _crowd_bar(g: Dictionary) -> Control:
	var v := UI.vbox(6)
	var total := maxf(1.0, float(g.cap))
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 2)
	bar.custom_minimum_size.y = 18
	var parts := [[g.fans, UITheme.ACCENT], [g.listeners, UITheme.INFO], [g.walkins, UITheme.GOLD], [float(g.cap) - float(g.attendance), Color(1, 1, 1, 0.08)]]
	for p in parts:
		if float(p[0]) <= 0.0:
			continue
		var r := ColorRect.new()
		r.color = p[1]
		r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		r.size_flags_stretch_ratio = float(p[0]) / total
		bar.add_child(r)
	v.add_child(bar)
	var legend := UI.hbox(22)
	legend.add_child(_legend(UITheme.ACCENT, "Fans", int(g.fans)))
	legend.add_child(_legend(UITheme.INFO, "Listeners", int(g.listeners)))
	legend.add_child(_legend(UITheme.GOLD, "Walk-ins", int(g.walkins)))
	if int(g.get("travelled", 0)) > 0:
		legend.add_child(UI.icon_label("bus", "%s travelled from other cities" % U.num(int(g.travelled)), UITheme.MUTED, "Small", 14))
	if int(g.get("super_fans", 0)) > 0:
		legend.add_child(UI.icon_label("crown", "%s super fans" % U.num(int(g.super_fans)), UITheme.GOLD, "Small", 14))
	v.add_child(legend)
	return v


static func _legend(c: Color, text: String, n: int) -> Control:
	var h := UI.hbox(6)
	var sw := ColorRect.new()
	sw.color = c
	sw.custom_minimum_size = Vector2(12, 12)
	sw.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	h.add_child(sw)
	h.add_child(UI.label("%s %s" % [text, U.num(n)], "Small", UITheme.TEXT))
	return h


# ------------------------------------------------------------- newspaper

static func _news(main: Control, ev: Dictionary, done: Callable) -> void:
	var p: Dictionary = ev.paper
	var v := UI.vbox(10)
	var mast := UI.label(str(p.pub).to_upper(), "", UITheme.INK)
	mast.add_theme_font_override("font", UITheme.serif_black())
	mast.add_theme_font_size_override("font_size", 62)
	mast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(mast)
	v.add_child(_ink_rule(3))
	var dl := UI.hbox(8)
	dl.add_child(_ink_label("%s · No. %d" % [p.date, 1000 + Game.week], 14, UITheme.F_COND_BOLD))
	dl.add_child(UI.spacer())
	dl.add_child(_ink_label("THE PAPER THAT ROCKS · 80p", 14, UITheme.F_COND_BOLD))
	v.add_child(dl)
	v.add_child(_ink_rule(1))
	var lead: bool = p.placement == "lead"
	var head_text: String = (str(p.you).to_upper() if lead else p.headline)
	var hl := _ink_label(head_text, 34 if lead else 38, UITheme.serif_black())
	hl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(hl)
	v.add_child(_ink_label(p.sub if not lead else str(p.get("lead_sub", "Our reporter was there. Fans were going wild.")), 18, UITheme.F_MED, true))
	v.add_child(_ink_rule(1))
	var cols := UI.hbox(22)
	var c1 := UI.vbox(6)
	c1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	c1.add_child(_ink_label("ALSO THIS WEEK", 14, UITheme.F_COND_BOLD))
	var s2 := _ink_label(p.second if not lead else p.headline, 22, UITheme.serif_black(), true)
	c1.add_child(s2)
	cols.add_child(c1)
	var c2 := PanelContainer.new()
	c2.add_theme_stylebox_override("panel", UITheme.box(Color(0, 0, 0, 0.06), 2, UITheme.INK, 1, 14, 10))
	c2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var cv := UI.vbox(4)
	var box_title := "IN BRIEF · LOCAL SCENE" if p.placement == "brief" else ("RISING STARS" if p.placement == "sidebar" else "THE CHARTS")
	cv.add_child(_ink_label(box_title, 14, UITheme.F_COND_BOLD))
	if lead:
		cv.add_child(_ink_label(str(p.get("lead_box", "Everybody's talking about %s." % Game.band_name)), 17, UITheme.F_MED, true))
	else:
		cv.add_child(_ink_label(p.you, 17 if p.placement == "brief" else 19, UITheme.F_SEMI, true))
	c2.add_child(cv)
	cols.add_child(c2)
	v.add_child(cols)
	if str(p.effect) != "":
		var col := UITheme.GOOD.darkened(0.45) if p.kind == "good" else UITheme.BAD.darkened(0.3)
		var eff := _ink_label("Effect: " + str(p.effect), 15, UITheme.F_BOLD)
		eff.add_theme_color_override("font_color", col)
		v.add_child(eff)
	var row := UI.hbox(10)
	row.add_child(UI.spacer())
	var m: Control
	var b := UI.button("PUT IT DOWN", "chevR", "", func():
		main.close_modal(m)
		done.call_deferred())
	b.add_theme_stylebox_override("normal", UITheme.box(UITheme.INK, 8, Color(0, 0, 0, 0), 0, 18, 10))
	row.add_child(b)
	v.add_child(row)
	m = main.open_modal(v, 860, false, "Paper")


static func _ink_label(text: String, size: int, font: Font, wrap: bool = false) -> Label:
	var l := UI.label(text, "", UITheme.INK, wrap)
	l.add_theme_font_override("font", font)
	l.add_theme_font_size_override("font_size", size)
	if wrap:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


static func _ink_rule(h: int) -> ColorRect:
	var r := ColorRect.new()
	r.color = UITheme.INK
	r.custom_minimum_size.y = h
	return r


# ---------------------------------------------------------------- report

static func _report(main: Control, done: Callable) -> void:
	var r: Dictionary = Game.report
	var v := _frame("Weekly update", "Week ending " + U.date_label(int(r.get("week", Game.week))), "mail")
	for ln in r.get("lines", []):
		v.add_child(UI.icon_label("dot", ln.text, UI.kind_color(ln.kind), "Body", 10))
	var m: Control
	v.add_child(UI.button("CONTINUE", "chevR", "Gold", func():
		main.close_modal(m)
		done.call_deferred()))
	m = main.open_modal(v, 640)


# ------------------------------------------------------------- interview

static func _interview(main: Control, ev: Dictionary, done: Callable) -> void:
	var o: Dictionary = MediaData.OUTLETS[int(ev.outlet)].duplicate()
	o.name = Game.cityize(o.name)
	var v := _frame("Interview request · " + o.kind, o.name, o.icon, UITheme.INFO)
	var fee_txt := " They'll pay an appearance fee of %s." % U.money(float(o.fee) * Settings.income_mult()) if float(o.fee) > 0 else ""
	v.add_child(UI.label("%s want a chat with %s.%s How do you play it?" % [o.name, Game.band_name, fee_txt], "Body", null, true))
	var m: Control
	for t in MediaData.TONES:
		var b := _choice_button("%s  —  %s" % [t.name, t.desc], t.icon, "", func(): _choose(main, m, ev, t.id, done))
		v.add_child(b)
	v.add_child(_choice_button("Decline politely", "x", "Ghost", func(): _choose(main, m, ev, "decline", done)))
	m = main.open_modal(v, 720)


# ------------------------------------------------------------- complaint

static func _complaint_reason(m: Dictionary) -> String:
	if int(m.inst) < Data.expected_inst_tier(m.skill) - 1:
		return "My %s is falling apart, boss. I'm embarrassed to play it on stage." % Data.instrument(m.role, int(m.inst)).name
	if Game.genre_match(m) == 0 and Data.genre_distance(m.genre, Game.genre) == 2:
		return "I didn't join a band to play %s. I'm a %s person, through and through." % [Data.genre_name(Game.genre), Data.genre_name(m.genre)]
	if float(Game.flags.get("fatigue", 0.0)) >= 7.0:
		return "We're knackered. Rehearse, gig, rehearse, gig... when do we get a break?"
	if Game.peak_reach > 300.0 and Game.reach() < Game.peak_reach * 0.6:
		return "The fans are leaving us. I'm starting to think this is going nowhere."
	if int(Data.practice_venue(Game.practice_idx).happy) < 0:
		return "Rehearsing in %s? Really? I need somewhere decent to work." % Data.practice_venue(Game.practice_idx).name
	if int(m.tier) > 0 and Game.fame() < float(m.min_fame):
		return "Do you know who I am? I'm used to much bigger stages than this."
	return "I just feel... undervalued. Like nobody notices what I bring to this band."


static func _complaint(main: Control, ev: Dictionary, done: Callable) -> void:
	var mem: Dictionary = Game.musicians.get(ev.mid, {})
	if mem.is_empty() or mem.status != "band":
		done.call_deferred()
		return
	var v := _frame("Can I have a word?", "%s isn't happy" % mem.name, "frown", Color("#ff9f43"))
	var h := UI.hbox(16)
	h.add_child(Portrait.make(mem.look, 100))
	var qv := UI.vbox(8)
	qv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	qv.add_child(UI.label("“%s”" % _complaint_reason(mem), "Title", null, true))
	qv.add_child(MusicianView.happy_block(mem, 280))
	h.add_child(qv)
	v.add_child(h)
	var m: Control
	v.add_child(BandPage.treat_options(main, mem.id, func(choice): _choose(main, m, ev, choice, done)))
	v.add_child(UI.label("OR", "Caps"))
	v.add_child(_choice_button("Have a heart-to-heart (free, might not work)", "smile", "", func(): _choose(main, m, ev, {"kind": "talk"}, done)))
	v.add_child(_choice_button("Tell them to stop moaning", "meh", "", func(): _choose(main, m, ev, {"kind": "ignore"}, done)))
	v.add_child(_choice_button("Let them go", "userX", "Ghost", func(): _choose(main, m, ev, {"kind": "release"}, done)))
	m = main.open_modal(v, 760)


# ------------------------------------------------------------ member left

static func _left(main: Control, ev: Dictionary, done: Callable) -> void:
	var gone: Dictionary = Game.musicians.get(ev.mid, {})
	var role_name: String = InstrumentData.ROLE_NAMES[ev.role]
	var v := _frame("Line-up change", "%s has left the band" % gone.get("name", "Someone"), "userX", UITheme.BAD)
	if not gone.is_empty():
		var h := UI.hbox(14)
		h.add_child(Portrait.make(gone.look, 72))
		h.add_child(UI.label("They've packed up their gear and gone. You need a new %s, and quickly." % role_name.to_lower(), "Body", null, true))
		h.get_child(1).size_flags_horizontal = Control.SIZE_EXPAND_FILL
		v.add_child(h)
	var m: Control
	if ev.options.is_empty():
		v.add_child(UI.label("Nobody suitable is available right now.", "BodyMuted"))
	else:
		v.add_child(UI.label("AVAILABLE NOW", "Caps"))
	for id in ev.options:
		var c: Dictionary = Game.musicians[id]
		var val := Game.value_of(c)
		var row := UI.panel("CardFlat")
		var rh := UI.hbox(12)
		rh.add_child(Portrait.make(c.look, 56))
		var iv := UI.vbox(2)
		iv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		iv.add_child(UI.label(c.name, "Strong"))
		iv.add_child(UI.label("Age %d · %s / %s · %s" % [int(c.age), Data.genre_name(c.genre), Data.genre_name(c.get("genre2", c.genre)), Game.temperament_word(int(c.ease))], "Small"))
		rh.add_child(iv)
		rh.add_child(MusicianView.skill_block(c, 200))
		var b := UI.button("FREE" if val == 0 else U.money(val), "handshake", "Gold", func(): _choose(main, m, ev, c.id, done))
		b.disabled = val > Game.funds
		rh.add_child(b)
		row.add_child(rh)
		v.add_child(row)
	v.add_child(_choice_button("I'll find someone myself (Talent page)", "search", "Ghost", func(): _choose(main, m, ev, "none", done)))
	m = main.open_modal(v, 820)


# -------------------------------------------------------------- releases

static func _producer(main: Control, ev: Dictionary, done: Callable) -> void:
	var v := _frame("The phone rings...", "A producer wants to record a single", "vinyl", UITheme.GOLD)
	v.add_child(UI.label("Word's got around about %s. Choose who'll produce your single. Better producers cost more, but even a good one can have an off day." % Game.band_name, "Body", null, true))
	if Game.demos.is_empty():
		v.add_child(UI.icon_label("alert", "You haven't got any demo songs! You'd have to write something in the studio, and it won't be great.", UITheme.BAD, "Small", 16, true))
	else:
		v.add_child(UI.icon_label("pen", "You'll record your best demo (%s). %d demo songs in the bank." % [Game.demo_word(Game.best_demo()), Game.demos.size()], UITheme.MUTED, "Small", 16, true))
	var m: Control
	for idx in ev.options:
		var p: Dictionary = MediaData.PRODUCERS[int(idx)]
		var row := UI.panel("CardFlat")
		var h := UI.hbox(12)
		var iv := UI.vbox(2)
		iv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		iv.add_child(UI.label(p.name, "Strong"))
		iv.add_child(UI.label(p.desc, "Small", null, true))
		var rep := UI.hbox(6)
		rep.add_child(UI.label("REPUTATION", "Caps"))
		rep.add_child(UI.stars(clampf(float(p.quality) / 20.0, 0.5, 5.0), 14))
		iv.add_child(rep)
		h.add_child(iv)
		var b := UI.button(U.money(p.fee), "funds", "Gold", func(): _choose(main, m, ev, int(idx), done))
		b.disabled = float(p.fee) > Game.funds
		b.custom_minimum_size.x = 130
		h.add_child(b)
		row.add_child(h)
		v.add_child(row)
	v.add_child(_choice_button("Not right now", "x", "Ghost", func(): _choose(main, m, ev, -1, done)))
	m = main.open_modal(v, 760)


## What each feel means for the player (Charts.FEELS order).
const FEEL_DESC := [
	"Catchy and broad. Climbs fast and grabs new listeners, but fades quickly, and some of your fans will call it a sell-out. Every so often one of these comes back as a massive hit.",
	"Accessible, with your genre underneath. Wins new listeners with less risk to your fans (they might even love it). Rises a little slower and lasts a little longer.",
	"Bang on genre. Pleases your fans and finds some new listeners, nothing wild. A slow riser with staying power. Could even sneak into the top 10.",
	"Pushes your genre's sound. Genre lovers will applaud; outsiders might not get it. A steady climber that hangs around for a while.",
	"All in. Your fans will love it, people outside the genre won't. Takes a while to climb, but if it catches it could be huge, and stay for ages.",
]


static func _name_release(main: Control, ev: Dictionary, done: Callable) -> void:
	var album: bool = ev.kind == "album"
	var v := _frame("Name your %s" % ("album" if album else "single"), "How does it sound?", "disc" if album else "vinyl", UITheme.GOLD)
	v.add_child(UI.label("Recorded with %s. Set the feel, then pick a title that fits your %s sound, or write your own." % [ev.producer, Data.genre_name(Game.genre)], "Body", null, true))
	if not ev.has("feel"):
		ev.feel = 2
	# The feel slider: Poppy .. Dial Up To 11.
	var fc := UI.panel("CardFlat")
	var fv := UI.vbox(8)
	fc.add_child(fv)
	var fh := UI.hbox(8)
	fh.add_child(UI.label("THE FEEL", "Caps", UITheme.GOLD))
	fh.add_child(UI.spacer())
	var fname := UI.label("", "H3", UITheme.GOLD)
	fh.add_child(fname)
	fv.add_child(fh)
	var slider := HSlider.new()
	slider.min_value = 0
	slider.max_value = Charts.FEELS.size() - 1
	slider.step = 1
	slider.tick_count = Charts.FEELS.size()
	slider.ticks_on_borders = true
	slider.value = int(ev.feel)
	slider.custom_minimum_size.y = 36
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fv.add_child(slider)
	var ends := UI.hbox(8)
	ends.add_child(UI.label("POPPY", "Caps"))
	ends.add_child(UI.spacer())
	ends.add_child(UI.label("UP TO 11", "Caps"))
	fv.add_child(ends)
	var fdesc := UI.label("", "Small", UITheme.TEXT, true)
	fdesc.custom_minimum_size.y = fdesc.get_line_height() * 3 + 4
	fv.add_child(fdesc)
	var show_feel := func(val: float):
		ev.feel = int(val)
		fname.text = Charts.FEELS[int(val)].name
		fdesc.text = FEEL_DESC[int(val)]
	show_feel.call(slider.value)
	slider.value_changed.connect(show_feel)
	v.add_child(fc)
	var m: Control
	var grid := GridContainer.new()
	grid.columns = 1
	grid.add_theme_constant_override("v_separation", 8)
	for t in ev.options:
		var b := UI.button("'%s'" % t, "note", "", func(): _choose(main, m, ev, t, done))
		b.add_theme_font_size_override("font_size", 21)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.custom_minimum_size.y = 54
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(b)
	v.add_child(grid)
	var row := UI.hbox(10)
	var le := LineEdit.new()
	le.placeholder_text = "Your own title..."
	le.max_length = 48
	le.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	le.custom_minimum_size.y = 50
	row.add_child(le)
	# Your own title can't be one that's already in the charts or released.
	var submit := func(t: String):
		t = t.strip_edges()
		if t == "":
			return
		if Charts.titles_in_use().has(t.to_lower()):
			main.show_toast("'%s' is already taken. Try something else." % t, "bad")
			return
		_choose(main, m, ev, t, done)
	var go := UI.button("RELEASE IT", "check", "Gold", func(): submit.call(le.text))
	row.add_child(go)
	le.text_submitted.connect(submit)
	v.add_child(row)
	m = main.open_modal(v, 720)


static func _label(main: Control, ev: Dictionary, done: Callable) -> void:
	var l: Dictionary = MediaData.LABELS[int(ev.label)]
	var v := _frame("Record deal", "%s want an album" % l.name, "disc", UITheme.GOLD)
	v.add_child(UI.label("Two Top 20 hits have got the industry talking. %s are offering a deal to record an album. Album sales are worth five times a single." % l.name, "Body", null, true))
	var g := UI.hbox(30)
	g.add_child(UI.stat("funds", "Advance", U.money(float(l.advance) * Settings.income_mult()), UITheme.GOLD, true))
	var rep := UI.vbox(2)
	rep.add_child(UI.label("LABEL CLOUT", "Caps"))
	rep.add_child(UI.stars(clampf(float(l.quality) / 20.0, 0.5, 5.0), 24))
	g.add_child(rep)
	v.add_child(g)
	var m: Control
	var row := UI.hbox(10)
	row.add_child(UI.button("SIGN THE DEAL", "handshake", "Gold", func(): _choose(main, m, ev, "accept", done)))
	row.add_child(UI.button("Not interested", "x", "Ghost", func(): _choose(main, m, ev, "decline", done)))
	v.add_child(row)
	m = main.open_modal(v, 680)


# ------------------------------------------------------------------ stars

static func _star(main: Control, ev: Dictionary, done: Callable) -> void:
	var s: Dictionary = Game.musicians.get(ev.mid, {})
	if s.is_empty():
		done.call_deferred()
		return
	var cur := Game.member(s.role)
	var v := _frame("A star calls", "%s wants to join!" % s.name, "crown", UITheme.GOLD)
	var h := UI.hbox(16)
	h.add_child(Portrait.make(s.look, 120))
	var iv := UI.vbox(6)
	iv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	iv.add_child(UI.label(s.bio, "Body", null, true))
	iv.add_child(MusicianView.skill_block(s, 300))
	h.add_child(iv)
	v.add_child(h)
	var value := Game.value_of(s)
	var deal := UI.hbox(30)
	deal.add_child(UI.stat("funds", "Their price", U.money(float(ev.price)), UITheme.GOLD, true))
	deal.add_child(UI.stat("trendDown", "Usual value", U.money(value), UITheme.MUTED))
	deal.add_child(UI.stat("sparkle", "Discount", "%d%%" % int(round(float(ev.discount) * 100.0)), UITheme.GOOD))
	v.add_child(deal)
	if not cur.is_empty():
		v.add_child(UI.icon_label("swap", "They'd replace %s (skill %d), who would leave the band." % [cur.name, int(cur.skill)], UITheme.BAD, "Body"))
	var m: Control
	var row := UI.hbox(10)
	var yes := UI.button("WELCOME ABOARD", "crown", "Gold", func(): _choose(main, m, ev, "accept", done))
	yes.disabled = float(ev.price) > Game.funds
	row.add_child(yes)
	row.add_child(UI.button("Thanks, but no", "x", "Ghost", func(): _choose(main, m, ev, "decline", done)))
	v.add_child(row)
	m = main.open_modal(v, 760)


# ----------------------------------------------------------------- random

static func _random(main: Control, ev: Dictionary, done: Callable) -> void:
	var e: Dictionary = Events.event_def(ev)
	var mem: Dictionary = Game.musicians.get(ev.get("mid", ""), {})
	var mname: String = mem.name if not mem.is_empty() else "Someone"
	var fame_ev: bool = ev.type == "fame"
	var v := _frame("Fame game" if fame_ev else "Meanwhile...", e.title, e.icon, UITheme.GOLD)
	if not mem.is_empty():
		var h := UI.hbox(14)
		h.add_child(Portrait.make(mem.look, 64))
		var t := UI.label(Events.event_text(e.text, ev, mname), "Body", null, true)
		t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(t)
		v.add_child(h)
	else:
		v.add_child(UI.label(Events.event_text(e.text, ev, mname), "Body", null, true))
	var m: Control
	for i in e.choices.size():
		var c: Dictionary = e.choices[i]
		var txt: String = c.label.replace("{member}", mname)
		var dis := false
		if c.has("cost_scale"):
			var cost := Events.random_cost(c)
			txt += "  ·  %s" % U.money(cost)
			dis = cost > Game.funds
		if c.has("cash_scale"):
			txt += "  ·  +%s" % U.money(roundf(float(c.cash_scale) * (1.0 + Game.fame() / 10.0) * Settings.income_mult()))
		if c.has("tips"):
			txt += "  ·  free, plus tips"
		v.add_child(_choice_button(txt, "chevR", "Gold" if i == 0 else "", func(): _choose(main, m, ev, i, done), dis))
	m = main.open_modal(v, 680)


static func _media_deal(main: Control, ev: Dictionary, done: Callable) -> void:
	var doc: bool = ev.type == "doc"
	var v := _frame("Documentary offer" if doc else "Concert film offer", ev.title, "film", UITheme.GOLD)
	v.add_child(UI.label("A streaming giant wants to follow %s for a year, warts and all." % Game.band_name if doc else "A film company wants to shoot a full-length concert film of your show at %s." % ev.venue, "Body", null, true))
	v.add_child(UI.stat("funds", "Fee", U.money(float(ev.fee) * Settings.income_mult()), UITheme.GOLD, true))
	var m: Control
	var row := UI.hbox(10)
	row.add_child(UI.button("ROLL CAMERA", "film", "Gold", func(): _choose(main, m, ev, "accept", done)))
	row.add_child(UI.button("No thanks", "x", "Ghost", func(): _choose(main, m, ev, "decline", done)))
	v.add_child(row)
	m = main.open_modal(v, 640)


static func _breakup(main: Control, ev: Dictionary, done: Callable) -> void:
	var v := _frame("Band meeting", "They want to split up", "alert", UITheme.BAD)
	v.add_child(UI.label("The fans are drifting away and the band are miserable. They've called a meeting in the pub, and it's not about the next gig. They think it's time to call it a day.", "Body", null, true))
	var m: Control
	var cost := Events.breakup_beg_cost()
	v.add_child(_choice_button("Beg them to stay (curry and a peace offering: %s)" % U.money(cost), "heart", "Gold", func(): _choose(main, m, ev, "beg", done)))
	v.add_child(_choice_button("Accept it. It's over.", "x", "", func(): _choose(main, m, ev, "accept", done)))
	m = main.open_modal(v, 680)


static func _end(main: Control, ev: Dictionary, done: Callable) -> void:
	var retired: bool = ev.reason == "retired"
	var v := _frame("The end of the road", "The final curtain" if retired else "The band has split", "flag" if retired else "frown", UITheme.GOLD if retired else UITheme.BAD)
	v.add_child(UI.label("The last chord rings out. %s take a bow, wave to the crowd one final time, and walk off into rock history." % Game.band_name if retired else "%s are no more. The van has been sold, the amps are on eBay and the drummer is retraining as a plumber." % Game.band_name, "Body", null, true))
	var m: Control
	v.add_child(UI.button("SEE YOUR LEGACY", "trophy", "Primary", func(): _choose(main, m, ev, "ok", done)))
	m = main.open_modal(v, 640)
