extends Screen
## Settings: difficulty, UI scale, popups, effects, save data.

var body: VBoxContainer


func _ready() -> void:
	add_child(UI.full_rect(StageBackdrop.new()))
	var v := page_root(48)
	var top := UI.hbox(16)
	top.add_child(UI.button("BACK", "chevL", "Ghost", func(): go("menu")))
	v.add_child(top)
	v.add_child(header("Settings", "Tweak the mix.", "Settings"))
	body = UI.vbox(14)
	var wrap := CenterContainer.new()
	wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.custom_minimum_size.x = minf(820.0, get_viewport_rect().size.x - 96.0)
	wrap.add_child(body)
	v.add_child(UI.scroller(wrap))
	_build()


func _build() -> void:
	UI.clear(body)
	body.add_child(_row("Difficulty", "Chilled pays better and fans are more forgiving. Hardcore is for veterans.", "target",
		_segmented(Settings.DIFFICULTY_NAMES, Settings.difficulty, func(i):
			Settings.difficulty = i
			_save())))
	body.add_child(_row("Interface size", "Make everything bigger or smaller. Handy on phones and tablets.", "eye",
		_segmented(["S", "M", "L", "XL"], Settings.ui_scale_idx, func(i):
			Settings.ui_scale_idx = i
			_save())))
	body.add_child(_row("Weekly report pop-up", "Show a summary every week as well as on the HQ page.", "mail",
		_toggle(Settings.weekly_popup, func(on):
			Settings.weekly_popup = on
			_save())))
	body.add_child(_row("Confirm next week", "Ask before advancing if you haven't booked a gig.", "check",
		_toggle(Settings.confirm_next_week, func(on):
			Settings.confirm_next_week = on
			_save())))
	body.add_child(_row("Reduce effects", "Turn off fades and transitions.", "sparkle",
		_toggle(Settings.reduce_effects, func(on):
			Settings.reduce_effects = on
			_save())))
	body.add_child(_row("Autosave", "Save automatically every week.", "save",
		_toggle(Settings.autosave, func(on):
			Settings.autosave = on
			_save())))
	var danger := UI.button("DELETE SAVED GAME", "trash", "", func():
		main.confirm("Delete your save?", "Your band in progress will be gone for good. The Hall of Fame is kept.", "DELETE", func():
			Game.delete_save()
			main.show_toast("Saved game deleted.", "good")
			_build()))
	danger.disabled = not Game.has_save()
	body.add_child(_row("Saved game", "Wipe your current career.", "trash", danger))


func _save() -> void:
	Settings.save_settings()
	_build()


func _row(title: String, desc: String, icon: String, control: Control) -> PanelContainer:
	var p := UI.panel("Card")
	var h := UI.hbox(16)
	h.add_child(Icons.make(icon, 26, UITheme.GOLD))
	var v := UI.vbox(2)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_child(UI.label(title, "Title"))
	v.add_child(UI.label(desc, "BodyMuted", null, true))
	h.add_child(v)
	control.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	h.add_child(control)
	p.add_child(h)
	return p


func _segmented(options: Array, selected: int, cb: Callable) -> HBoxContainer:
	var h := UI.hbox(6)
	for i in options.size():
		var b := UI.button(options[i], "", "SegOn" if i == selected else "Seg", cb.bind(i))
		b.custom_minimum_size.x = 64
		h.add_child(b)
	return h


func _toggle(on: bool, cb: Callable) -> HBoxContainer:
	return _segmented(["OFF", "ON"], 1 if on else 0, func(i): cb.call(i == 1))


func on_back() -> void:
	go("menu")
