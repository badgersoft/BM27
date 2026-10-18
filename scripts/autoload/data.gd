extends Node
## Data autoload: lookups over the static data tables, plus the generators
## that build the musician database and genre-appropriate names.

const DB_SEED := 270027
const PER_ROLE := 50

var genres: Array = GenreData.LIST
var managers: Array = ManagerData.LIST
var practice: Array = VenueData.PRACTICE
var gigs: Array = VenueData.GIGS

var _genre_by_id: Dictionary = {}


func _ready() -> void:
	for g in genres:
		_genre_by_id[g.id] = g


# ------------------------------------------------------------------ lookups

func genre(id: String) -> Dictionary:
	if _genre_by_id.is_empty():
		_ready()
	return _genre_by_id.get(id, genres[0])


func genre_name(id: String) -> String:
	return genre(id).name


func genre_color(id: String) -> Color:
	return Color(genre(id).color)


func manager(id: String) -> Dictionary:
	for m in managers:
		if m.id == id:
			return m
	return managers[0]


func practice_venue(idx: int) -> Dictionary:
	var v: Dictionary = practice[clampi(idx, 0, practice.size() - 1)]
	if str(v.name).contains("{city}"):
		v = v.duplicate()
		v.name = Game.cityize(v.name)
	return v


## A gig venue. With named=true, "{city}" in the name is filled with the
## city the venue is in this month.
func gig_venue(idx: int, named: bool = true) -> Dictionary:
	var v: Dictionary = gigs[clampi(idx, 0, gigs.size() - 1)]
	if not named:
		return v
	var local := VenueData.LOCAL_NAMES.has(v.id) and Game.public != null
	if local or str(v.name).contains("{city}"):
		var c := Game.gig_city_of(idx)
		v = v.duplicate()
		if local:
			v.name = local_venue_name(str(v.id), c)
		v.name = str(v.name).replace("{city}", Game.city_name(c))
	return v


## Small venues have a different name in each city (and each game): the
## village hall might be St Benedict's in one town and St David's in Cardiff.
## The pick is fixed for the game, so a city keeps its hall.
func local_venue_name(id: String, city: int) -> String:
	var pools: Dictionary = VenueData.LOCAL_NAMES[id]
	var pool: Array = (pools.any as Array).duplicate()
	if city >= 0:
		var rid: String = Game.public.regions[Game.public.region_of(city)].id
		pool.append_array(pools.get(rid, []))
	if pool.is_empty():
		return str(gigs[0].name)
	var h := absi(hash("%d:%s:%d" % [Game.public.seed_val, id, city]))
	return str(pool[h % pool.size()])


func instrument(role: String, tier: int) -> Dictionary:
	var list: Array = InstrumentData.TIERS[role]
	return list[clampi(tier, 0, list.size() - 1)]


## 0 = same genre, 1 = same family, 2 = different family
func genre_distance(a: String, b: String) -> int:
	if a == b:
		return 0
	return 1 if genre(a).family == genre(b).family else 2


# ------------------------------------------------------------- musician value

## Signing value in pounds. Free agents with low skill cost nothing.
func musician_value(m: Dictionary) -> int:
	var skill: float = m.skill
	if skill < 24.0 and int(m.tier) == 0:
		return 0
	var v: float = 30.0 * pow(1.11, skill - 24.0)
	v *= 1.0 + maxf(0.0, float(m.pot) - skill) / 50.0
	if int(m.age) > 40:
		v *= 0.8
	match int(m.tier):
		1: v *= 4.0
		2: v *= 20.0
	if v >= 100000.0:
		return int(round(v / 5000.0) * 5000.0)
	if v >= 10000.0:
		return int(round(v / 500.0) * 500.0)
	return int(maxf(50.0, round(v / 50.0) * 50.0))


## The instrument tier a musician of this skill would expect to own.
func expected_inst_tier(skill: float) -> int:
	return clampi(int(skill / 13.0), 0, 7)


# ----------------------------------------------------------- musician builder

## Builds the full musician database. Deterministic: the same 200 musicians
## every game, so players can learn the scene.
func build_musicians() -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = DB_SEED
	var out: Array = []
	var used_names: Dictionary = {}
	var n := 0
	for role in InstrumentData.ROLES:
		var stars: Array = MusicianData.STARS.filter(func(s): return s.role == role)
		for s in stars:
			var m := _make_star(s, rng)
			m.id = "m%03d" % n
			n += 1
			used_names[m.name] = true
			out.append(m)
		var count: int = PER_ROLE - stars.size()
		for i in count:
			var m := _make_freelancer(role, i, count, rng, used_names)
			m.id = "m%03d" % n
			n += 1
			out.append(m)
	# Everyone has a second influence, usually from a neighbouring genre.
	# Its own RNG so it doesn't reshuffle the rest of the database.
	var rng2 := RandomNumberGenerator.new()
	rng2.seed = DB_SEED + 2
	for m in out:
		m.genre2 = second_genre(rng2, m.genre)
	return out


func second_genre(rng: RandomNumberGenerator, first: String) -> String:
	var fam: String = genre(first).family
	var same: Array = genres.filter(func(g): return g.id != first and g.family == fam)
	var other: Array = genres.filter(func(g): return g.id != first)
	var pool: Array = same if (not same.is_empty() and rng.randf() < 0.6) else other
	return pool[rng.randi_range(0, pool.size() - 1)].id


func _base_musician() -> Dictionary:
	return {
		"id": "", "name": "", "role": "", "g": "m", "age": 20, "skill": 10.0, "pot": 20.0, "tier": 0,
		"genre": "rock", "genre2": "indie", "ease": 3, "happy": 60.0, "bio": "", "look": {}, "inst": 0,
		"status": "free", "joined": 0, "original": false, "cooldown": 0, "grudge": false,
		"last_complaint": -99, "gift_fatigue": 0.0, "min_fame": 0, "fame": 0.0, "last_fame_event": -99,
	}


func _make_star(s: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var m := _base_musician()
	m.name = s.name
	m.role = s.role
	m.g = s.g
	m.age = s.age
	m.skill = float(s.skill)
	m.pot = float(s.pot)
	m.tier = s.tier
	m.genre = s.genre
	m.ease = s.ease
	m.bio = s.bio
	m.happy = rng.randf_range(55.0, 80.0)
	m.inst = clampi(expected_inst_tier(m.skill), 5, 7)
	m.min_fame = 35 if s.tier == 1 else 60
	m.fame = 35.0 if s.tier == 1 else 60.0
	var look := random_look(rng, m.g, m.age, m.genre)
	look.glasses = "none"
	look.facial = "none"
	look.acc = "none"
	for k in s.get("look", {}):
		look[k] = s.look[k]
	m.look = look
	return m


func _make_freelancer(role: String, i: int, count: int, rng: RandomNumberGenerator, used: Dictionary) -> Dictionary:
	var m := _base_musician()
	m.role = role
	m.g = "f" if rng.randf() < 0.36 else "m"
	# Spread of grades: lots of hopefuls at the bottom, a few pros at the top.
	var t: float = float(i) / float(maxi(1, count - 1))
	var skill: float
	if t < 0.30:
		skill = rng.randf_range(6.0, 26.0)
	elif t < 0.58:
		skill = rng.randf_range(24.0, 44.0)
	elif t < 0.80:
		skill = rng.randf_range(42.0, 60.0)
	elif t < 0.93:
		skill = rng.randf_range(58.0, 73.0)
	else:
		skill = rng.randf_range(70.0, 82.0)
	var age: int
	var r := rng.randf()
	if r < 0.40:
		age = rng.randi_range(16, 22)
	elif r < 0.72:
		age = rng.randi_range(23, 30)
	elif r < 0.90:
		age = rng.randi_range(31, 42)
	else:
		age = rng.randi_range(43, 62)
	var headroom: float
	if age <= 21:
		headroom = rng.randf_range(18.0, 42.0)
	elif age <= 27:
		headroom = rng.randf_range(10.0, 28.0)
	elif age <= 34:
		headroom = rng.randf_range(4.0, 14.0)
	else:
		headroom = rng.randf_range(0.0, 6.0)
	# The odd hidden gem: a teenage nobody with genuine star potential.
	if age <= 19 and skill < 30.0 and rng.randf() < 0.18:
		headroom = rng.randf_range(55.0, 68.0)
	m.age = age
	m.skill = snappedf(skill, 0.1)
	m.pot = minf(95.0, snappedf(skill + headroom, 0.1))
	m.genre = genres[rng.randi_range(0, genres.size() - 1)].id
	m.ease = rng.randi_range(1, 5)
	m.happy = rng.randf_range(25.0, 85.0)
	m.inst = maxi(0, expected_inst_tier(m.skill) - rng.randi_range(1, 2))
	var name := ""
	for attempt in 20:
		var first: String = (MusicianData.FIRST_F if m.g == "f" else MusicianData.FIRST_M)[rng.randi_range(0, (MusicianData.FIRST_F if m.g == "f" else MusicianData.FIRST_M).size() - 1)]
		var last: String = MusicianData.LAST[rng.randi_range(0, MusicianData.LAST.size() - 1)]
		if rng.randf() < 0.28:
			var nick: String = MusicianData.NICKS[rng.randi_range(0, MusicianData.NICKS.size() - 1)]
			name = "%s \"%s\" %s" % [first, nick, last]
		else:
			name = "%s %s" % [first, last]
		if not used.has(name):
			break
	used[name] = true
	m.name = name
	var quirk: String = MusicianData.QUIRKS[rng.randi_range(0, MusicianData.QUIRKS.size() - 1)]
	var noun: String = {"vocals": "microphone", "guitar": "guitar", "bass": "bass", "drums": "drums"}[role]
	m.bio = quirk.replace("{r}", noun)
	m.look = random_look(rng, m.g, m.age, m.genre)
	return m


## A random cartoon look appropriate to gender, age and genre.
func random_look(rng: RandomNumberGenerator, g: String, age: int, genre_id: String) -> Dictionary:
	var age_band := 0
	if age >= 55:
		age_band = 3
	elif age >= 42:
		age_band = 2
	elif age >= 28:
		age_band = 1
	var hair_m := ["short", "spiky", "long", "fringe", "quiff", "mullet", "curly", "afro", "mohawk", "bald", "balding", "short"]
	var hair_f := ["long", "bob", "pixie", "bun", "curly", "afro", "ponytail", "fringe", "long", "mohawk"]
	var style: String = (hair_f if g == "f" else hair_m)[rng.randi_range(0, (hair_f if g == "f" else hair_m).size() - 1)]
	if age_band < 2 and (style == "bald" or style == "balding"):
		style = "short"
	var natural := ["#1a1412", "#2b1d14", "#4a3324", "#6b4f2a", "#a0522d", "#d9a441", "#e3c27a", "#151515", "#7a5230"]
	var dyed := ["#e01e5a", "#00c2a8", "#7b2cbf", "#39ff14", "#3a86ff", "#ff9f1c", "#f2f2f2"]
	var hair_color: String = natural[rng.randi_range(0, natural.size() - 1)]
	if genre_id in ["punk", "indie", "altrock"] and rng.randf() < 0.3:
		hair_color = dyed[rng.randi_range(0, dyed.size() - 1)]
	if age_band == 3:
		hair_color = ["#e8e4dc", "#c9c9c9", "#9c9c9c"][rng.randi_range(0, 2)]
	elif age_band == 2 and rng.randf() < 0.5:
		hair_color = "#8a8a8a"
	var facial := "none"
	if g == "m":
		var fr := rng.randf()
		if fr < 0.18:
			facial = "stubble"
		elif fr < 0.30:
			facial = "beard"
		elif fr < 0.38:
			facial = "moustache"
		elif fr < 0.45:
			facial = "goatee"
		elif fr < 0.49 and age_band >= 1:
			facial = "bigbeard"
	var glasses := "none"
	var gr := rng.randf()
	if gr < 0.07:
		glasses = "round"
	elif gr < 0.12:
		glasses = "square"
	elif gr < 0.17:
		glasses = "shades"
	var acc := "none"
	var ar := rng.randf()
	if ar < 0.07:
		acc = "beanie"
	elif ar < 0.12:
		acc = "cap"
	elif ar < 0.18:
		acc = "earring"
	elif ar < 0.21:
		acc = "bandana"
	elif ar < 0.24:
		acc = "headphones"
	var cloth_by_genre := {
		"rock": ["leather", "denim", "tee"], "indie": ["cardigan", "tee", "denim"], "grunge": ["flannel", "cardigan", "tee"],
		"metal": ["leather", "tee"], "punk": ["leather", "tee", "hoodie"], "britpop": ["parka", "tee", "suit"],
		"altrock": ["tee", "hoodie", "denim", "cardigan"],
	}
	var cloths: Array = cloth_by_genre.get(genre_id, ["tee"])
	var cloth_colors := ["#1d1d22", "#2b2d42", "#8b2e2e", "#264653", "#3f5f8a", "#6b705c", "#c8553d", "#9d4edd", "#e9c46a", "#f2f2f2", "#e63946", "#2a9d8f"]
	var exprs := ["smile", "grin", "smirk", "flat", "open"]
	var lips := ""
	if g == "f" and rng.randf() < 0.45:
		lips = ["#b23a48", "#9e3b4a", "#7b0d1e", "#c1121f", "#a8323e"][rng.randi_range(0, 4)]
	return {
		"skin": rng.randi_range(0, 5), "hair": style, "hair_color": hair_color, "facial": facial, "glasses": glasses,
		"acc": acc, "cloth": cloths[rng.randi_range(0, cloths.size() - 1)],
		"cloth_color": cloth_colors[rng.randi_range(0, cloth_colors.size() - 1)],
		"expr": exprs[rng.randi_range(0, exprs.size() - 1)], "age": age_band, "lips": lips,
		"bg": genre(genre_id).color,
	}


# ---------------------------------------------------------- name generators

func _plural(word: String) -> String:
	if word.ends_with("y") and not word.substr(word.length() - 2, 1) in ["a", "e", "i", "o", "u"]:
		return word.substr(0, word.length() - 1) + "ies"
	if word.ends_with("s") or word.ends_with("x") or word.ends_with("ch") or word.ends_with("sh"):
		return word + "es"
	return word + "s"


func band_name_options(genre_id: String, count: int = 4) -> Array:
	var pool: Dictionary = NameData.BAND.get(genre_id, NameData.BAND.rock)
	var out: Array = []
	var guard := 0
	while out.size() < count and guard < 200:
		guard += 1
		var pattern: String = NameData.BAND_PATTERNS.pick_random()
		var a: String = pool.A.pick_random()
		var n1: String = pool.N.pick_random()
		var n2: String = pool.N.pick_random()
		if n1 == n2:
			continue
		var name := pattern
		name = name.replace("{A}", a).replace("{X}", pool.X.pick_random())
		name = name.replace("{P}", _plural(n2))
		# Fill noun slots one at a time so "{N} {N}" gets two different nouns.
		var i := name.find("{N}")
		if i >= 0:
			name = name.substr(0, i) + n1 + name.substr(i + 3)
		i = name.find("{N}")
		if i >= 0:
			name = name.substr(0, i) + n2 + name.substr(i + 3)
		if not name in out:
			out.append(name)
	return out


func song_title_options(genre_id: String, used: Array, count: int = 3) -> Array:
	return _title_options(NameData.SONG, genre_id, used, count)


func album_title_options(genre_id: String, used: Array, count: int = 3) -> Array:
	return _title_options(NameData.ALBUM, genre_id, used, count)


## Suggestions that aren't already in any chart or used by you before.
func _title_options(src: Dictionary, genre_id: String, used: Array, count: int) -> Array:
	var taken := Charts.titles_in_use()
	for t in used:
		taken[str(t).to_lower()] = true
	var pool: Array = src.get(genre_id, src.rock).duplicate()
	pool.shuffle()
	var out: Array = []
	for t in pool:
		if not str(t).to_lower() in taken:
			out.append(t)
		if out.size() >= count:
			break
	var guard := 0
	while out.size() < count and guard < 20:
		guard += 1
		var t2 := Charts.fresh_title(genre_id, src == NameData.ALBUM)
		if not t2.to_lower() in taken and not t2 in out:
			out.append(t2)
	return out


func random_song_title() -> String:
	var g: String = genres.pick_random().id
	return NameData.SONG[g].pick_random()
