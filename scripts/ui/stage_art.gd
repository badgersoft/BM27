class_name StageArt
extends Control
## Gig night splash art. Each size of venue has its own look:
##   HALL     village and school halls: strip lights, bunting, a tea urn
##   PUB      pubs and clubs: brick walls, a bar, a neon sign, tiny stage
##   THEATRE  corn exchanges and town halls: curtains and a lighting truss
##   ARENA    academies and arenas: lighting rigs, side screens, PA stacks
##   STADIUM  stadiums and festivals: night sky, roof, giant screen, pyro
## Lights take the venue's colour and the crowd matches the attendance.
## The band name is drawn by Godot onto the style's banner.

enum { HALL, PUB, THEATRE, ARENA, STADIUM }

const W := 1000.0
const H := 380.0
## Banner rect (SVG units), and whether its lettering is dark (paper signs).
const BANNERS := {
	HALL: [Rect2(330, 62, 340, 50), true],
	PUB: [Rect2(300, 52, 400, 58), false],
	THEATRE: [Rect2(250, 44, 500, 64), false],
	ARENA: [Rect2(270, 36, 460, 70), false],
	STADIUM: [Rect2(300, 30, 400, 84), false],
}

var tex: Texture2D
var band := ""
var style := THEATRE
var neon := Color.WHITE


static func style_for(venue_idx: int) -> int:
	if venue_idx <= 1:
		return HALL
	if venue_idx <= 4:
		return PUB
	if venue_idx <= 7:
		return THEATRE
	if venue_idx <= 12:
		return ARENA
	return STADIUM


## A ready-to-use splash for a gig record.
static func for_gig(g: Dictionary) -> StageArt:
	var a := StageArt.new()
	var idx := int(g.get("venue", 5))
	a.style = style_for(idx)
	a.neon = Color(str(g.colour)).lightened(0.45)
	a.tex = build(str(g.colour), float(g.fill), float(g.crowd), int(g.week) * 31 + idx, int(g.attendance), idx)
	a.band = Game.band_name
	return a


## attendance: heads to draw for small crowds (about one head per person).
static func build(colour: String, fill: float, rating: float, seed_val: int, attendance: int = 1000, venue_idx: int = 5) -> Texture2D:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_val
	var c := Color(colour)
	var st := style_for(venue_idx)
	var s := PackedStringArray()
	s.append('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 380" width="1000" height="380">')
	s.append(_defs(c))
	match st:
		HALL: _hall(s, c, rng)
		PUB: _pub(s, c, rng)
		THEATRE: _theatre(s, c, rng)
		ARENA: _arena(s, c, rng)
		STADIUM: _stadium(s, c, rng, venue_idx == 13)
	_band(s, c, st)
	_floor(s, c, st)
	_crowd(s, rng, st, fill, rating, attendance, c)
	if st == STADIUM:
		_pyro(s, rating)
	s.append('</svg>')
	var img := Image.new()
	img.load_svg_from_string("".join(s), 1.5)
	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)


static func _hex(c: Color) -> String:
	return c.to_html(false)


static func _defs(c: Color) -> String:
	var hex := _hex(c)
	var d := '<defs>'
	d += '<linearGradient id="sky" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#%s" stop-opacity="0.55"/><stop offset="0.7" stop-color="#0b0b10" stop-opacity="1"/></linearGradient>' % hex
	d += '<linearGradient id="beam" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#%s" stop-opacity="0.6"/><stop offset="1" stop-color="#%s" stop-opacity="0"/></linearGradient>' % [_hex(c.lightened(0.3)), hex]
	d += '<linearGradient id="white" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#ffffff" stop-opacity="0.35"/><stop offset="1" stop-color="#ffffff" stop-opacity="0"/></linearGradient>'
	d += '<linearGradient id="screen" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#%s"/><stop offset="1" stop-color="#0d0d14"/></linearGradient>' % _hex(c.darkened(0.2))
	d += '<linearGradient id="night" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#05061a"/><stop offset="0.6" stop-color="#%s" stop-opacity="0.5"/><stop offset="1" stop-color="#0b0b10"/></linearGradient>' % _hex(c.darkened(0.4))
	d += '<linearGradient id="flame" x1="0" y1="1" x2="0" y2="0"><stop offset="0" stop-color="#ffdd55"/><stop offset="0.5" stop-color="#ff7a1a"/><stop offset="1" stop-color="#ff3d2e" stop-opacity="0"/></linearGradient>'
	return d + '</defs>'


# ------------------------------------------------------------- backdrops

## Village or school hall: magnolia walls, strip lights, bunting, a raffle
## table and a tea urn. Not a spotlight in sight.
static func _hall(s: PackedStringArray, c: Color, rng: RandomNumberGenerator) -> void:
	s.append('<rect width="1000" height="380" fill="#16130f"/><rect width="1000" height="262" fill="#2c2721"/>')
	# Wood panelling on the lower wall.
	s.append('<rect x="0" y="170" width="1000" height="92" fill="#3a2b1d"/>')
	for x in range(0, 1000, 62):
		s.append('<rect x="%d" y="170" width="2" height="92" fill="#2a1f14"/>' % x)
	s.append('<rect x="0" y="168" width="1000" height="5" fill="#4a3826"/>')
	# Fluorescent strip lights.
	for x in [140, 440, 740]:
		s.append('<rect x="%d" y="10" width="120" height="8" rx="3" fill="#eef6f2"/><rect x="%d" y="18" width="160" height="40" fill="url(#white)" opacity="0.6"/>' % [x, x - 20])
	# Bunting sagging across the hall.
	var cols := ["#%s" % _hex(c.lightened(0.2)), "#ffc53d", "#f2f2f2", "#3a86ff", "#e63946"]
	for strand in 2:
		var x0 := 20.0 + strand * 490.0
		for k in 11:
			var t := float(k) / 10.0
			var x := x0 + t * 460.0
			var y := 30.0 + 26.0 * sin(PI * t)
			s.append('<polygon points="%d,%d %d,%d %d,%d" fill="%s"/>' % [x, y, x + 34, y + 1, x + 17, y + 26, cols[(k + strand) % cols.size()]])
	# Wall clock and a notice board.
	s.append('<circle cx="880" cy="92" r="20" fill="#e8e1cf" stroke="#4a3826" stroke-width="4"/><path d="M880 92 L880 79 M880 92 L889 96" stroke="#222" stroke-width="3"/>')
	s.append('<rect x="70" y="70" width="110" height="74" fill="#6b4a2a"/><rect x="80" y="80" width="38" height="26" fill="#f2efe4"/><rect x="128" y="82" width="42" height="30" fill="#ffd166"/><rect x="88" y="112" width="44" height="24" fill="#a8dadc"/>')
	# Trestle table with the tea urn and a plate of biscuits.
	s.append('<rect x="820" y="214" width="170" height="10" fill="#d8d2c4"/><path d="M835 224 L825 262 M975 224 L985 262" stroke="#777" stroke-width="4"/>')
	s.append('<rect x="880" y="168" width="34" height="46" rx="6" fill="#b9bfc4"/><rect x="886" y="160" width="22" height="10" rx="3" fill="#8d9398"/><path d="M914 200 h10 v6" stroke="#8d9398" stroke-width="4" fill="none"/>')
	s.append('<ellipse cx="950" cy="212" rx="22" ry="4" fill="#f2f2f2"/><circle cx="944" cy="208" r="5" fill="#c08a4e"/><circle cx="956" cy="208" r="5" fill="#c08a4e"/>')
	# Stacked chairs.
	for k in 4:
		s.append('<path d="M%d 262 L%d 214 L%d 214" stroke="#5b6470" stroke-width="5" fill="none"/>' % [24 + k * 6, 24 + k * 6, 54 + k * 6])
	# The paper banner, taped up.
	s.append('<rect x="330" y="62" width="340" height="50" fill="#efe6cf"/><rect x="322" y="58" width="22" height="10" fill="#d9cfb0" opacity="0.8"/><rect x="656" y="58" width="22" height="10" fill="#d9cfb0" opacity="0.8"/>')
	# Combo amps on the floor.
	for ax in [140.0, 650.0]:
		s.append('<rect x="%d" y="206" width="76" height="56" rx="5" fill="#1d1d22" stroke="#33333c" stroke-width="3"/><rect x="%d" y="214" width="60" height="38" rx="3" fill="#2a2a32"/>' % [ax, ax + 8])


## Pub or club: bare brick, ceiling pipes, a bar with a lot of bottles, two
## little spotlights and a neon sign with your name on.
static func _pub(s: PackedStringArray, c: Color, rng: RandomNumberGenerator) -> void:
	s.append('<rect width="1000" height="380" fill="#0d0a09"/>')
	var brick := "#3a1d17"
	for row in 18:
		var y := 30 + row * 13
		var off := 0 if row % 2 == 0 else 22
		for x in range(-off, 1000, 44):
			var shade := Color(brick).darkened(rng.randf_range(0.0, 0.3))
			s.append('<rect x="%d" y="%d" width="41" height="10" fill="#%s"/>' % [x, y, _hex(shade)])
	# A bit of darkness at the top and pipes along the ceiling.
	s.append('<rect width="1000" height="40" fill="#0d0a09"/><rect x="0" y="14" width="1000" height="8" fill="#3b3b40"/><rect x="0" y="28" width="1000" height="5" fill="#2b2b30"/>')
	# Two small spotlight cans.
	for x in [380.0, 620.0]:
		s.append('<polygon points="%d,30 %d,30 %d,262 %d,262" fill="url(#beam)" opacity="0.75"/>' % [x - 8, x + 8, x + 90, x - 90])
		s.append('<rect x="%d" y="22" width="22" height="16" rx="3" fill="#1a1a1f"/>' % (x - 11))
	# Neon sign.
	var n := _hex(c.lightened(0.45))
	s.append('<rect x="300" y="52" width="400" height="58" rx="10" fill="#0e0e12"/>')
	s.append('<rect x="296" y="48" width="408" height="66" rx="14" fill="none" stroke="#%s" stroke-width="10" opacity="0.18"/>' % n)
	s.append('<rect x="300" y="52" width="400" height="58" rx="10" fill="none" stroke="#%s" stroke-width="3"/>' % n)
	# The bar: shelves of bottles, taps and the counter.
	s.append('<rect x="800" y="100" width="200" height="6" fill="#4a2e1c"/><rect x="800" y="150" width="200" height="6" fill="#4a2e1c"/>')
	var bottle_cols := ["#2a9d8f", "#e9c46a", "#8b1e1e", "#3a86ff", "#c8553d", "#6b705c"]
	for shelf in [100, 150]:
		for k in 8:
			var bx := 810 + k * 23
			var bh := rng.randf_range(22.0, 34.0)
			s.append('<rect x="%d" y="%d" width="12" height="%d" rx="3" fill="%s"/>' % [bx, shelf - bh, bh, bottle_cols[rng.randi() % bottle_cols.size()]])
	s.append('<rect x="790" y="208" width="210" height="16" fill="#5a3a22"/><rect x="800" y="224" width="200" height="38" fill="#2e1d12"/>')
	for tx in [830, 860, 890]:
		s.append('<rect x="%d" y="186" width="6" height="22" fill="#c9c9c9"/><rect x="%d" y="180" width="12" height="8" rx="2" fill="#%s"/>' % [tx, tx - 3, n])
	# Combo amps.
	for ax in [120.0, 630.0]:
		s.append('<rect x="%d" y="196" width="80" height="62" rx="5" fill="#16161b" stroke="#2c2c34" stroke-width="3"/><rect x="%d" y="204" width="64" height="44" rx="3" fill="#24242c"/>' % [ax, ax + 8])


## Theatre or town hall: red curtains, a lighting truss and a proper stage.
static func _theatre(s: PackedStringArray, c: Color, rng: RandomNumberGenerator) -> void:
	s.append('<rect width="1000" height="380" fill="#0b0b10"/><rect width="1000" height="300" fill="url(#sky)"/>')
	s.append('<rect x="0" y="0" width="1000" height="14" fill="#1c1c22"/>')
	for i in 5:
		var x := 170.0 + i * 165.0
		var tilt := rng.randf_range(-80.0, 80.0)
		s.append('<polygon points="%d,10 %d,10 %d,300 %d,300" fill="url(#beam)" opacity="0.7"/>' % [x - 8, x + 8, x + tilt + 70, x + tilt - 70])
		s.append('<circle cx="%d" cy="12" r="9" fill="#%s"/>' % [x, _hex(c.lightened(0.5))])
	s.append('<rect x="250" y="44" width="500" height="64" rx="6" fill="#121218" stroke="#%s" stroke-width="3"/>' % _hex(c))
	_stacks(s, [160.0, 750.0], 1)
	# Curtains and a scalloped valance.
	for side in [0, 1]:
		var x0 := 0.0 if side == 0 else 910.0
		s.append('<rect x="%d" y="0" width="90" height="262" fill="#6b0f17"/>' % x0)
		for k in 5:
			s.append('<rect x="%d" y="0" width="5" height="262" fill="#4a0a10"/>' % (x0 + 10 + k * 17))
	s.append('<rect x="0" y="0" width="1000" height="26" fill="#6b0f17"/>')
	for k in 20:
		s.append('<circle cx="%d" cy="26" r="25" fill="#6b0f17"/>' % (25 + k * 50))
	s.append('<rect x="0" y="0" width="1000" height="4" fill="#c9a227"/>')


## Academy or arena: two lighting rigs, lots of beams, side video screens and
## hanging PA.
static func _arena(s: PackedStringArray, c: Color, rng: RandomNumberGenerator) -> void:
	s.append('<rect width="1000" height="380" fill="#08080c"/><rect width="1000" height="300" fill="url(#sky)"/>')
	for i in 10:
		var x := 60.0 + i * 98.0
		var tilt := rng.randf_range(-140.0, 140.0)
		var fill := "url(#beam)" if i % 2 == 0 else "url(#white)"
		s.append('<polygon points="%d,24 %d,24 %d,300 %d,300" fill="%s" opacity="0.65"/>' % [x - 6, x + 6, x + tilt + 50, x + tilt - 50, fill])
	for y in [6, 26]:
		s.append('<rect x="0" y="%d" width="1000" height="10" fill="#22222a"/>' % y)
		for x in range(0, 1000, 20):
			s.append('<path d="M%d %d l10 10 l10 -10" stroke="#3a3a44" stroke-width="2" fill="none"/>' % [x, y])
	for i in 10:
		s.append('<circle cx="%d" cy="22" r="6" fill="#%s"/>' % [60 + i * 98, _hex(c.lightened(0.5)) if i % 2 == 0 else "f2f2f2"])
	# Side screens showing the singer.
	for sx in [24.0, 826.0]:
		s.append('<rect x="%d" y="62" width="150" height="100" rx="4" fill="url(#screen)" stroke="#2c2c34" stroke-width="4"/>' % sx)
		s.append('<circle cx="%d" cy="104" r="16" fill="#060609"/><path d="M%d 162 C%d 128 %d 128 %d 162 Z" fill="#060609"/>' % [sx + 75, sx + 45, sx + 50, sx + 100, sx + 105])
	# Hanging PA.
	for px in [196.0, 784.0]:
		for k in 6:
			s.append('<rect x="%d" y="%d" width="22" height="13" rx="2" fill="#16161b" stroke="#2c2c34" stroke-width="2"/>' % [px, 44 + k * 14])
	s.append('<rect x="270" y="36" width="460" height="70" rx="6" fill="#0d0d14" stroke="#%s" stroke-width="4"/>' % _hex(c))
	_stacks(s, [230.0, 690.0], 2)
	# Haze.
	s.append('<rect x="0" y="200" width="1000" height="70" fill="#ffffff" opacity="0.04"/>')


## Stadium or festival: night sky and stars, a huge roof (a pyramid for the
## festival), a giant screen, side screens and lasers.
static func _stadium(s: PackedStringArray, c: Color, rng: RandomNumberGenerator, festival: bool) -> void:
	s.append('<rect width="1000" height="380" fill="url(#night)"/>')
	for k in 40:
		s.append('<circle cx="%d" cy="%d" r="%.1f" fill="#ffffff" opacity="%.2f"/>' % [rng.randi_range(0, 1000), rng.randi_range(0, 130), rng.randf_range(0.6, 1.6), rng.randf_range(0.3, 0.9)])
	var lit := _hex(c.lightened(0.4))
	if festival:
		# The Pyramid-ish Stage.
		s.append('<polygon points="500,-40 60,262 940,262" fill="#0f0f16" stroke="#%s" stroke-width="5"/>' % lit)
		s.append('<path d="M500 -40 L280 262 M500 -40 L720 262 M170 186 L830 186 M260 124 L740 124" stroke="#2c2c38" stroke-width="3"/>')
	else:
		# A curved roof on two towers.
		s.append('<rect x="40" y="40" width="40" height="222" fill="#15151c"/><rect x="920" y="40" width="40" height="222" fill="#15151c"/>')
		s.append('<path d="M40 50 Q500 -50 960 50 L960 70 Q500 -30 40 70 Z" fill="#1c1c26" stroke="#%s" stroke-width="3"/>' % lit)
		for k in 12:
			var t := float(k) / 11.0
			var x := 40.0 + t * 920.0
			s.append('<path d="M%d %d L%d %d" stroke="#2c2c38" stroke-width="3"/>' % [x, 50.0 - 100.0 * t * (1.0 - t) * 0.9, x, 60.0 - 100.0 * t * (1.0 - t) * 0.9 + 12])
	# Lasers fanning out from the stage.
	for k in 8:
		var ex := rng.randi_range(-200, 1200)
		s.append('<path d="M500 140 L%d -10" stroke="#%s" stroke-width="2" opacity="0.55"/>' % [ex, "6dff8a" if k % 3 == 0 else lit])
	# Side screens.
	for sx in [100.0, 760.0]:
		s.append('<rect x="%d" y="96" width="140" height="92" rx="4" fill="url(#screen)" stroke="#2c2c38" stroke-width="4"/>' % sx)
		s.append('<circle cx="%d" cy="134" r="15" fill="#060609"/><path d="M%d 188 C%d 156 %d 156 %d 188 Z" fill="#060609"/>' % [sx + 70, sx + 40, sx + 46, sx + 94, sx + 100])
	# The giant central screen carries the band name.
	s.append('<rect x="300" y="30" width="400" height="84" rx="6" fill="url(#screen)" stroke="#%s" stroke-width="4"/>' % lit)
	_stacks(s, [250.0, 680.0], 3)


# ----------------------------------------------------------- stage parts

static func _stacks(s: PackedStringArray, xs: Array, wide: int) -> void:
	for ax in xs:
		for k in wide:
			var x: float = float(ax) + k * 24.0 - (wide - 1) * 12.0
			s.append('<rect x="%d" y="150" width="70" height="110" rx="4" fill="#15151a" stroke="#2c2c34" stroke-width="3"/>' % x)
			s.append('<rect x="%d" y="160" width="54" height="40" rx="3" fill="#202028"/><rect x="%d" y="208" width="54" height="44" rx="3" fill="#202028"/>' % [x + 8, x + 8])


## Where everyone stands, per style: guitar, singer, drums, bass (x), and
## the height of the stage floor. The drummer sits back and to one side of
## the singer so they don't overlap, and low enough to clear the banner.
static func _layout(st: int) -> Dictionary:
	match st:
		HALL: return {"gtr": 250.0, "voc": 420.0, "drm": 570.0, "bass": 740.0, "floor": 262.0}
		PUB: return {"gtr": 230.0, "voc": 400.0, "drm": 545.0, "bass": 715.0, "floor": 262.0}
	return {"gtr": 250.0, "voc": 425.0, "drm": 575.0, "bass": 760.0, "floor": 258.0}


## The kit on its riser, drawn over the (seated) drummer's legs.
static func _drums(s: PackedStringArray, c: Color, x: float, floor_y: float) -> void:
	var hex := _hex(c)
	var top := floor_y - 34.0
	s.append('<rect x="%d" y="%d" width="200" height="34" fill="#18181e"/>' % [x - 100, top])
	s.append('<ellipse cx="%d" cy="%d" rx="32" ry="32" fill="#22222a" stroke="#%s" stroke-width="3"/>' % [x, top - 6, hex])
	s.append('<ellipse cx="%d" cy="%d" rx="16" ry="5" fill="#c9a227"/><ellipse cx="%d" cy="%d" rx="18" ry="5" fill="#c9a227"/>' % [x - 46, top - 40, x + 48, top - 46])
	s.append('<path d="M%d %d V%d M%d %d V%d" stroke="#555" stroke-width="3"/>' % [x - 46, top - 40, top, x + 48, top - 46, top])


static func _band(s: PackedStringArray, c: Color, st: int) -> void:
	var L := _layout(st)
	var fl: float = L.floor
	var rim := _hex(c.lightened(0.4)) if st != HALL else "8a8478"
	# Feet (and the mic stand) sit exactly on the stage: a figure is 108
	# units tall before scaling.
	s.append(_figure(L.drm, fl - 104.0, 0.8, rim, "drums"))
	_drums(s, c, L.drm, fl)
	s.append(_figure(L.gtr, fl - 108.0, 1.0, rim, "guitar"))
	s.append(_figure(L.bass, fl - 108.0, 1.0, rim, "bass"))
	s.append(_figure(L.voc, fl - 108.0 * 1.08, 1.08, rim, "vocals"))


static func _floor(s: PackedStringArray, c: Color, st: int) -> void:
	match st:
		HALL:
			# A low wooden platform, then the parquet floor.
			s.append('<rect x="100" y="262" width="800" height="12" fill="#6b4a2a"/><rect x="0" y="274" width="1000" height="106" fill="#1a140f"/>')
			for x in range(100, 900, 40):
				s.append('<rect x="%d" y="262" width="2" height="12" fill="#4a3220"/>' % x)
		PUB:
			s.append('<rect x="110" y="262" width="680" height="12" fill="#1f1a18"/><rect x="110" y="262" width="680" height="2" fill="#%s" opacity="0.6"/><rect x="0" y="274" width="1000" height="106" fill="#0d0a09"/>' % _hex(c))
		_:
			s.append('<rect x="0" y="258" width="1000" height="26" fill="#1a1a20"/><rect x="0" y="258" width="1000" height="3" fill="#%s" opacity="0.8"/>' % _hex(c))


static func _crowd(s: PackedStringArray, rng: RandomNumberGenerator, st: int, fill: float, rating: float, attendance: int, c: Color) -> void:
	var hands := clampf((rating - 2.0) / 3.0, 0.0, 1.0)
	# About 160 head slots up front; small crowds get one head per person.
	var density := fill if attendance >= 160 else float(attendance) / 160.0
	# Big venues: a sea of tiny heads (and phone lights) stretching back.
	if st >= ARENA:
		var back_rows := 3 if st == ARENA else 4
		for row in back_rows:
			var y := 280.0 + row * 7.0
			var shade := Color("#0a0a0e").lerp(Color("#14131a"), float(row) / back_rows)
			var x := rng.randf_range(0.0, 8.0)
			while x < 1000.0:
				if rng.randf() < density:
					var r := 4.0 + row * 1.2
					s.append('<circle cx="%d" cy="%d" r="%.1f" fill="#%s"/>' % [x, y, r, _hex(shade)])
					if rng.randf() < 0.05 + hands * 0.12:
						s.append('<rect x="%d" y="%d" width="3" height="5" fill="#e6f0ff" opacity="0.85"/>' % [x + 2, y - 10])
				x += rng.randf_range(7.0, 11.0)
	for row in 4:
		var y := 300.0 + row * 22.0
		var shade := Color("#08080b").lerp(Color("#17161c"), float(3 - row) / 3.0)
		var x := -10.0 + rng.randf_range(0.0, 18.0)
		while x < 1010.0:
			if rng.randf() < density * (0.75 + row * 0.1):
				var r := rng.randf_range(10.0, 14.0)
				var hy := y + rng.randf_range(-6.0, 6.0)
				s.append('<circle cx="%d" cy="%d" r="%d" fill="#%s"/><rect x="%d" y="%d" width="%d" height="80" rx="8" fill="#%s"/>' % [x, hy, r, _hex(shade), x - r * 1.3, hy + r * 0.6, r * 2.6, _hex(shade)])
				if rng.randf() < hands * 0.35:
					var ax2 := x + rng.randf_range(-8.0, 8.0)
					var top := hy - r - rng.randf_range(18.0, 32.0)
					s.append('<path d="M%d %d L%d %d" stroke="#%s" stroke-width="6" stroke-linecap="round"/>' % [x + r * 0.7, hy + r, ax2, top, _hex(shade)])
					var held := rng.randf()
					if held < 0.22:
						# A pint held aloft: a tapered glass you can half see through,
						# darker than the phone screens so it doesn't glow.
						var gx := ax2
						var gy := top - 2.0
						s.append('<polygon points="%.1f,%.1f %.1f,%.1f %.1f,%.1f %.1f,%.1f" fill="#8a5a1c" opacity="0.55"/>' % [gx - 4.0, gy, gx + 4.0, gy, gx + 5.0, gy - 11.0, gx - 5.0, gy - 11.0])
						s.append('<polygon points="%.1f,%.1f %.1f,%.1f %.1f,%.1f %.1f,%.1f" fill="#cfc6b0" opacity="0.5"/>' % [gx - 5.0, gy - 11.0, gx + 5.0, gy - 11.0, gx + 5.2, gy - 14.0, gx - 5.2, gy - 14.0])
						s.append('<polygon points="%.1f,%.1f %.1f,%.1f %.1f,%.1f %.1f,%.1f" fill="none" stroke="#9aa0a8" stroke-width="1" opacity="0.4"/>' % [gx - 4.0, gy, gx + 4.0, gy, gx + 5.2, gy - 14.0, gx - 5.2, gy - 14.0])
						s.append('<path d="M%.1f %.1f L%.1f %.1f" stroke="#ffffff" stroke-width="1" opacity="0.18"/>' % [gx - 2.5, gy - 2.0, gx - 3.2, gy - 12.0])
					elif st >= ARENA and held < 0.5:
						s.append('<rect x="%d" y="%d" width="5" height="8" rx="1" fill="#e6f0ff" opacity="0.9"/>' % [ax2 - 2, top - 8])
			x += rng.randf_range(20.0, 30.0)


## Flames along the front of the stage (bigger when the crowd's loving it).
static func _pyro(s: PackedStringArray, rating: float) -> void:
	var h := 50.0 + clampf(rating - 3.0, 0.0, 2.0) * 25.0
	for fx in [60.0, 160.0, 850.0, 945.0]:
		s.append('<path d="M%d 258 C%d %d %d %d %d %d C%d %d %d %d %d 258 Z" fill="url(#flame)"/>' % [
			fx - 18, fx - 26, 258 - h * 0.5, fx - 4, 258 - h * 0.7, fx, 258 - h,
			fx + 6, 258 - h * 0.6, fx + 26, 258 - h * 0.4, fx + 18])


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
	# The band name, fitted to the style's banner.
	var b: Array = BANNERS[style]
	var r: Rect2 = b[0]
	var k := w / W
	var font: Font = UITheme.F_DISPLAY
	var text := band.to_upper()
	var fs := int(r.size.y * k * 0.7)
	var tw := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	if tw > r.size.x * k * 0.9:
		fs = int(fs * r.size.x * k * 0.9 / tw)
	var ink: Color = Color("#2a2420") if b[1] else (neon if style == PUB else UITheme.TEXT)
	var base := (r.position.y + r.size.y * 0.5) * k + fs * 0.36
	draw_string(font, Vector2(r.position.x * k, base), text, HORIZONTAL_ALIGNMENT_CENTER, r.size.x * k, fs, ink)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		var h := size.x * H / W
		if absf(custom_minimum_size.y - h) > 1.0:
			custom_minimum_size.y = h
		queue_redraw()
