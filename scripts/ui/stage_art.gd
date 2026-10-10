class_name StageArt
extends Control
## Gig night splash art: the band on stage, lights in the venue's colour and
## a crowd whose size matches the attendance. The band name goes on the banner.

var tex: Texture2D
var band := ""
var accent := Color("#ff3d2e")
const W := 1000.0
const H := 380.0


## attendance: heads to draw for small crowds (about one head per person).
static func build(colour: String, fill: float, rating: float, seed_val: int, attendance: int = 1000) -> Texture2D:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_val
	var c := Color(colour)
	var hex := c.to_html(false)
	var s := PackedStringArray()
	s.append('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 380" width="1000" height="380">')
	s.append('<defs><linearGradient id="sky" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#%s" stop-opacity="0.55"/><stop offset="0.7" stop-color="#0b0b10" stop-opacity="1"/></linearGradient>' % hex)
	s.append('<linearGradient id="beam" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#%s" stop-opacity="0.55"/><stop offset="1" stop-color="#%s" stop-opacity="0"/></linearGradient></defs>' % [c.lightened(0.3).to_html(false), hex])
	s.append('<rect width="1000" height="380" fill="#0b0b10"/><rect width="1000" height="300" fill="url(#sky)"/>')
	# Lighting truss and beams.
	s.append('<rect x="0" y="0" width="1000" height="14" fill="#1c1c22"/>')
	for i in 6:
		var x := 90.0 + i * 164.0
		var tilt := rng.randf_range(-90.0, 90.0)
		s.append('<polygon points="%d,10 %d,10 %d,300 %d,300" fill="url(#beam)" opacity="0.7"/>' % [x - 8, x + 8, x + tilt + 70, x + tilt - 70])
		s.append('<circle cx="%d" cy="12" r="9" fill="#%s"/>' % [x, c.lightened(0.5).to_html(false)])
	# Backdrop banner (band name drawn on top by Godot).
	s.append('<rect x="250" y="40" width="500" height="64" rx="6" fill="#121218" stroke="#%s" stroke-width="3"/>' % hex)
	# Amp stacks.
	for ax in [70.0, 840.0]:
		s.append('<rect x="%d" y="150" width="90" height="110" rx="4" fill="#15151a" stroke="#2c2c34" stroke-width="3"/>' % ax)
		s.append('<rect x="%d" y="160" width="70" height="40" rx="3" fill="#202028"/><rect x="%d" y="208" width="70" height="44" rx="3" fill="#202028"/>' % [ax + 10, ax + 10])
	# Drum riser and kit.
	s.append('<rect x="390" y="200" width="220" height="40" fill="#18181e"/>')
	s.append('<ellipse cx="500" cy="196" rx="34" ry="34" fill="#22222a" stroke="#%s" stroke-width="3"/>' % hex)
	s.append('<ellipse cx="452" cy="176" rx="18" ry="6" fill="#c9a227"/><ellipse cx="552" cy="170" rx="20" ry="6" fill="#c9a227"/>')
	s.append('<path d="M452 176 V230 M552 170 V230" stroke="#555" stroke-width="3"/>')
	# The band: silhouettes with a rim of stage light.
	var rim := c.lightened(0.4).to_html(false)
	s.append(_figure(500.0, 112.0, 0.82, rim, "drums"))
	s.append(_figure(300.0, 160.0, 1.0, rim, "guitar"))
	s.append(_figure(700.0, 160.0, 1.0, rim, "bass"))
	s.append(_figure(512.0, 168.0, 1.08, rim, "vocals"))
	# Stage floor.
	s.append('<rect x="0" y="258" width="1000" height="26" fill="#1a1a20"/><rect x="0" y="258" width="1000" height="3" fill="#%s" opacity="0.8"/>' % hex)
	# Crowd.
	var hands := clampf((rating - 2.0) / 3.0, 0.0, 1.0)
	# About 160 head slots; small crowds get one head per person.
	var density := fill if attendance >= 160 else float(attendance) / 160.0
	for row in 4:
		var y := 300.0 + row * 22.0
		var shade := Color("#08080b").lerp(Color("#17161c"), float(3 - row) / 3.0)
		var x := -10.0 + rng.randf_range(0.0, 18.0)
		while x < 1010.0:
			if rng.randf() < density * (0.75 + row * 0.1):
				var r := rng.randf_range(10.0, 14.0)
				var hy := y + rng.randf_range(-6.0, 6.0)
				s.append('<circle cx="%d" cy="%d" r="%d" fill="#%s"/><rect x="%d" y="%d" width="%d" height="80" rx="8" fill="#%s"/>' % [x, hy, r, shade.to_html(false), x - r * 1.3, hy + r * 0.6, r * 2.6, shade.to_html(false)])
				if rng.randf() < hands * 0.35:
					var ax2 := x + rng.randf_range(-8.0, 8.0)
					s.append('<path d="M%d %d L%d %d" stroke="#%s" stroke-width="6" stroke-linecap="round"/>' % [x + r * 0.7, hy + r, ax2, hy - r - rng.randf_range(18.0, 32.0), shade.to_html(false)])
			x += rng.randf_range(20.0, 30.0)
	s.append('</svg>')
	var img := Image.new()
	img.load_svg_from_string("".join(s), 1.5)
	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)


static func _figure(cx: float, top: float, sc: float, rim: String, role: String) -> String:
	var body := "#060609"
	var s := '<g transform="translate(%d %d) scale(%f)">' % [cx, top, sc]
	s += '<circle cx="0" cy="0" r="16" fill="%s" stroke="#%s" stroke-width="2"/>' % [body, rim]
	s += '<path d="M-22 22 C-20 14 20 14 22 22 L18 70 L12 108 L4 108 L0 76 L-4 108 L-12 108 L-18 70 Z" fill="%s" stroke="#%s" stroke-width="2"/>' % [body, rim]
	match role:
		"guitar":
			s += '<path d="M-26 52 L34 30" stroke="#%s" stroke-width="5" stroke-linecap="round"/><ellipse cx="-20" cy="56" rx="16" ry="12" fill="#8b1e1e" stroke="#%s" stroke-width="2"/>' % [rim, rim]
		"bass":
			s += '<path d="M-24 54 L44 24" stroke="#%s" stroke-width="5" stroke-linecap="round"/><ellipse cx="-18" cy="58" rx="16" ry="13" fill="#1e3a8b" stroke="#%s" stroke-width="2"/>' % [rim, rim]
		"vocals":
			s += '<path d="M28 6 L36 110" stroke="#777" stroke-width="3"/><circle cx="27" cy="4" r="5" fill="#999"/><path d="M14 28 L27 8" stroke="%s" stroke-width="7" stroke-linecap="round"/>' % body
		"drums":
			s += '<path d="M-18 30 L-34 6 M18 30 L34 6" stroke="#%s" stroke-width="5" stroke-linecap="round"/>' % rim
	return s + '</g>'


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size.y = 200


func _draw() -> void:
	if tex == null:
		return
	var w := size.x
	var h := w * H / W
	custom_minimum_size.y = h
	draw_texture_rect(tex, Rect2(0, 0, w, h), false)
	var font: Font = UITheme.F_DISPLAY
	var fs := int(h * 0.12)
	var by := h * (40.0 + 32.0) / H + fs * 0.36
	draw_string(font, Vector2(w * 0.25, by), band.to_upper(), HORIZONTAL_ALIGNMENT_CENTER, w * 0.5, fs, UITheme.TEXT)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		var h := size.x * H / W
		if absf(custom_minimum_size.y - h) > 1.0:
			custom_minimum_size.y = h
		queue_redraw()
