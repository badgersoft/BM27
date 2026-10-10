extends Screen
## The manager's office: stat bar, navigation rail, pages and NEXT WEEK.

const PAGES := {
	"home": ["HQ", "home", preload("res://scripts/pages/home_page.gd")],
	"band": ["BAND", "users", preload("res://scripts/pages/band_page.gd")],
	"fans": ["FANS", "heart", preload("res://scripts/pages/fans_page.gd")],
	"talent": ["TALENT", "search", preload("res://scripts/pages/talent_page.gd")],
	"gigs": ["GIGS", "ticket", preload("res://scripts/pages/gigs_page.gd")],
	"rehearsal": ["REHEARSAL", "venue", preload("res://scripts/pages/rehearsal_page.gd")],
	"charts": ["CHARTS", "chart", preload("res://scripts/pages/charts_page.gd")],
	"releases": ["RELEASES", "disc", preload("res://scripts/pages/releases_page.gd")],
	"scene": ["SCENE", "flame", preload("res://scripts/pages/scene_page.gd")],
	"inbox": ["INBOX", "mail", preload("res://scripts/pages/inbox_page.gd")],
}
const ORDER := ["home", "band", "fans", "talent", "gigs", "rehearsal", "charts", "releases", "scene", "inbox"]

var top_bar: PanelContainer
var nav: VBoxContainer
var page_scroll: ScrollContainer
var page: Control
var page_name := "home"
var next_btn: Button
var next_sub: Label
var _dirty := false
var _processing := false


func _ready() -> void:
	var root := UI.full_rect(VBoxContainer.new())
	root.add_theme_constant_override("separation", 0)
	add_child(root)
	top_bar = UI.panel("Bar")
	root.add_child(top_bar)
	var body := UI.hbox(0)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(body)
	var rail := PanelContainer.new()
	rail.add_theme_stylebox_override("panel", UITheme.box(UITheme.BG_2, 0, Color(0, 0, 0, 0), 0, 8, 10))
	nav = UI.vbox(4)
	rail.add_child(UI.scroller(nav))
	rail.custom_minimum_size.x = 96
	body.add_child(rail)
	page_scroll = ScrollContainer.new()
	page_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	page_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(page_scroll)
	# Floating NEXT WEEK button.
	var nb := UI.vbox(2)
	nb.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	nb.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	nb.grow_vertical = Control.GROW_DIRECTION_BEGIN
	nb.offset_right = -24
	nb.offset_bottom = -20
	next_btn = UI.button("NEXT WEEK", "next", "Primary", _on_next)
	next_btn.custom_minimum_size = Vector2(250, 66)
	next_btn.add_theme_font_size_override("font_size", 34)
	var shadow := UITheme.box(UITheme.ACCENT, 14, Color(0, 0, 0, 0), 0, 26, 12)
	shadow.shadow_color = Color(0, 0, 0, 0.6)
	shadow.shadow_size = 14
	next_btn.add_theme_stylebox_override("normal", shadow)
	next_sub = UI.label("", "Caps", UITheme.MUTED)
	next_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var pill := PanelContainer.new()
	pill.add_theme_stylebox_override("panel", UITheme.box(Color(0.06, 0.06, 0.08, 0.92), 8, UITheme.LINE, 1, 10, 3))
	pill.add_child(next_sub)
	pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	nb.add_child(pill)
	nb.add_child(next_btn)
	add_child(nb)
	Game.changed.connect(_mark_dirty)
	refresh()
	if args.get("welcome", false):
		_welcome()
	elif Game.has_events():
		process_events()


func _exit_tree() -> void:
	if Game.changed.is_connected(_mark_dirty):
		Game.changed.disconnect(_mark_dirty)


func _mark_dirty() -> void:
	if _dirty:
		return
	_dirty = true
	refresh.call_deferred()


func refresh() -> void:
	_dirty = false
	if not is_inside_tree():
		return
	_build_top()
	_build_nav()
	_build_page()
	_update_next()


func open_page(name: String) -> void:
	page_name = name
	page_scroll.scroll_vertical = 0
	refresh()


# ----------------------------------------------------------------- top bar

func _build_top() -> void:
	UI.clear(top_bar)
	# Phones at big UI sizes get a compact bar: the date moves under the name.
	var width := get_viewport_rect().size.x
	var narrow := width < 1180
	var h := UI.hbox(12 if narrow else 16)
	top_bar.add_child(h)
	var badge := PanelContainer.new()
	badge.add_theme_stylebox_override("panel", UITheme.box(UITheme.ACCENT, 8, Color(0, 0, 0, 0), 0, 8, 0))
	var bl := UI.label("BM27", "H3", Color("#140808"))
	badge.add_child(bl)
	badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	h.add_child(badge)
	var idv := UI.vbox(0)
	var bn := UI.label(Game.band_name, "H3")
	bn.clip_text = true
	bn.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	bn.custom_minimum_size.x = 150
	bn.tooltip_text = Game.band_name
	bn.mouse_filter = Control.MOUSE_FILTER_PASS
	idv.add_child(bn)
	var nr := UI.hbox(8)
	nr.add_child(UI.genre_chip(Game.genre))
	var sub := "%s · Managed by %s" % [Game.reach_label(), Game.manager().short]
	if narrow:
		sub = "%s · %s" % [Game.date_label(), Game.reach_label()]
	if Game.is_final_tour():
		sub = "FINAL TOUR · %d weeks left" % Game.final_tour_weeks_left()
	var sl := UI.label(sub, "Small", UITheme.GOLD if Game.is_final_tour() else UITheme.MUTED)
	sl.clip_text = true
	sl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	sl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sl.custom_minimum_size.x = 60
	nr.add_child(sl)
	idv.add_child(nr)
	idv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(idv)
	h.add_child(_stat("funds", "Funds", U.money(Game.funds), UITheme.GOLD))
	h.add_child(_stat("heart", "Fans", U.num(Game.true_fans), UITheme.ACCENT))
	h.add_child(_stat("headphones", "Listeners", U.num(Game.listeners), UITheme.INFO))
	var fame := Game.fame()
	var fv := UI.vbox(2)
	var fs := _stat("star", "Fame" if narrow else "Fame · " + Game.fame_label(), str(int(fame)), UITheme.GOLD)
	fs.tooltip_text = Game.fame_label()
	fv.add_child(fs)
	fv.add_child(UI.meter(fame / 100.0, UITheme.GOLD, 4.0))
	fv.custom_minimum_size.x = 90 if narrow else 130
	h.add_child(fv)
	if width >= 1240:
		h.add_child(_stat("hourglass", "Together", U.duration(Game.band_age()), UITheme.TEXT))
	if not narrow:
		h.add_child(_stat("calendar", "Date", Game.date_label(), UITheme.TEXT))
	var mb := UI.button("", "menu", "Ghost", _pause_menu)
	mb.tooltip_text = "Menu"
	mb.custom_minimum_size = Vector2(48, 48)
	h.add_child(mb)


func _stat(icon: String, cap: String, val: String, col: Color) -> HBoxContainer:
	var s := UI.hbox(8)
	s.add_child(Icons.make(icon, 20, col))
	var v := UI.vbox(-6)
	v.add_child(UI.label(cap.to_upper(), "Caps"))
	var l := UI.label(val, "Stat", col)
	l.add_theme_font_size_override("font_size", 25)
	v.add_child(l)
	s.add_child(v)
	return s


func _build_nav() -> void:
	UI.clear(nav)
	for key in ORDER:
		var pd: Array = PAGES[key]
		var b := UI.button(pd[0], pd[1], "NavActive" if key == page_name else "Nav", open_page.bind(key))
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		b.custom_minimum_size = Vector2(80, 60)
		b.expand_icon = false
		nav.add_child(b)


func _build_page() -> void:
	var keep := page_scroll.scroll_vertical
	if page:
		page_scroll.remove_child(page)
		page.queue_free()
	page = PAGES[page_name][2].new()
	page.set("hq", self)
	page.set("main", main)
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var m := UI.margin(page, 24, 20, 24, 110)
	m.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_scroll.add_child(m)
	page.call("build")
	page = m
	(func(): page_scroll.scroll_vertical = keep).call_deferred()


func _update_next() -> void:
	var d := U.date(Game.week)
	next_btn.disabled = Game.game_over
	if d.week_of_month == 4 and Game.gig_booked >= 0:
		next_sub.text = "GIG NIGHT AT THE END OF THIS WEEK"
		next_sub.add_theme_color_override("font_color", UITheme.GOLD)
	elif d.week_of_month == 4 and not Game.gig_offers.is_empty() and not Game.gig_skipped:
		next_sub.text = "NO GIG BOOKED THIS MONTH!"
		next_sub.add_theme_color_override("font_color", UITheme.BAD)
	else:
		next_sub.text = "%s · WEEK %d OF 4" % [d.month.to_upper(), d.week_of_month]
		next_sub.add_theme_color_override("font_color", UITheme.MUTED)


# -------------------------------------------------------------- next week

func _on_next() -> void:
	if Game.has_events():
		process_events()
		return
	var d := U.date(Game.week)
	var needs_gig := Game.gig_booked < 0 and not Game.gig_offers.is_empty() and not Game.gig_skipped
	if needs_gig and d.week_of_month == 4:
		main.confirm("No gig booked!", "This is the last week of the month and you haven't booked a gig. Skipping a month will cost you some fans.", "SKIP THE GIG", func():
			Game.skip_gig_month()
			_advance(), "ticket")
		return
	if needs_gig and Settings.confirm_next_week:
		main.confirm("Carry on?", "You haven't booked this month's gig yet. There's still time.", "NEXT WEEK", _advance, "ticket")
		return
	if not Game.band_complete():
		main.confirm("Band incomplete", "You're missing a member. Gigs will sound terrible until you hire one on the Talent page.", "NEXT WEEK ANYWAY", _advance, "alert")
		return
	_advance()


func _advance() -> void:
	Game.advance_week()
	process_events()


func process_events() -> void:
	if _processing:
		return
	_processing = true
	_next_event()


func _next_event() -> void:
	if Game.game_over:
		_processing = false
		go("end")
		return
	if not Game.has_events():
		_processing = false
		refresh()
		return
	var ev := Game.pop_event()
	EventView.present(main, ev, _next_event)


# ------------------------------------------------------------------ menus

func _welcome() -> void:
	var v := UI.vbox(16)
	v.add_child(UI.label("THE BAND IS BORN", "Caps", UITheme.ACCENT))
	v.add_child(UI.label(Game.band_name, "H1"))
	v.add_child(UI.rich("Welcome to HQ. Each week, pick what the band focuses on, then press [b]NEXT WEEK[/b].\n\n[color=#ffc53d]•[/color] Book a gig from the [b]Gigs[/b] page every month.\n[color=#ffc53d]•[/color] Keep an eye on contentment on the [b]Band[/b] page.\n[color=#ffc53d]•[/color] Busk or promote early on to find your first listeners.\n\nYour mum has already bought a T-shirt. Let's get famous."))
	var m: Control
	var b := UI.button("LET'S GO", "play", "Primary", func(): main.close_modal(m))
	v.add_child(b)
	m = main.open_modal(v, 620, true)


func _pause_menu() -> void:
	var v := UI.vbox(12)
	v.add_child(UI.label("PAUSED", "H2"))
	var m: Control
	v.add_child(UI.button("RESUME", "play", "Gold", func(): main.close_modal(m)))
	v.add_child(UI.button("SAVE GAME", "save", "", func():
		Game.save_game()
		main.show_toast("Game saved.", "good")
		main.close_modal(m)))
	v.add_child(UI.button("HOW TO PLAY", "info", "", func():
		main.close_modal(m)
		_how_to_play()))
	v.add_child(UI.button("SAVE & QUIT TO MENU", "exit", "", func():
		Game.quit_to_menu()
		go("menu")))
	m = main.open_modal(v, 420, true)


func _how_to_play() -> void:
	var v := UI.vbox(12)
	v.add_child(UI.label("Quick Tips", "H2"))
	for s in preload("res://scripts/screens/info_screen.gd").SECTIONS.slice(1, 8):
		v.add_child(UI.icon_label(s[0], s[1], UITheme.GOLD, "Strong", 18))
		v.add_child(UI.label(s[2], "BodyMuted", null, true))
	var m: Control
	v.add_child(UI.button("GOT IT", "check", "Gold", func(): main.close_modal(m)))
	m = main.open_modal(v, 700, true)


func on_back() -> void:
	if page_name != "home":
		open_page("home")
	else:
		_pause_menu()
