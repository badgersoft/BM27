extends Node
## Headless balance test. Plays the game with a simple bot for N weeks and
## prints progress. Run:
##   godot --headless --path . res://tests/sim_test.tscn -- --weeks=400 --runs=3

var G: Node
var D: Node
var weeks := 400
var runs := 3
var verbose := true
var seen_events: Dictionary = {}
var tour_at := -1
var neglect := false
var bot := AutoPlayer.new()


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--weeks="):
			weeks = int(a.get_slice("=", 1))
		elif a.begins_with("--runs="):
			runs = int(a.get_slice("=", 1))
		elif a.begins_with("--tour="):
			tour_at = int(a.get_slice("=", 1))
		elif a == "--neglect":
			neglect = true
		elif a == "--quiet":
			verbose = false
	await get_tree().process_frame
	bot.neglect = neglect
	G = Game
	D = Data
	var summary: Array = []
	for r in runs:
		summary.append(play_run(r))
	print("\nEvents seen: ", seen_events)
	print("\n==== SUMMARY ====")
	for s in summary:
		print(s)
	get_tree().quit(0)


func play_run(run_idx: int) -> String:
	G.new_game()
	G.choose_manager(G.manager_choices[run_idx % 4])
	var mgr: Dictionary = G.manager()
	print("\n### Run %d · manager %s · funds %s" % [run_idx, mgr.short, U.money(G.funds)])
	bot.setup_band()
	print("Band: %s · %s · score %.1f · funds %s" % [G.band_name, G.genre, G.band_score(), U.money(G.funds)])
	var ended_at := -1
	for i in weeks:
		if i == 60:
			# Save/load round trip mid-career.
			var before := "%s|%d|%.2f|%d" % [G.band_name, G.week, G.funds, G.releases.size()]
			G.save_game()
			G.load_game()
			var after := "%s|%d|%.2f|%d" % [G.band_name, G.week, G.funds, G.releases.size()]
			print("save/load round trip: ", "OK" if before == after else "MISMATCH %s vs %s" % [before, after])
		if tour_at >= 0 and i == tour_at:
			print("can start final tour: ", G.can_start_final_tour())
			G.start_final_tour()
		bot.play_week(seen_events)
		if G.game_over:
			ended_at = G.week
			break
		if verbose and G.week % 24 == 1:
			print_status()
	print_status()
	return "run %d %s: week %d fame %.0f fans %s listeners %s funds %s best_nat %d albums %d best_venue %s end=%s" % [
		run_idx, mgr.short, G.week, G.fame(), U.num(G.true_fans), U.num(G.listeners), U.money(G.funds),
		int(G.stats.best_nat), int(G.flags.albums), D.gig_venue(int(G.stats.best_venue)).name if int(G.stats.best_venue) >= 0 else "-",
		G.end_reason if ended_at >= 0 else "running"]


func print_status() -> void:
	var offers: Array = G.gig_offers.map(func(i): return D.gig_venue(i).name.substr(0, 14))
	var n40: float = G.chart_nat[39].power if G.chart_nat.size() >= 40 else 0.0
	print("   nat#1 %.0f nat#20 %.0f nat#40 %.0f · fatigue %.1f" % [G.chart_nat[0].power, G.chart_nat[19].power, n40, float(G.flags.fatigue)])
	print("%s fame %4.1f fans %7s lis %8s funds %8s score %5.1f happy %4.0f prac %d song %4.1f offers %s rel %d" % [
		U.date_label(G.week), G.fame(), U.num(G.true_fans), U.num(G.listeners), U.money(G.funds), G.band_score(),
		G.avg_happiness(), G.practice_idx, G.songcraft, offers, G.releases.size()])
