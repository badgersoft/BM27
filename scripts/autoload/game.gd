extends Node
## Game autoload: the whole state of a run, the player's actions,
## derived stats and save/load. The weekly simulation lives in WeekSim,
## the charts in Charts and the event logic in Events.

signal changed
signal toast(text: String, kind: String)

const SAVE_PATH := "user://bm27_save.json"
const HOF_PATH := "user://bm27_halloffame.json"
const SAVE_VERSION := 3
const ROLES := ["vocals", "guitar", "bass", "drums"]
const FINAL_TOUR_MIN_WEEKS := 96
const FINAL_TOUR_LENGTH := 24

# ------------------------------------------------------------------- state
var active := false
var week := 1
var manager_id := ""
var manager_choices: Array = []
var funds := 0.0
var band_name := ""
var genre := "rock"
var musicians: Dictionary = {}
var lineup: Dictionary = {"vocals": "", "guitar": "", "bass": "", "drums": ""}
var practice_idx := 0
var focus := "rehearse"
var public: Public
var base_city := -1
## Fans (fan + super fan) and listeners (listener + regular), in real people.
var true_fans: float:
	get:
		return public.real_at_least(Public.FAN) if public else 0.0
var listeners: float:
	get:
		return public.real_at_least(Public.LISTENER) - public.real_at_least(Public.FAN) if public else 0.0
var buzz := 0.0
var peak_reach := 16.0
var formed_week := 0
var songcraft := 5.0
var gig_offers: Array = []
var gig_cities: Dictionary = {}  # str(venue idx) -> city idx for this month's offers
var gig_booked := -1
var gig_city := -1
var gig_month := -1
var gig_skipped := false
var gig_history: Array = []
var releases: Array = []
var chart_nat: Array = []
var chart_local: Array = []
var chart_album: Array = []
var rivals: Array = []
var trends: Dictionary = {}
var inbox: Array = []
var queue: Array = []
var report: Dictionary = {}
var stats: Dictionary = {}
var flags: Dictionary = {}
var last_gig_rating := 0.0
var last_gig_week := -99
var used_titles: Array = []
var game_over := false
var end_reason := ""
var next_uid := 1


# =================================================================== setup

func new_game() -> void:
	active = true
	week = 1
	manager_id = ""
	var pool: Array = Data.managers.duplicate()
	pool.shuffle()
	manager_choices = pool.slice(0, 4).map(func(m): return m.id)
	funds = 0.0
	band_name = ""
	genre = "rock"
	musicians.clear()
	for m in Data.build_musicians():
		musicians[m.id] = m
	lineup = {"vocals": "", "guitar": "", "bass": "", "drums": ""}
	practice_idx = 0
	focus = "rehearse"
	public = Public.new()
	public.generate(randi() % 2000000000)
	base_city = -1
	buzz = 0.0
	peak_reach = 16.0
	formed_week = 0
	songcraft = 5.0
	gig_offers = []
	gig_cities = {}
	gig_booked = -1
	gig_city = -1
	gig_month = -1
	gig_skipped = false
	gig_history = []
	releases = []
	inbox = []
	queue = []
	report = {}
	stats = {"earned": 0.0, "spent": 0.0, "gigs": 0, "best_rating": 0.0, "peak_fame": 0.0, "best_nat": 0,
		"best_album": 0, "interviews": 0, "hired": 0, "best_venue": -1, "total_attendance": 0}
	flags = {"top20_since_album": 0, "albums": 0, "doc_done": false, "film_done": false, "final_tour_start": -1,
		"famous_weeks": 0, "last_release_week": -99, "last_producer_week": -99, "last_label_week": -99,
		"last_star_week": -99, "pending_album": {}, "final_tour_gigs": 0, "fatigue": 0.0}
	last_gig_rating = 0.0
	last_gig_week = -99
	used_titles = []
	game_over = false
	end_reason = ""
	next_uid = 1
	rivals = []
	for r in BandData.RIVALS:
		rivals.append({"name": r.name, "genre": r.genre, "fame": float(r.fame), "local": false})
	for r in BandData.LOCAL:
		rivals.append({"name": r.name, "genre": r.genre, "fame": randf_range(2.0, 28.0), "local": true,
			"city": randi() % public.cities.size()})
	trends = {}
	for g in Data.genres:
		trends[g.id] = randf_range(0.88, 1.12)
	Charts.init_charts()
	changed.emit()


func choose_manager(id: String) -> void:
	manager_id = id
	funds = float(Data.manager(id).funds)
	genre = Data.manager(id).genre
	changed.emit()


func manager() -> Dictionary:
	return Data.manager(manager_id)


func has_perk(perk: String) -> bool:
	return manager_id != "" and manager().perk == perk


## Choose the home city. Bigger cities have more potential fans but
## pricier rehearsal rooms and venues.
func set_base_city(c: int) -> void:
	base_city = c
	public.set_base(c)
	changed.emit()


func city_name(c: int = -1) -> String:
	if c < 0:
		c = base_city
	return public.city_name(c) if c >= 0 else "Badgerton"


func city_cost(c: int = -1) -> float:
	if c < 0:
		c = base_city
	return public.city_cost(c) if c >= 0 else 1.0


## Fills {city} and {region} placeholders in names and stories.
func cityize(s: String) -> String:
	if not s.contains("{"):
		return s
	var region: String = public.regions[public.region_of(base_city)].short if base_city >= 0 else "Regional"
	return s.replace("{city}", city_name()).replace("{region}", region)


func reach_stage() -> int:
	return public.stage if public else 0


func reach_label() -> String:
	if base_city < 0:
		return ""
	match public.stage:
		0: return "Local · %s" % city_name()
		1: return "Regional · %s" % public.regions[public.region_of(base_city)].short
	return "National"


## Which city a gig venue is in this month.
func gig_city_of(idx: int) -> int:
	var v := Data.gig_venue(idx, false)
	if RegionData.VENUE_CITY.has(v.id):
		return public.find_city(RegionData.VENUE_CITY[v.id])
	if gig_booked == idx and gig_city >= 0:
		return gig_city
	return int(gig_cities.get(str(idx), base_city))


func set_practice(idx: int) -> bool:
	var v := Data.practice_venue(idx)
	if idx > practice_idx and funds < rent_of(idx):
		return false
	practice_idx = idx
	add_inbox("Moved rehearsals", "The band now rehearses at %s." % v.name, "venue")
	changed.emit()
	return true


func rent_of(idx: int) -> float:
	var r: float = Data.practice_venue(idx).rent * city_cost()
	if has_perk("diy"):
		r *= 0.7
	return round(r)


## Finish setup: name the band and start the clock.
func form_band(name: String, genre_id: String) -> void:
	band_name = name.strip_edges()
	if band_name == "":
		band_name = "The Unnamed"
	genre = genre_id
	formed_week = week
	public._ensure_taste(genre)
	public.seed_first_fans(4, 12)
	for role in ROLES:
		var m := member(role)
		if not m.is_empty():
			m.original = true
			m.joined = week
	Charts.weekly_update(false)
	WeekSim.generate_gig_offers()
	add_inbox("The band is born!", "%s have officially formed. Mum has bought a T-shirt. Now let's get famous." % band_name, "star")
	save_game()
	changed.emit()


# ================================================================ getters

func uid(prefix: String) -> String:
	next_uid += 1
	return "%s%d" % [prefix, next_uid]


func member(role: String) -> Dictionary:
	var id: String = lineup.get(role, "")
	if id == "" or not musicians.has(id):
		return {}
	return musicians[id]


func members() -> Array:
	var out: Array = []
	for role in ROLES:
		var m := member(role)
		if not m.is_empty():
			out.append(m)
	return out


func band_complete() -> bool:
	return members().size() == 4


func is_formed() -> bool:
	return formed_week > 0


func band_age() -> int:
	return 0 if formed_week == 0 else week - formed_week


func tenure(m: Dictionary) -> int:
	return maxi(0, week - int(m.joined))


func reach() -> float:
	return true_fans + listeners


## Fame is mostly about real fans; casual listeners count for much less.
func fame_base() -> float:
	var x := true_fans * 20.0 + listeners * 0.5
	return clampf((log(1.0 + x) / log(10.0) - 1.5) / 6.0 * 100.0, 0.0, 100.0)


func fame() -> float:
	return clampf(fame_base() + buzz, 0.0, 100.0)


func fame_label(f: float = -1.0) -> String:
	if f < 0.0:
		f = fame()
	if f < 10.0: return "Unknown"
	if f < 25.0: return "Local Buzz"
	if f < 40.0: return "Scene Favourites"
	if f < 55.0: return "Regional Stars"
	if f < 70.0: return "National Name"
	if f < 85.0: return "Household Name"
	return "Global Icons"


## Expected crowd from fans and listeners alone for a venue in a city (real
## people). Venues use this to decide whether to book you.
func expected_crowd(idx: int, city: int = -1) -> float:
	var v := Data.gig_venue(idx, false)
	if city < 0:
		city = gig_city_of(idx)
	var crowd := public.gig_crowd(city, WeekSim.travel_factor(v.tier), is_final_tour(), true)
	return public.real_of(crowd.counts).total


func trend(g: String = "") -> float:
	if g == "":
		g = genre
	return trends.get(g, 1.0)


func value_of(m: Dictionary) -> int:
	return Data.musician_value(m)


func inst_bonus(m: Dictionary) -> int:
	return InstrumentData.BONUS[clampi(int(m.inst), 0, 7)]


## Effective on-stage contribution of one musician.
func effective_skill(m: Dictionary) -> float:
	return (float(m.skill) + inst_bonus(m)) * (0.8 + 0.4 * float(m.happy) / 100.0)


## Overall band performance score (roughly 0-120).
func band_score() -> float:
	var total_w := 0.0
	var s := 0.0
	var tenure_sum := 0.0
	var genre_bonus := 0.0
	for role in ROLES:
		var w: float = InstrumentData.ROLE_WEIGHT[role]
		total_w += w
		var m := member(role)
		if m.is_empty():
			continue
		s += effective_skill(m) * w
		tenure_sum += tenure(m)
		if m.genre == genre:
			genre_bonus += 1.5
	var base := s / total_w
	var chem := minf(6.0, tenure_sum / 4.0 / 8.0)
	var mgr := 3.0 if (manager_id != "" and manager().genre == genre) else 0.0
	return base + chem + songcraft * 0.05 + mgr + genre_bonus


func avg_happiness() -> float:
	var ms := members()
	if ms.is_empty():
		return 50.0
	var t := 0.0
	for m in ms:
		t += float(m.happy)
	return t / ms.size()


func happiness_word(h: float) -> String:
	if h >= 80: return "Ecstatic"
	if h >= 62: return "Happy"
	if h >= 45: return "Content"
	if h >= 28: return "Grumbling"
	if h >= 12: return "Fed Up"
	return "Leaving"


func temperament_word(ease: int) -> String:
	return ["", "Diva", "Demanding", "Moody", "Easygoing", "Chilled"][clampi(ease, 1, 5)]


func is_final_tour() -> bool:
	return int(flags.final_tour_start) >= 0


func final_tour_weeks_left() -> int:
	if not is_final_tour():
		return 0
	return maxi(0, int(flags.final_tour_start) + FINAL_TOUR_LENGTH - week)


func can_start_final_tour() -> bool:
	return is_formed() and not is_final_tour() and band_age() >= FINAL_TOUR_MIN_WEEKS and fame() >= 35.0


func date_label() -> String:
	return U.date_label(week)


# =========================================================== money helpers

func spend(amount: float, what: String = "") -> bool:
	if amount <= 0.0:
		return true
	if funds + 0.001 < amount:
		toast.emit("Not enough funds for %s." % (what if what != "" else "that"), "bad")
		return false
	funds -= amount
	stats.spent = float(stats.spent) + amount
	return true


func earn(amount: float) -> void:
	if amount <= 0.0:
		return
	funds += amount
	stats.earned = float(stats.earned) + amount


func gear_price(cost: float) -> float:
	var c := cost
	if has_perk("gearhead"):
		c *= 0.75
	if has_perk("diy"):
		c *= 0.9
	return round(c)


func venue_hire(idx: int) -> float:
	var v := Data.gig_venue(idx, false)
	var c: float = v.hire
	if not RegionData.VENUE_CITY.has(v.id):
		c *= city_cost(gig_city_of(idx))
	if has_perk("posh"):
		c *= 0.85
	return round(c)


# ============================================================ talent market

## Musicians on the market for a role: the ones you can afford, best first,
## plus a couple you can't quite afford yet to aim for.
func market(role: String) -> Array:
	var f := fame()
	var month: int = U.date(week).month_idx
	var affordable: Array = []
	var dreams: Array = []
	var cap := 9 if has_perk("scout") else 7
	for id in musicians:
		var m: Dictionary = musicians[id]
		if m.role != role or m.status != "free" or bool(m.grudge):
			continue
		if int(m.tier) > 0 and f < float(m.min_fame):
			continue
		# Availability rotates monthly: not everyone is looking for a band.
		var avail_pct := 82 if has_perk("scout") else 70
		if absi(hash(str(id) + ":" + str(month))) % 100 >= avail_pct:
			continue
		var v := value_of(m)
		if v <= funds:
			affordable.append(m)
		else:
			dreams.append(m)
	affordable.sort_custom(func(a, b): return value_of(a) > value_of(b) if value_of(a) != value_of(b) else float(a.skill) > float(b.skill))
	dreams.sort_custom(func(a, b): return value_of(a) < value_of(b))
	# At most two free hopefuls, so a tight budget still shows the best paid
	# players it can stretch to.
	var paid: Array = affordable.filter(func(m): return value_of(m) > 0)
	var free: Array = affordable.filter(func(m): return value_of(m) == 0)
	var out: Array = paid.slice(0, cap - mini(2, free.size())) + free.slice(0, 2)
	# Make sure a free hopeful is always available so nobody gets stuck.
	if not out.any(func(m): return value_of(m) == 0):
		for id in musicians:
			var m: Dictionary = musicians[id]
			if m.role == role and m.status == "free" and not bool(m.grudge) and value_of(m) == 0:
				out.append(m)
				break
	return out + dreams.slice(0, 3)


## Can the player see this musician's exact potential?
func knows_potential(m: Dictionary) -> bool:
	return m.status == "band" or has_perk("scout")


func potential_range(m: Dictionary) -> Vector2i:
	var p := float(m.pot)
	if knows_potential(m):
		return Vector2i(int(round(p)), int(round(p)))
	var spread := 8.0
	var off := float(absi(hash(m.id)) % 7) - 3.0
	return Vector2i(int(clampf(p - spread + off, m.skill, 99)), int(clampf(p + spread + off, m.skill, 99)))


## Offer a fee. Returns {ok: bool, text: String}.
func make_offer(id: String, amount: float) -> Dictionary:
	var m: Dictionary = musicians[id]
	if int(m.cooldown) > week:
		return {"ok": false, "text": "%s isn't answering your calls right now." % m.name}
	if amount > funds:
		return {"ok": false, "text": "You can't afford that offer."}
	var ask := float(value_of(m))
	var accept := true
	if amount < ask:
		var ratio := amount / maxf(1.0, ask)
		var min_ratio := 0.62 + float(m.happy) / 100.0 * 0.3
		if has_perk("silver"):
			min_ratio -= 0.12
		var p := clampf((ratio - min_ratio) / maxf(0.01, 1.0 - min_ratio), 0.0, 1.0) * 0.9
		if has_perk("silver"):
			p += 0.15
		accept = randf() < p
	if not accept:
		m.cooldown = week + 3
		m.happy = maxf(0.0, float(m.happy) - 4.0)
		return {"ok": false, "text": "%s laughed and hung up. Try again in a few weeks, or offer more." % m.name}
	sign_musician(id, amount)
	return {"ok": true, "text": "%s has joined the band!" % m.name}


func sign_musician(id: String, fee: float) -> void:
	var m: Dictionary = musicians[id]
	if fee > 0.0:
		spend(fee, "signing")
	var old := member(m.role)
	if not old.is_empty():
		_release(old, "replaced by %s" % m.name)
	m.status = "band"
	m.joined = week
	m.original = not is_formed()
	m.happy = clampf(maxf(float(m.happy), 60.0) + 8.0, 0.0, 100.0)
	m.last_complaint = week
	lineup[m.role] = id
	stats.hired = int(stats.hired) + 1
	if is_formed():
		add_inbox("New %s" % InstrumentData.ROLE_NAMES[m.role].to_lower(), "%s has joined %s." % [m.name, band_name], "userPlus")
	changed.emit()


func _release(m: Dictionary, why: String) -> void:
	m.status = "free"
	m.grudge = true
	m.cooldown = week + 12
	m.happy = 35.0
	if lineup.get(m.role, "") == m.id:
		lineup[m.role] = ""
	if is_formed():
		add_inbox("%s has gone" % m.name, "%s is no longer in the band (%s)." % [m.name, why], "userX")


func sack(role: String) -> void:
	var m := member(role)
	if m.is_empty():
		return
	if bool(m.original) and is_formed():
		public.lose(0.05, Public.FAN, 12.0)
	for other in members():
		if other.id != m.id and float(m.happy) > 50.0:
			other.happy = maxf(0.0, float(other.happy) - 3.0)
	_release(m, "sacked")
	changed.emit()


## Someone leaves of their own accord.
func member_quits(m: Dictionary) -> void:
	_release(m, "quit the band")
	m.grudge = true
	changed.emit()


func upgrade_instrument(role: String, tier: int) -> bool:
	var m := member(role)
	if m.is_empty() or tier <= int(m.inst):
		return false
	var item := Data.instrument(role, tier)
	var cost := gear_price(item.cost)
	if not spend(cost, item.name):
		return false
	var gained := tier - int(m.inst)
	m.inst = tier
	m.happy = clampf(float(m.happy) + 4.0 * gained, 0.0, 100.0)
	add_inbox("New gear!", "%s now plays a %s." % [m.name, item.name], "upgrade")
	changed.emit()
	return true


func gift_boost(m: Dictionary, base: float) -> float:
	return base * clampf(1.0 - float(m.gift_fatigue) / 40.0, 0.25, 1.0)


func give_gift(mid: String, gift_idx: int) -> String:
	var m: Dictionary = musicians[mid]
	var g: Dictionary = InstrumentData.GIFTS[gift_idx]
	if not spend(g.cost, g.name):
		return ""
	var boost := gift_boost(m, g.boost)
	m.happy = clampf(float(m.happy) + boost, 0.0, 100.0)
	m.gift_fatigue = float(m.gift_fatigue) + 8.0
	changed.emit()
	return "%s loved the %s. (+%d contentment)" % [m.name, g.name.to_lower(), int(round(boost))]


## One-off cash bonus options for a musician: [[amount, boost], ...]
func bonus_options(m: Dictionary) -> Array:
	var v := maxf(100.0, float(value_of(m)))
	return [[roundf(maxf(40.0, v * 0.04) / 10.0) * 10.0, 7.0], [roundf(maxf(120.0, v * 0.12) / 10.0) * 10.0, 14.0],
		[roundf(maxf(300.0, v * 0.3) / 10.0) * 10.0, 24.0]]


func give_bonus(mid: String, amount: float, base_boost: float) -> String:
	var m: Dictionary = musicians[mid]
	if not spend(amount, "the bonus"):
		return ""
	var boost := gift_boost(m, base_boost)
	m.happy = clampf(float(m.happy) + boost, 0.0, 100.0)
	m.gift_fatigue = float(m.gift_fatigue) + 6.0
	changed.emit()
	return "%s pocketed %s with a grin. (+%d contentment)" % [m.name, U.money(amount), int(round(boost))]


## Roughly what switching genre would cost, in real fans and listeners.
func genre_change_cost(new_genre: String) -> Dictionary:
	var p := public.preview_genre_change(new_genre)
	var fw := true_fans / maxf(1.0, public.count_at_least(Public.FAN))
	var lw := listeners / maxf(1.0, public.count(Public.LISTENER) + public.count(Public.REGULAR))
	return {"fans": p.x * fw, "listeners": p.y * lw}


func change_genre(new_genre: String) -> void:
	if new_genre == genre:
		return
	var old := genre
	public.genre_shock(new_genre)
	for m in members():
		if m.genre == new_genre:
			m.happy = clampf(float(m.happy) + 10.0, 0.0, 100.0)
		elif m.genre == old:
			m.happy = clampf(float(m.happy) - 8.0, 0.0, 100.0)
	genre = new_genre
	add_inbox("New direction", "%s have gone %s. Not everyone is pleased." % [band_name, Data.genre_name(new_genre)], "swap")
	changed.emit()


func set_focus(f: String) -> void:
	focus = f
	changed.emit()


func promote_cost() -> float:
	return roundf((20.0 + fame() * 4.0) / 5.0) * 5.0


# ===================================================================== gigs

func book_gig(idx: int) -> bool:
	if gig_booked >= 0 or not idx in gig_offers:
		return false
	var cost := venue_hire(idx)
	if not spend(cost, "the venue hire"):
		return false
	gig_booked = idx
	gig_city = gig_city_of(idx)
	gig_skipped = false
	add_inbox("Gig booked", "You've booked %s for the end of the month (%s)." % [Data.gig_venue(idx).name, U.money(cost)], "ticket")
	changed.emit()
	return true


func skip_gig_month() -> void:
	if gig_booked >= 0:
		return
	gig_skipped = true
	changed.emit()


## Rough attendance estimate shown before booking: [low, high]
func estimate_attendance(idx: int) -> Vector2i:
	var v := Data.gig_venue(idx)
	var c := gig_city_of(idx)
	var crowd := public.gig_crowd(c, WeekSim.travel_factor(v.tier), is_final_tour(), true)
	var expected: float = public.real_of(crowd.counts).total
	var w := WeekSim.walkin_range(v.tier)
	var walk := float(v.cap) * trend() * WeekSim.city_walk_factor(c)
	var lo := expected * 0.8 + walk * w.x
	var hi := expected * 1.2 + walk * w.y
	return Vector2i(int(minf(lo, v.cap)), int(minf(hi, v.cap)))


func gig_income_per_head(idx: int) -> float:
	var v := Data.gig_venue(idx)
	var merch: float = v.merch * (1.5 if is_final_tour() else 1.0)
	return (float(v.ticket) + float(v.bar) * 0.5 + merch) * Settings.income_mult()


func start_final_tour() -> void:
	if not can_start_final_tour():
		return
	flags.final_tour_start = week
	for m in members():
		m.happy = clampf(float(m.happy) + 15.0, 0.0, 100.0)
	add_inbox("THE FINAL TOUR", "%s have announced their farewell tour. Six months, then the curtain falls. Every casual fan in the land wants a ticket." % band_name, "flag")
	changed.emit()


# ==================================================================== inbox

func add_inbox(title: String, body: String, icon: String = "mail", kind: String = "info") -> void:
	inbox.push_front({"week": week, "title": title, "body": body, "icon": icon, "kind": kind})
	if inbox.size() > 120:
		inbox.resize(120)


# ==================================================================== turns

func can_advance() -> bool:
	return active and is_formed() and not game_over and queue.is_empty()


func advance_week() -> void:
	if not can_advance():
		return
	WeekSim.run()
	if Settings.autosave and not game_over:
		save_game()
	changed.emit()


func has_events() -> bool:
	return not queue.is_empty()


func pop_event() -> Dictionary:
	if queue.is_empty():
		return {}
	return queue.pop_front()


## Resolve an event choice. Returns a result dict for the UI
## ({title, text, icon, kind}) or {} if nothing to show.
func resolve_event(ev: Dictionary, choice: Variant) -> Dictionary:
	var res := Events.resolve(ev, choice)
	changed.emit()
	if Settings.autosave and active and not game_over:
		save_game()
	return res


func end_game(reason: String) -> void:
	game_over = true
	end_reason = reason
	_record_hall_of_fame()
	delete_save()
	changed.emit()


# ============================================================ hall of fame

func legacy_score() -> int:
	var s := float(stats.peak_fame) * 100.0
	s += sqrt(maxf(0.0, float(stats.earned))) * 4.0
	s += band_age() * 10.0
	if int(stats.best_nat) > 0:
		s += (41 - int(stats.best_nat)) * 60.0
	s += int(flags.albums) * 800.0
	if end_reason == "retired":
		s *= 1.25
	return int(s)


func _record_hall_of_fame() -> void:
	var list := load_hall_of_fame()
	list.append({
		"band": band_name, "manager": manager().short if manager_id != "" else "?", "genre": Data.genre_name(genre),
		"weeks": band_age(), "peak_fame": int(stats.peak_fame), "earned": float(stats.earned),
		"best_nat": int(stats.best_nat), "albums": int(flags.albums), "ending": end_reason, "score": legacy_score(),
	})
	list.sort_custom(func(a, b): return int(a.score) > int(b.score))
	if list.size() > 10:
		list.resize(10)
	var f := FileAccess.open(HOF_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(list))


func load_hall_of_fame() -> Array:
	if not FileAccess.file_exists(HOF_PATH):
		return []
	var f := FileAccess.open(HOF_PATH, FileAccess.READ)
	if f == null:
		return []
	var data = JSON.parse_string(f.get_as_text())
	return data if data is Array else []


# ================================================================ save/load

const SAVE_KEYS := ["week", "manager_id", "manager_choices", "funds", "band_name", "genre", "musicians", "lineup",
	"practice_idx", "focus", "base_city", "buzz", "peak_reach", "formed_week", "songcraft",
	"gig_offers", "gig_cities", "gig_city", "gig_booked", "gig_month", "gig_skipped", "gig_history", "releases", "chart_nat", "chart_local",
	"chart_album", "rivals", "trends", "inbox", "queue", "report", "stats", "flags", "last_gig_rating",
	"last_gig_week", "used_titles", "next_uid"]
const INT_KEYS := ["week", "practice_idx", "formed_week", "gig_booked", "gig_month", "last_gig_week", "next_uid",
	"base_city", "gig_city"]


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func save_game() -> void:
	if not active or not is_formed() or game_over:
		return
	var d := {"version": SAVE_VERSION}
	for k in SAVE_KEYS:
		d[k] = get(k)
	d["public"] = public.to_dict()
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(d))


func load_game() -> bool:
	if not has_save():
		return false
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return false
	var d = JSON.parse_string(f.get_as_text())
	if not d is Dictionary or int(d.get("version", 0)) != SAVE_VERSION or not d.has("public"):
		return false
	var pub := Public.new()
	if not pub.from_dict(d.public):
		return false
	public = pub
	for k in SAVE_KEYS:
		if not d.has(k):
			continue
		var v = d[k]
		if k in INT_KEYS:
			v = int(v)
		elif k == "gig_offers":
			v = (v as Array).map(func(x): return int(x))
		set(k, v)
	# JSON turns ints into floats; tidy the ones used as indices or counters.
	for id in musicians:
		var m: Dictionary = musicians[id]
		for key in ["age", "tier", "ease", "inst", "joined", "cooldown", "last_complaint", "min_fame"]:
			m[key] = int(m[key])
	for key in gig_cities.keys():
		gig_cities[key] = int(gig_cities[key])
	for r in rivals:
		if r.has("city"):
			r.city = int(r.city)
	for key in ["gigs", "best_nat", "best_album", "interviews", "hired", "best_venue", "total_attendance"]:
		stats[key] = int(stats.get(key, 0))
	for key in ["top20_since_album", "albums", "famous_weeks", "last_release_week", "last_producer_week",
			"last_label_week", "last_star_week", "final_tour_start", "final_tour_gigs"]:
		flags[key] = int(flags.get(key, 0))
	active = true
	game_over = false
	end_reason = ""
	changed.emit()
	return true


func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))


func quit_to_menu() -> void:
	if active and not game_over:
		save_game()
	active = false
