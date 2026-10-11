class_name NameData
extends RefCounted
## Word pools for generating band names, single titles and album titles
## that fit each genre. Patterns use {A} adjective, {N} noun, {P} plural noun,
## {V} verb, {X} free-form phrase. Titles are never reused while they're in
## a chart (see Charts.fresh_title), so bigger pools mean fresher charts.

const BAND := {
	"rock": {"A": ["Loud", "Electric", "Highway", "Iron", "Wild", "Burning", "Rusty", "Thunder", "Crimson", "Gold", "Muddy", "Crossroads", "Whiskey", "Delta", "Dusty", "Bottleneck", "Moonshine", "Smoky", "Lonesome"],
		"N": ["Badger", "Engine", "Riot", "Machine", "Jackal", "Rebel", "Rocket", "Vulture", "Lightning", "Diesel", "Boot", "Jack", "Mule", "Preacher", "Train", "Slide", "Hound", "Porch", "Banjo", "Juke"],
		"X": ["Rust & Thunder", "Volume Eleven", "Loud Neighbours", "The Last Orders", "Diesel Hearts", "Steel Valentine", "The Muddy Boots", "Crossroads Jack", "Bottleneck Sermon", "Whiskey Mule", "Delta Hounds", "Lonesome Freight"]},
	"metal": {"A": ["Iron", "Obsidian", "Doom", "Blood", "Molten", "Black", "Infernal", "Grim", "Thunder", "Savage"],
		"N": ["Goat", "Wraith", "Anvil", "Skull", "Throne", "Serpent", "Hammer", "Raven", "Kraken", "Cauldron"],
		"X": ["Anvil Of Sorrow", "Goat Throne", "Death By Badger", "Cauldron Born", "Hammerfist", "The Ninth Abyss"]},
	"grunge": {"A": ["Damp", "Rusted", "Soggy", "Flannel", "Bitter", "Grey", "Moss", "Static", "Sore", "Murky"],
		"N": ["Lung", "Drain", "Cobweb", "Puddle", "Bruise", "Feedback", "Mould", "Gutter", "Scab", "Fog"],
		"X": ["Sludgefield", "Wet Carpet", "Bruise Garden", "Seattle Drizzle", "Mildew Sermon", "Unwashed Saints"]},
	"punk": {"A": ["Angry", "Rotten", "Broken", "Spiky", "Cheap", "Snotty", "Feral", "Bored", "Useless", "Riot", "Detention", "Skate", "Summer", "Grounded", "Teenage", "Late", "Backyard", "Weekend", "Basement", "Sugar"],
		"N": ["Toaster", "Brick", "Pigeon", "Council", "Gob", "Kettle", "Bin", "Dole", "Spanner", "Lager", "Kid", "Date", "Crush", "Prom", "Ramp", "Homework", "Curfew", "Mixtape", "Sneaker", "Rollercoaster"],
		"X": ["Spit Valve", "Council Estate Kings", "No Future Tuesday", "The Safety Pins", "Gob Shite Choir", "Anarchy In The Chippy", "All Time Late", "My Mum Says No", "Detention Kids", "Skate Date", "Curfew Breakers", "Simple Plan B"]},
	"britpop": {"A": ["Seaside", "Mod", "Cheeky", "Northern", "Rainy", "Union", "Parka", "Corner", "Saturday", "Proper"],
		"N": ["Special", "Lad", "Hero", "Chippy", "Pier", "Scooter", "Terrace", "Bulldog", "Kettle", "Jukebox"],
		"X": ["Chip Shop Heroes", "The Seaside Specials", "Parklife Crisis", "Rainy Days Club", "Cuppa Tea Society", "Bus Stop Romeo"]},
	"indie": {"A": ["Paper", "Velvet", "Quiet", "Polite", "Borrowed", "Second-hand", "Tiny", "Neon", "Cardigan", "Sunday", "Pixel"],
		"N": ["Fox", "Postcode", "Bicycle", "Library", "Teaspoon", "Lighthouse", "Satellite", "Pigeon", "Ferry", "Allotment"],
		"X": ["Bicycle Thieves", "Postcards From Tuesday", "The Polite Society", "Tea For Strangers", "Hello Ferris Wheel", "We Were Pigeons"]},
	"altrock": {"A": ["Static", "Glass", "Hollow", "Siamese", "Plastic", "Paper", "Radio", "Broken", "Velvet", "Neon", "Slow", "Hazy", "Drifting", "Soft", "Pale", "Cloud", "Melting", "Silver", "Lilac"],
		"N": ["Bloom", "Elevator", "Signal", "Dream", "Machine", "Echo", "Satellite", "Orchid", "Heater", "Antenna", "Dazzle", "Drift", "Haze", "Reverb", "Halo", "Moth", "Shimmer", "Daydream", "Veil", "Lullaby"],
		"X": ["Static Bloom", "Glass Elevator", "Fuzz Aldrin", "Hollow Orchestra", "Analogue Ghosts", "Radio Ambulance", "Slow Dazzle", "Hazel Drift", "Pedalboard Sky", "Eyes On Laces", "Soft Focus Ghosts", "Moth Choir"]},
}
const BAND_PATTERNS := ["The {A} {P}", "{A} {N}", "{N} {N}", "{X}", "The {P}", "{A} {N} Club", "{N} & The {P}"]

const SONG := {
	"rock": [
		"Highway Burn", "Volume Up", "Thunder Road Rage", "Rock Me Till Tuesday", "Electric Gravy", "Born To Be Mild",
		"Back To The Badger", "Midnight Diesel", "Shout It Loud", "Smoke On The Lawn", "Live Wire Lizzie", "Big Amp Energy",
		"Stairway To Leeds", "Whole Lotta Lunch", "Rock Steady Eddie", "Hell's Kitchen Sink", "Seven Nation Armchair",
		"Fell In Love With A Squirrel", "Lonely Boy (In Leeds)", "Gold On The Ceiling Fan", "Crossroads Café", "Bottleneck Blues",
		"Whiskey Mule", "Delta Dawn Chorus", "Muddy Water Feature", "Smoky Porch", "Train Kept A-Rollin' Late", "Hound Dog Days",
		"Slide Into Sunday", "Moonshine Mavis", "Sweet Child O' Mine (Is Teething)", "Paradise City Centre",
		"You Shook Me All Night Long (Bad Back)", "Born In The Bus Station", "Highway Star Bar", "Dream On (And On)",
		"Livin' On A Prayer Mat", "Don't Stop Believin' In Biscuits", "Black Dog Walker", "Rock And Roll Allotment",
		"Thunderstruck By Lightning (Twice)", "Back In The Saddle Bag", "Gravy Train", "Kickstart My Moped",
		"Run To The Hills (Of Wigan)", "Long Way To The Top Shelf", "Free Bird Feeder", "Roadhouse Brews", "Satisfaction Guaranteed",
		"Gimme Shelter (From The Rain)"],
	"metal": [
		"Master Of Muppets", "Enter Sandwich", "Ace Of Spuds", "Run To The Kettles", "Paranoid Android Phone", "Iron Badger",
		"Breaking The Lawn", "Raining Bread", "Number Of The Beets", "Fear Of The Darts", "Hammer Of Gods-ish", "Throne Of Goats",
		"Kraken Me Up", "Anvil Of Sorrow", "Holy Diver (Snorkel)", "Crazy Train Station", "Hallowed Be Thy Lane",
		"Iron Man (Ironing Board)", "War Pigs In Blankets", "South Of Heaven (Basingstoke)", "Painkiller Paracetamol",
		"Wherever I May Roam (Charging)", "Chop Suey Takeaway", "Walk (Don't Run)", "Duality Of Man Bags", "Psychosocial Club",
		"Ace Of Bass Drums", "The Trooper (Paratrooper)", "Seasons In The Abyss Café", "Battery Hen", "Thunder Kitten", "Doom Kettle"],
	"grunge": [
		"Smells Like Wet Dog", "Rain On Me Again", "Puddle Of Me", "Black Hole Drizzle", "Come As You Aren't", "Feedback Funeral",
		"Man In The Box Room", "Jeremy's Garden Shed", "Heart-Shaped Bruise", "Even Flow Chart", "Lithium Battery", "Mouldy Sunday",
		"Spoonman's Cousin", "Cobweb Crown", "Would? (Probably Not)", "Rooster In The Garden", "Black (And Blue)",
		"Alive (Just About)", "Plush Toy", "Interstate Love Bus", "Hunger Strike Snack", "Touch Me I'm Soggy", "Rusty Cage Fighter",
		"Outshined Shoes", "Dumb (But Lovely)", "Hurt Feelings", "Daughter's Drum Kit", "Zero (Out Of Ten)", "Penny Royal Tea Bag",
		"Lake Of Fire Station", "Drain You (Bath)", "Flannel Funeral"],
	"punk": [
		"Anarchy In The Chippy", "God Save The Cream", "London Drizzling", "Blitzkrieg Pop-Tart", "Kettle Riot",
		"Council Estate Of Mind", "I Wanna Be Sedated (At Home)", "Pretty Vacant Lot", "Should I Stay Or Should I Go Home",
		"White Riot Van", "No Fun At All", "Spit On My Spanner", "Lager Than Life", "Bin Day Blues", "All The Small Thongs",
		"Basket Case Of Lager", "What's My Age Again (Ask My Mum)", "Sk8er Bro", "Fat Lip Balm", "In Too Shallow", "Grounded Forever",
		"Mixtape Heart", "Curfew Breaker", "The Rock Show (At School)", "Dammit Janet", "Detention Romance", "Summer Of '09",
		"Prom Night Disaster", "Ever Fallen In Love (With Your Sofa)", "New Rose Garden", "Holidays In The Drizzle",
		"Sheena Is A Punk Rocker (On Weekends)", "Alternative Ulster Fry", "Teenage Kicks (In The Shins)", "Complete Control Freak",
		"Rudie Can't Fail His Driving Test", "Smash It Up (The Shed)", "Hong Kong Garden Centre", "Boredom (Is Fine)",
		"Orgasm Addict (Dial-Up)", "Brain Stew Pot", "When I Come Around (For Tea)", "Welcome To Paradise Lost Property",
		"Misery Business Park", "Sugar We're Going Down (The Shops)", "I Miss You (Text Me)", "Girls & Boys (Remix)", "Skater Mum"],
	"britpop": [
		"Wonderwall Of Biscuits", "Parklife Crisis", "Common Peephole", "Don't Look Back In Bangor", "Girls & Boys & Dogs",
		"Champagne Supernova Tea", "Alright (Fair Enough)", "Country House Party", "Live Forever (Ish)", "Disco 2001",
		"Sunday Sunday Dinner", "Song 3", "The Chippy On The Corner", "Cuppa Tea Revolution", "Roll With It (Sausage Roll)",
		"Some Might Say (Others Won't)", "Charmless Man (Charming Really)", "Common Peeps", "The Drugs Don't Work (Paracetamol Does)",
		"Bitter Sweet Symphony Orchestra", "Lazy Sunday Roast", "Coffee & TV Licence", "Beetlebum Bag", "Tender Moments",
		"Alright Mate", "Animal Nitrate Free", "Stay Together (For The Kids)", "Stand By Me (In The Queue)",
		"Cigarettes & Alcohol-Free Lager", "Slight Return Ticket", "Female Of The Species (Is More Deadly With A Remote)",
		"Bank Holiday Rain", "Seaside Rock (Stick Of)", "Terrace Chant"],
	"indie": [
		"Postcards From The Bus Stop", "Tuesday Is A Feeling", "Cardigan Weather", "I Bet You Look Good On The Tram",
		"Last Train To Clarksville Road", "Mr Brightside Salad", "Somebody Else's Allotment", "Seven Nation Teaspoon",
		"Paper Planes Of Leeds", "Teenage Library Card", "Fluorescent Adolescent Badger", "Take Me Out (For Tea)", "Bike Shed Romance",
		"The Ferry Song", "Mardy Bum Bag", "When The Sun Goes Down (At Four)", "Chelsea Dagger (Butter Knife)", "Ruby Tuesday Market",
		"Last Nite Bus", "Reptilia Pet Shop", "Do You Want To (Come For Tea)", "Golden Skans Of Toast", "Rocket From The Crypt Shop",
		"Bus Stop Polaroids", "Somebody Told Me (Twice)", "There Is A Light That Never Goes Out (Bulb Needs Changing)",
		"This Charming Van", "Love Will Tear Us Apart (Gently)", "Electric Feel (Slight Tingle)", "Kids (Off The Lawn)",
		"Time To Pretend (To Work)", "Young Folks Club", "Tram Stop Heart", "Charity Shop Jumper"],
	"altrock": [
		"Karma Policeman", "Creep (Downstairs)", "Today Is Thursday", "Bullet With Butterfly Shingles", "Zero Interest",
		"Everlong Weekend", "Paranoid Antenna", "Static Bloom", "Radio Ambulance", "Plastic Tree Surgery", "Hollow Heater",
		"No Surprises Please", "Fake Plastic Trees (Real)", "Satellite Of Gloves", "Only Shallow End", "Soon (Ish)", "Alison's Reverb",
		"When You Sleep In", "Pedalboard Sky", "Moth Choir", "Halo Of Fog", "Lilac Haze", "Soft Focus", "Melting Ferris Wheel",
		"Sometimes (Always)", "Dagger In The Daydream", "Vapour Trails Of Tea", "Silver Lullaby", "Song 2 (Electric Boogaloo)",
		"Under The Bridge (Kettering)", "Black Hole Sun Lounger", "1979 (And A Bit)", "Disarm (Gently)", "Hysteria (Mild)",
		"Plug In Baby Monitor", "Supermassive Black Hole In My Sock", "Mountain Song (Small Hill)",
		"Where Is My Mind (Left It On The Bus)", "Here Comes Your Man (He's Late)", "Monkey Gone To Heaven (Swindon)",
		"Californication Station", "Scar Tissue Paper", "Mr. November Rain", "Fake Plastic Fork", "Pyramid Song (Small Triangle)",
		"Bones (Of Contention)", "Wall Of Reverb", "Pedal To The Metal Bin"],
}

const ALBUM := {
	"rock": [
		"Back In Black Pudding", "Highway To Hull", "Led Zeplinnn IV-ish", "Appetite For Construction", "Volume Eleven",
		"Rumours Has It", "Born In The UK", "Bat Out Of Hull", "Exile On Mean Street", "Elephant In The Room",
		"Brothers In Arms (And Legs)", "Electric Ladyland Rover", "El Camino Real Ale", "Let It Bleed (A Bit)", "Bottleneck Sermon",
		"Delta Hound Dog", "Highway To Hell's Kitchen", "Physical Graffiti Removal", "Machine Head (Lice)", "Hysteria Lane",
		"Slippery When Wet Wipes", "Appetite For Destruction Derby", "Toys In The Attic Room", "Rocks (And Pebbles)",
		"Get Your Wings (Chicken)", "Let There Be Rock Cakes", "Hotel California Budget Inn", "Out Of The Blue Peter"],
	"metal": [
		"Master Of Muppets", "Paranoid Android-ish", "The Number Of The Beets", "Ride The Lightning Bolt", "Reign In Bread",
		"Ace Of Spuds", "Iron Badger", "...And Justice For Owls", "Powerslave (To The Rhythm)", "Rust In Peace & Quiet",
		"Reign In Blood Orange", "Vulgar Display Of Flowers", "British Steel Toecaps", "Screaming For Vengeance (And Tea)",
		"Painkiller Pack Of 16", "Master Of Reality TV", "Iron Maidenhead", "Toxicity Report", "Sad Wings Of Destiny's Child",
		"Blizzard Of Ozz (Light Flurries)"],
	"grunge": [
		"Nevermind The Bills", "Ten (Out Of Ten)", "Superunknown Pleasures", "Dirt Cheap", "Bleach Blonde", "Badmotorfinger Food",
		"In Utero (Sort Of)", "Vs. The World", "Facelift Pending", "Core (Apple)", "Purple (Bruise)", "Bleach (Mild Spray)",
		"Vitalogy Test", "Down On The Upside Down Cake", "Jar Of Flies Swatter", "Siamese Twins Dreams", "Gish And Chips",
		"Temple Of The Dog Walker"],
	"punk": [
		"Never Mind The Bollards", "London Drizzling", "Rocket To Rushden", "Damned Damned Damp", "Pink Flag Day",
		"Council Estate Of Mind", "No Future Tuesday", "Brutalism (On A Budget)", "Dookie Monster", "Enema Of The Sixth Form",
		"American Idiot Abroad", "Take Off Your Pants And Jackets And Coats", "Riot At Prom", "Grounded Forever",
		"Sticks And Stones And Skateboards", "From Under The Duvet", "London Calling (Collect)", "Inflammable Material Girl",
		"Damned Damned Damp II", "Rattus Norvegicus (The Shed Rat)", "Singles Going Steady Eddie", "The Clash Of Clans",
		"Pink Flag Day Out", "Dookie Monster Munch", "Pop Punk's Not Dead (Just Resting)", "Riot! At The Leisure Centre",
		"Nimrod (Sorry)", "From Under The Cork Tree (Small Cork)"],
	"britpop": [
		"(What's The Story) Mourning Glory?", "Parklife Crisis", "Different Class Trip", "Definitely Maybe Not",
		"Modern Life Is Rubbish Collection", "Coming Up For Air (and Tea)", "Urban Hymns & Biscuits", "Be Here Now (Ish)",
		"Leisure Centre", "Coming Up For Air Freshener", "His 'N' Hers 'N' Theirs", "I Should Coco Pops", "A Northern Soul Food",
		"Dog Man Star Jump", "Elastica Band", "Moseley Shoals Shoes", "Blue Lines Of Tape", "The Great Escape Room", "Suede Shoes",
		"Standing On The Shoulder Of Giants (Gently)"],
	"indie": [
		"Whatever People Say I Am, That's What I'm Not Wearing", "Is This It? Probably", "Up The Bracket Shelf", "Hot Fuss Pot",
		"The Queen Is Dead Tired", "Postcards From Tuesday", "Cardigan Weather", "Favourite Worst Nightmare Before Christmas",
		"AM (And A Bit Of PM)", "Room On Fire Escape", "Sam's Town Hall", "Silent Alarm Clock", "Funeral (Sandwiches Provided)",
		"Oracular Spectacular Spectacles", "Is This Bit? Probably", "Some Girls Are Bigger Than Others (Shoe Sizes)",
		"The Stone Roses Garden Centre", "Turn On The Bright Lights (Bill Pending)", "Antics Roadshow", "Give Up (The Car)"],
	"altrock": [
		"OK Computer Says No", "Siamese Dreamboats", "The Bends In The Road", "Kid Ayy", "Mellon Collie And The Infinite Sadness Tea",
		"Doolittle Bit More", "Origin Of Symmetry Nightmares", "Puzzle (Missing Pieces)", "Loveless Than Zero", "Souvlaki Sunday",
		"Nowhere (Near)", "Going Blank Again And Again", "Pedalboard Sky", "Disintegration Loops", "Moth Choir", "Soft Focus Ghosts",
		"Blood Sugar Sex Magic Trick", "Surfer Rosa (Wet Suit)", "Absolution (And Bleach)", "Gish & Chips",
		"In Rainbows (Mostly Drizzle)", "Amnesiac (What Was It Again?)", "The Colour And The Shape Sorter",
		"Ten Thousand Fists (Gentle Taps)", "Deja Entendu Again", "Black Holes And Revelations (Week 2)",
		"Hail To The Thief (Of My Bike)", "Siamese Dream Holiday"],
}
