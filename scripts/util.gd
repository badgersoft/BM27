class_name U
extends RefCounted
## Shared formatting and calendar helpers.
## Calendar: 4 weeks a month, 12 months (48 weeks) a year.

const WEEKS_PER_MONTH := 4
const WEEKS_PER_YEAR := 48
const MONTHS := ["January", "February", "March", "April", "May", "June", "July", "August",
	"September", "October", "November", "December"]


static func date(week: int) -> Dictionary:
	var w := week - 1
	var month_idx := w / WEEKS_PER_MONTH
	return {
		"week": week,
		"week_of_month": (w % WEEKS_PER_MONTH) + 1,
		"month_idx": month_idx,
		"month": MONTHS[month_idx % 12],
		"month_short": MONTHS[month_idx % 12].substr(0, 3).to_upper(),
		"year": w / WEEKS_PER_YEAR + 1,
	}


static func date_label(week: int) -> String:
	var d := date(week)
	return "WK %d · %s · Y%d" % [d.week_of_month, d.month_short, d.year]


static func duration(weeks: int) -> String:
	weeks = maxi(0, weeks)
	var y := weeks / WEEKS_PER_YEAR
	var w := weeks % WEEKS_PER_YEAR
	if y == 0:
		return "%dw" % w
	return "%dy %dw" % [y, w]


static func _commas(n: int) -> String:
	var s := str(absi(n))
	var out := ""
	while s.length() > 3:
		out = "," + s.substr(s.length() - 3) + out
		s = s.substr(0, s.length() - 3)
	return ("-" if n < 0 else "") + s + out


static func _trim(s: String) -> String:
	if s.contains("."):
		while s.ends_with("0"):
			s = s.substr(0, s.length() - 1)
		if s.ends_with("."):
			s = s.substr(0, s.length() - 1)
	return s


## £950 · £9,850 · £12.4k · £1.25M
## The game's version (MAJOR.MINOR.PATCH), from project.godot. See
## tools/version.sh for how it's bumped.
static func version() -> String:
	return str(ProjectSettings.get_setting("application/config/version", "0.0.0"))


## Capitalises a title the player types the way the game's own titles are
## written, every word starting with a capital: "the shed in the rain" ->
## "The Shed In The Rain". Words with deliberate capitals ("McFly", "UK",
## "iPod") are left alone unless the whole title was typed in capitals.
static func title_case(text: String) -> String:
	var t := text.strip_edges()
	while "  " in t:
		t = t.replace("  ", " ")
	var all_caps := t == t.to_upper() and t != t.to_lower()
	var out: PackedStringArray = []
	for w in t.split(" "):
		out.append(_title_word(w, all_caps))
	return " ".join(out)


static func _title_word(w: String, all_caps: bool) -> String:
	if "-" in w:
		var done: PackedStringArray = []
		for part in w.split("-"):
			done.append(_title_word(part, all_caps))
		return "-".join(done)
	# Leading punctuation like ( or ' stays put.
	var lead := ""
	while w.length() > 0 and w[0].to_lower() == w[0].to_upper() and not w[0].is_valid_int():
		lead += w[0]
		w = w.substr(1)
	if w == "":
		return lead
	if not all_caps and w != w.to_lower():
		return lead + w   # deliberate capitals: McFly, UK, iPod
	var low := w.to_lower()
	return lead + low.substr(0, 1).to_upper() + low.substr(1)


static func money(v: float) -> String:
	var neg := v < 0.0
	v = absf(v)
	var s: String
	if v >= 1e6:
		s = "£" + _trim("%.2f" % (v / 1e6)) + "M"
	elif v >= 1e4:
		s = "£" + _trim("%.1f" % (v / 1e3)) + "k"
	else:
		s = "£" + _commas(int(round(v)))
	return ("−" if neg else "") + s


static func money_full(v: float) -> String:
	return ("−" if v < 0.0 else "") + "£" + _commas(int(round(absf(v))))


## 950 · 9,850 · 12.4k · 1.25M
static func num(v: float) -> String:
	var a := absf(v)
	var s: String
	if a >= 1e6:
		s = _trim("%.2f" % (a / 1e6)) + "M"
	elif a >= 1e4:
		s = _trim("%.1f" % (a / 1e3)) + "k"
	else:
		s = _commas(int(round(a)))
	return ("−" if v < -0.5 else "") + s


static func signed_num(v: float) -> String:
	if v >= 0.5:
		return "+" + num(v)
	if v <= -0.5:
		return "−" + num(-v)
	return "±0"


static func signed_money(v: float) -> String:
	if v >= 0.5:
		return "+" + money(v)
	if v <= -0.5:
		return "−" + money(-v)
	return "£0"


static func ordinal(n: int) -> String:
	var v := n % 100
	if v >= 11 and v <= 13:
		return "%dth" % n
	match n % 10:
		1: return "%dst" % n
		2: return "%dnd" % n
		3: return "%drd" % n
	return "%dth" % n


static func plural(n: int, one: String, many: String = "") -> String:
	if n == 1:
		return one
	return many if many != "" else one + "s"


static func stars_text(rating: float) -> String:
	var full := int(floor(rating))
	var half := rating - full >= 0.5
	return "★".repeat(full) + ("½" if half else "")
