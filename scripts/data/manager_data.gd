class_name ManagerData
extends RefCounted
## The full roster of managers. The game offers 4 at random each new game.
## Add, remove or edit entries freely: nothing else depends on the count
## or the gender split.
##
## perk ids are handled in Game (see Game.has_perk()).

const LIST := [
	{
		"id": "mags", "name": "Margaret \"Mags\" Thornbury", "short": "Mags", "gender": "f", "age": 67,
		"genre": "rock", "funds": 5000,
		"album": "Rumours Has It", "album_artist": "Fleetwood Mack",
		"bio": "Humped amps for half the stadium bands of the seventies. Once lent a plectrum to someone extremely famous and still won't say who. Can roll a cable in under four seconds.",
		"tastes": "Proper rock'n'roll, loud amps, and a band who say thank you to the sound engineer.",
		"perk": "roadie", "perk_name": "Roadie Wisdom", "perk_desc": "Band members are happier: their contentment settles 6 points higher.",
		"look": {"skin": 1, "hair": "bob", "hair_color": "#e8e4dc", "facial": "none", "glasses": "cateye", "acc": "earring",
			"cloth": "leather", "cloth_color": "#2b2b30", "expr": "smirk", "age": 3, "lips": "#b23a48", "bg": "#e63946"}
	},
	{
		"id": "dazza", "name": "Darren \"Dazza\" Pike", "short": "Dazza", "gender": "m", "age": 23,
		"genre": "poppunk", "funds": 800,
		"album": "Dookie Monster", "album_artist": "Green Hay",
		"bio": "Ran the biggest fan page on a social network nobody remembers. Managed his cousin's ska band for three weeks before they split over a trombone. Wears shorts all year round.",
		"tastes": "Anything you can do a kick-flip to. Choruses that go 'whoa-oh'.",
		"perk": "hustler", "perk_name": "Hustler", "perk_desc": "Busking and promotion earn 40% more.",
		"look": {"skin": 2, "hair": "spiky", "hair_color": "#2a2a2a", "facial": "none", "glasses": "none", "acc": "cap",
			"cloth": "hoodie", "cloth_color": "#ff9f1c", "expr": "grin", "age": 0, "bg": "#ff9f1c"}
	},
	{
		"id": "kev", "name": "Kevin \"Kev\" Doyle", "short": "Kev", "gender": "m", "age": 45,
		"genre": "britpop", "funds": 2300,
		"album": "(What's the Story) Mourning Glory?", "album_artist": "Oasthouse",
		"bio": "Was very nearly in a Britpop band in '95. Quit the day before they got signed. Has told this story at every party since. Owns eleven parkas.",
		"tastes": "Swagger, tambourines, and lyrics that rhyme 'fire' with 'higher'.",
		"perk": "contacts", "perk_name": "Nearly Famous", "perk_desc": "Still knows everyone. Interview offers come 50% more often.",
		"look": {"skin": 0, "hair": "fringe", "hair_color": "#5a3b24", "facial": "stubble", "glasses": "none", "acc": "none",
			"cloth": "parka", "cloth_color": "#56633a", "expr": "smirk", "age": 1, "bg": "#3a86ff"}
	},
	{
		"id": "priya", "name": "Priya Shah", "short": "Priya", "gender": "f", "age": 29,
		"genre": "indie", "funds": 1600,
		"album": "Is This It? Probably", "album_artist": "The Strolls",
		"bio": "Ran a tiny vinyl shop that sold more coffee than records. Can identify any B-side within two bars. Has strong opinions about reverb.",
		"tastes": "Jangle, wit and a bassline you can hum on the bus.",
		"perk": "crate", "perk_name": "Crate Digger", "perk_desc": "An ear for a tune: singles and albums score 8% higher.",
		"look": {"skin": 3, "hair": "long", "hair_color": "#1d1716", "facial": "none", "glasses": "round", "acc": "none",
			"cloth": "cardigan", "cloth_color": "#c8553d", "expr": "smile", "age": 0, "lips": "#9e3b4a", "bg": "#4cc9f0"}
	},
	{
		"id": "rupert", "name": "Lord Rupert Fanshawe-Biggs", "short": "Rupert", "gender": "m", "age": 58,
		"genre": "metal", "funds": 4800,
		"album": "Master of Muppets", "album_artist": "Metallicar",
		"bio": "Inherited a castle, a title and a deeply troubling love of thrash metal. Hosts headbanging garden parties. The butler wears earplugs.",
		"tastes": "Anything played at a volume that rattles the family silver.",
		"perk": "posh", "perk_name": "Posh Contacts", "perk_desc": "Old school ties: gig venues cost 15% less to hire.",
		"look": {"skin": 0, "hair": "balding", "hair_color": "#8a8a8a", "facial": "moustache", "glasses": "none", "acc": "none",
			"cloth": "suit", "cloth_color": "#3d2c4e", "expr": "grin", "age": 2, "bg": "#b8b8c0"}
	},
	{
		"id": "gary", "name": "\"Grunge\" Gary Mulligan", "short": "Gary", "gender": "m", "age": 51,
		"genre": "grunge", "funds": 1200,
		"album": "Nevermind the Bills", "album_artist": "Nervana",
		"bio": "Hasn't washed his lucky flannel shirt since 1993. Saw a seminal grunge band in a tiny club and has been chasing that feeling ever since. Smells faintly of damp.",
		"tastes": "Loud, quiet, loud. Sincere angst. Detuned guitars.",
		"perk": "faithful", "perk_name": "Flannel Faithful", "perk_desc": "Fans trust you: people get bored of the band 40% more slowly.",
		"look": {"skin": 1, "hair": "long", "hair_color": "#6b4f2a", "facial": "beard", "glasses": "none", "acc": "beanie",
			"cloth": "flannel", "cloth_color": "#8b2e2e", "expr": "flat", "age": 1, "bg": "#9aa63a"}
	},
	{
		"id": "zed", "name": "Zoe \"Zed\" Kowalski", "short": "Zed", "gender": "f", "age": 19,
		"genre": "edm", "funds": 500,
		"album": "Discovery Channel", "album_artist": "Daft Funk",
		"bio": "Built a following of 40,000 by DJing in her bedroom wearing a traffic cone. Has never been to a gig that didn't have lasers. Speaks fluent algorithm.",
		"tastes": "Drops, builds, lasers and more drops.",
		"perk": "viral", "perk_name": "Gone Viral", "perk_desc": "Knows the algorithm: streaming listeners grow 50% faster.",
		"look": {"skin": 0, "hair": "pixie", "hair_color": "#00c2a8", "facial": "none", "glasses": "none", "acc": "headphones",
			"cloth": "tee", "cloth_color": "#1b1b2f", "expr": "grin", "age": 0, "lips": "#7a2e8e", "bg": "#00f5d4"}
	},
	{
		"id": "barry", "name": "Barry Wheeler", "short": "Barry", "gender": "m", "age": 72,
		"genre": "bluesrock", "funds": 3700,
		"album": "Exile on Mean Street", "album_artist": "The Rolling Scones",
		"bio": "Managed pub bands since before decimalisation. Has a handshake that closes deals and a cardigan that has seen things. Claims he invented the guest list.",
		"tastes": "Twelve bars, a slide guitar and a pint of mild.",
		"perk": "silver", "perk_name": "Silver Tongue", "perk_desc": "A born negotiator: musicians accept cheaper offers far more readily.",
		"look": {"skin": 1, "hair": "balding", "hair_color": "#f0f0f0", "facial": "bigbeard", "glasses": "square", "acc": "none",
			"cloth": "cardigan", "cloth_color": "#7a5c3a", "expr": "smile", "age": 3, "bg": "#2a9d8f"}
	},
	{
		"id": "toby", "name": "Toby Fitch", "short": "Toby", "gender": "m", "age": 34,
		"genre": "punk", "funds": 900,
		"album": "Never Mind the Bollards", "album_artist": "The Sex Pistachios",
		"bio": "Photocopied fanzines in his mum's office for a decade. Believes in DIY, cheap rent and gaffer tape as a structural material. Owns one pair of boots, held together by ideology.",
		"tastes": "Fast, loud and under two minutes. Ideally ninety seconds.",
		"perk": "diy", "perk_name": "DIY Ethic", "perk_desc": "Thrifty: rehearsal rent is 30% cheaper and gear is 10% cheaper.",
		"look": {"skin": 0, "hair": "mohawk", "hair_color": "#e01e5a", "facial": "stubble", "glasses": "none", "acc": "earring",
			"cloth": "leather", "cloth_color": "#1d1d22", "expr": "smirk", "age": 1, "bg": "#ff2e88"}
	},
	{
		"id": "bernie", "name": "Bernadette \"Bernie\" O'Hara", "short": "Bernie", "gender": "f", "age": 48,
		"genre": "rock", "funds": 2900,
		"album": "Back in Black Pudding", "album_artist": "AC/BC",
		"bio": "Ran a guitar repair shop for twenty years. Can tell a fake vintage pickup by smell. Once refretted a neck during a power cut, by candlelight, for a fiver.",
		"tastes": "Riff-first rock and anything with a good valve amp.",
		"perk": "gearhead", "perk_name": "Gear Head", "perk_desc": "Knows the trade: instruments cost 25% less.",
		"look": {"skin": 2, "hair": "curly", "hair_color": "#a33b1f", "facial": "none", "glasses": "none", "acc": "bandana",
			"cloth": "denim", "cloth_color": "#3f5f8a", "expr": "grin", "age": 1, "lips": "#a8323e", "bg": "#e63946"}
	},
	{
		"id": "nigel", "name": "Dr. Nigel Pemberton", "short": "Nigel", "gender": "m", "age": 61,
		"genre": "shoegaze", "funds": 3300,
		"album": "Loveless Than Zero", "album_artist": "My Bloody Valentines Day",
		"bio": "Retired dentist. Spent his career listening to drills and decided he loved the noise. Owns 64 reverb pedals and labels each one in Latin.",
		"tastes": "Hazy, dreamy, ridiculously loud. Lyrics optional.",
		"perk": "perfectionist", "perk_name": "Perfectionist", "perk_desc": "Runs a tight ship: rehearsals improve skills 20% faster.",
		"look": {"skin": 0, "hair": "short", "hair_color": "#9c9c9c", "facial": "none", "glasses": "round", "acc": "none",
			"cloth": "suit", "cloth_color": "#5b6c7d", "expr": "flat", "age": 2, "bg": "#f4a6c1"}
	},
	{
		"id": "jam", "name": "Jamal \"Jam\" Okafor", "short": "Jam", "gender": "m", "age": 26,
		"genre": "altrock", "funds": 1900,
		"album": "Siamese Dreamboats", "album_artist": "The Smashing Pumpernickels",
		"bio": "Former festival steward who watched four hundred bands from the side of the stage and took notes on all of them. Spots talent the way other people spot typos.",
		"tastes": "Fuzz, feeling and a drummer who actually listens.",
		"perk": "scout", "perk_name": "Talent Spotter", "perk_desc": "Sees each musician's exact potential, and more of them turn up.",
		"look": {"skin": 4, "hair": "afro", "hair_color": "#1a1412", "facial": "goatee", "glasses": "none", "acc": "none",
			"cloth": "tee", "cloth_color": "#9d4edd", "expr": "smile", "age": 0, "bg": "#9d4edd"}
	},
]
