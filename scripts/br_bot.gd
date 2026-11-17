extends "res://scripts/dm_bot.gd"




# БОТ БАТЛ РОЯЛЯ: наследует весь DM-ИИ, но удерживается внутри
# сужающейся зоны. Игра периодически подаёт ему актуальные точки.

func set_zone_points(points: Array) -> void :
	# Подменяем список точек удержания/охоты точками внутри зоны.
	var fresh: Array[Vector3] = []
	for p in points:
		if p is Vector3:
			fresh.append(p)
	if fresh.is_empty():
		return
	_hold_points = fresh
	_hunt_points = fresh.duplicate()
	if not alive or _state == State.DEAD:
		return
	if _state == State.ENGAGE:
		return
	# Если текущая точка удержания далеко от нового набора —
	# перезаказываем маршрут внутрь зоны.
	var keep: = false
	for p in fresh:
		if p.distance_to(_hold_point) < 14.0:
			keep = true
			break
	if not keep or _hold_point == Vector3.ZERO:
		_choose_hold()
