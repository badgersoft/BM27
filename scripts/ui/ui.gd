class_name UI
extends RefCounted
## Small builders so screens read like layout, not boilerplate.


static func label(text: String, variation: String = "", color: Variant = null, wrap: bool = false) -> Label:
	var l := Label.new()
	l.text = text
	if variation != "":
		l.theme_type_variation = variation
	if color != null:
		l.add_theme_color_override("font_color", color)
	if wrap:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size.x = 40
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


static func rich(bbcode: String, size: int = 18) -> RichTextLabel:
	var r := RichTextLabel.new()
	r.bbcode_enabled = true
	r.fit_content = true
	r.scroll_active = false
	r.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	r.text = bbcode
	r.custom_minimum_size.x = 40
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if size != 18:
		r.add_theme_font_size_override("normal_font_size", size)
		r.add_theme_font_size_override("bold_font_size", size)
	return r


static func button(text: String, icon: String = "", variation: String = "", cb: Callable = Callable()) -> Button:
	var b := Button.new()
	b.text = text
	if icon != "":
		b.icon = Icons.tex(icon)
		b.expand_icon = false
	if variation != "":
		b.theme_type_variation = variation
	b.custom_minimum_size.y = 44
	b.focus_mode = Control.FOCUS_NONE if OS.has_feature("mobile") else Control.FOCUS_ALL
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if cb.is_valid():
		b.pressed.connect(cb)
	return b


static func hbox(sep: int = 12, children: Array = []) -> HBoxContainer:
	var b := HBoxContainer.new()
	b.add_theme_constant_override("separation", sep)
	for c in children:
		b.add_child(c)
	return b


static func vbox(sep: int = 12, children: Array = []) -> VBoxContainer:
	var b := VBoxContainer.new()
	b.add_theme_constant_override("separation", sep)
	for c in children:
		b.add_child(c)
	return b


static func margin(child: Control, l: int, t: int, r: int, b: int) -> MarginContainer:
	var m := MarginContainer.new()
	m.add_theme_constant_override("margin_left", l)
	m.add_theme_constant_override("margin_top", t)
	m.add_theme_constant_override("margin_right", r)
	m.add_theme_constant_override("margin_bottom", b)
	if child:
		m.add_child(child)
	return m


static func panel(variation: String = "Card", child: Control = null) -> PanelContainer:
	var p := PanelContainer.new()
	p.theme_type_variation = variation
	if child:
		p.add_child(child)
	return p


## A card with an icon+caps header. Returns [panel, body_vbox].
static func card(title: String, icon: String = "", variation: String = "Card", accent: Color = UITheme.MUTED) -> Array:
	var p := panel(variation)
	var v := vbox(12)
	p.add_child(v)
	if title != "":
		var h := hbox(8)
		if icon != "":
			h.add_child(Icons.make(icon, 18, accent))
		h.add_child(label(title.to_upper(), "Caps", accent))
		v.add_child(h)
	return [p, v]


static func spacer(expand_h: bool = true, expand_v: bool = false, min_size: Vector2 = Vector2.ZERO) -> Control:
	var c := Control.new()
	c.custom_minimum_size = min_size
	if expand_h:
		c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if expand_v:
		c.size_flags_vertical = Control.SIZE_EXPAND_FILL
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c


static func sep() -> HSeparator:
	return HSeparator.new()


## Small rounded tag, e.g. a genre.
static func chip(text: String, color: Color, filled: bool = false, icon: String = "") -> PanelContainer:
	var p := PanelContainer.new()
	var bg := color if filled else Color(color.r, color.g, color.b, 0.14)
	p.add_theme_stylebox_override("panel", UITheme.box(bg, 20, Color(color.r, color.g, color.b, 0.55), 0 if filled else 1, 10, 3))
	var h := hbox(5)
	var fg := Color("#111114") if filled else color.lightened(0.25)
	if icon != "":
		h.add_child(Icons.make(icon, 14, fg))
	var l := label(text.to_upper(), "Caps", fg)
	l.add_theme_font_size_override("font_size", 14)
	h.add_child(l)
	p.add_child(h)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	p.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return p


static func genre_chip(genre_id: String, filled: bool = false) -> PanelContainer:
	return chip(Data.genre_name(genre_id), Data.genre_color(genre_id), filled, "note")


static func meter(value: float, color: Color, height: float = 8.0, marker: float = -1.0, marker_hi: float = -1.0) -> Meter:
	var m := Meter.new()
	m.value = value
	m.color = color
	m.marker = marker
	m.marker_hi = marker_hi
	m.custom_minimum_size = Vector2(60, height)
	m.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return m


static func stars(rating: float, size: float = 22.0, color: Color = UITheme.GOLD) -> StarRating:
	var s := StarRating.new()
	s.rating = rating
	s.star_size = size
	s.color = color
	return s


## Icon + caption + big value, used in stat strips.
static func stat(icon: String, caption: String, value: String, color: Color = UITheme.TEXT, big: bool = false) -> HBoxContainer:
	var h := hbox(10)
	var ic := Icons.make(icon, 26 if big else 22, color)
	ic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	h.add_child(ic)
	var v := vbox(-4)
	v.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	v.add_child(label(caption.to_upper(), "Caps"))
	var val := label(value, "StatBig" if big else "Stat", color)
	v.add_child(val)
	h.add_child(v)
	return h


static func icon_label(icon: String, text: String, color: Color = UITheme.MUTED, variation: String = "Small", isize: float = 16.0) -> HBoxContainer:
	var h := hbox(6)
	h.add_child(Icons.make(icon, isize, color))
	var l := label(text, variation, color)
	h.add_child(l)
	return h


static func happiness_color(h: float) -> Color:
	if h >= 62.0:
		return UITheme.GOOD
	if h >= 45.0:
		return UITheme.GOLD
	if h >= 28.0:
		return Color("#ff9f43")
	return UITheme.BAD


static func happiness_icon(h: float) -> String:
	if h >= 55.0:
		return "smile"
	if h >= 30.0:
		return "meh"
	return "frown"


static func kind_color(kind: String) -> Color:
	match kind:
		"good": return UITheme.GOOD
		"bad": return UITheme.BAD
		"cost": return UITheme.MUTED
	return UITheme.INFO


static func clear(node: Node) -> void:
	for c in node.get_children():
		node.remove_child(c)
		c.queue_free()


## Vertically scrolling container with touch-friendly settings.
static func scroller(child: Control) -> ScrollContainer:
	var s := ScrollContainer.new()
	s.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.size_flags_vertical = Control.SIZE_EXPAND_FILL
	s.follow_focus = true
	child.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.add_child(child)
	return s


static func full_rect(c: Control) -> Control:
	c.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return c
