class_name WeekSim
extends RefCounted
## The weekly tick: rent, the band's focus for the week, training, fans,
## charts, happiness, the monthly gig, events, and end-of-game checks.

const FOCUS := {
	"rehearse": {"name": "Rehearse", "icon": "amp", "train": 1.0,
		"desc": "Full rehearsal week. Best for skills. A bit of a grind."},
	"write": {"name": "Write Songs", "icon": "pen", "train": 0.4,
		"desc": "Build up the song bank. Better songs, better gigs and singles."},
	"busk": {"name": "Busk", "icon": "hat", "train": 0.35,
		"desc": "Play the high street for spare change and a few new listeners."},
	"odd_jobs": {"name": "Odd Jobs", "icon": "handshake", "train": 0.25,
		"desc": "Car washes, a cricket club do, a mate's wedding. Free to do, decent tips, a few new listeners."},
	"promote": {"name": "Promote", "icon": "megaphone", "train": 0.3,
		"desc": "Flyers, posters and socials. Costs money, wins listeners."},
	"chill": {"name": "Chill Out", "icon": "moon", "train": 0.0,
		"desc": "A week off. No progress, but everyone's mood lifts."},
}
const FOCUS_ORDER := ["rehearse", "write", "busk", "odd_jobs", "promote", "chill"]
## What the band gets up to on an Odd Jobs week: [line, tips multiplier, listeners multiplier].
const ODD_JOBS := [
	["washed cars for the {city} Rotary Club's charity car wash (and played a few songs while they dried)", 0.8, 0.8],
	["played the cricket club's summer do in a marquee that smelt of grass and Pimm's", 1.0, 1.0],
	["played your mate's wedding reception. The best man cried during the slow one", 1.3, 0.7],
	["played background music at a garden centre's Christmas-in-July evening", 0.9, 0.6],
	["did a set at a school summer fete, between the tombola and the dog show", 0.7, 1.3],
	["played a pub quiz half-time slot at The Red Lion", 0.8, 1.0],
	["played a retirement party at the bus depot. Big tippers, bus drivers", 1.2, 0.6],
	["helped a removal firm for the day, then played a song for the customers", 1.1, 0.4],
]


static func run() -> void:
	var rep := {
		"week": Game.week, "lines": [], "funds0": Game.funds, "fans0": Game.true_fans,
		"listeners0": Game.listeners, "fame0": Game.fame(), "skill_gains": {},
	}
	_pay_rent(rep)
	_apply_focus(rep)
	_train(rep)
	_organic_fans(rep)
	Charts.weekly_update(true, rep)
	_happiness(rep)
	_birthdays(rep)
	if U.date(Game.week).week_of_month == 4:
		_resolve_month_gig(rep)
	Events.roll_weekly(rep)
	if Game.week % 2 == 0:
		Events.queue_news()
	_drift_world()
	Game.week += 1
	if U.date(Game.week).week_of_month == 1:
		generate_gig_offers()
		_monthly_trends()
	_pending_album(rep)
	_track_peaks()
	_check_endings()
	rep.funds1 = Game.funds
	rep.fans1 = Game.true_fans
	rep.listeners1 = Game.listeners
	rep.fame1 = Game.fame()
	Game.report = rep
	if Settings.weekly_popup and not Game.game_over:
		Game.queue.push_front({"type": "report"})


static func line(rep: Dictionary, text: String, kind: String = "info") -> void:
	(rep.lines as Array).append({"text": text, "kind": kind})


# ------------------------------------------------------------------- rent

static func _pay_rent(rep: Dictionary) -> void:
	var rent := Game.rent_of(Game.practice_idx)
	if rent <= 0.0:
		return
	if Game.funds >= rent:
		Game.funds -= rent
		Game.stats.spent = float(Game.stats.spent) + rent
		line(rep, "Rent at %s: %s" % [Data.practice_venue(Game.practice_idx).name, U.money(rent)], "cost")
		return
	# Can't pay: drop to the best place we can afford (Nan's shed is free).
	var idx := Game.practice_idx
	while idx > 0 and Game.rent_of(idx) > Game.funds:
		idx -= 1
	Game.practice_idx = idx
	var r2 := Game.rent_of(idx)
	Game.funds -= r2
	line(rep, "Couldn't make rent! Moved down to %s." % Data.practice_venue(idx).name, "bad")
	Game.add_inbox("Evicted!", "You couldn't pay the rent, so the band has moved to %s." % Data.practice_venue(idx).name, "alert", "bad")


# ------------------------------------------------------------------ focus

static func _apply_focus(rep: Dictionary) -> void:
	var f := Game.focus
	var fat_delta: float = {"rehearse": 1.0, "write": 0.5, "busk": 0.6, "odd_jobs": 0.7, "promote": 0.3, "chill": -3.5}[f]
	Game.flags.fatigue = clampf(float(Game.flags.get("fatigue", 0.0)) + fat_delta, 0.0, 10.0)
	var hustle := 1.4 if Game.has_perk("hustler") else 1.0
	var ms := Game.members()
	var avg_skill := 0.0
	for m in ms:
		avg_skill += float(m.skill)
	avg_skill = avg_skill / maxf(1.0, ms.size())
	match f:
		"write":
			var venue: Dictionary = Data.practice_venue(Game.practice_idx)
			var gain: float = (0.6 + avg_skill / 100.0) * float(venue.train) * 1.3 * (1.0 - Game.songcraft / 115.0)
			gain *= 0.5 + ms.size() / 8.0
			Game.songcraft = clampf(Game.songcraft + gain, 0.0, 100.0)
			line(rep, "Songwriting week: song bank +%.1f (now %d)." % [gain, int(Game.songcraft)], "good")
		"busk":
			var cash := (8.0 + avg_skill * 0.9) * randf_range(0.6, 1.4) * hustle * Settings.income_mult() * (ms.size() / 4.0)
			var fame := Game.fame()
			var newl := randf_range(3.0, 10.0) * hustle + Game.reach() * 0.002 * (1.0 + fame / 30.0)
			Game.earn(cash)
			var l0 := Game.listeners
			Game.public.add_listeners(newl, Public.SCOPE_LOCAL)
			newl = maxf(0.0, Game.listeners - l0)
			Game.public.pulse(Public.SCOPE_LOCAL, 0.01)
			if fame > 50.0:
				line(rep, "A surprise busk caused a minor riot on the high street! %s in the hat, +%s listeners." % [U.money(cash), U.num(newl)], "good")
			else:
				line(rep, "Busking earned %s and %s new listeners." % [U.money(cash), U.num(newl)], "good")
		"odd_jobs":
			var job: Array = ODD_JOBS.pick_random()
			# Bigger towns tip better; a band people have heard of tips better too.
			var tips := (70.0 + avg_skill * 1.4) * float(job[1]) * randf_range(0.7, 1.35) * hustle * Settings.income_mult() \
				* (ms.size() / 4.0) * Game.city_cost() * (1.0 + Game.fame() / 50.0)
			Game.earn(tips)
			var l2 := Game.listeners
			Game.public.add_listeners(randf_range(1.0, 5.0) * float(job[2]) * hustle, Public.SCOPE_LOCAL)
			var got := maxf(0.0, Game.listeners - l2)
			var what := Game.cityize(str(job[0]))
			line(rep, "Odd jobs: the band %s. %s in tips%s." % [what, U.money(tips), (", +%s listeners" % U.num(got)) if got >= 1.0 else ""], "good")
		"promote":
			var cost := Game.promote_cost()
			if Game.funds < cost:
				line(rep, "Couldn't afford promotion (%s), so the band rehearsed instead." % U.money(cost), "bad")
				Game.focus = "rehearse"
				return
			Game.funds -= cost
			Game.stats.spent = float(Game.stats.spent) + cost
			var newl := (14.0 + Game.reach() * 0.012) * randf_range(0.6, 1.4) * Game.trend() * hustle
			var l1 := Game.listeners
			Game.public.add_listeners(newl, Public.SCOPE_REACH)
			newl = maxf(0.0, Game.listeners - l1)
			Game.public.pulse(Public.SCOPE_REACH, 0.015)
			Game.buzz += 0.4
			line(rep, "Promotion push (%s): +%s listeners." % [U.money(cost), U.num(newl)], "good")
		"chill":
			line(rep, "The band took a week off. Everyone feels better for it.", "good")


# --------------------------------------------------------------- training

static func _train(rep: Dictionary) -> void:
	var venue: Dictionary = Data.practice_venue(Game.practice_idx)
	var fmult: float = FOCUS[Game.focus].train
	var perk := 1.2 if Game.has_perk("perfectionist") else 1.0
	for m in Game.members():
		var gap := float(m.pot) - float(m.skill)
		var age := int(m.age)
		var age_mult := 1.25 if age <= 21 else (1.0 if age <= 27 else (0.75 if age <= 34 else 0.5))
		var happy_mult := 0.6 + 0.8 * float(m.happy) / 100.0
		if gap > 0.0:
			var gain := gap * 0.014 * float(venue.train) * fmult * happy_mult * age_mult * perk * randf_range(0.8, 1.2)
			m.skill = minf(float(m.pot), float(m.skill) + gain)
			rep.skill_gains[m.id] = gain
		elif fmult >= 1.0 and Game.practice_idx >= 8 and float(m.happy) > 85.0 and randf() < 0.012:
			# Extremely unusual circumstances: a genuine breakthrough.
			var bump := randf_range(1.0, 3.0)
			m.pot = minf(99.0, float(m.pot) + bump)
			line(rep, "%s had a breakthrough in rehearsal and found a new level!" % m.name, "good")
			Game.add_inbox("Breakthrough!", "Something clicked for %s. Their potential has risen." % m.name, "sparkle", "good")
	# Free agents keep practising too, slowly.
	for id in Game.musicians:
		var fm: Dictionary = Game.musicians[id]
		if fm.status == "free" and float(fm.pot) > float(fm.skill):
			fm.skill = float(fm.skill) + (float(fm.pot) - float(fm.skill)) * 0.003


# ------------------------------------------------------------------- fans

## The public lives its week: hearing you, getting hooked, getting bored.
static func _organic_fans(rep: Dictionary) -> void:
	var pub := Game.public
	var q := clampf(Game.band_score() / 60.0, 0.35, 2.0) * Game.trend()
	pub.hear_mult = 1.5 if Game.has_perk("viral") else 1.0
	pub.boredom_mult = Settings.decay_mult() * (0.6 if Game.has_perk("faithful") else 1.0)
	for msg in pub.step(Game.genre, q):
		line(rep, msg, "good")
		Game.add_inbox("Spreading the word", msg, "trendUp", "good")
	Game.buzz *= 0.9


# -------------------------------------------------------------- happiness

static func _happiness(rep: Dictionary) -> void:
	var venue: Dictionary = Data.practice_venue(Game.practice_idx)
	var fame := Game.fame()
	var slump := Game.peak_reach > 300.0 and Game.reach() < Game.peak_reach * 0.6
	var complaint_raised := false
	for m in Game.members():
		var target := 55.0
		var dist := Data.genre_distance(m.genre, Game.genre)
		target += 8.0 if dist == 0 else (-2.0 if dist == 1 else -6.0)
		target += clampf((int(m.inst) - Data.expected_inst_tier(m.skill)) * 3.0, -9.0, 9.0)
		target += float(venue.happy)
		if Game.week - Game.last_gig_week <= 4:
			target += (Game.last_gig_rating - 3.0) * 3.0
		target += minf(4.0, fame / 25.0)
		target -= float(Game.flags.get("fatigue", 0.0)) * 1.5
		target += (int(m.ease) - 3) * 4.0
		if Game.has_perk("roadie"):
			target += 6.0
		if slump:
			target -= 15.0
		if Game.funds < 50.0:
			target -= 4.0
		if int(m.tier) > 0 and fame < float(m.min_fame):
			target -= 6.0
		if Game.is_final_tour():
			target += 10.0
		var rate := 0.10 + (5 - int(m.ease)) * 0.03
		var h := float(m.happy)
		h += (target - h) * rate
		match Game.focus:
			"rehearse": h -= 0.8
			"chill": h += 7.0 * (0.6 + int(m.ease) * 0.1)
		m.happy = clampf(h, 0.0, 100.0)
		m.gift_fatigue = maxf(0.0, float(m.gift_fatigue) - 1.0)
		if Game.is_final_tour():
			continue
		# Unhappy musicians speak up, and the miserable ones walk.
		if float(m.happy) < 12.0 and randf() < 0.3:
			Events.queue_member_left(m)
			continue
		if float(m.happy) < 28.0 and Game.week - int(m.last_complaint) >= 6 and not complaint_raised:
			m.last_complaint = Game.week
			complaint_raised = true
			Game.queue.append({"type": "complaint", "mid": m.id})


## Everyone gets a year older once a year (week 1 of each year).
static func _birthdays(rep: Dictionary) -> void:
	if Game.week % U.WEEKS_PER_YEAR != 0:
		return
	for id in Game.musicians:
		var m: Dictionary = Game.musicians[id]
		m.age = int(m.age) + 1
		if int(m.age) > 34:
			m.pot = maxf(5.0, float(m.pot) - randf_range(0.0, 1.5))
			if float(m.skill) > float(m.pot):
				m.skill = float(m.pot)
	line(rep, "Happy New Year! Everyone's a year older.", "info")


# -------------------------------------------------------------------- gigs

static func walkin_range(tier: String) -> Vector2:
	match tier:
		"Small": return Vector2(0.12, 0.45)
		"Medium": return Vector2(0.06, 0.25)
		"Large": return Vector2(0.04, 0.18)
		"Arena": return Vector2(0.03, 0.14)
	return Vector2(0.02, 0.12)


static func is_big(tier: String) -> bool:
	return tier in ["Large", "Arena", "Stadium"]


## People travel further for bigger shows: nobody crosses the country for a
## pub gig, plenty do for Wombley.
static func travel_factor(tier: String) -> float:
	match tier:
		"Large": return 1.5
		"Arena": return 2.2
		"Stadium": return 3.0
	return 1.0


## Bigger cities send more people wandering into gigs.
static func city_walk_factor(c: int) -> float:
	if c < 0:
		return 1.0
	return sqrt(float(Game.public.cities[c].count) / RegionData.BASE_POP)


## Where an ordinary venue offer comes from: home at first, then anywhere
## you've spread to (busier where your music is circulating most).
static func _offer_city() -> int:
	var pub := Game.public
	if pub.stage == 0 or randf() < 0.45:
		return Game.base_city
	var cs := pub.scope_cities(Public.SCOPE_REACH)
	var total := 0.0
	for c in cs:
		total += float(pub.cities[c].count) * (0.05 + pub.exposure[c])
	var x := randf() * total
	for c in cs:
		x -= float(pub.cities[c].count) * (0.05 + pub.exposure[c])
		if x <= 0.0:
			return c
	return Game.base_city


static func generate_gig_offers() -> void:
	Game.gig_month = U.date(Game.week).month_idx
	Game.gig_booked = -1
	Game.gig_skipped = false
	# A venue books you if fans and listeners alone should fill its "draw".
	var eligible: Array = []
	var cache: Dictionary = {}
	for i in Data.gigs.size():
		var v: Dictionary = Data.gigs[i]
		if float(v.draw) <= 0.0:
			eligible.append(i)
			continue
		var c := Game.base_city
		if RegionData.VENUE_CITY.has(v.id):
			c = Game.public.find_city(RegionData.VENUE_CITY[v.id])
		var key := "%d:%s" % [c, v.tier]
		if not cache.has(key):
			cache[key] = Game.expected_crowd(i, c)
		if float(v.draw) <= float(cache[key]):
			eligible.append(i)
	var top: Array = eligible.slice(maxi(0, eligible.size() - 3))
	var offers: Array = []
	for i in top:
		if top.size() > 1 and randf() < 0.15:
			continue
		offers.append(i)
	if offers.is_empty() and not top.is_empty():
		offers.append(top[top.size() - 1])
	if not Game.is_final_tour() and randf() < 0.06:
		offers = []
	Game.gig_offers = offers
	Game.gig_cities = {}
	Game.gig_city = -1
	for i in offers:
		Game.gig_cities[str(i)] = _offer_city()


static func _resolve_month_gig(rep: Dictionary) -> void:
	if Game.gig_booked >= 0:
		var g := play_gig(Game.gig_booked)
		Game.queue.push_front({"type": "gig", "gig": g})
		line(rep, "Gig night at %s: %d people, %s crowd rating." % [g.venue_name, g.attendance, U.stars_text(g.crowd)], "good" if g.crowd >= 3.0 else "bad")
		Game.gig_booked = -1
	elif Game.gig_offers.is_empty():
		line(rep, "No venues would book you this month. Fans understand.", "info")
	else:
		# Skipped, or simply forgot to book.
		Game.public.nudge(-0.6)
		Game.public.lose(0.06, Public.LISTENER, 5.0)
		var why := "You skipped this month's gig." if Game.gig_skipped else "You didn't book a gig this month!"
		line(rep, why + " Some fans drifted away.", "bad")
		Game.add_inbox("No gig this month", why + " A few fans have drifted off.", "ticket", "bad")


static func play_gig(idx: int) -> Dictionary:
	var v := Data.gig_venue(idx)
	var cap: int = v.cap
	var tour := Game.is_final_tour()
	var city := Game.gig_city_of(idx)
	var pub := Game.public
	# Every fan and listener decides for themselves whether to come.
	var roll := pub.gig_crowd(city, travel_factor(v.tier), tour)
	var cn: Array = roll.counts
	var real: Dictionary = pub.real_of(cn)
	var fans: float = real.fans
	var li: float = real.listeners
	var people := 0.0
	for n in cn:
		people += float(n)
	var per_person: float = float(real.total) / maxf(1.0, people)
	var w := walkin_range(v.tier)
	var walk := float(cap) * randf_range(w.x, w.y) * Game.trend() * city_walk_factor(city) * (1.5 if tour else 1.0)
	# Another band in your scene playing across town on the same night?
	var clash := ""
	var f := Game.fame()
	var gig_area := pub.home_area(city)
	var rivals_near: Array = Game.rivals.filter(func(r): return r.genre == Game.genre and absf(float(r.fame) - f) < 12.0 \
		and (not bool(r.local) or int(r.get("city", -1)) in gig_area))
	if not rivals_near.is_empty() and randf() < 0.25:
		clash = rivals_near.pick_random().name
		li *= 0.8
		walk *= 0.8
	# Fill the room: fans get in first, then listeners, then walk-ins.
	var a_tf := int(minf(fans, cap))
	var a_li := int(minf(li, cap - a_tf))
	var a_walk := int(minf(walk, cap - a_tf - a_li))
	var att := a_tf + a_li + a_walk
	var admit := float(a_tf + a_li) / maxf(1.0, fans + li)
	var fill := float(att) / float(cap)
	# Performance against what this crowd expects.
	var perf := Game.band_score() + randf_range(-9.0, 9.0) + minf(5.0, fill * 5.0)
	if not Game.band_complete():
		perf *= 0.75
	var expect := 18.0 + idx * 6.0
	var crowd := clampf(snappedf(3.0 + (perf - expect) / 11.0, 0.5), 0.5, 5.0)
	var critic := clampf(snappedf(2.6 + (perf - expect - 4.0) / 11.0 + randf_range(-0.7, 0.7), 0.5), 0.5, 5.0)
	# Money.
	var mult := Settings.income_mult()
	var tickets := att * float(v.ticket) * mult
	# The band's half of the bar: the prediction, give or take (-25% to +50%).
	var bar := att * float(v.bar) * 0.5 * mult * randf_range(0.75, 1.5)
	var merch := att * float(v.merch) * (1.5 if tour else 1.0) * mult
	var hire := Game.venue_hire(idx)
	Game.earn(tickets + bar + merch)
	# The crowd's verdict changes how each of them feels; good walk-ins stick.
	var r := crowd / 5.0
	var f0 := Game.true_fans
	var l0 := Game.listeners + f0
	pub.apply_gig(roll.people, admit, crowd, city, int(round(a_walk * 0.6 / Public.marginal(pub.count_at_least(Public.LISTENER)))))
	var new_listeners := Game.listeners + Game.true_fans - l0
	var new_fans := Game.true_fans - f0
	if crowd >= 4.0:
		pub.nudge(0.3)
	elif crowd < 2.0:
		pub.nudge(-0.5)
	Game.buzz += r * 4.0 * float(idx + 1) / 15.0
	for m in Game.members():
		m.happy = clampf(float(m.happy) + (crowd - 3.0) * 4.0, 0.0, 100.0)
	Game.flags.fatigue = clampf(float(Game.flags.get("fatigue", 0.0)) + 1.0, 0.0, 10.0)
	Game.last_gig_rating = crowd
	Game.last_gig_week = Game.week
	Game.stats.gigs = int(Game.stats.gigs) + 1
	Game.stats.total_attendance = int(Game.stats.total_attendance) + att
	Game.stats.best_rating = maxf(float(Game.stats.best_rating), crowd)
	if crowd >= 3.0:
		Game.stats.best_venue = maxi(int(Game.stats.best_venue), idx)
	if tour:
		Game.flags.final_tour_gigs = int(Game.flags.final_tour_gigs) + 1
	var bucket := clampi(int(crowd) - 1, 0, 4)
	var bucket_c := clampi(int(critic) - 1, 0, 4)
	var crowd_quote: String = MediaData.CROWD_QUOTES[bucket].pick_random()
	if att < 30 and crowd >= 4.0:
		crowd_quote = MediaData.SMALL_CROWD_QUOTES.pick_random().replace("{n2}", str(maxi(0, att - 1))).replace("{n}", str(att))
	var g := {
		"week": Game.week, "venue": idx, "venue_name": v.name, "tier": v.tier, "cap": cap, "attendance": att,
		"city": Game.city_name(city), "fans": a_tf, "listeners": a_li, "walkins": a_walk,
		"super_fans": int(float(real.super) * admit), "travelled": int(float(roll.travelled) * per_person * admit), "fill": fill, "crowd": crowd, "critic": critic,
		"crowd_quote": crowd_quote, "critic_quote": MediaData.CRITIC_QUOTES[bucket_c].pick_random(),
		"tickets": tickets, "bar": bar, "merch": merch, "hire": hire, "profit": tickets + bar + merch - hire,
		"new_listeners": new_listeners, "new_fans": new_fans, "clash": clash, "final_tour": tour,
		"colour": v.colour,
	}
	Game.gig_history.push_front(g)
	if Game.gig_history.size() > 60:
		Game.gig_history.resize(60)
	return g


# ------------------------------------------------------------------ world

static func _drift_world() -> void:
	for r in Game.rivals:
		var drift := randf_range(-0.35, 0.35)
		if bool(r.local):
			r.fame = clampf(float(r.fame) + drift + 0.03, 1.0, 45.0)
		else:
			r.fame = clampf(float(r.fame) + drift * 0.5, 30.0, 99.0)


static func _monthly_trends() -> void:
	for gid in Game.trends:
		var t: float = Game.trends[gid]
		t += randf_range(-0.06, 0.06) + (1.0 - t) * 0.08
		Game.trends[gid] = clampf(t, 0.7, 1.3)


static func _pending_album(rep: Dictionary) -> void:
	var pa: Dictionary = Game.flags.pending_album
	if pa.is_empty() or Game.week < int(pa.week):
		return
	Events.release_now(pa)
	Game.flags.pending_album = {}
	line(rep, "Your album '%s' is out now!" % pa.title, "good")


static func _track_peaks() -> void:
	Game.peak_reach = maxf(Game.peak_reach, Game.reach())
	var f := Game.fame()
	Game.stats.peak_fame = maxf(float(Game.stats.peak_fame), f)
	if f >= 65.0:
		Game.flags.famous_weeks = int(Game.flags.famous_weeks) + 1


static func _check_endings() -> void:
	if Game.is_final_tour() and Game.final_tour_weeks_left() <= 0:
		Game.queue.append({"type": "end", "reason": "retired"})
		return
	if Game.is_final_tour():
		return
	# Falling apart: big slide from the peak plus a miserable band.
	var collapse := Game.peak_reach > 500.0 and Game.reach() < Game.peak_reach * 0.35
	var misery := Game.members().size() >= 3 and Game.avg_happiness() < 18.0
	if (collapse and Game.avg_happiness() < 35.0) or misery:
		if randf() < 0.12 and not Game.queue.any(func(e): return e.type == "breakup"):
			Game.queue.append({"type": "breakup"})
