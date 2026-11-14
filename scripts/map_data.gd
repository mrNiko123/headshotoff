extends RefCounted




const MAPS: = [
	{
		"id": "yard", 
		"name": "ПОЛЯНА", 
		"kicker": "НОВАЯ · 56 × 56 М", 
		"desc": "Зелёный полигон HEADSHOT: две боковые площадки, центральные "
			+ "колонны с крышей и ровные линии прострела. Всё честно видно.", 
		"tags": ["СБАЛАНСИРОВАННАЯ", "ДВЕ ПЛОЩАДКИ", "РАМПЫ"], 
		"scene": "res://scenes/arena_yard.tscn", 
		"preview": "res://assets/maps/yard.png", 
	}, 
	{
		"id": "mesa", 
		"name": "КАНЬОН", 
		"kicker": "НОВАЯ · 56 × 56 М", 
		"desc": "Пустынный каньон: центральный мост через пропасть, две "
			+ "террасы по бокам и скальные блоки. Длинные дуэли на дальних линиях.", 
		"tags": ["ПУСТЫННАЯ", "МОСТ", "ТЕРРАСЫ"], 
		"scene": "res://scenes/arena_mesa.tscn", 
		"preview": "res://assets/maps/mesa.png", 
	}, 
	{
		"id": "lego", 
		"name": "ЛЕГО", 
		"kicker": "НОВАЯ · 56 × 56 М", 
		"desc": "Лего-крепость в духе AWP LEGO: цельная жёлтая платформа "
			+ "с башней с окнами, широкая рампа и длинные линии прострела "
			+ "через цветные квадранты арены.", 
		"tags": ["AWP", "КРЕПОСТЬ", "БАШНЯ"], 
		"scene": "res://scenes/arena_lego.tscn", 
		"preview": "res://assets/maps/lego.png", 
	}, 
]

const RANKED_MAPS: = [
	"res://scenes/arena_crusher.tscn", 
	"res://scenes/arena_fort.tscn", 
	"res://scenes/arena_lego.tscn", 
	"res://scenes/arena_yard.tscn", 
	"res://scenes/arena_mesa.tscn", 
]


# Рейтинг: случайная карта из двух своих арен.
static func random_ranked_scene() -> String:
	return str(RANKED_MAPS[randi() % RANKED_MAPS.size()])


static func has_map(id: String) -> bool:
	for entry in MAPS:
		if str(entry["id"]) == id:
			return true
	return false


static func get_map(id: String) -> Dictionary:
	for entry in MAPS:
		if str(entry["id"]) == id:
			return entry
	return MAPS[0]


static func arena_path(id: String) -> String:
	return str(get_map(id)["scene"])
