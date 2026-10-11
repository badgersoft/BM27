class_name MediaData
extends RefCounted
## Press, radio, TV, producers, record labels, newspapers and random events.

## Interview outlets. fame = minimum fame to be asked. reach = listener gain scale.
## fee = what they pay (big shows pay appearance fees).
const OUTLETS := [
	{"name": "St. Agnes School Gazette", "kind": "School newspaper", "fame": 0, "reach": 6, "fee": 0, "icon": "news"},
	{"name": "The Parish Pump Newsletter", "kind": "Village newsletter", "fame": 0, "reach": 8, "fee": 0, "icon": "news"},
	{"name": "BURP FM ({city} Uni Radio)", "kind": "Student radio", "fame": 6, "reach": 25, "fee": 0, "icon": "radio"},
	{"name": "Sniffin' Glue Again", "kind": "Photocopied fanzine", "fame": 8, "reach": 30, "fee": 0, "icon": "news"},
	{"name": "The {city} Echo", "kind": "Local newspaper", "fame": 14, "reach": 90, "fee": 0, "icon": "news"},
	{"name": "Radio {city}", "kind": "Local radio", "fame": 18, "reach": 160, "fee": 50, "icon": "radio"},
	{"name": "{region} Tonight", "kind": "Regional TV news", "fame": 28, "reach": 600, "fee": 150, "icon": "film"},
	{"name": "Kerplang! Magazine", "kind": "Rock magazine", "fame": 36, "reach": 1800, "fee": 300, "icon": "news"},
	{"name": "NMEh", "kind": "Music weekly", "fame": 42, "reach": 3500, "fee": 500, "icon": "news"},
	{"name": "Que? Magazine", "kind": "Monthly music magazine", "fame": 50, "reach": 7000, "fee": 1000, "icon": "news"},
	{"name": "Radio Won Breakfast Show", "kind": "National radio", "fame": 58, "reach": 12000, "fee": 2000, "icon": "radio"},
	{"name": "Sooner... with Jools Hollandaise", "kind": "TV music show", "fame": 66, "reach": 22000, "fee": 5000, "icon": "film"},
	{"name": "Top of the Plops", "kind": "Chart TV show", "fame": 74, "reach": 35000, "fee": 10000, "icon": "film"},
	{"name": "Rolling Scone Magazine (Cover)", "kind": "Global magazine", "fame": 82, "reach": 55000, "fee": 25000, "icon": "news"},
	{"name": "MTV-ish Unplugged-ish", "kind": "Global TV special", "fame": 88, "reach": 90000, "fee": 60000, "icon": "film"},
]

const TONES := [
	{"id": "humble", "name": "Humble", "icon": "smile", "desc": "Thank the fans, praise the band. Safe and steady."},
	{"id": "cocky", "name": "Cocky", "icon": "flame", "desc": "Biggest band in the world, mate. More buzz, egos may bruise."},
	{"id": "mystery", "name": "Mysterious", "icon": "eye", "desc": "Say very little, wear sunglasses. Slow-burn intrigue."},
	{"id": "wild", "name": "Controversial", "icon": "bolt", "desc": "Say something outrageous. Could go massive. Could backfire."},
]

const TONE_RESULTS := {
	"humble": ["You thanked everyone including the tea lady. Readers found it genuinely charming.",
		"Lovely, grounded chat. Your mum cut it out and stuck it on the fridge.",
		"You talked about the music, not yourselves. People noticed."],
	"cocky": ["You declared the band 'better than Queue'. The headline wrote itself.",
		"You turned up late and called the interviewer 'pal'. Somehow it worked.",
		"'We're the best band in the country and the country's lucky.' The quote is everywhere."],
	"mystery": ["You answered every question with another question. Fans are obsessed with decoding it.",
		"Sunglasses, single-word answers, a cryptic smile. The internet loves a riddle.",
		"You hinted at 'something big'. Nobody knows what. Including you."],
	"wild_good": ["You claimed the drummer was raised by badgers. It went viral overnight.",
		"You set fire to a copy of the competition's album live on air. Iconic, apparently.",
		"You called the biggest band in the world 'a tribute act'. Everybody's talking about you."],
	"wild_bad": ["You insulted the host's mum. Live. It did not go down well.",
		"A rant about pigeons went too far. Several pigeon fanciers have cancelled their tickets.",
		"You said the fans 'smell a bit'. Some of them heard."],
}

## Record producers. fame = minimum fame before they'll take your call.
const PRODUCERS := [
	{"name": "Kev from the Carpet Warehouse", "fee": 120, "quality": 18, "fame": 0, "desc": "Records in the stockroom. Uses a laptop he won in a raffle."},
	{"name": "DJ Uncle Barry", "fee": 250, "quality": 28, "fame": 0, "desc": "Does weddings. Adds an airhorn to everything."},
	{"name": "Gaz \"Two Laptops\" Pritchard", "fee": 500, "quality": 38, "fame": 6, "desc": "Two laptops. Neither has ever crashed. Allegedly."},
	{"name": "Sandra at the Old Chapel Studio", "fee": 1000, "quality": 48, "fame": 12, "desc": "Warm valve sound, warmer cups of tea."},
	{"name": "Puddle", "fee": 3500, "quality": 60, "fame": 22, "desc": "Single-name producer. Moody. Makes things sound enormous."},
	{"name": "Steve Albino", "fee": 9000, "quality": 72, "fame": 32, "desc": "Records everything live. Calls producers 'parasites'. Brilliant."},
	{"name": "Butch Vague", "fee": 20000, "quality": 80, "fame": 42, "desc": "Not entirely sure what he does, but the records go platinum."},
	{"name": "Dave Fridge", "fee": 40000, "quality": 85, "fame": 52, "desc": "Keeps everything very, very cool."},
	{"name": "Nigel Goodrich", "fee": 80000, "quality": 90, "fame": 60, "desc": "Turns knobs nobody else knew existed."},
	{"name": "Mutt Lunge", "fee": 130000, "quality": 93, "fame": 68, "desc": "Every chorus a stadium anthem. Every take, the 400th take."},
	{"name": "Rick Rubbish", "fee": 220000, "quality": 96, "fame": 76, "desc": "Despite the name, a genius. Sits barefoot on a sofa and just knows."},
	{"name": "George Martini", "fee": 400000, "quality": 99, "fame": 84, "desc": "Shaken, not stirred. The fifth member of every band he touches."},
]

## Record labels that offer album deals.
const LABELS := [
	{"name": "Badger Beat Records", "quality": 45, "advance": 3000, "fame": 0},
	{"name": "Sub Pup", "quality": 58, "advance": 12000, "fame": 25},
	{"name": "Rough Tirade", "quality": 64, "advance": 30000, "fame": 35},
	{"name": "Factory Settings Records", "quality": 70, "advance": 70000, "fame": 45},
	{"name": "Cremation Records", "quality": 76, "advance": 150000, "fame": 55},
	{"name": "Dominoes Records", "quality": 82, "advance": 350000, "fame": 65},
	{"name": "XL-arge Recordings", "quality": 88, "advance": 800000, "fame": 75},
	{"name": "Peninsula Records", "quality": 93, "advance": 1800000, "fame": 85},
]

const PUBLICATIONS := ["The Weekly Riff", "Kerplang!", "NMEh", "Melody Moaner", "Que?"]

## Headlines about other bands. {b} = band, {b2} = second band, {s} = song, {n} = number.
const MEGA_HEADLINES := [
	"{b} ANNOUNCE {n}-NIGHT RUN AT WOMBLEY",
	"{b} DRUMMER QUITS TO OPEN ARTISAN CHEESE SHOP",
	"{b} TOP THE CHARTS WITH '{s}'",
	"{b} AND {b2} IN BACKSTAGE SANDWICH ROW",
	"{b} REVEAL 'DIFFICULT' 14-MINUTE SINGLE",
	"{b} SINGER BANNED FROM SEASIDE TOWN AFTER SEAGULL INCIDENT",
	"{b} TO HEADLINE GLASTONBELLY, AGAIN",
	"{b} ALBUM LEAKS: 'IT'S MOSTLY KAZOO'",
	"{b} REUNION RUMOURS AS GUITARIST SPOTTED IN SAME TESCO",
	"{b} BUY A CASTLE, IMMEDIATELY REGRET IT",
	"{b} SUE {b2} OVER 'SUSPICIOUSLY SIMILAR' CHORD",
	"{b} INTRODUCE £400 'VIP SOUNDCHECK EXPERIENCE'",
	"{b} ANNOUNCE FAREWELL TOUR (THEIR FIFTH)",
]
const MEGA_SUBS := [
	"Fans queued for {n} hours in the rain. 'Worth it,' says soggy teen.",
	"Critics call it 'their bravest work since the last one'.",
	"A spokesperson said the band 'had no comment, but loved the question'.",
	"The bassist was unavailable for comment, having been in a sensory deprivation tank since March.",
	"Tickets sold out in {n} seconds. Touts are already asking for a kidney.",
]

## Stories about YOUR band. {band}, {member}, {venue}, {single}.
const YOU_GOOD := [
	{"text": "Local critics name {band} 'ones to watch'. Everybody watches.", "listeners": 0.06, "fans": 0.0},
	{"text": "A Radio {city} DJ played {band} twice in one show 'by accident'. Calls flooded in.", "listeners": 0.08, "fans": 0.0},
	{"text": "{member} of {band} rescued a cat from a tree. The video has been shared everywhere.", "listeners": 0.05, "fans": 0.01},
	{"text": "{band}'s demo spotted on a famous footballer's playlist.", "listeners": 0.10, "fans": 0.0},
	{"text": "A busload of fans travelled 200 miles to see {band}. 'They're our band,' says Barbara, 64.", "listeners": 0.03, "fans": 0.03},
	{"text": "{band} T-shirt spotted at a celebrity wedding.", "listeners": 0.07, "fans": 0.01},
	{"text": "A {city} primary school choir covered a {band} song at assembly. Parents are humming it at the school gates.", "listeners": 0.05, "fans": 0.0},
	{"text": "{member} of {band} helped push a stranger's car out of a ditch, then signed the bumper.", "listeners": 0.04, "fans": 0.01},
	{"text": "A barber in {city} has started offering 'the {band}' haircut. Queues round the block.", "listeners": 0.06, "fans": 0.0},
	{"text": "{band} played an impromptu set for a hospital ward. Nurses say it was 'the best medicine, after medicine'.", "listeners": 0.05, "fans": 0.02},
	{"text": "Online music forum votes {band} 'most likely to be massive'. One user wrote 400 words on the bassline.", "listeners": 0.07, "fans": 0.01},
	{"text": "A {city} taxi driver plays {band} to every passenger. 'Nobody's complained yet,' he says.", "listeners": 0.04, "fans": 0.0},
]
const YOU_BAD := [
	{"text": "{member} of {band} spotted buying a keytar. Fans 'deeply concerned'.", "listeners": -0.04, "fans": 0.0},
	{"text": "{band} accidentally played the wrong town. 'We thought it was Tuesday,' admits {member}.", "listeners": -0.03, "fans": -0.01},
	{"text": "Online blogger calls {band} 'aggressively beige'. It's being shared a lot.", "listeners": -0.05, "fans": 0.0},
	{"text": "{member} of {band} caught miming at a charity football match.", "listeners": -0.04, "fans": -0.01},
	{"text": "{band} soundcheck noise complaint makes the front page of the Parish Pump.", "listeners": -0.02, "fans": 0.0},
	{"text": "{member} of {band} told a radio host that cheese is 'basically a vegetable'. Phone-in chaos.", "listeners": -0.02, "fans": 0.0},
	{"text": "{band} accused of 'borrowing' a chorus from a 1970s bin-lorry jingle.", "listeners": -0.03, "fans": 0.0},
	{"text": "Fans grumble after {band} turn up 90 minutes late to a meet-and-greet. 'The van had a puncture,' claims {member}.", "listeners": -0.02, "fans": -0.01},
]
const YOU_NEUTRAL := [
	"{band} were seen rehearsing again. Neighbours report 'it's getting better, to be fair'.",
	"{band} have been sticking up posters around town. Several are upside down.",
	"Who are {band}? Our reporter asked around. Nobody's sure, but the name's catchy.",
	"{band} reportedly working on 'new material'. {member} declined to say more, then said quite a lot more.",
	"{member} of {band} was spotted at a {city} charity shop, buying a velvet jacket 'for the stage'.",
	"{band} have been banned from a {city} chippy, but only on Tuesdays. Nobody will say why.",
	"Spotted: {band} arguing about setlists in a supermarket car park. {member} won, apparently.",
	"{band}'s van has a new paint job. Opinions are divided, mostly against.",
	"Our reporter asked {member} of {band} for their biggest influence. The answer was 'my mum'. Aww.",
	"{band} are rumoured to be learning a sea shanty 'for emergencies'.",
]

## When your band is the lead story: the standfirst under it, and the side box.
const LEAD_SUBS := [
	"Our reporter was there. Fans were going wild. Rival managers were taking notes.",
	"The phones haven't stopped ringing at the office since.",
	"We asked around town. Everybody had an opinion. Most of them were loud.",
	"Full story, pictures and a very blurry photo of the drummer on pages 4 to 7.",
	"Love them or hate them, you can't ignore them. We've tried.",
	"Their manager declined to comment, but did ask for extra copies.",
]
const LEAD_BOX := [
	"Everybody's talking about {band}. You can't move for their T-shirts.",
	"Ticket touts report '{band}' is now the most searched name on their sites.",
	"Our readers' poll: 61% love {band}, 12% hate them, 27% are 'just here for the crossword'.",
	"{band} merch spotted on three continents and one very confused sheep.",
	"Rumour has it {band} have been offered a waxwork. They've asked for it to be 'less shiny'.",
	"Radio stations say requests for {band} have doubled since the spring.",
]

## Gig reviews in the paper, by how the critic rated it. {band}, {venue}, {city}, {quote}.
const GIG_REVIEWS := {
	"great": [
		"{band} tore the roof off {venue} in {city}. Our critic: '{quote}'",
		"REVIEW: {band} at {venue}. '{quote}' Get a ticket next time, if you can.",
		"{city} is still ringing after {band} played {venue}. '{quote}'",
		"Five-star scenes at {venue}: {band} delivered. '{quote}'",
	],
	"good": [
		"{band} put on a solid show at {venue}, {city}. '{quote}'",
		"REVIEW: {band} at {venue}. '{quote}' Worth a look.",
		"{band} warmed up a {city} crowd at {venue}. Our critic says: '{quote}'",
	],
	"bad": [
		"REVIEW: {band} at {venue}. '{quote}' Ouch.",
		"{band} struggled at {venue} in {city}. Our critic was blunt: '{quote}'",
		"Not their night: {band} misfired at {venue}. '{quote}'",
	],
}
## Chart stories. {band}, {title}, {pos}.
const CHART_NEW := [
	"{band} crash into the national chart at number {pos} with '{title}'.",
	"New entry! '{title}' by {band} lands at number {pos}.",
	"'{title}' is everywhere: {band} enter the chart at {pos}.",
]
const CHART_UP := [
	"'{title}' climbs to number {pos}. {band} are on the rise.",
	"{band} keep climbing: '{title}' is up to number {pos}.",
	"Radio can't get enough of '{title}'. {band} now sit at number {pos}.",
]
const CHART_DOWN := [
	"'{title}' slips to number {pos}, but {band} are still in the chart.",
	"{band}'s '{title}' is drifting down the chart, now at number {pos}.",
]

const CRITIC_QUOTES := [
	["An avoidable disaster. I've had more fun at the dentist.", "Out of tune, out of time, out of ideas.", "I left early. So did the drummer."],
	["Rough around the edges, and in the middle.", "There's a band in there somewhere. Somewhere.", "Loud. That's the nicest thing I can say."],
	["Solid enough. The singer has something.", "A decent night out, if nothing more.", "Promising, if they can stop tuning between every song."],
	["Tight, punchy and properly entertaining.", "The best thing I've seen at this venue all year.", "A band starting to believe its own hype, and rightly so."],
	["Transcendent. I wept into my notepad.", "Instant legends. Tell your grandchildren you were there.", "Five stars and I'd give six if the editor let me."],
]
## For great gigs in front of a handful of people. {n} = attendance.
const SMALL_CROWD_QUOTES := [
	"All {n} of them went absolutely wild.",
	"The front row (and only row) went mental.",
	"Small but mighty: everyone danced, including the caretaker.",
	"'Best night of my life,' says one of the {n}. The other {n2} agree.",
]
const CROWD_QUOTES := [
	["'Can I have my money back?'", "'The raffle was better.'", "Someone threw a sausage roll."],
	["'They were... loud?'", "Polite clapping. Some of it ironic.", "'My nan liked it.'"],
	["'Not bad at all, actually!'", "Heads nodding all round.", "'Get them back next month.'"],
	["The place was bouncing!", "Chants of 'ONE MORE SONG!'", "'Best gig I've been to this year!'"],
	["Absolute scenes. People crowd-surfing off the bar.", "The roof came off. Nearly literally.", "'I'm getting their name tattooed.'"],
]

## Random weekly events. Each has choices with effects (see Events._resolve_random).
## "bad" ones (mishaps) are rarer and never come within 3 weeks of each other.
const RANDOM_EVENTS := [
	{"id": "van", "bad": true, "title": "The Van Has Died", "icon": "bus", "min_fame": 0,
		"text": "Your battered transit van has made a noise like a dying walrus and stopped on the bypass.",
		"choices": [
			{"label": "Get it fixed", "cost_scale": 120, "happy": 2, "result": "The mechanic sucked his teeth, but it's running again."},
			{"label": "Make the band push it", "happy": -6, "result": "The band pushed it two miles in the rain. Morale is damp."}]},
	{"id": "birthday", "title": "Birthday In The Band", "icon": "gift", "min_fame": 0, "member": true,
		"text": "It's {member}'s birthday this week and they've mentioned it. Several times.",
		"choices": [
			{"label": "Buy a cake and candles", "cost_scale": 25, "happy_member": 10, "result": "{member} blew out the candles and got a bit emotional."},
			{"label": "Forget, conveniently", "happy_member": -8, "result": "{member} noticed. {member} definitely noticed."}]},
	{"id": "flood", "bad": true, "title": "Rehearsal Room Flooded", "icon": "alert", "min_fame": 0,
		"text": "A burst pipe has turned your rehearsal space into a paddling pool.",
		"choices": [
			{"label": "Pay for a pump and dry out", "cost_scale": 80, "result": "Mopped, dried and smelling only slightly of pond."},
			{"label": "Rehearse in the puddle", "happy": -4, "skill_loss": true, "result": "Electricity and water. Nobody died, but nobody played well either."}]},
	{"id": "amp", "bad": true, "title": "Amp Goes Bang", "icon": "amp", "min_fame": 0, "member": true,
		"text": "{member}'s amp just went bang mid-rehearsal. There was smoke. A lot of smoke.",
		"choices": [
			{"label": "Pay for a repair", "cost_scale": 60, "result": "Fixed. It sounds better than ever, apparently."},
			{"label": "Tell them to make do", "happy_member": -7, "result": "{member} is now playing through a clock radio."}]},
	{"id": "demo", "title": "Local DJ Wants Your Demo", "icon": "radio", "min_fame": 0,
		"text": "A late-night DJ on Radio {city} wants a demo for her 'Unsigned & Unhinged' slot.",
		"choices": [
			{"label": "Send the best rehearsal tape", "listeners_flat": 40, "listeners_pct": 0.05, "result": "She played it twice and called it 'raw, in a good way'."},
			{"label": "Ignore it, you're above that", "result": "Nothing happens. Probably for the best. Probably."}]},
	{"id": "support", "title": "Last-Minute Support Slot", "icon": "ticket", "min_fame": 5,
		"text": "{rival} need a support act tonight. No money, but a big crowd.",
		"choices": [
			{"label": "Grab the van, let's go", "listeners_flat": 60, "listeners_pct": 0.08, "happy": 3, "result": "You won over a fair few of their fans. They didn't love that."},
			{"label": "Politely decline", "result": "You stay home and watch telly instead."}]},
	{"id": "viral", "title": "Clip Goes Viral", "icon": "trendUp", "min_fame": 8, "member": true,
		"text": "A clip of {member} falling off the stage mid-solo (and still finishing it) is everywhere.",
		"choices": [
			{"label": "Lean into it, post more", "listeners_pct": 0.15, "happy_member": -3, "member_fame": 4, "result": "Millions of views. {member} is now 'that one who fell over'."},
			{"label": "Ask for it to be taken down", "happy_member": 4, "result": "{member} is relieved. The internet forgets, eventually."}]},
	{"id": "advert", "title": "Advert Wants Your Song", "icon": "film", "min_fame": 20, "needs_release": true,
		"text": "A building society wants to use your latest song in a TV advert about mortgages.",
		"choices": [
			{"label": "Sell out (gladly)", "cash_scale": 900, "fans_pct": -0.03, "listeners_pct": 0.12, "result": "Ker-ching. Some true fans call you sell-outs, but your nan loves it."},
			{"label": "Keep your integrity", "fans_pct": 0.02, "result": "Real fans respect it. Your bank manager doesn't."}]},
	{"id": "noise", "bad": true, "title": "Noise Complaint", "icon": "alert", "min_fame": 0,
		"text": "The neighbours have complained about the noise. There's a strongly-worded letter, in green ink.",
		"choices": [
			{"label": "Buy them flowers and earplugs", "cost_scale": 30, "result": "They're placated. One of them is now a fan."},
			{"label": "Turn it up to eleven", "happy": 3, "fans_flat": -1, "result": "The band loved it. Mrs Higginbottom at number 12 did not."}]},
	{"id": "stolen", "bad": true, "title": "Gear Stolen From The Van", "icon": "lock", "min_fame": 10, "member": true,
		"text": "Someone broke into the van overnight and nicked {member}'s gear.",
		"choices": [
			{"label": "Replace it like-for-like", "cost_scale": 150, "result": "Replaced. {member} has written a song about it."},
			{"label": "Downgrade to something cheaper", "downgrade": true, "happy_member": -6, "result": "{member} now plays something from a pawn shop window."}]},
	{"id": "festival", "title": "Charity Festival Invite", "icon": "heart", "min_fame": 15,
		"text": "A charity festival wants you on the bill. Unpaid, but it's for a good cause.",
		"choices": [
			{"label": "Play for free", "fans_pct": 0.03, "listeners_pct": 0.06, "happy": 2, "result": "Feel-good vibes all round. Good karma, good press."},
			{"label": "Ask for a fee", "cash_scale": 200, "fans_pct": -0.02, "result": "They paid up, but word got around."}]},
	{"id": "localtv", "title": "Local TV Wants A Video", "icon": "film", "min_fame": 4,
		"text": "{city} Tonight, the local TV news, want a 30-second clip of the band for their 'Ones To Watch' slot. They need it by Friday.",
		"choices": [
			{"label": "Film something proper", "cost_scale": 40, "listeners_flat": 50, "local": true, "listeners_pct": 0.04, "result": "It went out after the weather. Your mum has recorded it four times."},
			{"label": "Film it on a phone in the shed", "listeners_flat": 20, "local": true, "happy": 2, "result": "Wobbly, a bit dark, oddly charming. The presenter called it 'very authentic'."}]},
	{"id": "battle", "title": "Battle Of The Bands", "icon": "trophy", "min_fame": 2, "max_fame": 40,
		"text": "The {city} Battle of the Bands is this Saturday. {rival} have already entered and are telling everyone they'll win.",
		"choices": [
			{"label": "Enter and win", "battle": true, "result": ""},
			{"label": "Battles are for armies", "result": "You stayed home. {rival} won, and they're being unbearable about it."}]},
	{"id": "photo", "title": "Photographer Wants A Shoot", "icon": "eye", "min_fame": 10,
		"text": "A student photographer wants to shoot the band for her portfolio, moody and black-and-white, at the gasworks.",
		"choices": [
			{"label": "Smoulder for the camera", "listeners_pct": 0.03, "happy": 2, "result": "The photos are brilliant. Everyone looks about 30% cooler than in real life."},
			{"label": "Too busy", "result": "She shot {rival} instead. Their photos are everywhere now."}]},
	# Favour gigs: free to play, paid in tips. Mostly a lifeline for skint new bands.
	{"id": "wedding", "title": "A Mate's Wedding", "icon": "heart", "min_fame": 0, "max_fame": 35, "favour": true,
		"text": "Your mate Gaz is getting married on Saturday and the wedding band has pulled out. He's begging. There's a tip jar.",
		"choices": [
			{"label": "Play the reception", "tips": 160, "listeners_flat": 12, "happy": 2, "result": "Three hours of covers, one of yours, and a conga line. The tip jar was stuffed."},
			{"label": "Wish him luck", "result": "Gaz booked a DJ called 'DJ Dave'. Nobody will remember it."}]},
	{"id": "cricket", "title": "Cricket Club Summer Do", "icon": "sparkle", "min_fame": 0, "max_fame": 30, "favour": true,
		"text": "The {city} Cricket Club want live music for their summer barbecue. No fee, but they'll pass the hat round.",
		"choices": [
			{"label": "Play between the overs", "tips": 120, "listeners_flat": 10, "result": "Polite applause, then less polite dancing. The hat came back heavy."},
			{"label": "Not really our crowd", "result": "They got a man with an accordion instead."}]},
	{"id": "carwash", "title": "Charity Car Wash", "icon": "heart", "min_fame": 0, "max_fame": 25, "favour": true,
		"text": "The local hospice is running a charity car wash on Sunday and asked if the band would play (and hold a sponge).",
		"choices": [
			{"label": "Sponges and songs", "tips": 90, "listeners_flat": 14, "happy": 3, "result": "Soaked, but happy. The organisers gave you a share of the tips and a lot of new friends."},
			{"label": "Give it a miss", "result": "They raised a bit less without you, but they managed."}]},
	{"id": "food", "bad": true, "title": "Dodgy Kebab", "icon": "frown", "min_fame": 0,
		"text": "The whole band had kebabs from 'Dave's Late Night Meats'. Results are... unfolding.",
		"choices": [
			{"label": "Give everyone a week off", "happy": 4, "skill_loss": true, "result": "Rest, fluids and a solemn vow never to return to Dave's."},
			{"label": "Rehearse through it", "happy": -6, "result": "Brave. Messy. Never speak of it again."}]},
]

## Things famous band members get up to. "good" ones happen more to happy
## members. Same choice keys as RANDOM_EVENTS, plus others_happy (everyone but
## {member}), member_fame, and local (listeners_flat goes to your home area).
const FAME_EVENTS := [
	{"id": "ego", "title": "A Bigger Dressing Room", "icon": "crown", "min_fame": 55, "good": false,
		"text": "{member} has started referring to themselves in the third person and wants their own dressing room, stocked with one specific brand of Icelandic sparkling water.",
		"choices": [
			{"label": "Give them what they want", "cost_scale": 150, "happy_member": 8, "others_happy": -4, "result": "{member} is delighted. The others are rolling their eyes so hard you can hear it."},
			{"label": "Remind them it's a band", "happy_member": -10, "member_fame": -2, "result": "{member} sulked through two rehearsals, then quietly got over it."}]},
	{"id": "tabloid", "title": "Tabloid Trouble", "icon": "news", "min_fame": 55, "good": false,
		"text": "{member} was photographed leaving a nightclub at 4am wearing a traffic cone as a hat. It's on every front page.",
		"choices": [
			{"label": "Issue a grovelling apology", "listeners_pct": -0.01, "happy_member": -3, "result": "The apology was sincere, if a bit long. It blew over in a week."},
			{"label": "Lean into it. It's rock'n'roll", "listeners_pct": 0.03, "fans_pct": -0.03, "member_fame": 3, "result": "Traffic cones are now a fashion item. Some long-time fans think you've lost the plot."}]},
	{"id": "solo", "title": "Solo Album Rumours", "icon": "disc", "min_fame": 60, "good": false,
		"text": "A magazine claims {member} is secretly recording a solo album. The rest of the band read it on the tour bus.",
		"choices": [
			{"label": "Let them do a side project", "happy_member": 10, "others_happy": -6, "member_fame": 4, "result": "{member} is thrilled. The others have gone very quiet."},
			{"label": "Shut it down", "happy_member": -12, "others_happy": 3, "result": "The band's united again. {member} is not happy about it."}]},
	{"id": "noshow", "title": "Missing In Action", "icon": "alert", "min_fame": 55, "good": false,
		"text": "{member} didn't turn up to the band's big photoshoot. They were 'finding themselves' at a yoga retreat in Wales.",
		"choices": [
			{"label": "Pay to reschedule", "cost_scale": 100, "happy_member": -2, "result": "Reshot a week later. {member} looks very relaxed in every photo."},
			{"label": "Shoot without them", "others_happy": -4, "listeners_pct": -0.01, "result": "The photos look odd with a gap in them. Fans have noticed."}]},
	{"id": "feud", "title": "Public Feud", "icon": "flame", "min_fame": 65, "good": false,
		"text": "{member} has started a very public argument online with someone from {rival}. It's about sandwiches, but also about everything.",
		"choices": [
			{"label": "Tell them to log off", "happy_member": -6, "result": "{member} logged off, muttering. Peace returns."},
			{"label": "Let it run", "listeners_pct": 0.04, "fans_pct": -0.02, "others_happy": -3, "result": "Everyone's talking about it. Not all of it is nice."}]},
	{"id": "rider", "title": "Rider Demands", "icon": "gift", "min_fame": 70, "good": false,
		"text": "{member} has added 'a bowl of only blue sweets and one (1) live swan' to the band's backstage rider.",
		"choices": [
			{"label": "Get the swan", "cost_scale": 300, "happy_member": 6, "others_happy": -2, "result": "The swan bit the drummer. {member} says it was worth it."},
			{"label": "No swan", "happy_member": -8, "result": "{member} has written a song called 'No Swan'. It's quite good, actually."}]},
	{"id": "school", "title": "A New School", "icon": "heart", "min_fame": 55, "good": true,
		"text": "{member} has used their fame to help open a new music school in {city}. The local press can't get enough of it.",
		"choices": [
			{"label": "Get the whole band down there", "listeners_flat": 40, "local": true, "fans_pct": 0.02, "happy": 3, "result": "The kids played you a song. It was terrible. Everyone cried."},
			{"label": "Let {member} have their moment", "happy_member": 6, "member_fame": 2, "listeners_pct": 0.02, "result": "{member} cut the ribbon to a standing ovation."}]},
	{"id": "cause", "title": "Speaking Up", "icon": "megaphone", "min_fame": 65, "good": true,
		"text": "On live TV, {member} spoke up for the people of {country}, who hardly ever make the news. The clip has been shared millions of times.",
		"choices": [
			{"label": "Back them all the way", "listeners_pct": 0.05, "fans_pct": 0.02, "happy_member": 5, "others_happy": 2, "result": "Donations are pouring in, and people are looking up {country} on a map."},
			{"label": "Keep the band out of politics", "happy_member": -6, "listeners_pct": 0.01, "result": "{member} feels let down, but the clip still did some good."}]},
	{"id": "charity", "title": "Charity Single", "icon": "note", "min_fame": 60, "good": true,
		"text": "{member} has been asked to front a charity single for the {city} children's hospital.",
		"choices": [
			{"label": "The whole band will play on it", "listeners_pct": 0.04, "fans_pct": 0.02, "happy": 2, "result": "It went top 20 and raised a fortune. Proper feel-good stuff."},
			{"label": "{member} can do it solo", "happy_member": 4, "member_fame": 3, "listeners_pct": 0.02, "result": "{member}'s version is lovely. The band are a bit jealous."}]},
	{"id": "ward", "title": "A Quiet Visit", "icon": "smile", "min_fame": 55, "good": true,
		"text": "{member} quietly visited a children's ward in {city} with a guitar. A nurse's photo of it has gone viral.",
		"choices": [
			{"label": "Make it a regular thing", "happy": 2, "fans_pct": 0.02, "listeners_flat": 20, "local": true, "result": "The band now visit every month. The ward has a signed drum kit."},
			{"label": "Keep it low-key", "happy_member": 3, "fans_pct": 0.01, "result": "{member} didn't want a fuss. People respect that."}]},
]
const CAUSE_COUNTRIES := ["Tuvalu", "Malawi", "Moldova", "Kiribati", "Burkina Faso", "Laos", "Vanuatu", "Eswatini", "Bhutan", "Suriname"]

const DOC_TITLES := ["Loud & Unwashed: The Story of {band}", "{band}: Behind The Fuzz", "Some Kind of Badger: {band}",
	"Don't Look Back In {city}: {band}", "{band}: The Van Years"]
const FILM_TITLES := ["{band}: Live At {venue}", "Stop Making Sense-ish: {band}", "{band}: Ear-Splitting Live",
	"The Last Waltz-ish: {band}", "{band}: One Night Only"]
