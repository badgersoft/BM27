class_name AutoTest
extends RefCounted
## Automated screenshot tour for development. Run with:
##   godot --path . -- --autotest --out=res://tests/shots
## Plays through setup, simulates a career and captures every screen and
## event modal. Not used in normal play.

static var main_ref: Control
static var out_dir := "res://tests/shots"


static func maybe_run(main: Control) -> bool:
	var args := OS.get_cmdline_user_args()
	if not "--autotest" in args:
		return false
	for a in args:
		if a.begins_with("--out="):
			out_dir = a.get_slice("=", 1)
	main_ref = main
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))
	# Keep Godot from importing the screenshots as project assets.
	var gi := FileAccess.open(out_dir.path_join(".gdignore"), FileAccess.WRITE)
	if gi:
		gi.close()
	if "--monkey" in args:
		var steps := 1500
		for a in args:
			if a.begins_with("--steps="):
				steps = int(a.get_slice("=", 1))
		_monkey.call_deferred(steps)
	else:
		_run.call_deferred()
	return true


## Presses random visible buttons (on the top modal if there is one) to
## smoke-test every UI callback. Prefers NEXT WEEK so careers progress.
static func _monkey(steps: int) -> void:
	var m := main_ref
	var rng := RandomNumberGenerator.new()
	rng.seed = 2727
	Game.delete_save()
	m.show_screen("menu")
	var pressed: Dictionary = {}
	for i in steps:
		await m.get_tree().process_frame
		var root: Node = m.modal_layer.get_child(m.modal_layer.get_child_count() - 1) if m.modal_layer.get_child_count() > 0 else m.screen_layer
		var buttons: Array = []
		_collect_buttons(root, buttons)
		if buttons.is_empty():
			continue
		var pick: Button = null
		if m.current_name == "hq" and m.modal_layer.get_child_count() == 0 and rng.randf() < 0.55:
			pick = m.current.next_btn
		elif m.current_name == "recruit" and not m.current.next_btn.disabled and rng.randf() < 0.5:
			pick = m.current.next_btn
		else:
			pick = buttons[rng.randi_range(0, buttons.size() - 1)]
		if pick == null or pick.disabled:
			continue
		var key := "%s:%s" % [m.current_name, pick.text]
		pressed[key] = int(pressed.get(key, 0)) + 1
		pick.pressed.emit()
		if i % 250 == 0:
			print("monkey step %d · screen %s · week %d · band '%s' · funds %s" % [i, m.current_name, Game.week, Game.band_name, U.money(Game.funds)])
	print("monkey done: %d distinct buttons pressed" % pressed.size())
	Game.delete_save()
	m.get_tree().quit()


static func _collect_buttons(n: Node, out: Array) -> void:
	if n is CanvasItem and not n.is_visible_in_tree():
		return
	if n is Button and not n.disabled and n.text.strip_edges() != "QUIT":
		out.append(n)
	for c in n.get_children():
		_collect_buttons(c, out)


static func _shot(name: String) -> void:
	await main_ref.get_tree().process_frame
	await main_ref.get_tree().process_frame
	await main_ref.get_tree().process_frame
	var img := main_ref.get_viewport().get_texture().get_image()
	img.save_png(out_dir + "/" + name + ".png")
	print("shot: ", name)


static func _run() -> void:
	var m := main_ref
	Game.delete_save()
	m.show_screen("menu")
	await _shot("01_menu")
	m.show_screen("info")
	await _shot("02_info")
	m.show_screen("settings")
	await _shot("03_settings")
	Game.new_game()
	m.show_screen("managers")
	await _shot("04_managers")
	Game.choose_manager(Game.manager_choices[0])
	m.show_screen("practice_setup")
	await _shot("05_practice")
	Game.practice_idx = 0
	# Sign the best affordable player for the first two roles.
	for role in ["vocals", "guitar"]:
		var best: Dictionary = {}
		for mu in Game.market(role):
			if Game.value_of(mu) <= Game.funds * 0.25 and (best.is_empty() or float(mu.skill) > float(best.skill)):
				best = mu
		Game.sign_musician(best.id, Game.value_of(best))
	m.show_screen("recruit")
	await _shot("06_recruit")
	MusicianView.open_offer(m, Game.market("bass")[0], func(_ok): pass)
	await _shot("07_offer")
	m.close_all_modals()
	for role in ["bass", "drums"]:
		for mu in Game.market(role):
			if Game.value_of(mu) <= Game.funds * 0.4:
				Game.sign_musician(mu.id, Game.value_of(mu))
				break
	m.show_screen("naming")
	await _shot("08_naming")
	Game.form_band(Data.band_name_options(Game.genre)[0], Game.genre)
	m.show_screen("hq", {"welcome": true})
	await _shot("09_hq_welcome")
	var bot := AutoPlayer.new()
	for i in 8:
		bot.play_week()
	m.show_screen("hq")
	await _shot("09b_hq_early")
	if not Game.gig_history.is_empty():
		EventView.present(m, {"type": "gig", "gig": Game.gig_history[0]}, func(): pass)
		await _shot("09c_gig_early")
		m.close_all_modals()
	m.current.open_page("gigs")
	await _shot("09d_gigs_early")
	# Simulate a career so every page has something in it.
	for i in 142:
		bot.play_week()
	m.show_screen("hq")
	await _shot("10_hq_home")
	var hq: Control = m.current
	for p in ["band", "talent", "gigs", "rehearsal", "charts", "releases", "scene", "inbox"]:
		hq.open_page(p)
		await _shot("11_page_" + p)
	hq.open_page("home")
	# Event modals.
	if not Game.gig_history.is_empty():
		EventView.present(m, {"type": "gig", "gig": Game.gig_history[0]}, func(): pass)
		await _shot("20_gig")
		m.close_all_modals()
	Events.queue_news()
	EventView.present(m, Game.pop_event(), func(): pass)
	await _shot("21_news")
	m.close_all_modals()
	EventView.present(m, {"type": "interview", "outlet": 6}, func(): pass)
	await _shot("22_interview")
	m.close_all_modals()
	EventView.present(m, {"type": "complaint", "mid": Game.members()[0].id}, func(): pass)
	await _shot("23_complaint")
	m.close_all_modals()
	EventView.present(m, {"type": "producer", "options": [3, 4, 5]}, func(): pass)
	await _shot("24_producer")
	m.close_all_modals()
	EventView.present(m, {"type": "name_release", "kind": "single", "quality": 50.0, "it": 1.0, "producer": "Puddle", "options": Data.song_title_options(Game.genre, [])}, func(): pass)
	await _shot("25_name_release")
	m.close_all_modals()
	var star := Events._star_offer()
	if not star.is_empty():
		EventView.present(m, star, func(): pass)
		await _shot("26_star")
		m.close_all_modals()
	EventView.present(m, {"type": "random", "idx": 1, "mid": Game.members()[1].id, "rival": "The Wet Biscuits"}, func(): pass)
	await _shot("27_random")
	m.close_all_modals()
	EventView.present(m, {"type": "label", "label": 3}, func(): pass)
	await _shot("28_label")
	m.close_all_modals()
	Game.end_reason = "retired"
	m.show_screen("end")
	await _shot("30_end")
	Game.delete_save()
	m.get_tree().quit()
