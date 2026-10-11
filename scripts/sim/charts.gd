class_name Charts
extends RefCounted
## Three living charts: National Top 20 singles, the Local Top 10 for
## your home scene, and the National Album Top 20. Rival releases arrive every
## week, peak and fade; your releases compete against them on "power".
## Each entry has a "shape" (the song's feel, see FEELS) that sets how fast it
## climbs and how long it lasts.

const NAT_SIZE := 20
const LOCAL_SIZE := 10
const ALBUM_SIZE := 20

## Song feels, from catchy to all-in on the genre. rise: power by week until
## it peaks; decay: weekly fade after that. Tuned so a song's lifetime total
## is about the same whatever the feel (a little more for the gamble at 11):
## the feel changes when it sells, not how much.
const FEELS := [
	{"id": "poppy", "name": "Poppy", "rise": [1.0, 1.05], "decay": 0.78},
	{"id": "easy", "name": "Easy on the Ears", "rise": [0.85, 1.0, 1.0], "decay": 0.82},
	{"id": "onpoint", "name": "On Point", "rise": [0.7, 0.88, 1.0, 1.0], "decay": 0.84},
	{"id": "outthere", "name": "A Little Out There", "rise": [0.55, 0.75, 0.92, 1.0, 1.0], "decay": 0.845},
	{"id": "eleven", "name": "Dial Up To 11", "rise": [0.4, 0.55, 0.72, 0.88, 1.0, 1.05, 1.05], "decay": 0.865},
]
const SINGLE_PRICE := 0.35
const ALBUM_PRICE := SINGLE_PRICE * 5.0


static func curve(age: int, shape: int = -1) -> float:
	if shape < 0 or shape >= FEELS.size():
		match age:
			0: return 0.85
			1: return 1.0
			2: return 0.97
		return 0.97 * pow(0.86, age - 2)
	var f: Dictionary = FEELS[shape]
	var rise: Array = f.rise
	if age < rise.size():
		return float(rise[age])
	return float(rise[-1]) * pow(float(f.decay), age - rise.size() + 1)


## Rival songs get a random feel too, weighted toward the middle.
static func _random_shape() -> int:
	return [0, 1, 1, 2, 2, 2, 3, 3, 4].pick_random()


## A rival to release something, weighted by fame but skipping anyone who
## already has two entries in this chart, so no band hogs it.
static func _pick_artist(local: bool, chart: Array) -> Dictionary:
	var busy: Dictionary = {}
	for e in chart:
		busy[e.artist] = int(busy.get(e.artist, 0)) + 1
	var pool: Array = Game.rivals.filter(func(r): return bool(r.local) == local and int(busy.get(r.name, 0)) < 2)
	if pool.is_empty():
		pool = Game.rivals.filter(func(r): return bool(r.local) == local)
	if pool.is_empty():
		return {"name": "Unknown Artist", "genre": "rock"}
	var total := 0.0
	for r in pool:
		total += pow(float(r.fame) + 10.0, 1.4)
	var x := randf() * total
	for r in pool:
		x -= pow(float(r.fame) + 10.0, 1.4)
		if x <= 0.0:
			return r
	return pool[0]


## Titles that can't be used: anything in a chart now, everything you've
## released, every No.1 in the record books, and any rival title from the
## last couple of years.
static func titles_in_use() -> Dictionary:
	var used: Dictionary = {}
	for c in [Game.chart_nat, Game.chart_local, Game.chart_album]:
		for e in c:
			used[str(e.title).to_lower()] = true
	for t in Game.used_titles:
		used[str(t).to_lower()] = true
	for t in Game.flags.get("recent_titles", []):
		used[str(t).to_lower()] = true
	for kind in Game.chart_records:
		for k in Game.chart_records[kind]:
			used[str(Game.chart_records[kind][k].title).to_lower()] = true
	return used


## Made-up titles once the genre's pool has all been used.
const SONG_PATTERNS := ["{A} {N}", "The {N} Song", "{N} Of The {N}", "{A} {N}s", "My {A} {N}", "{N} ({A} Version)", "Last {N} Home"]
const ALBUM_PATTERNS := ["{A} {N}s", "Songs For {A} {N}s", "{N} & {N}", "Live At The {N}", "The {A} Sessions", "{N} Theory", "Return Of The {N}"]


## A title from the genre's pool that isn't taken (see titles_in_use).
## Falls back to other genres, then to a made-up title.
static func fresh_title(genre_id: String, album: bool) -> String:
	var used := titles_in_use()
	var src: Dictionary = NameData.ALBUM if album else NameData.SONG
	var pool: Array = src.get(genre_id, src.rock).duplicate()
	pool.shuffle()
	for t in pool:
		if not str(t).to_lower() in used:
			return t
	var all: Array = []
	for g in src:
		all.append_array(src[g])
	all.shuffle()
	for t in all:
		if not str(t).to_lower() in used:
			return t
	var w: Dictionary = NameData.BAND.get(genre_id, NameData.BAND.rock)
	for i in 80:
		var t2: String = (ALBUM_PATTERNS if album else SONG_PATTERNS).pick_random()
		t2 = t2.replace("{A}", w.A.pick_random())
		while "{N}" in t2:
			var at := t2.find("{N}")
			t2 = t2.substr(0, at) + str(w.N.pick_random()) + t2.substr(at + 3)
		if not t2.to_lower() in used:
			return t2
	return "Untitled #%d" % randi_range(2, 999)


static func _remember_title(t: String) -> void:
	var recent: Array = Game.flags.get("recent_titles", [])
	recent.append(t)
	# About two years of rival releases.
	Game.flags.recent_titles = recent.slice(maxi(0, recent.size() - 600))


static func _rival_entry(chart: Array, local: bool, base: float, age: int, album: bool = false) -> Dictionary:
	var artist := _pick_artist(local, chart)
	var title := fresh_title(artist.genre, album)
	_remember_title(title)
	var shape := _random_shape()
	return {"title": title, "artist": artist.name, "base": base, "power": base * curve(age, shape), "age": age,
		"pos": 0, "last": 0, "peak": 0, "player": false, "rel": "", "local": local, "shape": shape, "wk1": 0}


static func _new_nat_base() -> float:
	return 8.0 + 92.0 * pow(randf(), 2.2)


static func _new_local_base() -> float:
	return 4.0 + 46.0 * pow(randf(), 1.6)


static func init_charts() -> void:
	Game.chart_nat = []
	Game.chart_local = []
	Game.chart_album = []
	Game.flags.recent_titles = []
	for i in 70:
		Game.chart_nat.append(_rival_entry(Game.chart_nat, false, _new_nat_base(), randi_range(0, 16)))
	for i in 28:
		Game.chart_local.append(_rival_entry(Game.chart_local, true, _new_local_base(), randi_range(0, 13)))
	for i in 40:
		Game.chart_album.append(_rival_entry(Game.chart_album, false, _new_nat_base(), randi_range(0, 16), true))
	for c in [Game.chart_nat, Game.chart_local, Game.chart_album]:
		_rank(c)
		for e in c:
			e.last = e.pos


static func _age_chart(chart: Array, new_count: int, local: bool, album: bool) -> void:
	for e in chart:
		e.age = int(e.age) + 1
		# A rare sleeper hit: a catchy song that comes roaring back.
		if int(e.get("sleeper", -1)) == int(e.age):
			e.base = float(e.base) * 2.2
			if bool(e.player) and not local:
				_sleeper_news(e)
		e.power = float(e.base) * curve(int(e.age), int(e.get("shape", -1))) * randf_range(0.95, 1.05)
	var keep: Array = chart.filter(func(e): return int(e.age) <= 30 and float(e.power) > 1.5)
	chart.clear()
	chart.append_array(keep)
	for i in new_count:
		chart.append(_rival_entry(chart, local, _new_local_base() if local else _new_nat_base(), 0, album))


static func _sleeper_news(e: Dictionary) -> void:
	Game.add_inbox("'%s' is back!" % e.title, "Weeks after it faded, '%s' has been picked up by a TV advert and a thousand videos. It's flying back up the chart." % e.title, "trendUp", "good")


static func _rank(chart: Array) -> void:
	chart.sort_custom(func(a, b): return float(a.power) > float(b.power))
	for i in chart.size():
		var e: Dictionary = chart[i]
		e.last = int(e.pos)
		e.pos = i + 1
		if int(e.peak) == 0 or e.pos < int(e.peak):
			e.peak = e.pos


## advance=true: a week has passed (age, new releases, sales).
## advance=false: just re-rank (e.g. right after you release something).
static func weekly_update(advance: bool, rep: Dictionary = {}) -> void:
	if advance:
		_age_chart(Game.chart_nat, randi_range(4, 5), false, false)
		_age_chart(Game.chart_local, randi_range(1, 2), true, false)
		_age_chart(Game.chart_album, 2, false, true)
	for c in [Game.chart_nat, Game.chart_local, Game.chart_album]:
		_rank(c)
	if advance:
		_track_number_ones()
	_update_player_releases(advance, rep)


## The record books: every national No.1 single and album, and how many
## weeks it spent at the top.
static func _track_number_ones() -> void:
	for pair in [["single", Game.chart_nat], ["album", Game.chart_album]]:
		var chart: Array = pair[1]
		if chart.is_empty():
			continue
		var top: Dictionary = chart[0]
		top.wk1 = int(top.get("wk1", 0)) + 1
		var book: Dictionary = Game.chart_records.get(pair[0], {})
		var key := "%s|%s" % [top.title, top.artist]
		var r: Dictionary = book.get(key, {"title": top.title, "artist": top.artist, "weeks": 0, "first": Game.week, "player": bool(top.player)})
		r.weeks = int(r.weeks) + 1
		r.last = Game.week
		book[key] = r
		Game.chart_records[pair[0]] = book


## Number ones sorted by weeks at the top (most first).
static func records(kind: String, limit: int = 10) -> Array:
	var out: Array = (Game.chart_records.get(kind, {}) as Dictionary).values()
	out.sort_custom(func(a, b): return int(a.weeks) > int(b.weeks) if int(a.weeks) != int(b.weeks) else int(a.first) < int(b.first))
	return out.slice(0, limit)


static func _find_pos(chart: Array, rel_id: String) -> int:
	for e in chart:
		if e.rel == rel_id:
			return int(e.pos)
	return 0


static func _update_player_releases(advance: bool, rep: Dictionary) -> void:
	for rel in Game.releases:
		if rel.status == "gone":
			continue
		var album: bool = rel.kind == "album"
		var nat := _find_pos(Game.chart_album if album else Game.chart_nat, rel.id)
		var size := ALBUM_SIZE if album else NAT_SIZE
		if nat > size:
			nat = 0
		var loc := 0
		if not album:
			loc = _find_pos(Game.chart_local, rel.id)
			if loc > LOCAL_SIZE:
				loc = 0
		rel.last_nat = int(rel.nat_pos)
		rel.last_local = int(rel.local_pos)
		rel.nat_pos = nat
		rel.local_pos = loc
		if nat > 0 and (int(rel.peak_nat) == 0 or nat < int(rel.peak_nat)):
			rel.peak_nat = nat
		if loc > 0 and (int(rel.peak_local) == 0 or loc < int(rel.peak_local)):
			rel.peak_local = loc
		if not album and nat > 0 and nat <= 20 and not bool(rel.top20):
			rel.top20 = true
			Game.flags.top20_since_album = int(Game.flags.top20_since_album) + 1
		if album and nat > 0:
			if int(Game.stats.best_album) == 0 or nat < int(Game.stats.best_album):
				Game.stats.best_album = nat
		elif nat > 0:
			if int(Game.stats.best_nat) == 0 or nat < int(Game.stats.best_nat):
				Game.stats.best_nat = nat
		if not advance:
			continue
		# Sales for the week just gone.
		var sales := 0.0
		if nat > 0:
			sales = (60000.0 if album else 120000.0) / pow(nat, 1.1) * randf_range(0.9, 1.1)
		elif loc > 0:
			sales = 900.0 / pow(loc, 0.8) * randf_range(0.9, 1.1)
		var money := sales * (ALBUM_PRICE if album else SINGLE_PRICE) * Settings.income_mult()
		rel.sales = int(sales)
		rel.total_sales = int(rel.total_sales) + int(sales)
		rel.revenue = float(rel.revenue) + money
		if sales > 0.0:
			rel.weeks_on = int(rel.weeks_on) + 1
			Game.earn(money)
			# A national hit spreads you nationwide; a local hit around your region.
			var pub := Game.public
			if nat > 0 and pub.stage >= 1:
				pub.unlock(2)
				pub.pulse(Public.SCOPE_NATIONAL, 0.004 * float(NAT_SIZE + 1 - nat) / NAT_SIZE)
			var feel := int(rel.get("feel", 2))
			pub.add_listeners(sales * (0.16 if album else 0.08) * Events.FEEL_LISTENERS[feel], Public.SCOPE_NATIONAL if nat > 0 else Public.SCOPE_REGION, Events.FEEL_BREADTH[feel])
			pub.deepen(sales * (0.005 if album else 0.002))
			WeekSim.line(rep, "'%s' sold %s copies (%s)." % [rel.title, U.num(sales), U.money(money)], "good")
		# Out of the charts: show it for one more week, then retire it.
		if rel.status == "charting" and nat == 0 and loc == 0 and Game.week > int(rel.week):
			rel.status = "out"
			rel.out_week = Game.week
		elif rel.status == "out" and Game.week > int(rel.out_week):
			rel.status = "gone"


## Add a freshly released single/album to the charts.
static func add_release(rel: Dictionary) -> void:
	var shape := int(rel.get("feel", 2))
	var entry := {"title": rel.title, "artist": Game.band_name, "base": float(rel.nat_base), "power": float(rel.nat_base) * curve(0, shape),
		"age": 0, "pos": 0, "last": 0, "peak": 0, "player": true, "rel": rel.id, "local": true, "shape": shape,
		"sleeper": int(rel.get("sleeper", -1)), "wk1": 0}
	if rel.kind == "album":
		Game.chart_album.append(entry)
	else:
		Game.chart_nat.append(entry)
		var le := entry.duplicate()
		le.base = float(rel.local_base)
		le.power = float(rel.local_base) * curve(0, shape)
		Game.chart_local.append(le)
	weekly_update(false)


## Local scene singles in the charts right now (for the HQ chart panel).
static func local_rival_entries(limit: int = 4) -> Array:
	var out: Array = []
	for e in Game.chart_local:
		if not bool(e.player) and int(e.pos) <= LOCAL_SIZE:
			out.append(e)
		if out.size() >= limit:
			break
	return out
