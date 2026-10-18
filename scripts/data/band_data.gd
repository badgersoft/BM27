class_name BandData
extends RefCounted
## Rival bands. Megastars and national acts are spoofs of real bands;
## the local scene is all home-grown Badgerton talent (and lack of it).
## fame: 0-100. local = plays the same small-town circuit you do.

const RIVALS := [
	{
		"name": "Queue",
		"genre": "rock",
		"fame": 97,
	},
	{
		"name": "The Rolling Scones",
		"genre": "rock",
		"fame": 96,
	},
	{
		"name": "Lead Zeplinnn",
		"genre": "rock",
		"fame": 95,
	},
	{
		"name": "Food Fighters",
		"genre": "rock",
		"fame": 93,
	},
	{
		"name": "Metallicar",
		"genre": "metal",
		"fame": 94,
	},
	{
		"name": "Nervana",
		"genre": "grunge",
		"fame": 92,
	},
	{
		"name": "Radiohedge",
		"genre": "altrock",
		"fame": 91,
	},
	{
		"name": "Oasthouse",
		"genre": "britpop",
		"fame": 90,
	},
	{
		"name": "Red Hot Chilli Poppers",
		"genre": "altrock",
		"fame": 90,
	},
	{
		"name": "Green Hay",
		"genre": "punk",
		"fame": 89,
	},
	{
		"name": "Arctic Donkeys",
		"genre": "indie",
		"fame": 88,
	},
	{
		"name": "Ironing Maiden",
		"genre": "metal",
		"fame": 87,
	},
	{
		"name": "AC/BC",
		"genre": "rock",
		"fame": 88,
	},
	{
		"name": "Pearl Ham",
		"genre": "grunge",
		"fame": 86,
	},
	{
		"name": "Mews",
		"genre": "altrock",
		"fame": 85,
	},
	{
		"name": "Blurb",
		"genre": "britpop",
		"fame": 80,
	},
	{
		"name": "The Chillers",
		"genre": "indie",
		"fame": 79,
	},
	{
		"name": "Sound Gardening",
		"genre": "grunge",
		"fame": 77,
	},
	{
		"name": "Queens of the Scone Age",
		"genre": "rock",
		"fame": 76,
	},
	{
		"name": "The Smashing Pumpernickels",
		"genre": "altrock",
		"fame": 75,
	},
	{
		"name": "Black Sabbatical",
		"genre": "metal",
		"fame": 78,
	},
	{
		"name": "Kings of Neon",
		"genre": "rock",
		"fame": 74,
	},
	{
		"name": "The Strolls",
		"genre": "indie",
		"fame": 72,
	},
	{
		"name": "Kebabian",
		"genre": "britpop",
		"fame": 70,
	},
	{
		"name": "Slipknut",
		"genre": "metal",
		"fame": 69,
	},
	{
		"name": "Alice in Chairs",
		"genre": "grunge",
		"fame": 68,
	},
	{
		"name": "Stone Temple Pirates",
		"genre": "grunge",
		"fame": 64,
	},
	{
		"name": "Pixels",
		"genre": "altrock",
		"fame": 66,
	},
	{
		"name": "The Cure-All",
		"genre": "altrock",
		"fame": 70,
	},
	{
		"name": "My Bloody Valentines Day",
		"genre": "altrock",
		"fame": 60,
	},
	{
		"name": "Slowdrive",
		"genre": "altrock",
		"fame": 55,
	},
	{
		"name": "Joy Subtraction",
		"genre": "indie",
		"fame": 62,
	},
	{
		"name": "The Smyths",
		"genre": "indie",
		"fame": 67,
	},
	{
		"name": "Franz Ferdinandino",
		"genre": "indie",
		"fame": 61,
	},
	{
		"name": "The Libertimes",
		"genre": "indie",
		"fame": 58,
	},
	{
		"name": "Biffy Gyro",
		"genre": "altrock",
		"fame": 63,
	},
	{
		"name": "Royal Flood",
		"genre": "rock",
		"fame": 59,
	},
	{
		"name": "The Black Pies",
		"genre": "rock",
		"fame": 65,
	},
	{
		"name": "Blink-183",
		"genre": "punk",
		"fame": 66,
	},
	{
		"name": "Sum 42",
		"genre": "punk",
		"fame": 54,
	},
	{
		"name": "Paramour",
		"genre": "punk",
		"fame": 60,
	},
	{
		"name": "The Sex Pistachios",
		"genre": "punk",
		"fame": 64,
	},
	{
		"name": "The Clashed Potatoes",
		"genre": "punk",
		"fame": 62,
	},
	{
		"name": "IDLERS",
		"genre": "punk",
		"fame": 52,
	},
	{
		"name": "Fountains D.C.",
		"genre": "punk",
		"fame": 50,
	},
	{
		"name": "Damp Leg",
		"genre": "indie",
		"fame": 48,
	},
	{
		"name": "Pulpit",
		"genre": "britpop",
		"fame": 56,
	},
	{
		"name": "Supergrassy",
		"genre": "britpop",
		"fame": 50,
	},
	{
		"name": "Mudhoney Trap",
		"genre": "grunge",
		"fame": 46,
	},
	{
		"name": "Def Leopardskin",
		"genre": "rock",
		"fame": 57,
	},
	{
		"name": "Motörbike",
		"genre": "metal",
		"fame": 55,
	},
	{
		"name": "Guns N' Rosés",
		"genre": "rock",
		"fame": 84,
	},
	{
		"name": "Bon Jovial",
		"genre": "rock",
		"fame": 79,
	},
	{
		"name": "Thin Lizzard",
		"genre": "rock",
		"fame": 66,
	},
	{
		"name": "The Darkened",
		"genre": "rock",
		"fame": 61,
	},
	{
		"name": "Aerosmiths",
		"genre": "rock",
		"fame": 72,
	},
	{
		"name": "Megadebt",
		"genre": "metal",
		"fame": 74,
	},
	{
		"name": "Judas Priestley",
		"genre": "metal",
		"fame": 71,
	},
	{
		"name": "System Of A Clown",
		"genre": "metal",
		"fame": 67,
	},
	{
		"name": "Bring Me The Hobnob",
		"genre": "metal",
		"fame": 63,
	},
	{
		"name": "Sludgegarden",
		"genre": "grunge",
		"fame": 57,
	},
	{
		"name": "Screaming Bees",
		"genre": "grunge",
		"fame": 52,
	},
	{
		"name": "Hole-In-One",
		"genre": "grunge",
		"fame": 60,
	},
	{
		"name": "The Undertoads",
		"genre": "punk",
		"fame": 56,
	},
	{
		"name": "Buzzcocktails",
		"genre": "punk",
		"fame": 58,
	},
	{
		"name": "Siouxsie & The Banshee Bin Men",
		"genre": "punk",
		"fame": 61,
	},
	{
		"name": "Fall Out Toy",
		"genre": "punk",
		"fame": 70,
	},
	{
		"name": "My Chemical Bromance",
		"genre": "punk",
		"fame": 73,
	},
	{
		"name": "Sweede",
		"genre": "britpop",
		"fame": 69,
	},
	{
		"name": "The Verve Pipe Cleaners",
		"genre": "britpop",
		"fame": 72,
	},
	{
		"name": "Elastic Band",
		"genre": "britpop",
		"fame": 55,
	},
	{
		"name": "Ocean Colour Scone",
		"genre": "britpop",
		"fame": 60,
	},
	{
		"name": "The Killjoys",
		"genre": "indie",
		"fame": 77,
	},
	{
		"name": "Bloc Partly",
		"genre": "indie",
		"fame": 64,
	},
	{
		"name": "Arcade Firewood",
		"genre": "indie",
		"fame": 70,
	},
	{
		"name": "The Stone Rosettes",
		"genre": "indie",
		"fame": 66,
	},
	{
		"name": "MGMTea",
		"genre": "indie",
		"fame": 59,
	},
	{
		"name": "Throwing Mugs",
		"genre": "altrock",
		"fame": 68,
	},
	{
		"name": "Fuzz Fighters",
		"genre": "altrock",
		"fame": 57,
	},
	{
		"name": "Placebo Effect",
		"genre": "altrock",
		"fame": 62,
	},
	{
		"name": "Muse-um",
		"genre": "altrock",
		"fame": 74,
	},
	{
		"name": "Fleetwood Snack",
		"genre": "rock",
		"fame": 82,
	},
	{
		"name": "The Who-Dunnits",
		"genre": "rock",
		"fame": 80,
	},
	{
		"name": "Deep Purple Sprouts",
		"genre": "rock",
		"fame": 70,
	},
	{
		"name": "Status Brew",
		"genre": "rock",
		"fame": 62,
	},
	{
		"name": "Rush Hour",
		"genre": "rock",
		"fame": 52,
	},
	{
		"name": "Slaycake",
		"genre": "metal",
		"fame": 68,
	},
	{
		"name": "Lamb Of Cod",
		"genre": "metal",
		"fame": 60,
	},
	{
		"name": "Mastodonut",
		"genre": "metal",
		"fame": 57,
	},
	{
		"name": "Gojiraffe",
		"genre": "metal",
		"fame": 53,
	},
	{
		"name": "Bush Tucker",
		"genre": "grunge",
		"fame": 62,
	},
	{
		"name": "Silverchairlift",
		"genre": "grunge",
		"fame": 56,
	},
	{
		"name": "Temple Of The Hog",
		"genre": "grunge",
		"fame": 50,
	},
	{
		"name": "Mother Love Bun",
		"genre": "grunge",
		"fame": 47,
	},
	{
		"name": "Ramoans",
		"genre": "punk",
		"fame": 81,
	},
	{
		"name": "The Offspringles",
		"genre": "punk",
		"fame": 74,
	},
	{
		"name": "Stiff Little Fish Fingers",
		"genre": "punk",
		"fame": 57,
	},
	{
		"name": "Dead Kennels",
		"genre": "punk",
		"fame": 53,
	},
	{
		"name": "Manic Street Sweepers",
		"genre": "britpop",
		"fame": 76,
	},
	{
		"name": "The Charlatangerines",
		"genre": "britpop",
		"fame": 58,
	},
	{
		"name": "Shed Severn",
		"genre": "britpop",
		"fame": 52,
	},
	{
		"name": "Echobelly Button",
		"genre": "britpop",
		"fame": 46,
	},
	{
		"name": "Snow Petrol",
		"genre": "indie",
		"fame": 78,
	},
	{
		"name": "Kaiser Chefs",
		"genre": "indie",
		"fame": 69,
	},
	{
		"name": "The Cooks",
		"genre": "indie",
		"fame": 65,
	},
	{
		"name": "Wolf Alison",
		"genre": "indie",
		"fame": 63,
	},
	{
		"name": "Foal Play",
		"genre": "indie",
		"fame": 59,
	},
	{
		"name": "Coldplaydough",
		"genre": "altrock",
		"fame": 92,
	},
	{
		"name": "Wheezer",
		"genre": "altrock",
		"fame": 66,
	},
	{
		"name": "Elbow Grease",
		"genre": "altrock",
		"fame": 64,
	},
	{
		"name": "Daftones",
		"genre": "altrock",
		"fame": 55,
	},
]

## Badgerton & District's finest. Generated each game from these.
const LOCAL := [
	{
		"name": "The Wet Biscuits",
		"genre": "indie",
	},
	{
		"name": "Dad Bod Riot",
		"genre": "punk",
	},
	{
		"name": "Gravel Hearts",
		"genre": "rock",
	},
	{
		"name": "Sludge Hammer",
		"genre": "grunge",
	},
	{
		"name": "Goat Throne",
		"genre": "metal",
	},
	{
		"name": "Detention Kids",
		"genre": "punk",
	},
	{
		"name": "The Seaside Specials",
		"genre": "britpop",
	},
	{
		"name": "Static Bloom",
		"genre": "altrock",
	},
	{
		"name": "Hazel Drift",
		"genre": "altrock",
	},
	{
		"name": "The Muddy Boots",
		"genre": "rock",
	},
	{
		"name": "Hamster Wheel Of Doom",
		"genre": "metal",
	},
	{
		"name": "The Damp Flannels",
		"genre": "grunge",
	},
	{
		"name": "Velvet Postcode",
		"genre": "indie",
	},
	{
		"name": "Chip Shop Heroes",
		"genre": "britpop",
	},
	{
		"name": "Skate Date",
		"genre": "punk",
	},
	{
		"name": "The Angry Toasters",
		"genre": "punk",
	},
	{
		"name": "Highway Badgers",
		"genre": "rock",
	},
	{
		"name": "Glass Elevator",
		"genre": "altrock",
	},
	{
		"name": "Slow Dazzle",
		"genre": "altrock",
	},
	{
		"name": "Crossroads Jack",
		"genre": "rock",
	},
	{
		"name": "Moss & The Mildews",
		"genre": "grunge",
	},
	{
		"name": "The Paper Foxes",
		"genre": "indie",
	},
	{
		"name": "Diesel Nun",
		"genre": "rock",
	},
	{
		"name": "Spit Valve",
		"genre": "punk",
	},
	{
		"name": "Obsidian Ferret",
		"genre": "metal",
	},
	{
		"name": "Bus Stop Romeo",
		"genre": "britpop",
	},
	{
		"name": "Drizzle Machine",
		"genre": "altrock",
	},
	{
		"name": "Cul-De-Sac Rebels",
		"genre": "punk",
	},
	{
		"name": "Fuzz Aldrin",
		"genre": "altrock",
	},
	{
		"name": "Barry & The Bottlenecks",
		"genre": "rock",
	},
	{
		"name": "Leg Day",
		"genre": "metal",
	},
	{
		"name": "The Bin Lids",
		"genre": "punk",
	},
	{
		"name": "Overdraft",
		"genre": "grunge",
	},
	{
		"name": "Pier Pressure",
		"genre": "britpop",
	},
	{
		"name": "Satellite Dishwasher",
		"genre": "altrock",
	},
	{
		"name": "The Cardigan Collective",
		"genre": "indie",
	},
	{
		"name": "Gristle",
		"genre": "metal",
	},
	{
		"name": "Mild Peril",
		"genre": "indie",
	},
	{
		"name": "Parking Fine",
		"genre": "punk",
	},
	{
		"name": "Lukewarm Tea",
		"genre": "britpop",
	},
	{
		"name": "The Rusty Hinges",
		"genre": "rock",
	},
	{
		"name": "Soggy Biscuit Theory",
		"genre": "grunge",
	},
	{
		"name": "Reverb Nation State",
		"genre": "altrock",
	},
	{
		"name": "The Soggy Sandwiches",
		"genre": "indie",
	},
	{
		"name": "Mortgage Payment",
		"genre": "punk",
	},
	{
		"name": "Garden Centre Riot",
		"genre": "punk",
	},
	{
		"name": "Satnav Says Left",
		"genre": "indie",
	},
	{
		"name": "The Midlife Crisps",
		"genre": "rock",
	},
	{
		"name": "Shed Of Doom",
		"genre": "metal",
	},
	{
		"name": "Gravy Train Wreck",
		"genre": "rock",
	},
	{
		"name": "The Lost Remotes",
		"genre": "britpop",
	},
	{
		"name": "Damp Patch",
		"genre": "grunge",
	},
	{
		"name": "Kettle Descaler",
		"genre": "metal",
	},
	{
		"name": "The Overdue Library Books",
		"genre": "indie",
	},
	{
		"name": "Nan's Conservatory",
		"genre": "altrock",
	},
	{
		"name": "Tumble Dryer Of Despair",
		"genre": "grunge",
	},
	{
		"name": "Parish Council Uproar",
		"genre": "punk",
	},
	{
		"name": "The Carvery Kings",
		"genre": "britpop",
	},
	{
		"name": "Hi-Vis Heroes",
		"genre": "britpop",
	},
	{
		"name": "Unexpected Item In Bagging Area",
		"genre": "punk",
	},
	{
		"name": "Speed Bump Ballet",
		"genre": "altrock",
	},
	{
		"name": "Pewter Tankard",
		"genre": "metal",
	},
	{
		"name": "Dog Walkers Anonymous",
		"genre": "rock",
	},
	{
		"name": "Lukewarm Bath",
		"genre": "grunge",
	},
	{
		"name": "Fog On The Ringroad",
		"genre": "altrock",
	},
	{
		"name": "Dave's Van",
		"genre": "rock",
	},
	{
		"name": "Beige Cardigan",
		"genre": "indie",
	},
	{
		"name": "Sausage Roll Apocalypse",
		"genre": "metal",
	},
]
