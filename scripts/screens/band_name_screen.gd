extends Screen
## Step 4: pick a genre and a name.

var genre := ""
var names: Array = []
var chosen := ""
var genre_grid: GridContainer
var names_box: GridContainer
var name_edit: LineEdit
var preview: Label


func _ready() -> void:
	genre = Game.genre
	names = Data.band_name_options(genre)
	chosen = names[0]
	var v := page_root(36)
	var top := UI.hbox(16)
	top.add_child(UI.button("BACK", "chevL", "Ghost", func(): go("recruit")))
	top.add_child(UI.spacer())
	top.add_child(preload("res://scripts/screens/manager_select.gd")._steps(3))
	v.add_child(top)
	var hr := UI.hbox(20)
	var hd := header("Name The Band", "Pick the sound you're chasing, then a name to go with it. Musicians who love your genre play happier.", "Step 4 of 4 · Genre & name")
	hd.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hr.add_child(hd)
	var form := UI.button("FORM THE BAND", "flag", "Primary", _form)
	form.custom_minimum_size.y = 64
	form.size_flags_vertical = Control.SIZE_SHRINK_END
	hr.add_child(form)
	v.add_child(hr)
	var body := UI.vbox(18)
	var gc: Array = UI.card("Genre", "note", "Card", UITheme.GOLD)
	genre_grid = GridContainer.new()
	genre_grid.columns = 6 if get_viewport_rect().size.x >= 1200 else 4
	genre_grid.add_theme_constant_override("h_separation", 8)
	genre_grid.add_theme_constant_override("v_separation", 8)
	gc[1].add_child(genre_grid)
	body.add_child(gc[0])
	var nc: Array = UI.card("Band name", "flag", "Card", UITheme.GOLD)
	names_box = GridContainer.new()
	names_box.columns = 2
	names_box.add_theme_constant_override("h_separation", 10)
	names_box.add_theme_constant_override("v_separation", 10)
	nc[1].add_child(names_box)
	var er := UI.hbox(10)
	name_edit = LineEdit.new()
	name_edit.placeholder_text = "...or type your own"
	name_edit.max_length = 32
	name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_edit.custom_minimum_size.y = 48
	name_edit.text_changed.connect(func(t):
		if t.strip_edges() != "":
			chosen = t.strip_edges()
		_update_preview())
	er.add_child(name_edit)
	er.add_child(UI.button("NEW IDEAS", "refresh", "", func():
		names = Data.band_name_options(genre)
		chosen = names[0]
		name_edit.text = ""
		_build_names()))
	nc[1].add_child(er)
	body.add_child(nc[0])
	var fr := UI.hbox(16)
	var pv := UI.vbox(0)
	pv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pv.add_child(UI.label("INTRODUCING...", "Caps", UITheme.ACCENT))
	preview = UI.label("", "H2")
	pv.add_child(preview)
	fr.add_child(pv)
	body.add_child(fr)
	v.add_child(UI.scroller(body))
	_build_genres()
	_build_names()


func _build_genres() -> void:
	UI.clear(genre_grid)
	var mg: Dictionary = Game.manager()
	for g in Data.genres:
		var fans := Game.members().filter(func(m): return m.genre == g.id).size()
		var txt: String = g.name
		var b := UI.button(txt, "star" if mg.genre == g.id else "note", "SegOn" if g.id == genre else "Seg", _set_genre.bind(g.id))
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var tip: String = g.blurb
		if mg.genre == g.id:
			tip += "\n%s's favourite genre (+performance)." % mg.short
		if fans > 0:
			tip += "\n%d of your band love this." % fans
			b.text = "%s  ♥%d" % [txt, fans]
		b.tooltip_text = tip
		if g.id != genre:
			b.add_theme_color_override("icon_normal_color", Color(g.color))
		genre_grid.add_child(b)


func _build_names() -> void:
	UI.clear(names_box)
	for n in names:
		var b := UI.button(n, "", "SegOn" if n == chosen and name_edit.text.strip_edges() == "" else "Seg", func():
			chosen = n
			name_edit.text = ""
			_build_names())
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.custom_minimum_size.y = 52
		b.add_theme_font_size_override("font_size", 20)
		names_box.add_child(b)
	_update_preview()


func _update_preview() -> void:
	preview.text = chosen


func _set_genre(g: String) -> void:
	genre = g
	names = Data.band_name_options(genre)
	if name_edit.text.strip_edges() == "":
		chosen = names[0]
	_build_genres()
	_build_names()


func _form() -> void:
	Game.form_band(chosen, genre)
	go("hq", {"welcome": true})


func on_back() -> void:
	go("recruit")
