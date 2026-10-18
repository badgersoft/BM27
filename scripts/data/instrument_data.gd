class_name InstrumentData
extends RefCounted
## Instruments by role, tier 0 (car boot special) to tier 7 (legendary).
## bonus = points added to the player's effective skill on stage.

const ROLES := ["vocals", "guitar", "bass", "drums"]
const ROLE_NAMES := {"vocals": "Singer", "guitar": "Guitarist", "bass": "Bassist", "drums": "Drummer"}
const ROLE_ICONS := {"vocals": "mic", "guitar": "guitar", "bass": "bass", "drums": "drums"}
const ROLE_WEIGHT := {"vocals": 1.25, "guitar": 1.10, "bass": 0.85, "drums": 1.0}

const BONUS := [0, 2, 4, 6, 8, 10, 12, 15]

const TIERS := {
	"drums": [
		{"name": "Biscuit-Tin Kit", "cost": 0, "desc": "A car-boot special. The snare is a biscuit tin."},
		{"name": "Purl Rookie 5-Piece", "cost": 150, "desc": "Cheap, cheerful and mostly in tune."},
		{"name": "Yamahahaha Stage Custom", "cost": 450, "desc": "The workhorse of a thousand pub gigs."},
		{"name": "Tama-gotchi Superstar", "cost": 1200, "desc": "Needs feeding and a lot of attention."},
		{"name": "Ludwiggle Classic Maple", "cost": 3500, "desc": "Warm, punchy, and very wiggly."},
		{"name": "DW-ish Collector's Series", "cost": 9000, "desc": "Hand-made, sparkly and terrifyingly loud."},
		{"name": "Gretschin' Broadkaster '62", "cost": 25000, "desc": "Vintage shells that smell of history."},
		{"name": "The Grohlnut Signature Kit", "cost": 80000, "desc": "Comes pre-hit very, very hard."},
	],
	"guitar": [
		{"name": "Catalogue Strat-ish", "cost": 0, "desc": "Came free with a catalogue order of curtains."},
		{"name": "Squiggle Bullet", "cost": 120, "desc": "Every legend's first guitar. Probably."},
		{"name": "Epiphony Les Pal", "cost": 400, "desc": "Heavy, shiny and friendly."},
		{"name": "Fender Bender Player Strat", "cost": 1000, "desc": "A proper guitar. Dents not included."},
		{"name": "Gibbon SG Standard", "cost": 3000, "desc": "Devil horns and a growl to match."},
		{"name": "Rickenbacon 330", "cost": 8000, "desc": "Jangles like a pocket full of sunshine."},
		{"name": "Gibbon Les Pal '59 Reissue", "cost": 22000, "desc": "The holy grail. Weighs as much as a fridge."},
		{"name": "The Fireplace Special", "cost": 75000, "desc": "Hand-built from an old fireplace. A legend."},
	],
	"bass": [
		{"name": "Pawn Shop P-Bass Copy", "cost": 0, "desc": "Four strings. Three of them work."},
		{"name": "Ibanezzz GIO", "cost": 130, "desc": "Sleepy name, lively low end."},
		{"name": "Squiggle Jazz Bass", "cost": 380, "desc": "Smooth, thumpy and reliable."},
		{"name": "Fender Bender Precision", "cost": 1100, "desc": "The bass on half the records you love."},
		{"name": "Musicmanly StingRay", "cost": 3200, "desc": "Punchy enough to rattle your teeth."},
		{"name": "Rickenbacon 4003", "cost": 8500, "desc": "Growls like an angry badger."},
		{"name": "Hofnerd Violin Bass", "cost": 20000, "desc": "Light as a feather, iconic as a mop-top."},
		{"name": "The Flea Market Signature", "cost": 70000, "desc": "Slaps. Literally."},
	],
	"vocals": [
		{"name": "Karaoke Machine Mic", "cost": 0, "desc": "Has a built-in echo button. Uses it constantly."},
		{"name": "Sure-ish SM57½", "cost": 100, "desc": "Nearly a professional microphone."},
		{"name": "Sure-ish SM58 (Genuine!)", "cost": 250, "desc": "Indestructible. Can hammer nails."},
		{"name": "Sennheisenberg e935", "cost": 700, "desc": "Crisp highs, and uncertain about everything."},
		{"name": "Neumanny KMS Stage Mic", "cost": 2000, "desc": "Velvet-smooth and very expensive."},
		{"name": "Telefunky M80 + In-Ears", "cost": 6000, "desc": "Finally they can hear themselves."},
		{"name": "Custom In-Ears & Vocal Coach", "cost": 18000, "desc": "Breathing exercises at 7am. Worth it."},
		{"name": "The Golden Mic & Vocal Rider", "cost": 65000, "desc": "Honey, lemon and a gold-plated microphone."},
	],
}

## Gifts and treats for keeping a musician sweet. boost = contentment gained.
## Treats for the whole band: cost is per member, scaled up with fame (a
## famous band's night out costs more). fatigue: change to band fatigue.
const BAND_TREATS := [
	{"id": "town", "name": "Night on the Town", "icon": "flame", "cost": 60.0, "boost": 7.0, "fatigue": 1.0,
		"desc": "Curry, karaoke and a club that plays nothing but '90s anthems. Everyone's happier, if a bit fragile tomorrow.",
		"result": "The band painted {city} red. Somebody lost a shoe; nobody remembers whose. (+%d contentment each)"},
	{"id": "spa", "name": "Spa Weekend", "icon": "sparkle", "cost": 450.0, "boost": 14.0, "fatigue": -4.0,
		"desc": "Fluffy robes, a hot tub and a man called Sven who does something to your shoulders. Morale up, tiredness gone.",
		"result": "Two days of fluffy robes and cucumber water. The band came back glowing and well rested. (+%d contentment each)"},
]

const GIFTS := [
	{"id": "pint", "name": "A Pint & a Packet of Crisps", "cost": 10, "boost": 5, "icon": "gift"},
	{"id": "hoodie", "name": "Limited Edition Band Hoodie", "cost": 45, "boost": 8, "icon": "shirt"},
	{"id": "vinyl", "name": "Rare Signed Vinyl", "cost": 150, "boost": 12, "icon": "vinyl"},
	{"id": "blackpool", "name": "Dirty Weekend in Blackpool", "cost": 450, "boost": 17, "icon": "bus"},
	{"id": "pedal", "name": "Boutique Effects Pedal", "cost": 1200, "boost": 21, "icon": "amp"},
	{"id": "spa", "name": "Luxury Spa Retreat", "cost": 3500, "boost": 26, "icon": "sparkle"},
	{"id": "car", "name": "A Vintage Sports Car", "cost": 25000, "boost": 34, "icon": "flame"},
	{"id": "island", "name": "A Small Scottish Island", "cost": 250000, "boost": 45, "icon": "crown"},
]
