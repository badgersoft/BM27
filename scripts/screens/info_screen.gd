extends Screen
## How to play.

const SECTIONS := [
	["star", "The Goal", "Start with almost nothing and turn four nobodies into the biggest band in the land. Fill Wombley Stadium, top the charts, and retire a legend with a Final Tour, or watch it all fall apart."],
	["users", "Your Band", "Four members: singer, guitarist, bassist and drummer. Each has a current skill and a potential. Young players have more room to grow. Original members are marked with a star."],
	["amp", "Every Week", "Choose the band's focus: Rehearse (skills), Write Songs (better songs and singles), Busk (cash and listeners), Promote (spend money for listeners) or Chill Out (morale). Then hit NEXT WEEK."],
	["ticket", "Monthly Gigs", "Each month venues offer you a slot based on your following. Book one, pay the hire, and play at the end of the month. Bigger venues pay more, but the crowd expects more too. Skipping a month costs you fans."],
	["heart", "Your Public", "29,000 named music fans live across 9 regions: the three biggest cities in each, plus the City of London. Each has favourite genres, an age, a love of gigs, an appetite for new music (variance) and loyalty. They climb a ladder: Listener, Regular listener, Fan, then Super fan after six months. Great gigs win them over; boredom and bad gigs lose them."],
	["home", "Home City & Spreading", "You pick a home city. Bigger cities have more potential fans but cost more. Win 25 fans at home and word spreads across your region; build a regional following (or land a national hit) and you go national. Check the Fans page for your top fans and where they live."],
	["smile", "Keeping Them Happy", "Contentment affects how well they play. Good gear, a decent rehearsal space, the right genre, rest and success keep musicians sweet. Unhappy ones will want a word. Gifts and bonuses help, but get less effective if you lean on them."],
	["vinyl", "Singles & Albums", "Get famous enough and producers will call. Your single's success depends on the band, the producer, your best demo song, and the mysterious It Factor. Write demos on Write Songs weeks: singles use your best one, albums your best ten. Two Top 20 hits and the record labels come knocking. Albums sell for five times as much."],
	["news", "Press & Rivals", "Interviews start at the school paper and end on global TV. Choose your tone carefully. A music paper lands every two weeks. Other bands in your genre compete for the same crowds."],
	["swap", "Genre", "You can change genre any time. People who don't like the new sound drift away (loyal ones less so); people who love it warm to you."],
	["flag", "The Final Tour", "After ten years together, with enough fame, you can choose to announce a six-month Final Tour. Every casual fan wants a last look, so gate receipts and merch soar. Then you retire into the Hall of Fame. It is entirely optional: a band can keep going for decades if it holds together."],
	["alert", "Game Over", "If your following crashes from its peak and the band is miserable, they may decide to split up for good."],
	["funds", "Money", "Rehearsal rent is weekly. Gig hire is paid when you book. You earn from tickets, half the bar takings, merch, record sales, interviews and the odd deal. You can't go into debt: if you can't pay the rent, it's back to Nan's shed."],
]


func _ready() -> void:
	add_child(UI.full_rect(StageBackdrop.new()))
	var v := page_root(48)
	var top := UI.hbox(16)
	top.add_child(UI.button("BACK", "chevL", "Ghost", func(): go("menu")))
	top.add_child(UI.spacer())
	v.add_child(top)
	v.add_child(header("How To Play", "Everything a rookie manager needs to know. You'll pick up the rest the hard way.", "Information"))
	var grid := GridContainer.new()
	grid.columns = 2 if get_viewport_rect().size.x > 900 else 1
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 16)
	for s in SECTIONS:
		var c: Array = UI.card(s[1], s[0], "Card", UITheme.GOLD)
		c[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
		c[1].add_child(UI.label(s[2], "Body", null, true))
		grid.add_child(c[0])
	var credit: Array = UI.card("Credits", "info", "CardFlat")
	credit[1].add_child(UI.label("Band Manager 27 by Badger-soft. Made with Godot. Fonts: Bebas Neue, Barlow & Playfair Display (SIL Open Font License). All bands, musicians, venues and albums are fictional parodies.", "BodyMuted", null, true))
	var body := UI.vbox(16, [grid, credit[0]])
	v.add_child(UI.scroller(body))


func on_back() -> void:
	go("menu")
