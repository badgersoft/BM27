class_name Events
extends RefCounted
## Event generation (interviews, producers, labels, stars, documentaries,
## random mishaps, newspapers) and resolution of the player's choices.

const DECISION_TYPES := ["interview", "producer", "label", "star", "doc", "film", "random", "fame", "complaint", "left", "breakup"]


static func _decisions_queued() -> int:
	return Game.queue.filter(func(e): return e.type in DECISION_TYPES).size()


static func _has(type: String) -> bool:
	return Game.queue.any(func(e): return e.type == type)


# ============================================================== generation

static func roll_weekly(_rep: Dictionary) -> void:
	var f := Game.fame()
	var wk := Game.week
	var flags := Game.flags
	# Interview offers.
	var p_int := 0.16 * (1.5 if Game.has_perk("contacts") else 1.0)
	if _decisions_queued() < 2 and randf() < p_int:
		var outlets: Array = []
		for i in MediaData.OUTLETS.size():
			if float(MediaData.OUTLETS[i].fame) <= f:
				outlets.append(i)
		if not outlets.is_empty():
			var top: Array = outlets.slice(maxi(0, outlets.size() - 3))
			Game.queue.append({"type": "interview", "outlet": top.pick_random()})
	# A record producer calls.
	var since_release := wk - int(flags.last_release_week)
	if _decisions_queued() < 2 and Game.band_age() >= 6 and since_release >= 10 and wk - int(flags.last_producer_week) >= 6 \
			and f >= 3.0 and (flags.pending_album as Dictionary).is_empty():
		var p := clampf(0.08 + 0.01 * (since_release - 10), 0.08, 0.3)
		if randf() < p:
			var eligible: Array = []
			for i in MediaData.PRODUCERS.size():
				if float(MediaData.PRODUCERS[i].fame) <= f + 5.0:
					eligible.append(i)
			var pool: Array = eligible.slice(maxi(0, eligible.size() - 4))
			pool.shuffle()
			var opts: Array = pool.slice(0, mini(3, pool.size()))
			opts.sort()
			flags.last_producer_week = wk
			Game.queue.append({"type": "producer", "options": opts})
	# Record label album offers (2+ top 20 singles).
	if _decisions_queued() < 2 and int(flags.top20_since_album) >= 2 and wk - int(flags.last_label_week) >= 6 \
			and (flags.pending_album as Dictionary).is_empty() and randf() < 0.3:
		var labels: Array = []
		for i in MediaData.LABELS.size():
			if float(MediaData.LABELS[i].fame) <= f:
				labels.append(i)
		if not labels.is_empty():
			flags.last_label_week = wk
			var idx: int = labels[maxi(0, labels.size() - 1 - randi_range(0, 1))]
			Game.queue.append({"type": "label", "label": idx})
	# A star wants to join.
	if _decisions_queued() < 2 and f >= 55.0 and wk - int(flags.last_star_week) >= 12 and randf() < 0.05:
		var ev := _star_offer()
		if not ev.is_empty():
			flags.last_star_week = wk
			Game.queue.append(ev)
	# Documentary and concert film.
	if _decisions_queued() < 2 and not bool(flags.doc_done) and int(flags.famous_weeks) >= 24 and randf() < 0.08:
		var fee := roundf((250000.0 + f * 8000.0) * randf_range(0.8, 1.3) / 1000.0) * 1000.0
		Game.queue.append({"type": "doc", "fee": fee, "title": Game.cityize(MediaData.DOC_TITLES.pick_random().replace("{band}", Game.band_name))})
	if _decisions_queued() < 2 and not bool(flags.film_done) and f >= 72.0 and int(Game.stats.best_venue) >= 11 and randf() < 0.1:
		var fee2 := roundf((500000.0 + f * 12000.0) * randf_range(0.8, 1.3) / 1000.0) * 1000.0
		var vname: String = Data.gig_venue(int(Game.stats.best_venue)).name
		Game.queue.append({"type": "film", "fee": fee2, "venue": vname,
			"title": Game.cityize(MediaData.FILM_TITLES.pick_random().replace("{band}", Game.band_name).replace("{venue}", vname))})
	# Famous members get up to things, good and bad.
	if _decisions_queued() < 2 and wk - int(flags.get("last_fame_week", -99)) >= 4:
		var ev3 := _fame_event()
		if not ev3.is_empty():
			flags.last_fame_week = wk
			Game.queue.append(ev3)
	# Random mishaps and opportunities.
	if _decisions_queued() < 2 and randf() < 0.09:
		var ev2 := _random_event()
		if not ev2.is_empty():
			Game.queue.append(ev2)


static func _star_offer() -> Dictionary:
	var f := Game.fame()
	var best: Array = []
	for id in Game.musicians:
		var m: Dictionary = Game.musicians[id]
		if int(m.tier) == 0 or m.status != "free" or bool(m.grudge) or float(m.min_fame) > f + 10.0:
			continue
		var cur := Game.member(m.role)
		if not cur.is_empty() and float(m.skill) < float(cur.skill) + 5.0:
			continue
		best.append(m)
	if best.is_empty():
		return {}
	var m: Dictionary = best.pick_random()
	var discount := randf_range(0.2, 0.5)
	var price := roundf(Game.value_of(m) * (1.0 - discount) / 500.0) * 500.0
	return {"type": "star", "mid": m.id, "price": price, "discount": discount}


static func _random_event() -> Dictionary:
	var f := Game.fame()
	var has_rel := not Game.releases.is_empty()
	# Mishaps count half as much in the draw and need a 3-week gap. Any one
	# event can't come round again for 20 weeks (losing the same gear twice
	# in a month isn't fun).
	var bad_ok := Game.week - int(Game.flags.get("last_bad_event_week", -99)) > 3
	var seen: Dictionary = Game.flags.get("event_seen", {})
	var pool: Array = []
	var weights: Array = []
	for i in MediaData.RANDOM_EVENTS.size():
		var e: Dictionary = MediaData.RANDOM_EVENTS[i]
		var bad: bool = e.get("bad", false)
		if bad and not bad_ok:
			continue
		if Game.week - int(seen.get(e.id, -99)) < 20:
			continue
		if float(e.min_fame) > f or float(e.get("max_fame", 999.0)) < f:
			continue
		if e.get("needs_release", false) and not has_rel:
			continue
		if e.get("member", false) and Game.members().is_empty():
			continue
		pool.append(i)
		# Skint bands get offered favour gigs more often.
		var w := 0.5 if bad else 1.0
		if e.get("favour", false) and Game.funds < 300.0:
			w = 2.5
		weights.append(w)
	if pool.is_empty():
		return {}
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var idx: int = pool[rng.rand_weighted(PackedFloat32Array(weights))]
	var e2: Dictionary = MediaData.RANDOM_EVENTS[idx]
	if e2.get("bad", false):
		Game.flags.last_bad_event_week = Game.week
	seen[e2.id] = Game.week
	Game.flags.event_seen = seen
	var ev := {"type": "random", "idx": idx}
	if e2.get("member", false):
		ev.mid = Game.members().pick_random().id
	var locals: Array = Game.rivals.filter(func(r): return bool(r.local))
	ev.rival = locals.pick_random().name if not locals.is_empty() else "Some band"
	return ev


## The definition behind a "random" or "fame" event.
static func event_def(ev: Dictionary) -> Dictionary:
	return MediaData.FAME_EVENTS[int(ev.idx)] if ev.type == "fame" else MediaData.RANDOM_EVENTS[int(ev.idx)]


static func _fame_event() -> Dictionary:
	for m in Game.members():
		var mf := float(m.get("fame", 0.0))
		if mf < 55.0 or Game.week - int(m.get("last_fame_event", -99)) < 10:
			continue
		if randf() >= 0.015 + (mf - 55.0) / 45.0 * 0.04:
			continue
		# Happy members tend to use their fame for good.
		var good := randf() < clampf(0.35 + (float(m.happy) - 50.0) / 150.0, 0.15, 0.7)
		var pool: Array = []
		for i in MediaData.FAME_EVENTS.size():
			var e: Dictionary = MediaData.FAME_EVENTS[i]
			if bool(e.good) == good and float(e.min_fame) <= mf:
				pool.append(i)
		if pool.is_empty():
			continue
		m.last_fame_event = Game.week
		var locals: Array = Game.rivals.filter(func(r): return float(r.fame) >= 30.0)
		return {"type": "fame", "idx": pool.pick_random(), "mid": m.id,
			"rival": locals.pick_random().name if not locals.is_empty() else "another band",
			"country": MediaData.CAUSE_COUNTRIES.pick_random()}
	return {}


## Fills an event's text placeholders.
static func event_text(t: String, ev: Dictionary, member_name: String) -> String:
	return Game.cityize(t.replace("{member}", member_name).replace("{rival}", str(ev.get("rival", ""))).replace("{country}", str(ev.get("country", ""))))


static func queue_member_left(m: Dictionary) -> void:
	var role: String = m.role
	var old_skill := float(m.skill)
	Game.member_quits(m)
	var cands: Array = []
	for id in Game.musicians:
		var c: Dictionary = Game.musicians[id]
		if c.role == role and c.status == "free" and not bool(c.grudge) and c.id != m.id \
				and (int(c.tier) == 0 or Game.fame() >= float(c.min_fame)) and Game.value_of(c) <= maxf(Game.funds, 0.0):
			cands.append(c)
	cands.sort_custom(func(a, b): return absf(float(a.skill) - old_skill) < absf(float(b.skill) - old_skill))
	var opts: Array = cands.slice(0, 3).map(func(c): return c.id)
	Game.queue.push_front({"type": "left", "mid": m.id, "role": role, "options": opts})


static func queue_news() -> void:
	var f := Game.fame()
	var flags := Game.flags
	var recent: Array = flags.get("news_recent", [])
	var megas: Array = Game.rivals.filter(func(r): return not bool(r.local))
	megas.sort_custom(func(a, b): return float(a.fame) > float(b.fame))
	megas = megas.slice(0, 18)
	megas.shuffle()
	var b1: String = megas[0].name
	var b2: String = megas[1].name
	var b3: String = megas[2].name
	var h1 := _fresh(MediaData.MEGA_HEADLINES, recent, "h")
	var h2 := _fresh(MediaData.MEGA_HEADLINES, recent, "h")
	var headline := _fill(MediaData.MEGA_HEADLINES[h1], b1, b2)
	var second := _fill(MediaData.MEGA_HEADLINES[h2], b3, b1)
	var sub: String = MediaData.MEGA_SUBS[_fresh(MediaData.MEGA_SUBS, recent, "s")].replace("{n}", str(randi_range(3, 40)))
	# Your story: a fresh gig review first, then chart news, then gossip.
	var mems := Game.members()
	var member_name: String = mems.pick_random().name if not mems.is_empty() else "the manager"
	var you := ""
	var kind := "neutral"
	var effect := ""
	var review := _gig_review_story()
	if not review.is_empty():
		you = review.text
		kind = review.kind
	if you == "":
		var ch := _chart_story()
		if not ch.is_empty():
			you = ch.text
			kind = ch.kind
	if you == "":
		# Bad press with a real effect never lands within 6 weeks of the last.
		var bad_ok := Game.week - int(flags.get("last_bad_news_week", -99)) >= 6
		var r := randf()
		if r < 0.35:
			var s: Dictionary = MediaData.YOU_GOOD[_fresh(MediaData.YOU_GOOD, recent, "g")]
			you = _you_fill(s.text, member_name)
			kind = "good"
			# Gentle: good press every fortnight would otherwise compound.
			effect = _apply_news_effect(float(s.listeners) * 0.4, float(s.fans) * 0.4)
		elif r < 0.55 and bad_ok:
			var s2: Dictionary = MediaData.YOU_BAD[_fresh(MediaData.YOU_BAD, recent, "b")]
			you = _you_fill(s2.text, member_name)
			kind = "bad"
			effect = _apply_news_effect(float(s2.listeners), float(s2.fans))
			flags.last_bad_news_week = Game.week
		else:
			you = _you_fill(MediaData.YOU_NEUTRAL[_fresh(MediaData.YOU_NEUTRAL, recent, "n")], member_name)
	var placement := "brief"
	if f >= 55.0:
		placement = "lead"
	elif f >= 25.0:
		placement = "sidebar"
	var paper := {
		"pub": MediaData.PUBLICATIONS.pick_random(), "date": U.date_label(Game.week), "headline": headline, "sub": sub,
		"second": second, "you": you, "kind": kind, "placement": placement, "effect": effect,
		"lead_sub": MediaData.LEAD_SUBS[_fresh(MediaData.LEAD_SUBS, recent, "ls")],
		"lead_box": str(MediaData.LEAD_BOX[_fresh(MediaData.LEAD_BOX, recent, "lb")]).replace("{band}", Game.band_name),
	}
	flags.news_recent = recent.slice(maxi(0, recent.size() - 30))
	Game.queue.append({"type": "news", "paper": paper})


## Picks an index from pool that hasn't appeared in the recent papers, and
## remembers it. Falls back to anything once the pool is used up.
static func _fresh(pool: Array, recent: Array, tag: String) -> int:
	var opts: Array = []
	for i in pool.size():
		if not ("%s%d" % [tag, i]) in recent:
			opts.append(i)
	if opts.is_empty():
		for i in range(recent.size() - 1, -1, -1):
			if str(recent[i]).begins_with(tag):
				recent.remove_at(i)
		opts = range(pool.size())
	var pick: int = opts.pick_random()
	recent.append("%s%d" % [tag, pick])
	return pick


## Reviews the latest gig once, in the first paper after it.
static func _gig_review_story() -> Dictionary:
	if Game.gig_history.is_empty():
		return {}
	var g: Dictionary = Game.gig_history[0]
	if Game.week - int(g.week) > 3 or int(Game.flags.get("news_gig_reviewed", -99)) == int(g.week):
		return {}
	Game.flags.news_gig_reviewed = int(g.week)
	var critic := float(g.critic)
	var key := "great" if critic >= 4.0 else ("good" if critic >= 2.5 else "bad")
	# Small, unremarkable gigs don't always make the paper.
	if key == "good" and randf() < 0.5:
		return {}
	var t: String = MediaData.GIG_REVIEWS[key].pick_random()
	t = t.replace("{band}", Game.band_name).replace("{venue}", g.venue_name).replace("{city}", str(g.get("city", Game.city_name()))) \
		.replace("{quote}", str(g.critic_quote).trim_suffix("."))
	return {"text": t, "kind": "good" if key == "great" else ("neutral" if key == "good" else "bad")}


## Chart news only when something has changed since the last report.
static func _chart_story() -> Dictionary:
	var charting: Array = Game.releases.filter(func(r): return r.status == "charting" and int(r.nat_pos) > 0)
	if charting.is_empty():
		return {}
	charting.sort_custom(func(a, b): return int(a.nat_pos) < int(b.nat_pos))
	var rel: Dictionary = charting[0]
	var reported: Dictionary = Game.flags.get("news_chart", {})
	var pos := int(rel.nat_pos)
	var prev := int(reported.get(rel.title, 0))
	var pool: Array = []
	var kind := "good"
	if prev == 0:
		pool = MediaData.CHART_NEW
	elif pos <= prev - 3 or (pos <= 10 and pos < prev):
		pool = MediaData.CHART_UP
	elif pos >= prev + 8:
		pool = MediaData.CHART_DOWN
		kind = "neutral"
	else:
		return {}
	reported[rel.title] = pos
	Game.flags.news_chart = reported
	var t: String = pool.pick_random()
	return {"text": t.replace("{band}", Game.band_name).replace("{title}", rel.title).replace("{pos}", str(pos)), "kind": kind}


static func _fill(t: String, b: String, b2: String) -> String:
	return t.replace("{b}", b.to_upper()).replace("{b2}", b2.to_upper()).replace("{s}", Data.random_song_title().to_upper()) \
		.replace("{n}", str(randi_range(3, 12)))


static func _you_fill(t: String, member_name: String) -> String:
	return Game.cityize(t.replace("{band}", Game.band_name).replace("{member}", member_name))


## Shift listeners and fans by a fraction of their current size, through
## the public (in real people). Returns a short "+12 listeners" summary.
static func shift_public(lpct: float, fpct: float, scope: int = Public.SCOPE_REACH) -> String:
	var pub := Game.public
	var l0 := Game.listeners
	var f0 := Game.true_fans
	if lpct > 0.0:
		pub.add_listeners(maxf(4.0, l0 * lpct), scope)
	elif lpct < 0.0:
		pub.lose(-lpct * 2.0, Public.LISTENER, 10.0)
	if fpct > 0.0:
		pub.deepen(maxf(1.0, f0 * fpct * 3.0))
	elif fpct < 0.0:
		pub.lose(-fpct * 3.0, Public.FAN, 12.0)
	var dl := Game.listeners - l0
	var df := Game.true_fans - f0
	var parts: Array = []
	if absf(dl) >= 1.0:
		parts.append("%s listeners" % U.signed_num(dl))
	if absf(df) >= 1.0:
		parts.append("%s fans" % U.signed_num(df))
	return ", ".join(parts)


static func _apply_news_effect(lpct: float, fpct: float) -> String:
	return shift_public(lpct, fpct)


# ============================================================== resolution

static func _res(title: String, text: String, icon: String = "info", kind: String = "info") -> Dictionary:
	return {"title": title, "text": text, "icon": icon, "kind": kind}


static func resolve(ev: Dictionary, choice: Variant) -> Dictionary:
	match ev.type:
		"interview": return _resolve_interview(ev, choice)
		"complaint": return _resolve_complaint(ev, choice)
		"left": return _resolve_left(ev, choice)
		"producer": return _resolve_producer(ev, choice)
		"name_release": return _resolve_name(ev, choice)
		"label": return _resolve_label(ev, choice)
		"star": return _resolve_star(ev, choice)
		"random", "fame": return _resolve_random(ev, choice)
		"doc", "film": return _resolve_media_deal(ev, choice)
		"breakup": return _resolve_breakup(choice)
		"end":
			Game.end_game(ev.reason)
			return {}
	return {}


static func _resolve_interview(ev: Dictionary, tone: Variant) -> Dictionary:
	var o: Dictionary = MediaData.OUTLETS[int(ev.outlet)].duplicate()
	o.name = Game.cityize(o.name)
	if tone == "decline":
		return _res("Interview declined", "You let %s down gently. They'll find someone else." % o.name, "x")
	# Local press reaches your city, regional TV your region, the rest the nation.
	var scope := Public.SCOPE_LOCAL if int(ev.outlet) <= 5 else (Public.SCOPE_REGION if int(ev.outlet) == 6 else Public.SCOPE_REACH)
	Game.stats.interviews = int(Game.stats.interviews) + 1
	var base: float = float(o.reach) * randf_range(0.7, 1.3) * (0.5 + Game.band_score() / 200.0)
	var gained := 0.0
	var text := ""
	var kind := "good"
	match tone:
		"humble":
			gained = base
			Game.public.deepen(base * 0.05)
			Game.buzz += 1.0
			for m in Game.members():
				m.happy = clampf(float(m.happy) + 2.0, 0.0, 100.0)
			text = MediaData.TONE_RESULTS.humble.pick_random()
		"cocky":
			gained = base * 1.5
			Game.buzz += 2.5
			for m in Game.members():
				m.happy = clampf(float(m.happy) + (2.0 if int(m.ease) <= 2 else -3.0), 0.0, 100.0)
			text = MediaData.TONE_RESULTS.cocky.pick_random()
		"mystery":
			gained = base * 0.9
			Game.buzz += 3.5
			text = MediaData.TONE_RESULTS.mystery.pick_random()
		"wild":
			if randf() < 0.55:
				gained = base * 2.6
				Game.buzz += 5.0
				text = MediaData.TONE_RESULTS.wild_good.pick_random()
			else:
				gained = 0.0
				Game.public.lose(0.06, Public.LISTENER, 10.0)
				Game.public.lose(0.04, Public.FAN, 10.0)
				Game.public.nudge(-0.4)
				Game.buzz += 1.0
				kind = "bad"
				text = MediaData.TONE_RESULTS.wild_bad.pick_random()
	var before := Game.listeners
	if gained > 0.0:
		Game.public.add_listeners(gained, scope)
		Game.public.pulse(scope, 0.01 + float(o.fame) / 3000.0)
	gained = Game.listeners - before
	var fee := float(o.fee) * Settings.income_mult()
	Game.earn(fee)
	var extra := "\n\nListeners %s." % U.signed_num(gained)
	if fee > 0.0:
		extra += " Appearance fee: %s." % U.money(fee)
	Game.add_inbox("Interview: %s" % o.name, text, "mic", kind)
	return _res(o.name, text + extra, "mic", kind)


static func _resolve_complaint(ev: Dictionary, choice: Variant) -> Dictionary:
	var m: Dictionary = Game.musicians.get(ev.mid, {})
	if m.is_empty() or m.status != "band":
		return {}
	var c: Dictionary = choice
	match c.kind:
		"gift":
			var t := Game.give_gift(m.id, int(c.idx))
			if t == "":
				return _res("Can't afford it", "You pat your pockets. Nothing.", "funds", "bad")
			return _res("Gift given", t, "gift", "good")
		"bonus":
			var t2 := Game.give_bonus(m.id, float(c.amount), float(c.boost))
			if t2 == "":
				return _res("Can't afford it", "The bank says no.", "funds", "bad")
			return _res("Bonus paid", t2, "cash", "good")
		"talk":
			if randf() < 0.45 + int(m.ease) * 0.08:
				var b := randf_range(6.0, 12.0)
				m.happy = clampf(float(m.happy) + b, 0.0, 100.0)
				return _res("Heart to heart", "You sat down over a cup of tea and really listened. %s feels better about things. (+%d)" % [m.name, int(b)], "smile", "good")
			m.happy = maxf(0.0, float(m.happy) - 3.0)
			return _res("That didn't help", "%s says talk is cheap. Which, to be fair, it was." % m.name, "frown", "bad")
		"release":
			queue_member_left(m)
			return _res("Parting ways", "You agreed it was time for %s to move on. Time to find a replacement." % m.name, "userX")
	# ignore
	m.happy = maxf(0.0, float(m.happy) - 5.0)
	if float(m.happy) < 15.0 and randf() < 0.5:
		queue_member_left(m)
		return _res("They've walked", "%s felt ignored and has quit the band." % m.name, "userX", "bad")
	return _res("Ignored", "You changed the subject. %s is quietly fuming." % m.name, "meh", "bad")


static func _resolve_left(ev: Dictionary, choice: Variant) -> Dictionary:
	if choice is String and choice != "none" and Game.musicians.has(choice):
		var c: Dictionary = Game.musicians[choice]
		var fee := float(Game.value_of(c))
		if fee > Game.funds:
			return _res("Can't afford them", "You'll have to look on the Talent page instead.", "funds", "bad")
		Game.sign_musician(c.id, fee)
		return _res("Welcome aboard", "%s has stepped in as your new %s." % [c.name, InstrumentData.ROLE_NAMES[c.role].to_lower()], "userPlus", "good")
	return _res("Searching", "You'll find a new %s on the Talent page. Don't leave it too long: gigs sound awful without one." % InstrumentData.ROLE_NAMES[ev.role].to_lower(), "search")


static func _resolve_producer(ev: Dictionary, choice: Variant) -> Dictionary:
	var idx := int(choice)
	if idx < 0:
		return _res("Not this time", "You turned down the studio time. Maybe the songs need more work anyway.", "x")
	var p: Dictionary = MediaData.PRODUCERS[idx]
	if not Game.spend(float(p.fee), "the producer"):
		return _res("Can't afford it", "%s wants paying up front. You haven't got it." % p.name, "funds", "bad")
	var actual := clampf(float(p.quality) + randf_range(-12.0, 8.0), 5.0, 100.0)
	# The single is the band's best demo, polished in the studio.
	var song := float(Game.take_demos(1)[0]) if not Game.demos.is_empty() else 10.0
	var q := 0.45 * minf(100.0, Game.band_score()) + 0.25 * actual + 0.30 * song
	if Game.has_perk("crate"):
		q *= 1.08
	var it := randf_range(0.6, 1.45)
	if randf() < 0.05:
		it = randf_range(1.6, 1.9)
	Game.queue.push_front({"type": "name_release", "kind": "single", "quality": q, "it": it, "producer": p.name,
		"producer_day": actual - float(p.quality), "options": Data.song_title_options(Game.genre, Game.used_titles)})
	return {}


static func _resolve_label(ev: Dictionary, choice: Variant) -> Dictionary:
	var l: Dictionary = MediaData.LABELS[int(ev.label)]
	if choice != "accept":
		return _res("Deal declined", "You told %s you're keeping your options open." % l.name, "x")
	var adv := float(l.advance) * Settings.income_mult()
	Game.earn(adv)
	# An album takes the best ten demos; any missing are written in a hurry.
	var songs := Game.take_demos(10)
	var sum := 0.0
	for sq in songs:
		sum += float(sq)
	sum += (10 - songs.size()) * 12.0
	var q := 0.4 * minf(100.0, Game.band_score()) + 0.3 * float(l.quality) + 0.3 * sum / 10.0
	if Game.has_perk("crate"):
		q *= 1.08
	var it := randf_range(0.7, 1.4)
	if randf() < 0.05:
		it = randf_range(1.6, 1.9)
	Game.flags.top20_since_album = 0
	Game.queue.push_front({"type": "name_release", "kind": "album", "quality": q, "it": it, "producer": l.name,
		"options": Data.album_title_options(Game.genre, Game.used_titles)})
	Game.add_inbox("Album deal signed!", "%s have signed with %s. Advance: %s." % [Game.band_name, l.name, U.money(adv)], "disc", "good")
	return {}


static func _resolve_name(ev: Dictionary, title: Variant) -> Dictionary:
	var t := str(title).strip_edges()
	if t == "":
		t = ev.options[0]
	var data := {"kind": ev.kind, "title": t, "quality": ev.quality, "it": ev.it, "producer": ev.producer,
		"feel": clampi(int(ev.get("feel", 2)), 0, Charts.FEELS.size() - 1)}
	Game.used_titles.append(t)
	if ev.kind == "album":
		data.week = Game.week + 3
		Game.flags.pending_album = data
		Game.add_inbox("Into the studio", "Recording of '%s' has begun with %s. Out in 3 weeks." % [t, ev.producer], "disc")
		return _res("Recording '%s'" % t, "The band have decamped to the studio with %s. The album will be released in 3 weeks." % ev.producer, "disc", "good")
	release_now(data)
	var pos_txt := "It's in the shops now. The charts are decided by sales, so you'll see where it lands once the first week's sales are in, in next week's report."
	return _res("'%s' is out!" % t, "Produced by %s.\n\n%s" % [ev.producer, pos_txt], "vinyl", "good")


## Per feel (Charts.FEELS order): chart power, new listeners, and who they are
## (breadth: +1 catchy and broad .. -1 genre lovers only).
const FEEL_POWER := [1.2, 1.1, 1.0, 0.95, 1.0]
const FEEL_LISTENERS := [1.6, 1.3, 1.0, 0.8, 0.7]
const FEEL_BREADTH := [1.0, 0.5, 0.0, -0.5, -1.0]


static func release_now(data: Dictionary) -> Dictionary:
	var f := Game.fame()
	var q := float(data.quality)
	var it := float(data.it)
	var feel := int(data.get("feel", 2))
	var power: float = FEEL_POWER[feel]
	if feel >= 3:
		# Genre-heavy songs live or die by how the genre's doing.
		power *= sqrt(Game.trend())
	if feel == 4:
		# Love it or hate it.
		power *= randf_range(0.5, 1.6)
	var rel := {
		"id": Game.uid("r"), "kind": data.kind, "title": data.title, "week": Game.week, "quality": q, "it": it,
		"producer": data.producer, "nat_base": q * national_reach(f) * it * (0.85 + 0.15 * Game.trend()) * power,
		"local_base": q * (0.35 + f / 70.0) * it * power, "feel": feel,
		# Now and then a catchy song comes roaring back weeks later.
		"sleeper": randi_range(7, 12) if feel == 0 and randf() < 0.06 else -1,
		"nat_pos": 0, "local_pos": 0, "last_nat": 0, "last_local": 0,
		"peak_nat": 0, "peak_local": 0, "weeks_on": 0, "sales": 0, "total_sales": 0, "revenue": 0.0,
		"status": "charting", "out_week": -1, "top20": false, "genre": Game.genre,
	}
	Game.releases.push_front(rel)
	Game.flags.last_release_week = Game.week
	if data.kind == "album":
		Game.flags.albums = int(Game.flags.albums) + 1
	Charts.add_release(rel)
	Game.public.add_listeners((10.0 + q * 0.5) * FEEL_LISTENERS[feel], Public.SCOPE_REACH, FEEL_BREADTH[feel])
	Game.public.feel_reaction(feel)
	Game.public.nudge(0.3)
	Game.buzz += 2.0
	Game.add_inbox("New %s: '%s'" % [data.kind, data.title], "Out now, produced by %s." % data.producer, "vinyl", "good")
	return rel


## How much of a song's quality turns into national chart power at this fame.
## Bands nobody outside their home town knows struggle to chart nationally.
static func national_reach(f: float) -> float:
	var spread: float = [0.45, 0.75, 1.0][clampi(Game.reach_stage(), 0, 2)]
	# Tops out around the biggest rival records, so even a famous band needs
	# a strong song (and some luck) for a No.1.
	return (0.04 + pow(f / 100.0, 1.5) * 0.9) * spread


static func _resolve_star(ev: Dictionary, choice: Variant) -> Dictionary:
	var m: Dictionary = Game.musicians.get(ev.mid, {})
	if m.is_empty():
		return {}
	if choice != "accept":
		return _res("Thanks, but no", "You told %s you're happy with the line-up. They looked genuinely surprised." % m.name, "x")
	if float(ev.price) > Game.funds:
		return _res("Can't afford it", "Even at mates' rates, %s costs more than you've got." % m.name, "funds", "bad")
	Game.sign_musician(m.id, float(ev.price))
	Game.buzz += 6.0
	shift_public(0.08, 0.0)
	return _res("SUPERSTAR SIGNING", "%s has joined %s! The music press has gone into meltdown." % [m.name, Game.band_name], "crown", "good")


static func _resolve_random(ev: Dictionary, choice: Variant) -> Dictionary:
	var e: Dictionary = event_def(ev)
	var c: Dictionary = e.choices[int(choice)]
	var f := Game.fame()
	var m: Dictionary = Game.musicians.get(ev.get("mid", ""), {})
	var mname: String = m.name if not m.is_empty() else "Someone"
	if c.has("cost_scale"):
		var cost := random_cost(c)
		if not Game.spend(cost, "that"):
			return _res("Can't afford it", "You'll have to take the other option.", "funds", "bad")
	var tips_line := ""
	if c.has("tips"):
		var tips := roundf(float(c.tips) * randf_range(0.7, 1.4) * Game.city_cost() * Settings.income_mult())
		Game.earn(tips)
		tips_line = " (%s in tips)" % U.money(tips)
	if c.has("cash_scale"):
		Game.earn(roundf(float(c.cash_scale) * (1.0 + f / 10.0) * Settings.income_mult()))
	if c.has("happy"):
		for mm in Game.members():
			mm.happy = clampf(float(mm.happy) + float(c.happy), 0.0, 100.0)
	if c.has("happy_member") and not m.is_empty():
		m.happy = clampf(float(m.happy) + float(c.happy_member), 0.0, 100.0)
	if c.has("others_happy"):
		for mm in Game.members():
			if mm.id != ev.get("mid", ""):
				mm.happy = clampf(float(mm.happy) + float(c.others_happy), 0.0, 100.0)
	if c.has("member_fame") and not m.is_empty():
		m.fame = clampf(float(m.get("fame", 0.0)) + float(c.member_fame), 0.0, 100.0)
	if c.has("listeners_flat"):
		Game.public.add_listeners(float(c.listeners_flat), Public.SCOPE_LOCAL if c.get("local", false) else Public.SCOPE_REACH)
	if c.has("listeners_pct") or c.has("fans_pct"):
		shift_public(float(c.get("listeners_pct", 0.0)), float(c.get("fans_pct", 0.0)))
	if c.has("fans_flat"):
		Game.public.lose(0.02, Public.FAN, 8.0)
	if c.get("skill_loss", false):
		for mm in Game.members():
			mm.skill = maxf(1.0, float(mm.skill) - 0.5)
	if c.get("downgrade", false) and not m.is_empty():
		m.inst = maxi(0, int(m.inst) - 1)
	var text: String = event_text(c.result, ev, mname) + tips_line
	if c.get("battle", false):
		text = _battle_of_the_bands(ev)
	return _res(e.title, text, e.icon)


static func _battle_of_the_bands(ev: Dictionary) -> String:
	var rival := str(ev.get("rival", "the favourites"))
	var p := clampf(0.3 + (Game.band_score() - 40.0) / 80.0, 0.15, 0.85)
	if randf() < p:
		var prize := roundf(randf_range(150.0, 300.0) * Game.city_cost() * Settings.income_mult() / 10.0) * 10.0
		Game.earn(prize)
		Game.public.add_listeners(40.0, Public.SCOPE_LOCAL)
		for mm in Game.members():
			mm.happy = clampf(float(mm.happy) + 5.0, 0.0, 100.0)
		return "You WON! The judges loved you, %s sulked in the car park, and the prize was %s." % [rival, U.money(prize)]
	Game.public.add_listeners(12.0, Public.SCOPE_LOCAL)
	for mm in Game.members():
		mm.happy = clampf(float(mm.happy) - 3.0, 0.0, 100.0)
	return "%s won. You came a respectable second, and a few people in the crowd asked for your name." % rival


static func random_cost(c: Dictionary) -> float:
	return roundf(float(c.cost_scale) * (1.0 + Game.fame() / 20.0) / 5.0) * 5.0


static func _resolve_media_deal(ev: Dictionary, choice: Variant) -> Dictionary:
	if choice != "accept":
		return _res("Maybe later", "You turned it down. Mystique is valuable too.", "x")
	var fee := float(ev.fee) * Settings.income_mult()
	Game.earn(fee)
	if ev.type == "doc":
		Game.flags.doc_done = true
		shift_public(0.15, 0.05, Public.SCOPE_NATIONAL)
		Game.buzz += 8.0
		Game.add_inbox("Documentary deal", "'%s' is in production. Fee: %s." % [ev.title, U.money(fee)], "film", "good")
		return _res(ev.title, "Cameras follow the band everywhere for months. It streams worldwide to rave reviews.\n\nFee: %s · More listeners and fans nationwide" % U.money(fee), "film", "good")
	Game.flags.film_done = true
	shift_public(0.12, 0.06, Public.SCOPE_NATIONAL)
	Game.buzz += 8.0
	Game.add_inbox("Concert film", "'%s' is coming to cinemas. Fee: %s." % [ev.title, U.money(fee)], "film", "good")
	return _res(ev.title, "Thirty cameras, one legendary night at %s. It's showing in cinemas worldwide.\n\nFee: %s" % [ev.venue, U.money(fee)], "film", "good")


static func breakup_beg_cost() -> float:
	return roundf(maxf(200.0, Game.funds * 0.2) / 10.0) * 10.0


static func _resolve_breakup(choice: Variant) -> Dictionary:
	if choice == "beg":
		var cost := breakup_beg_cost()
		Game.spend(cost, "the peace offering")
		if randf() < 0.5:
			for m in Game.members():
				m.happy = clampf(float(m.happy) + 22.0, 0.0, 100.0)
			return _res("Crisis averted", "After a long night, a lot of tears and a curry, the band agree to give it one more go.", "heart", "good")
	Game.queue.push_front({"type": "end", "reason": "split"})
	return {}
