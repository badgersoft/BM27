class_name UITheme
extends RefCounted
## The Band Manager 27 look: black stage, paper-white type, amp-red and
## stage-gold accents. Bebas Neue for poster headlines, Barlow for everything
## you need to read quickly, Barlow Condensed for labels.

const BG := Color("#0f0f12")
const BG_2 := Color("#141419")
const PANEL := Color("#18181e")
const PANEL_2 := Color("#202028")
const PANEL_3 := Color("#2a2a34")
const LINE := Color("#2e2e3a")
const TEXT := Color("#f2efe9")
const MUTED := Color("#a19ea8")
const DIM := Color("#6d6a76")
const ACCENT := Color("#ff3d2e")
const ACCENT_DARK := Color("#c42a1e")
const GOLD := Color("#ffc53d")
const GOOD := Color("#3ddc84")
const BAD := Color("#ff5c5c")
const INFO := Color("#4cc9f0")
const PAPER := Color("#f3ecdc")
const INK := Color("#1b1a17")

const F_DISPLAY := preload("res://assets/fonts/BebasNeue-Regular.ttf")
const F_REG := preload("res://assets/fonts/Barlow-Regular.ttf")
const F_MED := preload("res://assets/fonts/Barlow-Medium.ttf")
const F_SEMI := preload("res://assets/fonts/Barlow-SemiBold.ttf")
const F_BOLD := preload("res://assets/fonts/Barlow-Bold.ttf")
const F_COND := preload("res://assets/fonts/BarlowCondensed-SemiBold.ttf")
const F_COND_BOLD := preload("res://assets/fonts/BarlowCondensed-Bold.ttf")
const F_SERIF := preload("res://assets/fonts/PlayfairDisplay.ttf")

static var _theme: Theme
static var _serif_black: FontVariation


static func serif_black() -> Font:
	if _serif_black == null:
		_serif_black = FontVariation.new()
		_serif_black.base_font = F_SERIF
		var ts := TextServerManager.get_primary_interface()
		_serif_black.variation_opentype = {ts.name_to_tag("wght"): 900}
	return _serif_black


static func box(bg: Color, radius: int = 10, border: Color = Color(0, 0, 0, 0), bw: int = 0, pad_h: int = 14, pad_v: int = 10) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(radius)
	if bw > 0:
		s.border_color = border
		s.set_border_width_all(bw)
	s.content_margin_left = pad_h
	s.content_margin_right = pad_h
	s.content_margin_top = pad_v
	s.content_margin_bottom = pad_v
	s.anti_aliasing = true
	return s


static func get_theme() -> Theme:
	if _theme == null:
		_theme = _build()
	return _theme


static func _build() -> Theme:
	var t := Theme.new()
	t.default_font = F_MED
	t.default_font_size = 18

	# ---- Labels
	t.set_color("font_color", "Label", TEXT)
	t.set_font("font", "Label", F_MED)
	t.set_font_size("font_size", "Label", 18)
	t.set_constant("line_spacing", "Label", 2)
	_label_var(t, "H1", F_DISPLAY, 72, TEXT)
	_label_var(t, "H2", F_DISPLAY, 40, TEXT)
	_label_var(t, "H3", F_DISPLAY, 28, TEXT)
	_label_var(t, "Caps", F_COND_BOLD, 15, MUTED)
	_label_var(t, "CapsBig", F_COND_BOLD, 19, TEXT)
	_label_var(t, "Body", F_REG, 18, TEXT)
	_label_var(t, "BodyMuted", F_REG, 17, MUTED)
	_label_var(t, "Small", F_MED, 15, MUTED)
	_label_var(t, "Strong", F_BOLD, 19, TEXT)
	_label_var(t, "Stat", F_DISPLAY, 30, TEXT)
	_label_var(t, "StatBig", F_DISPLAY, 48, TEXT)
	_label_var(t, "Title", F_SEMI, 22, TEXT)

	# ---- RichTextLabel
	t.set_color("default_color", "RichTextLabel", TEXT)
	t.set_font("normal_font", "RichTextLabel", F_REG)
	t.set_font("bold_font", "RichTextLabel", F_BOLD)
	t.set_font("italics_font", "RichTextLabel", F_MED)
	t.set_font_size("normal_font_size", "RichTextLabel", 18)
	t.set_font_size("bold_font_size", "RichTextLabel", 18)
	t.set_constant("line_separation", "RichTextLabel", 3)

	# ---- Buttons (default = secondary)
	t.set_font("font", "Button", F_SEMI)
	t.set_font_size("font_size", "Button", 18)
	t.set_color("font_color", "Button", TEXT)
	t.set_color("font_hover_color", "Button", Color.WHITE)
	t.set_color("font_pressed_color", "Button", Color.WHITE)
	t.set_color("font_focus_color", "Button", TEXT)
	t.set_color("font_disabled_color", "Button", DIM)
	t.set_color("icon_normal_color", "Button", TEXT)
	t.set_color("icon_hover_color", "Button", Color.WHITE)
	t.set_color("icon_pressed_color", "Button", Color.WHITE)
	t.set_color("icon_disabled_color", "Button", DIM)
	t.set_color("icon_focus_color", "Button", TEXT)
	t.set_constant("h_separation", "Button", 10)
	t.set_constant("icon_max_width", "Button", 22)
	t.set_stylebox("normal", "Button", box(PANEL_2, 10, LINE, 1, 16, 10))
	t.set_stylebox("hover", "Button", box(PANEL_3, 10, Color("#4a4a58"), 1, 16, 10))
	t.set_stylebox("pressed", "Button", box(Color("#33333f"), 10, ACCENT, 1, 16, 10))
	t.set_stylebox("disabled", "Button", box(Color("#1a1a20"), 10, Color("#24242c"), 1, 16, 10))
	t.set_stylebox("focus", "Button", box(Color(0, 0, 0, 0), 10, Color(1, 0.77, 0.24, 0.6), 2, 16, 10))

	# Primary: the big amp-red call to action.
	t.set_type_variation("Primary", "Button")
	t.set_font("font", "Primary", F_DISPLAY)
	t.set_font_size("font_size", "Primary", 30)
	t.set_color("font_color", "Primary", Color("#140808"))
	t.set_color("font_hover_color", "Primary", Color("#140808"))
	t.set_color("font_pressed_color", "Primary", Color("#140808"))
	t.set_color("font_focus_color", "Primary", Color("#140808"))
	t.set_color("icon_normal_color", "Primary", Color("#140808"))
	t.set_color("icon_hover_color", "Primary", Color("#140808"))
	t.set_color("icon_pressed_color", "Primary", Color("#140808"))
	t.set_color("icon_focus_color", "Primary", Color("#140808"))
	t.set_constant("icon_max_width", "Primary", 26)
	t.set_stylebox("normal", "Primary", box(ACCENT, 12, Color(0, 0, 0, 0), 0, 26, 12))
	t.set_stylebox("hover", "Primary", box(Color("#ff5546"), 12, Color(0, 0, 0, 0), 0, 26, 12))
	t.set_stylebox("pressed", "Primary", box(ACCENT_DARK, 12, Color(0, 0, 0, 0), 0, 26, 12))
	t.set_stylebox("disabled", "Primary", box(Color("#3a2522"), 12, Color(0, 0, 0, 0), 0, 26, 12))
	t.set_stylebox("focus", "Primary", box(Color(0, 0, 0, 0), 12, GOLD, 2, 26, 12))

	# Gold: positive confirmation (sign, book, accept).
	t.set_type_variation("Gold", "Button")
	t.set_font("font", "Gold", F_COND_BOLD)
	t.set_font_size("font_size", "Gold", 19)
	for k in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "icon_normal_color", "icon_hover_color", "icon_pressed_color", "icon_focus_color"]:
		t.set_color(k, "Gold", Color("#1a1405"))
	t.set_stylebox("normal", "Gold", box(GOLD, 10, Color(0, 0, 0, 0), 0, 16, 9))
	t.set_stylebox("hover", "Gold", box(Color("#ffd469"), 10, Color(0, 0, 0, 0), 0, 16, 9))
	t.set_stylebox("pressed", "Gold", box(Color("#d9a51f"), 10, Color(0, 0, 0, 0), 0, 16, 9))
	t.set_stylebox("disabled", "Gold", box(Color("#2b2616"), 10, Color(0, 0, 0, 0), 0, 16, 9))
	t.set_color("font_disabled_color", "Gold", Color("#6e6440"))

	# Ghost: quiet, borderless.
	t.set_type_variation("Ghost", "Button")
	t.set_stylebox("normal", "Ghost", box(Color(0, 0, 0, 0), 10, Color(0, 0, 0, 0), 0, 12, 8))
	t.set_stylebox("hover", "Ghost", box(Color(1, 1, 1, 0.06), 10, Color(0, 0, 0, 0), 0, 12, 8))
	t.set_stylebox("pressed", "Ghost", box(Color(1, 1, 1, 0.1), 10, Color(0, 0, 0, 0), 0, 12, 8))
	t.set_stylebox("disabled", "Ghost", box(Color(0, 0, 0, 0), 10, Color(0, 0, 0, 0), 0, 12, 8))
	t.set_color("font_color", "Ghost", MUTED)

	# Menu: the big main-menu buttons.
	t.set_type_variation("Menu", "Button")
	t.set_font("font", "Menu", F_DISPLAY)
	t.set_font_size("font_size", "Menu", 30)
	t.set_constant("icon_max_width", "Menu", 26)
	t.set_constant("h_separation", "Menu", 14)
	t.set_stylebox("normal", "Menu", box(Color(1, 1, 1, 0.04), 12, Color(1, 1, 1, 0.1), 1, 24, 10))
	t.set_stylebox("hover", "Menu", box(Color(1, 1, 1, 0.1), 12, Color(1, 1, 1, 0.3), 1, 24, 10))
	t.set_stylebox("pressed", "Menu", box(Color(1, 0.24, 0.18, 0.2), 12, ACCENT, 1, 24, 10))
	t.set_stylebox("focus", "Menu", box(Color(0, 0, 0, 0), 12, GOLD, 2, 24, 10))

	# Nav rail buttons.
	t.set_type_variation("Nav", "Button")
	t.set_font("font", "Nav", F_COND_BOLD)
	t.set_font_size("font_size", "Nav", 14)
	t.set_color("font_color", "Nav", MUTED)
	t.set_color("icon_normal_color", "Nav", MUTED)
	t.set_constant("icon_max_width", "Nav", 24)
	t.set_stylebox("normal", "Nav", box(Color(0, 0, 0, 0), 10, Color(0, 0, 0, 0), 0, 6, 8))
	t.set_stylebox("hover", "Nav", box(Color(1, 1, 1, 0.05), 10, Color(0, 0, 0, 0), 0, 6, 8))
	t.set_stylebox("pressed", "Nav", box(Color(1, 1, 1, 0.08), 10, Color(0, 0, 0, 0), 0, 6, 8))
	t.set_type_variation("NavActive", "Button")
	t.set_font("font", "NavActive", F_COND_BOLD)
	t.set_font_size("font_size", "NavActive", 14)
	t.set_color("font_color", "NavActive", TEXT)
	t.set_color("font_hover_color", "NavActive", TEXT)
	t.set_color("icon_normal_color", "NavActive", ACCENT)
	t.set_color("icon_hover_color", "NavActive", ACCENT)
	t.set_constant("icon_max_width", "NavActive", 24)
	var nav_on := box(Color(1, 0.24, 0.18, 0.12), 10, Color(0, 0, 0, 0), 0, 6, 8)
	t.set_stylebox("normal", "NavActive", nav_on)
	t.set_stylebox("hover", "NavActive", nav_on)
	t.set_stylebox("pressed", "NavActive", nav_on)

	# Segmented toggle buttons (settings, tabs).
	t.set_type_variation("Seg", "Button")
	t.set_font("font", "Seg", F_COND_BOLD)
	t.set_font_size("font_size", "Seg", 17)
	t.set_color("font_color", "Seg", MUTED)
	t.set_stylebox("normal", "Seg", box(PANEL_2, 8, LINE, 1, 14, 8))
	t.set_stylebox("hover", "Seg", box(PANEL_3, 8, LINE, 1, 14, 8))
	t.set_stylebox("pressed", "Seg", box(PANEL_3, 8, LINE, 1, 14, 8))
	t.set_type_variation("SegOn", "Button")
	t.set_font("font", "SegOn", F_COND_BOLD)
	t.set_font_size("font_size", "SegOn", 17)
	for k in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "icon_normal_color", "icon_hover_color"]:
		t.set_color(k, "SegOn", Color("#140808"))
	var seg_on := box(TEXT, 8, Color(0, 0, 0, 0), 0, 14, 8)
	t.set_stylebox("normal", "SegOn", seg_on)
	t.set_stylebox("hover", "SegOn", seg_on)
	t.set_stylebox("pressed", "SegOn", seg_on)

	# ---- Panels
	t.set_stylebox("panel", "PanelContainer", box(PANEL, 14, LINE, 1, 18, 16))
	t.set_type_variation("Card", "PanelContainer")
	t.set_stylebox("panel", "Card", box(PANEL, 14, LINE, 1, 18, 16))
	t.set_type_variation("CardFlat", "PanelContainer")
	t.set_stylebox("panel", "CardFlat", box(PANEL_2, 12, Color(0, 0, 0, 0), 0, 14, 12))
	t.set_type_variation("CardHi", "PanelContainer")
	t.set_stylebox("panel", "CardHi", box(PANEL, 14, GOLD, 2, 18, 16))
	t.set_type_variation("Bar", "PanelContainer")
	t.set_stylebox("panel", "Bar", box(BG_2, 0, Color(0, 0, 0, 0), 0, 16, 8))
	t.set_type_variation("Modal", "PanelContainer")
	var modal := box(PANEL, 18, Color("#3a3a48"), 1, 28, 24)
	modal.shadow_color = Color(0, 0, 0, 0.55)
	modal.shadow_size = 24
	t.set_stylebox("panel", "Modal", modal)
	t.set_type_variation("Paper", "PanelContainer")
	var paper := box(PAPER, 4, Color(0, 0, 0, 0), 0, 34, 28)
	paper.shadow_color = Color(0, 0, 0, 0.6)
	paper.shadow_size = 28
	t.set_stylebox("panel", "Paper", paper)
	# Sliders: a chunky track and a big round grabber, easy on touch screens.
	t.set_stylebox("slider", "HSlider", box(BG_2, 6, LINE, 1, 0, 5))
	t.set_stylebox("grabber_area", "HSlider", box(GOLD.darkened(0.25), 6, Color(0, 0, 0, 0), 0, 0, 5))
	t.set_stylebox("grabber_area_highlight", "HSlider", box(GOLD, 6, Color(0, 0, 0, 0), 0, 0, 5))
	var knob := Image.create(30, 30, false, Image.FORMAT_RGBA8)
	for y in 30:
		for x in 30:
			var d := Vector2(x - 14.5, y - 14.5).length()
			if d <= 14.5:
				knob.set_pixel(x, y, GOLD if d <= 11.5 else Color("#140808"))
	var gtex := ImageTexture.create_from_image(knob)
	t.set_icon("grabber", "HSlider", gtex)
	t.set_icon("grabber_highlight", "HSlider", gtex)
	# Scroll hint: a short, soft shadow (flipped by Godot for the bottom edge).
	var g := Gradient.new()
	g.set_color(0, Color(0, 0, 0, 0.75))
	g.set_color(1, Color(0, 0, 0, 0.0))
	var gt := GradientTexture2D.new()
	gt.gradient = g
	gt.width = 4
	gt.height = 36
	gt.fill_from = Vector2(0, 0)
	gt.fill_to = Vector2(0, 1)
	t.set_icon("scroll_hint_vertical", "ScrollContainer", gt)

	# ---- Inputs
	t.set_font("font", "LineEdit", F_SEMI)
	t.set_font_size("font_size", "LineEdit", 20)
	t.set_color("font_color", "LineEdit", TEXT)
	t.set_color("font_placeholder_color", "LineEdit", DIM)
	t.set_color("caret_color", "LineEdit", ACCENT)
	t.set_color("selection_color", "LineEdit", Color(1, 0.24, 0.18, 0.35))
	t.set_stylebox("normal", "LineEdit", box(BG_2, 10, LINE, 1, 14, 10))
	t.set_stylebox("focus", "LineEdit", box(BG_2, 10, ACCENT, 2, 14, 10))

	# ---- Scrollbars: slim and out of the way.
	var grab := box(Color("#3a3a46"), 4, Color(0, 0, 0, 0), 0, 0, 0)
	var grab_hi := box(Color("#55556a"), 4, Color(0, 0, 0, 0), 0, 0, 0)
	var track := StyleBoxEmpty.new()
	for sb in ["VScrollBar", "HScrollBar"]:
		t.set_stylebox("scroll", sb, track)
		t.set_stylebox("grabber", sb, grab)
		t.set_stylebox("grabber_highlight", sb, grab_hi)
		t.set_stylebox("grabber_pressed", sb, grab_hi)
	var sep := StyleBoxLine.new()
	sep.color = LINE
	sep.thickness = 1
	t.set_stylebox("separator", "HSeparator", sep)
	t.set_constant("separation", "HSeparator", 12)

	# ---- Tooltips
	t.set_stylebox("panel", "TooltipPanel", box(Color("#26262f"), 8, LINE, 1, 10, 6))
	t.set_color("font_color", "TooltipLabel", TEXT)
	t.set_font("font", "TooltipLabel", F_MED)
	t.set_font_size("font_size", "TooltipLabel", 16)
	return t


static func _label_var(t: Theme, name: String, font: Font, size: int, color: Color) -> void:
	t.set_type_variation(name, "Label")
	t.set_font("font", name, font)
	t.set_font_size("font_size", name, size)
	t.set_color("font_color", name, color)
