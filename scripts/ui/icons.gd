class_name Icons
extends RefCounted
## Hand-drawn 24px stroke icons, rasterised from SVG at runtime so they stay
## razor sharp at any UI scale. All icons are white: tint with modulate or
## the Button icon colours.

const RES := 72  # rasterise size in px (downscaled with mipmaps)

const P := {
	"home": '<path d="M3 11l9-7 9 7v9a1 1 0 0 1-1 1h-5v-6h-6v6H4a1 1 0 0 1-1-1z"/>',
	"users": '<circle cx="9" cy="8" r="3.5"/><path d="M2.5 20c.6-3.6 3.3-5.5 6.5-5.5s5.9 1.9 6.5 5.5"/><circle cx="17" cy="9" r="2.5"/><path d="M17 14c2.5 0 4.2 1.5 4.6 4"/>',
	"userX": '<circle cx="9" cy="8" r="3.5"/><path d="M2.5 20c.6-3.6 3.3-5.5 6.5-5.5s5.9 1.9 6.5 5.5"/><path d="M17 8l4 4M21 8l-4 4"/>',
	"userPlus": '<circle cx="9" cy="8" r="3.5"/><path d="M2.5 20c.6-3.6 3.3-5.5 6.5-5.5s5.9 1.9 6.5 5.5"/><path d="M19 7v6M16 10h6"/>',
	"heart": '<path d="M12 20s-7.5-4.6-9.2-9.3C1.7 7.5 3.8 4.5 7 4.5c2 0 3.5 1.1 5 3 1.5-1.9 3-3 5-3 3.2 0 5.3 3 4.2 6.2C19.5 15.4 12 20 12 20z"/>',
	"headphones": '<path d="M4 15v-3a8 8 0 0 1 16 0v3"/><rect x="3" y="14" width="4.5" height="6.5" rx="1.5"/><rect x="16.5" y="14" width="4.5" height="6.5" rx="1.5"/>',
	"funds": '<circle cx="12" cy="12" r="9"/><path d="M14.6 8.4a2.5 2.5 0 0 0-4.6 1.4V16M8 16h8M8.5 12.5h4.5"/>',
	"star": '<path d="M12 3.5l2.6 5.3 5.9.9-4.3 4.1 1 5.8L12 16.9l-5.2 2.7 1-5.8-4.3-4.1 5.9-.9z"/>',
	"starFill": '<path d="M12 3.5l2.6 5.3 5.9.9-4.3 4.1 1 5.8L12 16.9l-5.2 2.7 1-5.8-4.3-4.1 5.9-.9z" fill="#ffffff"/>',
	"hourglass": '<path d="M6 3h12M6 21h12M7 3c0 5 5 6 5 9s-5 4-5 9M17 3c0 5-5 6-5 9s5 4 5 9"/>',
	"calendar": '<rect x="3" y="5" width="18" height="16" rx="2"/><path d="M3 10h18M8 3v4M16 3v4"/>',
	"guitar": '<path d="M11 13l8-8M17 3l4 4"/><path d="M10.3 10.9c-1.5-.7-3.3-.5-4.3.5-.8.8-1 1.9-.7 2.9-1.2.1-2.2.9-2.6 2-.5 1.8.8 3.7 2.8 4.3 1.7.4 3.3-.2 3.9-1.6 1 .4 2.1.2 2.9-.6 1-1 1.2-2.8.5-4.3"/><circle cx="8" cy="16" r="1.3"/>',
	"bass": '<g transform="translate(24 0) scale(-1 1)"><path d="M11 13l9-9M18.5 2.5l3 3"/><path d="M10.3 10.9c-1.3-.6-2.9-.4-3.8.4-.7.7-.9 1.7-.6 2.6-1.1.1-2 .8-2.4 1.8-.5 1.7.8 3.5 2.7 4 1.6.4 3.1-.2 3.7-1.5.9.3 1.9.1 2.6-.6.9-.9 1.1-2.6.4-4"/><path d="M7 15.5l2 2"/></g>',
	"drums": '<ellipse cx="12" cy="10" rx="8" ry="3"/><path d="M4 10v6c0 1.7 3.6 3 8 3s8-1.3 8-3v-6M8 3l3 5M16 3l-3 5"/>',
	"mic": '<rect x="9" y="3" width="6" height="11" rx="3"/><path d="M5.5 11a6.5 6.5 0 0 0 13 0M12 17.5V21M8.5 21h7"/>',
	"note": '<path d="M9 18V5l11-2v13"/><circle cx="6" cy="18" r="3"/><circle cx="17" cy="16" r="3"/>',
	"ticket": '<path d="M4 6h16a1 1 0 0 1 1 1v3a2 2 0 0 0 0 4v3a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1v-3a2 2 0 0 0 0-4V7a1 1 0 0 1 1-1z"/><path d="M15 6v2M15 11v2M15 16v2"/>',
	"chart": '<path d="M3 21h18M6 17v-5M11 17V6M16 17v-8M21 17v-3"/>',
	"disc": '<circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="3"/><path d="M12 6.5A5.5 5.5 0 0 0 6.5 12"/>',
	"news": '<path d="M4 5h13v14a2 2 0 0 0 2 2H6a2 2 0 0 1-2-2z"/><path d="M17 9h3v10a2 2 0 0 1-2 2"/><path d="M7 9h7M7 13h7M7 17h4"/>',
	"sliders": '<path d="M4 6h10M18 6h2M4 12h4M12 12h8M4 18h12M20 18h0"/><circle cx="16" cy="6" r="2"/><circle cx="10" cy="12" r="2"/><circle cx="18" cy="18" r="2"/>',
	"info": '<circle cx="12" cy="12" r="9"/><path d="M12 11v6M12 7.5v.5"/>',
	"play": '<path d="M7 4.5v15l13-7.5z" fill="#ffffff" stroke="none"/>',
	"next": '<path d="M5 4.5v15l11-7.5z" fill="#ffffff" stroke="none"/><path d="M19 5v14"/>',
	"chevR": '<path d="M9 6l6 6-6 6"/>',
	"chevL": '<path d="M15 6l-6 6 6 6"/>',
	"up": '<path d="M12 19V5M5 12l7-7 7 7"/>',
	"down": '<path d="M12 5v14M19 12l-7 7-7-7"/>',
	"triUp": '<path d="M12 6l7 10H5z" fill="#ffffff" stroke="none"/>',
	"triDown": '<path d="M12 18l7-10H5z" fill="#ffffff" stroke="none"/>',
	"minus": '<path d="M5 12h14"/>',
	"plus": '<path d="M12 5v14M5 12h14"/>',
	"x": '<path d="M6 6l12 12M18 6L6 18"/>',
	"check": '<path d="M5 12.5l4.5 4.5L19 7"/>',
	"bolt": '<path d="M13 2L4 14h7l-1 8 9-12h-7z"/>',
	"gift": '<rect x="3" y="8" width="18" height="5" rx="1"/><path d="M5 13v8h14v-8M12 8v13"/><path d="M12 8C10.5 4.5 6.5 4 7 6.5S12 8 12 8zm0 0c1.5-3.5 5.5-4 5-1.5S12 8 12 8z"/>',
	"cash": '<rect x="2" y="6" width="20" height="12" rx="2"/><circle cx="12" cy="12" r="3"/><path d="M6 9.5v.01M18 14.5v.01"/>',
	"pen": '<path d="M4 20l4-1L19 8l-3-3L5 16z"/><path d="M14 7l3 3"/>',
	"megaphone": '<path d="M3 10v4h3l9 5V5l-9 5z"/><path d="M18.5 9a4 4 0 0 1 0 6M7 14l1.5 5.5h2.5L10 15"/>',
	"hat": '<path d="M2.5 17h19"/><path d="M6 17c0-6 1.8-9 6-9s6 3 6 9"/><path d="M6.3 13.5h11.4"/><circle cx="12" cy="20.5" r=".6"/>',
	"moon": '<path d="M20 14.5A8 8 0 0 1 9.5 4a8 8 0 1 0 10.5 10.5z"/>',
	"amp": '<rect x="3" y="4" width="18" height="17" rx="2"/><circle cx="12" cy="14" r="4.5"/><circle cx="12" cy="14" r="1"/><path d="M6.5 7.5h.01M9.5 7.5h.01M12.5 7.5h.01"/>',
	"trophy": '<path d="M8 4h8v5a4 4 0 0 1-8 0z"/><path d="M8 6H5a3 3 0 0 0 3 4M16 6h3a3 3 0 0 1-3 4M12 13v4M9 21h6M10 17h4v4h-4z"/>',
	"flame": '<path d="M12 22c4 0 7-2.8 7-6.8 0-3.7-2.6-6-4-8.7-.8 2-2 3-3 3.3.3-2.8-.6-5.6-3-7.8-.3 3.6-4 6.4-4 11.4C5 19.3 8 22 12 22z"/>',
	"exit": '<path d="M10 4H5v16h5"/><path d="M14 8l4 4-4 4M18 12H9"/>',
	"save": '<path d="M5 3h11l4 4v12a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V5a2 2 0 0 1 1-2z"/><path d="M8 3v5h8V3M8 21v-7h8v7"/>',
	"trash": '<path d="M4 7h16M9 7V4h6v3M6 7l1 13h10l1-13"/>',
	"swap": '<path d="M4 8h15l-3-3M20 16H5l3 3"/>',
	"lock": '<rect x="5" y="11" width="14" height="10" rx="2"/><path d="M8 11V8a4 4 0 0 1 8 0v3"/>',
	"alert": '<path d="M12 3.5l9.5 17h-19z"/><path d="M12 10v5M12 17.8v.01"/>',
	"crown": '<path d="M3 8l4.5 4L12 5l4.5 7L21 8l-2 11H5z"/>',
	"venue": '<path d="M3 21h18M5 21V9l7-5 7 5v12M9.5 21v-5h5v5"/><path d="M9 11h6"/>',
	"mail": '<rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 7.5l9 6 9-6"/>',
	"flag": '<path d="M5 21V4M5 4h12l-2.5 4L17 12H5"/>',
	"film": '<rect x="3" y="4" width="18" height="16" rx="2"/><path d="M7.5 4v16M16.5 4v16M3 9h4.5M3 15h4.5M16.5 9H21M16.5 15H21"/>',
	"refresh": '<path d="M20 11a8 8 0 0 0-14.9-3.5M4 3.5v4h4M4 13a8 8 0 0 0 14.9 3.5M20 20.5v-4h-4"/>',
	"smile": '<circle cx="12" cy="12" r="9"/><path d="M8 14s1.5 2 4 2 4-2 4-2M9 9.5v.01M15 9.5v.01"/>',
	"meh": '<circle cx="12" cy="12" r="9"/><path d="M8.5 15h7M9 9.5v.01M15 9.5v.01"/>',
	"frown": '<circle cx="12" cy="12" r="9"/><path d="M8 16s1.5-2 4-2 4 2 4 2M9 9.5v.01M15 9.5v.01"/>',
	"menu": '<path d="M4 6h16M4 12h16M4 18h16"/>',
	"upgrade": '<path d="M12 20V9M7 14l5-5 5 5M5 4h14"/>',
	"trendUp": '<path d="M3 17l6-6 4 4 8-8"/><path d="M15 7h6v6"/>',
	"trendDown": '<path d="M3 7l6 6 4-4 8 8"/><path d="M15 17h6v-6"/>',
	"bus": '<rect x="3" y="4" width="18" height="13" rx="2"/><path d="M3 10h18M8 4v6M16 4v6"/><circle cx="7.5" cy="19" r="1.5"/><circle cx="16.5" cy="19" r="1.5"/>',
	"search": '<circle cx="11" cy="11" r="6.5"/><path d="M20 20l-4.3-4.3"/>',
	"eye": '<path d="M2 12s3.6-7 10-7 10 7 10 7-3.6 7-10 7S2 12 2 12z"/><circle cx="12" cy="12" r="3"/>',
	"handshake": '<path d="M2 12l4-4 4 2 3-2 4 1 5 3"/><path d="M6 8v7l4 4 2-1 2 1 4-4"/><path d="M10 13l2 2M13 12l2 2"/>',
	"sparkle": '<path d="M12 3v4M12 17v4M3 12h4M17 12h4M6 6l2.5 2.5M15.5 15.5L18 18M6 18l2.5-2.5M15.5 8.5L18 6"/>',
	"shirt": '<path d="M8 3l-5 3 2 4 2-1v12h10V9l2 1 2-4-5-3c-.5 1.5-2 2.5-4 2.5S8.5 4.5 8 3z"/>',
	"radio": '<rect x="3" y="8" width="18" height="12" rx="2"/><path d="M7 8l10-5"/><circle cx="15.5" cy="14" r="3"/><path d="M6.5 12h3M6.5 15h3"/>',
	"vinyl": '<circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="1.5"/><path d="M12 5.5a6.5 6.5 0 0 1 6.5 6.5M12 8.5A3.5 3.5 0 0 1 15.5 12"/>',
	"target": '<circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="5"/><circle cx="12" cy="12" r="1"/>',
	"dot": '<circle cx="12" cy="12" r="5" fill="#ffffff" stroke="none"/>',
}

static var _cache: Dictionary = {}


static func tex(name: String) -> Texture2D:
	if _cache.has(name):
		return _cache[name]
	var body: String = P.get(name, P.info)
	var svg := '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="#ffffff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">%s</svg>' % body
	var img := Image.new()
	if img.load_svg_from_string(svg, float(RES) / 24.0) != OK:
		img = Image.create(RES, RES, false, Image.FORMAT_RGBA8)
	img.generate_mipmaps()
	var t := ImageTexture.create_from_image(img)
	_cache[name] = t
	return t


## A ready-made icon node.
static func make(name: String, size: float = 22.0, color: Color = UITheme.TEXT) -> TextureRect:
	var r := TextureRect.new()
	r.texture = tex(name)
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	r.custom_minimum_size = Vector2(size, size)
	r.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	r.modulate = color
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r


static func role_icon(role: String) -> String:
	return InstrumentData.ROLE_ICONS.get(role, "note")
