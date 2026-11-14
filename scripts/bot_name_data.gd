extends RefCounted









const ADJECTIVES: = [
	"swift", "silent", "dark", "bright", "cold", "hot", "wild", "calm", 
	"brave", "crazy", "angry", "happy", "lucky", "lonely", "lost", "frozen", 
	"burning", "golden", "silver", "iron", "steel", "shadow", "ghost", "neon", 
	"pixel", "cyber", "lunar", "solar", "cosmic", "rapid", "deadly", "fatal", 
	"brutal", "gentle", "mighty", "tiny", "giant", "clever", "sneaky", "shady", 
	"frosty", "stormy", "misty", "dusty", "rusty", "shiny", "bloody", "royal", 
	"rebel", "savage", "toxic", "vivid", "alpha", "beta", "omega", "prime", 
	"ultra", "hyper", "mega", "turbo", "nitro", "retro", "modern", "ancient", 
	"hidden", "broken", "chosen", "fallen", "rising", "endless", "final", "first", 
	"last", "north", "south", "east", "west", "upper", "lower", "inner", 
	"outer", "deep", "high", "low", "long", "short", "fast", "slow", 
	"hard", "soft", "sweet", "sour", "bitter", "spicy", "salty", "fresh", 
	"stale", "clean", "dirty", "rich", "poor", "young", "old", "new", 
	"wise", "mad", "grim", "pale", "light", "heavy", "empty", "full", 
	"open", "closed", "quiet", "loud", "proud", "humble", "honest", "sly", 
	"keen", "sharp", "blunt", "bold", "shy", "warm", "cool", "icy", 
	"sunny", "rainy", "windy", "snowy", "foggy", "starry", "cloudy", "muddy", 
	"sandy", "rocky", "grassy", "leafy", "woody", "fiery", "watery", "airy", 
	"earthy", "electric", "atomic", "stellar", "glowing", "sleepy", "lazy", "busy", 
]

const NOUNS: = [
	"wolf", "fox", "bear", "lion", "tiger", "eagle", "falcon", "hawk", 
	"raven", "crow", "owl", "snake", "viper", "cobra", "shark", "whale", 
	"dolphin", "turtle", "rabbit", "hare", "mouse", "rat", "cat", "dog", 
	"panda", "koala", "monkey", "gorilla", "horse", "pony", "bull", "cow", 
	"goat", "sheep", "pig", "boar", "deer", "elk", "moose", "badger", 
	"otter", "beaver", "lynx", "puma", "jaguar", "leopard", "cheetah", "panther", 
	"rhino", "hippo", "camel", "zebra", "giraffe", "elephant", "penguin", "seal", 
	"walrus", "octopus", "squid", "crab", "shrimp", "jellyfish", "starfish", "salmon", 
	"trout", "pike", "carp", "eel", "frog", "toad", "lizard", "gecko", 
	"chameleon", "crocodile", "alligator", "dragon", "phoenix", "griffin", "unicorn", "demon", 
	"angel", "devil", "spirit", "zombie", "vampire", "werewolf", "goblin", "troll", 
	"orc", "elf", "dwarf", "knight", "ninja", "samurai", "viking", "pirate", 
	"cowboy", "hunter", "sniper", "ranger", "soldier", "captain", "king", "queen", 
	"prince", "princess", "lord", "boss", "chief", "master", "legend", "hero", 
	"villain", "joker", "clown", "wizard", "witch", "monk", "priest", "shaman", 
	"nomad", "wanderer", "stranger", "traveler", "runner", "rider", "driver", "pilot", 
	"sailor", "fisher", "farmer", "builder", "miner", "trader", "banker", "hacker", 
	"coder", "gamer", "player", "noob", "pro", "rookie", "veteran", "champion", 
	"winner", "loser", "fighter", "killer", "slayer", "reaper", "sword", "knife", 
	"axe", "hammer", "spear", "bow", "arrow", "shield", "helmet", "mask", 
	"cloak", "boots", "glove", "ring", "crown", "throne", "castle", "tower", 
	"bridge", "gate", "wall", "roof", "door", "window", "chair", "table", 
	"lamp", "candle", "mirror", "clock", "phone", "camera", "radio", "guitar", 
	"piano", "drum", "violin", "trumpet", "flute", "microphone", "headset", "keyboard", 
	"monitor", "screen", "cable", "battery", "engine", "rocket", "missile", "bullet", 
	"grenade", "bomb", "mine", "tank", "plane", "helicopter", "boat", "ship", 
	"train", "car", "bike", "truck", "bus", "taxi", "tractor", "drone", 
	"robot", "android", "machine", "reactor", "portal", "crystal", "diamond", "ruby", 
	"emerald", "sapphire", "pearl", "coin", "gold", "map", "compass", "lantern", 
	"torch", "book", "page", "pen", "brush", "paint", "canvas", 
	"puzzle", "cube", "sphere", "prism", "shard", "fragment", "relic", "artifact", 
	"totem", "idol", 
]

const FOOD: = [
	"pizza", "burger", "sushi", "ramen", "pasta", "noodle", "taco", "burrito", 
	"kebab", "shawarma", "hotdog", "sandwich", "toast", "pancake", "waffle", "donut", 
	"cookie", "cake", "pie", "muffin", "cupcake", "chocolate", "candy", "honey", 
	"jam", "butter", "cheese", "milk", "cream", "yogurt", "kefir", "bread", 
	"bagel", "croissant", "pretzel", "popcorn", "chips", "fries", "nugget", "steak", 
	"bacon", "sausage", "ham", "chicken", "turkey", "duck", "goose", "beef", 
	"pork", "lamb", "caviar", "egg", "omelet", "salad", "soup", "borscht", 
	"pelmeni", "dumpling", "varenik", "blini", "porridge", "rice", "buckwheat", "potato", 
	"tomato", "cucumber", "carrot", "onion", "garlic", "pepper", "cabbage", "broccoli", 
	"pumpkin", "corn", "pea", "bean", "mushroom", "olive", "lemon", "lime", 
	"orange", "apple", "pear", "peach", "plum", "cherry", "grape", "melon", 
	"watermelon", "strawberry", "raspberry", "blueberry", "banana", "mango", "pineapple", "coconut", 
	"kiwi", "avocado", "coffee", "tea", "cocoa", "soda", "cola", "lemonade", 
	"juice", "smoothie", "milkshake", "beer", "wine", "vodka", "whiskey", "cocktail", 
]

const GAMING: = [
	"aim", "headshot", "wallbang", "noscope", "scope", "crosshair", "recoil", "spray", 
	"flick", "clutch", "ace", "defuse", "plant", "round", "match", "lobby", 
	"queue", "rank", "elo", "mmr", "meta", "patch", "update", "tryhard", 
	"smurf", "cheater", "camper", "rusher", "lurker", "entry", "support", "anchor", 
	"rotator", "igl", "awper", "rifler", "duelist", "sentinel", "controller", "initiator", 
	"healer", "dps", "carry", "feeder", "jungler", "mid", "top", "jungle", 
	"gank", "farm", "push", "rush", "hold", "peek", "bait", "trade", 
	"flank", "rotate", "strat", "tactic", "team", "squad", "clan", "guild", 
	"party", "raid", "loot", "drop", "skin", "case", "crate", "chest", 
	"key", "token", "level", "xp", "quest", "mission", "arena", "duel", 
	"battle", "war", "victory", "defeat", "win", "loss", "draw", "streak", 
	"combo", "critical", "damage", "healing", "mana", "energy", "stamina", "reload", 
	"ammo", "magazine", "pistol", "rifle", "shotgun", "smg", "lmg", "flash", 
	"smoke", "molotov", "decoy", "flashbang", "lineup", "frag", "kill", "death", 
	"assist", "score", "board", "leaderboard", "rankup", "derank", "placement", 
]

const NAMES: = [
	"alex", "max", "mark", "mike", "nick", "john", "jack", "jake", 
	"luke", "leo", "leon", "dan", "dave", "david", "paul", "peter", 
	"sam", "tom", "tim", "ted", "bob", "rob", "ron", "ben", 
	"bill", "will", "kai", "kyle", "ryan", "sean", "seth", "cole", 
	"cody", "dylan", "ethan", "evan", "gabe", "grant", "james", "jason", 
	"kevin", "liam", "logan", "mason", "nolan", "owen", "quinn", "ross", 
	"scott", "shane", "tyler", "wyatt", "zane", "adam", "adrian", "alan", 
	"albert", "andrew", "anton", "arthur", "barry", "blake", "brandon", "brian", 
	"bruce", "bryan", "calvin", "carl", "chad", "charles", "chris", "clark", 
	"clay", "clint", "clyde", "colin", "connor", "craig", "curt", 
	"caleb", "dale", "damon", "dean", "derek", "derrick", "devin", "dominic", 
	"don", "douglas", "duncan", "dustin", "earl", "eddie", "edgar", "elliot", 
	"eric", "ernest", "felix", "fernando", "frank", "fred", "gary", "george", 
	"gerald", "gilbert", "glen", "gordon", "graham", "greg", "harold", "harry", 
	"harvey", "hector", "henry", "herbert", "howard", "hugh", "ian", "ivan", 
	"jasper", "jeff", "jerry", "jim", "joe", "joel", "jordan", "jose", 
	"josh", "juan", "justin", "karl", "keith", "ken", "kenneth", "kurt", 
	"lance", "larry", "lawrence", "lee", "lewis", "lincoln", "lloyd", "louis", 
	"lucas", "luis", "malcolm", "manuel", "marcus", "mario", "martin", "marvin", 
	"matthew", "maurice", "melvin", "miguel", "milton", "mitchell", "morgan", "neil", 
	"nelson", "norman", "oliver", "oscar", "patrick", "pedro", "perry", "philip", 
	"pierce", "ralph", "randy", "raymond", "reginald", "rex", "richard", "rick", 
	"ricky", "robert", "roger", "roland", "ronald", "roy", "russell", "salvador", 
	"samuel", "sergio", "sidney", "simon", "spencer", "stanley", "stephen", "stuart", 
	"terry", "theodore", "thomas", "timothy", "tobias", "todd", "travis", "trevor", 
	"troy", "vincent", "walter", "warren", "wayne", "wesley", "william", "winston", 
	"zach", 
]

const RUSSIAN_NAMES: = [
	"artem", "bogdan", "boris", "danil", "denis", "dima", "egor", "fedor", 
	"gleb", "gosha", "grisha", "igor", "ilya", "kirill", "kostya", "kostik", 
	"leva", "lyosha", "maks", "maksim", "misha", "nikita", "oleg", "pasha", 
	"petya", "roma", "romchik", "ruslan", "sasha", "sanya", "senya", "sergey", 
	"stepan", "syoma", "timofey", "tolik", "vadim", "valera", "vasya", "viktor", 
	"vitalik", "vlad", "vladik", "vova", "yarik", "yura", "zakhar", "zhora", 
	"alena", "anastasia", "anya", "dasha", "katya", "ksenia", "lena", "liza", 
	"masha", "nadya", "natasha", "oksana", "olga", "polina", "sveta", "tanya", 
	"vera", "vika", "yana", "yulia", "zhanna", 
]

const NATURE: = [
	"storm", "thunder", "lightning", "rain", "snow", "wind", "cloud", "fog", 
	"mist", "frost", "fire", "flame", "spark", "ember", "ash", 
	"dust", "sand", "stone", "rock", "mountain", "hill", "valley", "river", 
	"lake", "sea", "ocean", "wave", "tide", "beach", "island", "forest", 
	"wood", "tree", "leaf", "branch", "root", "grass", "moss", "flower", 
	"rose", "lotus", "tulip", "daisy", "cactus", "palm", "bamboo", "maple", 
	"oak", "pine", "birch", "cedar", "willow", "berry", "seed", "field", 
	"meadow", "garden", "park", "cave", "cliff", "canyon", "desert", "swamp", 
	"glacier", "volcano", "geyser", "spring", "waterfall", "sunrise", "sunset", "dawn", 
	"dusk", "noon", "midnight", "star", "moon", "sun", "sky", "space", 
	"galaxy", "comet", "meteor", "planet", "orbit", "nebula", "eclipse", "horizon", 
	"aurora", "zenith", 
]

const VERBS: = [
	"run", "jump", "fly", "swim", "dive", "climb", "crawl", "walk", 
	"ride", "drive", "shoot", "strike", "slash", "stab", "punch", "kick", 
	"throw", "catch", "grab", "break", "smash", "crush", "burn", 
	"freeze", "melt", "glow", "shine", "dash", "sneak", 
	"hide", "seek", "hunt", "chase", "track", "trap", 
	"lose", "fight", "die", "live", "rise", "fall", "stand", 
	"sit", "sleep", "wake", "dream", "think", "know", "learn", "teach", 
	"play", "work", "build", "make", "craft", "fix", "hack", "code", 
	"type", "click", "tap", "swipe", 
	"heal", "save", "help", "lead", "follow", "join", "leave", "start", 
	"stop", "wait", "watch", "listen", "speak", "shout", "whisper", "laugh", 
	"cry", "smile", "fear", "hope", "trust", "dare", "try", "test", 
	"prove", "search", "find", "explore", 
]

const CITIES: = [
	"moscow", "spb", "piter", "kazan", "sochi", "omsk", "perm", "ufa", 
	"samara", "tula", "orel", "kursk", "bryansk", "smolensk", "tver", "ryazan", 
	"voronezh", "rostov", "krasnodar", "stavropol", "volgograd", "astrakhan", "saratov", "penza", 
	"izhevsk", "chelyabinsk", "ekb", "tyumen", "novosibirsk", "tomsk", "krasnoyarsk", "irkutsk", 
	"khabarovsk", "vladivostok", "yakutsk", "murmansk", "arkhangelsk", "pskov", "novgorod", "kaliningrad", 
	"minsk", "kiev", "odessa", "kharkov", "almaty", "astana", "baku", "tbilisi", 
	"yerevan", "tashkent", "bishkek", "dushanbe", "tokyo", "seoul", "beijing", "shanghai", 
	"delhi", "mumbai", "cairo", "dubai", "istanbul", "athens", "rome", "madrid", 
	"paris", "london", "berlin", "prague", "vienna", "warsaw", "budapest", "oslo", 
	"stockholm", "helsinki", "dublin", "lisbon", "amsterdam", "brussels", "zurich", "toronto", 
	"chicago", "boston", "denver", "dallas", "austin", "seattle", "miami", "vegas", 
	"houston", "sydney", "melbourne", "auckland", "perth", "brisbane", "adelaide", 
	"canberra", "hobart", "darwin", "wellington", 
]


const TAGS: = [
	"pro", "noob", "gg", "wp", "ez", "tv", "yt", "tw", 
	"cs", "fps", "aim", "clip", "play", "game", "live", "real", 
	"top", "best", "one", "solo", "duo", "trio", "squad", "clan", 
	"crew", "mode", "op", "god", "king", "boss", "main", "alt", 
	"smurf", "boost", "carry", "rush", "camp", "lurk", "flick", "spray", 
]


const LISTS: = [
	ADJECTIVES, NOUNS, FOOD, GAMING, NAMES, RUSSIAN_NAMES, NATURE, VERBS, 
	CITIES, 
]


static func word_count() -> int:
	var total: = 0
	for list in LISTS:
		total += list.size()
	return total
