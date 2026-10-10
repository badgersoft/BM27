class_name Charts
extends RefCounted
## Three living charts: National Top 40 singles, the Badgerton & District
## Local Top 20, and the National Album Top 20. Rival releases arrive every
## week, peak and fade; your releases compete against them on "power".

const NAT_SIZE := 40
const LOCAL_SIZE := 20
const ALBUM_SIZE := 20
const SINGLE_PRICE := 0.35
const ALBUM_PRICE := SINGLE_PRICE * 5.0


static func curve(age: int) -> float:
	match age:
		0: return 0.85
		1: return 1.0
		2: return 0.97
	return 0.97 * pow(0.86, age - 2)


static func _pick_artist(local: bool) -> Dictionary:
	var pool: Array = Game.rivals.filter(func(r): return bool(r.local) == local)
	if pool.is_empty():
		return {"name": "Unknown Artist", "genre": "rock"}
	var total := 0.0
	for r in pool:
		total += pow(float(r.fame), 2.0)
	var x := randf() * total
	for r in pool:
		x -= pow(float(r.fame), 2.0)
		if x <= 0.0:
			return r
	return pool[0]


static func _rival_entry(local: bool, base: float, age: int, album: bool = false) -> Dictionary:
	var artist := _pick_artist(local)
	var g: String = artist.genre
	var title: String = NameData.ALBUM[g].pick_random() if album else NameData.SONG[g].pick_random()
	return {"title": title, "artist": artist.name, "base": base, "power": base * curve(age), "age": age,
		"pos": 0, "last": 0, "peak": 0, "player": false, "rel": "", "local": local}


static func _new_nat_base() -> float:
	return 8.0 + 92.0 * pow(randf(), 2.2)


static func _new_local_base() -> float:
	return 4.0 + 46.0 * pow(randf(), 1.6)


static func init_charts() -> void:
	Game.chart_nat = []
	Game.chart_local = []
	Game.chart_album = []
	for i in 70:
		Game.chart_nat.append(_rival_entry(false, _new_nat_base(), randi_range(0, 16)))
	for i in 28:
		Game.chart_local.append(_rival_entry(true, _new_local_base(), randi_range(0, 13)))
	for i in 40:
		Game.chart_album.append(_rival_entry(false, _new_nat_base(), randi_range(0, 16), true))
	for c in [Game.chart_nat, Game.chart_local, Game.chart_album]:
		_rank(c)
		for e in c:
			e.last = e.pos


static func _age_chart(chart: Array, new_count: int, local: bool, album: bool) -> void:
	for e in chart:
		e.age = int(e.age) + 1
		e.power = float(e.base) * curve(int(e.age)) * randf_range(0.95, 1.05)
	var keep: Array = chart.filter(func(e): return int(e.age) <= 30 and float(e.power) > 1.5)
	chart.clear()
	chart.append_array(keep)
	for i in new_count:
		chart.append(_rival_entry(local, _new_local_base() if local else _new_nat_base(), 0, album))


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
	_update_player_releases(advance, rep)


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
			Game.listeners += sales * (0.16 if album else 0.08)
			Game.true_fans += sales * (0.005 if album else 0.002)
			WeekSim.line(rep, "'%s' sold %s copies (%s)." % [rel.title, U.num(sales), U.money(money)], "good")
		# Out of the charts: show it for one more week, then retire it.
		if rel.status == "charting" and nat == 0 and loc == 0 and Game.week > int(rel.week):
			rel.status = "out"
			rel.out_week = Game.week
		elif rel.status == "out" and Game.week > int(rel.out_week):
			rel.status = "gone"


## Add a freshly released single/album to the charts.
static func add_release(rel: Dictionary) -> void:
	var entry := {"title": rel.title, "artist": Game.band_name, "base": float(rel.nat_base), "power": float(rel.nat_base) * curve(0),
		"age": 0, "pos": 0, "last": 0, "peak": 0, "player": true, "rel": rel.id, "local": true}
	if rel.kind == "album":
		Game.chart_album.append(entry)
	else:
		Game.chart_nat.append(entry)
		var le := entry.duplicate()
		le.base = float(rel.local_base)
		le.power = float(rel.local_base) * curve(0)
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
