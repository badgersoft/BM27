class_name AutoPlayer
extends RefCounted
## A simple computer manager. Used by the balance test (tests/sim_test.gd)
## and the screenshot tour (scripts/autotest.gd). Not used in normal play.

var neglect := false


## Sign the best players each role's budget allows, then form the band.
func setup_band(city: int = -1) -> void:
	if Game.base_city < 0:
		Game.set_base_city(city if city >= 0 else randi() % Game.public.cities.size())
	for role in Game.ROLES:
		var budget: float = Game.funds * 0.25
		var best: Dictionary = {}
		for m in Game.market(role):
			if Game.value_of(m) <= budget and (best.is_empty() or float(m.skill) > float(best.skill)):
				best = m
		if best.is_empty():
			for m in Game.market(role):
				if Game.value_of(m) == 0:
					best = m
					break
		Game.sign_musician(best.id, Game.value_of(best))
	Game.form_band(Data.band_name_options(Game.genre)[0], Game.genre)


## Play one full week: decisions, advance, then answer every event.
func play_week(seen: Dictionary = {}) -> void:
	bot_week()
	Game.advance_week()
	while Game.has_events():
		var ev: Dictionary = Game.pop_event()
		seen[ev.type] = int(seen.get(ev.type, 0)) + 1
		bot_event(ev)


func bot_week() -> void:
	# Book the biggest affordable gig.
	if Game.gig_booked < 0 and not Game.gig_offers.is_empty():
		var choice := -1
		for idx in Game.gig_offers:
			var est: Vector2i = Game.estimate_attendance(idx)
			var income: float = (est.x + est.y) * 0.5 * Game.gig_income_per_head(idx)
			if Game.venue_hire(idx) <= Game.funds and (income > Game.venue_hire(idx) * 0.7 or Game.funds > Game.venue_hire(idx) * 4.0):
				choice = idx
		# Nobody gets famous without playing: book the cheapest slot if nothing pays.
		if choice < 0:
			var cheapest: int = Game.gig_offers[0]
			if Game.funds >= Game.venue_hire(cheapest) + 30.0:
				choice = cheapest
		if choice >= 0:
			Game.book_gig(choice)
	# Focus.
	if neglect:
		Game.set_focus("rehearse")
		return
	if Game.funds < 150:
		Game.set_focus("odd_jobs" if Game.week % 2 == 0 else "busk")
	elif Game.demos.size() < 8 and Game.week % 3 == 0:
		Game.set_focus("write")
	elif Game.week % 3 == 1 and Game.funds > Game.promote_cost() * 6:
		Game.set_focus("promote")
	elif Game.avg_happiness() < 40:
		Game.set_focus("chill")
	else:
		Game.set_focus("rehearse")
	# Upgrades.
	var nxt: int = Game.practice_idx + 1
	if nxt < Data.practice.size() and Game.funds > Game.rent_of(nxt) * 40 + 500:
		Game.set_practice(nxt)
	for m in Game.members():
		var t: int = int(m.inst) + 1
		if t <= 7 and Game.funds > Game.gear_price(Data.instrument(m.role, t).cost) * 5 + 300:
			Game.upgrade_instrument(m.role, t)
	# Replace the weakest member when rich.
	if Game.week % 8 == 0:
		for role in Game.ROLES:
			var cur: Dictionary = Game.member(role)
			for m in Game.market(role):
				var v: int = Game.value_of(m)
				if v <= Game.funds * 0.3 and float(m.skill) > float(cur.skill) + 12:
					Game.make_offer(m.id, v)
					break


func bot_event(ev: Dictionary) -> void:
	match ev.type:
		"interview": Game.resolve_event(ev, "humble")
		"producer":
			var pick := -1
			for idx in ev.options:
				if float(MediaData.PRODUCERS[idx].fee) <= Game.funds * 0.5:
					pick = idx
			Game.resolve_event(ev, pick)
		"name_release":
			ev.feel = randi() % 5
			Game.resolve_event(ev, ev.options[0])
		"label", "doc", "film": Game.resolve_event(ev, "accept")
		"star": Game.resolve_event(ev, "accept" if float(ev.price) <= Game.funds * 0.5 else "decline")
		"complaint":
			if neglect:
				Game.resolve_event(ev, {"kind": "ignore"})
				return
			var m: Dictionary = Game.musicians[ev.mid]
			var opts: Array = Game.bonus_options(m)
			if float(opts[1][0]) <= Game.funds * 0.2:
				Game.resolve_event(ev, {"kind": "bonus", "amount": opts[1][0], "boost": opts[1][1]})
			else:
				Game.resolve_event(ev, {"kind": "talk"})
		"left":
			var pick2 := "none"
			for id in ev.options:
				if Game.value_of(Game.musicians[id]) <= Game.funds:
					pick2 = id
					break
			Game.resolve_event(ev, pick2)
			if Game.member(ev.role).is_empty():
				for m2 in Game.market(ev.role):
					if Game.value_of(m2) <= Game.funds:
						Game.sign_musician(m2.id, Game.value_of(m2))
						break
		"random", "fame":
			var e: Dictionary = Events.event_def(ev)
			var c0: Dictionary = e.choices[0]
			var ok: bool = not c0.has("cost_scale") or Events.random_cost(c0) <= Game.funds * 0.3
			Game.resolve_event(ev, 0 if ok else 1)
		"breakup": Game.resolve_event(ev, "beg")
		"end": Game.resolve_event(ev, "ok")
		_: Game.resolve_event(ev, "ok")
