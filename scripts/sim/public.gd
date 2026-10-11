class_name Public
extends RefCounted
## The music-loving public: ~29,000 named people across 9 UK regions.
##
## Everyone is generated from a seed. Their fixed traits (city, gender, age,
## favourite genres, gig likelihood, variance, loyalty, name) are rebuilt
## from that seed on load, so saves only store how they feel about the band.
## Data lives in packed arrays (one entry per person) to stay fast and small
## on phones.
##
## Fan ladder, driven by each person's fanatic score (0-100):
##   Not a fan -> Listener -> Regular listener -> Fan -> Super fan
## Promotion and demotion thresholds differ slightly so people don't flicker.

const NOT_FAN := 0
const LISTENER := 1
const REGULAR := 2
const FAN := 3
const SUPER := 4
const TIER_NAMES := ["Not a fan", "Listener", "Regular listener", "Fan", "Super fan"]
const TIER_DESC := [
	"Hasn't heard of you, or isn't bothered.",
	"Casually listens to you now and then.",
	"Listens a lot. Likely to become a fan or tell their mates.",
	"Seeks you out. Comes to local gigs and may travel to see you.",
	"Long-term devotee. Nearly always there locally, and happy to travel.",
]
const UP := [0.0, 8.0, 20.0, 40.0, 70.0]
const DOWN := [0.0, 5.0, 16.0, 35.0, 62.0]
const SUPER_WEEKS := 24  # six months as a fan before anyone can be a super fan

## Where an effect lands.
const SCOPE_LOCAL := 0     # your home city
const SCOPE_REACH := 1     # wherever you've spread to so far
const SCOPE_REGION := 2    # your home region
const SCOPE_NATIONAL := 3  # the whole country
const STAGE_NAMES := ["Local", "Regional", "National"]

# Chance to attend a gig in your own city, by tier...
const ATTEND := [0.0, 0.035, 0.12, 0.55, 0.9]
# ...and how much of that survives travelling within the region / further.
const TRAVEL_REGION := [0.0, 0.10, 0.25, 0.45, 0.75]
const TRAVEL_FAR := [0.0, 0.01, 0.04, 0.12, 0.40]

var seed_val := 0
var cities: Array = []    # {name, region, start, count, cost, top_genres}
var regions: Array = []   # {id, name, short, cities: [city idx]}
var names: PackedStringArray = []
var genre_ids: Array = []
var genre_family: PackedByteArray = []

# Fixed traits, one entry per person.
var city: PackedByteArray = []
var gender: PackedByteArray = []   # 0 female, 1 male
var age: PackedByteArray = []
var g1: PackedByteArray = []       # favourite genre
var g2: PackedByteArray = []       # second favourite
var gig: PackedByteArray = []      # likelihood to go to gigs, 0-100
var variance: PackedByteArray = [] # appetite for new music / boredom, 0-100
var loyalty: PackedByteArray = []  # how much bad times they'll put up with, 0-100
var name_idx: PackedInt32Array = []

# How each person feels about the band.
var fanatic: PackedFloat32Array = []
var tier: PackedByteArray = []
var fan_weeks: PackedInt32Array = []

# Per city: how much your music is circulating there (0-1).
var exposure: PackedFloat32Array = []
var base_city := -1
var stage := 0
var momentum := 0.0   # band-wide mood swing from recent good/bad news
var hear_mult := 1.0     # manager perks: how quickly new people discover you
var boredom_mult := 1.0  # difficulty / perks: how quickly people drift off

# Derived, rebuilt by _recount().
var tier_count: Array = [0, 0, 0, 0, 0]
var city_tier: Array = []
var city_active: PackedInt32Array = []
var engaged: PackedInt32Array = []
var _dirty := true
var _taste_genre := ""
var _taste: PackedFloat32Array = []


# ================================================================ generation

func generate(seed_value: int) -> void:
	seed_val = seed_value
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	genre_ids = []
	var families: Dictionary = {}
	genre_family = PackedByteArray()
	for g in Data.genres:
		genre_ids.append(g.id)
		if not families.has(g.family):
			families[g.family] = families.size()
		genre_family.append(families[g.family])
	_build_names()
	_build_geography(rng)
	var total := 0
	for c in cities:
		total += int(c.count)
	# Packed arrays are value types: resize each one directly.
	city.resize(total)
	gender.resize(total)
	age.resize(total)
	g1.resize(total)
	g2.resize(total)
	gig.resize(total)
	variance.resize(total)
	loyalty.resize(total)
	tier.resize(total)
	name_idx.resize(total)
	fanatic.resize(total)
	fan_weeks.resize(total)
	fanatic.fill(0.0)
	tier.fill(0)
	fan_weeks.fill(0)
	var ng := genre_ids.size()
	for ci in cities.size():
		var c: Dictionary = cities[ci]
		var reg: Dictionary = regions[int(c.region)]
		var flavour: Dictionary = RegionData.REGIONS[int(c.region)].cities[int(c.local_idx)].flavour
		# Genre weights per age band for this city, with this game's drift.
		var drift := _scene_drift(rng)
		var weights: Array = []
		for band in 4:
			var w := PackedFloat32Array()
			for gi2 in ng:
				var g: String = genre_ids[gi2]
				w.append(float(RegionData.GENRE_POP[g]) * float(flavour.get(g, 1.0)) * float(RegionData.GENRE_AGE[g][band]) * drift[gi2])
			weights.append(w)
		var hist := PackedInt32Array()
		hist.resize(ng)
		hist.fill(0)
		for k in int(c.count):
			var i: int = int(c.start) + k
			city[i] = ci
			var gnd := 1 if rng.randf() < 0.5 else 0
			gender[i] = gnd
			var a := _random_age(rng)
			age[i] = a
			var band := 0 if a < 25 else (1 if a < 40 else (2 if a < 60 else 3))
			var w1: PackedFloat32Array = weights[band]
			var fav := _weighted(rng, w1, -1, -1)
			var second := _weighted(rng, w1, fav, genre_family[fav])
			g1[i] = fav
			g2[i] = second
			hist[fav] += 1
			gig[i] = clampi(int(_gig_base(a) + rng.randf_range(-25.0, 25.0)), 2, 100)
			variance[i] = clampi(int(90.0 - (a - 14) * 1.1 + rng.randf_range(-18.0, 18.0)), 3, 100)
			loyalty[i] = clampi(int(30.0 + (a - 14) * 0.6 + rng.randf_range(-25.0, 25.0)), 3, 100)
			name_idx[i] = _random_name(rng, gnd, str(reg.id))
		# The two biggest genres in town.
		var order: Array = range(ng)
		order.sort_custom(func(x, y): return hist[x] > hist[y])
		c.top_genres = [genre_ids[order[0]], genre_ids[order[1]], genre_ids[order[2]]]
		c.genre_share = {}
		for gi in ng:
			c.genre_share[genre_ids[gi]] = float(hist[gi]) / float(c.count)
	exposure = PackedFloat32Array()
	exposure.resize(cities.size())
	exposure.fill(0.0)
	base_city = -1
	stage = 0
	momentum = 0.0
	_dirty = true
	_taste_genre = ""


func _build_geography(rng: RandomNumberGenerator) -> void:
	cities = []
	regions = []
	var start := 0
	for ri in RegionData.REGIONS.size():
		var r: Dictionary = RegionData.REGIONS[ri]
		var reg := {"id": r.id, "name": r.name, "short": r.short, "cities": []}
		for li in r.cities.size():
			var cd: Dictionary = r.cities[li]
			var count: int
			if r.id == "lon":
				count = int(round(RegionData.LONDON_POP * rng.randf_range(0.9, 1.1)))
			else:
				count = int(round(RegionData.BASE_POP * float(cd.size) * rng.randf_range(0.96, 1.04)))
			var c := {"name": cd.name, "region": ri, "local_idx": li, "start": start, "count": count,
				"cost": snappedf(pow(float(count) / RegionData.BASE_POP, 0.55), 0.01)}
			reg.cities.append(cities.size())
			cities.append(c)
			start += count
		regions.append(reg)


## Each game, every city's scene shifts a little: one genre is having a
## moment, the rest wobble. So the same city won't sound the same every time.
func _scene_drift(rng: RandomNumberGenerator) -> PackedFloat32Array:
	var d := PackedFloat32Array()
	for gi in genre_ids.size():
		d.append(rng.randf_range(0.8, 1.25))
	d[rng.randi_range(0, genre_ids.size() - 1)] *= 1.35
	return d


func _build_names() -> void:
	names = PackedStringArray()
	for n in RegionData.NAMES_F:
		names.append(n)
	for n in RegionData.NAMES_M:
		names.append(n)
	for rid in RegionData.REGION_NAMES:
		for n in RegionData.REGION_NAMES[rid].f:
			names.append(n)
		for n in RegionData.REGION_NAMES[rid].m:
			names.append(n)


func _random_name(rng: RandomNumberGenerator, gnd: int, region_id: String) -> int:
	var nf := RegionData.NAMES_F.size()
	var nm := RegionData.NAMES_M.size()
	if RegionData.REGION_NAMES.has(region_id) and rng.randf() < 0.4:
		var offset := nf + nm
		for rid in RegionData.REGION_NAMES:
			var pool: Dictionary = RegionData.REGION_NAMES[rid]
			if rid == region_id:
				if gnd == 0:
					return offset + rng.randi_range(0, pool.f.size() - 1)
				return offset + pool.f.size() + rng.randi_range(0, pool.m.size() - 1)
			offset += pool.f.size() + pool.m.size()
	if gnd == 0:
		return rng.randi_range(0, nf - 1)
	return nf + rng.randi_range(0, nm - 1)


func _random_age(rng: RandomNumberGenerator) -> int:
	var r := rng.randf()
	if r < 0.10: return rng.randi_range(14, 17)
	if r < 0.34: return rng.randi_range(18, 24)
	if r < 0.58: return rng.randi_range(25, 34)
	if r < 0.80: return rng.randi_range(35, 49)
	if r < 0.94: return rng.randi_range(50, 64)
	return rng.randi_range(65, 80)


func _gig_base(a: int) -> float:
	var v := 45.0
	for pair in RegionData.GIG_BY_AGE:
		if a >= int(pair[0]):
			v = float(pair[1])
	return v


## Weighted pick; when excluding the favourite, same-family genres are
## twice as likely (metalheads' second love is usually rock, not EDM).
func _weighted(rng: RandomNumberGenerator, w: PackedFloat32Array, exclude: int, family: int) -> int:
	var total := 0.0
	for gi in w.size():
		if gi != exclude:
			total += w[gi] * (2.0 if family >= 0 and genre_family[gi] == family else 1.0)
	var x := rng.randf() * total
	for gi in w.size():
		if gi == exclude:
			continue
		x -= w[gi] * (2.0 if family >= 0 and genre_family[gi] == family else 1.0)
		if x <= 0.0:
			return gi
	return 0 if exclude != 0 else 1


# ============================================================== geography

func size() -> int:
	return fanatic.size()


func region_of(c: int) -> int:
	return int(cities[c].region)


func city_name(c: int) -> String:
	return cities[c].name


func region_name(r: int) -> String:
	return regions[r].name


func city_cost(c: int) -> float:
	return float(cities[c].cost) if c >= 0 else 1.0


func find_city(name: String) -> int:
	for i in cities.size():
		if cities[i].name == name:
			return i
	return -1


## Cities a home-grown band spreads to first. London's scene spills into
## the South East, since London is a one-city region.
func home_area(c: int = -1) -> Array:
	if c < 0:
		c = base_city
	var r := region_of(c)
	var out: Array = regions[r].cities.duplicate()
	if regions[r].id == "lon":
		for ri in regions.size():
			if regions[ri].id == "se":
				out.append_array(regions[ri].cities)
	return out


func set_base(c: int) -> void:
	base_city = c
	for i in exposure.size():
		exposure[i] = 0.0
	exposure[c] = 0.04
	stage = 0


## Mum, Nan, your mate from school... the very first fans: locals who
## genuinely like your sound (and, for the fans, the loyal sort).
func seed_first_fans(fans: int, listeners: int) -> void:
	var c: Dictionary = cities[base_city]
	var picked := 0
	var guard := 0
	while picked < fans + listeners and guard < 20000:
		guard += 1
		var i: int = int(c.start) + randi() % int(c.count)
		if fanatic[i] > 0.0:
			continue
		var want_fan := picked < fans
		if guard < 15000 and (taste(i) < (0.6 if want_fan else 0.3) or (want_fan and loyalty[i] < 60)):
			continue
		fanatic[i] = randf_range(55.0, 62.0) if want_fan else randf_range(9.0, 14.0)
		_update_tier(i, false)
		picked += 1
	_dirty = true


# ================================================================== taste

## How much someone with these favourites likes the band's genre.
func _ensure_taste(genre_id: String) -> void:
	if genre_id == _taste_genre and not _taste.is_empty():
		return
	_taste = _taste_table(genre_id)
	_taste_genre = genre_id


func _taste_table(genre_id: String) -> PackedFloat32Array:
	var gi := genre_ids.find(genre_id)
	var n := genre_ids.size()
	var t := PackedFloat32Array()
	t.resize(n * n)
	for a in n:
		for b in n:
			# With only seven genres, plenty of people like yours a bit: it's
			# the ones who really love it who become fans.
			var v := 0.07   # guitar music fans give other guitar bands a fair hearing
			if a == gi:
				v = 1.0
			elif b == gi:
				v = 0.45
			elif genre_family[a] == genre_family[gi]:
				v = 0.2
			elif genre_family[b] == genre_family[gi]:
				v = 0.12
			t[a * n + b] = v
	return t


func taste(i: int) -> float:
	return _taste[g1[i] * genre_ids.size() + g2[i]]


# ================================================================== tiers

func _update_tier(i: int, weekly: bool) -> void:
	var f := fanatic[i]
	var t := int(tier[i])
	while t < SUPER and f >= UP[t + 1] and (t + 1 != SUPER or fan_weeks[i] >= SUPER_WEEKS):
		t += 1
	while t > NOT_FAN and f < DOWN[t]:
		t -= 1
	tier[i] = t
	if t >= FAN:
		if weekly:
			fan_weeks[i] += 1
	else:
		fan_weeks[i] = 0


func _recount() -> void:
	tier_count = [0, 0, 0, 0, 0]
	city_tier = []
	city_active = PackedInt32Array()
	city_active.resize(cities.size())
	city_active.fill(0)
	for c in cities.size():
		city_tier.append([0, 0, 0, 0, 0])
	var eng := PackedInt32Array()
	for i in fanatic.size():
		var t := int(tier[i])
		var c := int(city[i])
		tier_count[t] += 1
		city_tier[c][t] += 1
		if fanatic[i] > 0.0:
			city_active[c] += 1
		if t >= LISTENER:
			eng.append(i)
	engaged = eng
	_dirty = false


func _ensure() -> void:
	if _dirty:
		_recount()


func count(t: int) -> int:
	_ensure()
	return tier_count[t]


## People at or above a tier.
func count_at_least(t: int) -> int:
	_ensure()
	var s := 0
	for k in range(t, 5):
		s += tier_count[k]
	return s


func city_counts(c: int) -> Array:
	_ensure()
	return city_tier[c]


func real_fans() -> int:
	return count_at_least(FAN)


# ======================================================== representation

## The UK music public in real people. The simulated people are a sample.
const TOTAL_REAL := 10000000

## How many real people each simulated person stands for, by how many people
## are in a group: [group size up to, each extra person counts as]. Only the
## people inside a band get its weight (like tax bands), so totals never jump.
const BANDS := [[100, 1.0], [500, 2.0], [1500, 5.0], [3000, 15.0], [6000, 40.0], [12000, 100.0], [1000000000, 300.0]]


## Real people represented by a group of n simulated people.
static func represent(n: float) -> float:
	var total := 0.0
	var prev := 0.0
	for b in BANDS:
		var top := float(b[0])
		if n <= top:
			return total + (n - prev) * float(b[1])
		total += (top - prev) * float(b[1])
		prev = top
	return total


## What the next person added to a group of n would count as.
static func marginal(n: float) -> float:
	for b in BANDS:
		if n < float(b[0]):
			return float(b[1])
	return float(BANDS[BANDS.size() - 1][1])


## Real people at or above a tier. The curve is applied from the top down
## ("super fans", "fans and up", "regulars and up"...), so promoting someone
## from fan to super fan can never make your fan total drop.
func real_at_least(t: int) -> float:
	if t <= NOT_FAN:
		return float(TOTAL_REAL)
	return represent(count_at_least(t))


## Real people in exactly this tier. "Not a fan" is everyone else.
func real_tier(t: int) -> float:
	if t == NOT_FAN:
		return maxf(0.0, TOTAL_REAL - real_at_least(LISTENER))
	if t == SUPER:
		return real_at_least(SUPER)
	return real_at_least(t) - real_at_least(t + 1)


## Average real people per simulated person in a tier.
func tier_weight(t: int) -> float:
	var c := count(t)
	if c <= 0:
		return marginal(count_at_least(t))
	return real_tier(t) / float(c)


## Real people for a set of simulated people by tier (e.g. a gig crowd).
func real_of(counts: Array) -> Dictionary:
	var fans := float(counts[FAN]) * tier_weight(FAN) + float(counts[SUPER]) * tier_weight(SUPER)
	var lis := float(counts[LISTENER]) * tier_weight(LISTENER) + float(counts[REGULAR]) * tier_weight(REGULAR)
	return {"fans": fans, "listeners": lis, "super": float(counts[SUPER]) * tier_weight(SUPER), "total": fans + lis}


## Simulated people needed to make `real` new people at a tier.
func _people_from_real(real: float, at_tier: int = LISTENER) -> int:
	var p := real / marginal(count_at_least(at_tier))
	var n := int(floor(p))
	if randf() < p - n:
		n += 1
	return n


# ================================================================ weekly

## One week of word of mouth, listening, boredom and loyalty.
## quality: how good the band is right now (~0.35-2). Returns news lines.
func step(genre_id: String, quality: float) -> Array:
	_ensure()
	_ensure_taste(genre_id)
	_update_exposure()
	var ng := genre_ids.size()
	var mom := momentum
	for ci in cities.size():
		var e: float = exposure[ci]
		if e <= 0.001 and city_active[ci] == 0:
			continue
		var c: Dictionary = cities[ci]
		var s: int = c.start
		for i in range(s, s + int(c.count)):
			var f: float = fanatic[i]
			var t: float = _taste[g1[i] * ng + g2[i]]
			var o: float = variance[i] * 0.01
			if f < 3.0:
				# Not into you (yet): a chance to hear you for the first time.
				if e > 0.0 and randf() < e * 0.10 * (0.3 + o) * t * hear_mult:
					f += randf_range(4.0, 9.0) * quality
				elif f > 0.0:
					f = maxf(0.0, f - 0.3)
			else:
				var l: float = loyalty[i] * 0.01
				# Growth slows sharply near the top: hardly anyone reaches 100.
				var growth: float = (0.06 + e * 0.7) * t * quality * randf() * 1.6 * pow(maxf(0.0, 1.0 - f / 104.0), 1.4)
				# Restless (high variance) people get bored; loyal ones stick around.
				var boredom: float = f * 0.009 * (0.35 + o) * (1.25 - l) / (0.55 + 0.45 * t) * boredom_mult
				# Good news lifts those who like your sound; bad news hits everyone but the loyal.
				var mood: float = mom * 0.5 * t if mom > 0.0 else mom * (1.0 - l * 0.7)
				f += growth - boredom + mood
			fanatic[i] = clampf(f, 0.0, 100.0)
			_update_tier(i, true)
	momentum *= 0.75
	_recount()
	return _check_stage()


func _density(c: int) -> float:
	var ct: Array = city_tier[c]
	return (ct[REGULAR] * 0.3 + ct[FAN] + ct[SUPER] * 1.5) / float(cities[c].count)


func _area_density(area: Array) -> float:
	var s := 0.0
	var pop := 0.0
	for c in area:
		var ct: Array = city_tier[c]
		s += ct[FAN] + ct[SUPER]
		pop += float(cities[c].count)
	return s / maxf(1.0, pop)


func _update_exposure() -> void:
	if base_city < 0:
		return
	var area := home_area()
	for c in cities.size():
		exposure[c] = exposure[c] * 0.95 + _density(c) * 0.12
	if stage >= 1:
		var seed_e := _density(base_city) * 0.05 + _area_density(area) * 0.4
		for c in area:
			if c != base_city:
				exposure[c] += seed_e
	if stage >= 2:
		var nat := _area_density(range(cities.size()))
		for c in cities.size():
			if not c in area:
				exposure[c] += nat * 0.6 + _area_density(home_area(c)) * 0.3
	# Your own city always hears a bit about you.
	exposure[base_city] = maxf(exposure[base_city], 0.08)
	for c in cities.size():
		exposure[c] = clampf(exposure[c], 0.0, 1.0)


func _check_stage() -> Array:
	var msgs: Array = []
	var base_ct: Array = city_tier[base_city]
	var base_fans: int = base_ct[FAN] + base_ct[SUPER]
	if stage == 0 and (base_fans >= 25 or (base_fans + base_ct[REGULAR] * 0.5) / float(cities[base_city].count) >= 0.08):
		unlock(1)
		msgs.append("Word is spreading beyond %s: people across %s are starting to hear about you." % [city_name(base_city), region_name(region_of(base_city))])
	elif stage == 1:
		var area := home_area()
		var fans := 0
		for c in area:
			fans += city_tier[c][FAN] + city_tier[c][SUPER]
		if fans >= 150 or _area_density(area) >= 0.03:
			unlock(2)
			msgs.append("You've gone national! People all over the country are discovering your music.")
	return msgs


func unlock(new_stage: int) -> void:
	if new_stage <= stage:
		return
	stage = new_stage
	if stage >= 1:
		for c in home_area():
			exposure[c] = maxf(exposure[c], 0.02)
	if stage >= 2:
		for c in cities.size():
			exposure[c] = maxf(exposure[c], 0.01)


# ================================================================ effects

func scope_cities(scope: int) -> Array:
	match scope:
		SCOPE_LOCAL:
			return [base_city]
		SCOPE_REGION:
			return home_area()
		SCOPE_NATIONAL:
			return range(cities.size())
	if stage == 0:
		return [base_city]
	if stage == 1:
		return home_area()
	return range(cities.size())


func _pick_city(cs: Array) -> int:
	var total := 0.0
	for c in cs:
		total += float(cities[c].count) * (0.15 + exposure[c])
	var x := randf() * total
	for c in cs:
		x -= float(cities[c].count) * (0.15 + exposure[c])
		if x <= 0.0:
			return c
	return cs[cs.size() - 1]


## Win over `real` new listeners (in real people). Returns people affected.
## breadth: -1 (only people who love your genre) .. 0 (normal) .. +1 (catchy,
## reaches people outside the genre).
func add_listeners(real: float, scope: int = SCOPE_REACH, breadth: float = 0.0) -> int:
	if real < 0.0:
		lose(minf(1.0, -real / maxf(1.0, real_at_least(LISTENER))), LISTENER, 10.0)
		return 0
	_ensure_taste(_taste_genre if _taste_genre != "" else genre_ids[0])
	var n := mini(_people_from_real(real), 3000)
	var cs := scope_cities(scope)
	var added := 0
	for k in n:
		for attempt in 6:
			var c := _pick_city(cs)
			var i: int = int(cities[c].start) + randi() % int(cities[c].count)
			if tier[i] >= REGULAR:
				continue
			var t := taste(i)
			if breadth > 0.0:
				t = lerpf(t, 0.75, breadth * 0.5)
			elif breadth < 0.0:
				t = minf(1.0, pow(t, 1.0 - breadth * 1.5) * (1.0 - breadth * 0.3))
			if randf() < t * (0.4 + variance[i] * 0.006):
				fanatic[i] = maxf(fanatic[i] + randf_range(2.0, 5.0), randf_range(9.0, 14.0))
				_update_tier(i, false)
				added += 1
				break
	_dirty = true
	return added


## Turn existing listeners into bigger fans (`real` people's worth).
func deepen(real: float) -> void:
	_ensure()
	if engaged.is_empty():
		return
	var n := mini(_people_from_real(real, FAN), engaged.size())
	for k in n:
		var i: int = engaged[randi() % engaged.size()]
		fanatic[i] = minf(100.0, fanatic[i] + randf_range(6.0, 14.0) * (0.4 + taste(i)))
		_update_tier(i, false)
	_dirty = true


## How your existing listeners and fans take a new song's feel
## (0 Poppy .. 4 Dial Up To 11, see Charts.FEELS). Genre purists hate a sell-out;
## people who love the genre lap up the heavy stuff, and outsiders cool on it.
func feel_reaction(feel: int) -> void:
	_ensure()
	for i in engaged:
		var t := taste(i)
		var tr := int(tier[i])
		var d := 0.0
		match feel:
			0:
				if tr >= FAN and randf() < 0.35:
					d = -randf_range(2.0, 8.0) * t * (1.0 - loyalty[i] * 0.006)
			1:
				if tr >= FAN:
					d = randf_range(-3.0, 4.0) * t
			2:
				d = randf_range(0.0, 3.0) * t
			3:
				d = randf_range(-1.0, 5.0) * (t - 0.3) * 1.5 + variance[i] * 0.02
			4:
				d = randf_range(0.0, 8.0) * (t - 0.35) * 1.6
		if d != 0.0:
			fanatic[i] = clampf(fanatic[i] + d * 0.4, 0.0, 100.0)
			_update_tier(i, false)
	_dirty = true


## A fraction of people at or above `min_tier` cool on the band.
## Loyal people shrug most of it off.
func lose(fraction: float, min_tier: int, amount: float) -> void:
	_ensure()
	for i in engaged:
		if int(tier[i]) >= min_tier and randf() < fraction:
			fanatic[i] = maxf(0.0, fanatic[i] - amount * (1.0 - loyalty[i] * 0.006))
			_update_tier(i, false)
	_dirty = true


func pulse(scope: int, amount: float) -> void:
	for c in scope_cities(scope):
		exposure[c] = clampf(exposure[c] + amount, 0.0, 1.0)


func pulse_city(c: int, amount: float) -> void:
	exposure[c] = clampf(exposure[c] + amount, 0.0, 1.0)


## Good news lifts everyone a little; bad news drags them down.
func nudge(amount: float) -> void:
	momentum = clampf(momentum + amount, -3.0, 3.0)


## Switching genre: people who don't like the new sound drift away,
## people who love it warm up.
func genre_shock(new_genre: String) -> void:
	_ensure()
	_ensure_taste(new_genre)
	for i in engaged:
		var t := taste(i)
		if t < 0.3:
			fanatic[i] *= 0.6 + loyalty[i] * 0.003
		elif t >= 0.65:
			fanatic[i] = minf(100.0, fanatic[i] + 4.0)
		_update_tier(i, false)
	_dirty = true


## Rough people lost if you switched: Vector2(fans, listeners).
func preview_genre_change(new_genre: String) -> Vector2:
	_ensure()
	var tbl := _taste_table(new_genre)
	var n := genre_ids.size()
	var fans := 0.0
	var lis := 0.0
	for i in engaged:
		if tbl[g1[i] * n + g2[i]] < 0.3:
			if int(tier[i]) >= FAN:
				fans += 0.6
			else:
				lis += 0.8
	return Vector2(fans, lis)


# ================================================================== gigs

## Who turns up to a gig in city `venue_city`. travel: how much further
## people will go for this size of show (1 = a pub gig, 3 = a stadium).
## With expected=true returns expected counts instead of rolling dice.
## Counts are in simulated people (see real_of()).
func gig_crowd(venue_city: int, travel: float, tour: bool, expected: bool = false) -> Dictionary:
	_ensure()
	var area := home_area(venue_city)
	var counts := [0.0, 0.0, 0.0, 0.0, 0.0]
	var travelled := 0.0
	var people := PackedInt32Array()
	for i in engaged:
		var t := int(tier[i])
		var p: float = ATTEND[t]
		if tour and t <= REGULAR:
			p *= 2.5
		var pc := int(city[i])
		if pc != venue_city:
			var d: float = TRAVEL_REGION[t] if pc in area else TRAVEL_FAR[t]
			d = minf(1.0, d * travel)
			p *= d
		p = minf(0.98, p * (0.4 + gig[i] * 0.009))
		if expected:
			counts[t] += p
			if pc != venue_city:
				travelled += p
		elif randf() < p:
			counts[t] += 1.0
			people.append(i)
			if pc != venue_city:
				travelled += 1.0
	return {"counts": counts, "travelled": travelled, "people": people}


## After the gig: the crowd's verdict changes how they feel, and the best
## walk-ins become listeners. Returns tier changes in people.
func apply_gig(people: PackedInt32Array, admit: float, crowd: float, venue_city: int, walk_people: int) -> Dictionary:
	_ensure()
	var before_l := count_at_least(LISTENER)
	var before_f := count_at_least(FAN)
	for i in people:
		if randf() > admit:
			continue
		# Seeing you live is what turns listeners into fans (or not).
		var d := (crowd - 2.6) * randf_range(4.0, 8.0)
		if d < 0.0:
			d *= 1.0 - loyalty[i] * 0.006
		else:
			d *= pow(maxf(0.0, 1.0 - fanatic[i] / 108.0), 1.5)
		fanatic[i] = clampf(fanatic[i] + d, 0.0, 100.0)
		_update_tier(i, false)
	var c: Dictionary = cities[venue_city]
	var r := crowd / 5.0
	for k in mini(walk_people, int(c.count)):
		var i: int = int(c.start) + randi() % int(c.count)
		if tier[i] >= REGULAR:
			continue
		fanatic[i] = fanatic[i] + taste(i) * r * r * randf_range(8.0, 24.0)
		_update_tier(i, false)
	pulse_city(venue_city, 0.03 * r)
	_recount()
	return {"listeners": count_at_least(LISTENER) - before_l, "fans": count_at_least(FAN) - before_f}


# ============================================================== reporting

func person(i: int) -> Dictionary:
	return {"id": i, "name": names[name_idx[i]], "gender": "f" if gender[i] == 0 else "m", "age": int(age[i]),
		"city": city_name(int(city[i])), "region": region_name(region_of(int(city[i]))),
		"fav": genre_ids[g1[i]], "second": genre_ids[g2[i]], "gig": int(gig[i]), "variance": int(variance[i]),
		"loyalty": int(loyalty[i]), "fanatic": fanatic[i], "tier": int(tier[i]), "months": fan_weeks[i] / 4}


## The biggest fans, most devoted first.
func top_fans(n: int = 25) -> Array:
	_ensure()
	var idx: Array = []
	for i in engaged:
		if int(tier[i]) >= FAN:
			idx.append(i)
	idx.sort_custom(func(a, b): return fanatic[a] > fanatic[b] if absf(fanatic[a] - fanatic[b]) > 0.01 else fan_weeks[a] > fan_weeks[b])
	var out: Array = []
	for i in idx.slice(0, n):
		out.append(person(i))
	return out


## Age bands and gender of people at or above a tier.
func demographics(min_tier: int) -> Dictionary:
	_ensure()
	var bands := [0, 0, 0, 0, 0, 0]
	var female := 0
	var total := 0
	for i in engaged:
		if int(tier[i]) < min_tier:
			continue
		total += 1
		if gender[i] == 0:
			female += 1
		var a := int(age[i])
		var b := 0 if a < 18 else (1 if a < 25 else (2 if a < 35 else (3 if a < 50 else (4 if a < 65 else 5))))
		bands[b] += 1
	return {"bands": bands, "female": female, "total": total}


# ================================================================ saving

## Most people don't know you, so their rows are zeros: compress them.
static func _pack(bytes: PackedByteArray) -> String:
	return Marshalls.raw_to_base64(bytes.compress(FileAccess.COMPRESSION_ZSTD))


static func _unpack(s: String, raw_size: int) -> PackedByteArray:
	return Marshalls.base64_to_raw(s).decompress(raw_size, FileAccess.COMPRESSION_ZSTD)


func to_dict() -> Dictionary:
	return {"seed": seed_val, "base": base_city, "stage": stage, "momentum": momentum,
		"exposure": Array(exposure), "genre": _taste_genre, "people": size(),
		"fanatic": _pack(fanatic.to_byte_array()),
		"tier": _pack(tier),
		"fan_weeks": _pack(fan_weeks.to_byte_array())}


func from_dict(d: Dictionary) -> bool:
	generate(int(d.seed))
	if int(d.get("people", -1)) != size():
		return false
	var f := _unpack(str(d.fanatic), size() * 4).to_float32_array()
	var t := _unpack(str(d.tier), size())
	var w := _unpack(str(d.fan_weeks), size() * 4).to_int32_array()
	if f.size() != size() or t.size() != size() or w.size() != size():
		return false
	fanatic = f
	tier = t
	fan_weeks = w
	base_city = int(d.base)
	stage = int(d.stage)
	momentum = float(d.momentum)
	var e: Array = d.exposure
	for i in mini(e.size(), exposure.size()):
		exposure[i] = float(e[i])
	if str(d.get("genre", "")) != "":
		_ensure_taste(str(d.genre))
	_dirty = true
	return true
