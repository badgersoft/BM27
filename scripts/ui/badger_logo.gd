class_name BadgerLogo
extends RefCounted
## The Badger-soft badge: a friendly striped badger face.

const SVG := '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" width="64" height="64"><path d="M10 22 C10 10 20 6 32 6 C44 6 54 10 54 22 C58 34 52 52 32 58 C12 52 6 34 10 22Z" fill="#f2efe9"/><ellipse cx="14" cy="12" rx="5" ry="5" fill="#1a1a1f"/><ellipse cx="50" cy="12" rx="5" ry="5" fill="#1a1a1f"/><ellipse cx="14" cy="12.5" rx="2.4" ry="2.4" fill="#f2efe9"/><ellipse cx="50" cy="12.5" rx="2.4" ry="2.4" fill="#f2efe9"/><path d="M17 10 C21 12 24 22 25 34 C25.5 42 27 50 29 55 C22 52 15 44 13 34 C12 24 13 14 17 10Z" fill="#1a1a1f"/><path d="M47 10 C43 12 40 22 39 34 C38.5 42 37 50 35 55 C42 52 49 44 51 34 C52 24 51 14 47 10Z" fill="#1a1a1f"/><circle cx="21.5" cy="30" r="2.6" fill="#f2efe9"/><circle cx="42.5" cy="30" r="2.6" fill="#f2efe9"/><circle cx="22" cy="30.5" r="1.2" fill="#1a1a1f"/><circle cx="42" cy="30.5" r="1.2" fill="#1a1a1f"/><ellipse cx="32" cy="50" rx="5" ry="3.6" fill="#1a1a1f"/><path d="M29 40 L32 44 L35 40" stroke="#ff3d2e" stroke-width="2.2" fill="none" stroke-linecap="round" stroke-linejoin="round"/></svg>'

static var _tex: Texture2D


static func texture() -> Texture2D:
	if _tex == null:
		var img := Image.new()
		img.load_svg_from_string(SVG, 3.0)
		img.generate_mipmaps()
		_tex = ImageTexture.create_from_image(img)
	return _tex
