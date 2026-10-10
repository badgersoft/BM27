extends Control
## Root of the game: owns the screen stack, the modal layer and toasts.

const SCREENS := {
	"menu": preload("res://scripts/screens/main_menu.gd"),
	"info": preload("res://scripts/screens/info_screen.gd"),
	"settings": preload("res://scripts/screens/settings_screen.gd"),
	"hall": preload("res://scripts/screens/hall_of_fame.gd"),
	"managers": preload("res://scripts/screens/manager_select.gd"),
	"practice_setup": preload("res://scripts/screens/practice_select.gd"),
	"recruit": preload("res://scripts/screens/recruit_screen.gd"),
	"naming": preload("res://scripts/screens/band_name_screen.gd"),
	"hq": preload("res://scripts/screens/hq_screen.gd"),
	"end": preload("res://scripts/screens/end_screen.gd"),
}

var screen_layer: Control
var modal_layer: Control
var toast_box: VBoxContainer
var current: Control
var current_name := ""
var _modals: Array = []


func _ready() -> void:
	theme = UITheme.get_theme()
	var bg := ColorRect.new()
	bg.color = UITheme.BG
	add_child(UI.full_rect(bg))
	screen_layer = UI.full_rect(Control.new())
	screen_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(screen_layer)
	modal_layer = UI.full_rect(Control.new())
	modal_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(modal_layer)
	toast_box = VBoxContainer.new()
	toast_box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	toast_box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	toast_box.grow_vertical = Control.GROW_DIRECTION_BEGIN
	toast_box.offset_bottom = -96
	toast_box.alignment = BoxContainer.ALIGNMENT_END
	toast_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(toast_box)
	Game.toast.connect(show_toast)
	get_tree().root.min_size = Vector2i(960, 540)
	get_tree().set_auto_accept_quit(false)
	if not AutoTest.maybe_run(self):
		show_screen("menu")


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		Game.quit_to_menu()
		get_tree().quit()
	elif what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_on_back()
	elif what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		# Phones can kill a backgrounded app at any time: save while we can.
		if Game.active and Settings.autosave:
			Game.save_game()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back()


## Android back button / Escape: close a dismissable modal, else go back.
func _on_back() -> void:
	if not _modals.is_empty():
		var top: Control = _modals.back()
		if top.get_meta("dismissable", false):
			close_modal(top)
		return
	if current and current.has_method("on_back"):
		current.on_back()


func show_screen(name: String, args: Dictionary = {}) -> void:
	close_all_modals()
	if current:
		current.queue_free()
	var s: Control = SCREENS[name].new()
	s.set("main", self)
	s.set("args", args)
	current = s
	current_name = name
	screen_layer.add_child(UI.full_rect(s))


# ------------------------------------------------------------------ modals

## Shows content in a centred, scrollable modal card. Returns the modal node
## (pass it to close_modal).
func open_modal(content: Control, width: float = 640.0, dismissable: bool = false, variation: String = "Modal") -> Control:
	var wrap := UI.full_rect(Control.new())
	wrap.set_meta("dismissable", dismissable)
	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.02, 0.03, 0.78)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	wrap.add_child(UI.full_rect(dim))
	if dismissable:
		dim.gui_input.connect(func(e):
			if (e is InputEventMouseButton and e.pressed) or (e is InputEventScreenTouch and e.pressed):
				close_modal(wrap))
	var center := UI.full_rect(CenterContainer.new())
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.add_child(center)
	var vp := get_viewport_rect().size
	var w := minf(width, vp.x - 32.0)
	var panel := UI.panel(variation)
	var pad := 56.0 if variation == "Modal" else 68.0
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content.custom_minimum_size.x = w - pad
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(content)
	panel.add_child(scroll)
	panel.custom_minimum_size.x = w
	center.add_child(panel)
	var fit := func():
		if not is_instance_valid(scroll):
			return
		var max_h := get_viewport_rect().size.y - 72.0
		scroll.custom_minimum_size.y = minf(content.get_combined_minimum_size().y, max_h)
	content.minimum_size_changed.connect(fit)
	fit.call_deferred()
	modal_layer.add_child(wrap)
	_modals.append(wrap)
	if not Settings.reduce_effects:
		panel.pivot_offset = panel.size * 0.5
		panel.modulate.a = 0.0
		var tw := create_tween()
		tw.tween_property(panel, "modulate:a", 1.0, 0.12)
	return wrap


## Closes a modal. Passing null closes the top one: modal buttons capture
## their modal variable before it's assigned (GDScript lambdas capture by
## value), and only the top modal can receive input anyway.
func close_modal(wrap: Control) -> void:
	if not is_instance_valid(wrap):
		if _modals.is_empty():
			return
		wrap = _modals.back()
	_modals.erase(wrap)
	wrap.queue_free()


func close_all_modals() -> void:
	for m in _modals:
		if is_instance_valid(m):
			m.queue_free()
	_modals.clear()


func has_modal() -> bool:
	return not _modals.is_empty()


## Simple confirm dialog.
func confirm(title: String, text: String, ok_text: String, on_ok: Callable, icon: String = "alert", ok_variation: String = "Primary") -> void:
	var v := UI.vbox(16)
	var h := UI.hbox(12)
	h.add_child(Icons.make(icon, 30, UITheme.GOLD))
	h.add_child(UI.label(title, "H2"))
	v.add_child(h)
	v.add_child(UI.rich(text))
	var row := UI.hbox(12)
	row.add_child(UI.spacer())
	var m: Control
	row.add_child(UI.button("Cancel", "x", "", func(): close_modal(m)))
	var ok := UI.button(ok_text, "check", ok_variation, func():
		close_modal(m)
		on_ok.call())
	if ok_variation == "Primary":
		ok.add_theme_font_size_override("font_size", 24)
	row.add_child(ok)
	v.add_child(row)
	m = open_modal(v, 560, true)


func show_toast(text: String, kind: String = "info") -> void:
	var p := PanelContainer.new()
	var col := UI.kind_color(kind)
	p.add_theme_stylebox_override("panel", UITheme.box(Color("#24242c"), 10, col, 1, 16, 10))
	var h := UI.hbox(10)
	h.add_child(Icons.make("alert" if kind == "bad" else "check" if kind == "good" else "info", 18, col))
	h.add_child(UI.label(text, "Body"))
	p.add_child(h)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	toast_box.add_child(p)
	var tw := create_tween()
	tw.tween_interval(2.4)
	tw.tween_property(p, "modulate:a", 0.0, 0.4)
	tw.tween_callback(p.queue_free)
