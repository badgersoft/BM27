class_name Portrait
extends RefCounted
## Cartoon portraits built from a "look" dictionary as SVG, then rasterised.
## Keys: skin (0-5), hair, hair_color, facial, glasses, acc, cloth,
## cloth_color, expr, age (0-3), lips, bg.

const SKINS := ["#f6d7c3", "#eac0a0", "#d8a27a", "#b97c55", "#8d5a3b", "#5e3b26"]
const MOUTH := "#3a1a14"

static var _cache: Dictionary = {}


static func _dark(hex: String, amt: float) -> String:
	return "#" + Color(hex).darkened(amt).to_html(false)


static func _light(hex: String, amt: float) -> String:
	return "#" + Color(hex).lightened(amt).to_html(false)


static func svg(look: Dictionary) -> String:
	var skin: String = SKINS[clampi(int(look.get("skin", 1)), 0, SKINS.size() - 1)]
	var skin_d := _dark(skin, 0.16)
	var hair: String = look.get("hair_color", "#2b1d14")
	var style: String = look.get("hair", "short")
	var cloth: String = look.get("cloth", "tee")
	var cc: String = look.get("cloth_color", "#2b2d42")
	var age := int(look.get("age", 1))
	var expr: String = look.get("expr", "smile")
	var bg: String = look.get("bg", "#444455")
	var s := PackedStringArray()
	s.append('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200" width="200" height="200">')
	s.append('<defs><clipPath id="c"><rect x="0" y="0" width="200" height="200" rx="38"/></clipPath>')
	s.append('<clipPath id="b"><path d="M18 200 C22 166 54 154 100 154 C146 154 178 166 182 200 Z"/></clipPath></defs>')
	s.append('<g clip-path="url(#c)">')
	s.append('<rect width="200" height="200" fill="%s"/>' % _dark(bg, 0.35))
	s.append('<circle cx="100" cy="92" r="84" fill="%s"/>' % _dark(bg, 0.12))
	# Hair behind the head (behind body for short styles).
	if style in ["afro", "curly", "bun"]:
		s.append(_hair_back(style, hair))
	s.append(_body(cloth, cc))
	if not style in ["afro", "curly", "bun"]:
		s.append(_hair_back(style, hair))
	s.append('<rect x="86" y="128" width="28" height="34" rx="6" fill="%s"/>' % skin_d)
	s.append('<ellipse cx="56" cy="104" rx="8" ry="12" fill="%s"/><ellipse cx="144" cy="104" rx="8" ry="12" fill="%s"/>' % [skin, skin])
	s.append('<path d="M56 96 C56 58 76 44 100 44 C124 44 144 58 144 96 C144 128 124 151 100 151 C76 151 56 128 56 96 Z" fill="%s"/>' % skin)
	# Age.
	if age >= 2:
		s.append('<path d="M84 70 Q100 65 116 70" stroke="%s" stroke-width="2.4" fill="none" stroke-linecap="round"/>' % skin_d)
		s.append('<path d="M66 100 l-5 -3 M66 105 l-5 1 M134 100 l5 -3 M134 105 l5 1" stroke="%s" stroke-width="2" fill="none" stroke-linecap="round"/>' % skin_d)
	if age >= 3:
		s.append('<path d="M88 76 Q100 72 112 76" stroke="%s" stroke-width="2.2" fill="none" stroke-linecap="round"/>' % skin_d)
		s.append('<path d="M84 116 Q80 126 85 134 M116 116 Q120 126 115 134" stroke="%s" stroke-width="2.2" fill="none" stroke-linecap="round"/>' % skin_d)
	if age == 0:
		s.append('<circle cx="74" cy="119" r="7" fill="#ff7b7b" opacity="0.22"/><circle cx="126" cy="119" r="7" fill="#ff7b7b" opacity="0.22"/>')
	# Eyes and brows.
	var brow := _dark(hair, 0.15) if age < 3 else "#8a8580"
	var lb := "M72 90 Q82 84 92 89"
	var rb := "M108 89 Q118 84 128 90"
	if expr == "smirk":
		rb = "M108 87 Q118 79 128 85"
	elif expr == "flat":
		lb = "M72 89 Q82 87 92 89"
		rb = "M108 89 Q118 87 128 89"
	s.append('<path d="%s %s" stroke="%s" stroke-width="4.2" fill="none" stroke-linecap="round"/>' % [lb, rb, brow])
	s.append('<ellipse cx="82" cy="102" rx="5" ry="5.6" fill="#1d1614"/><ellipse cx="118" cy="102" rx="5" ry="5.6" fill="#1d1614"/>')
	s.append('<circle cx="83.8" cy="100" r="1.6" fill="#ffffff"/><circle cx="119.8" cy="100" r="1.6" fill="#ffffff"/>')
	if look.get("lips", "") != "":
		s.append('<path d="M76 97 l-4 -3 M124 97 l4 -3" stroke="#1d1614" stroke-width="2.2" stroke-linecap="round"/>')
	s.append('<path d="M100 104 Q94 118 99 121 Q103 122 106 119" stroke="%s" stroke-width="3" fill="none" stroke-linecap="round" stroke-linejoin="round"/>' % skin_d)
	s.append(_facial(look.get("facial", "none"), hair))
	s.append(_mouth(expr, look.get("lips", "")))
	s.append(_hair_front(style, hair, skin))
	s.append(_glasses(look.get("glasses", "none")))
	s.append(_acc(look.get("acc", "none"), cc))
	s.append('</g></svg>')
	return "".join(s)


static func _body(cloth: String, cc: String) -> String:
	var dk := _dark(cc, 0.25)
	var lt := _light(cc, 0.25)
	var base := '<path d="M18 200 C22 166 54 154 100 154 C146 154 178 166 182 200 Z" fill="%s"/>' % cc
	match cloth:
		"leather":
			return base + '<path d="M84 155 L72 176 L90 172 L100 200 M116 155 L128 176 L110 172 L100 200" stroke="%s" stroke-width="3" fill="none" stroke-linejoin="round"/><path d="M106 176 L103 200" stroke="#9a9aa6" stroke-width="2"/>' % lt
		"flannel":
			var g := '<g clip-path="url(#b)" stroke="%s" stroke-width="5" opacity="0.55">' % dk
			for x in range(26, 182, 18):
				g += '<path d="M%d 150 V200"/>' % x
			for y in range(162, 200, 16):
				g += '<path d="M10 %d H190"/>' % y
			g += '</g>'
			return base + g + '<path d="M84 155 L100 172 L116 155" stroke="%s" stroke-width="3" fill="none"/>' % dk
		"suit":
			return base + '<path d="M86 155 L100 188 L114 155 Z" fill="#f4f1ea"/><path d="M97 164 L103 164 L105 188 L100 195 L95 188 Z" fill="#c1121f"/><path d="M86 155 L94 180 M114 155 L106 180" stroke="%s" stroke-width="3"/>' % dk
		"hoodie":
			return base + '<path d="M62 164 C70 148 130 148 138 164 C124 175 76 175 62 164 Z" fill="%s"/><path d="M92 170 L90 190 M108 170 L110 190" stroke="#f2efe9" stroke-width="2.5" stroke-linecap="round"/>' % dk
		"cardigan":
			return base + '<path d="M86 155 L100 184 L114 155 Z" fill="%s"/><circle cx="100" cy="190" r="2.6" fill="%s"/><circle cx="100" cy="198" r="2.6" fill="%s"/>' % [lt, dk, dk]
		"denim":
			return base + '<path d="M84 155 L92 172 L100 162 L108 172 L116 155" stroke="%s" stroke-width="3" fill="none"/><path d="M60 182 h22 M118 182 h22" stroke="%s" stroke-width="2.5"/>' % [lt, lt]
		"parka":
			return base + '<path d="M56 168 C64 146 136 146 144 168" stroke="#cdbb98" stroke-width="11" fill="none" stroke-linecap="round"/><path d="M100 168 V200" stroke="%s" stroke-width="3"/>' % dk
	# tee
	return base + '<path d="M84 155 Q100 170 116 155" stroke="%s" stroke-width="4" fill="none"/>' % dk


static func _hair_back(style: String, c: String) -> String:
	match style:
		"long":
			return '<path d="M50 100 C46 52 72 34 100 34 C128 34 154 52 150 100 L158 176 C140 186 60 186 42 176 Z" fill="%s"/>' % c
		"bob":
			return '<path d="M48 98 C46 52 72 36 100 36 C128 36 154 52 152 98 L154 142 C142 150 126 148 120 142 L120 110 L80 110 L80 142 C74 148 58 150 46 142 Z" fill="%s"/>' % c
		"afro":
			return '<circle cx="100" cy="82" r="64" fill="%s"/><circle cx="46" cy="96" r="22" fill="%s"/><circle cx="154" cy="96" r="22" fill="%s"/>' % [c, c, c]
		"curly":
			var out := ""
			for p in [[52, 80, 20], [58, 110, 18], [68, 56, 20], [90, 42, 20], [112, 42, 20], [132, 56, 20], [146, 80, 20], [142, 110, 18], [56, 136, 16], [144, 136, 16]]:
				out += '<circle cx="%d" cy="%d" r="%d" fill="%s"/>' % [p[0], p[1], p[2], c]
			return out
		"mullet":
			return '<path d="M54 96 L48 170 C70 178 130 178 152 170 L146 96 Z" fill="%s"/>' % c
		"ponytail":
			return '<path d="M136 62 C178 70 178 136 156 160 C160 124 154 98 134 84 Z" fill="%s"/>' % c
		"bun":
			return '<circle cx="100" cy="30" r="20" fill="%s"/>' % c
	return ""


static func _hair_front(style: String, c: String, skin: String) -> String:
	match style:
		"short":
			return '<path d="M56 96 C52 52 76 40 100 40 C126 40 150 52 144 96 C140 74 126 62 100 62 C76 62 62 72 56 96 Z" fill="%s"/>' % c
		"spiky":
			return '<path d="M54 94 L56 60 L66 66 L68 40 L82 54 L90 30 L102 50 L112 28 L120 52 L132 38 L134 62 L144 58 L146 94 C138 72 124 62 100 62 C78 62 62 72 54 94 Z" fill="%s"/>' % c
		"fringe":
			return '<path d="M53 104 C49 52 74 37 100 37 C126 37 151 52 147 104 C145 90 141 82 135 80 C120 86 88 88 62 80 C58 86 55 94 53 104 Z" fill="%s"/>' % c
		"quiff":
			return '<path d="M56 96 C54 64 66 50 84 44 C100 24 140 22 152 44 C142 42 130 46 124 56 C140 62 146 78 144 96 C138 74 122 64 100 64 C78 64 62 72 56 96 Z" fill="%s"/>' % c
		"long":
			return '<path d="M56 104 C54 58 76 42 100 42 C124 42 146 58 144 104 C140 80 126 64 104 62 L100 70 L96 62 C76 64 60 80 56 104 Z" fill="%s"/>' % c
		"bob":
			return '<path d="M56 100 C54 56 78 42 100 42 C122 42 146 56 144 100 C142 88 138 80 132 76 C114 80 88 80 68 76 C62 80 58 88 56 100 Z" fill="%s"/>' % c
		"pixie":
			return '<path d="M56 98 C52 54 80 40 104 40 C130 40 148 56 144 94 C136 72 112 60 90 70 C76 74 64 82 56 98 Z" fill="%s"/>' % c
		"bun", "ponytail":
			return '<path d="M57 92 C56 56 78 44 100 44 C122 44 144 56 143 92 C138 70 122 60 100 60 C78 60 62 70 57 92 Z" fill="%s"/>' % c
		"afro":
			return '<path d="M56 92 C50 50 76 36 100 36 C124 36 150 50 144 92 C138 72 124 64 100 64 C76 64 62 72 56 92 Z" fill="%s"/>' % c
		"curly":
			var out := ""
			for p in [[64, 74, 13], [78, 62, 14], [94, 56, 15], [110, 56, 15], [124, 62, 14], [137, 74, 13]]:
				out += '<circle cx="%d" cy="%d" r="%d" fill="%s"/>' % [p[0], p[1], p[2], c]
			return out
		"mullet":
			return '<path d="M56 94 C52 50 76 40 100 40 C126 40 150 50 144 94 C140 72 126 60 100 60 C76 60 62 70 56 94 Z" fill="%s"/>' % c
		"mohawk":
			return '<path d="M58 90 C58 64 74 52 90 50 L90 70 C76 72 64 80 58 90 Z M142 90 C142 64 126 52 110 50 L110 70 C124 72 136 80 142 90 Z" fill="%s" opacity="0.28"/><path d="M90 72 L87 34 L94 18 L100 30 L106 14 L113 32 L110 72 Z" fill="%s"/>' % [c, c]
		"balding":
			return '<path d="M55 106 C52 88 56 76 64 72 L66 104 Z M145 106 C148 88 144 76 136 72 L134 104 Z" fill="%s"/><ellipse cx="86" cy="60" rx="10" ry="6" fill="#ffffff" opacity="0.22"/>' % c
		"bald":
			return '<ellipse cx="86" cy="60" rx="11" ry="7" fill="#ffffff" opacity="0.25"/>'
	return ""


static func _facial(kind: String, c: String) -> String:
	var moustache := '<path d="M84 124 C90 118 98 120 100 123 C102 120 110 118 116 124 C112 129 104 128 100 125 C96 128 88 129 84 124 Z" fill="%s"/>' % c
	match kind:
		"stubble":
			return '<path d="M60 112 C62 138 80 152 100 152 C120 152 138 138 140 112 C132 128 118 124 100 124 C82 124 68 128 60 112 Z" fill="%s" opacity="0.3"/>' % c
		"beard":
			return '<path d="M58 106 C58 140 78 160 100 160 C122 160 142 140 142 106 C136 122 126 120 116 127 C110 123 90 123 84 127 C74 120 64 122 58 106 Z" fill="%s"/>' % c + moustache
		"bigbeard":
			return '<path d="M56 102 C54 150 76 184 100 184 C124 184 146 150 144 102 C138 120 126 118 116 126 C110 122 90 122 84 126 C74 118 62 120 56 102 Z" fill="%s"/>' % c + moustache
		"moustache":
			return moustache
		"goatee":
			return '<path d="M89 139 C91 156 109 156 111 139 C105 143 95 143 89 139 Z" fill="%s"/>' % c + moustache
	return ""


static func _mouth(expr: String, lips: String) -> String:
	var col := MOUTH if lips == "" else lips
	var w := "4" if lips == "" else "5.5"
	match expr:
		"grin":
			return '<path d="M84 129 Q100 151 116 129 Z" fill="#ffffff" stroke="%s" stroke-width="3.5" stroke-linejoin="round"/>' % col
		"smirk":
			return '<path d="M88 134 Q104 139 116 127" stroke="%s" stroke-width="%s" fill="none" stroke-linecap="round"/>' % [col, w]
		"flat":
			return '<path d="M89 135 H111" stroke="%s" stroke-width="%s" fill="none" stroke-linecap="round"/>' % [col, w]
		"open":
			return '<ellipse cx="100" cy="135" rx="8" ry="9.5" fill="%s"/><ellipse cx="100" cy="140" rx="5" ry="3.5" fill="#d9544d"/>' % MOUTH
	return '<path d="M86 131 Q100 143 114 131" stroke="%s" stroke-width="%s" fill="none" stroke-linecap="round"/>' % [col, w]


static func _glasses(kind: String) -> String:
	match kind:
		"round":
			return '<g stroke="#1a1a1a" stroke-width="3.2" fill="#ffffff" fill-opacity="0.12"><circle cx="82" cy="102" r="12"/><circle cx="118" cy="102" r="12"/></g><path d="M94 101 Q100 97 106 101" stroke="#1a1a1a" stroke-width="3" fill="none"/>'
		"square":
			return '<g stroke="#1a1a1a" stroke-width="3.2" fill="#ffffff" fill-opacity="0.12"><rect x="69" y="92" width="26" height="19" rx="4"/><rect x="105" y="92" width="26" height="19" rx="4"/></g><path d="M95 100 H105" stroke="#1a1a1a" stroke-width="3"/>'
		"shades":
			return '<g fill="#121216" stroke="#121216" stroke-width="2"><rect x="67" y="93" width="29" height="17" rx="7"/><rect x="104" y="93" width="29" height="17" rx="7"/></g><path d="M96 99 H104" stroke="#121216" stroke-width="3"/><path d="M72 97 h8" stroke="#ffffff" stroke-width="2" opacity="0.4" stroke-linecap="round"/>'
		"cateye":
			return '<g stroke="#7b1e3a" stroke-width="3.2" fill="#ffffff" fill-opacity="0.1"><path d="M66 94 Q82 90 96 96 Q94 112 82 112 Q70 112 66 94 Z"/><path d="M134 94 Q118 90 104 96 Q106 112 118 112 Q130 112 134 94 Z"/></g><path d="M96 99 H104" stroke="#7b1e3a" stroke-width="3"/>'
	return ""


static func _acc(kind: String, cc: String) -> String:
	match kind:
		"beanie":
			var b := "#3b4a6b" if cc != "#3b4a6b" else "#8b2e2e"
			return '<path d="M54 88 C50 38 150 38 146 88 Z" fill="%s"/><rect x="51" y="78" width="98" height="14" rx="6" fill="%s"/>' % [b, _dark(b, 0.25)]
		"cap":
			return '<path d="M56 82 C56 42 144 42 144 82 Z" fill="#c1121f"/><path d="M118 79 C150 75 172 81 177 90 C150 93 130 90 116 88 Z" fill="#8f0d17"/><circle cx="100" cy="46" r="3" fill="#8f0d17"/>'
		"headphones":
			return '<path d="M50 102 C46 34 154 34 150 102" stroke="#1d1d22" stroke-width="9" fill="none" stroke-linecap="round"/><rect x="40" y="88" width="17" height="30" rx="7" fill="#1d1d22"/><rect x="143" y="88" width="17" height="30" rx="7" fill="#1d1d22"/><rect x="43" y="96" width="5" height="14" rx="2" fill="#00f5d4"/><rect x="152" y="96" width="5" height="14" rx="2" fill="#00f5d4"/>'
		"earring":
			return '<circle cx="55" cy="120" r="3.6" fill="#ffc53d"/>'
		"bandana":
			return '<path d="M54 78 C70 66 130 66 146 78 L146 89 C130 80 70 80 54 89 Z" fill="#c1121f"/><path d="M146 82 L162 74 L158 90 Z" fill="#c1121f"/><circle cx="80" cy="77" r="1.8" fill="#ffffff"/><circle cx="118" cy="76" r="1.8" fill="#ffffff"/>'
		"tophat":
			return '<rect x="64" y="8" width="72" height="46" rx="4" fill="#141414"/><rect x="64" y="40" width="72" height="8" fill="#6b1d1d"/><ellipse cx="100" cy="55" rx="54" ry="9" fill="#141414"/>'
		"headband":
			return '<path d="M56 80 C72 70 128 70 144 80" stroke="#f2efe9" stroke-width="7" fill="none" stroke-linecap="round"/>'
		"flower":
			return '<circle cx="134" cy="62" r="8" fill="#ff7eb6"/><circle cx="134" cy="62" r="3" fill="#ffc53d"/>'
	return ""


## Texture for a look, cached. size: rasterised pixel size.
static func texture(look: Dictionary, size: int = 160) -> Texture2D:
	var key := str(look.hash()) + ":" + str(size)
	if _cache.has(key):
		return _cache[key]
	var img := Image.new()
	if img.load_svg_from_string(svg(look), float(size) / 200.0) != OK:
		img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.generate_mipmaps()
	var t := ImageTexture.create_from_image(img)
	_cache[key] = t
	return t


static func make(look: Dictionary, size: float = 96.0) -> TextureRect:
	var r := TextureRect.new()
	var px := 112 if size <= 72.0 else 224
	r.texture = texture(look, px)
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	r.custom_minimum_size = Vector2(size, size)
	r.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r
