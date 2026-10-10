extends Node
## Times generation, a national-stage weekly step, gig crowds and save/load.
func _ready() -> void:
	var p := Public.new()
	var t0 := Time.get_ticks_usec()
	p.generate(12345)
	var t1 := Time.get_ticks_usec()
	p.set_base(0)
	p._ensure_taste("rock")
	p.unlock(2)
	for c in p.cities.size():
		p.exposure[c] = 0.6
	for i in 30:
		p.step("rock", 1.3)
	var t2 := Time.get_ticks_usec()
	p.step("rock", 1.3)
	var t3 := Time.get_ticks_usec()
	var crowd := p.gig_crowd(0, true, false)
	var t4 := Time.get_ticks_usec()
	var d := p.to_dict()
	var json := JSON.stringify(d)
	var q := Public.new()
	q.from_dict(JSON.parse_string(json))
	var t5 := Time.get_ticks_usec()
	print("people %d · generate %.1f ms · one national week %.1f ms · gig crowd %.1f ms · save+load %.1f ms (%d KB)" % [
		p.size(), (t1 - t0) / 1000.0, (t3 - t2) / 1000.0, (t4 - t3) / 1000.0, (t5 - t4) / 1000.0, json.length() / 1024])
	q._recount()
	print("tiers ", p.tier_count, " · engaged ", p.engaged.size(), " · reload matches: ", q.tier_count == p.tier_count)
	var counts := {}
	for c in p.cities:
		counts[c.name] = c.count
	print(counts)
	get_tree().quit()
