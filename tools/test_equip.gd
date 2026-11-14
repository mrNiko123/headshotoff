extends Node

# Тест: экипировка базового скина ножа через Settings.

func _ready() -> void :
	var s: Node = get_node("/root/Settings")
	print("OWNED_COMBAT=", s.owns_item("knife", "combat"))
	print("HAS_SKIN=", s._has_skin("knife", "combat"))
	print("BEFORE knife_skin=", s.knife_skin)
	var ok: bool = s.set_loadout("knife", "combat")
	print("SET_LOADOUT=", ok)
	print("AFTER knife_skin=", s.knife_skin)
	print("IS_EQUIPPED=", s.is_equipped("knife", "combat"))
	get_tree().quit()
