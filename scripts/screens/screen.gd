class_name Screen
extends Control
## Base for full screens. main is the root (scripts/main.gd).

var main: Control
var args: Dictionary = {}


func go(name: String, a: Dictionary = {}) -> void:
	main.show_screen(name, a)


## Standard screen header: step pill, big title, subtitle. Returns the VBox.
func header(title: String, subtitle: String = "", step: String = "", size: int = 60) -> VBoxContainer:
	var v := UI.vbox(0)
	if step != "":
		v.add_child(UI.label(step.to_upper(), "Caps", UITheme.ACCENT))
	var t := UI.label(title, "H1")
	t.add_theme_font_size_override("font_size", size)
	v.add_child(t)
	if subtitle != "":
		v.add_child(UI.label(subtitle, "BodyMuted", null, true))
	return v


## Funds pill for setup screens.
func funds_pill() -> PanelContainer:
	var p := UI.panel("CardFlat")
	p.add_child(UI.stat("funds", "Funds available", U.money(Game.funds), UITheme.GOLD))
	p.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return p


## Root layout: margins + vbox, returns the vbox.
func page_root(pad: int = 40) -> VBoxContainer:
	var m := UI.margin(null, pad, 22, pad, 20)
	add_child(UI.full_rect(m))
	var v := UI.vbox(14)
	m.add_child(v)
	return v
