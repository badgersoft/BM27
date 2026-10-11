class_name RegionData
extends RefCounted
## The public base: 9 UK regions. Eight have their three largest cities
## (about 1,000 people each, more for the big ones). London is a single
## 3,000-strong City of London.
##
## size: population multiplier (1.0 = ~1,000 people).
## flavour: genre popularity multipliers for the local music scene. Every
## city leads with something different; each game also shakes the scenes up
## a little (see Public._scene_drift).

const BASE_POP := 1000
const LONDON_POP := 3000   # give or take 10%, different each game

const REGIONS := [
	{"id": "nw", "name": "Northwest England", "short": "North West", "cities": [
		{"name": "Manchester", "size": 1.4, "flavour": {"britpop": 2.2, "indie": 1.6, "rock": 0.8}},
		{"name": "Liverpool", "size": 1.4, "flavour": {"britpop": 1.6, "rock": 1.5, "indie": 1.2, "metal": 0.7}},
		{"name": "Preston", "size": 1.0, "flavour": {"punk": 1.8, "grunge": 1.3, "indie": 0.8}},
	]},
	{"id": "ne", "name": "Northeast England", "short": "North East", "cities": [
		{"name": "Newcastle", "size": 1.2, "flavour": {"rock": 1.8, "metal": 1.4, "britpop": 0.8}},
		{"name": "Sunderland", "size": 1.0, "flavour": {"indie": 1.7, "britpop": 1.4, "rock": 0.8}},
		{"name": "Middlesbrough", "size": 1.0, "flavour": {"metal": 1.7, "punk": 1.4, "indie": 0.8}},
	]},
	{"id": "mid", "name": "Midlands", "short": "Midlands", "cities": [
		{"name": "Birmingham", "size": 1.4, "flavour": {"metal": 2.4, "rock": 1.3, "indie": 0.7}},
		{"name": "Nottingham", "size": 1.0, "flavour": {"grunge": 2.2, "punk": 1.4, "rock": 0.8}},
		{"name": "Leicester", "size": 1.0, "flavour": {"altrock": 1.8, "indie": 1.3, "rock": 0.8}},
	]},
	{"id": "se", "name": "Southeast England", "short": "South East", "cities": [
		{"name": "Brighton", "size": 1.0, "flavour": {"indie": 1.9, "altrock": 1.5, "metal": 0.6}},
		{"name": "Southampton", "size": 1.0, "flavour": {"punk": 1.8, "grunge": 1.3, "britpop": 0.8}},
		{"name": "Portsmouth", "size": 1.0, "flavour": {"rock": 1.5, "punk": 1.5, "indie": 0.8}},
	]},
	{"id": "sw", "name": "Southwest England", "short": "South West", "cities": [
		{"name": "Bristol", "size": 1.0, "flavour": {"altrock": 2.0, "grunge": 1.5, "rock": 0.8}},
		{"name": "Plymouth", "size": 1.0, "flavour": {"grunge": 2.1, "rock": 1.3, "indie": 0.8}},
		{"name": "Bournemouth", "size": 1.0, "flavour": {"britpop": 1.7, "rock": 1.3, "metal": 0.7}},
	]},
	{"id": "wal", "name": "Wales", "short": "Wales", "cities": [
		{"name": "Cardiff", "size": 1.2, "flavour": {"rock": 1.7, "metal": 1.6, "britpop": 0.8}},
		{"name": "Swansea", "size": 1.0, "flavour": {"metal": 1.8, "grunge": 1.3, "indie": 0.8}},
		{"name": "Newport", "size": 1.0, "flavour": {"punk": 1.9, "altrock": 1.3, "rock": 0.8}},
	]},
	{"id": "ire", "name": "Ireland", "short": "Ireland", "cities": [
		{"name": "Dublin", "size": 1.2, "flavour": {"indie": 1.8, "altrock": 1.5, "metal": 0.8}},
		{"name": "Belfast", "size": 1.0, "flavour": {"punk": 2.1, "rock": 1.3, "britpop": 0.8}},
		{"name": "Cork", "size": 1.0, "flavour": {"rock": 1.7, "britpop": 1.3, "metal": 0.8}},
	]},
	{"id": "sco", "name": "Scotland", "short": "Scotland", "cities": [
		{"name": "Glasgow", "size": 1.2, "flavour": {"indie": 1.8, "altrock": 1.6, "britpop": 1.2}},
		{"name": "Edinburgh", "size": 1.0, "flavour": {"altrock": 1.7, "grunge": 1.4, "rock": 0.8}},
		{"name": "Aberdeen", "size": 1.0, "flavour": {"metal": 1.9, "rock": 1.4, "indie": 0.8}},
	]},
	{"id": "lon", "name": "London", "short": "London", "cities": [
		{"name": "City of London", "size": 3.0, "flavour": {"punk": 1.4, "indie": 1.3, "britpop": 1.3, "altrock": 1.2, "grunge": 1.1, "metal": 1.1}},
	]},
]

## Nationwide genre popularity before local flavour and age. Kept fairly
## flat so local scenes decide what a city sounds like.
const GENRE_POP := {"rock": 1.05, "indie": 1.05, "grunge": 0.95, "metal": 0.95, "punk": 0.95,
	"britpop": 0.95, "altrock": 1.0}

## Genre appeal by age band: [under 25, 25-39, 40-59, 60+]
const GENRE_AGE := {
	"rock": [0.85, 1.0, 1.2, 1.4], "indie": [1.3, 1.2, 0.85, 0.5], "grunge": [0.8, 1.25, 1.2, 0.6],
	"metal": [1.15, 1.1, 1.0, 0.6], "punk": [1.3, 1.0, 1.0, 0.9],
	"britpop": [0.7, 1.2, 1.4, 0.9], "altrock": [1.15, 1.3, 1.0, 0.55],
}

## How likely each age band is to go to gigs (0-100, before personal variation).
const GIG_BY_AGE := [[14, 45], [18, 70], [25, 60], [35, 42], [50, 30], [65, 18]]

const NAMES_F := ["Amy", "Abbie", "Alice", "Amber", "Ava", "Becky", "Beth", "Bethany", "Caitlin", "Charlotte",
	"Chloe", "Claire", "Courtney", "Danielle", "Debbie", "Ella", "Ellie", "Emily", "Emma", "Erin", "Evie",
	"Faye", "Freya", "Gemma", "Georgia", "Grace", "Hannah", "Hayley", "Heather", "Holly", "Imogen", "Isla",
	"Jade", "Jasmine", "Jenny", "Jess", "Jodie", "Julie", "Karen", "Kate", "Katie", "Kayleigh", "Kerry",
	"Kirsty", "Laura", "Lauren", "Leah", "Lily", "Lisa", "Lorraine", "Lucy", "Lydia", "Maisie", "Megan",
	"Mel", "Mia", "Millie", "Molly", "Naomi", "Natalie", "Nicola", "Olivia", "Paige", "Phoebe", "Poppy",
	"Rachel", "Rebecca", "Rosie", "Ruby", "Sadie", "Samantha", "Sarah", "Scarlett", "Shannon", "Sophie",
	"Stacey", "Tasha", "Tilly", "Tracey", "Vicky", "Zoe", "Bev", "Brenda", "Carol", "Denise", "Doreen",
	"Elaine", "Gail", "Jackie", "Janet", "Linda", "Maureen", "Pat", "Sandra", "Sharon", "Wendy", "Yvonne",
	"Aisha", "Priya", "Fatima", "Zara", "Amira", "Leila", "Nadia", "Simone", "Keisha", "Precious"]
const NAMES_M := ["Aaron", "Adam", "Alex", "Alfie", "Archie", "Ben", "Billy", "Bradley", "Callum", "Charlie",
	"Chris", "Connor", "Craig", "Dan", "Danny", "Darren", "Dave", "Dean", "Dylan", "Ed", "Elliot", "Ethan",
	"Finley", "Frankie", "Freddie", "Gary", "George", "Harry", "Harvey", "Jack", "Jacob", "Jake", "James",
	"Jamie", "Jason", "Joe", "Jordan", "Josh", "Kai", "Karl", "Kev", "Kieran", "Kyle", "Lee", "Leo", "Lewis",
	"Liam", "Louis", "Luke", "Mark", "Martin", "Matt", "Max", "Michael", "Mike", "Nathan", "Neil", "Nick",
	"Oliver", "Ollie", "Oscar", "Paul", "Pete", "Phil", "Reece", "Rich", "Rob", "Ryan", "Sam", "Scott",
	"Sean", "Si", "Steve", "Stuart", "Theo", "Tom", "Tony", "Tyler", "Wayne", "Will", "Alan", "Barry",
	"Brian", "Clive", "Colin", "Derek", "Graham", "Keith", "Malcolm", "Nigel", "Ray", "Roy", "Terry",
	"Trevor", "Arjun", "Hassan", "Imran", "Kwame", "Mo", "Raj", "Tariq", "Tunde", "Yusuf", "Marcus"]
## Extra names mixed in for some regions (40% of people there).
const REGION_NAMES := {
	"ire": {"f": ["Aoife", "Ciara", "Niamh", "Orla", "Saoirse", "Siobhan", "Roisin", "Grainne", "Clodagh", "Aisling", "Mairead", "Sinead"],
		"m": ["Cian", "Ciaran", "Conor", "Darragh", "Eoin", "Fionn", "Oisin", "Padraig", "Ronan", "Seamus", "Declan", "Niall"]},
	"sco": {"f": ["Eilidh", "Iona", "Kirsty", "Morag", "Mhairi", "Shona", "Fiona", "Ailsa", "Catriona", "Isla"],
		"m": ["Angus", "Callum", "Euan", "Fraser", "Hamish", "Iain", "Lachlan", "Murray", "Rory", "Struan", "Gregor", "Alasdair"]},
	"wal": {"f": ["Bethan", "Carys", "Cerys", "Ffion", "Gwen", "Nia", "Rhiannon", "Seren", "Sian", "Mali", "Eluned"],
		"m": ["Aled", "Dafydd", "Dylan", "Emyr", "Gareth", "Gethin", "Huw", "Ieuan", "Owain", "Rhys", "Taff", "Bryn"]},
	"lon": {"f": ["Chiamaka", "Adaeze", "Shanice", "Roxanne", "Anya", "Esme", "Ines", "Mei", "Yasmin", "Kemi"],
		"m": ["Femi", "Kofi", "Rashid", "Dev", "Luca", "Mateo", "Jun", "Omar", "Andre", "Jermaine"]},
}

## Landmark venues always play in a fixed city.
const VENUE_CITY := {"brixtown": "City of London", "allypally": "City of London", "o3": "City of London",
	"wombley": "City of London", "moonarena": "Manchester", "glasto": "Bristol"}
