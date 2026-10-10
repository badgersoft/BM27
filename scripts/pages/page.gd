class_name Page
extends VBoxContainer
## Base for HQ pages. build() is called after hq/main are set.

var hq: Control
var main: Control


func _init() -> void:
	add_theme_constant_override("separation", 16)


func build() -> void:
	pass


func title(text: String, subtitle: String = "", icon: String = "") -> void:
	var h := UI.hbox(12)
	if icon != "":
		h.add_child(Icons.make(icon, 34, UITheme.ACCENT))
	var v := UI.vbox(0)
	v.add_child(UI.label(text, "H2"))
	if subtitle != "":
		v.add_child(UI.label(subtitle, "BodyMuted", null, true))
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(v)
	add_child(h)


## Two flexible columns. Returns [left, right]. Stacks on narrow screens.
func columns(ratio_left: float = 1.6) -> Array:
	var wide := get_viewport().get_visible_rect().size.x >= 1100.0
	var box: BoxContainer = HBoxContainer.new() if wide else VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	var l := UI.vbox(16)
	var r := UI.vbox(16)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.size_flags_stretch_ratio = ratio_left
	box.add_child(l)
	box.add_child(r)
	add_child(box)
	return [l, r]


func movement(cur: int, last: int) -> Control:
	if last == 0 and cur > 0:
		return UI.chip("New", UITheme.GOLD, true)
	if cur == 0:
		return UI.chip("Out", UITheme.BAD)
	if cur < last:
		return Icons.make("triUp", 16, UITheme.GOOD)
	if cur > last:
		return Icons.make("triDown", 16, UITheme.BAD)
	return Icons.make("minus", 16, UITheme.MUTED)
