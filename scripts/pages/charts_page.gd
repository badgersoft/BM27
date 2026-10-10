extends Page
## The three charts.

static var tab := "nat"


func build() -> void:
	title("The Charts", "Updated every week. Your releases are highlighted in gold, local bands are tagged.", "chart")
	var tabs := UI.hbox(6)
	for t in [["nat", "NATIONAL TOP 40", "chart"], ["local", "LOCAL TOP 20", "home"], ["album", "ALBUM TOP 20", "disc"]]:
		tabs.add_child(UI.button(t[1], t[2], "SegOn" if tab == t[0] else "Seg", func():
			tab = t[0]
			hq.refresh()))
	add_child(tabs)
	var chart: Array
	var size := 40
	match tab:
		"local":
			chart = Game.chart_local
			size = Charts.LOCAL_SIZE
		"album":
			chart = Game.chart_album
			size = Charts.ALBUM_SIZE
		_:
			chart = Game.chart_nat
	var c: Array = UI.card("", "", "Card")
	var list: VBoxContainer = c[1]
	list.add_theme_constant_override("separation", 2)
	for e in chart.slice(0, size):
		list.add_child(_row(e))
	add_child(c[0])


func _row(e: Dictionary) -> Control:
	var mine := bool(e.player)
	var p := PanelContainer.new()
	var bg := Color(1, 0.77, 0.24, 0.12) if mine else Color(0, 0, 0, 0)
	p.add_theme_stylebox_override("panel", UITheme.box(bg, 8, Color(0, 0, 0, 0), 0, 10, 6))
	var h := UI.hbox(14)
	var pos := UI.label(str(int(e.pos)), "Stat", UITheme.GOLD if mine else UITheme.TEXT)
	pos.custom_minimum_size.x = 44
	pos.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	h.add_child(pos)
	var mv := movement(int(e.pos), int(e.last) if int(e.age) > 0 else 0)
	mv.custom_minimum_size.x = 44
	h.add_child(mv)
	var t := UI.label(e.title, "Strong", UITheme.GOLD if mine else UITheme.TEXT)
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	t.clip_text = true
	t.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	h.add_child(t)
	var a := UI.label(e.artist, "Body", UITheme.GOLD if mine else UITheme.MUTED)
	a.custom_minimum_size.x = 260
	a.clip_text = true
	a.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	h.add_child(a)
	if bool(e.local) and not mine and tab != "local":
		h.add_child(UI.chip("Local", UITheme.INFO))
	var wk := UI.label("%dw" % (int(e.age) + 1), "Small")
	wk.custom_minimum_size.x = 36
	h.add_child(wk)
	p.add_child(h)
	return p
