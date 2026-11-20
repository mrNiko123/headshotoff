extends RefCounted

# Скины игрока (персонажа). Это не оружейные скины: они не попадают
# в инвентарь оружия и не торгуются на рынке — только покупка в разделе
# «СКИНЫ» и экипировка.


const DEFAULT_ID: = "default"
const ANGEL_ID: = "angel"


const SKINS: = [
	{
		"id": "default", 
		"name": "РЕКРУТ", 
		"tag": "СТАРТОВЫЙ", 
		"rarity": "common", 
		"price": 0, 
		"model": "res://assets/skins/player_default/player.obj", 
		"desc": "Стандартная экипировка бойца HEADSHOT OFF: оливковая броня и тёмный шлем.", 
		"palette": {
			"torso": "333d33", 
			"shirt": "9e4d47", 
			"pants": "424d38", 
			"pants_dark": "2e3629", 
			"boots": "1f1f1f", 
			"skin": "c28f66", 
			"glove": "3d3d38", 
			"helmet": "293326", 
			"accent": "ccad57", 
			"eye": "17171a", 
			"sole": "141414", 
		}, 
	}, 
	{
		"id": "angel", 
		"name": "АНГЕЛ", 
		"tag": "ЭКСКЛЮЗИВ", 
		"rarity": "legendary", 
		"price": 4800, 
		"model": "res://assets/skins/player_angel/player_angel.obj", 
		"desc": "Белоснежная броня с золотой отделкой, крылья и нимб. Скин игрока: на рынке не продаётся и не покупается.", 
		"palette": {
			"torso": "f5f2eb", 
			"shirt": "fcfcff", 
			"pants": "dbe8fa", 
			"pants_dark": "a9c2e8", 
			"boots": "d1a133", 
			"skin": "f0c4a1", 
			"glove": "fcfcff", 
			"helmet": "d1a133", 
			"accent": "ffd452", 
			"eye": "3885f2", 
			"sole": "8a6a1e", 
		}, 
	}, 
]


static func all() -> Array:
	return SKINS


static func get_skin(skin_id: String) -> Dictionary:
	for skin in SKINS:
		if str(skin.get("id", "")) == skin_id:
			return skin
	return SKINS[0]


static func has_skin(skin_id: String) -> bool:
	for skin in SKINS:
		if str(skin.get("id", "")) == skin_id:
			return true
	return false


static func model_path(skin_id: String) -> String:
	var skin: Dictionary = get_skin(skin_id)
	return str(skin.get("model", ""))


static func ragdoll_colors(skin_id: String) -> Dictionary:
	var skin: Dictionary = get_skin(skin_id)
	var raw: Dictionary = skin.get("palette", {})
	var out: Dictionary = {}
	for key in raw:
		out[str(key)] = Color(str(raw[key]))
	return out


static func brighten_mesh(mesh: Mesh) -> void :
	if mesh == null:
		return
	for i in mesh.get_surface_count():
		var source: Material = mesh.surface_get_material(i)
		if source is StandardMaterial3D:
			var mat: StandardMaterial3D = (source as StandardMaterial3D).duplicate()
			mat.metallic = 0.05
			mat.roughness = 0.55
			mat.rim_enabled = true
			mat.rim = 0.25
			mesh.surface_set_material(i, mat)
