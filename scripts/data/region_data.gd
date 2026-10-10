class_name RegionData
extends RefCounted
## The public base: 9 UK regions. Eight have their three largest cities
## (about 1,000 people each, more for the big ones). London is a single
## 3,000-strong City of London.
##
## size: population multiplier (1.0 = ~1,000 people).
## flavour: genre popularity multipliers for the local music scene.

const BASE_POP := 1000
const LONDON_POP := 3000   # give or take 10%, different each game

const REGIONS := [
	{"id": "nw", "name": "Northwest England", "short": "North West", "cities": [
		{"name": "Manchester", "size": 1.4, "flavour": {"britpop": 1.9, "indie": 1.6, "edm": 1.3, "altrock": 1.2}},
		{"name": "Liverpool", "size": 1.4, "flavour": {"britpop": 1.7, "indie": 1.4, "rock": 1.2, "bluesrock": 1.2}},
		{"name": "Preston", "size": 1.0, "flavour": {"rock": 1.2, "poppunk": 1.2}},
	]},
	{"id": "ne", "name": "Northeast England", "short": "North East", "cities": [
		{"name": "Newcastle", "size": 1.2, "flavour": {"rock": 1.4, "indie": 1.3, "metal": 1.2}},
		{"name": "Sunderland", "size": 1.0, "flavour": {"indie": 1.3, "britpop": 1.2}},
		{"name": "Middlesbrough", "size": 1.0, "flavour": {"rock": 1.3, "punk": 1.2}},
	]},
	{"id": "mid", "name": "Midlands", "short": "Midlands", "cities": [
		{"name": "Birmingham", "size": 1.4, "flavour": {"metal": 2.2, "rock": 1.4, "edm": 1.2}},
		{"name": "Nottingham", "size": 1.0, "flavour": {"indie": 1.3, "punk": 1.2, "edm": 1.2}},
		{"name": "Leicester", "size": 1.0, "flavour": {"indie": 1.3, "altrock": 1.2}},
	]},
	{"id": "se", "name": "Southeast England", "short": "South East", "cities": [
		{"name": "Brighton", "size": 1.0, "flavour": {"indie": 1.5, "edm": 1.5, "shoegaze": 1.4}},
		{"name": "Southampton", "size": 1.0, "flavour": {"poppunk": 1.3, "rock": 1.1}},
		{"name": "Portsmouth", "size": 1.0, "flavour": {"punk": 1.3, "rock": 1.2}},
	]},
	{"id": "sw", "name": "Southwest England", "short": "South West", "cities": [
		{"name": "Bristol", "size": 1.0, "flavour": {"edm": 1.9, "altrock": 1.3, "indie": 1.2}},
		{"name": "Plymouth", "size": 1.0, "flavour": {"rock": 1.2, "poppunk": 1.2}},
		{"name": "Bournemouth", "size": 1.0, "flavour": {"bluesrock": 1.3, "edm": 1.2}},
	]},
	{"id": "wal", "name": "Wales", "short": "Wales", "cities": [
		{"name": "Cardiff", "size": 1.2, "flavour": {"rock": 1.5, "metal": 1.4, "altrock": 1.2}},
		{"name": "Swansea", "size": 1.0, "flavour": {"rock": 1.3, "metal": 1.3}},
		{"name": "Newport", "size": 1.0, "flavour": {"punk": 1.3, "rock": 1.2}},
	]},
	{"id": "ire", "name": "Ireland", "short": "Ireland", "cities": [
		{"name": "Dublin", "size": 1.2, "flavour": {"indie": 1.5, "rock": 1.4, "altrock": 1.2}},
		{"name": "Belfast", "size": 1.0, "flavour": {"punk": 1.6, "rock": 1.3}},
		{"name": "Cork", "size": 1.0, "flavour": {"rock": 1.3, "bluesrock": 1.3, "indie": 1.2}},
	]},
	{"id": "sco", "name": "Scotland", "short": "Scotland", "cities": [
		{"name": "Glasgow", "size": 1.2, "flavour": {"indie": 1.8, "rock": 1.3, "shoegaze": 1.3}},
		{"name": "Edinburgh", "size": 1.0, "flavour": {"indie": 1.3, "edm": 1.2, "altrock": 1.2}},
		{"name": "Aberdeen", "size": 1.0, "flavour": {"rock": 1.3, "metal": 1.3}},
	]},
	{"id": "lon", "name": "London", "short": "London", "cities": [
		{"name": "City of London", "size": 3.0, "flavour": {"edm": 1.4, "punk": 1.3, "indie": 1.3, "altrock": 1.2}},
	]},
]

## Nationwide genre popularity before local flavour and age.
const GENRE_POP := {"rock": 1.3, "indie": 1.2, "grunge": 0.6, "metal": 0.8, "punk": 0.7, "poppunk": 0.8,
	"britpop": 0.9, "altrock": 1.0, "shoegaze": 0.4, "bluesrock": 0.6, "edm": 1.2}

## Genre appeal by age band: [under 25, 25-39, 40-59, 60+]
const GENRE_AGE := {
	"rock": [0.9, 1.0, 1.3, 1.6], "indie": [1.3, 1.2, 0.9, 0.5], "grunge": [0.7, 1.2, 1.3, 0.6],
	"metal": [1.1, 1.1, 1.0, 0.6], "punk": [0.9, 0.9, 1.2, 1.3], "poppunk": [1.6, 1.1, 0.5, 0.2],
	"britpop": [0.6, 1.2, 1.5, 0.9], "altrock": [1.1, 1.3, 1.0, 0.5], "shoegaze": [1.0, 1.2, 1.0, 0.5],
	"bluesrock": [0.5, 0.8, 1.3, 2.0], "edm": [1.6, 1.1, 0.6, 0.3],
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
